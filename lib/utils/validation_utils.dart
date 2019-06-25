class ValidationUtils {
  static String ltrim(String str) {
    return str.replaceFirst(new RegExp(r"^\s+"), "");
  }

  static String rtrim(String str) {
    return str.replaceFirst(new RegExp(r"\s+$"), "");
  }

  static String trimLeadingAndTrailingWhitespace(String str) {
    return ltrim(rtrim(str));
  }
}
