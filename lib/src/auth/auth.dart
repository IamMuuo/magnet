import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:magnet/src/config/config.dart';

class Auth {
  /// Pings the home page and extract the token
  /// Incase the session token is not extracted it humbly returns an
  /// exception
  static Future<Either<Exception, String>> fetchSessionToken() async {
    try {
      final response = await http.get(Uri.parse("${Config.baseUrl}/"));

      if (response.statusCode != 200) {
        return Left(
          Exception("Failed to commumnicate to server please try again later"),
        );
      }

      // Session token extraction
      final sessionToken =
          response.headers["set-cookie"].toString().split(" ")[0];
      assert(sessionToken.isNotEmpty, "Failed to retrieve session token");

      return Right(sessionToken);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  /// Login
  /// The method attempts to verify the user against the student portal
  /// with the provided user credentials + session
  static Future<Either<Exception, String>> login(
      String sessionID, String admno, String password) async {
    assert(
      sessionID.isNotEmpty,
      "sessionID is empty ensure you query for it before attempting to login",
    );
    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/Login/LoginUser"),
        headers: {
          'Content-type': 'application/json',
          "Cookie": sessionID,
        },
        body: json.encode(
          {"Username": admno, "Password": password},
        ),
      );

      if (response.statusCode != 200) {
        return Left(
          Exception(
            "Failed to send request to server check your connection and try again, ${response.statusCode}",
          ),
        );
      }

      final body = json.decode(response.body);

      if (!body["success"]) {
        return Left(Exception("${body['message']}"));
      }

      final userSession = '$sessionID ${response.headers["set-cookie"]}';

      assert(userSession.isNotEmpty, "Failed to retrieve student sessionID");
      return Right(userSession);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
