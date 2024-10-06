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
  bool _isLoadingPickFile = false; // Separate loading state for pick file
  bool _isLoadingSubmit = false; // Separate loading state for submit
  bool _isUploaded = false;
  String? _filePath;
  Key _pdfKey = UniqueKey();
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  PDFViewController? _pdfViewController;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // for getting the verification status if pending or verified

  // @override
  // void initState() {
  //   super.initState();
  //   _redirectToStatusPageIfNeeded();
  // }
  //
  // Future<void> _redirectToStatusPageIfNeeded() async {
  //   String? status = await _checkVerificationStatus();
  //   if (status == 'Pending' || status == 'Verified') {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => VerificationStatusScreen(uid: _auth.currentUser!.uid),
  //       ),
  //     );
  //   }
  // }
  //
  // Future<String?> _checkVerificationStatus() async {
  //   final user = _auth.currentUser;
  //   if (user != null) {
  //     return await GetVerifiedServices().fetchStatus(user.uid);
  //   }
  //   return 'not_verified';
  // }

  Future<void> _pickFile() async {
    setState(() {
      _isLoadingPickFile = true; // Set loading state for picking file
    });

    try {
      String? filePath = await GetVerifiedServices().pickFile();

      if (filePath != null && filePath.isNotEmpty) {
        setState(() {
          _filePath = filePath;
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
        _isLoadingPickFile = false; // Reset loading state after picking file
      });
    }
  }

  Future<void> _uploadFile() async {
    final user = _auth.currentUser;
    if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a PDF file first')),
      );
      return; // Exit if no file is picked
    }

    setState(() {
      _isLoadingSubmit = true; // Set loading state for submission
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
            builder: (context) => VerificationStatusScreen(uid: user!.uid),
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
        _isLoadingSubmit = false; // Reset loading state after submission
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

                // Pick PDF Button
                ElevatedButton(
                  onPressed: () {
                    if (!_isLoadingPickFile) {
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
                    _isLoadingPickFile ? 'Picking...' : 'Pick PDF',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white), // Set text style here
                  ),
                ),
                const SizedBox(height: 16),

                // Display file name if a file is selected
                if (_filePath != null)
                  Text(
                    'File Name: ${path.basename(_filePath!)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),

                const SizedBox(height: 16),

                if (_filePath != null)
                  Column(
                    children: [
                      SizedBox(
                        height: 400, // Adjust height as needed
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
                              SnackBar(content: Text('Error loading PDF: $error')),
                            );
                          },
                          onPageChanged: (page, total) {
                            setState(() {
                              _currentPage = page!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (_isReady)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () async {
                                if (_currentPage > 0) {
                                  _currentPage--;
                                  await _pdfViewController?.setPage(_currentPage); // Navigate to previous page
                                }
                              },
                            ),
                            Text(
                              'Page ${_currentPage + 1} of $_totalPages',
                              style: const TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () async {
                                if (_currentPage < _totalPages - 1) {
                                  _currentPage++;
                                  await _pdfViewController?.setPage(_currentPage); // Navigate to next page
                                }
                              },
                            ),
                          ],
                        ),
                      const SizedBox(height: 32),

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
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15), // Set the corner radius
                            ),
                          ),
                          child: _isLoadingSubmit
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
