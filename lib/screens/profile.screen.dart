import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Text(
          'Page de profil',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
