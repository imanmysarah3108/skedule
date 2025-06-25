// Filename: add_subject_screen.dart
import 'package:flutter/material.dart';

class AddSubjectScreen extends StatelessWidget { // Renamed class
  final subjectController = TextEditingController();
  final teacherController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Subject")), // Updated AppBar title
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: subjectController, decoration: InputDecoration(labelText: "Subject Name")), // Clarified label
            TextField(controller: teacherController, decoration: InputDecoration(labelText: "Teacher Name")), // Clarified label
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Will be added later
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Subject Saved (not really yet 😅)"))); // Updated Snackbar text
              },
              icon: Icon(Icons.class_), // Changed icon to a class/subject appropriate icon
              label: Text("Save Subject"), // Updated button text
            )
          ],
        ),
      ),
    );
  }
}