import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ToDo_admin.dart';
import 'ToDo_user.dart';
import 'dash_admin.dart';
import 'dash_mem.dart';
import 'firebase_options.dart';
import 'welcome_screen.dart';    // your first screen

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandDark = Color(0xFF1F2A37);
    const Color brandAccent = Color(0xFFF7D990);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Unite FP",
      theme: ThemeData(
        useMaterial3: true,
        // Professional type pairing:
        //  - Playfair Display: an elegant serif used only for headings/titles
        //  - Inter: a clean, highly-legible sans used everywhere else
        // Loaded via google_fonts so the intended fonts always render,
        // instead of silently falling back to the platform default when a
        // custom font family isn't bundled in pubspec.yaml.
        fontFamily: GoogleFonts.inter().fontFamily,
        scaffoldBackgroundColor: const Color(0xFFECE3D3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          primary: brandDark,
          secondary: brandAccent,
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: brandDark,
          ),
          headlineMedium: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: brandDark,
          ),
          titleLarge: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: brandDark,
          ),
          bodyLarge: GoogleFonts.inter(color: brandDark),
          bodyMedium: GoogleFonts.inter(color: brandDark),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: brandDark,
          centerTitle: true,
          titleTextStyle: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: brandDark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: brandDark,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      home: const WelcomeScreen(), // FIRST screen
    );
  }
}
