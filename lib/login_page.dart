import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _rememberMe = false;

  Future<void> _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Usuario no encontrado';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta';
      } else {
        message = 'Error: ${e.message}';
      }
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Detectar si es Web
  bool get _isWeb => identical(0, 0.0);

  // Fuente segura multiplataforma
  String get _fontFamily => _isWeb ? 'Roboto' : '.SF UI Text';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Iniciar Sesión',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: CupertinoColors.white,
            fontFamily: _fontFamily,
          ),
        ),
        backgroundColor: CupertinoColors.systemBlue,
        border: null,
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Icono de perfil
                const Icon(
                  CupertinoIcons.person_crop_circle_fill,
                  size: 90,
                  color: CupertinoColors.systemBlue,
                ),
                const SizedBox(height: 30),

                // 1. CupertinoTextField - Email
                CupertinoTextField(
                  controller: emailController,
                  placeholder: 'Email',
                  placeholderStyle: TextStyle(color: CupertinoColors.placeholderText, fontFamily: _fontFamily),
                  keyboardType: TextInputType.emailAddress,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CupertinoColors.separator, width: 0.5),
                  ),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(
                      CupertinoIcons.mail_solid,
                      size: 20,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                  style: TextStyle(fontSize: 17, fontFamily: _fontFamily),
                  clearButtonMode: OverlayVisibilityMode.editing,
                ),
                const SizedBox(height: 12),

                // 2. CupertinoTextField - Contraseña
                CupertinoTextField(
                  controller: passwordController,
                  placeholder: 'Contraseña',
                  placeholderStyle: TextStyle(color: CupertinoColors.placeholderText, fontFamily: _fontFamily),
                  obscureText: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CupertinoColors.separator, width: 0.5),
                  ),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(
                      CupertinoIcons.lock_fill,
                      size: 20,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                  style: TextStyle(fontSize: 17, fontFamily: _fontFamily),
                  clearButtonMode: OverlayVisibilityMode.editing,
                ),
                const SizedBox(height: 20),

                // 3. CupertinoSwitch - Recordarme
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Recordarme',
                      style: TextStyle(
                        fontSize: 17,
                        color: CupertinoColors.label,
                        fontFamily: _fontFamily,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CupertinoSwitch(
                      value: _rememberMe,
                      activeColor: CupertinoColors.activeBlue,
                      thumbColor: CupertinoColors.white,
                      trackColor: CupertinoColors.systemFill,
                      onChanged: (value) => setState(() => _rememberMe = value),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // 4. CupertinoButton.filled - Iniciar sesión
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    borderRadius: BorderRadius.circular(8),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CupertinoActivityIndicator(
                            color: CupertinoColors.white,
                            radius: 12,
                          )
                        : Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white,
                              fontFamily: _fontFamily,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // 5. CupertinoActivityIndicator
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CupertinoActivityIndicator(radius: 20),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}