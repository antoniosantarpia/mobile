import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prova/aggiungiviaggio.dart';
import 'database/database_helper.dart';
import 'database/viaggio.dart';
import 'database/categoria.dart';
import 'database/destinazione.dart';
import 'database/foto.dart';
import 'dettagliviaggio.dart';
import 'dart:io';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  List<destinazione> _destinazioni = [];
  viaggio? _prossimoViaggio;
  foto? _prossimaFoto;

  final TextEditingController _categoriaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    final viaggiList = await db.getViaggi();
    final destinazioniList = await db.getUltimiViaggiDestinazioni(2);

    viaggio? prossimoViaggio;
    List<foto>? prossimaFotoList;

    // Trova il viaggio più vicino alla data attuale come "Prossimo Viaggio".
    DateTime now = DateTime.now();
    for (var viaggio in viaggiList) {
      if (prossimoViaggio == null ||
          viaggio.data_inizio.difference(now).abs().compareTo(prossimoViaggio.data_inizio.difference(now).abs()) < 0) {
        prossimoViaggio = viaggio;
      }
    }

    if (prossimoViaggio != null) {
      prossimaFotoList = await db.getFotoByViaggioId(prossimoViaggio.id_viaggio);
      _prossimoViaggio = prossimoViaggio;
      _prossimaFoto = prossimaFotoList.isNotEmpty ? prossimaFotoList[0] : null;
    } else {
      _prossimoViaggio = null;
      _prossimaFoto = null;
    }

    setState(() {
      _destinazioni = destinazioniList;
      _prossimoViaggio = prossimoViaggio;
      _prossimaFoto = _prossimaFoto;
    });
  }


  Future<void> _addCategoria() async {
    try {
      final nome = _categoriaController.text;

      final newCategoria = categoria(nome: nome);

      await DatabaseHelper.instance.insertCategoria(newCategoria);
      print('Added category: $nome');
      _categoriaController.clear();

    } catch (e) {
      print('Error adding category: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prossimo Viaggio',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DettaglioViaggio(v: _prossimoViaggio!, onSave: _loadData)),
              );
            },
            child: _prossimoViaggio != null ? Container(
              width: 340, // Larghezza della card
              margin: const EdgeInsets.symmetric(horizontal: 8),
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
                      child: _prossimaFoto != null
                          ? Image.file(
                        File(_prossimaFoto!.path),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                          : const SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: Center(
                          child: Text('No Image Available'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _prossimoViaggio!.titolo,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Text(
                        'Dal ${DateFormat('dd/MM/yyyy').format(_prossimoViaggio!.data_inizio)} al ${DateFormat('dd/MM/yyyy').format(_prossimoViaggio!.data_fine)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : const Center(child: Text('Nessun viaggio trovato')),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ultime Destinazioni:',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (_destinazioni.isEmpty)
            const Center(child: Text('Nessuna destinazione trovata')) // Mostra il messaggio solo se non ci sono destinazioni
          else
            const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _destinazioni.length > 2 ? 2 : _destinazioni.length, // Mostra al massimo due destinazioni
              itemBuilder: (context, index) {
                final destinazione = _destinazioni[index];
                return Card(
                  color: const Color(0xffa9b9de),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(
                      destinazione.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AggiungiViaggio()),
                  ).then((value) {
                    if (value == true) {
                      _loadData();
                    }
                  });
                },
                child: const Text('Aggiungi Viaggio'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Aggiungi categoria'),
                        content: TextField(
                          controller: _categoriaController,
                          decoration: const InputDecoration(hintText: 'Nome categoria'),
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
                              Navigator.of(context).pop(_categoriaController.text);
                            },
                            child: const Text('Aggiungi'),
                          ),
                        ],
                      );
                    },
                  );
                  if (result != null && result.isNotEmpty) {
                    await _addCategoria();
                  }
                },
                child: const Text('Crea Categoria'),
              ),
            ],
          ),
        ],
      ),
    );
  }

}