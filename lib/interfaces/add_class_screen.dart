import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:skedule/supabase_service.dart';

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({super.key});

  @override
  _AddClassScreenState createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  // Controllers
  final _subjectController = TextEditingController();
  final _buildingController = TextEditingController();
  final _roomController = TextEditingController();
  final _lecturerController = TextEditingController();

  // Form state
  String? _selectedDay;
  String? _selectedClassType = 'Lecture';
  TimeOfDay? _startTime, _endTime;
  bool _reminderEnabled = false;
  Color _selectedColor = Colors.blue;
  bool _isSaving = false;

  // Predefined options
  static const _daysOfWeek = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
  static const _classTypes = ['Lecture', 'Lab'];

  @override
  void dispose() {
    _subjectController.dispose();
    _buildingController.dispose();
    _roomController.dispose();
    _lecturerController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime 
          ? _startTime ?? TimeOfDay.now()
          : _endTime ?? (_startTime?.plusHours(1) ?? TimeOfDay.now().plusHours(1)),
    );
    if (picked != null) {
      setState(() => isStartTime ? _startTime = picked : _endTime = picked);
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) => setState(() => _selectedColor = color),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveClass() async {
    if (!_validateForm()) return;

    setState(() => _isSaving = true);

    try {
      await _saveClassToDatabase();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool _validateForm() {
    if (_subjectController.text.isEmpty ||
        _buildingController.text.isEmpty ||
        _roomController.text.isEmpty ||
        _selectedDay == null ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return false;
    }
    return true;
  }

  Future<void> _saveClassToDatabase() async {
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) return;

    // Create subject if needed
    final subjectId = await _getOrCreateSubjectId();

    // Format times
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, _startTime!.hour, _startTime!.minute);
    final endTime = DateTime(now.year, now.month, now.day, _endTime!.hour, _endTime!.minute);

    await SupabaseService.client.from('classes').insert({
      'user_id': userId,
      'subject_id': subjectId,
      'class_type': _selectedClassType,
      'building': _buildingController.text,
      'room': _roomController.text,
      'lecturer': _lecturerController.text,
      'day': _selectedDay,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'color_hex': '#${_selectedColor.value.toRadixString(16).substring(2, 8)}',
      'reminder': _reminderEnabled,
    });
  }

  Future<String> _getOrCreateSubjectId() async {
    final existing = await SupabaseService.client
        .from('subject')
        .select('subject_id')
        .eq('subject_title', _subjectController.text)
        .maybeSingle();

    if (existing != null) return existing['subject_id'];

    final newSubject = await SupabaseService.client
        .from('subject')
        .insert({'subject_title': _subjectController.text})
        .select()
        .single();

    return newSubject['subject_id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Class")),
      body: _isSaving 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextField(_subjectController, "Subject", "Enter subject name", Icons.subject),
                  const SizedBox(height: 16),
                  _buildTextField(_buildingController, "Building", "Enter building name", Icons.business),
                  const SizedBox(height: 16),
                  _buildTextField(_roomController, "Room", "Enter room number", Icons.meeting_room),
                  const SizedBox(height: 16),
                  _buildTextField(_lecturerController, "Lecturer (Optional)", "Enter lecturer name", Icons.person),
                  const SizedBox(height: 16),
                  _buildDropdown("Day", _selectedDay, _daysOfWeek, Icons.calendar_today, 
                      (v) => setState(() => _selectedDay = v)),
                  const SizedBox(height: 16),
                  _buildDropdown("Class Type", _selectedClassType, _classTypes, Icons.class_, 
                      (v) => setState(() => _selectedClassType = v)),
                  const SizedBox(height: 16),
                  _buildColorPicker(),
                  const SizedBox(height: 16),
                  const Text("Class Time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildTimePicker("Start Time", _startTime, true)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTimePicker("End Time", _endTime, false)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildReminderToggle(),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveClass,
                    icon: _isSaving 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? "Saving..." : "Save Class"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, IconData icon, ValueChanged<String?> onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return InkWell(
      onTap: _showColorPicker,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: "Class Color",
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.color_lens),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _selectedColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black54),
              ),
            ),
            const SizedBox(width: 10),
            Text('#${_selectedColor.value.toRadixString(16).substring(2, 8)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? time, bool isStartTime) {
    return InkWell(
      onTap: () => _selectTime(context, isStartTime),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(
          time?.format(context) ?? 'Select Time',
          style: TextStyle(color: time == null ? Colors.grey[600] : null),
        ),
      ),
    );
  }

  Widget _buildReminderToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Enable Reminder", style: TextStyle(fontSize: 16)),
        Switch(
          value: _reminderEnabled,
          onChanged: (v) => setState(() => _reminderEnabled = v),
        ),
      ],
    );
  }
}

extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay plusHours(int hours) {
    final minutes = hour * 60 + minute + hours * 60;
    return TimeOfDay(hour: minutes ~/ 60 % 24, minute: minutes % 60);
  }
}