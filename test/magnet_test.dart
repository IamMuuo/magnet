import 'package:magnet/magnet.dart';
import 'package:test/test.dart';

void main() {
  group('Test Scrape Engine', () {
    final magnet = Magnet();

    setUp(() {
      // Additional setup goes here.
    });

    test('Login Test', () async {
      expect(await magnet.login("someone", "example"), isFalse);
    });

    test("Login Test 2 (Test failure on wrong credentials))", () async {
      expect(await magnet.login("someone", "example"), isFalse);
    });
  });
}
