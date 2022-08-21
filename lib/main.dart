import 'package:file/local.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'src/data.dart';
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
  String? _errorLoading;
  LoadState _loadState = LoadState.none;
  Histogram? _histogram;

  void _setChartName(String? name) {
    setState(() {
      _chartName = name;
      _histogram = _histogram?.copy(title: name);
    });
  }

  void _picker() async {
    setState(() => _loadState = LoadState.pickingFile);
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(dialogTitle: 'Select histogram file');
    final path = result?.files.first.path;
    if (path == null) {
      setState(() => _loadState = LoadState.none);
    } else {
      setState(() => _loadState = LoadState.parsingChart);
      try {
        final histogram = await parseHistogramData(
            const LocalFileSystem().file(path), _chartName ?? 'Histogram');
        setState(() {
          _histogram = histogram;
          _currentFile = path;
          _loadState = LoadState.none;
        });
      } on HistogramParseException catch (e) {
        setState(() {
          _histogram = null;
          _currentFile = null;
          _errorLoading = e.message;
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
            Expanded(child: chartWidget(context, _histogram, _errorLoading)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _picker,
        tooltip: 'Pick a file',
        child: const Icon(Icons.file_open),
      ),
    );
  }
}
