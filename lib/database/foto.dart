
class foto {
  final int id_foto;
  final int viaggio;

  const foto(
      {required this.id_foto,
       required this.viaggio});

  Map<String, Object?> toMap() {
    return {
      'id_foto': id_foto,
      'viaggio': viaggio
    };
  }


  @override
  String toString() {
    return 'foto{id_foot: $id_foto, viaggio: $viaggio}';
  }
}