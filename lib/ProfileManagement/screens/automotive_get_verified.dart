import 'package:autocare_automotiveshops/ProfileManagement/services/get_verified_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _isLoadingPickFile = false;
  bool _isLoadingSubmit = false;
  bool _isUploaded = false;
  String? _filePath;
  Key _pdfKey = UniqueKey();
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  PDFViewController? _pdfViewController;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _pickFile() async {
    setState(() {
      _isLoadingPickFile = true;
    });

    try {
      String? filePath = await GetVerifiedServices().pickFile();

      if (filePath != null && filePath.isNotEmpty) {
        setState(() {
          _filePath = filePath;
          _pdfKey = UniqueKey();
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
        _isLoadingPickFile = false;
      });
    }
  }

  Future<void> _uploadFile() async {
    final user = _auth.currentUser;
    if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a PDF file first')),
      );
      return;
    }

    setState(() {
      _isLoadingSubmit = true;
    });

    try {
      String? fileUrl = await GetVerifiedServices().uploadFile(_filePath!);

      if (fileUrl != null && fileUrl.isNotEmpty) {
        await GetVerifiedServices().saveVerificationData(fileUrl);
        await GetVerifiedServices().updateStatus(user!.uid, 'Pending');
        setState(() {
          _isUploaded = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully uploaded the file!'),
              backgroundColor: Colors.green),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationStatusScreen(uid: user.uid),
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
        _isLoadingSubmit = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Register as a Verified Automotive Shop',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(height: 10),
                // Instruction Texts Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: '1. ',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'Prepare the Documents:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0, top: 8),
                      child: Text(
                        'Compile the following into a single PDF file',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    // Sub-steps
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              text: '- ',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black),
                              children: [
                                TextSpan(
                                  text: 'Business Permit: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: 'A clear copy of your valid business permit.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // File Name Display Section
                if (_filePath != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Text(
                      'Selected File: ${path.basename(_filePath!)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Pick File Button
                SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.8,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_isLoadingPickFile) {
                        _pickFile();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 30),
                      backgroundColor: Colors.orange.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      _isLoadingPickFile ? 'Picking...' : 'Pick File',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // PDF Preview Section
                if (_filePath != null)
                  Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: PDFView(
                          key: _pdfKey,
                          filePath: _filePath,
                          fitPolicy: FitPolicy.BOTH,
                          enableSwipe: true,
                          swipeHorizontal: false,
                          autoSpacing: true,
                          pageFling: true,
                          pageSnap: true,
                          onRender: (pages) {
                            setState(() {
                              _totalPages = pages ?? 0;
                              _isReady = true;
                            });
                          },
                          onViewCreated: (PDFViewController pdfViewController) {
                            _pdfViewController = pdfViewController;
                          },
                          onError: (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error loading PDF: $error')),
                            );
                          },
                          onPageChanged: (page, total) {
                            setState(() {
                              _currentPage = page!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_isReady)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () async {
                                if (_currentPage > 0) {
                                  _currentPage--;
                                  await _pdfViewController?.setPage(
                                      _currentPage);
                                }
                              },
                            ),
                            Text(
                              'Page ${_currentPage + 1} of $_totalPages',
                              style: const TextStyle(fontSize: 14),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () async {
                                if (_currentPage < _totalPages - 1) {
                                  _currentPage++;
                                  await _pdfViewController?.setPage(
                                      _currentPage);
                                }
                              },
                            ),
                          ],
                        ),
                      const SizedBox(height: 14),

                      // Submit Button
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_isLoadingSubmit) {
                              _uploadFile();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 30),
                            backgroundColor: Colors.orange.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: _isLoadingSubmit
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor:
                              AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                              : const Text(
                            'Submit',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
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
