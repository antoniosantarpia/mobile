import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'database/viaggio.dart';
import 'database/database_helper.dart';
import 'database/destinazione.dart';
import 'database/categoria.dart';
import 'database/viaggio_categoria.dart';
import 'database/foto.dart';

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
  late TextEditingController _itinerarioController;
  late TextEditingController _noteController;

  DateTime? _dataInizio;
  DateTime? _dataFine;
  String? _selectedDestinazione;
  List<destinazione> _destinazioni = [];
  List<categoria> _selectedCategorie = [];
  List<categoria> _categorie = [];
  String? _currentImagePath; // Aggiungi questo campo per l'immagine attuale
  String? _previousImagePath; // Campo per il percorso dell'immagine precedente

  @override
  void initState() {
    super.initState();
    _titoloController = TextEditingController(text: widget.v.titolo);
    _dataInizioController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(widget.v.data_inizio));
    _dataFineController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(widget.v.data_fine));
    _itinerarioController = TextEditingController(text: widget.v.itinerario);
    _noteController = TextEditingController(text: widget.v.note);
    _dataInizio = widget.v.data_inizio;
    _dataFine = widget.v.data_fine;

    _loadDestinazioni();
    _loadCategorie();
    _loadImage(); // Carica l'immagine attuale
  }

  @override
  void dispose() {
    _titoloController.dispose();
    _dataInizioController.dispose();
    _dataFineController.dispose();
    _itinerarioController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadDestinazioni() async {
    try {
      final destinazioni = await DatabaseHelper.instance.getDestinations();
      setState(() {
        _destinazioni = destinazioni;
        _selectedDestinazione = widget.v.destinazione;
      });
    } catch (e) {
      print('Error loading destinations: $e');
    }
  }

  Future<void> _loadCategorie() async {
    final categorie = await DatabaseHelper.instance.getCategory();
    final selectedCat = await DatabaseHelper.instance.getCategoryOfTrip(widget.v.id_viaggio);
    setState(() {
      _categorie = categorie;
      _selectedCategorie = selectedCat;
    });
  }

  Future<void> _loadImage() async {
    final foto? immagine = await DatabaseHelper.instance.getFotoByViaggioId(widget.v.id_viaggio);
    setState(() {
      _currentImagePath = immagine?.path;
      _previousImagePath = immagine?.path; // Imposta il percorso dell'immagine precedente
    });
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
        destinazione: _selectedDestinazione!,
        itinerario: _itinerarioController.text,
        note: _noteController.text,
      );

      await DatabaseHelper.instance.deleteViaggioCategorieByViaggioId(widget.v.id_viaggio);
      // Inserisci le nuove associazioni viaggio-categoria
      for (var categoria in _selectedCategorie) {
        final viaggioCategoria = viaggio_categoria(
          viaggio: widget.v.id_viaggio,
          categoria: categoria.nome,
        );
        await DatabaseHelper.instance.insertViaggioCategoria(viaggioCategoria);
      }
      await DatabaseHelper.instance.updateViaggio(updatedViaggio);



        final idfoto;

        if(_previousImagePath==null){
              idfoto = await DatabaseHelper.instance.getLastImgId()+1;
        }else{
              idfoto = await DatabaseHelper.instance.getIdFoto(_previousImagePath!);
        }

        final newFoto = foto(
          id_foto: idfoto,
          viaggio: widget.v.id_viaggio,
          path: _currentImagePath!,
        );
        await DatabaseHelper.instance.saveOrUpdateFoto(newFoto);


      widget.onSave(); // Chiama il callback per aggiornare TripScreen
      Navigator.of(context).pop();
    }
  }

  Future<void> _showCategorieDialog() async {
    //final selectedCategorieTemp = List<categoria>.from(_selectedCategorie);
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Seleziona Categorie'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: _categorie.map((categoria) {
                    return CheckboxListTile(
                      title: Text(categoria.nome),
                      value: _selectedCategorie.contains(categoria),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true && !_selectedCategorie.contains(categoria)) {
                            _selectedCategorie.add(categoria);
                          } else if (value == false && _selectedCategorie.contains(categoria)) {
                            _selectedCategorie.remove(categoria);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    setState(() {
                      _selectedCategorie;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Aggiorna il percorso dell'immagine attuale
      setState(() {
        _currentImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.v.titolo),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await DatabaseHelper.instance.deleteViaggio(widget.v.id_viaggio); // Usa widget.v per accedere al viaggio
              widget.onSave(); // Aggiorna la lista dei viaggi nella schermata precedente
              Navigator.of(context).pop(); // Chiudi la schermata dei dettagli
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_currentImagePath != null)
                Image.file(
                  File(_currentImagePath!),
                  width: 300, // Imposta la larghezza desiderata
                  height: 200, // Imposta l'altezza desiderata
                  fit: BoxFit.cover, // Imposta il BoxFit desiderato
                ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Cambia Immagine'),
              ),
              TextFormField(
                controller: _titoloController,
                decoration: const InputDecoration(labelText: 'Titolo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci un titolo';
                  }
                  return null;
                },
              ),
              GestureDetector(
                onTap: () => _selectDate(context, _dataInizioController, isStartDate: true),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dataInizioController,
                    decoration: const InputDecoration(labelText: 'Data Inizio'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci una data di inizio';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _selectDate(context, _dataFineController, isStartDate: false),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dataFineController,
                    decoration: const InputDecoration(labelText: 'Data Fine'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci una data di fine';
                      }
                      if (_dataInizio != null && _dataFine != null && _dataFine!.isBefore(_dataInizio!)) {
                        return 'La data di fine deve essere successiva alla data di inizio';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedDestinazione,
                decoration: const InputDecoration(labelText: 'Destinazione'),
                items: _destinazioni.map((destinazione d) {
                  return DropdownMenuItem<String>(
                    value: d.nome,
                    child: Text(d.nome),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDestinazione = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleziona una destinazione';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _itinerarioController,
                decoration: const InputDecoration(labelText: 'Itinerario'),
              ),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
              ListTile(
                title: const Text('Categorie Viaggio'),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: _showCategorieDialog,
              ),
              Wrap(
                children: _selectedCategorie.map((categoria) {
                  return Chip(
                    label: Text(categoria.nome),
                    onDeleted: () {
                      setState(() {
                        _selectedCategorie.remove(categoria);
                      });
                    },
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Salva Modifiche'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
