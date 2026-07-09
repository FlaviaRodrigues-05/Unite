import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/app_bottom_nav.dart';
import 'widgets/app_background.dart';
class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final DateTime today = DateTime.now();
  String? clubId;
  List<Map<String, dynamic>> allEvents = [];

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc =
    await FirebaseFirestore.instance.collection("users").doc(uid).get();

    clubId = userDoc["clubId"];

    FirebaseFirestore.instance
        .collection("clubs")
        .doc(clubId)
        .collection("events")
        .orderBy("date")
        .snapshots()
        .listen((snapshot) {
      allEvents = snapshot.docs.map((e) => e.data()).toList();
      setState(() {});
    });
  }

  List<DateTime> getDates() => List.generate(
    14,
        (index) =>
        today.subtract(const Duration(days: 3)).add(Duration(days: index)),
  );

  bool hasEvent(DateTime date) {
    return allEvents.any((event) {
      if (event["date"] == null) return false;

      DateTime d = (event["date"] as Timestamp).toDate();
      return d.day == date.day &&
          d.month == date.month &&
          d.year == date.year;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dates = getDates();

    final todayEvents = allEvents.where((event) {
      if (event["date"] == null) return false;

      DateTime d = (event["date"] as Timestamp).toDate();
      return d.day == today.day &&
          d.month == today.month &&
          d.year == today.year;
    }).toList();

    final upcomingEvents = allEvents.where((event) {
      if (event["date"] == null) return false;

      DateTime d = (event["date"] as Timestamp).toDate();
      return d.isAfter(today);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
            bottomNavigationBar: const AppBottomNav(
        currentTab: AppTab.events,
        isAdmin: false,
      ),
      body: AppBackground(
        child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              "assets/vectors/top_circles.png",
              width: 230,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),
                  Text(
                    "Events",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2A37),
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildDateScroller(dates),

                  const SizedBox(height: 25),
                  const Text(
                    "Scheduled Today",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2A37)),
                  ),
                  const SizedBox(height: 15),

                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildDynamicTimeSlot("08.00", todayEvents),
                        _buildDynamicTimeSlot("10.00", todayEvents),
                        _buildDynamicTimeSlot("12.00", todayEvents),
                        _buildDynamicTimeSlot("14.00", todayEvents),

                        const SizedBox(height: 30),

                        const Text(
                          "Upcoming Events",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 15),

                        ...upcomingEvents.map((event) {
                          DateTime d =
                          (event["date"] as Timestamp).toDate();
                          return _buildUpcomingCard(
                            DateFormat('dd MMM').format(d),
                            event["name"] ?? "Event",
                            "${event["fromTime"]} - ${event["toTime"]}",
                          );
                        }),

                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  // ✅ DATE SCROLLER
  Widget _buildDateScroller(List<DateTime> dates) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];

          bool isToday =
              date.day == today.day && date.month == today.month;

          bool eventExists = hasEvent(date);

          return Container(
            margin: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                Container(
                  width: 58,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.white.withOpacity(0.4)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('dd').format(date),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEE')
                            .format(date)
                            .substring(0, 2),
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                if (eventExists)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ FIXED DYNAMIC SLOT
  Widget _buildDynamicTimeSlot(
      String timeLabel, List<Map<String, dynamic>> events) {

    int slotHour = int.parse(timeLabel.split('.')[0]);

    final eventsAtTime = events.where((e) {
      if (e["fromTime"] == null) return false;

      try {
        DateTime parsedTime =
        DateFormat("hh:mm a").parse(e["fromTime"]);
        return parsedTime.hour == slotHour;
      } catch (e) {
        return false;
      }
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 55,
            child: Text(timeLabel,
                style: const TextStyle(
                    color: Colors.black45, fontSize: 14)),
          ),
          Expanded(
            child: eventsAtTime.isNotEmpty
                ? Column(
              children: eventsAtTime.map((event) {
                return Container(
                  margin:
                  const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8FA178),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Text(
                    event["name"] ?? "Event",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
            )
                : Container(
              height: 2,
              color: Colors.black12,
            ),
          )
        ],
      ),
    );
  }

  // ✅ UPCOMING CARD
  Widget _buildUpcomingCard(
      String date, String title, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D231A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE4BC92),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month,
                color: Color(0xFF2D231A), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(date,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13)),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(time,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
