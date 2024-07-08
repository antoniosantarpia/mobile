class viaggio {
  final int id_viaggio;
  final String titolo;
  final String? note;
  final String? itinerario;
  final DateTime data_inizio;
  final DateTime data_fine;
  final String destinazione;

  viaggio({
    required this.id_viaggio,
    required this.titolo,
    required this.note,
    required this.itinerario,
    required this.data_inizio,
    required this.data_fine,
    required this.destinazione,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_viaggio': id_viaggio,
      'titolo': titolo,
      'note': note,
      'itinerario': itinerario,
      'data_inizio': data_inizio.toIso8601String(),
      'data_fine': data_fine.toIso8601String(),
      'destinazione': destinazione,
    };
  }

  static viaggio fromMap(Map<String, dynamic> map) {
    return viaggio(
      id_viaggio: map['id_viaggio'] as int,
      titolo: map['titolo'] as String,
      note: map['note'] ?? '', // Gestione del valore null per 'note'
      itinerario: map['itinerario'] ?? '', // Gestione del valore null per 'itinerario'
      data_inizio: DateTime.parse(map['data_inizio'] as String),
      data_fine: DateTime.parse(map['data_fine'] as String),
      destinazione: map['destinazione'] ?? '', // Gestione del valore null per 'destinazione'
    );
  }
}
