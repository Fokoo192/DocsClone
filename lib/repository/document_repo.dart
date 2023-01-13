import 'dart:convert';
import 'package:docs_clone/constants.dart';
import 'package:docs_clone/models/document_model.dart';
import 'package:docs_clone/models/error_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final documentRepoProvider = Provider((ref) => DocumentRepo(client: Client()));

class DocumentRepo {
  final Client _client;

  DocumentRepo({required Client client}) : _client = client;

  Future<ErrorModel> createDocument(String token) async {
    ErrorModel error =
        ErrorModel(error: "Some unexpected error occured", data: null);
    try {
      var res = await _client.post(Uri.parse("$host/doc/create"),
          headers: {
            "Content-Type": "application/json; charset=UTF-8",
            "x-auth-token": token
          }, //tellin the server it is in json format
          body:
              jsonEncode({"createdAt": DateTime.now().millisecondsSinceEpoch}));
      switch (res.statusCode) {
        case 200:
          error =
              ErrorModel(error: null, data: DocumentModel.fromJson(res.body));
          break;
        default:
          error = ErrorModel(error: res.body, data: null);
          break;
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> getDocuments(String token) async {
    ErrorModel error =
        ErrorModel(error: "Some unexpected error occured", data: null);
    try {
      var res = await _client.get(
        Uri.parse("$host/docs/me"),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "x-auth-token": token
        }, //tellin the server it is in json format
      );
      switch (res.statusCode) {
        case 200:
          //passing each page into the list one after another
          List<DocumentModel> docs = [];
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            docs.add(
                DocumentModel.fromJson(jsonEncode(jsonDecode(res.body)[i])));
          }
          error = ErrorModel(error: null, data: docs);
          break;
        default:
          error = ErrorModel(error: res.body, data: null);
          break;
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> updateTitle({
      required String token,
      required String id,
      required String title
      }) async {
    ErrorModel error =
        ErrorModel(error: "Some unexpected error occured", data: null);
    try {
      var res = await _client.post(Uri.parse("$host/doc/title"),
          headers: {
            "Content-Type": "application/json; charset=UTF-8",
            "x-auth-token": token
          },
          body: jsonEncode({"id": id, "title": title}));
      switch (res.statusCode) {
        case 200:
          error =
              ErrorModel(error: null, data:title); //not really needed but used for error checking
          break;
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> getDocumentById(String token, String id) async {
    ErrorModel error =
        ErrorModel(error: "Some unexpected error occured", data: null);
    try {
      var res = await _client.get(
        Uri.parse("$host/docs/$id"),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "x-auth-token": token
        }, //tellin the server it is in json format
      );
      switch (res.statusCode) {
        case 200:
          error = ErrorModel(error: null, data: DocumentModel.fromJson(res.body));
          break;
        default:
          throw "This document does not , please create another one"; 
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }
}
