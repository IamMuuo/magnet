import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:logger/logger.dart';
import 'package:magnet/src/config/config.dart';

/// The Repository class provides an efficient way to query for student
/// data.
class Repository {
  static final Logger _logger = Logger();
  static Future<Either<Exception, Map<String, dynamic>>> fetchCateringToken(
      String token) async {
    try {
      final response = await http.get(
        Uri.parse("${Config.baseUrl}/Dashboard/Dashboard"),
        headers: Config.generateHeader(token),
      );

      assert(
        response.statusCode == 200,
        "Failed to fetch catering token status code [${response.statusCode}]",
      );
      final document = parser.parse(response.body);
      final buttons = document.querySelectorAll("button");

      for (final button in buttons) {
        if (button.innerHtml.trim() == "Get Catering Token") {
          final res = await http.post(
            Uri.parse("${Config.baseUrl}/Dashboard/GenerateNewCateringToken"),
            headers: Config.generateHeader(token),
          );

          assert(
            response.statusCode == 200,
            "Failed to fetch catering token status code [${response.statusCode}]",
          );

          return Right(json.decode(res.body));
        }
      }
      return left(Exception("You are not eligible for meals"));
    } catch (e) {
      return left(Exception(e.toString()));
    }
  }

  // Fetch Academic Calendar
  static Future<Either<Exception, List<Map<String, dynamic>>>>
      fetchAcademicCalendar(String token) async {
    try {
      final response = await http.get(
        Uri.parse("${Config.baseUrl}/Dashboard/Dashboard"),
        headers: Config.generateHeader(token),
      );

      assert(response.statusCode == 200, "Error fetching semester timeline");

      var dashboard = response.body;
      var document = parser.parse(dashboard);

      final content =
          document.querySelector("button.btn.btn-sm.btn-success.form-control");

      var sem = content?.attributes["onclick"]
          ?.replaceRange(0, 16, "")
          .replaceAll("(", "")
          .replaceAll(")", "")
          .replaceAll(";", "")
          .replaceAll("'", "");

      // Attempt to fetch the String
      final res = await http.post(
        Uri.parse("${Config.baseUrl}/Common/GetAcademicCalender/"),
        body: json.encode({"Sem": sem}),
        headers: Config.generateHeader(token),
      );

      assert(res.statusCode == 200, "Error extracting semester timeline");

      var html = parser.parse(res.body);
      var table = html.querySelectorAll("tbody tr");

      var events = <Map<String, dynamic>>[];

      for (var row in table) {
        events.add({
          "name": row.children[0].innerHtml,
          "start": row.children[1].innerHtml,
          "stop": row.children[2].innerHtml,
        });
      }

      return Right(events);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  // Returns all transcripts for a user's enrolled programmes
  static Future<Either<Exception, List<String>>> fetchTranscript(
      String token) async {
    _logger.i("Fetching student transcript");
    final response = await fetchEnrolledProgrammes(token);

    final List<String> transcripts = [];
    return response.fold((error) {
      _logger.e(error);
      return left(error);
    }, (programmes) async {
      for (final programme in programmes) {
        // Fetch all user transcripts

        final response = await http.post(
          Uri.parse("${Config.baseUrl}/ViewDocuments/ProvisionalResults"),
          headers: Config.generateHeader(token),
          body: json.encode({"Prog": programme["Value"]!}),
        );

        if (response.statusCode == 200) {
          transcripts.add(json.decode(response.body)["message"]!);
          _logger.i("transcript fetched successfully");
          continue;
        }

        _logger.e(
          "The server responded with ${response.statusCode} please try the operation again later",
        );

        return left(
          Exception("Failed to fetch your transcripts please try again later"),
        );
      }
      return right(transcripts);
    });
  }

  static Future<Either<Exception, List<String>>> fetchStudentAudit(
      String token) async {
    _logger.i("Fetching student audit");
    final response = await fetchEnrolledProgrammes(token);

    final List<String> audits = [];
    return response.fold((error) {
      _logger.e(error);
      return left(error);
    }, (programmes) async {
      for (final programme in programmes) {
        final response = await http.post(
          Uri.parse("${Config.baseUrl}/ViewDocuments/GenerateStudentAudit"),
          headers: Config.generateHeader(token),
          body: json.encode({"Prog": programme["Value"]!}),
        );

        if (response.statusCode == 200) {
          audits.add(json.decode(response.body)["message"]!);
          continue;
        }

        _logger.e(
          "The server responded with ${response.statusCode} please try the operation again later",
        );

        return left(
          Exception("Failed to fetch your audits please try again later"),
        );
      }
      return right(audits);
    });
  }

  /// Fetches a student's fee statement
  static Future<Either<Exception, List<Map<String, dynamic>>>>
      fetchFeeStatement(String token) async {
    try {
      final response = await http.get(
        Uri.parse("${Config.baseUrl}/Financial/FeeStatement"),
        headers: Config.generateHeader(token),
      );

      assert(
        response.statusCode == 200,
        "Something went wrong while attempting to fetch fee statement status code [${response.statusCode}]",
      );
      var html = response.body;
      final statements = <Map<String, dynamic>>[];

      final document = parser.parse(html);
      final tableRows =
          document.querySelectorAll("table.table.table-striped tbody tr");

      for (var row in tableRows) {
        var content = {
          "posting_date": row.children[0].innerHtml,
          "ref": row.children[1].innerHtml,
          "description": row.children[2].innerHtml,
          "debit": row.children[3].innerHtml,
          "credit": row.children[4].innerHtml,
          "running_balance": row.children[5].innerHtml,
        };
        statements.add(content);
      }
      return Right(statements);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  // Fetches the student's class attendance
  static Future<Either<Exception, List<Map<String, int>>>>
      fetchUserClassAttendance(String token) async {
    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/Dashboard/GetUnitsClassAttendance"),
        headers: Config.generateHeader(token),
      );

      assert(
        response.statusCode == 200,
        "Something went wrong while fetching attendance code[${response.statusCode}]",
      );

      // Parse the response
      var document = parser.parse(response.body);

      var tableRows = document.querySelectorAll("table tr td div.col-12");

      var unitsList = <Map<String, int>>[];

      for (var row in tableRows) {
        unitsList.add({
          row.children[0].innerHtml: int.parse(
              row.children[1].children[0].attributes["aria-valuenow"] ?? "0")
        });
      }
      return Right(unitsList);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  /// Fetches the user data provided by the token
  static Future<Either<Exception, Map<String, String>>> fetchUserDetails(
      String token) async {
    try {
      final response = await http.get(
        Uri.parse("${Config.baseUrl}/Dashboard/Dashboard"),
        headers: Config.generateHeader(token),
      );

      assert(
        response.statusCode == 200,
        "Failed to fetch student data status code: ${response.statusCode}",
      );

      // Start the parsing
      final document = parser.parse(response.body);

      // Select all div elements with class "row mb-X"
      final dataBlocks = document.querySelectorAll('div[class^="row mb-"]');
      var data = <String, String>{};

      for (final dataBlock in dataBlocks) {
        final labelElement = dataBlock.querySelector('label');
        final valueElement = dataBlock.querySelector('.badge');

        if (labelElement != null && valueElement != null) {
          final key = labelElement.text.trim();
          final value = valueElement.text.trim();

          data[key
              .toLowerCase()
              .trim()
              .replaceAll(".", "")
              .replaceAll(" ", "")] = value.toLowerCase().trim();
        }
      }
      final elements = document.getElementsByClassName('rounded-circle');

      if (elements.isNotEmpty) {
        final imgElement = elements[0];
        final src = imgElement.attributes['src'];
        data["profile"] = src ?? "";
      }
      // print(dat/* a) */;
      return Right(data);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  static Future<Either<Exception, List<Map<String, String>>>>
      fetchUserTimeTable(String token) async {
    try {
      var response = await http.get(
        Uri.parse("${Config.baseUrl}/Course/StudentTimetable"),
        headers: Config.generateHeader(token),
      );

      assert(
        response.statusCode == 200,
        "Something went wrong while fetching data error code: ${response.statusCode}",
      );

      /// Starting the parsing
      final document = parser.parse(response.body);
      final table = document.querySelector('table.table.table-hover');

      var tbody = table!.querySelector("tbody");
      var rows = tbody!.querySelectorAll("tr");

      final List<Map<String, String>> dataList = [];
      for (int i = 1; i < rows.length; i++) {
        final cells = rows[i].querySelectorAll("td");
        final unit = cells[0].text.trim();
        final section = cells[1].text.trim();
        final dayOfWeek = cells[2].text.trim();
        final period = cells[3].text.trim();
        final campus = cells[4].text.trim();
        final lectureRoom = cells[5].text.trim();
        final lecturer = cells[6].text.trim();

        dataList.add({
          'unit': unit,
          'section': section,
          'day_of_the_week': dayOfWeek,
          'period': period,
          'campus': campus,
          'room': lectureRoom,
          'lecturer': lecturer,
        });
      }
      return Right(dataList);
    } catch (e) {
      return left(Exception(e.toString()));
    }
  }

  /// Fetches the entire timetable from the student's pov
  static Future<Either<Exception, List<Map<String, String>>>> fetchTimeTable(
      String token) async {
    try {
      final response = await http.get(
        Uri.parse("${Config.baseUrl}/Course/StudentTimetable"),
        headers: Config.generateHeader(token),
      );

      assert(
        response.statusCode == 200,
        "Something went wrong while fetching data error code: ${response.statusCode}",
      );

      final document = parser.parse(response.body);
      final table = document.querySelector('table.table.table-hover');

      var tbody = table!.querySelectorAll("tbody");
      var rows = tbody[1].querySelectorAll("tr");

      final List<Map<String, String>> dataList = [];
      for (int i = 1; i < rows.length; i++) {
        final cells = rows[i].querySelectorAll("td");
        final unit = cells[0].text.trim();
        final section = cells[1].text.trim();
        final dayOfWeek = cells[2].text.trim();
        final period = cells[3].text.trim();
        final campus = cells[4].text.trim();
        final lectureRoom = cells[5].text.trim();
        final lecturer = cells[6].text.trim();

        dataList.add({
          'unit': unit,
          'section': section,
          'day_of_the_week': dayOfWeek,
          'period': period,
          'campus': campus,
          'room': lectureRoom,
          'lecturer': lecturer,
        });
      }
      return Right(dataList);
    } catch (e) {
      return left(Exception(e.toString()));
    }
  }

  /// Fetches a student's enrolled programmes
  static Future<Either<Exception, List<Map<String, dynamic>>>>
      fetchEnrolledProgrammes(String token) async {
    try {
      _logger.t("Fetching enrolled programmes");
      final response = await http.get(
        Uri.parse("${Config.baseUrl}/ViewDocuments/GetEnrolledProgrammes"),
        headers: Config.generateHeader(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["ListOfValues"]
            .cast<Map<String, dynamic>>();
        _logger.i("Enrolled programmes fetched");
        return right(data);
      }

      _logger.e(
        "The server responded with an invalid response.. [${response.statusCode}] please wait it might be under maintenance",
      );

      throw "The server responded with an invalid response [${response.statusCode}].. please wait it might be under maintenance";
    } catch (e) {
      _logger.e(e);
      return left(Exception(e.toString()));
    }
  }
}
