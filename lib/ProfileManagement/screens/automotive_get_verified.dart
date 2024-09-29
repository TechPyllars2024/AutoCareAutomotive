import 'package:autocare_automotiveshops/ProfileManagement/services/get_verified_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'automotive_verification_status.dart';

class AutomotiveGetVerifiedScreen extends StatefulWidget {
  const AutomotiveGetVerifiedScreen({super.key});

  @override
  State<AutomotiveGetVerifiedScreen> createState() =>
      _AutomotiveGetVerifiedScreenState();
}

class _AutomotiveGetVerifiedScreenState
    extends State<AutomotiveGetVerifiedScreen> {
  bool _isLoading = false;
  bool _isUploaded = false;
  String? _filePath; // To store the selected file path

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
      _isUploaded = false;
    });

    try {
      String? filePath = await GetVerifiedServices().pickFile();

      if (filePath != null && filePath.isNotEmpty) {
        setState(() {
          _filePath = filePath; // Store the selected file path
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_filePath == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? fileUrl = await GetVerifiedServices().uploadFile(_filePath!);

      if (fileUrl != null && fileUrl.isNotEmpty) {
        await GetVerifiedServices().saveVerificationData(fileUrl);
        setState(() {
          _isUploaded = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully uploaded the file!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationStatusScreen(
              uid: 'user_uid',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload file')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload file: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Get Verified', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading) const CircularProgressIndicator(),
              if (!_isLoading && _isUploaded)
                const Text(
                  'SUCCESSFULLY UPLOADED THE FILE',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              Image.asset('lib/ProfileManagement/assets/getVerifiedCar.png',
                  height: 200),
              const SizedBox(height: 16),
              const Text(
                'Please upload a PDF file to get verified',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  minimumSize: const Size(300, 45),
                  backgroundColor: Colors.deepOrange.shade700,
                ),
                onPressed: () {
                  if (!_isLoading) {
                    _pickFile();
                  }
                },
                child: Text(
                  _isLoading ? 'Picking...' : 'Pick PDF',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15),
                ),
              ),
              const SizedBox(height: 16),
              if (_filePath != null)
                Column(
                  children: [
                    Container(
                      height: 300,
                      child: PDFView(
                        filePath: _filePath,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (!_isLoading) {
                          _uploadFile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        minimumSize: const Size(300, 45),
                        backgroundColor: Colors.deepOrange.shade700,
                      ),
                      child: Text(_isLoading ? 'Loading...' : 'Submit',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 15),),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
