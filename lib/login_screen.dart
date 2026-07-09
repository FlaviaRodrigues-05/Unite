import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dash_admin.dart';
import 'dash_mem.dart';
import 'widgets/app_background.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _loading = false;

  // ================= LOGIN FUNCTION =================
  void _login() async {
    setState(() => _loading = true);

    try {
      // ✅ Firebase Login
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      String uid = userCredential.user!.uid;

      // ✅ Fetch user role from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        throw Exception("User data not found");
      }

      String role = userDoc["role"];

      // ✅ Navigate based on role
      if (role == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardPageAdmin(),
          ),
        );
      } else if (role == "member") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardPage(),
          ),
        );
      } else {
        throw Exception("Invalid user role");
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
            body: AppBackground(
        child: Stack(
        children: [

          // TOP VECTOR
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/vectors/top_curve.png',
              width: size.width * 0.45,
            ),
          ),

          // BOTTOM VECTOR
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/vectors/bottom_curve.png',
              width: size.width * 0.45,
            ),
          ),

          // MAIN CARD
          Center(
            child: Container(
              width: size.width * 0.82,
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text("Email",
                      style:
                      TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 6),

                  _InputField(
                    controller: _emailController,
                    iconPath: 'assets/icons/email.png',
                    hint: 'Enter your email',
                    obscure: false,
                  ),

                  const SizedBox(height: 16),

                  const Text("Password",
                      style:
                      TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 6),

                  _InputField(
                    controller: _passwordController,
                    iconPath: 'assets/icons/lock.png',
                    hint: 'Enter your password',
                    obscure: true,
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: _loading
                        ? const Center(
                      child: CircularProgressIndicator(),
                    )
                        : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF3A2414),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ================= INPUT FIELD =================
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String iconPath;
  final String hint;
  final bool obscure;

  const _InputField({
    required this.controller,
    required this.iconPath,
    required this.hint,
    required this.obscure,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE6DECC),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Image.asset(iconPath, width: 18, height: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}