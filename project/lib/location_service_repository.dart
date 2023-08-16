import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:background_locator_2/location_dto.dart';

class LocationServiceRepository {
  static final LocationServiceRepository _instance =
      LocationServiceRepository._();

  LocationServiceRepository._();

  factory LocationServiceRepository() {
    return _instance;
  }

  static const String isolateName = 'LocatorIsolate';
  int count = 0;

  Future<void> init(Map<dynamic, dynamic> params) async {
    debugPrint('Plugin initialization');
  }

  Future<void> dispose() async {
    //バックグラウンドサービス終了時
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> callback(LocationDto locationDto) async {
    //既に実行中の場合はスキップする（二重実行防止）
    count += 1;
    debugPrint('$count, ${locationDto.latitude}, ${locationDto.longitude}');
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(locationDto.toJson());
  }
}
