import 'package:flutter/material.dart';
import 'tripscreen.dart';
import 'destinationscreen.dart';
import 'searchscreen.dart';
import 'statisticsscreen.dart';
import 'homescreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
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
            const SizedBox(width: 3),
            Image.asset(
              'assets/images/icon.png', // Percorso dell'icona aggiunta
              height: 53, // Altezza desiderata dell'icona
            ),
            const SizedBox(width: 8),
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
      bottomNavigationBar:
        Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.red), // Aggiungi un bordo rosso
        ),
        child:  BottomNavigationBar(
        backgroundColor: Colors.green,
        selectedItemColor: Colors.deepPurple[700],
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
    ),
    );
  }
}
