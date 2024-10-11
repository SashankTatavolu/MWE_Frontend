import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sentence_model.dart';
import '../services/secureStorageService.dart';


Future<List<Sentence>> FetchSentenceItems(int projectId) async {

  var url = Uri.https('www.cfilt.iitb.ac.in', 'annotation_tool_apis/sentence/get_sentences');
  var token = await SecureStorage().readSecureData("jwtToken");

  var body = {"project_id" : projectId};
  String bodyJson = jsonEncode(body);

  var header = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json; charset=UTF-8'
  };


  final response = await http.post(
    url,
    headers: header,
    body : bodyJson,
  );

  print(response);

  if (response.statusCode == 200) {
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<Sentence>((json) => Sentence.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load Sentence items');
  }
}

