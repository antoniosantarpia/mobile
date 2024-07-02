
class destinazione {
  final String nome;
  final int tripCount;

  const destinazione(
      {
        required this.nome,
        required this.tripCount});

  Map<String, Object?> toMap() {
    return {
      'nome': nome,
      'tripCount': tripCount
    };
  }


  @override
  String toString() {
    return 'destinazione{nome: $nome, tripCount: $tripCount}';
  }
}