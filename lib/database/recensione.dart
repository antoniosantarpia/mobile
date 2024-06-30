
class recensione {
  final int id_recensione;
  final String testo;
  final int viaggio;

  const recensione(
      {
        required this.id_recensione,
        required this.testo,
        required this.viaggio});

  Map<String, Object?> toMap() {
    return {
      'id_recensione': id_recensione,
      'testo': testo,
      'viaggio': viaggio
    };
  }


  @override
  String toString() {
    return 'recensione{id_recensione: $id_recensione, testo: $testo, viaggio: $viaggio}';
  }
}