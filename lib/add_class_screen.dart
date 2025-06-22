import 'package:flutter/material.dart';

class AddClassScreen extends StatelessWidget {
  final subjectController = TextEditingController();
  final teacherController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Class")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: subjectController, decoration: InputDecoration(labelText: "Subject")),
            TextField(controller: teacherController, decoration: InputDecoration(labelText: "Teacher")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Will be added later
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved (not really yet 😅)")));
              },
              child: Text("Save Class"),
            )
          ],
        ),
      ),
    );
  }
}
