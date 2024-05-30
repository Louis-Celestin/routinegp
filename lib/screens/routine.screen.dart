import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_routinggp/models/routine.models.dart';
import 'package:flutter_application_routinggp/screens/routineform.screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RoutinePage extends StatefulWidget {
  @override
  _RoutinePageState createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  List<Routine> routines = [];
  bool isLoading = true;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadRoutineData();
  }

  void loadRoutineData() async {
    final response =
        await http.get(Uri.parse('http://172.31.1.51:5500/api/routines'));

    if (response.statusCode == 200) {
      try {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          routines = jsonData.map((data) => Routine.fromJson(data)).toList();
          isLoading = false;
        });
      } catch (e) {
        print('Failed to parse routines: $e');
      }
    } else {
      print('Failed to load routines');
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Routine'),
        backgroundColor: Colors.indigo,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              height: height,
              width: width,
              color: Colors.indigo,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    height: height * 0.25,
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 35, left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Routine",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add,
                                    color: Colors.white, size: 30),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RoutineFormPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Marchand')),
                            DataColumn(label: Text('Concurence')),
                            DataColumn(label: Text('Date')),
                          ],
                          rows: routines
                              .map(
                                (routine) => DataRow(
                                  cells: [
                                    DataCell(
                                        Text(routine.pointMarchandRoutine)),
                                    DataCell(Text(
                                        routine.veilleConcurentielleRoutine)),
                                    DataCell(Text(DateFormat('dd/MM/yyyy HH:mm')
                                        .format(
                                            routine.dateRoutine!.toLocal()))),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
