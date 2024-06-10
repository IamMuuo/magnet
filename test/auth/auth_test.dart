import 'package:dotenv/dotenv.dart';
import 'package:magnet/src/auth/auth.dart';
import 'package:test/test.dart';

void main() {
  String token = "";
  final env = DotEnv(includePlatformEnvironment: true)..load();

  group('AuthTest', () {
    test('Env Load Test', () {
      expect(env["USERNAME"], isNotNull);
      expect(env["PASSWORD"], isNotNull);
    });

    test("Session Token test", () async {
      final response = await Auth.fetchSessionToken();
      response.fold((l) {
        fail(l.toString());
      }, (r) {
        token = r;
      });
    });

    test('Login test', () async {
      final response =
          await Auth.login(token, env["USERNAME"]!, env["PASSWORD"]!);
      response.fold((l) {
        fail(l.toString());
      }, (r) {
        token = r;
      });
    });
  });
}
