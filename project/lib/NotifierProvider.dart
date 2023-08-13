import 'package:flutter/material.dart';

class NotificationSettingsProvider extends ChangeNotifier {
  bool _notificationSwitchValue = false;

  bool get notificationSwitchValue => _notificationSwitchValue;

  void updateNotificationSwitchValue(bool newValue) {
    _notificationSwitchValue = newValue;
    notifyListeners();
  }
}
