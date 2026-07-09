import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/app_background.dart';
class AddEventScreen extends StatefulWidget {
  const AddEventScreen({Key? key}) : super(key: key);

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController =
  TextEditingController();

  DateTime selectedDate = DateTime.now();

  TimeOfDay fromTime =
  const TimeOfDay(hour: 12, minute: 0);

  TimeOfDay toTime =
  const TimeOfDay(hour: 14, minute: 0);

  /// ---------------- DATE PICKER ----------------
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// ---------------- TIME PICKER ----------------
  Future<void> pickTime(bool isFrom) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? fromTime : toTime,
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromTime = picked;
        } else {
          toTime = picked;
        }
      });
    }
  }

  /// ================= SAVE EVENT =================
  Future<void> saveEvent() async {

    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    try {

      /// current admin uid
      String uid =
          FirebaseAuth.instance.currentUser!.uid;

      /// get admin clubId
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      String clubId = userDoc["clubId"];

      /// SAVE EVENT INSIDE CLUB
      await FirebaseFirestore.instance
          .collection("clubs")
          .doc(clubId)
          .collection("events")
          .add({
        "name": nameController.text.trim(),
        "description":
        descriptionController.text.trim(),
        "date": selectedDate,
        "fromTime": fromTime.format(context),
        "toTime": toTime.format(context),
        "createdAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event Added")),
      );

      Navigator.pop(context);

    } catch (e) {
      print("Error adding event: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
            body: AppBackground(
        child: Stack(
        children: [

          /// TOP DESIGN
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              "assets/vectors/top_circles.png",
              width: 230,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 60),

                  const Text(
                    "Let's set the\nevent easily!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2A37),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Select the date",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1F2A37),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// DATE SELECTOR
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      dateBox(
                          "Date",
                          "${selectedDate.day}"),
                      dateBox(
                          "Month",
                          DateFormat('MMM')
                              .format(selectedDate)),
                      dateBox(
                          "Year",
                          "${selectedDate.year}"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Select time",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1F2A37),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// TIME SELECTOR
                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20),
                    decoration: BoxDecoration(
                      color:
                      const Color(0xFF8FA178),
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                      children: [

                        GestureDetector(
                          onTap: () =>
                              pickTime(true),
                          child: timeColumn(
                              "From",
                              fromTime
                                  .format(context)),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.white,
                        ),

                        GestureDetector(
                          onTap: () =>
                              pickTime(false),
                          child: timeColumn(
                              "To",
                              toTime
                                  .format(context)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text("Event Name"),
                  const SizedBox(height: 8),

                  TextField(
                    controller: nameController,
                    decoration:
                    InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets
                          .symmetric(
                          horizontal: 16,
                          vertical: 12),
                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius
                            .circular(12),
                        borderSide:
                        BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                      "Event Description"),
                  const SizedBox(height: 8),

                  TextField(
                    controller:
                    descriptionController,
                    maxLines: 4,
                    decoration:
                    InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets
                          .symmetric(
                          horizontal: 16,
                          vertical: 16),
                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius
                            .circular(12),
                        borderSide:
                        BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// SAVE BUTTON
                  Center(
                    child: SizedBox(
                      width: 140,
                      height: 50,
                      child: ElevatedButton(
                        style:
                        ElevatedButton
                            .styleFrom(
                          backgroundColor:
                          const Color(
                              0xFFE8C87D),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                                30),
                          ),
                        ),
                        onPressed:
                        saveEvent,
                        child:
                        const Text(
                          "Save",
                          style:
                          TextStyle(
                            fontSize:
                            16,
                            fontWeight:
                            FontWeight
                                .w600,
                            color: Colors
                                .black,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// DATE BOX
  Widget dateBox(String label, String value) {
    return GestureDetector(
      onTap: pickDate,
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4A2C1A),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 80,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFE8C87D),
              borderRadius:
              BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              value,
              style:
              const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// TIME COLUMN
  Widget timeColumn(
      String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style:
          const TextStyle(
            color:
            Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style:
          const TextStyle(
            fontSize: 20,
            color:
            Colors.white,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

