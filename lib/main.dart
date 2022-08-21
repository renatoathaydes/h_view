import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'src/data.dart';
import 'src/files/reader.dart'
    if (dart.library.js) 'src/files/web_reader.dart'
    if (dart.library.io) 'src/files/io_reader.dart';
import 'src/histogram_parser.dart';
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
  Object? _errorLoading;
  LoadState _loadState = LoadState.none;
  Histogram? _histogram;

  void _setChartName(String? name) {
    setState(() {
      _chartName = name;
      _histogram = _histogram?.copy(title: name);
    });
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
            await readableFile(file), _chartName ?? 'Histogram');
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
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      drawer: drawer(
          context, () => w.pad(w.selectFileForm(_chartName, _setChartName))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            w.pad(w.selectedFile(context, _currentFile, _loadState)),
            Expanded(
                child: _loadState == LoadState.parsingChart
                    ? w.loadingDialog()
                    : chartWidget(context, _histogram, _errorLoading)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        mini: true,
        tooltip: 'Pick a file',
        child: const Icon(Icons.file_open),
      ),
    );
  }
}
