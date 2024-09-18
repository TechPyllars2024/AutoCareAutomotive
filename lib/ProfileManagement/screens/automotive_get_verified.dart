import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AutomotiveGetVerified extends StatefulWidget {
  @override
  _AutomotiveGetVerifiedState createState() => _AutomotiveGetVerifiedState();
}

class _AutomotiveGetVerifiedState extends State<AutomotiveGetVerified> {
  bool _isLoading = false;
  String? _uploadedFileURL;

  Future<void> _pickAndUploadFile() async {
    setState(() {
      _isLoading = true;
    });

    // Pick a file
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);

      // Upload the file to Firebase Storage
      try {
        String fileName = result.files.single.name;
        Reference storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
        UploadTask uploadTask = storageRef.putFile(file);

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();

        setState(() {
          _uploadedFileURL = downloadURL;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File uploaded successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload file: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No file selected')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Get Verified'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _pickAndUploadFile();
              },
              child: const Text('Upload File'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // get verified
              },
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
