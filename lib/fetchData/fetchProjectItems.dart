import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/project.dart';
import '../services/secureStorageService.dart';


Future<List<Project>> FetchProjectItems() async {

  var url = Uri.https('www.cfilt.iitb.ac.in', 'annotation_tool_apis/project/get_project_list');
  var token = await SecureStorage().readSecureData("jwtToken");

  var header = {
    'Authorization': 'Bearer $token',
  };

  final response = await http.get(
    url,
    headers: header,
  );

  print(response);

  if (response.statusCode == 200) {
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<Project>((json) => Project.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load project items');
  }
}

