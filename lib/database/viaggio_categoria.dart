
class viaggio_categoria {
  final String categoria;
  final int viaggio;

  const viaggio_categoria(
      {required this.categoria,
        required this.viaggio});

  Map<String, Object?> toMap() {
    return {
      'categoria': categoria,
      'viaggio': viaggio
    };
  }


  @override
  String toString() {
    return 'viaggio_categoria{categoria: $categoria, viaggio: $viaggio}';
  }
}