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

  test('can parse full histogram successfully', () async {
    FileSystem fs = MemoryFileSystem();
    final histFile = fs.file('example_histogram.txt');
    await histFile.writeAsString(histogramExample);

    final histogram = await parseHistogramData(histFile, 'example_hist');

    expect(histogram.name, equals('example_hist'));
    expect(
        histogram.stats,
        equals(const HistogramStatistics(
            mean: 4.881,
            max: 64.736,
            stdDev: 1.777,
            totalCount: 3477000,
            buckets: 27,
            subBuckets: 2048)));
    expect(
        histogram.data,
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
}
