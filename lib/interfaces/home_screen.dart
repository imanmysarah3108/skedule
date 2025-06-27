import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'add_class_screen.dart';    // The new AddClassScreen with dropdowns, time picker, etc.
import 'add_location_screen.dart'; // The screen for adding Building Name and Room Number
import 'add_subject_screen.dart';  // The screen for adding Subject Name and Teacher Name
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String userName = "Loading...";
  bool _isFabOpen = false; // State to control the expansion of the FAB
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    fetchUserName();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchUserName() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      setState(() {
        userName = "Unknown User";
      });
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('user_profile')
          .select('name')
          .eq('id', userId)
          .single();

      setState(() {
        userName = response['name'] ?? "Unnamed";
      });
    } catch (e) {
      print("Error fetching user name: $e");
      setState(() {
        userName = "Error loading name";
      });
    }
  }

  void logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget _buildSubFab({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required double delay,
  }) {
    return ScaleTransition( // Scale animation for buttons
      scale: _animation,
      child: FadeTransition( // Fade animation for buttons
        opacity: _animation,
        child: Container( // Wrap in Container for margin
          margin: const EdgeInsets.symmetric(vertical: 6.0), // Spacing between buttons
          child: FloatingActionButton.extended(
            heroTag: label, // Unique tag for each FAB
            onPressed: () {
              onPressed();
              _toggleFab(); // Close FAB menu after selection
            },
            icon: Icon(icon),
            label: Text(label),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Skedule - Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome, $userName!", style: const TextStyle(fontSize: 18)),
            // Removed the separate "Add Location" ElevatedButton.icon from here
          ],
        ),
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Sub-FABs (conditionally visible and animated)
          if (_isFabOpen) ...[
            Positioned(
              bottom: 80.0, // Adjust position based on button size and spacing
              right: 4.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end, // Align labels to the right
                children: [
                  _buildSubFab(
                    icon: Icons.class_,
                    label: "Add Subject",
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddSubjectScreen())),
                    delay: 0.0, // Animation delay (can be adjusted)
                  ),
                  _buildSubFab(
                    icon: Icons.business,
                    label: "Add Location",
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddLocationScreen())),
                    delay: 0.1,
                  ),
                  _buildSubFab(
                    icon: Icons.add, // Or Icons.calendar_today, Icons.event
                    label: "Add Class",
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddClassScreen())),
                    delay: 0.2,
                  ),
                ],
              ),
            ),
          ],
          // Main FAB
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: _toggleFab,
              tooltip: _isFabOpen ? "Close Menu" : "Add New",
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  // Rotate the icon based on animation progress
                  return Transform.rotate(
                    angle: _animation.value * (2 * 3.1415926535), // Rotate 360 degrees
                    child: Icon(_isFabOpen ? Icons.close : Icons.add),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}