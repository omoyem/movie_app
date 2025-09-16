import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/view/downloads/controller/downloads_controller.dart';
import 'package:godly_seed_app/view/downloads/models/download.dart';

import 'package:godly_seed_app/view/movie/screens/play_movie.dart';
import 'package:godly_seed_app/constants/color_palette.dart';

class DownloadsScreen extends StatefulWidget {
  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {

       final DownloadsController controller = Get.find<DownloadsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Ensure no back button is shown
        title: Text(
          'Downloads',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Obx(() => controller.downloads.isNotEmpty
              ? PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.black),
                  onSelected: (value) {
                    if (value == 'clear_all') {
                      _showClearAllDialog(context);
                    } else if (value == 'storage_info') {
                      _showStorageInfo(context);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'storage_info',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 20),
                          SizedBox(width: 8),
                          Text('Storage Info'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'clear_all',
                      child: Row(
                        children: [
                          Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Clear All', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                )
              : SizedBox()),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.errorMessage.value.isNotEmpty) {
              final context = Get.context;
              if (context != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(controller.errorMessage.value),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                controller.errorMessage.value = '';
              }
            }
          });

          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.downloads.isEmpty) {
            return _buildEmptyState();
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download, size: 80, color: Colors.grey[300]),
          SizedBox(height: 20),
          Text(
            'No downloads yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Downloaded movies will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadItem(BuildContext context, DownloadItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: _buildThumbnail(item),
            title: Text(
              item.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.details != null && item.details!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      item.details!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ),
                SizedBox(height: 8),
                _buildStatusWidget(item),
              ],
            ),
            trailing: _buildActionButton(context, item),
            onTap: () => _handleItemTap(context, item),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(DownloadItem item) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty
            ? Image.network(
                item.thumbnailUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: Icon(Icons.movie, color: Colors.grey[400]),
                  );
                },
              )
            : Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: Icon(Icons.movie, color: Colors.grey[400]),
              ),
      ),
    );
  }

  Widget _buildStatusWidget(DownloadItem item) {
    switch (item.status) {
      case DownloadStatus.inProgress:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Downloading...',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Text(
                  '${(item.progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            LinearProgressIndicator(
              value: item.progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 4,
            ),
          ],
        );
      case DownloadStatus.completed:
        return Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            SizedBox(width: 4),
            Text(
              'Downloaded',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      case DownloadStatus.failed:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 16),
                SizedBox(width: 4),
                Text(
                  'Download failed',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (item.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  item.errorMessage!,
                  style: TextStyle(
                    color: Colors.red[300],
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        );
      default:
        return SizedBox();
    }
  }

  Widget _buildActionButton(BuildContext context, DownloadItem item) {
    switch (item.status) {
      case DownloadStatus.inProgress:
        return IconButton(
          icon: Icon(Icons.close, color: Colors.red),
          onPressed: () => _showCancelDialog(context, item),
        );
      case DownloadStatus.completed:
        return PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onSelected: (value) {
            if (value == 'play') {
              _playMovie(context, item);
            } else if (value == 'delete') {
              _showDeleteDialog(context, item);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'play',
              child: Row(
                children: [
                  Icon(Icons.play_arrow, size: 20),
                  SizedBox(width: 8),
                  Text('Play'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        );
      case DownloadStatus.failed:
        return IconButton(
          icon: Icon(Icons.refresh, color: primaryColor),
          onPressed: () => controller.retryDownload(item),
        );
      default:
        return SizedBox();
    }
  }

  void _handleItemTap(BuildContext context, DownloadItem item) {
    if (item.status == DownloadStatus.completed) {
      _playMovie(context, item);
    } else if (item.status == DownloadStatus.failed) {
      controller.retryDownload(item);
    }
  }

  void _playMovie(BuildContext context, DownloadItem item) async {
    if (item.filePath != null) {
      final decryptedPath = await controller.getDecryptedFilePath(item.filePath!);
      if (decryptedPath != null) {
        Get.to(() => VideoPlayerScreen(
          movieTitle: item.title,
          videoUrl: decryptedPath,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play movie. File may be corrupted.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCancelDialog(BuildContext context, DownloadItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Download'),
        content: Text('Are you sure you want to cancel downloading "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.cancelDownload(item.title);
            },
            child: Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, DownloadItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Download'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteDownload(item);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Downloads'),
        content: Text('Are you sure you want to delete all downloads? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.clearAllDownloads();
            },
            child: Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showStorageInfo(BuildContext context) async {
    final totalSize = await controller.getTotalDownloadSize();
    final sizeInMB = (totalSize / (1024 * 1024)).toStringAsFixed(2);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Storage Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Downloads: ${controller.downloads.length}'),
            SizedBox(height: 8),
            Text('Storage Used: ${sizeInMB} MB'),
            SizedBox(height: 8),
            Text('All downloads are encrypted and stored securely in the app\'s private storage.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}