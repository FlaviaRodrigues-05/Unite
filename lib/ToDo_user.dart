import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/app_bottom_nav.dart';
import 'widgets/app_background.dart';
class UserWeeklyTaskScreen extends StatefulWidget {
  const UserWeeklyTaskScreen({super.key});

  @override
  State<UserWeeklyTaskScreen> createState() =>
      _UserWeeklyTaskScreenState();
}

class _UserWeeklyTaskScreenState
    extends State<UserWeeklyTaskScreen> {

  Future<String> getClubId() async {
    String uid =
        FirebaseAuth.instance.currentUser!.uid;

    var userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    return userDoc["clubId"];
  }

  Future<void> toggleTask(
      String clubId,
      String docId,
      bool current) async {

    await FirebaseFirestore.instance
        .collection("clubs")
        .doc(clubId)
        .collection("weeklyTasks")
        .doc(docId)
        .update({
      "isDone": !current
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,
            body: AppBackground(
        child: FutureBuilder<String>(
        future: getClubId(),
        builder: (context, clubSnap) {

          if (!clubSnap.hasData) {
            return const Center(
                child:
                CircularProgressIndicator());
          }

          String clubId = clubSnap.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("clubs")
                .doc(clubId)
                .collection("weeklyTasks")
                .orderBy("createdAt",
                descending: true)
                .snapshots(),

            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Center(
                    child:
                    CircularProgressIndicator());
              }

              final tasks =
                  snapshot.data!.docs;

              return Stack(
                children: [

                  Positioned(
                    top: -40,
                    right: -20,
                    child: Opacity(
                      opacity: 0.3,
                      child: Icon(
                        Icons.wb_sunny_outlined,
                        size: 180,
                        color:
                        const Color(0xFFF7D990),
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          const SizedBox(height: 50),

                          const Text(
                            "Weekly Tasks",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight:
                              FontWeight.bold,
                              color:
                              Color(0xFF432C1B),
                            ),
                          ),

                          const SizedBox(height: 30),

                          Expanded(
                            child: tasks.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                              itemCount:
                              tasks.length,
                              itemBuilder:
                                  (context,
                                  index) {

                                final doc =
                                tasks[index];

                                final task =
                                doc.data()
                                as Map<
                                    String,
                                    dynamic>;

                                return Container(
                                  margin:
                                  const EdgeInsets.only(
                                      bottom:
                                      14),
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal:
                                      18,
                                      vertical:
                                      20),
                                  decoration:
                                  BoxDecoration(
                                    color: Colors
                                        .transparent,
                                    border: Border.all(
                                        color:
                                        const Color(
                                            0xFF432C1B),
                                        width:
                                        1.2),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                        15),
                                  ),
                                  child: Row(
                                    children: [

                                      GestureDetector(
                                        onTap: () =>
                                            toggleTask(
                                                clubId,
                                                doc.id,
                                                task[
                                                "isDone"]),
                                        child:
                                        Icon(
                                          task[
                                          "isDone"]
                                              ? Icons
                                              .check_circle
                                              : Icons
                                              .circle_outlined,
                                          color:
                                          const Color(
                                              0xFF432C1B),
                                          size: 24,
                                        ),
                                      ),

                                      const SizedBox(
                                          width: 15),

                                      Expanded(
                                        child:
                                        Text(
                                          task["title"] ??
                                              "No Title",
                                          style:
                                          TextStyle(
                                            fontSize:
                                            17,
                                            color:
                                            const Color(
                                                0xFF432C1B),
                                            decoration:
                                            task["isDone"]
                                                ? TextDecoration
                                                .lineThrough
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      ),

      bottomNavigationBar: const AppBottomNav(
        currentTab: AppTab.tasks,
        isAdmin: false,
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "No tasks assigned for this week.",
        style: TextStyle(
            color:
            Color(0xFF8B7E66),
            fontSize: 16),
      ),
    );
  }
}