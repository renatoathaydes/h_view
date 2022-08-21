import 'package:flutter/material.dart';
import 'package:h_view/src/data.dart';

final _formKey = GlobalKey<FormState>();

Widget pad(Widget child){
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: child,
  );
}

Widget selectedFile(BuildContext context, String? currentFile, LoadState loadState) {
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

Widget noChartGeneratedYet(BuildContext context) {
  return Expanded(
      child: Align(
          child: Text('No chart generated yet...',
              style: Theme.of(context).textTheme.headline5)));
}
