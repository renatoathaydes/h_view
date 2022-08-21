import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../histogram_parser.dart';

Widget chartWidget(
    BuildContext context, Histogram? histogram, String? errorLoading) {
  Widget mainWidget;
  if (histogram != null) {
    mainWidget = _histogramWidget(histogram);
  } else if (errorLoading != null) {
    mainWidget = Text(
      errorLoading,
      style: Theme.of(context).textTheme.button,
    );
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
      title: ChartTitle(text: histogram.name),
      primaryXAxis: NumericAxis(
          title: AxisTitle(text: 'Percentile')),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Time (ms)'),
      ),
      series: <ChartSeries>[
        // Renders line chart
        LineSeries<HistogramData, double>(
          dataSource: histogram.data,
          xValueMapper: (data, _) => data.percentile,
          yValueMapper: (data, _) => data.value,
        )
      ]);
}
