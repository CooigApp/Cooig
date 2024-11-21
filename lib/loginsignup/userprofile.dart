import 'package:cooig_firebase/background.dart';
import 'package:cooig_firebase/home.dart';
//import 'package:cooig_firebase/lostpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

class Userprofile extends StatefulWidget {
  const Userprofile({super.key});

  @override
  _UserprofileState createState() => _UserprofileState();
}

class _UserprofileState extends State<Userprofile> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();
  File? _imageFile;
  String? _username, _branch, _bio;
  bool _isLoading = false;
  String defaultvalue = "";
  List<Map<String, String>> dropdownlist = [
    {"title": "First Year", "value": "1"},
    {"title": "Second Year", "value": "2"},
    {"title": "Third Year", "value": "3"},
    {"title": "Fourth Year", "value": "4"},
    {"title": "Fifth Year", "value": "5"},
  ];

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      } else {
        throw 'No image selected';
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _saveDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      String userid = _auth.currentUser!.uid;
      if (user == null) throw 'No user logged in';

      String? imageUrl;
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_profile_pics/${user.uid}.jpg');
        await storageRef.putFile(_imageFile!);
        imageUrl = await storageRef.getDownloadURL();
      }

      await _firestore.collection('users').doc(user.uid).set({
        'username': _username ?? '',
        'branch': _branch ?? '',
        'bio': _bio ?? '',
        'profile_pic': imageUrl ?? '',
        'year': defaultvalue,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details saved successfully!')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                Homepage(userId: userid)), // Replace with your home page
      );
    } catch (e) {
      _showErrorSnackBar('Failed to save details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RadialGradientBackground(
      colors: const [Color(0XFF9752C5), Color(0xFF000000)],
      radius: 0.8,
      centerAlignment: Alignment.bottomRight,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          title: Text(
            'Cooig',
            style: GoogleFonts.libreBodoni(
              textStyle: const TextStyle(
                color: Color.fromARGB(255, 254, 253, 255),
                fontSize: 26,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(23.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Welcome",
                      style: GoogleFonts.ebGaramond(
                        color: const Color(0XFF9752C5),
                        fontSize: 40,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : null,
                          child: _imageFile == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey[800],
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon:
                                Icon(Icons.camera_alt, color: Colors.grey[800]),
                            onPressed: _pickImage,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Username',
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(18),
                            right: Radius.circular(18),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.person, color: Colors.grey[800]),
                      ),
                      onChanged: (value) => _username = value,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Branch',
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(18),
                            right: Radius.circular(18),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.school, color: Colors.grey[800]),
                      ),
                      onChanged: (value) => _branch = value,
                    ),
                    const SizedBox(height: 17),
                    DropdownButtonFormField<String>(
                      value: defaultvalue.isNotEmpty ? defaultvalue : null,
                      items: dropdownlist
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item['value'],
                              child: Text(item['title']!),
                            ),
                          )
                          .toList(),
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(18),
                            right: Radius.circular(18),
                          ),
                        ),
                        labelText: 'Year of Study',
                        prefixIcon:
                            Icon(Icons.calendar_today, color: Colors.grey[800]),
                        labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 148, 147, 147),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          defaultvalue = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: 'Bio',
                        alignLabelWithHint: true,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(18),
                            right: Radius.circular(18),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.edit, color: Colors.grey[800]),
                      ),
                      onChanged: (value) => _bio = value,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFF9752C5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: Text(
                        'Next',
                        style: GoogleFonts.ebGaramond(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
