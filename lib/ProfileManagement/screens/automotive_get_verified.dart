import 'package:autocare_automotiveshops/ProfileManagement/services/get_verified_services.dart';
import 'package:flutter/material.dart';

import 'automotive_verification_status.dart';

class AutomotiveGetVerifiedScreen extends StatefulWidget {
  const AutomotiveGetVerifiedScreen({super.key});


  @override
  State<AutomotiveGetVerifiedScreen> createState() => _AutomotiveGetVerifiedScreenState();
}

class _AutomotiveGetVerifiedScreenState extends State<AutomotiveGetVerifiedScreen> {
  bool _isLoading = false;
  bool _isUploaded = false; // To track if the file was successfully uploaded

  Future<void> _pickAndUploadFile() async {
    setState(() {
      _isLoading = true;
      _isUploaded = false; // Reset the upload status
    });

    try {
      String? fileUrl = await GetVerifiedServices().pickAndUploadFile();

      if (fileUrl != null && fileUrl.isNotEmpty) {
        await GetVerifiedServices().saveVerificationData(fileUrl);
        setState(() {
          _isUploaded = true; // Mark as uploaded
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully uploaded the file!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationStatusScreen(uid: 'user_uid',),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload file: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Verified'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator(), // Show loading spinner during upload
              if (!_isLoading && _isUploaded)
                const Text(
                  'SUCCESSFULLY UPLOADED THE FILE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              Image.asset('lib/ProfileManagement/assets/getVerifiedCar.png', height: 200),
              const SizedBox(height: 16),
              const Text(
                'Please upload a PDF file to get verified',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (!_isLoading) {
                    _pickAndUploadFile();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(_isLoading ? 'Uploading...' : 'Upload PDF'),
              ),
              const SizedBox(height: 16), // Add spacing between buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerificationStatusScreen(uid: 'user_uid'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Status'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
