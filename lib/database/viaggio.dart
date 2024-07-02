import 'package:intl/intl.dart';

class viaggio {
    final int id_viaggio;
    final String titolo;
    final DateTime data_inizio;
    final DateTime data_fine;
    final String note;
    final String itinerario;
    final String destinazione;

    const viaggio(
    { required this.id_viaggio,
      required this.titolo,
      required this.data_inizio,
      required this.data_fine,
      required this.note,
      required this.itinerario,
      required this.destinazione,
     });



    Map<String, Object?> toMap() {
      return {
        'id_viaggio': id_viaggio,
        'titolo': titolo,
        'itinerario': itinerario,
        'data_inizio': DateFormat('yyyy-MM-dd').format(data_inizio), // Converte la data in String
        'data_fine': DateFormat('yyyy-MM-dd').format(data_fine), // Converte la data in String
        'destinazione': destinazione,
      };
    }


    @override
    String toString() {
      return 'viaggio{id_viaggio: $id_viaggio, titolo: $titolo, data_inizio: $data_inizio, data_fine: $data_fine, note: $note, itinerario: $itinerario, destinazione: $destinazione}';
    }
}