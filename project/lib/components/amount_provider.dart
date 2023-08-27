import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class AmountProvider extends ChangeNotifier {
  int _amount = 0;

  AmountProvider() {
    _initializeAmountFromDatabase();
  }

  int get amount => _amount;

  void _initializeAmountFromDatabase() async {
    final lastInfo = await DatabaseInformation.instance.getLastInformation();
    if (lastInfo != null) {
      final amountFromDatabase = lastInfo['setamount'] as int;
      _amount = amountFromDatabase;
      notifyListeners();
    }
  }

  // 外部からアクセス可能なメソッドとしてsetAmountを定義します
  void setAmount(int newAmount) {
    _amount = newAmount;
    notifyListeners();
  }
}
