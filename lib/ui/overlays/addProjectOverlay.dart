import 'dart:convert';
import 'dart:js_util';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../services/secureStorageService.dart';
import 'package:http/http.dart' as http;


enum Language {
  Bangla,
  Maithili,
  Konkani,
  Marathi,
  Manipuri,
  Nepali,
  Bodo,
  Assamee,
  Hindi,
}

class AddProjectOverlay extends StatefulWidget {
  final VoidCallback? onCancel;

  const AddProjectOverlay({super.key, this.onCancel});

  @override
  State<AddProjectOverlay> createState() => _AddProjectOverlayState();
}

class _AddProjectOverlayState extends State<AddProjectOverlay> {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectDescriptionController =
      TextEditingController();

  String dropdownValue = 'English';
  bool _fileUploaded = false;
  Language? _selectedLanguage = Language.Bangla;
  String? fileContent;
  String? token;

  // List of items in our dropdown menu

  Future<Object> _uploadProject(String projectTitle, String projectDescription,
      String language, String fileText) async {

    var url = Uri.https('www.cfilt.iitb.ac.in', 'annotation_tool_apis/project/add_project');
    token = await SecureStorage().readSecureData("jwtToken");
    print(token);
    var header = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    var body = {
      "title": projectTitle,
      "description": projectDescription,
      "language": language,
      "file_text": fileText
    };
    String bodyJson = jsonEncode(body);

    final response = await http.post(
      url,
      headers: header,
      body: bodyJson,
    );
    print(response);
    if (response.statusCode == 201) {

      return response;

    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.grey[200],
        width: 800,
        height: 480,
        child: Column(
          children: [
            const Text(
              'Add Project',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              const SizedBox(width: 120, child: Text('Project Title')),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(
                    top: 20, right: 8, left: 8, bottom: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                width: 500,
                height: 40,
                child: TextField(
                  controller: _projectNameController,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              )
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              const SizedBox(width: 120, child: Text('Project Decription')),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                width: 500,
                height: 40,
                child: TextField(
                  controller: _projectDescriptionController,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              )
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              const SizedBox(width: 120, child: Text('Language')),
              Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  width: 500,
                  height: 150,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: ListTile(
                              title: const Text('Bangla'),
                              leading: Radio<Language>(
                                value: Language.Bangla,
                                groupValue: _selectedLanguage,
                                onChanged: (Language? value) {
                                  setState(() {
                                    _selectedLanguage = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text('Maithili'),
                              leading: Radio<Language>(
                                value: Language.Maithili,
                                groupValue: _selectedLanguage,
                                onChanged: (Language? value) {
                                  setState(() {
                                    _selectedLanguage = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text('Konkani'),
                              leading: Radio<Language>(
                                value: Language.Konkani,
                                groupValue: _selectedLanguage,
                                onChanged: (Language? value) {
                                  setState(() {
                                    _selectedLanguage = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: ListTile(
                              title: const Text('Marathi'),
                              leading: Radio<Language>(
                                value: Language.Marathi,
                                groupValue: _selectedLanguage,
                                onChanged: (Language? value) {
                                  setState(() {
                                    _selectedLanguage = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text('Nepali'),
                              leading: Radio<Language>(
                                value: Language.Nepali,
                                groupValue: _selectedLanguage,
                                onChanged: (Language? value) {
                                  setState(() {
                                    _selectedLanguage = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text('Bodo'),
                              leading: Radio<Language>(
                                value: Language.Bodo,
                                groupValue: _selectedLanguage,
                                onChanged: (Language? value) {
                                  setState(() {
                                    _selectedLanguage = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: ListTile(
                              title: const Text('Hindi'),
                              leading: Radio<Language>(
                                value: Language.Hindi,
                                groupValue: _selectedLanguage,
                                onChanged: (Language? value) {
                                  setState(() {
                                    _selectedLanguage = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text('Manipuri'),
                              leading: Radio<Language>(
                                value: Language.Manipuri,
                                groupValue: _selectedLanguage,
                                onChanged: (Language? value) {
                                  setState(() {
                                    _selectedLanguage = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text('Assamee'),
                              leading: Radio<Language>(
                                value: Language.Assamee,
                                groupValue: _selectedLanguage,
                                onChanged: (Language? value) {
                                  setState(() {
                                    _selectedLanguage = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ))
            ]),
            Container(
              margin: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        fileContent = await pickAndDecodeFile();
                      },
                      child: const SizedBox(
                          width: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(Icons.upload),
                              Text("Upload Text File"),
                            ],
                          ))),
                  if (_fileUploaded)
                    const Text(
                      "File Uploaded Successfully",
                      style: TextStyle(
                          color: Colors.green, fontStyle: FontStyle.italic),
                    )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (_projectNameController.text.isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Project Name is mandatory"),
                          ));
                        }
                        if (_projectDescriptionController.text.isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Project Description is mandatory"),
                          ));
                        }
                        if (not(_fileUploaded)) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Text File Upload is mandatory"),
                          ));
                        }
                        if (_projectNameController.text.isNotEmpty &
                            _projectNameController.text.isNotEmpty &
                            _fileUploaded) {
                          var response = _uploadProject(
                              _projectNameController.text,
                              _projectDescriptionController.text,
                              _selectedLanguage!.toString(),
                              fileContent!);
                          print("response +$response");
                          widget.onCancel!();
                        }
                      },
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll<Color>(Colors.green)),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      )),
                  ElevatedButton(
                      onPressed: () {
                        if (widget.onCancel != null) {
                          widget.onCancel!();
                        }
                      },
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll<Color>(Colors.red)),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        _fileUploaded = true;
      });
      return file.bytes; // For Flutter web, you directly get bytes
    } else {
      // User canceled the picker
      return null;
    }
  }

  Future<String> processFileBytes(Uint8List fileBytes) async {
    return String.fromCharCodes(fileBytes);
  }

  Future<String> pickAndDecodeFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      // For Flutter Web, the result contains the file bytes directly
      setState(() {
        _fileUploaded = true;

      });
      PlatformFile file = result.files.first;

      // Decoding the bytes assuming the file is encoded in UTF-8
      //print(file.bytes.toString());
      String fileContent = utf8.decode(file.bytes!);

      // You can now use the `fileContent` string which contains your Hindi paragraphs
      return fileContent;
    } else {
      // User canceled the picker
      return "Empty";
    }
  }
}
