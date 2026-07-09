import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/app_bottom_nav.dart';
import 'widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/app_bottom_nav.dart';
import 'widgets/app_background.dart';

class MemberDirectoryUser extends StatefulWidget {
  const MemberDirectoryUser({super.key});

  @override
  State<MemberDirectoryUser> createState() =>
      _MemberDirectoryUserState();
}

class _MemberDirectoryUserState extends State<MemberDirectoryUser> {
  String searchText = "";

  String? clubId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadClubId();
  }

  Future<void> loadClubId() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          clubId = userDoc["clubId"];
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        loading = false;
      });
    }
  }

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
                padding: const EdgeInsets.only(
                  left: 24,
                  top: 40,
                  bottom: 20,
                ),
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
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.45),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 1,
                    ),
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
                      _buildSearchBar(),

                      const Divider(
                        color: Colors.black87,
                        thickness: 1.2,
                        height: 1,
                      ),

                      Expanded(
                        child: loading
                            ? const Center(
                          child: CircularProgressIndicator(),
                        )
                            : StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .where("clubId",
                              isEqualTo: clubId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child:
                                CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  "Error: ${snapshot.error}",
                                ),
                              );
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child:
                                Text("No members found"),
                              );
                            }

                            final users = snapshot.data!.docs
                                .where((doc) {
                              final data = doc.data()
                              as Map<String, dynamic>;

                              final name =
                              (data["name"] ?? "")
                                  .toString()
                                  .toLowerCase();

                              return name.contains(
                                searchText.toLowerCase(),
                              );
                            }).toList();

                            if (users.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No members match your search",
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: users.length,
                              itemBuilder:
                                  (context, index) {
                                final data = users[index]
                                    .data()
                                as Map<String, dynamic>;

                                return _buildUserTile(
                                  data["name"] ?? "",
                                  data["email"] ?? "",
                                  data["role"] ?? "",
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
        isAdmin: false,
      ),
    );
  }

  Widget _buildUserTile(
      String name,
      String email,
      String role,
      ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF9BA6B3),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 13,
                        decoration:
                        TextDecoration.underline,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: role == "admin"
                            ? Colors.orange
                            : Colors.grey,
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: Text(
                        role,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(
          color: Colors.black87,
          thickness: 1.2,
          height: 1,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius:
          BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.9),
          ),
          boxShadow: [
            BoxShadow(
              color:
              const Color(0xFF4A2F1B).withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
          decoration: const InputDecoration(
            hintText: "Search...",
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            contentPadding:
            EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }
}