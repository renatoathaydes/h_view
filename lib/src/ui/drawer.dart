import 'package:flutter/material.dart';

Widget drawer(BuildContext context, Widget Function() buildItem) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: const Text('Settings'),
        ),
        ListTile(
          title: buildItem(),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          title: const Text('Close'),
          onTap: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
