import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting TimeOfDay

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({super.key});

  @override
  _AddClassScreenState createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  // Controllers for optional text input fields (not explicitly requested, but good practice if needed)
  // final classNameController = TextEditingController(); // Example if you want a class name text input

  // Dropdown states
  String? _selectedSubject;
  String? _selectedLocation;
  String? _selectedClassType = 'Lecture'; // Default value

  // Time picker states
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Toggle state
  bool _reminderEnabled = false;

  // Temporary dummy lists for dropdowns (will be populated from database later)
  final List<String> _subjects = ['Mathematics', 'Science', 'History', 'Art'];
  final List<String> _locations = ['Building A - Room 101', 'Building B - Lab 205', 'Online'];
  final List<String> _classTypes = ['Lecture', 'Lab'];

  // Function to show the time picker
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now().plusHours(1)), // Default end time 1 hour after start
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false), // Set to true for 24-hour format
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Class")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView( // Use SingleChildScrollView for scrollability if content overflows
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
            children: [
              // Subject Dropdown
              _buildDropdown(
                label: "Select Subject",
                value: _selectedSubject,
                items: _subjects,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSubject = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Location Dropdown
              _buildDropdown(
                label: "Select Location",
                value: _selectedLocation,
                items: _locations,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLocation = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Class Type Dropdown
              _buildDropdown(
                label: "Class Type",
                value: _selectedClassType,
                items: _classTypes,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedClassType = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Time Pickers
              const Text("Class Time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTimePickerField(context, "Start Time", _startTime, true),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTimePickerField(context, "End Time", _endTime, false),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Reminder Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Enable Reminder", style: TextStyle(fontSize: 16)),
                  Switch(
                    value: _reminderEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _reminderEnabled = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Save Class Button
              ElevatedButton.icon(
                onPressed: () {
                  // Access the selected values here:
                  // print('Subject: $_selectedSubject');
                  // print('Location: $_selectedLocation');
                  // print('Class Type: $_selectedClassType');
                  // print('Start Time: ${_startTime?.format(context)}');
                  // print('End Time: ${_endTime?.format(context)}');
                  // print('Reminder Enabled: $_reminderEnabled');

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Class saved (conceptually)! Check debug console for values.")),
                  );
                },
                icon: const Icon(Icons.save), // Changed icon to save
                label: const Text("Save Class"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build consistent dropdowns
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      isEmpty: value == null,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Helper method to build consistent time picker fields
  Widget _buildTimePickerField(
      BuildContext context, String label, TimeOfDay? time, bool isStartTime) {
    return InkWell( // Use InkWell to make the text field tappable
      onTap: () => _selectTime(context, isStartTime),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(
          time == null ? 'Select Time' : time.format(context),
          style: TextStyle(fontSize: 16, color: time == null ? Colors.grey[700] : Colors.black),
        ),
      ),
    );
  }
}

// Extension to add hours to TimeOfDay (for initial end time)
extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay plusHours(int hours) {
    int totalMinutes = hour * 60 + minute + hours * 60;
    int newHour = (totalMinutes ~/ 60) % 24;
    int newMinute = totalMinutes % 60;
    return TimeOfDay(hour: newHour, minute: newMinute);
  }
}