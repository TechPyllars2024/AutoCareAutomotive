import 'package:autocare_automotiveshops/ProfileManagement/screens/automotive_verification_status.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/top_section.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/profile_details.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/services_carousel.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/feedback_section.dart';
import '../services/profile_service.dart';
import '../models/automotive_shop_profile_model.dart';
import '../widgets/button.dart'; // Assuming this is the button widget file
import 'automotive_edit_profile.dart';
import 'automotive_get_verified.dart';

class AutomotiveProfileScreen extends StatefulWidget {
  const AutomotiveProfileScreen({super.key});

  @override
  State<AutomotiveProfileScreen> createState() => _AutomotiveProfileScreenState();
}

class _AutomotiveProfileScreenState extends State<AutomotiveProfileScreen> {
  final ProfileService _profileService = ProfileService();
  AutomotiveProfileModel? profile;
  final user = FirebaseAuth.instance.currentUser;

  final double coverHeight = 160;
  final double profileHeight = 100;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final fetchedProfile = await _profileService.fetchProfileData();
    setState(() {
      profile = fetchedProfile;
    });
  }

  void editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AutomotiveEditProfile()),
    ).then((_) {
      // Reload profile data after returning from the edit profile screen
      _loadProfileData();
    });
  }

  void getVerified() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AutomotiveGetVerifiedScreen()),
    );
  }

  void checkStatus() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VerificationStatusScreen(uid: user!.uid)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            TopSection(
              coverHeight: coverHeight,
              profileHeight: profileHeight,
              profile: profile,
            ),
            ProfileDetails(profile: profile),
            buildButton(),
            const SizedBox(height: 10),
            buildGetVerified(),
            const SizedBox(height: 10),
            buildCheckStatus(),
            const ServicesCarousel(),
            const FeedbackSection(),
          ],
        ),
      ),
    );
  }

  Widget buildButton() => WideButtons(
    onTap: editProfile,
    text: 'Edit Profile',
  );

  Widget buildGetVerified() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25),
    child: ElevatedButton(
    onPressed: getVerified,
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      minimumSize: const Size(400, 45),
      backgroundColor: Colors.white, // Applied deep orange shade
    ),
    child: Text('Get Verified', style: TextStyle(color: Colors.deepOrange.shade700, fontWeight: FontWeight.bold),),
  )
  );
  Widget buildCheckStatus() => WideButtons(
    onTap: checkStatus,
    text: 'Check Status',
  );
}
