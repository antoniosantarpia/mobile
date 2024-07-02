import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'database/destinazione.dart';

class DestinationsScreen extends StatefulWidget {
  const DestinationsScreen({super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  final TextEditingController _nomeController = TextEditingController();
  List<destinazione> destinations = [];

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    try {
      final db = DatabaseHelper.instance;
      final destinationMaps = await db.getDestinationWithTripCount();

      setState(() {
        destinations = destinationMaps.map((map) {
          return destinazione(
            nome: map['nome'] as String,
            tripCount: map['trip_count'] as int,
          );
        }).toList();
      });
    } catch (e) {
      print('Error loading destinations: $e');
    }
  }

  Future<void> _addDestination() async {
    try {
      final nome = _nomeController.text;
      //final lastId = await DatabaseHelper.instance.getLastDestinazioneId();
      //final count = lastId + 1;

      final newDestination = destinazione(nome: nome, tripCount: 0);

      await DatabaseHelper.instance.insertDestinazione(newDestination);
      print('Added destination: $nome');
      _nomeController.clear();
      await _loadDestinations();
    } catch (e) {
      print('Error adding destination: $e');
    }
  }

  Future<void> _deleteDestination(String nome) async {
    try {
      await DatabaseHelper.instance.deleteDestinazione(nome);
      print('Deleted destination with name: $nome');
      await _loadDestinations();
    } catch (e) {
      print('Error deleting destination: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Destinazioni',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                final destination = destinations[index];
                return ListTile(
                  title: Text(
                    destination.nome,
                    style: const TextStyle(fontSize: 22),
                  ),
                  subtitle: Text('Numero di viaggi: ${destination.tripCount}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Elimina destinazione'),
                            content: const Text('Sei sicuro di voler eliminare questa destinazione?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text('Annulla'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('Elimina'),
                              ),
                            ],
                          );
                        },
                      );
                      if (result == true) {
                        await _deleteDestination(destination.nome);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Aggiungi destinazione'),
                content: TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(hintText: 'Nome destinazione'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annulla'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(_nomeController.text);
                    },
                    child: const Text('Aggiungi'),
                  ),
                ],
              );
            },
          );
          if (result != null && result.isNotEmpty) {
            await _addDestination();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
