import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/endpoints.dart';
import 'package:godly_seed_app/data/local/secure_storage_helper.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../view/login/screens/login_screen.dart';



double deviceHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double deviceWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

// Future<void> launchMapsUrl(double lat, double lon) async {
//   if (Platform.isIOS) {
//     var urlAppleMaps = 'https://maps.apple.com/?q=$lat,$lon';
//     if (await canLaunchUrl(Uri.parse(urlAppleMaps))) {
//       await launchUrl(Uri.parse(urlAppleMaps));
//     } else {
//       throw 'Could not launch $urlAppleMaps';
//     }
//   } else {
//     MapsLauncher.launchCoordinates(lat, lon);
//   }
// }

logout() {
  LocalStorageHelper localStorageHelper = LocalStorageHelper();
 
 localStorageHelper.clearAll();
  Get.offAll( SignInScreen());
}

String specialFormatDate(DateTime date) {
  final formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(date);
}

String formatDateFromString({
  required String dateString
}) {
  final inputFormatter = DateFormat("yyyy-MM-dd");
  final date = inputFormatter.parseStrict(dateString);
  final outputFormatter = DateFormat('yyyy-MM-dd');
  return outputFormatter.format(date);
}

logItem(dynamic item, {String? title = "Default Log Title"}) {
  if (kDebugMode) {
    print(title);
    print(item);
  }
}

showSnackBar({required title, required message, required type, int? duration = 4}) {
  var color = type == "error"
      ? Colors.red
      : (type == "success"
      ? Colors.green
      : (type == "warn" ? Colors.amber : Colors.blue));
  Get.snackbar(title, message,
      backgroundColor: color,
      snackPosition: SnackPosition.BOTTOM,
      colorText: type == "warn" ? Colors.black : Colors.white,
      duration: Duration(seconds: duration!));
}


Future<void> launchExternalUrl(String urlString) async {
  if (await canLaunchUrl(Uri.parse(urlString))) {
    // Check if the URL can be launched
    await launchUrl(Uri.parse(urlString));
  } else {
    throw 'Could not launch $urlString'; // throw could be used to handle erroneous situations
  }
}

Future copyText(String input, {String? message}) async {
  await Clipboard.setData(ClipboardData(text: input)).then((value) => {
        showSnackBar(
            title: "Success",
            message: message ?? "Copied Successfully",
            type: "success")
      });
}



getParamsFromUri(String url) {
  // Parse the URL
  Uri uri = Uri.parse(url);

  return uri.queryParameters;
}

Future<dynamic> customDialog({required List<Widget> children}) {
  return Get.bottomSheet(
    Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
      ),
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: children,
        ),
      ),
    ),
  );
}



// Future<StreamSubscription> getConnectivity() async {
//   return Connectivity().onConnectivityChanged.listen(
//         (ConnectivityResult result) async {},
//       );
// }

String extractYear(String date) {
  try {
    final parsedDate = DateTime.parse(date);
    return parsedDate.year.toString();
  } catch (e) {
    return 'Invalid date';
  }
}
String? validatePhoneInput(String email) {
  if (email.isEmpty) return "Phone number is required";

  if (email.length != 11) {
    return "Enter a valid phone number";
  }
  return null;
}

bool isEmailValid(String email) {
  return RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);
}


hideKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(new FocusNode());
}

getImageUrl(String url) {
  return Endpoints.imageBaseUrl + url;
}

Future<DecorationImage> getNetworkImageWidget(String url) async {

  var token = await LocalStorageHelper.getAccessTokenMain();

  return DecorationImage(
    image: NetworkImage(getImageUrl(url)),
    fit: BoxFit.cover,
  );
}

showNoInternetSnackBar() {
  showSnackBar(
      title: "Network Error", message: "No Internet Connection", type: 'error');
}

Future<String?> getDeviceId() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (defaultTargetPlatform == TargetPlatform.android) {
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id; // Android device ID
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor; // iOS device ID
  }
  return null; // Fallback for other platforms
}

String maskEmail(String email) {
  final emailParts = email.split('@');
  if (emailParts.length != 2) {
    throw ArgumentError('Invalid email format');
  }

  final localPart = emailParts[0];
  final domainPart = emailParts[1];

  if (localPart.length <= 3) {
    // If the local part is very short, mask all characters except the first one
    return '${localPart[0]}*******@$domainPart';
  }

  // Mask all characters after the first 3 with asterisks
  final visiblePart = localPart.substring(0, 3);
  final maskedPart = '*' * (localPart.length - 3);

  return '$visiblePart$maskedPart@$domainPart';
}

Color hexToColor(String hexColor) {
  /// The [hexColor] can be in the format "#RRGGBB", "RRGGBB", or "#AARRGGBB".
  hexColor = hexColor.toUpperCase().replaceAll('#', '');

  if (hexColor.length == 6) {
    hexColor = 'FF$hexColor'; // Add opacity if not specified
  }

  return Color(int.parse(hexColor, radix: 16));
}

String truncateString(String input) {
  const int maxLength = 30; // Maximum allowed characters
  if (input.length > maxLength) {
    return input.substring(0, maxLength) + '...'; // Truncate and add '...'
  }
  return input; // Return as is if within limit
}
