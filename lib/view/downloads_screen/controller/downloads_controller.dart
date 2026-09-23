
import 'dart:async';
import 'package:get/get.dart';
import 'package:movie_app/view/downloads_screen/models/download.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:movie_app/utils/encrption_service.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';


class DownloadsController extends GetxController {
  static const String downloadsBoxName = 'downloadsBox';
  late Box<DownloadItem> downloadsBox;
  var downloads = <DownloadItem>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isHiveReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(DownloadStatusAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(DownloadItemAdapter());
    downloadsBox = await Hive.openBox<DownloadItem>(downloadsBoxName);
    loadDownloads();
    isHiveReady.value = true;
    print('Hive is ready.');
  }

  void loadDownloads() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      downloads.clear();
      // Load from Hive
      downloads.addAll(downloadsBox.values);
      print('Loaded ${downloads.length} downloads from Hive.');
    } catch (e) {
      errorMessage.value = 'Failed to load downloads.';
      print('Error in loadDownloads: ' + e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveDownloadsToHive() async {
    await downloadsBox.clear();
    for (var item in downloads) {
      await downloadsBox.add(item);
    }
    print('Saved ${downloads.length} downloads to Hive.');
  }

  @override
  void onClose() {
    downloadsBox.close();
    super.onClose();
  }

  Future<void> addDownload({
    required String title,
    required String videoUrl,
    String? thumbnailUrl,
    String? details,
  }) async {
    if (!isHiveReady.value || !downloadsBox.isOpen) {
      errorMessage.value = 'Download system not ready. Please try again in a moment.';
      print('Download system not ready. Hive isHiveReady:  [31m${isHiveReady.value} [0m, box open:  [31m${downloadsBox.isOpen} [0m');
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$title.mp4';

    downloads.insert(0, DownloadItem(
      title: title,
      thumbnailUrl: thumbnailUrl,
      details: details,
      status: DownloadStatus.inProgress,
      errorMessage: null,
      filePath: filePath,
      progress: 0.0,
    ));
    await _saveDownloadsToHive();
    print('Started download for $title from $videoUrl');

    try {
      final index = downloads.indexWhere((d) => d.title == title);
      await Dio().download(
        videoUrl,
        filePath,
        onReceiveProgress: (received, total) async {
          if (total != -1 && index != -1) {
            final prog = received / total;
            downloads[index] = downloads[index].copyWith(progress: prog);
            await _saveDownloadsToHive();
            print('Download progress for $title: ${(prog * 100).toStringAsFixed(1)}%');
          }
        },
      );
      print('Download completed for $title. Encrypting...');
      final encryptedPath = await EncrptionService.encryptFile(filePath);
      print('Encryption complete for $title. Encrypted file at $encryptedPath');
      final originalFile = File(filePath);
      if (await originalFile.exists()) {
        await originalFile.delete();
        print('Original file deleted for $title');
      }
      if (index != -1) {
        downloads[index] = downloads[index].copyWith(
          status: DownloadStatus.completed,
          filePath: encryptedPath,
          progress: 1.0,
        );
        await _saveDownloadsToHive();
        print('DownloadItem updated to completed for $title');
      }
    } catch (e) {
      final index = downloads.indexWhere((d) => d.title == title);
      if (index != -1) {
        downloads[index] = downloads[index].copyWith(
          status: DownloadStatus.failed,
          errorMessage: 'Download failed. Tap to retry.',
        );
        await _saveDownloadsToHive();
      }
      errorMessage.value = 'Download failed: ' + e.toString();
      print('Error downloading $title: ' + e.toString());
    }
  }
}