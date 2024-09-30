import 'package:autocare_automotiveshops/ProfileManagement/services/get_verified_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path/path.dart' as path;
import 'automotive_verification_status.dart';

class AutomotiveGetVerifiedScreen extends StatefulWidget {
  const AutomotiveGetVerifiedScreen({super.key});

  @override
  State<AutomotiveGetVerifiedScreen> createState() =>
      _AutomotiveGetVerifiedScreenState();
}

class _AutomotiveGetVerifiedScreenState extends State<AutomotiveGetVerifiedScreen> {
  bool _isLoading = false;
  bool _isUploaded = false;
  String? _filePath; // To store the selected file path
  Key _pdfKey = UniqueKey(); // Use a unique key for the PDF view

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
          _pdfKey = UniqueKey(); // Force PDFView to reload
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
            builder: (context) => VerificationStatusScreen(uid: 'user_uid'),
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
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                      _pickFile();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    _isLoading ? 'Picking...' : 'Pick PDF',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), // Set text style here
                  ),
                ),

                const SizedBox(height: 16),

                // Display file name if a file is selected
                if (_filePath != null)
                  Text(
                    'Selected file: ${path.basename(_filePath!)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),

                const SizedBox(height: 16),

                if (_filePath != null)
                  Column(
                    children: [
                      SizedBox(
                        height: 400, // Adjust height as needed
                        child: PDFView(
                          key: _pdfKey, // Use the unique key here
                          filePath: _filePath,
                          fitPolicy: FitPolicy.BOTH, // Fit PDF to its original size within the available space
                          onRender: (_pages) {
                            setState(() {});
                          },
                          onError: (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error loading PDF: $error')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_isLoading) {
                              _uploadFile();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15), // Set the corner radius
                            ),
                          ),
                          child: _isLoading // Check loading state
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white, // Set indicator color
                            ),
                          )
                              : const Text(
                            'Submit',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
