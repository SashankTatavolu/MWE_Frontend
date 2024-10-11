import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multiwordexpressionworkbench/services/annotationService.dart';
import 'package:multiwordexpressionworkbench/ui/annotateSentencePage.dart';
import 'package:multiwordexpressionworkbench/ui/loginPage.dart';
import 'package:multiwordexpressionworkbench/ui/overlays/addProjectOverlay.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../fetchData/fetchProjectItems.dart';
import '../fetchData/fetchSentenceItems.dart';
import '../models/project.dart';
import '../models/sentence_model.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List<Project> projects = [];
  List<Sentence> sentences = [];
  int currentPage = 0;
  final int itemsPerPage = 5;
  final AnnotationService annotationService = AnnotationService();

  Future<void> fetchProjectItems() async {
    try {
      final fetchedProjects =
          await FetchProjectItems(); // Assuming this returns List<Project>
      setState(() {
        projects = fetchedProjects;
      });
    } catch (e) {
      print("Error fetching projects: $e");
      // Handle any errors here, perhaps by showing a message to the user
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProjectItems();
  }

  void _showOverlay(BuildContext context) async {
    OverlayState overlayState = Overlay.of(context);
    late OverlayEntry
        overlayEntry; // Declare overlayEntry late so it can be used in its initializer.
    overlayEntry = OverlayEntry(
      builder: (context) => Center(
        // Use Center to align the overlay container.
        child: AddProjectOverlay(
          onCancel: () async {
            await fetchProjectItems();
            overlayEntry
                .remove(); // This will remove the overlay when the cancel button is pressed.
          },
        ),
      ),
    );
    overlayState.insert(overlayEntry);
  }

  void _handleLogout(BuildContext context) {
    // Clear any existing user data if needed (optional)

    // Navigate to the login page and remove all previous routes from the stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false, // This removes all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (projects.length / itemsPerPage).ceil();

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
        actions: [
          Container(
              margin: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                  onPressed: () {
                    _handleLogout(context);
                  },
                  child: const Text("Log Out"))),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(40),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Projects",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                  onPressed: () {
                    _showOverlay(context);
                  },
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.green)),
                  child: const Text(
                    "+ Add Project",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  )),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: itemsPerPage,
              itemBuilder: (context, index) {
                if (index + currentPage * itemsPerPage < projects.length) {
                  final projectIndex = index + currentPage * itemsPerPage;
                  final project = projects[projectIndex];
                  return Card(
                    child: ListTile(
                      onTap: () async {
                        sentences = await FetchSentenceItems(project.id);
                        print(sentences[0].content);
                        Get.to(AnnotateSentencePage(
                          sentences: sentences,
                          project: project,
                        ));
                      },
                      title: Text(project.title),
                      subtitle: Text(
                          'Language: ${project.language}\nDescription: ${project.description}'),
                      trailing: SizedBox(
                        width: 400,
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: LinearPercentIndicator(
                                width: 150,
                                lineHeight: 20.0,
                                percent: 0.8,
                                center: const Text("80.0%"),
                                linearStrokeCap: LinearStrokeCap.roundAll,
                                progressColor: Colors.green,
                              ),
                            ),
                            PopupMenuButton(
                              onSelected: (String result) {},
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                    value: 'Option 1',
                                    child: Text('Download XML'),
                                    onTap: () async {
                                      await annotationService
                                          .downloadAnnotationsXML(
                                              project.id, project.title);
                                    }),
                                PopupMenuItem<String>(
                                    value: 'Option 2',
                                    child: Text('Download Text'),
                                    onTap: () async {
                                      await annotationService
                                          .downloadAnnotationsTXT(
                                              project.id, project.title);
                                    }),
                              ],
                              icon: const Icon(Icons.download),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container(); // Return an empty container for unused slots
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: currentPage > 0
                    ? () {
                        setState(() {
                          currentPage--;
                        });
                      }
                    : null,
              ),
              ...List<Widget>.generate(totalPages, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '${index + 1}',
                      style: (index == currentPage)
                          ? const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)
                          : null,
                    ),
                  ),
                );
              }),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: currentPage < totalPages - 1
                    ? () {
                        setState(() {
                          currentPage++;
                        });
                      }
                    : null,
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
