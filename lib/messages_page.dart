import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});
  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? userName;
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (user == null) return;
    final doc = await firestore.collection('usuarios').doc(user!.uid).get();
    final name = doc.exists ? doc['nombre'] ?? user!.email?.split('@')[0] : 'Usuario';
    
    // Simulación de mensajes
    final mockMessages = List.generate(5, (i) => {
      'id': 'msg_$i',
      'title': 'Mensaje ${i + 1}',
      'subtitle': 'Del Dr. Example',
      'time': DateTime.now().subtract(Duration(minutes: i * 5)),
    });

    setState(() {
      userName = name;
      messages = mockMessages;
    });
  }

  Future<void> _deleteMessage(String id) async {
    setState(() => messages.removeWhere((m) => m['id'] == id));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mensaje eliminado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mensajes de $userName'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            return Dismissible(
              key: Key(msg['id']),
              direction: DismissDirection.endToStart,
              background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
              onDismissed: (_) => _deleteMessage(msg['id']),
              child: GestureDetector(
                onLongPress: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(title: const Text('Long Press'), content: const Text('Mensaje seleccionado'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]),
                ),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(msg['title']),
                  subtitle: Text(msg['subtitle']),
                  trailing: Text('${msg['time'].hour}:${msg['time'].minute}'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}