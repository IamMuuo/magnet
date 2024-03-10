import 'dart:convert';

import 'package:magnet/magnet.dart';

import 'package:http/http.dart' as http;

extension MagnetNotificationExtension on Magnet {
  static const String _backendUrl = "http://academia.erick.serv00.net";
  Future<List> fetchNotifications() async {
    var response = await http.get(Uri.parse("$_backendUrl/notifications/"));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception("Couldn't fetch notifications, please try again later");
  }
}
