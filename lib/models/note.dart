class Note {
  int? id;
  String text;
  String priorite;
  DateTime? dateDebut;
  DateTime? dateFin;
  int progression;

  Note({
    required this.id,
    required this.text,
    required this.priorite,
    this.dateDebut,
    this.dateFin,
    required this.progression,
  });

  Note.sansId({
    required this.text,
    required this.priorite,
    this.dateDebut,
    this.dateFin,
    required this.progression,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'text': text,
      'priorite': priorite,
      'progression': progression,
    };

    if (dateDebut != null) {
      map['dateDebut'] = dateDebut!.toIso8601String();
    }

    if (dateFin != null) {
      map['dateFin'] = dateFin!.toIso8601String();
    }

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      text: map['text'],
      priorite: map['priorite'],
      dateDebut:
          map['dateDebut'] != null ? DateTime.tryParse(map['dateDebut']) : null,
      dateFin:
          map['dateFin'] != null ? DateTime.tryParse(map['dateFin']) : null,
      progression: map['progression'],
    );
  }

  Note copyWith({
    int? id,
    String? text,
    String? priorite,
    DateTime? dateDebut,
    DateTime? dateFin,
    int? progression,
  }) {
    return Note(
      id: id ?? this.id,
      text: text ?? this.text,
      priorite: priorite ?? this.priorite,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      progression: progression ?? this.progression,
    );
  }
}
