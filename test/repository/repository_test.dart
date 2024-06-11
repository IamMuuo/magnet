import 'package:magnet/src/auth/auth.dart';
import 'package:magnet/src/repository/repository.dart';
import 'package:test/test.dart';
import 'package:dotenv/dotenv.dart';

void main() {
  String token = "";
  final env = DotEnv(includePlatformEnvironment: true)..load();

  setUp(() async {
    final response = await Auth.fetchSessionToken();
    response.fold((l) {
      fail(l.toString());
    }, (r) {
      token = r;
    });

    final res = await Auth.login(token, env["USERNAME"]!, env["PASSWORD"]!);
    res.fold((l) {
      fail(l.toString());
    }, (r) {
      token = r;
    });
  });

  group('RepositoryTest', () {
    test("Fetch time table", () async {
      final result = await Repository.fetchTimeTable(token);
      result.fold((l) {
        fail(l.toString());
      }, (r) {
        expect(r.isNotEmpty, true);
        expect(r[0].containsKey("unit"), true);
      });
    });

    test("Fetch student time table", () async {
      final result = await Repository.fetchUserTimeTable(token);
      result.fold((l) {
        fail(l.toString());
      }, (r) {
        expect(r.isNotEmpty, true);
        expect(r[0].containsKey("unit"), true);
      });
    });

    // test("Fetch semester timeline", () async {
    //   final result = await Repository.fetchAcademicCalendar(token);
    //   result.fold((l) {
    //     fail(l.toString());
    //   }, (r) {
    //     expect(r.isNotEmpty, true);
    //     expect(r[0].containsKey("name"), true);
    //   });
    // });

    test("Fetch fee statement", () async {
      final result = await Repository.fetchFeeStatement(token);
      result.fold((l) {
        fail(l.toString());
      }, (r) {
        expect(r.isNotEmpty, true);
        expect(r[0].containsKey("credit"), true);
      });
    });

    test("Fetch catering token", () async {
      final result = await Repository.fetchCateringToken(token);
      result.fold((l) {}, (r) {
        expect(r.isNotEmpty, true);
      });
    });

    test("Fetch student details", () async {
      final result = await Repository.fetchUserDetails(token);
      result.fold((l) {
        fail(l.toString());
      }, (r) {
        expect(r.isNotEmpty, true);
        expect(r.containsKey("regno"), true);
      });
    });
  });
}
