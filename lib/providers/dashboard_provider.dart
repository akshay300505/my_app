import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  double wellbeingScore = 80;
  int rank = 10;

  void updateScore(double score) {
    wellbeingScore = score;
    notifyListeners();
  }
}