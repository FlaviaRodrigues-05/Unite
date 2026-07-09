import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/app_bottom_nav.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/app_background.dart';
class DashboardPageAdmin extends StatefulWidget {
  const DashboardPageAdmin({super.key});

  @override
  State<DashboardPageAdmin> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPageAdmin> {
  // ================= FIREBASE DATA =================
  String adminName = "";
  String clubName = "";
  String clubCode = "";
  int memberCount = 0;
  String announcementTitle = "Checking...";
  String announcementSubtitle = "";

  String eventTitle = "Checking...";
  String eventSubtitle = "";

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  // ================= FIXED FIREBASE FUNCTION =================
  Future<void> loadDashboardData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final uid = currentUser.uid;

      /// 1️⃣ Get Admin User
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      adminName = userData["name"] ?? "";

      String clubCodeFromUser = userData["clubCode"] ?? "";
      if (clubCodeFromUser.isEmpty) return;

      /// 2️⃣ Find club by clubCode
      final clubQuery = await FirebaseFirestore.instance
          .collection("clubs")
          .where("clubCode", isEqualTo: clubCodeFromUser)
          .limit(1)
          .get();

      if (clubQuery.docs.isEmpty) return;

      final clubDoc = clubQuery.docs.first;
      final clubData = clubDoc.data();
      final clubId = clubDoc.id;

      clubName = clubData["clubName"] ?? "";
      clubCode = clubData["clubCode"] ?? "";

      /// 3️⃣ Count Members
      final membersSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("clubId", isEqualTo: clubId)
          .get();

      memberCount = membersSnapshot.docs.length;

      /// 4️⃣ Latest Announcement (Dynamic Logic)
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

      /// 5️⃣ Latest Event (Dynamic Logic)
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

      setState(() {});
    } catch (e) {
      print("Dashboard error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFFEF9E4);
    const Color accentYellow = Color(0xFFF7D990);

    return Scaffold(
      backgroundColor: Colors.transparent,
            body: AppBackground(
        child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 35),

              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: _buildHighEndClubCard(accentYellow)),
                  const SizedBox(width: 12),
                  Expanded(
                      flex: 1,
                      child: _buildHighEndMembersCard(accentYellow)),
                ],
              ),

              const SizedBox(height: 40),

              /// ✅ RESTORED THE IMAGE AS REQUESTED
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Image.asset(
                    'assets/images/dash.png',
                    height: 280,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Text(
                "Latest Updates",
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              /// ✅ DYNAMIC NOTIFICATION TILES
              _buildNotificationTile(
                icon: Icons.campaign_rounded,
                title: announcementTitle,
                subtitle: announcementSubtitle,
              ),

              const SizedBox(height: 12),

              _buildNotificationTile(
                icon: Icons.event_available_rounded,
                title: eventTitle,
                subtitle: eventSubtitle,
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      ),
      bottomNavigationBar: const AppBottomNav(
        currentTab: AppTab.home,
        isAdmin: true,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome,",
                style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold)),
            Text(
              adminName,
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black54),
            ),
          ],
        ),
        const ProfileAvatar(radius: 35),
      ],
    );
  }

  Widget _buildHighEndClubCard(Color yellow) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: yellow,
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
                fontSize: 24,
                fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "#$clubCode",
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighEndMembersCard(Color yellow) {
    return Container(
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
          Text("$memberCount",
              style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold)),
          const Text("Members",
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}