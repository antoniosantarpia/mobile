import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'database/foto.dart';
import 'database/viaggio.dart';
import 'database/destinazione.dart';
import 'database/categoria.dart';
import 'database/viaggio_categoria.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
  final List<String> _imagePaths = [];
  bool _photosUploaded = false;

  DateTime? _dataInizio;
  DateTime? _dataFine;

  List<String> _selectedCategorie = [];
  List<categoria> _categorie = [];
  bool _showCategorieError = false;
  bool _showDateError = false;

  @override
  void initState() {
    super.initState();
    _loadDestinazioni();
    _loadCategorie();
  }

  Future<void> _loadDestinazioni() async {
    try {
      final destinazioni = await DatabaseHelper.instance.getDestinations();
      setState(() {
        _destinazioni = destinazioni;
      });
    } catch (e) {
      print('Error loading destinations: $e');
    }
  }

  Future<void> _loadCategorie() async {
    final categorie = await DatabaseHelper.instance.getCategory();
    setState(() {
      _categorie = categorie;
    });
  }

  Future<String> _saveImage(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    final imagePath = '$path/$fileName';
    final savedImage = await image.copy(imagePath);
    return savedImage.path;
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      for (var pickedFile in pickedFiles) {
        final imagePath = await _saveImage(File(pickedFile.path));
        setState(() {
          _imagePaths.add(imagePath);
        });
      }
      setState(() {
        _photosUploaded = true;
      });
    } else {
      print('Nessuna immagine selezionata.');
    }
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
      final newId = lastId + 1;

      if (_selectedDestinazione == null) {
        throw Exception('Per favore seleziona una destinazione');
      }

      // Formatta le date per la verifica
      final dateCheck = await DatabaseHelper.instance.verifyDateTrip(
        DateFormat('yyyy-MM-dd').format(formatter.parse(dataInizio)),
        DateFormat('yyyy-MM-dd').format(formatter.parse(dataFine)),
      );

      if (dateCheck != 0) {
        setState(() {
          _showDateError = true;
        });
      } else {
        setState(() {
          _showDateError = false;
        });

        if (!_showDateError) {
          final newViaggio = viaggio(
            id_viaggio: newId,
            titolo: titolo,
            data_inizio: formatter.parse(dataInizio),
            data_fine: formatter.parse(dataFine),
            note: note,
            itinerario: itinerario,
            destinazione: _selectedDestinazione!,
          );

          await DatabaseHelper.instance.insertViaggio(newViaggio);

          for (String categoria in _selectedCategorie) {
            final newViaggioCategoria = viaggio_categoria(
              categoria: categoria,
              viaggio: newId,
            );
            await DatabaseHelper.instance.insertViaggioCategoria(newViaggioCategoria);
          }

          final lastidFoto = await DatabaseHelper.instance.getLastImgId();
          int newFotoId = lastidFoto + 1;

          for (var imagePath in _imagePaths) {
            final newFoto = foto(
              id_foto: newFotoId,
              viaggio: newId,
              path: imagePath,
            );
            newFotoId++;
            await DatabaseHelper.instance.insertFoto(newFoto);
          }

          print('Added Trip: $titolo');
          _titoloController.clear();
          _dataInizioController.clear();
          _dataFineController.clear();
          _noteController.clear();
          _itinerarioController.clear();
          setState(() {
            _imagePaths.clear();
            _photosUploaded = false;
          });
        }
      }
    } catch (e) {
      print('Error adding trip: $e');
    }
  }

  Future<void> _showCategorieDialog() async {
    final selectedCategorieTemp = List<String>.from(_selectedCategorie);
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
                      value: selectedCategorieTemp.contains(categoria.nome),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true && !selectedCategorieTemp.contains(categoria.nome)) {
                            selectedCategorieTemp.add(categoria.nome);
                          } else if (value == false && selectedCategorieTemp.contains(categoria.nome)) {
                            selectedCategorieTemp.remove(categoria.nome);
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
                      _selectedCategorie = selectedCategorieTemp;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi Viaggio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
                decoration: const InputDecoration(labelText: 'Destinazione Viaggio'),
                value: _selectedDestinazione,
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
              ListTile(
                title: const Text('Categorie Viaggio'),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: _showCategorieDialog,
              ),
              if (_showCategorieError)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Per favore seleziona almeno una categoria',
                        style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        children: _selectedCategorie.map((categoria) {
                          return Chip(
                            label: Text(categoria),
                            onDeleted: () {
                              setState(() {
                                _selectedCategorie.remove(categoria);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _selectedCategorie.map((categoria) {
                    return Chip(
                      label: Text(categoria),
                      onDeleted: () {
                        setState(() {
                          _selectedCategorie.remove(categoria);
                        });
                      },
                    );
                  }).toList(),
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
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    final formatter = DateFormat('dd/MM/yyyy');
                    setState(() {
                      _dataInizioController.text = formatter.format(pickedDate);
                      _dataInizio = pickedDate;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore inserisci la data di inizio';
                  }
                  return null;
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
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    if (_dataInizio != null && pickedDate.isBefore(_dataInizio!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('La data di fine deve essere successiva alla data di inizio'),
                        ),
                      );
                    } else {
                      final formatter = DateFormat('dd/MM/yyyy');
                      setState(() {
                        _dataFineController.text = formatter.format(pickedDate);
                        _dataFine = pickedDate;
                      });
                    }
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore inserisci la data di fine';
                  }
                  if (_dataInizio != null && _dataFine != null && _dataFine!.isBefore(_dataInizio!)) {
                    return 'La data di fine deve essere successiva alla data di inizio';
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
              ElevatedButton(
                onPressed: _pickImages,
                child: _photosUploaded
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Foto caricate con successo!'),
                  ],
                )
                    : const Text('Carica Foto'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _showCategorieError = _selectedCategorie.isEmpty;
                  });

                  if (_formKey.currentState!.validate() && !_showCategorieError) {
                    final formatter = DateFormat('dd/MM/yyyy');
                    final dataInizio = _dataInizioController.text;
                    final dataFine = _dataFineController.text;

                    final dateCheck = await DatabaseHelper.instance.verifyDateTrip(
                      DateFormat('yyyy-MM-dd').format(formatter.parse(dataInizio)),
                      DateFormat('yyyy-MM-dd').format(formatter.parse(dataFine)),
                    );

                    if (dateCheck != 0) {
                      setState(() {
                        _showDateError = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hai già un viaggio in queste date')),
                      );
                    } else {
                      setState(() {
                        _showDateError = false;
                      });

                      if (_formKey.currentState!.validate() && !_showCategorieError && !_showDateError) {
                        await _addViaggio();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Viaggio aggiunto con successo')),
                        );
                        Navigator.pop(context, true);
                      }
                    }
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
