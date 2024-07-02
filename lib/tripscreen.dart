import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'database/viaggio.dart';
import 'aggiungiviaggio.dart';
import 'package:intl/intl.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  _TripsScreenState createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  List<viaggio> _viaggi = [];

  @override
  void initState() {
    super.initState();
    _loadViaggi();
  }

  Future<void> _loadViaggi() async {
    try {
      final db = DatabaseHelper.instance;
      final viaggiList = await db.getViaggi();

      // Log dei dati caricati per il debug
      for (var viaggio in viaggiList) {
        print('Loaded trip: ${viaggio.titolo}, ${viaggio.data_inizio}, ${viaggio.data_fine}, ${viaggio.destinazione}');
      }

      setState(() {
        _viaggi = viaggiList;
      });
    } catch (e) {
      print('Error loading viaggi: $e');
    }
  }

  Future<void> _refreshViaggi() async {
    await _loadViaggi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viaggi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _viaggi.isEmpty
            ? const Center(child: Text('Nessun viaggio trovato'))
            : ListView.builder(
          itemCount: _viaggi.length,
          itemBuilder: (context, index) {
            final viaggio = _viaggi[index];
            return Card(
              child: ListTile(
                title: Text(viaggio.titolo),
                subtitle: Text(
                    'Dal ${DateFormat('dd/MM/yyyy').format(viaggio.data_inizio)} al ${DateFormat('dd/MM/yyyy').format(viaggio.data_fine)}\n${viaggio.destinazione}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await DatabaseHelper.instance.deleteViaggio(viaggio.id_viaggio);
                    _refreshViaggi();
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AggiungiViaggio()),
          );
          if(result == true) {
            _refreshViaggi(); // Ricarica la lista dei viaggi dopo l'aggiunta di un nuovo viaggio
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
