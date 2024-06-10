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
  List<String> _serialNumbers = [];
  List<Widget> _tpeForms = [];
  bool? _visibleProblemeMobile = false;
  bool _visibleProblemeBancaire = false;

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

  final List<Map<String, dynamic>> _etatItems = [
    {'value': 'OK', 'label': 'OK'},
    {'value': 'NON OK', 'label': 'NON OK'},
  ];

  final List<Map<String, dynamic>> _problemeItems = [
    {'value': 'OUI', 'label': 'OUI'},
    {'value': 'NON', 'label': 'NON'},
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadCommercialId();
    _checkLocationPermission();
    _loadPointsMarchand();
    _controller = TextEditingController(text: '2');
  }

  Future<void> _loadPointsMarchand() async {
    try {
      final response = await http.post(
        Uri.parse(baseLocalUrl + '/getpm'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'latitudeTelephone': 5.2973114754742,
          'longitudeTelephone': -3.972523960301,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
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
      Tpe tpe = Tpe(
        problemeBancaire: '',
        descriptionProblemeBancaire: '',
        problemeMobile: '',
        descriptionProblemeMobile: '',
        idTerminal: '',
        etatTpeRoutine: '',
        etatChargeurTpeRoutine: '',
      );
      tpeList.add(tpe);
      _tpeForms.add(_buildTpeForm(tpe));
    });
  }

  void _removeTpe(int index) {
    setState(() {
      tpeList.removeAt(index);
      _tpeForms.removeAt(index);
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
          Uri.parse(baseLocalUrl + '/makeRoutine'),
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

  Future<void> _fetchSerialNumbers(String selectedPointMarchand) async {
    try {
      final response = await http.post(
        Uri.parse(baseLocalUrl + '/getSnBypointMarchand'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pointMarchand': selectedPointMarchand,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _serialNumbers = List<String>.from(data
              .map((serialNumber) => serialNumber['SERIAL_NUMBER'])
              .toList());
        });
        _generateTpeForms();
      } else {
        print('Failed to load serial numbers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading serial numbers: $e');
    }
  }

  void _generateTpeForms() {
    _tpeForms.clear();
    tpeList.clear();

    for (String serialNumber in _serialNumbers) {
      Tpe tpe = Tpe(
        problemeBancaire: '',
        descriptionProblemeBancaire: '',
        problemeMobile: '',
        descriptionProblemeMobile: '',
        idTerminal: serialNumber,
        etatTpeRoutine: '',
        etatChargeurTpeRoutine: '',
      );
      tpeList.add(tpe);
      _tpeForms.add(_buildTpeForm(tpe));
    }
    setState(() {});
  }

  Widget _buildTpeForm(Tpe tpe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text('TPE ${tpeList.indexOf(tpe) + 1}'),
        DropdownButtonFormField<String>(
          value: tpe.etatTpeRoutine.isEmpty ? null : tpe.etatTpeRoutine,
          items: _etatItems.map((item) {
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Text(item['label']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              tpe.etatTpeRoutine = value!;
            });
          },
          decoration: InputDecoration(labelText: 'État TPE'),
        ),
        DropdownButtonFormField<String>(
          value: tpe.problemeBancaire.isEmpty ? null : tpe.problemeBancaire,
          items: _problemeItems.map((item) {
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Text(item['label']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              tpe.problemeBancaire = value!;
              _visibleProblemeBancaire = value == 'OUI';
            });
          },
          decoration: InputDecoration(labelText: 'Problème Bancaire'),
        ),
        Visibility(
          visible: tpe.problemeBancaire == 'OUI',
          child: TextFormField(
            decoration:
                InputDecoration(labelText: 'Description Problème Bancaire'),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                tpe.descriptionProblemeBancaire = value;
              });
            },
            validator: (value) {
              if (tpe.problemeBancaire == 'OUI' &&
                  (value == null || value.isEmpty)) {
                return 'Description obligatoire si problème bancaire est OUI';
              }
              return null;
            },
          ),
        ),
        DropdownButtonFormField<String>(
          value: tpe.problemeMobile.isEmpty ? null : tpe.problemeMobile,
          items: _problemeItems.map((item) {
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Text(item['label']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              tpe.problemeMobile = value!;
              _visibleProblemeMobile = value == 'OUI';
            });
          },
          decoration: InputDecoration(labelText: 'Problème Mobile'),
        ),
        Visibility(
          visible: tpe.problemeMobile == 'OUI',
          child: TextFormField(
            decoration:
                InputDecoration(labelText: 'Description Problème Mobile'),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                tpe.descriptionProblemeMobile = value;
              });
            },
            validator: (value) {
              if (tpe.problemeMobile == 'OUI' &&
                  (value == null || value.isEmpty)) {
                return 'Description obligatoire si problème mobile est OUI';
              }
              return null;
            },
          ),
        ),
        DropdownButtonFormField<String>(
          value: tpe.idTerminal.isEmpty ? null : tpe.idTerminal,
          items: _serialNumbers.map((serialNumber) {
            return DropdownMenuItem<String>(
              value: serialNumber,
              child: Text(serialNumber),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              tpe.idTerminal = value!;
            });
          },
          decoration: InputDecoration(labelText: 'ID Terminal'),
        ),
      ],
    );
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
              Visibility(
                visible: false,
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Commercial ID'),
                  initialValue: commercialId.toString(),
                  keyboardType: TextInputType.number,
                  enabled: false,
                ),
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
// Récupérer les numéros de série en fonction du point marchand sélectionné
                    _fetchSerialNumbers(value);
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
              Visibility(
                visible: false,
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Latitude Réelle'),
                  keyboardType: TextInputType.number,
                  enabled: false,
                  initialValue:
                      latitudeReel != null ? latitudeReel.toString() : '',
                ),
              ),
              Visibility(
                visible: false,
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Longitude Réelle'),
                  keyboardType: TextInputType.number,
                  enabled: false,
                  initialValue:
                      longitudeReel != null ? longitudeReel.toString() : '',
                ),
              ),
// Display the generated TPE forms
              ..._tpeForms,
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTpe,
                child: Text('Ajouter un TPE'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Enregistrer la Routine'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Tpe {
  String problemeBancaire;
  String descriptionProblemeBancaire;
  String problemeMobile;
  String descriptionProblemeMobile;
  String idTerminal;
  String etatTpeRoutine;
  String etatChargeurTpeRoutine;

  Tpe({
    required this.problemeBancaire,
    required this.descriptionProblemeBancaire,
    required this.problemeMobile,
    required this.descriptionProblemeMobile,
    required this.idTerminal,
    required this.etatTpeRoutine,
    required this.etatChargeurTpeRoutine,
  });

  Map<String, dynamic> toJson() {
    return {
      'problemeBancaire': problemeBancaire,
      'descriptionProblemeBancaire': descriptionProblemeBancaire,
      'problemeMobile': problemeMobile,
      'descriptionProblemeMobile': descriptionProblemeMobile,
      'idTerminal': idTerminal,
      'etatTpeRoutine': etatTpeRoutine,
      'etatChargeurTpeRoutine': etatChargeurTpeRoutine,
    };
  }
}
