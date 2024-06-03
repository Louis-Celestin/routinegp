import 'package:flutter/material.dart';
import 'package:flutter_application_routinggp/models/routine.models.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class RoutineFormPage extends StatefulWidget {
  @override
  _RoutineFormPageState createState() => _RoutineFormPageState();
}

class _RoutineFormPageState extends State<RoutineFormPage> {
  final _formKey = GlobalKey<FormState>();
  int commercialId = 0;
  String pointMarchand = '';
  String veilleConcurrentielle = '';
  double latitudeReel = 0.0;
  double longitudeReel = 0.0;
  List<Tpe> tpeList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      if (await Permission.location.request().isGranted) {
        _getCurrentLocation();
      }
    } else if (status.isGranted) {
      _getCurrentLocation();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  void _getCurrentLocation() async {
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
          Uri.parse('http://172.31.1.55:5500/api/makeRoutine'),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec de l\'enregistrement de la routine')),
          );
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

  void _removeTpe(int index) {
    setState(() {
      tpeList.removeAt(index);
    });
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
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer l\'ID du commercial';
                  }
                  return null;
                },
                onSaved: (value) {
                  commercialId = int.parse(value!);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Point Marchand'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer le point marchand';
                  }
                  return null;
                },
                onSaved: (value) {
                  pointMarchand = value!;
                },
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Veille Concurrentielle'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer la veille concurrentielle';
                  }
                  return null;
                },
                onSaved: (value) {
                  veilleConcurrentielle = value!;
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TPE ${index + 1}'),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeTpe(index),
                        ),
                      ],
                    ),
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
