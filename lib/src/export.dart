import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'ui/chart.dart';

Future<Uint8List?> exportChartAsImage(BuildContext context) async {
  final state = cartesianChartKey.currentState;
  if (state == null) return null;
  final data = await state.toImage(pixelRatio: 3.0);
  final bytes = await data.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) return null;
  return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
}
