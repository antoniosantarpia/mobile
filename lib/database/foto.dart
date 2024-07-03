class foto {
  final int id_foto;
  final int viaggio;
  final String path;

  foto({
    required this.id_foto,
    required this.viaggio,
    required this.path,
  });

  factory foto.fromMap(Map<String, dynamic> map) {
    return foto(
      id_foto: map['id_foto'],
      viaggio: map['viaggio'],
      path: map['path'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_foto': id_foto,
      'viaggio': viaggio,
      'path': path,
    };
  }
}
