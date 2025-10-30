import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'messages_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  User? user;
  String? userName;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? user!.email?.split('@')[0];
        });
      } else {
        setState(() {
          userName = user!.email?.split('@')[0];
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MessagesPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menú Principal"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mensaje de bienvenida
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Bienvenido, ${userName ?? 'Usuario'}!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            // Dos widgets: Agendar citas y Consejos médicos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.calendar_today, size: 40),
                            const SizedBox(height: 8),
                            const Text('Agendar Citas'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.lightbulb_outline, size: 40),
                            const SizedBox(height: 8),
                            const Text('Consejos Médicos'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Lista de especialistas
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Especialistas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  SpecialistCard(name: 'Cardiólogo', icon: Icons.favorite),
                  SpecialistCard(name: 'Dermatólogo', icon: Icons.face),
                  SpecialistCard(name: 'Neurologo', icon: Icons.psychology),
                  SpecialistCard(name: 'Pediatra', icon: Icons.child_care),
                  SpecialistCard(name: 'Oncólogo', icon: Icons.local_hospital),
                ],
              ),
            ),
            // Popular Doctors
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Popular Doctors',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  DoctorCard(name: 'Dr. John Doe', specialty: 'Cardiólogo', rating: 4.8),
                  DoctorCard(name: 'Dr. Jane Smith', specialty: 'Dermatólogo', rating: 4.9),
                  DoctorCard(name: 'Dr. Emily Johnson', specialty: 'Neurologo', rating: 4.7),
                  DoctorCard(name: 'Dr. Michael Brown', specialty: 'Pediatra', rating: 4.6),
                  DoctorCard(name: 'Dr. Sarah Davis', specialty: 'Oncólogo', rating: 4.9),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Mensajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class SpecialistCard extends StatelessWidget {
  final String name;
  final IconData icon;

  const SpecialistCard({super.key, required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50),
            const SizedBox(height: 8),
            Text(name),
          ],
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;

  const DoctorCard({super.key, required this.name, required this.specialty, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey, // Placeholder for doctor image
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(specialty),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.yellow),
                Text(rating.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}