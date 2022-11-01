// ignore: file_names
import 'dart:ffi';

class Comic {
  /// 漫画的标题
  String title = '';

  /// 简述
  String? description;

  /// 标签 / 分类 / 类型
  List<String>? tags;

  /// 作者
  String? author;

  /// 更新时间
  String? updateTime;

  /// 连载状态
  String? statusText;

  Comic.fromMap(Map data) {
    title = data['title'];
    description = data['description'];
    tags = data['tags'];
    author = data['author'];
    updateTime = data['updateTime'];
    statusText = data['statusText'];
  }
}
