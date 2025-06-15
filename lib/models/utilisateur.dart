class Utilisateur {
  final int? id;
  final String nom;
  final String motDePasse;

  Utilisateur({this.id, required this.nom, required this.motDePasse});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'mot_de_passe': motDePasse,
    };
  }

  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id'],
      nom: map['nom'],
      motDePasse: map['mot_de_passe'],
    );
  }
}
