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
  List<viaggio> _effettuatiViaggi = [];
  List<viaggio> _pianificatiViaggi = [];

  @override
  void initState() {
    super.initState();
    _loadViaggi();
  }

  Future<void> _loadViaggi() async {
    try {
      final db = DatabaseHelper.instance;
      final viaggiList = await db.getViaggi();
      final now = DateTime.now();

      final effettuati = viaggiList.where((viaggio) => viaggio.data_fine.isBefore(now)).toList();
      final pianificati = viaggiList.where((viaggio) => !viaggio.data_fine.isBefore(now)).toList();

      setState(() {
        _effettuatiViaggi = effettuati;
        _pianificatiViaggi = pianificati;
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
        title: const Text('Viaggi',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _effettuatiViaggi.isEmpty && _pianificatiViaggi.isEmpty
            ? const Center(child: Text('Nessun viaggio trovato'))
            : ListView(
          children: _buildViaggiList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AggiungiViaggio()),
          );
          if (result == true) {
            _refreshViaggi(); // Ricarica la lista dei viaggi dopo l'aggiunta di un nuovo viaggio
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Widget> _buildViaggiList() {
    final List<Widget> viaggiWidgets = [];

    if (_pianificatiViaggi.isNotEmpty) {
      viaggiWidgets.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Viaggi Pianificati',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
      for (var viaggio in _pianificatiViaggi) {
        viaggiWidgets.add(_buildViaggioCard(viaggio));
      }
    }

    if (_effettuatiViaggi.isNotEmpty) {
      viaggiWidgets.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Viaggi Effettuati',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
      for (var viaggio in _effettuatiViaggi) {
        viaggiWidgets.add(_buildViaggioCard(viaggio));
      }
    }

    return viaggiWidgets;
  }

  Widget _buildViaggioCard(viaggio v) {
    return Card(
      child: ListTile(
        title: Text(v.titolo),
        subtitle: Text(
            'Dal ${DateFormat('dd/MM/yyyy').format(v.data_inizio)} al ${DateFormat('dd/MM/yyyy').format(v.data_fine)}\n${v.destinazione}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            await DatabaseHelper.instance.deleteViaggio(v.id_viaggio);
            _refreshViaggi();
          },
        ),
      ),
    );
  }
}
