
class categoria {
  final String nome;

  const categoria(
      {required this.nome});

  Map<String, Object?> toMap() {
    return {
      'nome': nome
    };
  }


  @override
  String toString() {
    return 'categoria{nome: $nome}';
  }
}