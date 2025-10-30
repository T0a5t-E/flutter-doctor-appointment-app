// New file: privacy_page.dart
import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidad'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Información sobre nuestra política de privacidad. '
          'Nos comprometemos a proteger tus datos personales y a no compartirlos sin tu consentimiento. '
          'Para más detalles, consulta nuestros términos y condiciones.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}