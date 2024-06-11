/// The config class cointains various configuration sessings
/// for magnet package

class Config {
  static final baseUrl = "http://student.daystar.ac.ke";

  /// The generateHeader function creates headers from
  /// necessary for the working of the school portal based on
  /// the session
  static Map<String, String> generateHeader(String session) {
    return {'Cookie': session};
  }
}
