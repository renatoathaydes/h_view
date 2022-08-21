import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:h_view/src/histogram_parser.dart';

const histogramExample = '''
       Value   Percentile   TotalCount 1/(1-Percentile)

       0.189     0.000000            1         1.00
       2.845     0.100000       348248         1.11
       3.603     0.200000       695644         1.25
       4.135     0.300000      1043796         1.43
      64.767     1.000000      3477000          inf
#[Mean    =        4.881, StdDeviation   =        1.777]
#[Max     =       64.736, Total count    =      3477000]
#[Buckets =           27, SubBuckets     =         2048]
''';

const multiSeriesHistogramExample = '''
       Value   Percentile   TotalCount 1/(1-Percentile)

       0.189     0.000000            1         1.00
      64.767     1.000000      3477000          inf
#[Mean    =        4.881, StdDeviation   =        1.777]

  Foo Bar
       Value   Percentile   TotalCount 1/(1-Percentile)

         1.2       0.100000            2         0.00
         3.1       0.900000            3         2.00
#[Max     =         10, Total count    =      100]


Another

       Value   Percentile   TotalCount 1/(1-Percentile)

         1         0.250001            5         0.23
         3         0.999999            7         2.98
         
#[Mean    =        8, StdDeviation   =        2]
#[Max     =       23, Total count    =      1000]
#[Buckets =           4, SubBuckets     =         100]

''';

void main() {
  test('HistogramConverter can convert a valid line', () {
    final data = const HistogramConverter()
        .convert('2.845     0.100000       348248         1.11');

    expect(
        data,
        equals(const HistogramData(
            value: 2.845,
            percentile: 0.1,
            percentileInverse: 1.11,
            totalCount: 348248)));
  });

  test('can parse single-series histogram successfully', () async {
    FileSystem fs = MemoryFileSystem();
    final histFile = fs.file('example_histogram.txt');
    await histFile.writeAsString(histogramExample);

    final histogram = await parseHistogramData(histFile, 'example_hist');

    expect(histogram.series, hasLength(1));
    expect(histogram.title, equals('example_hist'));

    final series = histogram.series[0];

    expect(series.title, equals(''));
    expect(
        series.stats,
        equals(const HistogramStatistics(
            mean: 4.881,
            max: 64.736,
            stdDev: 1.777,
            totalCount: 3477000,
            buckets: 27,
            subBuckets: 2048)));
    expect(
        series.data,
        equals(const [
          HistogramData(
              value: 0.189, percentile: 0, percentileInverse: 1, totalCount: 1),
          HistogramData(
              value: 2.845,
              percentile: 0.1,
              percentileInverse: 1.11,
              totalCount: 348248),
          HistogramData(
              value: 3.603,
              percentile: 0.2,
              percentileInverse: 1.25,
              totalCount: 695644),
          HistogramData(
              value: 4.135,
              percentile: 0.3,
              percentileInverse: 1.43,
              totalCount: 1043796),
          HistogramData(
              value: 64.767,
              percentile: 1.0,
              percentileInverse: double.infinity,
              totalCount: 3477000),
        ]));
  });

  test('can parse multi-series histogram successfully', () async {
    FileSystem fs = MemoryFileSystem();
    final histFile = fs.file('multi_series_histogram.txt');
    await histFile.writeAsString(multiSeriesHistogramExample);

    final histogram = await parseHistogramData(histFile, 'multi_series');

    expect(histogram.series, hasLength(3));
    expect(histogram.title, equals('multi_series'));

    final series1 = histogram.series[0];
    final series2 = histogram.series[1];
    final series3 = histogram.series[2];

    expect(series1.title, equals(''));
    expect(
        series1.stats,
        equals(const HistogramStatistics(
            mean: 4.881,
            max: 0,
            stdDev: 1.777,
            totalCount: 0,
            buckets: 0,
            subBuckets: 0)));
    expect(
        series1.data,
        equals(const [
          HistogramData(
              value: 0.189, percentile: 0, percentileInverse: 1, totalCount: 1),
          HistogramData(
              value: 64.767,
              percentile: 1.0,
              percentileInverse: double.infinity,
              totalCount: 3477000),
        ]));

    expect(series2.title, equals('Foo Bar'));
    expect(
        series2.stats,
        equals(const HistogramStatistics(
            mean: 0,
            max: 10,
            stdDev: 0,
            totalCount: 100,
            buckets: 0,
            subBuckets: 0)));
    expect(
        series2.data,
        equals(const [
          HistogramData(
              value: 1.2, percentile: 0.1, percentileInverse: 0, totalCount: 2),
          HistogramData(
              value: 3.1,
              percentile: 0.9,
              percentileInverse: 2.0,
              totalCount: 3),
        ]));

    expect(series3.title, equals('Another'));
    expect(
        series3.stats,
        equals(const HistogramStatistics(
            mean: 8,
            max: 23,
            stdDev: 2.0,
            totalCount: 1000,
            buckets: 4,
            subBuckets: 100)));
    expect(
        series3.data,
        equals(const [
          HistogramData(
              value: 1,
              percentile: 0.250001,
              percentileInverse: 0.23,
              totalCount: 5),
          HistogramData(
              value: 3,
              percentile: 0.999999,
              percentileInverse: 2.98,
              totalCount: 7),
        ]));
  });
}
