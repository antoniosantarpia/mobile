import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiche'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Numero totale di viaggi: 10',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Destinazioni più visitate:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDestinationItem('Roma', 5),
            _buildDestinationItem('Parigi', 3),
            _buildDestinationItem('New York', 2),
            const SizedBox(height: 16),
            const Text(
              'Grafici:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Text('Grafico qui'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationItem(String destination, int visits) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(destination),
          ),
          Text('$visits volte'),
        ],
      ),
    );
  }

}
