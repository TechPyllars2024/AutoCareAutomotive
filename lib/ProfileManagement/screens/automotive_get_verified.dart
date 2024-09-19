import 'package:autocare_automotiveshops/ProfileManagement/services/get_verified_services.dart';
import 'package:flutter/material.dart';

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

      if (fileUrl != null) {
        setState(() {
          _isUploaded = true; // Mark as uploaded
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully uploaded the file!')),
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
                ), // Show success message
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
            ],
          ),
        ),
      ),
    );
  }
}
