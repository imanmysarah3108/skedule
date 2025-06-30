import 'package:flutter/material.dart';
import 'package:skedule/performance%20_helper.dart';
import 'package:skedule/supabase_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final PageController _pageController = PageController(initialPage: 2);
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  int _currentPage = 2;
  final Map<int, List<Map<String, dynamic>>> _cachedClasses = {};
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _cachedClasses.clear();
    super.dispose();
  }

  Future<void> _loadClassesForDay(int dayIndex) async {
    if (_isLoading || _cachedClasses.containsKey(dayIndex)) return;

    setState(() => _isLoading = true);
    
    try {
      await PerformanceHelper.runInBackground(() async {
        final classes = await SupabaseService.getUserClasses(
          SupabaseService.client.auth.currentUser?.id ?? ''
        );
        _cachedClasses[dayIndex] = classes.where((c) => c['day'] == _days[dayIndex]).toList();
      });
    } catch (e) {
      debugPrint('Error loading classes: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildClassItem(Map<String, dynamic> classItem) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              classItem['time'] ?? 'No time',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              classItem['name'] ?? 'No class name',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              classItem['room'] ?? 'No room',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _days[index],
                  style: TextStyle(
                    color: _currentPage == index ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassList(int dayIndex) {
    if (_isLoading && !_cachedClasses.containsKey(dayIndex)) {
      return PerformanceHelper.buildLoadingPlaceholder();
    }

    final classes = _cachedClasses[dayIndex] ?? [];

    if (classes.isEmpty) {
      return Center(
        child: Text(
          'No classes for ${_days[dayIndex]}',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: classes.length,
      itemBuilder: (context, index) => _buildClassItem(classes[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_days[_currentPage]),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                _loadClassesForDay(index);
              },
              itemBuilder: (context, index) => _buildClassList(index),
              itemCount: _days.length,
            ),
          ),
        ],
      ),
    );
  }
}