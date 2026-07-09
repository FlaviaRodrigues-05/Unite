import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dash_admin.dart';
import 'widgets/app_background.dart';
class SignupCreateClubScreen extends StatefulWidget {
  const SignupCreateClubScreen({super.key});

  @override
  State<SignupCreateClubScreen> createState() =>
      _SignupCreateClubScreenState();
}

class _SignupCreateClubScreenState
    extends State<SignupCreateClubScreen> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final clubNameController = TextEditingController();

  String generateClubCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rand = Random();
    return List.generate(6, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> createClub() async {
    try {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }

      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      print("✅ Firebase Auth Success");
      print("UID: ${userCredential.user!.uid}");

      String uid = userCredential.user!.uid;
      String clubCode = generateClubCode();

      print("➡️ Creating club...");

      await FirebaseFirestore.instance.collection("clubs").doc(uid).set({
        "clubName": clubNameController.text.trim(),
        "clubCode": clubCode,
        "createdBy": uid,
        "createdAt": Timestamp.now(),
      });

      print("✅ Club created");

      print("➡️ Creating user document...");

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "role": "admin",
        "clubCode": clubCode,
        "clubId": uid,
      });

      print("✅ User document created");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardPageAdmin(),
        ),
      );

    }
    catch (e) {
      print("❌ ERROR:");
      print(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
            body: AppBackground(
        child: Stack(
        children: [

          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/vectors/top_curve.png',
              width: size.width * 0.45,
            ),
          ),

          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/vectors/bottom_curve.png',
              width: size.width * 0.45,
            ),
          ),

          Center(
            child: Container(
              width: size.width * 0.84,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 26,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Center(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Center(
                      child: Text(
                        "Create a Club",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    _label("Name"),
                    _InputField(
                      icon: 'assets/icons/user.png',
                      controller: nameController,
                    ),

                    const SizedBox(height: 14),

                    _label("Email"),
                    _InputField(
                      icon: 'assets/icons/email.png',
                      controller: emailController,
                    ),

                    const SizedBox(height: 14),

                    _label("Password"),
                    _InputField(
                      icon: 'assets/icons/lock_off.png',
                      obscure: true,
                      controller: passwordController,
                    ),

                    const SizedBox(height: 14),

                    _label("Confirm Password"),
                    _InputField(
                      icon: 'assets/icons/lock.png',
                      obscure: true,
                      controller: confirmPasswordController,
                    ),

                    const SizedBox(height: 14),

                    _label("Club/Committee Name"),
                    _InputField(
                      icon: 'assets/icons/edit.png',
                      controller: clubNameController,
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: createClub,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A2414),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          "Sign up",
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
          ),
        ],
      ),
      ),
    );
  }

  static Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.black87,
      ),
    );
  }
}

// ================= INPUT FIELD =================

class _InputField extends StatelessWidget {
  final String icon;
  final bool obscure;
  final TextEditingController controller;

  const _InputField({
    required this.icon,
    required this.controller,
    this.obscure = false,
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
          Image.asset(
            icon,
            width: 18,
            height: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
