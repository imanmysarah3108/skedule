import 'package:flutter/material.dart';

class AddLocationScreen extends StatelessWidget {
  final buildingController = TextEditingController();
  final roomController = TextEditingController();

  AddLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Location")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: buildingController,
              decoration: const InputDecoration(labelText: "Building Name"), // Changed label
            ),
            TextField(
              controller: roomController,
              decoration: const InputDecoration(labelText: "Room Number"), // Changed label
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Will be added later - you can access values like:
                // String buildingName = buildingController.text;
                // String roomNumber = roomController.text;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location Saved (not really yet 😅)"))); // Updated text
              },
              child: const Text("Save Location"), // Changed text
            )
          ],
        ),
      ),
    );
  }
}