// Filename: add_subject_screen.dart
import 'package:flutter/material.dart';

class AddSubjectScreen extends StatelessWidget { // Renamed class
  final subjectController = TextEditingController();
  final teacherController = TextEditingController();

  AddSubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Subject")), // Updated AppBar title
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: subjectController, decoration: const InputDecoration(labelText: "Subject Name")), // Clarified label
            TextField(controller: teacherController, decoration: const InputDecoration(labelText: "Teacher Name")), // Clarified label
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Will be added later
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Subject Saved (not really yet 😅)"))); // Updated Snackbar text
              },
              icon: const Icon(Icons.class_), // Changed icon to a class/subject appropriate icon
              label: const Text("Save Subject"), // Updated button text
            )
          ],
        ),
      ),
    );
  }
}