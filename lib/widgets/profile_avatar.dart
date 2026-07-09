import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A tappable circular profile picture.
///
/// - Reads the user's photo (stored as a small base64 string on their
///   Firestore user document, field `photoBase64`) and displays it live.
/// - When [editable] is true, tapping it lets the user choose a photo from
///   their gallery or camera and saves it straight to Firestore.
/// - When no photo has been set yet, it falls back to the original
///   grey person icon so existing accounts look exactly the same until the
///   user chooses to add a picture.
class ProfileAvatar extends StatefulWidget {
  final double radius;
  final bool editable;

  const ProfileAvatar({
    super.key,
    this.radius = 35,
    this.editable = true,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _uploading = false;

  Future<void> _choosePhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Text(
                "Update profile picture",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      if (picked == null) return;

      setState(() => _uploading = true);

      final bytes = await picked.readAsBytes();
      final encoded = base64Encode(bytes);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'photoBase64': encoded});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Couldn't update your photo. Please try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _avatarCircle(null);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        String? photoBase64;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          photoBase64 = data?['photoBase64'] as String?;
        }

        final avatar = _avatarCircle(photoBase64);

        if (!widget.editable) return avatar;

        return GestureDetector(
          onTap: _uploading ? null : _choosePhoto,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              avatar,
              if (_uploading)
                Positioned.fill(
                  child: CircleAvatar(
                    radius: widget.radius,
                    backgroundColor: Colors.black45,
                    child: const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7D990),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 15,
                    color: Color(0xFF1F2A37),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _avatarCircle(String? photoBase64) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: const Color(0xFF9BA6B3),
      backgroundImage: photoBase64 != null ? MemoryImage(base64Decode(photoBase64)) : null,
      child: photoBase64 == null
          ? Icon(Icons.person, color: Colors.white, size: widget.radius * 1.15)
          : null,
    );
  }
}
