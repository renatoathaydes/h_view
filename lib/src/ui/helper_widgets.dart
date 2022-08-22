import 'package:flutter/material.dart';
import 'package:h_view/src/data.dart';

final _formKey = GlobalKey<FormState>();

Widget pad(Widget child) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: child,
  );
}

Widget selectedFile(
    BuildContext context, String? currentFile, LoadState loadState) {
  return Text(
    loadState == LoadState.pickingFile
        ? 'Waiting...'
        : 'Selected file: ${currentFile ?? '<none>'}',
    style: Theme.of(context).textTheme.bodySmall,
  );
}

Form selectFileForm(String? chartName, Function(String?) setChartName) {
  return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Chart name:'),
          ),
          TextFormField(
            initialValue: chartName,
            onChanged: setChartName,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Give the chart a name!',
            ),
          )
        ],
      ));
}

Form selectDirectoryToExport(
    String? dirToExport, Function(String?) setDirToExport) {
  return Form(
      // key: _formKey,
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('Directory to export images to:'),
      ),
      TextFormField(
        initialValue: dirToExport,
        onChanged: setDirToExport,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Pick a directory!',
        ),
      )
    ],
  ));
}

Widget noChartGeneratedYet(BuildContext context) {
  return Expanded(
      child: Align(
          child: Text('No chart generated yet...',
              style: Theme.of(context).textTheme.headline5)));
}

void Function(String message) snackBarShower(BuildContext context) {
  final textStyle = Theme.of(context).textTheme.bodyLarge;
  return (msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).backgroundColor,
      content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 20),
          child: Center(child: Text(msg, style: textStyle)))));
}

Widget loadingDialog() {
  return SimpleDialog(
    children: [
      Center(
          child: Column(children: const <Widget>[
        Text('Loading chart'),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      ])),
    ],
  );
}

Future<bool?> showYesNoDialog(
  BuildContext context, {
  required Widget question,
  Widget title = const Text(''),
  Widget yesLabel = const Text('Yes'),
  Widget noLabel = const Text('No'),
}) {
  // set up the buttons
  final alert = AlertDialog(
    title: title,
    content: question,
    actions: [
      TextButton(
        child: noLabel,
        onPressed: () => Navigator.pop(context, false),
      ),
      TextButton(
        child: yesLabel,
        onPressed: () => Navigator.pop(context, true),
      )
    ],
  );
  return showDialog<bool>(context: context, builder: (context) => alert);
}
