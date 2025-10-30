// New file: about_page.dart
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre nosotros'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Somos una plataforma dedicada a conectar pacientes con especialistas médicos. '
          'Nuestra misión es facilitar el acceso a la atención médica de calidad. '
          'Fundada en 2023, contamos con un equipo de profesionales apasionados por la salud.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}