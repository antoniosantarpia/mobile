import 'package:flutter/material.dart';
import 'tripscreen.dart';
import 'destinationscreen.dart';
import 'searchscreen.dart';
import 'statisticsscreen.dart';
import 'homescreen.dart'; // Importa il nuovo file homescreen.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.black87,
        title: Row(
          children: [
            const SizedBox(width: 16),
            const Text(
              'Travel Manager',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Container(),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatisticsScreen()), // Naviga alla schermata delle statistiche
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: const Text('Statistiche'),
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          HomePageContent(),
          TripsScreen(),
          DestinationsScreen(),
          SearchTripsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black87,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.airplanemode_active), label: 'Viaggi'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Destinazioni'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Ricerca'),
        ],
      ),
    );
  }
}
