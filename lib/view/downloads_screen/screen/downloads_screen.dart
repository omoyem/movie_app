import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/view/downloads_screen/controller/downloads_controller.dart';
import 'package:godly_seed_app/view/downloads_screen/models/download.dart';
import 'package:godly_seed_app/view/movie/screens/play_movie.dart';
import 'package:godly_seed_app/utils/encrption_service.dart';


class DownloadsScreen extends GetView<DownloadsController> {
  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DownloadsController>()) {
      Get.put(DownloadsController());
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Downloads',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {
             
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.errorMessage.value.isNotEmpty) {
              final context = Get.context;
              if (context != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(controller.errorMessage.value)),
                );
                controller.errorMessage.value = '';
              }
            }
          });
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  SizedBox(height: 16),
                  Text('Something went wrong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text(controller.errorMessage.value, style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadDownloads, // You may need to implement this
                    child: Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }
          if (controller.downloads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text('No downloads yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: controller.downloads.length,
            separatorBuilder: (context, index) => SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = controller.downloads[index];
              return _buildDownloadItem(context, item);
            },
          );
        }),
      ),
    );
  }

  Widget _buildDownloadItem(BuildContext context, DownloadItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: SizedBox(
          width: 60,
          height: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty
                ? Image.network(item.thumbnailUrl!, width: 60, height: 60, fit: BoxFit.cover)
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, color: Colors.grey[400]),
                  ),
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.details != null && item.details!.isNotEmpty)
              Text(item.details!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            if (item.status == DownloadStatus.failed && item.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(item.errorMessage!, style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            if (item.status == DownloadStatus.inProgress)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: item.progress, minHeight: 6),
                    SizedBox(height: 4),
                    Text('${(item.progress * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
              ),
          ],
        ),
        trailing: _buildStatusIcon(item.status),
        onTap: () async {
          if (item.status == DownloadStatus.completed && item.filePath != null) {
            String fileToPlay = item.filePath!;
            if (fileToPlay.endsWith('.enc')) {
             
              fileToPlay = await EncrptionService.decryptFile(fileToPlay);
            }
            Get.to(() => VideoPlayerScreen(
              movieTitle: item.title,
              videoUrl: fileToPlay, 
            ));
          }
        },
      ),
    );
  }

  Widget _buildStatusIcon(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.completed:
        return Icon(Icons.check_circle, color: Colors.green, size: 28);
      case DownloadStatus.failed:
        return Icon(Icons.refresh, color: Colors.red, size: 28);
      case DownloadStatus.inProgress:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      default:
        return Icon(Icons.hourglass_empty, color: Colors.grey, size: 28);
    }
  }
} 