enum LoadState { none, pickingFile, parsingChart }

enum MaxPercentile9s {
  zero(0, 0.99, '99%'),
  one(1, 0.999, '99.9%'),
  two(2, 0.9999, '99.99%'),
  three(3, 0.99999, '99.999%'),
  four(4, 0.999999, '99.9999%'),
  five(5, 0.9999999, '99.99999%'),
  six(6, 0.99999999, '99.999999%');

  static const int maxNumber = 6;
  static const MaxPercentile9s max = six;

  final int number;
  final double percentile;
  final String percentText;

  const MaxPercentile9s(this.number, this.percentile, this.percentText);

  static MaxPercentile9s fromNumber(int number) {
    switch (number) {
      case 0:
        return zero;
      case 1:
        return one;
      case 2:
        return two;
      case 3:
        return three;
      case 4:
        return four;
      case 5:
        return five;
      case 6:
        return six;
      default:
        throw RangeError('out of range (0-6): $number');
    }
  }
}
