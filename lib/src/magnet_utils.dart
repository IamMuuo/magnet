import 'dart:convert';

import 'package:magnet/magnet.dart';

import 'package:http/http.dart' as http;

extension MagnetNotificationExtension on Magnet {
  static const String _backendUrl = "http://35.212.209.181:80";
  Future<List> fetchNotifications() async {
    var response = await http.get(Uri.parse("$_backendUrl/notifications/"));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception("Couldn't fetch notifications, please try again later");
  }
}
