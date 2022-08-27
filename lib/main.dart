import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'src/data.dart';
import 'src/export.dart';
import 'src/files/reader.dart'
    if (dart.library.js) 'src/files/web_reader.dart'
    if (dart.library.io) 'src/files/io_reader.dart';
import 'src/histogram_parser.dart';
import 'src/ui/buttons.dart';
import 'src/ui/chart.dart';
import 'src/ui/drawer.dart';
import 'src/ui/helper_widgets.dart' as w;

void main() {
  runApp(const MyApp());
}

// https://help.syncfusion.com/flutter/cartesian-charts/chart-types/line-chart
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HView',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(),
      ),
      home: const MyHomePage(title: 'HView'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _currentFile;
  String? _chartName;
  MaxPercentile9s _maxPercentile = MaxPercentile9s.max;
  double? _percentileLine = 0.5;
  Object? _errorLoading;
  LoadState _loadState = LoadState.none;
  Histogram? _histogram;

  void _setChartName(String? name) {
    setState(() {
      _chartName = name;
      _histogram = _histogram?.copy(title: name);
    });
  }

  void _setMaxPercentile9s(MaxPercentile9s value) {
    setState(() => _maxPercentile = value);
  }

  void _setPercentileLine(double? value) {
    setState(() => _percentileLine = value);
  }

  void _exportImage(BuildContext context) async {
    final showMessage = w.snackBarShower(context);
    Future<Uint8List?> getImage() => exportChartAsImage(context);
    final chartFile = _currentFile;
    if (chartFile == null) {
      return showMessage('No chart has been generated yet!');
    }
    FutureOr<String> getSavedFile(String? dir, Uint8List image) {
      return const FilesImpl().saveFile(context, dir, chartFile, image);
    }

    setState(() => _loadState = LoadState.pickingFile);
    String? dir;
    try {
      if (const FilesImpl().supportsGetDirectoryPath) {
        dir = await FilePicker.platform
            .getDirectoryPath(dialogTitle: 'Select a directory');
        if (dir == null) {
          return showMessage('No directory selected.');
        }
      }
      final image = await getImage();
      if (image == null) {
        return showMessage('An error occurred trying to export the image!');
      }
      try {
        final savedFile = await getSavedFile(dir, image);
        showMessage('Successfully saved $savedFile.');
      } catch (e) {
        showMessage('Could not save the image: $e');
      }
    } finally {
      setState(() => _loadState = LoadState.none);
    }
  }

  void _pickFile() async {
    setState(() => _loadState = LoadState.pickingFile);
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(dialogTitle: 'Select histogram file');
    final file = result?.files.first;
    if (file == null) {
      setState(() => _loadState = LoadState.none);
    } else {
      setState(() => _loadState = LoadState.parsingChart);

      try {
        final histogram = await parseHistogramData(
            await const FilesImpl().readableFile(file),
            _chartName ?? 'Histogram');
        setState(() {
          _histogram = histogram;
          _currentFile = file.name;
          _loadState = LoadState.none;
          _errorLoading =
              histogram.series.isEmpty ? 'No data was found!' : null;
        });
      } catch (e) {
        setState(() {
          _histogram = null;
          _currentFile = null;
          _loadState = LoadState.none;
          _errorLoading = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = _loadState != LoadState.none;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        foregroundColor: theme.colorScheme.primary,
        title: Text(widget.title),
      ),
      drawer: drawer(context, [
        w.form([
          ...w.chartNameSelector(_chartName, _setChartName),
          const SizedBox(height: 20),
          ...w.maxPercentileSelector(_maxPercentile, _setMaxPercentile9s),
          const SizedBox(height: 20),
          ...w.percentileLineSelector(_percentileLine, _setPercentileLine),
        ]),
      ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            w.pad(w.selectedFile(context, _currentFile, _loadState)),
            Expanded(
                child: _loadState == LoadState.parsingChart
                    ? w.loadingDialog()
                    : chartWidget(context, _histogram, _errorLoading,
                        _maxPercentile, _percentileLine)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: menuButtons(
        [
          button(
              'Export image',
              const Icon(Icons.image_outlined),
              _histogram == null || loading
                  ? null
                  : () => _exportImage(context),
              backgroundColor: _histogram == null || loading
                  ? theme.disabledColor
                  : theme.floatingActionButtonTheme.foregroundColor),
          button('Pick a file', const Icon(Icons.file_open),
              loading ? null : _pickFile,
              backgroundColor: loading
                  ? theme.disabledColor
                  : theme.floatingActionButtonTheme.foregroundColor),
        ],
      ),
    );
  }
}
