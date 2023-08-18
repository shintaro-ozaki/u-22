import 'package:flutter/material.dart';

class AmountProvider extends ChangeNotifier {
  int _amount = 0;

  int get amount => _amount;

  void setAmount(int newAmount) {
    _amount = newAmount;
    notifyListeners();
  }
}