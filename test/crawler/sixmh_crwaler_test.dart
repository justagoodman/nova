import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:nova/crawler/sixmh.dart';
import 'package:nova/model/Comic.dart';
import 'package:path/path.dart' as path;

void main() {
  test('should get data', () async {
    var crawler = SixMHCrawler();
    var data;
    try {
      data = await crawler.makeRequest('http://www.sixmh7.com');
    } catch (e) {
      print(e);
      data = null;
    }

    expect(data, isNotNull);
  });

  test('should find links from html', () async {
    var crawler = SixMHCrawler();

    // for test only
    // path would be like /D:/FlutterProject/nova_project
    // the first / character is not necessary
    var pathStr = path.dirname(Platform.script.path).substring(1);

    var file = File('$pathStr/test/crawler/test.html');

    var html = file.readAsStringSync();
    var doc = Document.html(html);

    var links = crawler.findLinks(doc, 'http://www.sixmh7.com');

    expect(links.length, equals(162));
  });

  test('should normalize links ', () async {
    var crawler = SixMHCrawler();

    var relative = '/';
    var full = 'http://123.3.0.0';
    var fullHttps = 'https://125555';
    var notRight = 'ws://1111';
    var notEvenALink = 's4s4s4s4';

    expect(crawler.normalizeLink(relative, 'http://www.sixmh7.com'),
        equals('http://www.sixmh7.com/'));

    expect(crawler.normalizeLink(full, 'http://www.sixmh7.com'),
        equals('http://123.3.0.0'));

    expect(crawler.normalizeLink(fullHttps, 'http://www.sixmh7.com'),
        equals('https://125555'));

    expect(crawler.normalizeLink(notRight, 'http://www.sixmh7.com'),
        equals('http://www.sixmh7.comws://1111'));

    expect(crawler.normalizeLink(notEvenALink, 'http://www.sixmh7.com'),
        equals('http://www.sixmh7.coms4s4s4s4'));
  });

  test('should run until finish ', () async {
    var crawler = SixMHCrawler();

    try {
      var future = Future.delayed(const Duration(milliseconds: 10), () async {
        await crawler.run();
      }).timeout(const Duration(seconds: 10));

      await future;
    } catch (e) {
      print('finished');
    }

    expect(crawler.entries.length, greaterThan(10));
  });

  test('should correctly find out if the page is detail page ', () async {
    var crawler = SixMHCrawler();

    var isDetail =
        crawler.isDetailPage('http://www.sixmh7.com/15194/', Document());

    expect(isDetail, true);
  });

  test('should get tags from text  ', () async {
    var crawler = SixMHCrawler();

    var tags = crawler.getTags('标签：["热血""后宫""玄幻""精品""漫改"]');

    expect(tags, equals(['热血', '后宫', '玄幻', '精品', '漫改']));
  });

  test('should extract comic detail from detail page tags from text  ',
      () async {
    var crawler = SixMHCrawler();

    var pathStr = path.dirname(Platform.script.path).substring(1);

    var file = File('$pathStr/test/crawler/test_detail.html');

    var html = file.readAsStringSync();
    var doc = Document.html(html);

    var comic = crawler.onTouchDetailPage(doc);

    expect(comic.title, '元尊');
    expect(comic.statusText, '连载中');
    expect(comic.author, 'Dr.大吉天蚕土豆');
    expect(comic.tags, equals(['玄幻', '古风', '漫改', '武侠', '精品']));
    expect(comic.updateTime, '2022-11-03');
    expect(comic.description,
        '介绍:主人公周元，为周朝皇子天生圣龙气运。因一道预言，气运被夺身中剧毒，经脉被锁无法修炼。背负国仇家恨，周元没有被这种困境摧毁，而是靠着坚强意志重开八脉，在家族存亡的危机时刻强势崛起。未来路漫漫兮，天生大才注定不凡的少年将在修行路上继续铿锵前行…');
  });
}
