import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/app_bottom_nav.dart';
import 'widgets/app_background.dart';
class AdminWeeklyTaskScreen extends StatefulWidget {
  const AdminWeeklyTaskScreen({super.key});

  @override
  State<AdminWeeklyTaskScreen> createState() =>
      _AdminWeeklyTaskScreenState();
}

class _AdminWeeklyTaskScreenState
    extends State<AdminWeeklyTaskScreen> {

  final TextEditingController _taskController =
  TextEditingController();

  /// ✅ GET CLUB ID
  Future<String> getClubId() async {
    String uid =
        FirebaseAuth.instance.currentUser!.uid;

    var userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    return userDoc["clubId"];
  }

  /// ✅ ADD TASK
  Future<void> _addTask() async {

    if (_taskController.text.trim().isEmpty)
      return;

    String clubId = await getClubId();

    await FirebaseFirestore.instance
        .collection("clubs")
        .doc(clubId)
        .collection("weeklyTasks")
        .add({
      "title": _taskController.text.trim(),
      "isDone": false,
      "createdAt": Timestamp.now(),
    });

    _taskController.clear();
    Navigator.pop(context);
  }

  /// ✅ TOGGLE CHECKBOX
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

  /// ✅ DELETE
  Future<void> deleteTask(
      String clubId,
      String docId) async {

    await FirebaseFirestore.instance
        .collection("clubs")
        .doc(clubId)
        .collection("weeklyTasks")
        .doc(docId)
        .delete();
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
                child: CircularProgressIndicator());
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
                    child: CircularProgressIndicator());
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
                        color: const Color(0xFFF7D990),
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 24),
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

                          const Text(
                            "Admin Control Panel",
                            style: TextStyle(
                                color:
                                Color(0xFF8B7E66)),
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

                                return Dismissible(
                                  key:
                                  Key(doc.id),
                                  onDismissed:
                                      (_) =>
                                      deleteTask(
                                          clubId,
                                          doc.id),

                                  child: Container(
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
                                      BorderRadius.circular(
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
                                          ),
                                        ),

                                        const SizedBox(
                                            width:
                                            15),

                                        Expanded(
                                          child:
                                          Text(
                                            task[
                                            "title"],
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

                                        IconButton(
                                          icon:
                                          const Icon(
                                            Icons
                                                .delete_outline,
                                            color: Colors
                                                .redAccent,
                                            size:
                                            20,
                                          ),
                                          onPressed:
                                              () =>
                                              deleteTask(
                                                  clubId,
                                                  doc.id),
                                        )
                                      ],
                                    ),
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

      floatingActionButton:
      FloatingActionButton(
        backgroundColor:
        const Color(0xFFF7D990),
        child: const Icon(Icons.add,
            color:
            Color(0xFF432C1B)),
        onPressed:
        _showAddTaskDialog,
      ),

      // ================= NEW NAVIGATION =================
      bottomNavigationBar: const AppBottomNav(
        currentTab: AppTab.tasks,
        isAdmin: true,
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "No tasks created yet.\nTap + to assign a task.",
        textAlign: TextAlign.center,
        style: TextStyle(
            color:
            Color(0xFF8B7E66),
            fontSize: 16),
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
        const Color(0xFFFEF9E4),
        title:
        const Text("Create New Task"),
        content: TextField(
          controller:
          _taskController,
        ),
        actions: [
          TextButton(
              onPressed:
                  () =>
                  Navigator.pop(
                      context),
              child:
              const Text(
                  "Cancel")),
          ElevatedButton(
              onPressed:
              _addTask,
              child:
              const Text(
                  "Create"))
        ],
      ),
    );
  }

}