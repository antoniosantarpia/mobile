import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'database/database_helper.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  Future<Map<String, dynamic>> _loadStatistics() async {
    final int totalTrips = await DatabaseHelper.instance.getTotalTripsDone();
    final List<Map<String, dynamic>> mostVisitedDestinations = await DatabaseHelper.instance.getMostVisitedDestinations();
    final List<Map<String, dynamic>> tripDataMaps = await DatabaseHelper.instance.getTripDataForChart();

    final List<MapEntry<DateTime, int>> tripData = tripDataMaps.map((map) {
      final String monthYear = map['month_year'] as String;
      final int count = map['count'] as int;

      final List<String> parts = monthYear.split('-');
      final int year = int.parse(parts[0]);
      final int month = int.parse(parts[1]);

      final DateTime date = DateTime(year, month, 1);

      return MapEntry(date, count);
    }).toList();

    return {
      'totalTrips': totalTrips,
      'mostVisitedDestinations': mostVisitedDestinations,
      'tripData': tripData,
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
              final List<MapEntry<DateTime, int>> tripData = stats['tripData'] ?? [];

              final List<charts.Series<MapEntry<DateTime, int>, DateTime>> seriesList = [
                charts.Series<MapEntry<DateTime, int>, DateTime>(
                  id: 'Trips',
                  colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                  domainFn: (entry, _) => entry.key,
                  measureFn: (entry, _) => entry.value,
                  data: tripData,
                ),
              ];

              return SingleChildScrollView(
                child: Column(
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
                      'Grafico dell\'andamento dei viaggi nel tempo:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 400, // Set a fixed height for the chart
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.grey[300],
                      child: Stack(
                        children: [
                          charts.TimeSeriesChart(
                            seriesList,
                            animate: true,
                            dateTimeFactory: const charts.LocalDateTimeFactory(),
                            behaviors: [
                              charts.ChartTitle('Data'),
                              charts.ChartTitle('Numero di viaggi', behaviorPosition: charts.BehaviorPosition.start),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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