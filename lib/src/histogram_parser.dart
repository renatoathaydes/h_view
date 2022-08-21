import 'dart:convert';

import 'package:file/file.dart';

const _columnsHeader = 'Value   Percentile   TotalCount 1/(1-Percentile)';
final _termSplitter = RegExp('\\s+=\\s+');
final _columnsSplitter = RegExp('\\s+');

class HistogramParseException {
  final String message;

  const HistogramParseException(this.message);

  @override
  String toString() {
    return 'HistogramParseException{message: $message}';
  }
}

class Histogram {
  final String name;
  final List<HistogramData> data;
  final HistogramStatistics stats;

  const Histogram(this.name, this.data, this.stats);
}

class HistogramData {
  final double value;
  final double percentile;
  final double percentileInverse;
  final int totalCount;

  const HistogramData({
    required this.value,
    required this.percentile,
    required this.percentileInverse,
    required this.totalCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistogramData &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          percentile == other.percentile &&
          percentileInverse == other.percentileInverse &&
          totalCount == other.totalCount;

  @override
  int get hashCode =>
      value.hashCode ^
      percentile.hashCode ^
      percentileInverse.hashCode ^
      totalCount.hashCode;

  @override
  String toString() {
    return 'HistogramData{value: $value, percentile: $percentile, '
        'percentileInverse: $percentileInverse, totalCount: $totalCount}';
  }
}

// Mutable version of HistogramStatistics
class _HistogramStatistics {
  double mean = 0;
  double max = 0;
  double stdDev = 0;
  int totalCount = 0;
  int buckets = 0;
  int subBuckets = 0;

  HistogramStatistics freeze() => HistogramStatistics(
        mean: mean,
        max: max,
        stdDev: stdDev,
        totalCount: totalCount,
        buckets: buckets,
        subBuckets: subBuckets,
      );
}

class HistogramStatistics {
  final double mean;
  final double max;
  final double stdDev;
  final int totalCount;
  final int buckets;
  final int subBuckets;

  const HistogramStatistics(
      {required this.mean,
      required this.max,
      required this.stdDev,
      required this.totalCount,
      required this.buckets,
      required this.subBuckets});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistogramStatistics &&
          runtimeType == other.runtimeType &&
          mean == other.mean &&
          max == other.max &&
          stdDev == other.stdDev &&
          totalCount == other.totalCount &&
          buckets == other.buckets &&
          subBuckets == other.subBuckets;

  @override
  int get hashCode =>
      mean.hashCode ^
      max.hashCode ^
      stdDev.hashCode ^
      totalCount.hashCode ^
      buckets.hashCode ^
      subBuckets.hashCode;

  @override
  String toString() {
    return 'HistogramStatistics{mean: $mean, max: $max, stdDev: $stdDev, '
        'totalCount: $totalCount, buckets: $buckets, subBuckets: $subBuckets}';
  }
}

class HistogramConverter extends Converter<String, HistogramData> {
  const HistogramConverter();

  @override
  HistogramData convert(String input) {
    //  Value   Percentile   TotalCount 1/(1-Percentile)
    // 64.607     0.999992      3476975    131072.00
    final columns = input.split(_columnsSplitter);
    if (columns.length != 4) {
      throw HistogramParseException('Expected row with 4 columns: "$input"');
    }
    return HistogramData(
      value: columns[0].toDouble('Value'),
      percentile: columns[1].toDouble('Percentile'),
      totalCount: columns[2].toInt('TotalCount'),
      percentileInverse: columns[3].toDouble('1/(1-Percentile)'),
    );
  }
}

Future<Histogram> parseHistogramData(File file, String name) async {
  final dataStream = file
      .openRead()
      .map(utf8.decode)
      .transform(const LineSplitter())
      .map((line) => line.trim())
      .skipWhile((line) => line.trim() != _columnsHeader)
      .skip(1)
      .where((line) => line.isNotEmpty);

  final data = <HistogramData>[];
  final stats = _HistogramStatistics();
  var parsingData = true;

  await for (final line in dataStream) {
    if (parsingData && !line.startsWith('#')) {
      data.add(const HistogramConverter().convert(line));
      continue;
    } else if (parsingData) {
      parsingData = false;
    }
    _parseStats(line, stats);
  }

  return Histogram(name, data, stats.freeze());
}

void _parseStats(String line, _HistogramStatistics stats) {
  // example: #[Mean    =        4.881, StdDeviation   =        1.777]
  if (!(line.startsWith('#[') && line.endsWith(']'))) return;
  line = line.substring(2, line.length - 1);
  for (final term in line.split(',')) {
    final parts = term.split(_termSplitter);
    if (parts.length != 2) {
      throw HistogramParseException(
          'expected term to contain key=value: "$term"');
    }
    final key = parts[0].trim();
    final value = parts[1];
    switch (key) {
      case 'Mean':
        stats.mean = value.toDouble('Mean');
        break;
      case 'StdDeviation':
        stats.stdDev = value.toDouble('StdDeviation');
        break;
      case 'Max':
        stats.max = value.toDouble('Max');
        break;
      case 'Total count':
        stats.totalCount = value.toInt('Total count');
        break;
      case 'Buckets':
        stats.buckets = value.toInt('Buckets');
        break;
      case 'SubBuckets':
        stats.subBuckets = value.toInt('SubBuckets');
        break;
      default:
        throw HistogramParseException('Unexpected statistic value: $key');
    }
  }
}

extension _HistogramParserNumberConverter on String {
  double toDouble(String key) {
    if (this == 'inf') return double.infinity;
    try {
      return double.parse(this);
    } on FormatException {
      throw HistogramParseException('invalid number for $key: $this');
    }
  }

  int toInt(String key) {
    try {
      return int.parse(this);
    } on FormatException {
      throw HistogramParseException('invalid number for $key: $this');
    }
  }
}
