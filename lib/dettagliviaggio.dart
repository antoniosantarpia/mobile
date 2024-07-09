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
import 'database/recensione.dart';

class DettaglioViaggio extends StatefulWidget {
  final viaggio v;
  final VoidCallback onSave; // Callback per aggiornare TripScreen

  const DettaglioViaggio({super.key, required this.v, required this.onSave});

  @override
  _DettaglioViaggioState createState() => _DettaglioViaggioState();
}

class _DettaglioViaggioState extends State<DettaglioViaggio> {
  final _formKey = GlobalKey<FormState>();
  final _categorieKey = GlobalKey<FormFieldState>();
  late TextEditingController _titoloController;
  late TextEditingController _dataInizioController;
  late TextEditingController _dataFineController;
  late TextEditingController _itinerarioController;
  late TextEditingController _noteController;
  late TextEditingController _recensioneController;

  DateTime? _dataInizio;
  DateTime? _dataFine;
  String? _selectedDestinazione;
  List<destinazione> _destinazioni = [];
  List<categoria> selectedCategorie = [];
  List<categoria> _categorie = [];
  String? _recensione;
  List<String> _currentImagePaths = []; // Aggiungi questo campo per l'immagine attuale
  List<String> _previousImagePaths = []; // Campo per il percorso dell'immagine precedente
  bool canAddReview = false;

  @override
  void initState() {
    super.initState();
    _titoloController = TextEditingController(text: widget.v.titolo);
    _dataInizioController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(widget.v.data_inizio));
    _dataFineController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(widget.v.data_fine));
    _itinerarioController = TextEditingController(text: widget.v.itinerario);
    _noteController = TextEditingController(text: widget.v.note);
    _recensioneController = TextEditingController();
    _dataInizio = widget.v.data_inizio;
    _dataFine = widget.v.data_fine;

    _loadDestinazioni();
    _loadCategorie();
    _loadImages(); // Carica l'immagine attuale
    _loadRecensione();
  }

  @override
  void dispose() {
    _titoloController.dispose();
    _dataInizioController.dispose();
    _dataFineController.dispose();
    _itinerarioController.dispose();
    _recensioneController.dispose();
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

  Future<void> _loadRecensione() async {
    try {
      final rec = await DatabaseHelper.instance.getRecensione(widget.v.id_viaggio);
      setState(() {
        _recensione = rec;
        _recensioneController = TextEditingController(text: rec);
      });
    } catch (e) {
      print('Error loading review: $e');
    }
  }

  Future<void> _loadCategorie() async {
    final categorie = await DatabaseHelper.instance.getCategory();
    final selectedCat = await DatabaseHelper.instance.getCategoryOfTrip(widget.v.id_viaggio);
    setState(() {
      _categorie = categorie;
      selectedCategorie = selectedCat;
    });
  }

  Future<void> _loadImages() async {
    final List<foto> fotoList = await DatabaseHelper.instance.getFotoByViaggioId(widget.v.id_viaggio);
    setState(() {
      _currentImagePaths = fotoList.map((foto) => foto.path).toList();
      _previousImagePaths = _currentImagePaths.toList();
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
      await _saveImages(widget.v.id_viaggio);
      await DatabaseHelper.instance.updateViaggio(updatedViaggio);

      for (var categoria in selectedCategorie) {
        final viaggioCategoria = viaggio_categoria(
          viaggio: widget.v.id_viaggio,
          categoria: categoria.nome,
        );
        await DatabaseHelper.instance.insertViaggioCategoria(viaggioCategoria);
      }

      final recensione Recensione;
      final idRec = await DatabaseHelper.instance.getRecIdByViaggio(widget.v.id_viaggio);
      if(_recensioneController.text.isNotEmpty) {
        if (idRec == 0) {
          Recensione = recensione(
            id_recensione: await DatabaseHelper.instance.getLastRecId() + 1,
            testo: _recensioneController.text,
            viaggio: widget.v.id_viaggio,
          );
          await DatabaseHelper.instance.insertRecensione(Recensione);
        } else {
          Recensione = recensione(
            id_recensione: idRec,
            testo: _recensioneController.text,
            viaggio: widget.v.id_viaggio,
          );
          await DatabaseHelper.instance.UpdateRecensione(Recensione);
        }

      }else if(_recensioneController.text.isEmpty && idRec!=0){ // se tolgo la recensione di un viaggio la elimina anche dal db
        await DatabaseHelper.instance.deleteReview(widget.v.id_viaggio);
      }

      // se un viaggio diventa pianificato eliminiamo la recensione presente
      if(canAddReview==false) {
        await DatabaseHelper.instance.deleteReview(widget.v.id_viaggio);
      }

      widget.onSave(); // Chiama il callback per aggiornare TripScreen
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveImages(int idViaggio) async {
    // Get the last used ID for photos
    int lastPhotoId = await DatabaseHelper.instance.getPhotoId() ?? 0;

    // permetto di inserire le foto aggiunte alla collezione di foto
    for (var imagePath in _currentImagePaths) {
      if (!_previousImagePaths.contains(imagePath)) {
        final fotoInstance = foto(
          id_foto: lastPhotoId + 1,
          viaggio: idViaggio,
          path: imagePath,
        );
        await DatabaseHelper.instance.saveOrUpdateFoto(fotoInstance);
        lastPhotoId++; // Increment the ID for the next photo
      }
    }

    // se tra le immagini correnti non compare un'immagine precedente, allora significa che è stata eliminata
    // quindi eliminarla anche dal db
    for (var imagePath in _previousImagePaths){
      if(!_currentImagePaths.contains(imagePath)){
        await DatabaseHelper.instance.deleteFoto(imagePath);
      }
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
                      value: selectedCategorie.contains(categoria),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            if (!selectedCategorie.contains(categoria)) {
                              selectedCategorie.add(categoria);
                            }
                          } else {
                            selectedCategorie.remove(categoria);
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
                      selectedCategorie;
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


  void _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage(
      maxWidth: 800,
    );
    setState(() {
      _currentImagePaths.addAll(pickedFiles.map((file) => file.path));
    });
    }

  void _removeImage(int index) {
    setState(() {
      _currentImagePaths.removeAt(index);
    });
  }

  Future<void> _deleteViaggioAndVerifyCategory() async{

    int count = 0;
    await DatabaseHelper.instance.deleteViaggio(widget.v.id_viaggio);
    for(categoria c in selectedCategorie){
      count = await DatabaseHelper.instance.verifyCategory(c);
      if(count==0){
        await DatabaseHelper.instance.deleteCategory(c);
      }
    }

    await DatabaseHelper.instance.deleteViaggio(widget.v.id_viaggio);
  }

  @override
  Widget build(BuildContext context) {
    canAddReview = _dataFine != null && _dataFine!.isBefore(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.v.titolo),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: (){
              _deleteViaggioAndVerifyCategory();
              widget.onSave(); // Aggiorna la schermata precedente
              Navigator.of(context).pop(); // Chiudi la schermata di dettaglio
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start of the column
              children: [
                if (_currentImagePaths.isNotEmpty)
                  GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Numero di immagini per riga
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the GridView
                    itemCount: _currentImagePaths.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Image.file(
                            File(_currentImagePaths[index]),
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeImage(index),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ElevatedButton(
                  onPressed: _pickImages,
                  child: Text('Aggiungi Immagini (${_currentImagePaths.length})'),
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
                  spacing: 10,
                  runSpacing: 10,
                  children: selectedCategorie.map((categoria) {
                    return Chip(
                      label: Text(categoria.nome),
                      padding: const EdgeInsets.all(10),
                      onDeleted: () {
                        setState(() {
                          selectedCategorie.remove(categoria);
                        });
                      },
                    );
                  }).toList(),
                ),
                if (canAddReview)
                  TextFormField(
                    controller: _recensioneController,
                    decoration: const InputDecoration(labelText: 'Recensione'),
                    maxLines: 4,
                  ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      if (_dataInizio != null && _dataFine != null && _dataFine!.isBefore(_dataInizio!)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('La data di fine deve essere successiva alla data di inizio')),
                        );
                      } else {
                        _saveChanges();
                      }
                    }
                  },
                  child: const Text('Salva Modifiche'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
