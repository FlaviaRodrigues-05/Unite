import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_announcement.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/app_background.dart';
class AnnouncementsAdmin extends StatefulWidget {
  const AnnouncementsAdmin({super.key});

  @override
  State<AnnouncementsAdmin> createState() =>
      _AnnouncementsAdminState();
}

class _AnnouncementsAdminState
    extends State<AnnouncementsAdmin> {

  /// ================= GET CLUB ID =================
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
        child: Stack(
          children: [

            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: const EdgeInsets.only(
                      left: 24,
                      top: 40,
                      bottom: 20),
                  child: Text(
                    'Anouncements',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 40,
                      fontWeight:
                      FontWeight.bold,
                      color:
                      const Color(0xFF1A2E35),
                    ),
                  ),
                ),

                Expanded(
                  child: FutureBuilder<String>(
                    future: getClubId(),
                    builder:
                        (context, clubSnap) {

                      if (!clubSnap.hasData) {
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
                                24),
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
                                    1.2,
                                    width:
                                    double
                                        .infinity,
                                    color: Colors
                                        .black
                                        .withOpacity(
                                        0.5),
                                    margin:
                                    const EdgeInsets.symmetric(
                                        vertical:
                                        4),
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

            Positioned(
              right: 24,
              bottom: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const AddAnnouncementScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration:
                  const BoxDecoration(
                    color:
                    Color(0xFF75544C),
                    shape:
                    BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color:
                    Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),

      bottomNavigationBar: const AppBottomNav(
        currentTab: AppTab.announcements,
        isAdmin: true,
      ),
    );
  }
}

/// ================= CARD UI (UNCHANGED) =================
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
          vertical: 10),
      height: 90,
      decoration:
      BoxDecoration(
        color:
        const Color(
            0xFFE5DED0),
        borderRadius:
        BorderRadius
            .circular(25),
      ),
      child: Align(
        alignment:
        Alignment
            .centerLeft,
        child: Padding(
          padding:
          const EdgeInsets
              .only(
              left: 20),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 10,
                backgroundColor:
                Color(
                    0xFF4A2C2A),
              ),
              const SizedBox(
                  width: 15),
              Expanded(
                  child:
                  Text(text)),
            ],
          ),
        ),
      ),
    );
  }
}