import 'package:autocare_automotiveshops/ProfileManagement/screens/automotive_verification_status.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/top_section.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/profile_details.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/services_carousel.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import '../models/feedbacks_model.dart';
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
  bool isExpanded = false;

  final double coverHeight = 160;
  final double profileHeight = 100;
  late Future<Map<String, dynamic>> _providerData;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _providerData =
        ProfileService().fetchProviderByUid(user!.uid);
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
    final double top = coverHeight - profileHeight / 2;
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _providerData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available.'));
          } else {
            final data = snapshot.data!;
            return ListView(
              children: [
                buildTopSection(data, top),
                ProfileDetails(profile: profile),
                buildButton(),
                const SizedBox(height: 10),
                buildGetVerified(),
                const SizedBox(height: 10),
                buildCheckStatus(),
                const ServicesCarousel(),
                feedbackSection(user?.uid ?? ''),
              ],
            );
          }
        }
      ),
    );
  }

  Widget buildTopSection(Map<String, dynamic> data, double top) {
    double rating =
        data['totalRatings'] ?? 0;
    int numberOfRating =
        data['numberOfRatings'] ?? 0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: profileHeight / 2),
          child: buildCoverImage(data),
        ),
        Positioned(
          left: 20,
          top: top,
          child: buildProfileImage(data),
        ),
        Positioned(
          right: 20,
          top: coverHeight + 10,
          child: Row(
            children: [
              PannableRatingBar(
                rate: rating,
                items: List.generate(
                  5,
                      (index) =>  RatingWidget(
                    selectedColor: Colors.orange.shade900,
                    unSelectedColor: Colors.grey,
                    child: const Icon(
                      Icons.star,
                      size: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '$numberOfRating ratings',
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCoverImage(Map<String, dynamic> data) => Container(
    color: Colors.grey,
    child: Image.network(
      data['coverImage'] ?? 'default_cover_image_url',
      width: double.infinity,
      height: coverHeight,
      fit: BoxFit.cover,
    ),
  );

  Widget buildProfileImage(Map<String, dynamic> data) => CircleAvatar(
    radius: profileHeight / 2,
    backgroundColor: Colors.grey.shade800,
    backgroundImage:
    NetworkImage(data['profileImage'] ?? 'default_profile_image_url'),
  );

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

  Widget feedbackSection(String serviceProviderUid) =>
      StreamBuilder<List<FeedbackModel>>(
      stream: ProfileService().fetchFeedbacks(serviceProviderUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No feedbacks available.'));
        } else {
          final feedbacks = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Feedback',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: 150,

                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.85),
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final feedback = feedbacks[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PhysicalModel(
                        color: Colors.white,
                        elevation: 5,
                        shadowColor: Colors.grey,
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.blueGrey[50],
                                      child: Text(
                                        feedback.feedbackerName[0], // First letter of the feedbacker's name
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        feedback.feedbackerName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isExpanded = !isExpanded;
                                        });
                                      },
                                      child: Text(
                                        feedback.comment,
                                        style: TextStyle(
                                          fontSize: isExpanded ? 12 : 13, // Decrease font size if expanded
                                          color: Colors.black54,
                                        ),
                                        overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                        maxLines: isExpanded ? null : 2, // Show all lines if expanded
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),


                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.orange.shade900, size: 16),
                                        const SizedBox(width: 5),
                                        Text(
                                          feedback.rating.toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _formatTimestamp(feedback.timestamp), // Function to format timestamp
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45,
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
                  },
                ),
              ),
            ],
          );
        }
      },
    );

// Helper function to format the timestamp
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}
