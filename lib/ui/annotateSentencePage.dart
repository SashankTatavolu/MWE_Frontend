import 'dart:math';

import 'package:flutter/material.dart';
import 'package:multiwordexpressionworkbench/ui/loginPage.dart';

import '../models/annotation_model.dart';
import '../models/project.dart';
import '../models/sentence_model.dart';
import '../services/annotationService.dart';
import 'package:pdfrx/pdfrx.dart';

class AnnotateSentencePage extends StatefulWidget {
  final List<Sentence> sentences;
  final Project project;

  const AnnotateSentencePage(
      {super.key, required this.sentences, required this.project});

  @override
  State<AnnotateSentencePage> createState() => _AnnotateSentencePageState();
}

class _AnnotateSentencePageState extends State<AnnotateSentencePage> {
  List<Annotation> annotationList = [];
  Map<int, TextEditingController> annotationControllers = {}; // Add this map
  int selectedIndex = -1;
  TextEditingController? _controller;
  int currentPage = 0;
  final int sentencesPerPage = 6;
  bool isValidTextSelected = false;
  String selectedText = "";
  final List<String> _dropdownAnnotationValues = [
    "Noun Compound",
    "Reduplicated",
    "Idiom",
    "Compound Verb",
    "Complex Predicate"
  ];
  String? _selectedValue;
  bool unsavedChanges = false;
  AnnotationService annotationService = AnnotationService();
  String _selectedType = 'Multiword Expression';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    for (var controller in annotationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _checkSelectedText(TextEditingController controller) {
    if (controller.selection.isValid) {
      String selectedText = controller.text
          .substring(controller.selection.start, controller.selection.end);
      if (selectedText.trim().split(RegExp(r'\s+')).length > 1) {
        print("Selected text: $selectedText");
        isValidTextSelected = true;
        setState(() {
          this.selectedText = selectedText;
        });
      } else {
        setState(() {
          isValidTextSelected = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = (widget.sentences.length / sentencesPerPage).ceil();
    final currentPageSentences = getCurrentPageSentences();

    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              _buildProjectHeader(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMainContent(currentPageSentences, pages),
                  _buildAnnotationsSidebar(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Sentence> getCurrentPageSentences() {
    final startIndex = currentPage * sentencesPerPage;
    final endIndex =
        min(startIndex + sentencesPerPage, widget.sentences.length);
    return widget.sentences.getRange(startIndex, endIndex).toList();
  }

  Widget _buildMainContent(List<Sentence> currentPageSentences, int pages) {
    return Row(
      children: [
        Container(
          width: 900,
          height: 600,
          child: Column(
            children: [
              _buildSentenceList(currentPageSentences),
              isValidTextSelected
                  ? _buildAnnotationControls()
                  : _buildSelectTextPrompt(),
              _buildPaginationControls(pages),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnnotationControls() {
    return Container(
      child: Column(
        children: [
          Container(
            child: const Row(
              children: [
                Text("Annotation Type"),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Selected Text : $selectedText"),
              _buildDropdownAnnotation(),
              _buildAddButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRadioTile(String title) {
    return ListTile(
      title: Text(title),
      leading: Radio<String>(
        value: title,
        groupValue: _selectedType,
        onChanged: (String? value) {
          setState(() {
            _selectedType = value!;
          });
        },
      ),
    );
  }

  Widget _buildDropdownAnnotation() {
    return DropdownButton<String>(
      value: _selectedValue,
      hint: const Text("Select Annotation"),
      items: _dropdownAnnotationValues.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedValue = newValue;
        });
      },
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: _onAddButtonPressed,
      child: const Text("Add"),
    );
  }

  void _onAddButtonPressed() {
    if (_selectedValue != null) {
      Annotation annotation = Annotation(
        wordPhrase: selectedText,
        annotation: _selectedValue!,
        sentenceId: widget
            .sentences[selectedIndex + (currentPage * sentencesPerPage)].id,
        projectId: widget.project.id,
      );
      print(annotation.toJson());
      setState(() {
        unsavedChanges = true;
        annotationList.add(annotation);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Select Annotation")),
      );
    }
  }

  Widget _buildSelectTextPrompt() {
    return const Text(
      "Select at least two words to Annotate",
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAnnotationsSidebar() {
    return Container(
      width: 400,
      height: 500,
      margin: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAnnotationsList(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildAnnotationsList() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(),
        ),
        child: ListView.builder(
          itemCount: annotationList.length,
          itemBuilder: (context, index) {
            return _buildAnnotationListItem(index);
          },
        ),
      ),
    );
  }

  Widget _buildAnnotationListItem(int index) {
    final annotation = annotationList[index];

    // Initialize the controller for each annotation if not already initialized
    if (!annotationControllers.containsKey(index)) {
      annotationControllers[index] =
          TextEditingController(text: annotation.wordPhrase);
    }

    final annotationController = annotationControllers[index]!;

    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: TextField(
              controller: annotationController,
              decoration: const InputDecoration(
                hintText: 'Edit annotation text',
              ),
              onChanged: (newValue) {
                setState(() {
                  annotationList[index].wordPhrase = newValue;
                  unsavedChanges = true;
                });
              },
            ),
          ),
          Text(
            ": ${annotation.annotation}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      leading: Text(
        (index + 1).toString(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => _deleteAnnotation(index),
      ),
    );
  }

  void _deleteAnnotation(int index) {
    setState(() {
      annotationList.removeAt(index);
    });
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSubmitButton(),
        _buildResetButton(),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _handleSubmit,
      child: const Text("Submit"),
    );
  }

  void _handleSubmit() async {
    bool submitStatus = await annotationService.addAnnotation(annotationList);
    if (submitStatus) {
      setState(() {
        unsavedChanges = false;
        // Assuming annotationList[0] is not out of bounds; consider handling potential empty list or refactor logic accordingly.
        widget.sentences[selectedIndex + (currentPage * sentencesPerPage)]
            .isAnnotated = true;
        annotationList = [];
      });
    } else {
      // Handle failure case
    }
  }

  Widget _buildResetButton() {
    return ElevatedButton(
      onPressed: _handleReset,
      child: const Text("Reset"),
    );
  }

  void _handleReset() async {
    setState(() {
      annotationList = [];
    });
  }

  Widget _buildProjectHeader() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [Text(widget.project.title), Text(widget.project.language)],
      );

  Widget _buildSentenceList(List<Sentence> sentences) => Expanded(
        child: ListView.builder(
          itemCount: sentences.length,
          itemBuilder: (context, index) {
            return _buildSentenceTile(index, sentences);
          },
        ),
      );

  Widget _buildSentenceTile(int index, List<Sentence> sentences) {
    final isSelected = selectedIndex == index;
    final sentence = sentences[index];

    return ListTile(
      onTap: () async {
        if (unsavedChanges) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  "Please submit the annotations before moving on to the next sentence")));
        } else {
          List<Annotation> existingAnnotationList =
              await annotationService.fetchAnnotations(sentence.id);
          print(existingAnnotationList);
          setState(() {
            selectedIndex = index; // Update the selected index
            isValidTextSelected = false;
            // Update the controller only if the selected index changes
            _controller?.text =
                sentence.content; // Set the text for the current sentence
            annotationList = existingAnnotationList;
          });
        }
      },
      leading: sentence.isAnnotated == true
          ? const Icon(
              Icons.done_outline_outlined,
              color: Colors.green,
            )
          : null,
      title: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
          color: isSelected ? Colors.yellow : Colors.grey[300],
        ),
        padding: const EdgeInsets.all(8),
        height: 60,
        child: isSelected
            ? TextField(
                decoration: const InputDecoration(border: InputBorder.none),
                controller:
                    _controller, // Link the controller to the selected text
                readOnly: true,
                showCursor: false,
                autofocus: true,
              )
            : Text(
                sentence.content,
                style: const TextStyle(fontSize: 16.5),
              ),
      ),
      trailing: selectedIndex == index
          ? ElevatedButton(
              onPressed: () {
                _checkSelectedText(_controller!);
              },
              child: Text("Annotate"),
            )
          : null,
    );
  }

  Widget _buildPaginationControls(int pages) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: currentPage > 0
                ? () => setState(() {
                      currentPage--;
                      // Reset selectedIndex to -1 when changing pages
                      selectedIndex = -1;
                      _controller?.clear(); // Clear the controller
                    })
                : null,
          ),
          Text('Page ${currentPage + 1} of $pages'),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: currentPage < pages - 1
                ? () => setState(() {
                      currentPage++;
                      selectedIndex = -1; // Reset selected index on page change
                      _controller?.clear(); // Clear the controller
                    })
                : null,
          ),
        ],
      );

  void _handleLogout(BuildContext context) {
    // Clear any existing user data if needed (optional)

    // Navigate to the login page and remove all previous routes from the stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false, // This removes all previous routes
    );
  }

  void _showPdf(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("PDF Content"),
          content: SizedBox(
            width: 1000,
            height: 600,
            child: PdfViewer.asset(
                'assets/files/USER_Guidelines.pdf'), // Update path as necessary
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPDF(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("PDF Content"),
          content: SizedBox(
            width: 1000,
            height: 600,
            child: PdfViewer.asset(
                'assets/files/annotation_guidelines.pdf'), // Update path as necessary
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  AppBar _buildAppBar() => AppBar(
        leading: Image.asset("images/logo.png"),
        toolbarHeight: 100,
        leadingWidth: 300,
        backgroundColor: Colors.blue[100],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _showPdf(context);
              },
              child: const Text("Show User Guidelines"),
            ),
            const Spacer(),
            const Text('Multiword Expression Workbench'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                _showPDF(context);
              },
              child: const Text("Show Annotation Guidelines"),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                _handleLogout(context);
              },
              child: const Text("Log Out"),
            ),
          ),
        ],
      );
}
