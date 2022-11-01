import 'package:flutter/foundation.dart';

class BaseCrawler {
  static var dbConnection;

  String enqueueStrategy = 'same-site';

  List<String> entries;

  BaseCrawler(this.entries) {
    if (entries.isEmpty) {
      if (kDebugMode) {
        print('crawler should have at least one entry');
      }
    }
  }

  tryResume() {}

  run() {
    // enqueue link
    // route
    // handle
    // yield data
  }

  stop() {}
}
