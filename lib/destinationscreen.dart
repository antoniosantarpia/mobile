import 'package:flutter/material.dart';

class DestinationsScreen extends StatefulWidget {
  @override
  _DestinationsScreenState createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  // Lista di esempio delle destinazioni
  List<String> destinations = [
    'Roma',
    'Parigi',
    'New York',
    'Tokyo',
  ];

  // Mappa per tenere traccia del numero di visite per ogni destinazione
  Map<String, int> visits = {
    'Roma': 2,
    'Parigi': 5,
    'New York': 3,
    'Tokyo': 1,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Destinazioni',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                final destination = destinations[index];
                final visitCount = visits[destination] ?? 0;

                return ListTile(
                  title: Text(destination),
                  subtitle: Text('Visitata $visitCount volte'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aggiungi azione desiderata per aggiungere una destinazione
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
