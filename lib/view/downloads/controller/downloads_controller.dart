import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import 'package:godly_seed_app/view/downloads/models/download.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:godly_seed_app/utils/encrption_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DownloadsController extends GetxController {
  static const String downloadsBoxName = 'downloadsBox';
  late Box<DownloadItem> downloadsBox;
  var downloads = <DownloadItem>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isHiveReady = false.obs;

  final Map<String, CancelToken> _activeDowloads = {};

  @override
  void onInit() {
    super.onInit();
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(DownloadStatusAdapter());
      if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(DownloadItemAdapter());
      downloadsBox = await Hive.openBox<DownloadItem>(downloadsBoxName);
      loadDownloads();
      isHiveReady.value = true;
      print('Hive initialized successfully');
    } catch (e) {
      errorMessage.value = 'Failed to initialize storage: ${e.toString()}';
      print('Error initializing Hive: $e');
    }
  }

  void loadDownloads() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      downloads.clear();
  
      final items = downloadsBox.values.toList();
      for (var item in items) {
        if (item.status == DownloadStatus.completed && item.filePath != null) {
          final file = File(item.filePath!);
          if (await file.exists()) {
            downloads.add(item);
          } else {
          
            await _removeDownloadFromHive(item);
          }
        } else {
          downloads.add(item);
        }
      }
      
      print('Loaded ${downloads.length} downloads from storage');
    } catch (e) {
      errorMessage.value = 'Failed to load downloads: ${e.toString()}';
      print('Error loading downloads: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveDownloadsToHive() async {
    try {
      await downloadsBox.clear();
      for (var item in downloads) {
        await downloadsBox.add(item);
      }
      print('Saved ${downloads.length} downloads to storage');
    } catch (e) {
      print('Error saving downloads to Hive: $e');
    }
  }

  Future<void> _removeDownloadFromHive(DownloadItem item) async {
    try {
      final key = downloadsBox.keys.firstWhere(
        (k) => downloadsBox.get(k)?.title == item.title,
        orElse: () => null,
      );
      if (key != null) {
        await downloadsBox.delete(key);
      }
    } catch (e) {
      print('Error removing download from Hive: $e');
    }
  }

  Future<String> _getSecureDownloadPath() async {

    final dir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${dir.path}/secure_downloads');
    
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    
    return downloadDir.path;
  }

  Future<bool> _checkPermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      print('[DEBUG] Android SDK version:  [${androidInfo.version.sdkInt}]');
      if (androidInfo.version.sdkInt >= 33) {
      
        final videoStatus = await Permission.videos.status;
        print('[DEBUG] Permission.videos status:  [${videoStatus}]');
        if (!videoStatus.isGranted) {
          final result = await Permission.videos.request();
          print('[DEBUG] Permission.videos request result:  [${result}]');
          return result.isGranted;
        }
        return true;
      } else {
      
        final storageStatus = await Permission.storage.status;
        print('[DEBUG] Permission.storage status:  [${storageStatus}]');
        if (!storageStatus.isGranted) {
          final result = await Permission.storage.request();
          print('[DEBUG] Permission.storage request result:  [${result}]');
          return result.isGranted;
        }
        return true;
      }
    }
 
    print('[DEBUG] Not Android, permission granted by default.');
    return true;
  }

  String _generateSecureFileName(String title) {
   
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    final sanitizedTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
    return '${sanitizedTitle}_${timestamp}_$random.enc';
  }

  Future<void> addDownload({
    required String title,
    required String videoUrl,
    String? thumbnailUrl,
    String? details,
  }) async {
    if (!isHiveReady.value || !downloadsBox.isOpen) {
      errorMessage.value = 'Download system not ready. Please try again.';
      print('Download system not ready');
      return;
    }
    if (downloads.any((d) => d.title == title && 
        (d.status == DownloadStatus.inProgress || d.status == DownloadStatus.completed))) {
      errorMessage.value = 'This movie is already downloaded or downloading.';
      return;
    }

   
    if (!await _checkPermissions()) {
      errorMessage.value = 'Storage permission required for downloads.';
      return;
    }

    try {
      final secureDir = await _getSecureDownloadPath();
      final secureFileName = _generateSecureFileName(title);
      final tempFilePath = '$secureDir/temp_$secureFileName';
      final finalFilePath = '$secureDir/$secureFileName';

  
      final downloadItem = DownloadItem(
        title: title,
        thumbnailUrl: thumbnailUrl,
        details: details,
        status: DownloadStatus.inProgress,
        errorMessage: null,
        filePath: finalFilePath,
        progress: 0.0,
      );

      downloads.insert(0, downloadItem);
      await _saveDownloadsToHive();

      final cancelToken = CancelToken();
      _activeDowloads[title] = cancelToken;

      print('Starting download for: $title');
      
      await _performDownload(
        downloadItem: downloadItem,
        videoUrl: videoUrl,
        tempFilePath: tempFilePath,
        finalFilePath: finalFilePath,
        cancelToken: cancelToken,
      );

    } catch (e) {
      final index = downloads.indexWhere((d) => d.title == title);
      if (index != -1) {
        downloads[index] = downloads[index].copyWith(
          status: DownloadStatus.failed,
          errorMessage: 'Download failed: ${e.toString()}',
        );
        await _saveDownloadsToHive();
      }
      errorMessage.value = 'Download failed: ${e.toString()}';
      print('Error in addDownload: $e');
    } finally {
      _activeDowloads.remove(title);
    }
  }

  Future<void> _performDownload({
    required DownloadItem downloadItem,
    required String videoUrl,
    required String tempFilePath,
    required String finalFilePath,
    required CancelToken cancelToken,
  }) async {
    try {
      await Dio().download(
        videoUrl,
        tempFilePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) async {
          if (total != -1 && !cancelToken.isCancelled) {
            final progress = received / total;
            final index = downloads.indexWhere((d) => d.title == downloadItem.title);
            if (index != -1) {
              downloads[index] = downloads[index].copyWith(progress: progress);
              await _saveDownloadsToHive();
            }
          }
        },
      );

      if (cancelToken.isCancelled) {
      
        final tempFile = File(tempFilePath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
        return;
      }

      print('Download completed for: ${downloadItem.title}. Starting encryption...');

      final encryptedFilePath = await EncrptionService.encryptFile(tempFilePath);
      
     
      final encryptedFile = File(encryptedFilePath);
      if (await encryptedFile.exists()) {
        await encryptedFile.rename(finalFilePath);
      }

 
      final tempFile = File(tempFilePath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      final index = downloads.indexWhere((d) => d.title == downloadItem.title);
      if (index != -1) {
        downloads[index] = downloads[index].copyWith(
          status: DownloadStatus.completed,
          filePath: finalFilePath,
          progress: 1.0,
        );
        await _saveDownloadsToHive();
      }

      print('Download and encryption completed for: ${downloadItem.title}');
      
    } catch (e) {
      if (!cancelToken.isCancelled) {
      
        await _cleanupFailedDownload(tempFilePath, finalFilePath);
        rethrow;
      }
    }
  }

  Future<void> _cleanupFailedDownload(String tempFilePath, String finalFilePath) async {
    try {
      final tempFile = File(tempFilePath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      
      final finalFile = File(finalFilePath);
      if (await finalFile.exists()) {
        await finalFile.delete();
      }
    } catch (e) {
      print('Error cleaning up failed download: $e');
    }
  }

  Future<void> cancelDownload(String title) async {
    final cancelToken = _activeDowloads[title];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Download cancelled by user');
    }

    final index = downloads.indexWhere((d) => d.title == title);
    if (index != -1) {
      final item = downloads[index];
      if (item.status == DownloadStatus.inProgress) {
      
        if (item.filePath != null) {
          final file = File(item.filePath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
        
        downloads.removeAt(index);
        await _saveDownloadsToHive();
      }
    }
  }

  Future<void> retryDownload(DownloadItem item) async {
    if (item.status == DownloadStatus.failed) {
     
      downloads.removeWhere((d) => d.title == item.title);
      await _saveDownloadsToHive();
     
      await addDownload(
        title: item.title,
        videoUrl: '', 
        thumbnailUrl: item.thumbnailUrl,
        details: item.details,
      );
    }
  }

  Future<void> deleteDownload(DownloadItem item) async {
    try {
     
      if (item.filePath != null) {
        final file = File(item.filePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      downloads.removeWhere((d) => d.title == item.title);
      await _saveDownloadsToHive();
      
      print('Download deleted: ${item.title}');
    } catch (e) {
      errorMessage.value = 'Failed to delete download: ${e.toString()}';
      print('Error deleting download: $e');
    }
  }

  Future<String?> getDecryptedFilePath(String encryptedFilePath) async {
    try {
      return await EncrptionService.decryptFile(encryptedFilePath);
    } catch (e) {
      print('Error decrypting file: $e');
      return null;
    }
  }


  Future<int> getTotalDownloadSize() async {
    int totalSize = 0;
    for (var item in downloads) {
      if (item.status == DownloadStatus.completed && item.filePath != null) {
        final file = File(item.filePath!);
        if (await file.exists()) {
          totalSize += await file.length();
        }
      }
    }
    return totalSize;
  }

  
  Future<void> clearAllDownloads() async {
    try {
      
      for (var item in downloads) {
        if (item.filePath != null) {
          final file = File(item.filePath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }

     
      downloads.clear();
      await downloadsBox.clear();
      
      print('All downloads cleared');
    } catch (e) {
      errorMessage.value = 'Failed to clear downloads: ${e.toString()}';
      print('Error clearing downloads: $e');
    }
  }

  @override
  void onClose() {
   
    for (var cancelToken in _activeDowloads.values) {
      if (!cancelToken.isCancelled) {
        cancelToken.cancel('App closing');
      }
    }
    
    downloadsBox.close();
    super.onClose();
  }
}