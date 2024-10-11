import 'package:autocare_automotiveshops/ProfileManagement/screens/automotive_edit_profile.dart';
import 'package:autocare_automotiveshops/ProfileManagement/screens/automotive_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Authentication/Widgets/snackBar.dart';
import '../../Authentication/screens/login.dart';
import '../../Authentication/services/authentication_signout.dart';
import '../models/automotive_shop_profile_model.dart';
import '../services/get_verified_services.dart';
import '../services/profile_service.dart';
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
  bool isVerified = false;

  final double profileHeight = 100;
  late Future<Map<String, dynamic>> _providerData;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _providerData = ProfileService().fetchProviderByUid(user!.uid);
    _checkVerificationStatus();
  }

  Future<void> _loadProfileData() async {
    final fetchedProfile = await _profileService.fetchProfileData();
    setState(() {
      profile = fetchedProfile;
    });
  }

  Future<void> _checkVerificationStatus() async {
    String? status = await GetVerifiedServices().fetchStatus(user!.uid);
    setState(() {
      isVerified = status == 'Verified';
    });
  }

  void editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const AutomotiveEditProfileScreen()),
    ).then((_) {
      // Reload profile data after returning from the edit profile screen
      _loadProfileData();
    });
  }

  void getVerified() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const AutomotiveGetVerifiedScreen()),
    );
  }

  void checkStatus() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => VerificationStatusScreen(uid: user!.uid)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.grey.shade100,
        actions: [
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                color: Colors
                    .orange.shade900, // Set the background color to orange
                borderRadius: BorderRadius.circular(12.0), // Rounded edges
              ),
              padding: const EdgeInsets.all(
                  6.0), // Optional: Add some padding for better aesthetics
              child: const Center(
                // Center the icon
                child: Icon(
                  Icons.edit,
                  color: Colors.white, // Set the icon color to white
                  size: 25,
                ),
              ),
            ),
            onPressed: editProfile, // Call the editProfile method when pressed
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                width: 180, // Adjust width for border thickness
                height: 180, // Adjust height for border thickness
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.orange.shade900, // Border color
                    width: 1, // Border width
                  ),
                ),
                child: CircleAvatar(
                  radius: 90,
                  backgroundColor: Colors.white,
                  backgroundImage: profile?.profileImage.isNotEmpty == true
                      ? NetworkImage(profile!.profileImage)
                      : null,
                  child: profile?.profileImage.isEmpty == true
                      ? const Icon(Icons.person, size: 90, color: Colors.black)
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${profile?.shopName}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isVerified)
                      const Icon(
                        Icons.verified,
                        color: Colors.orange,
                        size: 30,
                      ),
                  ],
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
                      title: "Shop Profile",
                      icon: Icons.storefront,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AutomotiveProfileScreen()),
                        );
                      },
                    ),
                  ),
                  FutureBuilder<String?>(
                    future: GetVerifiedServices().fetchStatus(user!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Error fetching status');
                      } else {
                        String status = snapshot.data ?? 'Pending';
                        String title;
                        IconData icon;

                        switch (status) {
                          case 'Verified':
                            title = 'Check Status';
                            icon = Icons.verified;
                            break;
                          case 'Rejected':
                            title = 'Check Status';
                            icon = Icons.verified;
                            break;
                          case 'Pending':
                            title = 'Check Status';
                            icon = Icons.verified;
                            break;
                          default:
                            title = 'Get Verified';
                            icon = Icons.description;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ProfileMenuWidget(
                            title: title,
                            icon: icon,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VerificationStatusScreen(uid: user!.uid),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                  // Container(
                  //   margin: const EdgeInsets.only(bottom: 10),
                  //   child: ProfileMenuWidget(
                  //       title: "Get Verified",
                  //       icon: Icons.description,
                  //       onPressed: () {
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) =>
                  //                   VerificationStatusScreen(uid: user!.uid)),
                  //         );
                  //       }),
                  // ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ProfileMenuWidget(
                      title: "Logout",
                      icon: Icons.logout,
                      onPressed: () async {
                        try {
                          await AuthenticationMethodSignOut().signOut();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
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
                Icon(
                  Icons.location_on,
                  color: Colors.orange.shade900,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Text(
                  profile?.location ?? 'Location',
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: Colors.orange.shade900,
                  size: 15,
                ),
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
                Icon(
                  Icons.schedule,
                  color: Colors.orange.shade900,
                  size: 15,
                ),
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
                    Icon(
                      Icons.check,
                      color: Colors.orange.shade900,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    // Ensure operationTime is a String
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (profile?.serviceSpecialization.join(', ') ??
                                'Specialization'
                                    ''),
                            overflow:
                                TextOverflow.visible, // Allow text to wrap
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
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.grey.withOpacity(0.1),
              ),
              child: const Icon(Icons.arrow_forward_ios,
                  size: 18.0, color: Colors.grey),
            )
          : null,
    );
  }
}
