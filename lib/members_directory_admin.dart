import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/app_bottom_nav.dart';
import 'widgets/app_background.dart';
class MemberDirectoryAdmin extends StatefulWidget {
  const MemberDirectoryAdmin({super.key});

  @override
  State<MemberDirectoryAdmin> createState() =>
      _MemberDirectoryAdminState();
}

class _MemberDirectoryAdminState
    extends State<MemberDirectoryAdmin> {

  String searchQuery = "";
  final TextEditingController _searchController =
  TextEditingController();

  final Color bgColor = const Color(0xFFFEF9E4);
  final Color containerColor = const Color(0xFFE5DED0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
            body: AppBackground(
        child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
              const EdgeInsets.only(left: 24.0, top: 40, bottom: 20),
              child: Text(
                "Member’s\nDirectory",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ),

            Expanded(
              child: Container(
                margin:
                const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.45),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30)),
                  border:
                  Border.all(color: Colors.white.withOpacity(0.6), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A2F1B).withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    /// SEARCH BAR
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.75),
                          borderRadius:
                          BorderRadius.circular(25),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.9)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4A2F1B).withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              searchQuery =
                                  value.toLowerCase();
                            });
                          },
                          decoration:
                          const InputDecoration(
                            hintText: "Search...",
                            prefixIcon: Icon(
                                Icons.search,
                                color: Colors.black54),
                            border: InputBorder.none,
                            contentPadding:
                            EdgeInsets.symmetric(
                                vertical: 10),
                          ),
                        ),
                      ),
                    ),

                    const Divider(
                        color: Colors.black87,
                        thickness: 1.2,
                        height: 1),

                    /// 🔥 UPDATED LOGIC (ONLY THIS PART CHANGED)
                    Expanded(
                      child: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth
                            .instance.currentUser!.uid)
                            .get(),
                        builder: (context, adminSnapshot) {
                          if (!adminSnapshot.hasData) {
                            return const Center(
                                child:
                                CircularProgressIndicator());
                          }

                          final adminData =
                          adminSnapshot.data!.data()
                          as Map<String, dynamic>;

                          final String clubId =
                          adminData['clubId'];

                          return StreamBuilder<
                              QuerySnapshot>(
                            stream: FirebaseFirestore
                                .instance
                                .collection('users')
                                .where('clubId',
                                isEqualTo: clubId)
                                .snapshots(),
                            builder:
                                (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child:
                                    CircularProgressIndicator());
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs
                                      .isEmpty) {
                                return const Center(
                                    child: Text(
                                        "No Users Found"));
                              }

                              final users = snapshot
                                  .data!.docs
                                  .where((doc) {
                                String name =
                                doc['name']
                                    .toString()
                                    .toLowerCase();
                                return name.contains(
                                    searchQuery);
                              }).toList();

                              if (users.isEmpty) {
                                return const Center(
                                    child: Text(
                                        "No matching members"));
                              }

                              return ListView.builder(
                                itemCount:
                                users.length,
                                itemBuilder:
                                    (context, index) {
                                  var user =
                                  users[index];
                                  return _buildUserTile(
                                    user['name'],
                                    user['email'],
                                    user['role'],
                                    user.id,
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
          ],
        ),
      ),
      ),

      bottomNavigationBar: const AppBottomNav(
        currentTab: AppTab.members,
        isAdmin: true,
      ),
    );
  }

  /// USER TILE
  Widget _buildUserTile(
      String name,
      String email,
      String role,
      String docId) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 20, horizontal: 16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor:
                Color(0xFF9BA6B3),
                child: Icon(Icons.person,
                    size: 50,
                    color: Colors.white),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(email,
                        style: const TextStyle(
                            fontSize: 13,
                            decoration:
                            TextDecoration
                                .underline)),
                    const SizedBox(height: 4),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4),
                      decoration: BoxDecoration(
                        color: role == "admin"
                            ? Colors.orange
                            : Colors.grey,
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: Text(
                        role,
                        style:
                        const TextStyle(
                            color: Colors.white,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == "remove") {
                    await FirebaseFirestore
                        .instance
                        .collection('users')
                        .doc(docId)
                        .delete();
                  }
                  if (value == "make_admin") {
                    await FirebaseFirestore
                        .instance
                        .collection('users')
                        .doc(docId)
                        .update({
                      "role": "admin"
                    });
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                      value: "remove",
                      child: Text("Remove")),
                  PopupMenuItem(
                      value: "make_admin",
                      child:
                      Text("Make Admin")),
                ],
              ),
            ],
          ),
        ),
        const Divider(
            color: Colors.black87,
            thickness: 1.2,
            height: 1),
      ],
    );
  }

}