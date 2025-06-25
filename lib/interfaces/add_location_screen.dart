import 'package:flutter/material.dart';

class AddLocationScreen extends StatelessWidget {
  final buildingController = TextEditingController();
  final roomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Location")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: buildingController,
              decoration: InputDecoration(labelText: "Building Name"), // Changed label
            ),
            TextField(
              controller: roomController,
              decoration: InputDecoration(labelText: "Room Number"), // Changed label
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Will be added later - you can access values like:
                // String buildingName = buildingController.text;
                // String roomNumber = roomController.text;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location Saved (not really yet 😅)"))); // Updated text
              },
              child: Text("Save Location"), // Changed text
            )
          ],
        ),
      ),
    );
  }
}