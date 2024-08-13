import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multiwordexpressionworkbench/services/secureStorageService.dart';
import 'package:http/http.dart' as http;
import 'package:multiwordexpressionworkbench/ui/projectDisplayPage.dart';

import '../models/responseModel/accessTokenResponse.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  Future<Object> _validLogin(String email, String password) async {
    var url = Uri.https('www.cfilt.iitb.ac.in', 'annotation_tool_apis/user/login');
    print(url);
    var body = {"email": email, "password": password};
    String bodyJson = jsonEncode(body);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: bodyJson,
    );
    print(response);
    if (response.statusCode == 200) {
      return response;
    } else {
      return false;
    }
 }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset(
          "images/logo.png",
        ),
        toolbarHeight: 100,
        leadingWidth: 300,
        backgroundColor: Colors.grey[300],
        title: const Align(
            alignment: Alignment.center,
            child: Text('Multiword Expression Workbench')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                dynamic response = await _validLogin(emailController.text, passwordController.text);
                if (response == false){
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Incorrect Email or Password")));
                }
                else {

                  String jsonString = response.body;
                  Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
                  AccessTokenResponse accessTokenResponse = AccessTokenResponse.fromJson(jsonResponse);
                  await SecureStorage().writeSecureData('jwtToken', accessTokenResponse.accessToken);
                  await SecureStorage().writeSecureData('role', accessTokenResponse.role);
                  Get.to(const ProjectsPage());

                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
