import 'package:flutter/material.dart';

class SheetProvider extends ChangeNotifier {
  bool isExpanded = true;
  static const double minExtent = 0.59;
  static const double maxExtent = .95;
  double initialExtent = 0.85;
  /* double _initialExtent = minExtent;

  double get initialExtent => _initialExtent;
  set initialExtent(double iExtent) {
    this._initialExtent = iExtent;
    notifyListeners();
  }
  */
}
