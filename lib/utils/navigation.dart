import 'package:flutter/material.dart';

class NavigationUtils {
  void push(context, widget) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return widget;
    }));
  }

  void pushReplace(context, widget) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return widget;
    }));
  }
}
