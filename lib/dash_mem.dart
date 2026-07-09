import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/app_bottom_nav.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/app_background.dart';
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageMemberState();
}

class _DashboardPageMemberState extends State<DashboardPage> {
  /// ================= DATA =================
  String memberName = "";
  String role = "";
  String clubName = "";
  String clubCode = "";
  int totalMembers = 0;

  String announcementTitle = "Checking...";
  String announcementSubtitle = "";

  String eventTitle = "Checking...";
  String eventSubtitle = "";

  Stream<QuerySnapshot>? taskStream;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  /// ================= FIREBASE =================
  Future<void> loadDashboardData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userDoc =
    await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (!userDoc.exists) return;

    final userData = userDoc.data()!;

    memberName = userData["name"] ?? "";
    role = userData["role"] ?? "";
    String clubId = userData["clubId"];

    final clubDoc =
    await FirebaseFirestore.instance.collection("clubs").doc(clubId).get();

    if (clubDoc.exists) {
      final clubData = clubDoc.data()!;
      clubName = clubData["clubName"] ?? "";
      clubCode = clubData["clubCode"] ?? "";
    }

    final members = await FirebaseFirestore.instance
        .collection("users")
        .where("clubId", isEqualTo: clubId)
        .get();

    totalMembers = members.docs.length;

    final ann = await FirebaseFirestore.instance
        .collection("clubs")
        .doc(clubId)
        .collection("announcements")
        .limit(1)
        .get();

    if (ann.docs.isNotEmpty) {
      announcementTitle = "Check out new announcement!";
      announcementSubtitle = "A new announcement was posted";
    } else {
      announcementTitle = "No new announcement";
      announcementSubtitle = "You're all caught up";
    }

    final event = await FirebaseFirestore.instance
        .collection("clubs")
        .doc(clubId)
        .collection("events")
        .limit(1)
        .get();

    if (event.docs.isNotEmpty) {
      eventTitle = "Upcoming Event";
      eventSubtitle = "New event scheduled";
    } else {
      eventTitle = "No upcoming events";
      eventSubtitle = "Stay tuned";
    }

    /// REALTIME TASK STREAM
    taskStream = FirebaseFirestore.instance
        .collection("clubs")
        .doc(clubId)
        .collection("weeklyTasks")
        .snapshots();

    setState(() {});
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFFEF9E4);
    const Color accentYellow = Color(0xFFF7D990);

    return Scaffold(
      backgroundColor: Colors.transparent,
            body: AppBackground(
        child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome,",
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "$memberName ($role)",
                        style: const TextStyle(
                            fontSize: 18, color: Colors.black54),
                      ),
                    ],
                  ),
                  const ProfileAvatar(radius: 35),
                ],
              ),
              const SizedBox(height: 35),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 140,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: accentYellow,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clubName,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "#$clubCode",
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_alt_rounded),
                          const SizedBox(height: 8),
                          Text(
                            totalMembers.toString(),
                            style: const TextStyle(
                                fontSize: 34, fontWeight: FontWeight.bold),
                          ),
                          const Text("Members",
                              style:
                              TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),

              /// ✅ UPDATED TASK BAR UI
              StreamBuilder<QuerySnapshot>(
                stream: taskStream,
                builder: (context, snapshot) {
                  double progress = 0;
                  int total = 0;
                  int completed = 0;

                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    final docs = snapshot.data!.docs;
                    total = docs.length;
                    completed = docs.where((t) => t["isDone"] == true).length;
                    progress = completed / total;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Task Progress",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${(progress * 100).toInt()}%",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 18,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) => AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: constraints.maxWidth * progress,
                                decoration: BoxDecoration(
                                  color: accentYellow,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$completed of $total tasks completed",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),
              Text(
                "Latest Updates",
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _notificationTile(Icons.campaign_rounded, announcementTitle,
                  announcementSubtitle),
              const SizedBox(height: 12),
              _notificationTile(Icons.event_available_rounded, eventTitle,
                  eventSubtitle),
            ],
          ),
        ),
      ),
      ),
      bottomNavigationBar: const AppBottomNav(
        currentTab: AppTab.home,
        isAdmin: false,
      ),
    );
  }

  Widget _notificationTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}