import 'package:flutter/material.dart';

class SearchTripsScreen extends StatefulWidget {
  const SearchTripsScreen({super.key});

  @override
  _SearchTripsScreenState createState() => _SearchTripsScreenState();
}

class _SearchTripsScreenState extends State<SearchTripsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> trips = [
    'Viaggio a Parigi',
    'Vacanza in Giappone',
    'Tour negli Stati Uniti',
    'Escursione alle Maldive',
    'Weekend a Roma',
    'Viaggio in Thailandia',
  ];
  List<String> filteredTrips = [];

  // Variabili per i filtri
  DateTime? startDate;
  DateTime? endDate;
  String? tripType;

  void filterTrips(String searchTerm) {
    setState(() {
      filteredTrips = trips.where((trip) =>
          trip.toLowerCase().contains(searchTerm.toLowerCase())).toList();
    });
  }

  void showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filtri',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Data Partenza'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  ).then((pickedDate) {
                    if (pickedDate != null) {
                      setState(() {
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
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  ).then((pickedDate) {
                    if (pickedDate != null) {
                      setState(() {
                        endDate = pickedDate;
                      });
                    }
                  });
                },
                child: Text(endDate != null
                    ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                    : 'Seleziona Data'),
              ),
              const SizedBox(height: 16),
              const Text('Tipo Viaggio'),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: tripType,
                onChanged: (value) {
                  setState(() {
                    tripType = value;
                  });
                },
                items: <String>['Vacanza', 'Lavoro', 'Esplorazione']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Chiudi il modal
                    },
                    style: ElevatedButton.styleFrom(
                    ),
                    child: const Text('Annulla'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Applica i filtri desiderati
                      applyFilters();
                      Navigator.of(context).pop(); // Chiudi il modal
                    },
                    child: const Text('Mostra'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void applyFilters() {
    // Applica i filtri basati su startDate, endDate, tripType, ecc.
    print('Filtri applicati:');
    print('Data Partenza: $startDate');
    print('Data Ritorno: $endDate');
    print('Tipo Viaggio: $tripType');
    // Implementa la logica per filtrare la lista dei viaggi
  }

  @override
  void initState() {
    filteredTrips.addAll(trips);
    super.initState();
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
                filterTrips(value);
              },
              decoration: const InputDecoration(
                labelText: 'Cerca viaggio',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTrips.length,
              itemBuilder: (context, index) {
                final trip = filteredTrips[index];
                return ListTile(
                  title: Text(trip),
                  onTap: () {
                    // Azione da eseguire quando viene selezionato un viaggio
                    print('Hai selezionato: $trip');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
