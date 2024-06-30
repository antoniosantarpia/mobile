
class categoria {
  final int id_categoria;
  final String nome;

  const categoria(
      {required this.id_categoria,
        required this.nome});

  Map<String, Object?> toMap() {
    return {
      'id_categoria': id_categoria,
      'nome': nome
    };
  }


  @override
  String toString() {
    return 'categoria{id_categoria: $id_categoria, nome: $nome}';
  }
}