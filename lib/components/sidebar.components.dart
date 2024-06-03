import 'package:flutter/material.dart';
import 'package:flutter_application_routinggp/screens/deploiement.screen.dart';
import 'package:flutter_application_routinggp/screens/routine.screen.dart';
import 'package:flutter_application_routinggp/screens/routineform.screen.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.indigo,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.white),
              title: Text('Routine', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RoutinePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.cloud_upload, color: Colors.white),
              title: Text('Déploiement', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Deployment()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.white),
              title: Text('Profil', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Logique pour naviguer vers Profil
              },
            ),
          ],
        ),
      ),
    );
  }
}
