import 'package:magnet/magnet.dart';
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
  });
}
