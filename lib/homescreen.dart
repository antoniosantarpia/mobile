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
      if (viaggio.data_inizio.isAfter(now) || viaggio.data_inizio.isAtSameMomentAs(now)) {
        if (prossimoViaggio == null || viaggio.data_inizio.isBefore(prossimoViaggio.data_inizio)) {
          prossimoViaggio = viaggio;
        }
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

      if (await DatabaseHelper.instance.insertCategoria(newCategoria) == 1){
        _showErrorDialog('La categoria esiste già.');
      }
      print('Added category: $nome');
      _categoriaController.clear();

    } catch (e) {
      print('Error adding category: $e');
    }
  }


  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Errore'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Prossimo Viaggio',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DettaglioViaggio(v: _prossimoViaggio!, onSave: _loadData)),
                  );
                },
                child: _prossimoViaggio != null
                    ? Container(
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
                              child: Text('Immagine non disponibile'),
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
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              if (_destinazioni.isEmpty)
                const Center(child: Text('Nessuna destinazione trovata')) // Mostra il messaggio solo se non ci sono destinazioni
              else
                const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                          return SingleChildScrollView(
                            child: AlertDialog(
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
                            ),
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
        ),
      ),
    );
  }
}

