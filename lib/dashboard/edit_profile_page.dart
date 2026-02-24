import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final classController = TextEditingController();
  final regionController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    var doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      nameController.text = doc['name'] ?? "";
      phoneController.text = doc['phone'] ?? "";
      classController.text = doc['class'] ?? "";
      regionController.text = doc['region'] ?? "";
    }
  }

  void saveProfile() async {

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .set({
      "name": nameController.text.trim(),
      "email": user!.email,
      "phone": phoneController.text.trim(),
      "class": classController.text.trim(),
      "region": regionController.text.trim(),
    }, SetOptions(merge: true));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: classController,
              decoration: const InputDecoration(labelText: "Class"),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: regionController,
              decoration: const InputDecoration(labelText: "Region"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}