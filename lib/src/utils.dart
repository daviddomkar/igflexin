class Utils {
  static double computeResponsivity(double value, double devicePixelRatio) {
    return devicePixelRatio < 2.625 ? value / (5.0 - devicePixelRatio) * (5.0 - 2.625) : value;
  }
}
