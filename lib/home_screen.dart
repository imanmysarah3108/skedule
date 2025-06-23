import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'add_class_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  void logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = Supabase.instance.client.auth.currentUser?.email ?? "No email";
    return Scaffold(
      appBar: AppBar(
        title: Text("Skedule - Home"),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: () => logout(context)),
        ],
      ),
      body: Center(
        child: Text("Welcome, $userEmail!", style: TextStyle(fontSize: 18)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddClassScreen())),
        child: Icon(Icons.add),
        tooltip: "Add Class",
      ),
    );
  }
}
