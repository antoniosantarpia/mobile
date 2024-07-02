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



/*child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Viaggi Pianificati',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 250, // Altezza delle card
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // Scrolling orizzontale
                itemCount: _viaggi.length,
                itemBuilder: (context, index) {
                  final viaggioItem = _viaggi[index];
                  return GestureDetector(
                    onTap: () {
                      // Implementa la logica per modificare il viaggio
                    },
                    child: Container(
                      width: 200, // Larghezza delle card
                      margin: const EdgeInsets.only(right: 10),
                      child: Card(
                        color: const Color(0xffdcdcf7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: Image.asset(
                                'assets/images/viaggio${index + 1}.png',
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                viaggioItem.titolo,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: Text(
                                viaggioItem.itinerario,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Viaggi Effettuati',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical, // Scrolling verticale
                itemCount: _viaggi.length,
                itemBuilder: (context, index) {
                  final viaggioItem = _viaggi[index];
                  return GestureDetector(
                    onTap: () {
                      // Implementa la logica per modificare il viaggio
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        color: const Color(0xffdcdcf7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: Image.asset(
                                'assets/images/viaggio${index + 1}.png',
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                viaggioItem.titolo,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: Text(
                                viaggioItem.itinerario,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),*/