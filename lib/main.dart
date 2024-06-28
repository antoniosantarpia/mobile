import 'package:flutter/material.dart';
import 'tripscreen.dart';
import 'destinationscreen.dart';
import 'searchscreen.dart';
import 'statisticsscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.black87,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/user_image.png'), // Immagine dell'utente
            ),
            SizedBox(width: 16),
            Text(
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
                  MaterialPageRoute(builder: (context) => StatisticsScreen()), // Naviga alla schermata delle statistiche
                );
              },
              child: Text('Statistiche'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
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
        children: [
          _homeContent(),
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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.airplanemode_active), label: 'Viaggi'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Destinazioni'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Ricerca'),
        ],
      ),
    );
  }

  Widget _homeContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prossimo Viaggio',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Container(
            height: 250, // Altezza delle card
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 1, // Numero di viaggi pianificati
              itemBuilder: (context, index) {
                return Container(
                  width: 340, // Larghezza delle card
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  child: Card(
                    color: Color(0xffdcdcf7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          child: Image.asset(
                            'assets/images/viaggio${index + 1}.png',
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Viaggio ${index + 1}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Text(
                            'Dettagli del viaggio ${index + 1}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Ultime Destinazioni',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: 2, // Numero di ultime destinazioni
              itemBuilder: (context, index) {
                return Card(
                  color: Color(0xffa9b9de),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(
                      'Destinazione ${index + 1}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Dettagli della destinazione ${index + 1}'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text('Aggiungi Viaggio'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('Crea Categoria'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
