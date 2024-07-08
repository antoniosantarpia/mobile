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
    return DefaultTextStyle(
      style: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        fontStyle: FontStyle.normal,
        fontFamily: 'Helvetica',
      ),
      child: MaterialApp(
        title: 'Travel Manager',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            toolbarHeight: 80,
            backgroundColor: Color.fromRGBO(227, 186, 245, 1),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
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
        toolbarHeight: 90,
        backgroundColor: Colors.deepPurple,
        title: Row(
          children: [
            const SizedBox(width: 3),
            Image.asset(
              'assets/images/icon.png', // Percorso dell'icona aggiunta
              height: 45, // Altezza desiderata dell'icona
            ),
            const SizedBox(width: 8),
           const  Expanded(
              child: Text(
                'Travel Manager',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Helvetica-BoldOblique',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  fontSize: 24, // Dimensione del font ridotta
                  overflow: TextOverflow.ellipsis, // Aggiunto per prevenire overflow
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatisticsScreen()), // Naviga alla schermata delle statistiche
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                side: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Text(
                'Statistiche',
                style: TextStyle(fontSize: 16),
              ),
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
      bottomNavigationBar: Container(
        height: 75,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.6),
              spreadRadius: 4,
              blurRadius: 6,
              offset: const Offset(0, 1), // Ombra
            ),
          ],
        ),
        child: BottomNavigationBar(
          selectedItemColor: Colors.deepPurple[900],
          selectedFontSize: 18,
          unselectedItemColor: Colors.grey,
          unselectedFontSize: 12,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home, size: 25), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.airplanemode_active, size: 25), label: 'Viaggi'),
            BottomNavigationBarItem(icon: Icon(Icons.location_on, size: 25), label: 'Destinazioni'),
            BottomNavigationBarItem(icon: Icon(Icons.search, size: 25), label: 'Ricerca'),
          ],
        ),
      ),
    );
  }

}