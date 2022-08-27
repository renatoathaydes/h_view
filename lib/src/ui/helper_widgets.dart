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

Form form(List<Widget> widgets) {
  return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ));
}

List<Widget> chartNameSelector(
    String? chartName, Function(String?) setChartName) {
  return [
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
    ),
  ];
}

List<Widget> percentileLineSelector(
    double? percentileLine, Function(double?) setPercentileLine) {
  return [
    const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text('Percentile line:'),
    ),
    SizedBox(
      height: 85,
      child: TextFormField(
        initialValue: percentileLine?.toString() ?? '',
        validator: (value) {
          if (value == null || value.trim().isEmpty) return null;
          final number = double.tryParse(value);
          if (number == null || number < 0.0 || number > 1.0) {
            return 'Value must be between 0.0 and 1.0';
          }
          return null;
        },
        onChanged: (value) {
          if (!_formKey.currentState!.validate()) return;
          if (value.trim().isEmpty) {
            setPercentileLine(null);
          } else {
            setPercentileLine(double.parse(value.trim()));
          }
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Value between 0.0 to 1.0, or empty',
        ),
      ),
    ),
  ];
}

List<Widget> maxPercentileSelector(MaxPercentile9s max9sPercentile,
    Function(MaxPercentile9s) setMax9sPercentile) {
  return [
    const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text("Max 9's in 99.N%:"),
    ),
    Column(
      children: [
        Slider(
          value: max9sPercentile.number.toDouble(),
          min: 0,
          max: MaxPercentile9s.maxNumber.toDouble(),
          divisions: MaxPercentile9s.values.length - 1,
          onChanged: (number) =>
              setMax9sPercentile(MaxPercentile9s.fromNumber(number.toInt())),
        ),
        Text(max9sPercentile.percentText),
      ],
    ),
  ];
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
