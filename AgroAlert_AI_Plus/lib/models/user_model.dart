/// Représente un utilisateur de l'application AgroAlert AI+.
///
/// Ce modèle est un simple conteneur de données (aucune logique métier,
/// aucun appel réseau) conformément à l'architecture MVC du projet.
class UserModel {
  final String uid;
  final String name;
  final String email;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
  });

  /// Convertit l'instance en Map pour l'écriture dans Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
    };
  }

  /// Construit une instance à partir d'un document Firestore.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
    );
  }

  /// Retourne une copie de l'utilisateur avec certains champs modifiés.
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}
