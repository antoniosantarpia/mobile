
class viaggio_categoria {
  final int id_categoria;
  final int id_viaggio;

  const viaggio_categoria(
      {required this.id_categoria,
        required this.id_viaggio});

  Map<String, Object?> toMap() {
    return {
      'id_categoria': id_categoria,
      'id_viaggio': id_viaggio
    };
  }


  @override
  String toString() {
    return 'viaggio_categoria{id_categoria: $id_categoria, id_viaggio: $id_viaggio}';
  }
}