import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/app_bottom_nav.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/app_background.dart';
import 'welcome_screen.dart';   // ✅ Correct file

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() =>
      _SettingsPageAdminState();
}

class _SettingsPageAdminState
    extends State<SettingsPage> {
  final Color bgColor = const Color(0xFFFFF8E6);
  final Color cardColor = const Color(0xFFE5DED0);

  final currentUser =
      FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
            body: AppBackground(
        child: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Text(
                'Settings',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2A37),
                ),
              ),
              const SizedBox(height: 40),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore
                    .instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child:
                        CircularProgressIndicator());
                  }

                  var userData =
                  snapshot.data!.data()
                  as Map<String, dynamic>;

                  String name =
                      userData['name'] ?? '';
                  String email =
                      userData['email'] ?? '';
                  String role =
                      userData['role'] ?? 'Admin';
                  String clubId =
                      userData['clubId'] ?? '';

                  return Column(
                    children: [
                      Container(
                        padding:
                        const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius:
                          BorderRadius.circular(
                              28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(
                                  alpha: 0.1),
                              blurRadius: 15,
                              offset:
                              const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const ProfileAvatar(radius: 48),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                mainAxisSize:
                                MainAxisSize.min,
                                children: [
                                  Text(
                                    name,
                                    style:
                                    const TextStyle(
                                      fontSize: 22,
                                      fontWeight:
                                      FontWeight.bold,
                                      color: Color(
                                          0xFF1F2A37),
                                    ),
                                    overflow:
                                    TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                          Icons.email_outlined,
                                          size: 14),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          email,
                                          style:
                                          const TextStyle(
                                            fontSize: 14,
                                            decoration:
                                            TextDecoration
                                                .underline,
                                          ),
                                          overflow:
                                          TextOverflow
                                              .ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    role,
                                    style:
                                    const TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                      FontWeight.w500,
                                      color:
                                      Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120),
                      _buildSettingButton(
                          'Leave club/committee',
                              () => _leaveClub(clubId)),
                      const SizedBox(height: 24),
                      _buildSettingButton(
                          'Log Out', _logout),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      ),
      bottomNavigationBar: const AppBottomNav(
        currentTab: AppTab.settings,
        isAdmin: false,
      ),
    );
  }

  // ================= LEAVE CLUB =================
  Future<void> _leaveClub(
      String clubId) async {
    var adminCount =
    await FirebaseFirestore.instance
        .collection('users')
        .where('clubId',
        isEqualTo: clubId)
        .where('role',
        isEqualTo: 'admin')
        .get();

    if (adminCount.docs.length <= 1) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
            content: Text(
                "Assign another admin before leaving.")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .update({
      "clubId": null,
      "role": "member"
    });

    // ✅ Redirect to WelcomeScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (_) =>
          const WelcomeScreen()),
          (route) => false,
    );
  }

  // ================= LOGOUT =================
  Future<void> _logout() async {
    await FirebaseAuth.instance
        .signOut();

    // ✅ Redirect to WelcomeScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (_) =>
          const WelcomeScreen()),
          (route) => false,
    );
  }

  Widget _buildSettingButton(
      String text,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(15),
          border: Border.all(
              color: Colors.black,
              width: 1.5),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight:
              FontWeight.w600,
              color:
              Color(0xFF1F2A37),
            ),
          ),
        ),
      ),
    );
  }
}