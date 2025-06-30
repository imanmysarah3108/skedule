import 'package:flutter/material.dart';
import 'package:skedule/supabase_service.dart';

class AddSubjectScreen extends StatefulWidget {
  final Function(String)? onSubjectAdded;
  
  const AddSubjectScreen({super.key, this.onSubjectAdded});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _subjectCodeController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _subjectCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveSubject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final subjectTitle = _subjectController.text.trim();
      final subjectCode = _subjectCodeController.text.trim();
      
      // Insert into Supabase
      await SupabaseService.client
          .from('subject')
          .insert({
            'subject_id': subjectCode,  // Assuming subject_id is the code
            'subject_title': subjectTitle
          });

      if (widget.onSubjectAdded != null) {
        widget.onSubjectAdded!(subjectTitle);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subject added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Subject'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveSubject,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _subjectCodeController,
                decoration: const InputDecoration(
                  labelText: 'Subject Code',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. MATH101, SCI202',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. Mathematics, Science',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveSubject,
                icon: _isSaving 
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save Subject'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}