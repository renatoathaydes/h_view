import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'ui/chart.dart';

Future<void> exportChartAsImage(
    BuildContext context, SfCartesianChart chart) async {
  final ui.Image data =
      await cartesianChartKey.currentState!.toImage(pixelRatio: 3.0);
  final ByteData? bytes = await data.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List imageBytes =
      bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

  // TODO save image bytes into file
}
