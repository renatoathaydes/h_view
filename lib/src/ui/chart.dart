import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide HistogramSeries;

import '../data.dart';
import '../histogram_parser.dart';
import 'helper_widgets.dart';

final cartesianChartKey = GlobalKey<SfCartesianChartState>();

Widget chartWidget(BuildContext context, Histogram? histogram,
    Object? errorLoading, MaxPercentile9s maxPercentile9s) {
  Widget mainWidget;
  if (errorLoading != null) {
    mainWidget = pad(Container(
      constraints: const BoxConstraints.tightFor(width: 500.0, height: 200.0),
      color: Colors.red,
      child: Center(
        child: pad(Text(
          _errorMessage(errorLoading),
          style: Theme.of(context).textTheme.bodyLarge,
        )),
      ),
    ));
  } else if (histogram != null) {
    mainWidget = _histogramWidget(histogram, maxPercentile9s);
  } else {
    mainWidget = Text(
      'No chart generated yet...',
      style: Theme.of(context).textTheme.headline5,
    );
  }
  return Center(child: mainWidget);
}

const chartColors = <Color>[
  Colors.purpleAccent,
  Colors.greenAccent,
  Colors.amberAccent,
  Colors.cyanAccent,
  Colors.blueAccent,
  Colors.white,
];

class _IndexedSeries {
  final int index;
  final HistogramSeries series;

  _IndexedSeries(this.index, this.series);

  String get seriesName =>
      series.title.isEmpty ? 'Series ${index + 1}' : series.title;
}

Widget _histogramWidget(Histogram histogram, MaxPercentile9s maxPercentile9s) {
  var colorIndex = 0;

  var index = 0;
  final data = histogram.series
      .map((series) => _IndexedSeries(index++,
          series.filter((p) => p.percentile < maxPercentile9s.percentile)))
      .toList(growable: false);

  return SfCartesianChart(
      key: cartesianChartKey,
      palette: chartColors,
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      title: ChartTitle(text: histogram.title),
      primaryXAxis:
          CategoryAxis(title: AxisTitle(text: 'Percentile (non linear)')),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Time (ms)'),
      ),
      series: data
          .map(
            (series) => LineSeries<HistogramData, String>(
              name: series.seriesName,
              dataSource: series.series.data,
              xValueMapper: (data, _) => data.percentile.toString(),
              yValueMapper: (data, _) => data.value,
            ),
          )
          .followedBy(data.map((series) => LineSeries(
        name: '${series.seriesName} (mean)',
                color: chartColors[colorIndex++ % chartColors.length],
                opacity: 0.6,
                dataSource: series.series.data,
                xValueMapper: (data, _) => data.percentile.toString(),
                yValueMapper: (data, _) => series.series.stats.mean,
              )))
          .toList(growable: false));
}

String _errorMessage(Object error) {
  if (error is HistogramParseException) {
    return 'Error parsing histogram data:\n${error.message}';
  }
  return 'Unexpected error:\n$error';
}
