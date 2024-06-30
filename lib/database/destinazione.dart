
class destinazione {
  final int id_destinazione;
  final String nome;
  final int tripCount;

  const destinazione(
      {required this.id_destinazione,
        required this.nome,
        required this.tripCount});

  Map<String, Object?> toMap() {
    return {
      'id_destinazione': id_destinazione,
      'nome': nome,
      'tripCount': tripCount
    };
  }


  @override
  String toString() {
    return 'destinazione{id_destinazione: $id_destinazione, nome: $nome, tripCount: $tripCount}';
  }
}