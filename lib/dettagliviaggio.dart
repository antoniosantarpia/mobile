import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database/viaggio.dart';
import 'database/database_helper.dart';

class DettaglioViaggio extends StatefulWidget {
  final viaggio v;
  final VoidCallback onSave; // Callback per aggiornare TripScreen

  const DettaglioViaggio({super.key, required this.v, required this.onSave});

  @override
  _DettaglioViaggioState createState() => _DettaglioViaggioState();
}

class _DettaglioViaggioState extends State<DettaglioViaggio> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titoloController;
  late TextEditingController _dataInizioController;
  late TextEditingController _dataFineController;
  late TextEditingController _destinazioneController;
  late TextEditingController _itinerarioController;
  late TextEditingController _noteController;

  DateTime? _dataInizio;
  DateTime? _dataFine;

  @override
  void initState() {
    super.initState();
    _titoloController = TextEditingController(text: widget.v.titolo);
    _dataInizioController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(widget.v.data_inizio));
    _dataFineController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(widget.v.data_fine));
    _destinazioneController = TextEditingController(text: widget.v.destinazione);
    _itinerarioController = TextEditingController(text: widget.v.itinerario);
    _noteController = TextEditingController(text: widget.v.note);

    _dataInizio = widget.v.data_inizio;
    _dataFine = widget.v.data_fine;
  }

  @override
  void dispose() {
    _titoloController.dispose();
    _dataInizioController.dispose();
    _dataFineController.dispose();
    _destinazioneController.dispose();
    _itinerarioController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, {required bool isStartDate}) async {
    DateTime initialDate = DateFormat('dd/MM/yyyy').parse(controller.text);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != initialDate) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
        if (isStartDate) {
          _dataInizio = picked;
          // Verifica che la data di fine sia valida
          if (_dataFine != null && _dataFine!.isBefore(_dataInizio!)) {
            _dataFine = null;
            _dataFineController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('La data di fine deve essere successiva alla data di inizio')),
            );
          }
        } else {
          _dataFine = picked;
        }
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedViaggio = viaggio(
        id_viaggio: widget.v.id_viaggio,
        titolo: _titoloController.text,
        data_inizio: DateFormat('dd/MM/yyyy').parse(_dataInizioController.text),
        data_fine: DateFormat('dd/MM/yyyy').parse(_dataFineController.text),
        destinazione: _destinazioneController.text,
        itinerario: _itinerarioController.text,
        note: _noteController.text,
      );

      await DatabaseHelper.instance.updateViaggio(updatedViaggio);
      widget.onSave(); // Chiama il callback per aggiornare TripScreen
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.v.titolo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titoloController,
                decoration: const InputDecoration(labelText: 'Titolo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore inserisci un titolo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dataInizioController,
                decoration: const InputDecoration(labelText: 'Data Inizio'),
                readOnly: true,
                onTap: () => _selectDate(context, _dataInizioController, isStartDate: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore inserisci una data di inizio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dataFineController,
                decoration: const InputDecoration(labelText: 'Data Fine'),
                readOnly: true,
                onTap: () => _selectDate(context, _dataFineController, isStartDate: false),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore inserisci una data di fine';
                  }
                  if (_dataInizio != null && _dataFine != null && _dataFine!.isBefore(_dataInizio!)) {
                    return 'La data di fine deve essere successiva alla data di inizio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _destinazioneController,
                decoration: const InputDecoration(labelText: 'Destinazione'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore inserisci una destinazione';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _itinerarioController,
                decoration: const InputDecoration(labelText: 'Itinerario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore inserisci un itinerario';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore inserisci delle note';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annulla'),
                  ),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: const Text('Salva'),
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
