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
