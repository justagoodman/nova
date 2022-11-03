import 'package:html/dom.dart';
import 'package:nova/crawler/base.dart';
import 'package:dio/dio.dart';
import 'package:nova/model/Comic.dart';

class SixMHCrawler extends BaseCrawler {
  // retrieve all touched urls
  Set<String> touched = {};

  SixMHCrawler() : super({'http://www.sixmh7.com'}) {}

  isDetailPage(String url, Document doc) {
    var suffix = url.replaceAll('http://www.sixmh7.com/', '');
    if (suffix.endsWith('/')) {
      suffix = suffix.substring(0, suffix.length - 1);
    }
    var suffixNumber = -1;
    try {
      suffixNumber = int.parse(suffix);
    } catch (e) {
      print(e);
      suffixNumber = -1;
    }

    return suffixNumber != -1;
  }

  Comic onTouchDetailPage(Document doc) {
    print('find detail page');

    var title = doc.querySelector('#intro_l > div.cy_title > h1')?.innerHtml;
    var statusText = doc.querySelector('.cy_xinxi font')?.innerHtml;

    var desc = doc.querySelector('#comic-description')?.innerHtml;

    var author = doc.querySelector('.cy_xinxi span:first-child')?.innerHtml;
    if (author != null) {
      author = author.replaceAll('作者：', '');
    }

    var updateTime = doc.querySelector('.cy_zhangjie_top font')?.innerHtml;

    var tags = getTags(doc
        .querySelector(
            '#intro_l:nth-child(1) > div:nth-child(7) > span:last-child')
        ?.innerHtml);

    Comic comic = Comic.fromMap({
      "title": title,
      "statusText": statusText,
      "description": desc,
      "author": author,
      "updateTime": updateTime,
      "tags": tags,
    });
    return comic;
  }

  List<String> getTags(String? text) {
    if (text == null) {
      return [];
    }

    var real = text.replaceAll('标签：', '');
    var tags = real.split('""');
    var tags_modified = tags.map((e) {
      e = e.replaceAll('"', "");
      e = e.replaceAll('[', "");
      e = e.replaceAll(']', "");

      return e;
    });

    return tags_modified.toList();
  }

  String? nextUrl() {
    var url = entries.elementAt(0);
    entries.remove(url);

    while (touched.contains(url)) {
      if (url.isEmpty) {
        break;
      }
      url = entries.elementAt(0);
      entries.remove(url);
    }

    return url;
  }

  recordUrl(url) {
    touched.add(url);
  }

  makeRequest(url) async {
    // get url first

    touched.add(url);

    // request for data
    var data = await this.dio.get(url);

    var doc = Document.html(data.toString());

    return doc;
  }

  @override
  run() async {
    if (entries.isEmpty) {
      print('no entries');
      return;
    }

    var url = nextUrl();

    if (url == null) {
      print('no entries');
      return;
    }

    recordUrl(url);

    var doc = await makeRequest(url);

    var links = findLinks(doc, url);

    entries.addAll(links);

    if (isDetailPage(url, doc)) {
      var commic = onTouchDetailPage(doc);

      print('get comic info -------------');
      print(commic.toString());
    }

    await run();
  }

  findLinks(Document doc, String pageUrl) {
    var aElement = doc.querySelectorAll('a');

    List<String> all = [];

    aElement.forEach((element) {
      var url = element.attributes['href'];
      if (url == null) return;
      var full = normalizeLink(url, pageUrl);
      all.add(full);
    });

    return all;
  }

  normalizeLink(String toNormalize, String pageUrl) {
    if (toNormalize.startsWith('http')) {
      return toNormalize;
    }
    return '$pageUrl$toNormalize';
  }
}
