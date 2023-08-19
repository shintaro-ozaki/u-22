// ignore: file_names
import 'package:flutter/material.dart';

enum NotificationFrequency {
  unspecified,
  oncePerDay,
  oncePerThreeDays,
  oncePerWeek,
}

class FrequencyProvider extends ChangeNotifier {
  NotificationFrequency _selectedFrequency = NotificationFrequency.unspecified;

  NotificationFrequency get selectedFrequency => _selectedFrequency;

  void setSelectedFrequency(NotificationFrequency frequency) {
    _selectedFrequency = frequency;
    notifyListeners();
  }
}
