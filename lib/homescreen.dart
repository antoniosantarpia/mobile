import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prova/aggiungiviaggio.dart';
import 'database/database_helper.dart';
import 'database/viaggio.dart';
import 'database/destinazione.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  List<viaggio> _viaggi = [];
  List<destinazione> _destinazioni = [];
  viaggio? _prossimoViaggio;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    final viaggiList = await db.getViaggi();
    final destinazioniList = await db.getUltimiViaggiDestinazioni(2);

    // Trova il viaggio più vicino alla data attuale come "Prossimo Viaggio"
    viaggio? prossimoViaggio;
    DateTime now = DateTime.now();
    viaggiList.forEach((viaggio) {
      if (prossimoViaggio == null ||
          viaggio.data_inizio.difference(now).abs().compareTo(prossimoViaggio!.data_inizio.difference(now).abs()) < 0) {
        prossimoViaggio = viaggio;
      }
    });

    setState(() {
      _viaggi = viaggiList;
      _destinazioni = destinazioniList;
      _prossimoViaggio = prossimoViaggio;
    });
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
          _prossimoViaggio != null
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
                    child: Image.asset(
                      'assets/images/viaggio1.png', // Sostituire con il percorso corretto dell'immagine
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
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
              : const SizedBox(height: 0), // Se non ci sono viaggi, non mostra nulla
          const SizedBox(height: 16),
          const Text(
            'Ultime Destinazioni',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
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
                    trailing: const Icon(Icons.arrow_forward_ios),
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
                onPressed: () {},
                child: const Text('Crea Categoria'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
