import 'package:dartz/dartz.dart';
import 'package:dotenv/dotenv.dart';
import 'package:magnet/magnet.dart';
import 'package:test/test.dart';

void main() {
  String token = "";
  final env = DotEnv(includePlatformEnvironment: true)..load();
  late Magnet magnet;

  setUp(() {
    magnet = Magnet(env["USERNAME"]!, env["PASSWORD"]!);
  });

  group("MagnetTest", () {
    test('Env Load Test', () {
      expect(env["USERNAME"], isNotNull);
      expect(env["PASSWORD"], isNotNull);
    });

    test('Login test', () async {
      final response = await magnet.login();
      response.fold((l) {
        fail(l.toString());
      }, (r) {
        token = r;
      });
    });
    test('fetchCateringToken - Fail if empty container or exception', () async {
      final result = await magnet.fetchCateringToken();

      expect(result.fold((l) => true, (r) => false), isTrue);
    });

    test('fetchAcademicCalendar - Fail if empty container or exception',
        () async {
      final result = await magnet.fetchAcademicCalendar();

      expect(result.fold((l) => true, (r) => false), isTrue);
    });

    test('fetchTranscript - Fail if empty container or exception', () async {
      final result = await magnet.fetchTranscript();
      expect(result.isLeft(), false);
      expect(result.isRight(), true);
    }, tags: ['transcript']);

    test('fetchStudentAudit - Fail if empty container or exception', () async {
      final result = await magnet.fetchStudentAudit();

      expect(result.isLeft(), false);
      expect(result.isRight(), true);
      final audits = (result as Right).value as List<String>;
      expect(audits.length, equals(1));
    }, tags: ['audit']);

    test('fetchFeeStatement - Fail if empty container or exception', () async {
      final result = await magnet.fetchFeeStatement();

      result.fold((l) => fail(l.toString()), (r) {
        expect(r.isNotEmpty, true);
      });
    });

    test('fetchUserClassAttendance - Fail if empty container or exception',
        () async {
      final result = await magnet.fetchUserClassAttendance();

      result.fold((l) => fail(l.toString()), (r) {
        expect(r.isNotEmpty, true);
      });
    });

    test('fetchUserDetails - Fail if empty container or exception', () async {
      final result = await magnet.fetchUserDetails();

      result.fold((l) => fail(l.toString()), (r) {
        expect(r.isNotEmpty, true);
      });
    });

    test('fetchUserTimeTable - Fail if empty container or exception', () async {
      final result = await magnet.fetchUserTimeTable();

      result.fold((l) => fail(l.toString()), (r) {
        expect(r.isNotEmpty, true);
      });
    });

    test('fetchTimeTable - Fail if empty container or exception', () async {
      final result = await magnet.fetchTimeTable();

      result.fold((l) => fail(l.toString()), (r) {
        expect(r.isNotEmpty, true);
      });
    });
  });
}
