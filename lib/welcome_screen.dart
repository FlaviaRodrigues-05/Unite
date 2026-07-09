import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unite_fp/signup_screen.dart';
import 'login_screen.dart';
import 'widgets/app_background.dart';
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Used the 'size' variable here to set the image height, resolving the 'unused' warning
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // ================= TEXT SECTION =================
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -1.5,
                    height: 1.1,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children:  [
                    Text(
                      "To ",
                      style: TextStyle(
                        fontSize: 58,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      "Unîte",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF4A2F1B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "because teamwork deserves better tools.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ), // Added missing comma here

            const Spacer(flex: 2),

            // ================= BUTTON SECTION =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  // Log In Button
                  _buildActionButton(
                    text: "Log in",
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                  ),

                  const SizedBox(height: 16),

                  // Divider OR Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(thickness: 1, color: Colors.black54, indent: 20)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            // Fixed deprecated withOpacity to withValues
                            color: Colors.black.withValues(alpha: 0.7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(thickness: 1, color: Colors.black54, endIndent: 20)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Sign Up Button
                  _buildActionButton(
                    text: "Sign up",
                    onPressed: () {
                      // Ensure SignupChoiceScreen is imported correctly
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupChoiceScreen()));
                    },
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // ================= IMAGE SECTION =================
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                // Using 'size' to ensure the image takes up appropriate space
                height: size.height * 0.25,
                child: Image.asset(
                  'assets/images/teamwork.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // Helper method for identical buttons
  Widget _buildActionButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: 280,
      height: 65,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8FA876), // Sage green
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
            side: const BorderSide(color: Colors.black12, width: 1),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}