import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'database/viaggio.dart';
import 'database/destinazione.dart';
import 'package:intl/intl.dart';

class AggiungiViaggio extends StatefulWidget {
  const AggiungiViaggio({super.key});

  @override
  _AggiungiViaggioState createState() => _AggiungiViaggioState();
}

class _AggiungiViaggioState extends State<AggiungiViaggio> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titoloController = TextEditingController();
  final TextEditingController _dataInizioController = TextEditingController();
  final TextEditingController _dataFineController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _itinerarioController = TextEditingController();

  String? _selectedDestinazione;
  List<destinazione> _destinazioni = [];

  @override
  void initState() {
    super.initState();
    _loadDestinazioni();
  }

  Future<void> _loadDestinazioni() async {
    final destinazioni = await DatabaseHelper.instance.getDestinations();
    setState(() {
      _destinazioni = destinazioni;
    });
  }


  Future<void> _addViaggio() async {
    try {
      final formatter = DateFormat('dd/MM/yyyy');

      final titolo = _titoloController.text;
      final dataInizio = _dataInizioController.text;
      final dataFine = _dataFineController.text;
      final note = _noteController.text;
      final itinerario = _itinerarioController.text;

      final lastId = await DatabaseHelper.instance.getLastViaggioId();
      final count = lastId + 1;

      final newViaggio = viaggio(id_viaggio: count, titolo: titolo, data_inizio: formatter.parse(dataInizio), data_fine: formatter.parse(dataFine), note: note, itinerario: itinerario, destinazione: _selectedDestinazione ?? '');

      await DatabaseHelper.instance.insertViaggio(newViaggio);
      print('Added Trip: $titolo');
      _titoloController.clear();
      _dataInizioController.clear();
      _dataFineController.clear();
      _noteController.clear();
      _itinerarioController.clear();
    } catch (e) {
      print('Error adding trip: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi Viaggio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titoloController,
                decoration: const InputDecoration(labelText: 'Nome Viaggio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore inserisci il nome del viaggio';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                hint: const Text('Seleziona una destinazione'),
                decoration: const InputDecoration(labelText: 'Destinazione Viaggio'),
                items: _destinazioni.map((destinazione) {
                  return DropdownMenuItem<String>(
                    value: destinazione.nome,
                    child: Text(destinazione.nome),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDestinazione = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore seleziona una destinazione';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dataInizioController,
                decoration: const InputDecoration(labelText: 'Data Inizio'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    final formatter = DateFormat('dd/MM/yyyy');
                    setState(() {
                      _dataInizioController.text = formatter.format(pickedDate);
                    });
                  }
                },
              ),
              TextFormField(
                controller: _dataFineController,
                decoration: const InputDecoration(labelText: 'Data Fine'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    final formatter = DateFormat('dd/MM/yyyy');
                    setState(() {
                      _dataFineController.text = formatter.format(pickedDate);
                    });
                  }
                },
              ),
              TextFormField(
                controller: _itinerarioController,
                decoration: const InputDecoration(labelText: 'Itinerario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore inserisci l\'itinerario del viaggio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore inserisci delle note per il viaggio';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  // Implementa la funzionalità per selezionare una foto
                },
                child: const Text('Carica Foto'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _addViaggio();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Viaggio aggiunto con successo')),
                    );
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Salva Viaggio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
