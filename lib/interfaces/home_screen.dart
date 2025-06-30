import 'package:flutter/material.dart';
import 'package:skedule/interfaces/notification.inbox.dart';
import 'login_screen.dart';
import 'add_class_screen.dart';    // The new AddClassScreen with dropdowns, time picker, etc. // The screen for adding Building Name and Room Number  // The screen for adding Subject Name and Teacher Name
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
  // Replace the logout button in the appBar with a notification icon
appBar: AppBar(
  title: const Text(
    "Skedule",
    style: TextStyle(
      color: Colors.white,
      fontSize: 24,
    ),
  ),
  backgroundColor: Color.fromARGB(255, 118, 51, 157),
  actions: [
    IconButton(
      icon: const Icon(Icons.notifications),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NotificationInboxScreen()),
        );
      },
      tooltip: "Notifications",
    ),
  ],
  iconTheme: const IconThemeData(color: Colors.white),
),
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Welcome, $userName!", style: const TextStyle(fontSize: 18)),
      ],
    ),
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddClassScreen()),
      );
    },
    icon: Icon(Icons.add),
    label: Text("Add Class"),
  ),
);
}
}