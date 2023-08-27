import 'package:flutter/material.dart';
import '../db/database_helper.dart';

enum NotificationFrequency {
  unspecified,
  oncePerDay,
  oncePerthreeTimesDays,
  oncePerWeek,
}

NotificationFrequency convertToNotificationFrequency(String value) {
  switch (value) {
    case '指定なし':
      return NotificationFrequency.unspecified;
    case '1日に1回':
      return NotificationFrequency.oncePerDay;
    case '3日に1回':
      return NotificationFrequency.oncePerthreeTimesDays;
    case '1週間に1回':
      return NotificationFrequency.oncePerWeek;
    default:
      return NotificationFrequency.unspecified;
  }
}

class FrequencyProvider extends ChangeNotifier {
  NotificationFrequency _selectedFrequency = NotificationFrequency.oncePerWeek;

  FrequencyProvider() {
    _initializeFrequencyFromDatabase();
  }

  NotificationFrequency get selectedFrequency => _selectedFrequency;

  void _initializeFrequencyFromDatabase() async {
    final lastInfo = await DatabaseInformation.instance.getLastInformation();
    if (lastInfo != null) {
      final frequencyFromDatabase = lastInfo['frequency'] as String;
      _selectedFrequency =
          convertToNotificationFrequency(frequencyFromDatabase);
      notifyListeners();
    }
  }

  // ここいる？
  void setSelectedFrequency(NotificationFrequency frequency) {
    _selectedFrequency = frequency;
    notifyListeners();
  }
}
