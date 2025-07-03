import 'package:flutter/material.dart';

import '../../constants/images.dart';
import '../../utils/helpers.dart';
import 'no_internet_widget.dart';
import 'no_result_widget.dart';

class ListHandling extends StatelessWidget {
  final bool? hasNextPage;
  final bool showPaginationLoader;
  final bool isConnected;
  final bool isEmpty;
  final bool? isNetworkTimeout;
  final VoidCallback onRetry;

  const ListHandling(
      {Key? key,
      this.hasNextPage,
      required this.showPaginationLoader,
      required this.isConnected,
      required this.isEmpty,
      required this.isNetworkTimeout,
      required this.onRetry})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hasNextPage != null && showPaginationLoader && isConnected) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (isNetworkTimeout != null) {
      if ((isEmpty && isConnected && isNetworkTimeout!) ||
          (isEmpty && !isConnected)) {
        return NoInternetWidget(onRetry: onRetry);
      }

      if ((isEmpty && isConnected && !isNetworkTimeout!)) {
        return const NoResultWidget(title: "No Videos found");
      }
    }
    return Container();
  }
}
