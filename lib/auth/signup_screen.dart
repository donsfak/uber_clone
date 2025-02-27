// ignore_for_file: body_might_complete_normally_catch_error, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Import du package
import 'package:uber_clone/auth/login_screen.dart';
import 'package:uber_clone/methods/common_methods.dart';
import 'package:uber_clone/screens/home_screen.dart';
import 'package:uber_clone/widgets/loading_dialog.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController =
      TextEditingController();
  CommonMethods cMethods = CommonMethods();
  // Vérifie si l'utilisateur est connecté à Internet
  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);

    signUpFormValidation();
  }

  signUpFormValidation() {
    if (userNameTextEditingController.text.trim().length < 3) {
      cMethods.displaySnackBar('Please enter your name', context);
    } else if (!emailTextEditingController.text.trim().contains('@')) {
      cMethods.displaySnackBar('Please enter your email', context);
    } else if (passwordTextEditingController.text.trim().length < 6) {
      cMethods.displaySnackBar('Please enter your password', context);
    } else if (userPhoneTextEditingController.text.trim().length < 10) {
      cMethods.displaySnackBar('Please enter your phone number', context);
    } else {
      registerNewUser();
    }
  }

  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  registerNewUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext context) =>
              LoadingDialog(messageText: "Account register..."),
    );

    final User? userFirebase =
        (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim(),
            )
            .catchError((errorMsg) {
              Navigator.pop(context);
              cMethods.displaySnackBar(errorMsg.toString(), context);
            })).user;

    if (!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(userFirebase!.uid);
    Map userDataMap = {
      "name": userNameTextEditingController.text.trim(),
      "email": emailTextEditingController.text.trim(),
      "phone": userPhoneTextEditingController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no",
    };
    userRef.set(userDataMap);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueAccent, Colors.purpleAccent],
          ),
        ),
        height:
            MediaQuery.of(
              context,
            ).size.height, // Prend toute la hauteur de l'écran
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _animation!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * _animation!.value),
                      child: child,
                    );
                  },
                  child: Image.asset('assets/images/logo.png', height: 120),
                ),
                const SizedBox(height: 20),
                const Text(
                      'Create a User\'s Account',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(
                      begin: -0.5,
                      end: 0,
                    ), // Animation avec flutter_animate
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      _buildTextField(
                            controller: userNameTextEditingController,
                            labelText: 'User Name',
                            icon: Icons.person,
                          )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideX(begin: -0.5, end: 0),
                      const SizedBox(height: 12),
                      _buildTextField(
                            controller: emailTextEditingController,
                            labelText: 'Email',
                            icon: Icons.email,
                          )
                          .animate()
                          .fadeIn(duration: 700.ms)
                          .slideX(begin: -0.5, end: 0),
                      const SizedBox(height: 12),
                      _buildTextField(
                            controller: passwordTextEditingController,
                            labelText: 'Password',
                            icon: Icons.lock,
                            obscureText: true,
                          )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .slideX(begin: -0.5, end: 0),
                      const SizedBox(height: 12),
                      _buildTextField(
                            controller: userPhoneTextEditingController,
                            labelText: 'Phone',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                          )
                          .animate()
                          .fadeIn(duration: 900.ms)
                          .slideX(begin: -0.5, end: 0),
                      const SizedBox(height: 20),
                      ElevatedButton(
                            onPressed: () {
                              checkIfNetworkIsAvailable();
                              //print('Checking Network');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.purple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 100,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 1000.ms)
                          .slideY(begin: 0.5, end: 0),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Utilisation de PageRouteBuilder pour une transition personnalisée
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                LoginScreen(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: const Text(
                    'Already have an Account? Login Here.',
                    style: TextStyle(color: Colors.white),
                  ),
                ).animate().fadeIn(duration: 1100.ms).slideY(begin: 0.5, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        // ignore: deprecated_member_use
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
