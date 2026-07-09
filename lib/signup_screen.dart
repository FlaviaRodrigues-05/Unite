import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/app_background.dart';
import 'package:unite_fp/signup_join_club.dart'; // Restored original import
import 'signup_create_club_screen.dart';        // Restored original import

class SignupChoiceScreen extends StatelessWidget {
  const SignupChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using LayoutBuilder or MediaQuery to ensure responsiveness
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
            body: AppBackground(
        child: SafeArea(
        child: Center( // Centers the entire content horizontally
          child: SingleChildScrollView( // Prevents overflow on smaller devices
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centers content vertically
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // ===== TITLE =====
                Text(
                  "Unite",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 42, // Adjusted for proper sizing
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF4A2F1B),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Manage. Connect. Unite.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 48),

                // ===== CREATE CLUB CARD =====
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupCreateClubScreen(),
                      ),
                    );
                  },
                  child: _OptionCard(
                    text: "Create\nA Club",
                    imagePath: "assets/images/create_club.png",
                  ),
                ),

                const SizedBox(height: 24),

                // ===== JOIN CLUB CARD =====
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupJoinClub(),
                      ),
                    );
                  },
                  child: _OptionCard(
                    text: "Join\nA Club",
                    imagePath: "assets/images/join_club.png",
                    reverse: true, // Swapping text/image to match your screenshot layout
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String text;
  final String imagePath;
  final bool reverse;

  const _OptionCard({
    required this.text,
    required this.imagePath,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width * 0.88,
      height: 190, // Set height to ensure characters have room
      padding: const EdgeInsets.all(20), // Padding ensures no edge overlap
      decoration: BoxDecoration(
        color: const Color(0xFFFFE09A),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        // Allows us to flip the image to the left side like in your 'Join' card
        textDirection: reverse ? TextDirection.rtl : TextDirection.ltr,
        children: [
          // Text section
          Expanded(
            flex: 3,
            child: Text(
              text,
              textAlign: reverse ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                fontSize: 30, // Proper sizing as requested
                fontWeight: FontWeight.w900,
                color: Colors.black,
                height: 1.1,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Image section
          Expanded(
            flex: 2,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}