import 'package:flutter/material.dart';

Widget menuButtons(List<Widget> buttons) {
  final allButFirst = buttons.sublist(1);
  final first = buttons.first;
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      first,
      ...allButFirst.map((button) => Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: button,
          )),
    ],
  );
}

Widget button(String tooltip, Icon icon, void Function()? onPressed,
    {bool mini = true, required Color? backgroundColor}) {
  return FloatingActionButton(
    onPressed: onPressed,
    mini: true,
    backgroundColor: backgroundColor,
    tooltip: tooltip,
    child: icon,
  );
}
