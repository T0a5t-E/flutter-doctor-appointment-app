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
    if (user == null) return;
    final doc = await _firestore.collection('usuarios').doc(user!.uid).get();
    setState(() {
      userName = doc.exists ? doc['nombre'] ?? user!.email?.split('@')[0] : user!.email?.split('@')[0];
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesPage()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hola, ${userName ?? 'Usuario'}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Acciones rápidas
            Row(
              children: [
                Expanded(child: _ActionCard(icon: Icons.calendar_today, title: 'Agendar Citas')),
                const SizedBox(width: 16),
                Expanded(child: _ActionCard(icon: Icons.lightbulb_outline, title: 'Consejos Médicos')),
              ],
            ),
            const SizedBox(height: 24),

            // Especialistas
            const Text('Especialistas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF007AFF))),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _SpecialistCard(name: 'Cardiólogo', icon: Icons.favorite),
                  _SpecialistCard(name: 'Dermatólogo', icon: Icons.face),
                  _SpecialistCard(name: 'Neurólogo', icon: Icons.psychology),
                  _SpecialistCard(name: 'Pediatra', icon: Icons.child_care),
                  _SpecialistCard(name: 'Oncólogo', icon: Icons.local_hospital),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Doctores populares
            const Text('Doctores Populares', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF007AFF))),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _DoctorCard(name: 'Dr. John Doe', specialty: 'Cardiólogo', rating: 4.8),
                  _DoctorCard(name: 'Dr. Jane Smith', specialty: 'Dermatólogo', rating: 4.9),
                  _DoctorCard(name: 'Dr. Emily Johnson', specialty: 'Neurólogo', rating: 4.7),
                  _DoctorCard(name: 'Dr. Michael Brown', specialty: 'Pediatra', rating: 4.6),
                  _DoctorCard(name: 'Dr. Sarah Davis', specialty: 'Oncólogo', rating: 4.9),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF007AFF),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}

// Tarjetas reutilizables
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  const _ActionCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 40, color: const Color(0xFF007AFF)),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialistCard extends StatelessWidget {
  final String name;
  final IconData icon;
  const _SpecialistCard({required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: const Color(0xFF007AFF)),
            const SizedBox(height: 8),
            Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  const _DoctorCard({required this.name, required this.specialty, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 35, backgroundColor: Colors.grey),
            const SizedBox(height: 12),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text(specialty, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                Text(rating.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}