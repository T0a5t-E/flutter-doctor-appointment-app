import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bcrypt/bcrypt.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController historialMedicoController = TextEditingController();
  final TextEditingController nuevaContrasenaController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  bool _showPasswordField = false; // Mostrar campo de contraseña

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('usuarios').doc(user!.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          nombreController.text = data['nombre'] ?? '';
          edadController.text = data['edad']?.toString() ?? '';
          telefonoController.text = data['telefono'] ?? '';
          historialMedicoController.text = data['historial_medico'] ?? '';
        }
      } catch (e) {
        _showError('Error al cargar datos');
      }
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate() || user == null) return;

    try {
      Map<String, dynamic> updateData = {
        'nombre': nombreController.text.trim(),
        'edad': int.tryParse(edadController.text) ?? 0,
        'email': user!.email,
        'telefono': telefonoController.text.trim(),
        'historial_medico': historialMedicoController.text.trim(),
      };

      // Si el usuario escribió una nueva contraseña
      if (nuevaContrasenaController.text.isNotEmpty) {
        if (nuevaContrasenaController.text.length < 6) {
          _showError('La contraseña debe tener al menos 6 caracteres');
          return;
        }

        // Encriptar contraseña con BCrypt
        final hashedPassword = BCrypt.hashpw(nuevaContrasenaController.text, BCrypt.gensalt());
        updateData['contraseña_hash'] = hashedPassword;

        // También actualizar en Firebase Auth
        await user!.updatePassword(nuevaContrasenaController.text);
      }

      await _firestore.collection('usuarios').doc(user!.uid).set(updateData, SetOptions(merge: true));

      _showSuccess('Perfil actualizado correctamente');
      setState(() => _showPasswordField = false);
      nuevaContrasenaController.clear();
    } catch (e) {
      _showError('Error al guardar: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: user == null
          ? const Center(child: Text('No hay usuario autenticado'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Campos existentes
                    _buildTextField(nombreController, 'Nombre completo', Icons.person),
                    const SizedBox(height: 12),
                    _buildTextField(edadController, 'Edad', Icons.cake, keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    _buildTextField(telefonoController, 'Teléfono', Icons.phone, keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    _buildTextField(historialMedicoController, 'Historial médico (opcional)', Icons.medical_services, maxLines: 4),
                    const SizedBox(height: 20),

                    // Botón para mostrar campo de contraseña
                    if (!_showPasswordField)
                      OutlinedButton.icon(
                        icon: const Icon(Icons.lock),
                        label: const Text('Cambiar contraseña'),
                        onPressed: () => setState(() => _showPasswordField = true),
                      ),

                    // Campo de nueva contraseña (solo si se activa)
                    if (_showPasswordField) ...[
                      TextFormField(
                        controller: nuevaContrasenaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Nueva contraseña',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (_showPasswordField && (value == null || value.isEmpty)) {
                            return 'Ingresa una nueva contraseña';
                          }
                          if (_showPasswordField && value!.length < 6) {
                            return 'Mínimo 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() => _showPasswordField = false);
                          nuevaContrasenaController.clear();
                        },
                        child: const Text('Cancelar cambio de contraseña'),
                      ),
                    ],

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveUserData,
                      child: const Text('Guardar Perfil'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (label != 'Historial médico (opcional)' && (value == null || value.trim().isEmpty)) {
          return 'Campo obligatorio';
        }
        if (label == 'Edad' && int.tryParse(value!) == null) {
          return 'Edad inválida';
        }
        if (label == 'Teléfono' && value!.length < 10) {
          return 'Teléfono inválido';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    edadController.dispose();
    telefonoController.dispose();
    historialMedicoController.dispose();
    nuevaContrasenaController.dispose();
    super.dispose();
  }
}