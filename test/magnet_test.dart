import 'dart:typed_data';

import 'package:magnet/magnet.dart';
import 'package:magnet/src/magnet_utils.dart';
import 'package:test/test.dart';
import 'package:dotenv/dotenv.dart';

void main() {
  group('Test Scrape Engine', () {
    var env = DotEnv(includePlatformEnvironment: true)..load();

    test('Env Load Test', () {
      expect(env["USERNAME"], isNotNull);
      expect(env["PASSWORD"], isNotNull);
    });

    final magnet = Magnet(env["USERNAME"]!, env["PASSWORD"]!);

    setUp(() {
      // Additional setup goes here
      DotEnv(includePlatformEnvironment: true).load();
    });

    test('Login Test', () async {
      expect(await magnet.login(), isTrue);
    });

    test("Login Test 2 (Test failure on wrong credentials))", () async {
      expect(await magnet.login(), isTrue);
    });

    var data = {};
    test('Fetch user data', () async {
      data = await magnet.fetchUserData();
      expect(data, isNot({}));
    });

    test('User data is not corrpt', () async {
      expect(data["regno"], isNotNull);
    });

    test("profile link is present", () async {
      expect(data["profile"], isNotNull);
    });
    var timetable = [];
    test('Fetch TimeTable', () async {
      timetable = await magnet.fetchTimeTable();
      expect(timetable, isNot([{}]));
    });

    test('Timetable data is valid', () async {
      expect(timetable.first.keys, contains("Unit"));
    });

    var allCourses = [];
    test('Fetch TimeTable', () async {
      allCourses = await magnet.fetchAllCourses();
      expect(allCourses, isNot([{}]));
    });

    test('Timetable data is valid', () async {
      expect(allCourses.first.keys, contains("Unit"));
    });

    var token = {};
    test("Fetch Catering token", () async {
      token = await magnet.fetchCateringToken();
      expect(token, isNot({}));
    });

    test("Catering token is valid", () async {
      expect(token["message"], isNotEmpty);
      expect(token["success"], isTrue);
    });

    var courseAttendace = <Map<String, int>>[];
    test("Fetch Class Attendance", () async {
      courseAttendace = await magnet.fetchUserClassAttendance();
      expect(courseAttendace, isNot([]));
    });

    var feeStatement = [];
    test('Fetch Fee Statement', () async {
      feeStatement = await magnet.fetchFeeStatement();
      expect(feeStatement, isNot([]));
    });

    var calendar = [];
    test('Fetch Academic Calendar', () async {
      calendar = await magnet.fetchAcademicCalendar();
      expect(calendar, isNot([]));
    });

    var units = [];
    test("Fetch Exam Timetable", () async {
      units = await magnet.fetchExamTimeTabale(
          "ACS 311A, ACS 323A, ACS 354A, ACS 362B, BIL 112B, MAT 322A, ACS 311A, ACS 323A, ACS 354A, ACS 362B, BIL 112B, MAT 322A,");
      expect(units, isNot([]));
    });

    Uint8List audit;
    test('Fetch Student Audit', () async {
      audit = await magnet.fetchStudentAudit(env["USERNAME"]!);
      expect(audit, isNotNull);
    });

    Uint8List transcript;
    test('Fetch Student Transcript', () async {
      transcript = await magnet.fetchTranscript(env["USERNAME"]!);
      expect(transcript, isNotNull);
    });

    var contributors = [];
    test('Fetch Project Contributors', () async {
      contributors = await magnet.fetchContributors();
      expect(contributors, isNotEmpty);
    });

    late List notifications;
    test('Fetch Notifications', () async {
      notifications = await magnet.fetchNotifications();
      expect(notifications, isNotEmpty);
    });
  });
}
