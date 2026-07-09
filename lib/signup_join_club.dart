import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dash_mem.dart';
import 'widgets/app_background.dart';
class SignupJoinClub extends StatefulWidget {
  const SignupJoinClub({super.key});

  @override
  State<SignupJoinClub> createState() => _SignupJoinClubState();
}

class _SignupJoinClubState extends State<SignupJoinClub> {
  // ===== CONTROLLERS =====
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _clubCodeController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _loading = false;

  // ===== SIGN UP FUNCTION =====
  void _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final clubCode = _clubCodeController.text.trim(); // remove extra spaces

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        clubCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      print("Checking club code: '$clubCode'");

      // 1️⃣ Verify club code
      QuerySnapshot clubQuery = await FirebaseFirestore.instance
          .collection("clubs")
          .where("clubCode", isEqualTo: clubCode) // <-- matches Firestore field
          .get();

      print("Found clubs: ${clubQuery.docs.length}");

      if (clubQuery.docs.isEmpty) {
        throw Exception("Invalid club code");
      }

      String clubId = clubQuery.docs.first.id;

      // 2️⃣ Create Firebase Auth user
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // 3️⃣ Create Firestore user document
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "name": name,
        "email": email,
        "role": "member",
        "clubId": clubId,
        "joinedAt": FieldValue.serverTimestamp(),
      });

      // ✅ Navigate to Member Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Sign up failed')),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _clubCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
            body: AppBackground(
        child: Stack(
        children: [
          // ===== TOP VECTOR =====
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/vectors/top_curve.png',
              width: size.width * 0.45,
            ),
          ),
          // ===== BOTTOM VECTOR =====
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/vectors/bottom_curve.png',
              width: size.width * 0.45,
            ),
          ),

          // ===== MAIN CARD =====
          Center(
            child: Container(
              width: size.width * 0.84,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== TITLE =====
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
                        "Join a club",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 26),

                    _label("Name"),
                    _InputField(controller: _nameController, icon: 'assets/icons/user.png'),

                    const SizedBox(height: 14),
                    _label("Email"),
                    _InputField(controller: _emailController, icon: 'assets/icons/email.png'),

                    const SizedBox(height: 14),
                    _label("Password"),
                    _InputField(controller: _passwordController, icon: 'assets/icons/lock_off.png', obscure: true),

                    const SizedBox(height: 14),
                    _label("Confirm Password"),
                    _InputField(controller: _confirmPasswordController, icon: 'assets/icons/lock.png', obscure: true),

                    const SizedBox(height: 14),
                    _label("Club/Committee Code"),
                    _InputField(controller: _clubCodeController, icon: 'assets/icons/edit.png'),

                    const SizedBox(height: 28),

                    // ===== SIGN UP BUTTON =====
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: _signUp,
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

  static Widget _label(String text) => Text(
    text,
    style: const TextStyle(fontSize: 13, color: Colors.black87),
  );
}

// ================= INPUT FIELD =================
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String icon;
  final bool obscure;

  const _InputField({
    required this.controller,
    required this.icon,
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
          Image.asset(icon, width: 18, height: 18),
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
