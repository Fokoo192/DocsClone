// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DocumentModel {
  final String title;
  final String uid;
  final List contents;
  final DateTime createdAt;
  final String id;
  DocumentModel({
    required this.title,
    required this.uid,
    required this.contents,
    required this.createdAt,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'uid': uid,
      'contents': contents,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'id': id,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      title: map['title'] ?? "",
      uid: map['uid'] ?? "",
      id: map['_id'] ?? "",
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      contents: List.from((map['contents'])),
    );
  }

  String toJson() => json.encode(toMap());

  factory DocumentModel.fromJson(String source) => DocumentModel.fromMap(json.decode(source));
}

