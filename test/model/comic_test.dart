import 'package:flutter_test/flutter_test.dart';
import 'package:nova/model/Comic.dart';

void main() {
  test('should create Comic instance from a map data', () {
    var comicData = {
      'title': 'this is a title',
      'description': 'this is a description',
      'tags': ['tag', 'tag'],
      'author': 'this is an author',
      'statusText': 'this is an statusText'
    };

    var comicInstance = Comic.fromMap(comicData);

    expect(comicInstance.title, 'this is a title');
    expect(comicInstance.description, 'this is a description');
    expect(comicInstance.tags, ['tag', 'tag']);
    expect(comicInstance.author, 'this is an author');
    expect(comicInstance.statusText, 'this is an statusText');
  });
}
