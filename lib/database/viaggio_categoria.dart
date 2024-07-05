
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

  static viaggio_categoria fromMap(Map<String, dynamic> map) {
    return viaggio_categoria(
      categoria: map['categoria'] as String,
      viaggio: map['viaggio'] as int,
    );
  }

  @override
  String toString() {
    return 'viaggio_categoria{categoria: $categoria, viaggio: $viaggio}';
  }
}