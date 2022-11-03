import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class BaseCrawler {
  static var dbConnection;

  String enqueueStrategy = 'same-site';

  Set<String> entries;

  Dio dio = Dio();

  BaseCrawler(this.entries) {
    if (entries.isEmpty) {
      if (kDebugMode) {
        print('crawler should have at least one entry');
      }
    }
  }

  tryResume() {}

  run() async {
    // enqueue link
    // route
    // handle
    // yield data
  }

  stop() {}
}
