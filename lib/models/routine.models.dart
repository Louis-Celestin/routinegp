class Routine {
  int id;
  int? commercialRoutineId;
  String pointMarchandRoutine;
  String latitudeMarchandRoutine;
  String longitudeMarchandRoutine;
  String veilleConcurentielleRoutine;
  DateTime? dateRoutine;
  List<Tpe> tpeRoutine;

  Routine({
    this.id = 0,
    this.commercialRoutineId,
    required this.pointMarchandRoutine,
    required this.latitudeMarchandRoutine,
    required this.longitudeMarchandRoutine,
    required this.veilleConcurentielleRoutine,
    this.dateRoutine,
    required this.tpeRoutine,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'] ?? 0,
      commercialRoutineId: json['commercial_routine_id'],
      pointMarchandRoutine: json['point_marchand_routine'] ?? '',
      latitudeMarchandRoutine: json['latitude_marchand_routine'] ?? '',
      longitudeMarchandRoutine: json['longitude_marchand_routine'] ?? '',
      veilleConcurentielleRoutine: json['veille_concurentielle_routine'] ?? '',
      dateRoutine: json['date_routine'] != null
          ? DateTime.parse(json['date_routine'])
          : null,
      tpeRoutine: (json['tpe_routine'] as List)
          .map((data) => Tpe.fromJson(data))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commercial_routine_id': commercialRoutineId,
      'point_marchand_routine': pointMarchandRoutine,
      'latitude_marchand_routine': latitudeMarchandRoutine,
      'longitude_marchand_routine': longitudeMarchandRoutine,
      'veille_concurentielle_routine': veilleConcurentielleRoutine,
      'date_routine': dateRoutine?.toIso8601String(),
      'tpe_routine': tpeRoutine.map((tpe) => tpe.toJson()).toList(),
    };
  }
}

class Tpe {
  int id;
  int? routineId;
  String idTerminal;
  String etatTpeRoutine;
  String etatChargeurTpeRoutine;
  String problemeBancaire;
  String? descriptionProblemeBancaire;
  String problemeMobile;
  String? descriptionProblemeMobile;

  Tpe({
    this.id = 0,
    this.routineId,
    required this.idTerminal,
    required this.etatTpeRoutine,
    required this.etatChargeurTpeRoutine,
    required this.problemeBancaire,
    this.descriptionProblemeBancaire,
    required this.problemeMobile,
    this.descriptionProblemeMobile,
  });

  factory Tpe.fromJson(Map<String, dynamic> json) {
    return Tpe(
      id: json['id'] ?? 0,
      routineId: json['routine_id'],
      idTerminal: json['idTerminal'] ?? '',
      etatTpeRoutine: json['etatTpe'] ?? '',
      etatChargeurTpeRoutine: json['etatChargeur'] ?? '',
      problemeBancaire: json['problemeBancaire'] ?? '',
      descriptionProblemeBancaire: json['descriptionProblemeBancaire'],
      problemeMobile: json['problemeMobile'] ?? '',
      descriptionProblemeMobile: json['descriptionProblemeMobile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routine_id': routineId,
      'idTerminal': idTerminal,
      'etatTpe': etatTpeRoutine,
      'etatChargeur': etatChargeurTpeRoutine,
      'problemeBancaire': problemeBancaire,
      'descriptionProblemeBancaire': descriptionProblemeBancaire,
      'problemeMobile': problemeMobile,
      'descriptionProblemeMobile': descriptionProblemeMobile,
    };
  }
}
