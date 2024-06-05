import 'package:flutter/material.dart';
import 'package:flutter_application_routinggp/consts/env.const.dart';
import 'package:flutter_application_routinggp/models/routine.models.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoutineFormPage extends StatefulWidget {
  @override
  _RoutineFormPageState createState() => _RoutineFormPageState();
}

class _RoutineFormPageState extends State<RoutineFormPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _controller;
  int commercialId = 0;
  String pointMarchand = '';
  String veilleConcurrentielle = '';
  double latitudeReel = 0.0;
  double longitudeReel = 0.0;
  List<Tpe> tpeList = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> _pointsMarchand = [];
  String? _selectedPointMarchand;

  final List<Map<String, dynamic>> _items = [
    {
      'value': 'N/A',
      'label': 'N/A',
    },
    {
      'value': 'MOOV',
      'label': 'Moov',
    },
    {
      'value': 'MTN',
      'label': 'MTN',
    },
    {
      'value': 'ORANGE',
      'label': 'Orange',
    },
    {
      'value': 'WAVE',
      'label': 'Wave',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCommercialId();
    _checkLocationPermission();
    _loadPointsMarchand();
    _controller = TextEditingController(text: '2');
  }

  Future<void> _loadPointsMarchand() async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + '/getpm'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          // Body parameters if any
          'latitudeTelephone': 5.2973114754742,
          'longitudeTelephone': -3.972523960301,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(data);
        setState(() {
          _pointsMarchand = data.map((point) {
            return {
              'value': point['POINT_MARCHAND'],
              'label': point['POINT_MARCHAND'],
            };
          }).toList();
        });
      } else {
        print('Failed to load points marchand: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading points marchand: $e');
    }
  }

  Future<void> _loadCommercialId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      commercialId = prefs.getInt('agentId') ?? 0;
    });
  }

  Future<void> _checkLocationPermission() async {
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      // Handle the case where the user denied the permission
      print('Location permission denied');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        latitudeReel = position.latitude;
        longitudeReel = position.longitude;
      });
    } catch (e) {
      print("Erreur lors de la récupération de la position: $e");
    }
  }

  void _addTpe() {
    setState(() {
      tpeList.add(Tpe(
        problemeBancaire: '',
        descriptionProblemeBancaire: '',
        problemeMobile: '',
        descriptionProblemeMobile: '',
        idTerminal: '',
        etatTpeRoutine: '',
        etatChargeurTpeRoutine: '',
      ));
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      final routineData = {
        'commercialId': commercialId,
        'pointMarchand': pointMarchand,
        'veilleConcurrentielle': veilleConcurrentielle,
        'latitudeReel': latitudeReel,
        'longitudeReel': longitudeReel,
        'tpeList': tpeList.map((tpe) => tpe.toJson()).toList(),
      };

      try {
        final response = await http.post(
          Uri.parse(baseUrl + '/makeRoutine'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(routineData),
        );
        setState(() {
          _isLoading = false;
        });
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Routine enregistrée avec succès')),
          );
          Navigator.pop(context, true);
        } else {
          print(response.body);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(response.body.characters.string),
          ));
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enregistrer une Routine'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Commercial ID'),
                initialValue: commercialId.toString(),
                keyboardType: TextInputType.number,
                enabled: false,
              ),
              DropdownButtonFormField<String>(
                value: _selectedPointMarchand,
                items: _pointsMarchand.map((point) {
                  return DropdownMenuItem<String>(
                    value: point['value'],
                    child: Text(point['label']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPointMarchand = value;
                    pointMarchand = value!;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Sélectionnez un point marchand',
                ),
              ),
              SelectFormField(
                type: SelectFormFieldType.dropdown,
                initialValue: 'N/A',
                labelText: 'Veille Concurrentielle',
                items: _items,
                onChanged: (value) {
                  print(value);
                  setState(() {
                    veilleConcurrentielle = value;
                  });
                },
                onSaved: (value) {
                  veilleConcurrentielle = value.toString();
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Latitude Réelle'),
                keyboardType: TextInputType.number,
                enabled: false,
                initialValue:
                    latitudeReel != null ? latitudeReel.toString() : '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Longitude Réelle'),
                keyboardType: TextInputType.number,
                enabled: false,
                initialValue:
                    longitudeReel != null ? longitudeReel.toString() : '',
              ),
              ...tpeList.asMap().entries.map((entry) {
                int index = entry.key;
                Tpe tpe = entry.value;

                return Column(
                  key: ValueKey(index),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Text('TPE ${index + 1}'),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'État Chargeur'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Veuillez entrer l\'état du chargeur';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        tpeList[index].etatChargeurTpeRoutine = value!;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'État TPE'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Veuillez entrer l\'état du TPE';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        tpeList[index].etatTpeRoutine = value!;
                      },
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: 'Problème Bancaire'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Veuillez entrer le problème bancaire';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        tpeList[index].problemeBancaire = value!;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Description du Problème Bancaire'),
                      onSaved: (value) {
                        tpeList[index].descriptionProblemeBancaire = value!;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Problème Mobile'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Veuillez entrer le problème mobile';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        tpeList[index].problemeMobile = value!;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Description du Problème Mobile'),
                      onSaved: (value) {
                        tpeList[index].descriptionProblemeMobile = value!;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'ID Terminal'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Veuillez entrer l\'ID du terminal';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        tpeList[index].idTerminal = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
              ElevatedButton(
                onPressed: _addTpe,
                child: Text('Ajouter un TPE'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text('Soumettre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
