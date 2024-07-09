import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'database/viaggio.dart';
import 'database/viaggio_categoria.dart';
import 'database/destinazione.dart';
import 'database/categoria.dart';
import 'dettagliviaggio.dart';

class SearchTripsScreen extends StatefulWidget {
  const SearchTripsScreen({super.key});

  @override
  _SearchTripsScreenState createState() => _SearchTripsScreenState();
}

class _SearchTripsScreenState extends State<SearchTripsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<viaggio> viaggi = []; // Lista di viaggi dal DB
  List<viaggio> filteredTrips = [];
  List<String> allCategories = [];
  List<viaggio_categoria> viaggioCategorie = [];

  String? _selectedDestinazione;

  List<destinazione> _destinazioni = [];
  List<categoria> _categorie = [];
  List<String> _selectedCategorie = [];

  // Variabili per i filtri
  DateTime? startDate;
  DateTime? endDate;
  String? destination;
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _loadViaggi();
    _loadDestinazioni();
    _loadCategorie();
    _loadViaggioCategorie();
  }

  // Carica i viaggi e le categorie dal database
  Future<void> _loadViaggi() async {
    try {
      final db = DatabaseHelper.instance;
      viaggi = await db.getViaggi();
      setState(() {
        filterTrips();
      });
    } catch (e) {
      print('Error loading viaggi: $e');
    }
  }

  Future<void> _loadCategorie() async {
    final categorie = await DatabaseHelper.instance.getCategory();
    setState(() {
      _categorie = categorie;
      filterTrips();
    });
  }

  Future<void> _loadViaggioCategorie() async {
    try {
      final db = DatabaseHelper.instance;
      viaggioCategorie = await db.getViaggioCategoria();
      print('ViaggioCategorie caricate: ${viaggioCategorie.length}');
      setState(() {
        filterTrips();
      });
    } catch (e) {
      print('Error loading viaggioCategorie: $e');
    }
  }

  Future<void> _loadDestinazioni() async {
    try {
      final destinazioni = await DatabaseHelper.instance.getDestinations();
      setState(() {
        _destinazioni = destinazioni;
        filterTrips();
      });
    } catch (e) {
      print('Error loading destinations: $e');
    }
  }

  Future<void> filterTrips() async {
    try {
      setState(() {
        final searchTerm = _searchController.text.toLowerCase();
        print('Search term: $searchTerm');

        filteredTrips = viaggi.where((trip) {
          // Verifica se il titolo del viaggio corrisponde al termine di ricerca
          final matchesSearchTerm = trip.titolo.toLowerCase().contains(searchTerm);

          // Verifica se il viaggio rientra nelle date selezionate
          final matchesDateRange = (startDate == null || !trip.data_inizio.isBefore(startDate!)) &&
              (endDate == null || !trip.data_fine.isAfter(endDate!));

          // Verifica se la destinazione del viaggio corrisponde alla destinazione selezionata
          final matchesDestination = _selectedDestinazione == null || trip.destinazione == _selectedDestinazione;

          // Verifica se il viaggio appartiene a una delle categorie selezionate
          final matchesCategories = _selectedCategorie.isEmpty || _selectedCategorie.every((categoria) {
            return viaggioCategorie.any((vc) => vc.viaggio == trip.id_viaggio && vc.categoria == categoria);
          });

          return matchesSearchTerm && matchesDateRange && matchesDestination && matchesCategories;
        }).toList();
      });
    } catch (e) {
      print('Eccezione filterTrips: $e');
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


  List<Widget> _buildViaggiList() {
    List<Widget> viaggiWidgets = [];
    for (var v in filteredTrips) { // Usa filteredTrips invece di _viaggio
      viaggiWidgets.add(_buildViaggioCard(v));
    }
    return viaggiWidgets;
  }

  Widget _buildViaggioCard(viaggio v) {
    return Card(
      child: ListTile(
        title: Text(v.titolo),
        onTap: () {
          final result = Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DettaglioViaggio(
              v: v,
              onSave: () {
                _loadViaggi();
              },
            ),
          ));

          // Aggiorna i viaggi e filtra nuovamente dopo il ritorno dalla pagina di dettaglio
          if (result == true) {
            _loadViaggi();
            filterTrips();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ricerca Viaggi',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              showFilterOptions(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                filterTrips();
              },
              decoration: const InputDecoration(
                labelText: 'Cerca viaggio',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredTrips.isEmpty
                ? const Center(child: Text('Nessun viaggio trovato'))
                : ListView(
              children: _buildViaggiList(),
            ),
          ),
        ],
      ),
    );
  }

  void showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView( // Aggiunto SingleChildScrollView
              child: Container(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filtri',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Data Partenza'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2050),
                        ).then((pickedDate) {
                          if (pickedDate != null) {
                            setModalState(() {
                              startDate = pickedDate;
                            });
                          }
                        });
                      },
                      child: Text(startDate != null
                          ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                          : 'Seleziona Data'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Data Ritorno'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2050),
                        ).then((pickedDate) {
                          if (pickedDate != null) {
                            setModalState(() {
                              if (startDate != null && pickedDate.isBefore(startDate!)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('La data di ritorno non può essere precedente alla data di partenza.'),
                                  ),
                                );
                              } else {
                                endDate = pickedDate;
                              }
                            });
                          }
                        });
                      },
                      child: Text(endDate != null
                          ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                          : 'Seleziona Data'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Destinazione'),
                    const SizedBox(height: 8),
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
                        setModalState(() {
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
                      onTap: () async {
                        await _showCategorieDialog();
                        setModalState(() {});
                      },
                    ),
                    Wrap(
                      children: _selectedCategorie.map((categoria) {
                        return Chip(
                          label: Text(categoria),
                          onDeleted: () {
                            setModalState(() {
                              _selectedCategorie.remove(categoria);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16), // Padding tra categorie e pulsanti
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setModalState(() {
                              startDate = null;
                              endDate = null;
                              _selectedDestinazione = null;
                              _selectedCategorie.clear();
                            });
                            filterTrips(); // Azzera i filtri e applica l'aggiornamento
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(),
                          child: const Text('Azzera filtri'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            filterTrips(); // Applica i filtri desiderati
                            Navigator.of(context).pop(); // Chiudi il modal
                          },
                          child: const Text('Mostra'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }



  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
