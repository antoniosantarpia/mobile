import 'package:flutter/material.dart';
import 'database/database_helper.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  Future<Map<String, dynamic>> _loadStatistics() async {
    final int totalTrips = await DatabaseHelper.instance.getTotalTrips();
    final List<Map<String, dynamic>> mostVisitedDestinations = await DatabaseHelper.instance.getMostVisitedDestinations();
    return {
      'totalTrips': totalTrips,
      'mostVisitedDestinations': mostVisitedDestinations,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiche'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _loadStatistics(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Errore nel caricamento delle statistiche'));
            } else {
              final stats = snapshot.data!;
              final int totalTrips = stats['totalTrips'] ?? 0;
              final List<Map<String, dynamic>> mostVisitedDestinations = stats['mostVisitedDestinations'] ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Numero totale di viaggi: $totalTrips',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Destinazioni più visitate:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...mostVisitedDestinations.map((destination) {
                    final destinazione = destination['destinazione'] as String?;
                    final count = destination['count'] as int?;
                    if (destinazione != null && count != null) {
                      return _buildDestinationItem(destinazione, count);
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
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
              );
            }
          },
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
