import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skedule/supabase_service.dart';
import 'package:skedule/theme/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  List<Map<String, dynamic>> _assignments = [];
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  String? _selectedSubject;
  List<String> _subjects = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([_fetchAssignments(), _fetchSubjects()]);
  }

  Future<void> _fetchAssignments() async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return;
      
      final response = await SupabaseService.client
          .from('assignments')
          .select()
          .eq('user_id', userId)
          .order('due_date', ascending: true);

      if (response != null) {
        setState(() => _assignments = List<Map<String, dynamic>>.from(response));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching assignments: $e')),
        );
      }
    }
  }

  Future<void> _fetchSubjects() async {
    try {
      final response = await SupabaseService.client
          .from('subject')
          .select('subject_id')
          .order('subject_id', ascending: true);

      if (response != null) {
        setState(() {
          _subjects = response
              .map<String>((subject) => subject['subject_id'] as String)
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching subjects: $e')),
        );
      }
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dueDate) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _addAssignment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date')),
      );
      return;
    }

    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return;

      await SupabaseService.client.from('assignments').insert({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'due_date': _dueDate!.toIso8601String(),
        'subject': _selectedSubject,
        'is_completed': false,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _dueDate = null;
        _selectedSubject = null;
      });
      await _fetchAssignments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment added successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding assignment: $e')),
        );
      }
    }
  }

  Future<void> _toggleComplete(int id, bool currentStatus) async {
    try {
      await SupabaseService.client
          .from('assignments')
          .update({'is_completed': !currentStatus})
          .eq('id', id);
      await _fetchAssignments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating assignment: $e')),
        );
      }
    }
  }

  Future<void> _deleteAssignment(int id) async {
    try {
      await SupabaseService.client
          .from('assignments')
          .delete()
          .eq('id', id);
      await _fetchAssignments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting assignment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Assignments'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddAssignmentDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _assignments.isEmpty
          ? Center(
              child: Text(
                'No assignments yet!\nTap + to add one',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.text.withOpacity(0.5),
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _assignments.length,
              itemBuilder: (context, index) {
                final assignment = _assignments[index];
                final dueDate = DateTime.parse(assignment['due_date']);
                final isOverdue = dueDate.isBefore(DateTime.now()) &&
                    !assignment['is_completed'];
                final isCompleted = assignment['is_completed'];

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: AppColors.card,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                assignment['title'],
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isCompleted
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: isCompleted
                                        ? Colors.green
                                        : AppColors.primary,
                                  ),
                                  onPressed: () => _toggleComplete(
                                    assignment['id'],
                                    assignment['is_completed'],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteAssignment(
                                      assignment['id']),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (assignment['description'] != null &&
                            assignment['description'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              assignment['description'],
                              style: TextStyle(
                                color: AppColors.text.withOpacity(0.7),
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.subject,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                assignment['subject'] ?? 'No Subject',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: isOverdue
                                    ? Colors.red
                                    : AppColors.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('MMM dd, yyyy').format(dueDate),
                                style: TextStyle(
                                  color: isOverdue
                                      ? Colors.red
                                      : AppColors.secondary,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showAddAssignmentDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Assignment'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                    items: _subjects
                        .map((subject) => DropdownMenuItem(
                              value: _selectedSubject,
                              child: Text(subject),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedSubject = value),
                    validator: (value) =>
                        value == null ? 'Please select a subject' : null,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDueDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _dueDate == null
                            ? 'Select Date'
                            : DateFormat('MMM dd, yyyy').format(_dueDate!),
                        style: TextStyle(
                          color: _dueDate == null
                              ? Colors.grey[700]
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addAssignment,
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}