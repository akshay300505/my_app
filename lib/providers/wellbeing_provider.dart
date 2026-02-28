import 'package:flutter/material.dart';

class WellbeingProvider extends ChangeNotifier {
  double mood = 75;

  void updateMood(double value) {
    mood = value;
    notifyListeners();
  }
}