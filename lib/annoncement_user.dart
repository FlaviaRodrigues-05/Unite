import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/app_bottom_nav.dart';
import 'widgets/app_background.dart';
class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() =>
      _AnnouncementsPageState();
}

class _AnnouncementsPageState
    extends State<AnnouncementsPage> {

  Future<String> getClubId() async {

    String uid =
        FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot userDoc =
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    return userDoc["clubId"];
  }

  @override
  Widget build(BuildContext context) {

    const Color bgColor = Color(0xFFFEF9E4);

    return Scaffold(
      backgroundColor: Colors.transparent,
            body: AppBackground(
        child: SafeArea(
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            Padding(
              padding:
              const EdgeInsets.only(
                  left: 20,
                  top: 40,
                  bottom: 10),
              child: Text(
                'Anouncements',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 42,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  const Color(0xFF1A2E35),
                ),
              ),
            ),

            Expanded(
              child:
              FutureBuilder<String>(
                future:
                getClubId(),
                builder:
                    (context,
                    clubSnap) {

                  if (!clubSnap
                      .hasData) {
                    return const Center(
                        child:
                        CircularProgressIndicator());
                  }

                  return StreamBuilder<
                      QuerySnapshot>(
                    stream:
                    FirebaseFirestore
                        .instance
                        .collection(
                        "clubs")
                        .doc(
                        clubSnap
                            .data)
                        .collection(
                        "announcements")
                        .orderBy(
                        "createdAt",
                        descending:
                        true)
                        .snapshots(),
                    builder:
                        (context,
                        snapshot) {

                      if (!snapshot
                          .hasData) {
                        return const Center(
                            child:
                            CircularProgressIndicator());
                      }

                      final docs =
                          snapshot
                              .data!
                              .docs;

                      return ListView
                          .builder(
                        padding:
                        const EdgeInsets
                            .symmetric(
                            horizontal:
                            20),
                        itemCount:
                        docs.length,
                        itemBuilder:
                            (context,
                            index) {

                          final data =
                          docs[index]
                              .data()
                          as Map<
                              String,
                              dynamic>;

                          final announcementText =
                              data[
                              "text"] ??
                                  data[
                                  "announcement"] ??
                                  data[
                                  "title"] ??
                                  "No Announcement";

                          return Column(
                            children: [
                              AnnouncementCard(
                                  text:
                                  announcementText),
                              Container(
                                height:
                                1.5,
                                width:
                                double
                                    .infinity,
                                color: Colors
                                    .black
                                    .withOpacity(
                                    0.4),
                                margin:
                                const EdgeInsets
                                    .symmetric(
                                    vertical:
                                    2),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),

      bottomNavigationBar: const AppBottomNav(
        currentTab: AppTab.announcements,
        isAdmin: false,
      ),
    );
  }
}

/// ===== CARD UI (UNCHANGED) =====
class AnnouncementCard
    extends StatelessWidget {

  final String text;

  const AnnouncementCard(
      {super.key,
        required this.text});

  @override
  Widget build(
      BuildContext context) {
    return Container(
      margin:
      const EdgeInsets
          .symmetric(
          vertical: 12),
      padding:
      const EdgeInsets
          .all(28),
      decoration:
      BoxDecoration(
        color: const Color(
            0xFFE5DED0),
        borderRadius:
        BorderRadius
            .circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 12,
            backgroundColor:
            Color(
                0xFF4A2C2A),
          ),
          const SizedBox(
              width: 20),
          Expanded(
            child: Text(
              text,
              style:
              const TextStyle(
                fontWeight:
                FontWeight
                    .w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}