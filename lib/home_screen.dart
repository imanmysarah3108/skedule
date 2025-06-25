import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'add_class_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchUserName();
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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Skedule - Home"),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: () => logout(context)),
        ],
      ),
      body: Center(
        child: Text("Welcome, $userName!", style: TextStyle(fontSize: 18)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddClassScreen())),
        child: Icon(Icons.add),
        tooltip: "Add Class",
      ),
    );
  }
}
