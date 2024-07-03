import 'package:flutter/material.dart';
import 'database/viaggio.dart'; // Assicurati di importare il modello viaggio

class DettaglioViaggio extends StatelessWidget {
  final viaggio v;

  const DettaglioViaggio({super.key, required this.v});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(v.titolo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text('Titolo'),
              subtitle: Text(v.titolo),
            ),
            ListTile(
              title: const Text('Data Inizio'),
              subtitle: Text('${v.data_inizio.day}/${v.data_inizio.month}/${v.data_inizio.year}'),
            ),
            ListTile(
              title: const Text('Data Fine'),
              subtitle: Text('${v.data_fine.day}/${v.data_fine.month}/${v.data_fine.year}'),
            ),
            ListTile(
              title: const Text('Destinazione'),
              subtitle: Text(v.destinazione),
            ),
            ListTile(
              title: const Text('Itinerario'),
              subtitle: Text(v.itinerario),
            ),
            ListTile(
              title: const Text('Note'),
              subtitle: Text(v.note),
            ),
            // Aggiungi altre informazioni del viaggio se necessario
          ],
        ),
      ),
    );
  }
}
