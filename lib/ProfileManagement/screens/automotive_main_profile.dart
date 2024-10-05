import 'package:autocare_automotiveshops/ProfileManagement/screens/automotive_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Authentication/Widgets/snackBar.dart';
import '../../Authentication/screens/login.dart';
import '../../Authentication/services/authentication_signout.dart';
import '../models/automotive_shop_profile_model.dart';
import '../services/profile_service.dart';
import 'automotive_edit_profile.dart';
import 'automotive_get_verified.dart';
import 'automotive_verification_status.dart';

class AutomotiveMainProfile extends StatefulWidget {
  const AutomotiveMainProfile({super.key, this.child});

  final Widget? child;

  @override
  State<AutomotiveMainProfile> createState() => _AutomotiveMainProfileState();
}

class _AutomotiveMainProfileState extends State<AutomotiveMainProfile> {
  final ProfileService _profileService = ProfileService();
  AutomotiveProfileModel? profile;
  final user = FirebaseAuth.instance.currentUser;
  bool isExpanded = false;

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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
        ),
        backgroundColor: Colors.grey.shade100,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white,
                backgroundImage: profile?.profileImage.isNotEmpty == true
                    ? NetworkImage(profile!.profileImage)
                    : null,
                child: profile?.profileImage.isEmpty == true
                    ? const Icon(Icons.person, size: 100, color: Colors.black)
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: Text(
                  '${profile?.shopName}' ?? '',
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            ProfileDetailsWidget(profile: profile),

            const Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ProfileMenuWidget(
                      title: "Shop Profile Details",
                      icon: Icons.storefront,
                      onPressed: () {
                        // Navigate to Address screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AutomotiveProfileScreen()),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ProfileMenuWidget(
                        title: "Get Verified", 
                        icon: Icons.description, 
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AutomotiveGetVerifiedScreen()),
                          );
                        }),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ProfileMenuWidget(
                        title: "Check Status", 
                        icon: Icons.verified, 
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => VerificationStatusScreen(uid: user!.uid)),
                          );
                        }),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ProfileMenuWidget(
                        title: "Logout",
                        icon: Icons.logout,
                        onPressed: () async {
                          try {
                            await AuthenticationMethodSignOut().signOut();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          } catch (e) {
                            Utils.showSnackBar('Error Signing Out: $e');
                          }
                        },
                        // onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileDetailsWidget extends StatelessWidget {
  final AutomotiveProfileModel? profile;

  const ProfileDetailsWidget({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.orange.shade900, size: 15,),
                const SizedBox(width: 4),
                Text(
                  profile?.location ?? 'Location',

                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.orange.shade900, size: 15,),
                const SizedBox(width: 4),
                // Convert the list to a comma-separated string if it's a list
                Text(
                  (profile?.daysOfTheWeek.join(', ') ?? 'Days of the Week'),

                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.orange.shade900, size: 15,),
                const SizedBox(width: 4),
                // Ensure operationTime is a String
                Text(
                  profile?.operationTime ?? 'Operation Time',

                ),
              ],
            ),
            const SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check, color: Colors.orange.shade900, size: 15,),
                    const SizedBox(width: 4),
                    // Ensure operationTime is a String
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (profile?.serviceSpecialization.join(', ') ?? 'Specialization'
                                ''),
                            overflow: TextOverflow.visible, // Allow text to wrap
                            maxLines: 2, // Set max lines if needed
                            softWrap: true, // Enable soft wrapping

                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.endIcon = true,
    this.color,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final bool endIcon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.orange.shade900.withOpacity(0.1),
        ),
        child: Icon(icon, color: Colors.orange.shade900),
      ),
      title: Text(title, style: TextStyle(color: color ?? Colors.black)),
      trailing: endIcon? Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: const Icon(Icons.arrow_forward_ios, size: 18.0, color: Colors.grey),
      ) : null,
    );
  }
}