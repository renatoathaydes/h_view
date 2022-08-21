import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../histogram_parser.dart';
import 'helper_widgets.dart';

Widget chartWidget(
    BuildContext context, Histogram? histogram, Object? errorLoading) {
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
    mainWidget = _histogramWidget(histogram);
  } else {
    mainWidget = Text(
      'No chart generated yet...',
      style: Theme.of(context).textTheme.headline5,
    );
  }
  return Center(child: mainWidget);
}

Widget _histogramWidget(Histogram histogram) {
  return SfCartesianChart(
      // key: ValueKey(histogram),
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      title: ChartTitle(text: histogram.title),
      primaryXAxis:
          CategoryAxis(title: AxisTitle(text: 'Percentile (non linear)')),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Time (ms)'),
      ),
      series: histogram.series
          .map(
            (series) => LineSeries<HistogramData, String>(
              name: series.title,
              dataSource: series.data,
              xValueMapper: (data, _) => data.percentile.toString(),
              yValueMapper: (data, _) => data.value,
            ),
          )
          .followedBy(histogram.series.map((series) => LineSeries(
                name: '${series.title} (mean)',
                dataSource: series.data,
                xValueMapper: (data, _) => data.percentile.toString(),
                yValueMapper: (data, _) => series.stats.mean,
              )))
          .toList(growable: false));
}

String _errorMessage(Object error) {
  if (error is HistogramParseException) {
    return 'Error parsing histogram data:\n${error.message}';
  }
  return 'Unexpected error:\n$error';
}
