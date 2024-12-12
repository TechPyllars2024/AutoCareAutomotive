import 'package:autocare_automotiveshops/ProfileManagement/screens/automotive_commission.dart';
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
  bool isLoading = true;
  final double profileHeight = 100;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _checkVerificationStatus();
  }

  Future<void> _loadProfileData() async {
    final fetchedProfile = await _profileService.fetchProfileData();
    setState(() {
      profile = fetchedProfile;
      isLoading = false;
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
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
        backgroundColor: Colors.orange.shade900,
        actions: [
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.all(6.0),
              child:  Center(
                child: Icon(
                  Icons.edit,
                  color: Colors.orange.shade900,
                  size: 25,
                ),
              ),
            ),
            onPressed: editProfile,
          ),
        ],
      ),
      body: isLoading
          ?  Center(
        child:  CircularProgressIndicator(
          color: Colors.orange.shade900,
        ),
      )
          :SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  color: Colors.orange.shade900,
                ),
                Positioned(
                  top: 0, // Adjust this value to position the orange container at the top
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    height: 100,
                    color: Colors.orange.shade900,
                  ),
                ),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade100,
                      width: 6,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 90,
                    backgroundColor: Colors.grey.shade400,
                    backgroundImage: profile?.profileImage.isNotEmpty == true
                        ? NetworkImage(profile!.profileImage)
                        : null,
                    child: profile?.profileImage.isEmpty == true
                        ? const Icon(Icons.person, size: 90, color: Colors.white)
                        : null,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
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
                      Icon(
                        Icons.verified,
                        color: Colors.orange.shade900,
                        size: 30,
                      ),
                  ],
                ),
              ),
            ),

            const Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),


            //Shop Profile Details Section
            ProfileDetailsWidget(profile: profile),



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
                      if (snapshot.hasError) {
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
                                  builder: (context) =>
                                      VerificationStatusScreen(uid: user!.uid),
                                ),
                              );
                              _checkVerificationStatus();
                            },
                          ),
                        );
                      }
                    },
                  ),

                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ProfileMenuWidget(
                      title: "Commission",
                      icon: Icons.handshake_outlined,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              AutomotiveCommission(serviceProviderUid: user!.uid,)),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () async {
                          try {
                            await AuthenticationMethodSignOut().signOut();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          } catch (e) {
                            Utils.showSnackBar('Error Signing Out: $e');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: Colors.orange.shade900),
                              const SizedBox(width: 10),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.grey.shade900,
                                  fontSize: 15,

                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.orange.shade900,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        profile?.location ?? 'Location',
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        softWrap: true,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Icon(
                          Icons.schedule,
                          color: Colors.orange.shade900,
                          size: 20,
                        ),
                    ),
                    const SizedBox(height: 5),
                    const SizedBox(width: 8),
                    Flexible(
                        child: Text(
                          profile?.operationTime ?? 'Operation Time',
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 14),
                          softWrap: true,
                        ),
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Table(
              border: TableBorder.all(color: Colors.orange.shade900),
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: Colors.orange.shade900,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Days of the Week',
                            style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            color: Colors.orange.shade900,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Specialization',
                            style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        profile?.daysOfTheWeek.join(', ') ?? 'Days of the Week',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 5,
                        softWrap: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        profile?.serviceSpecialization.join(', ') ?? 'Specialization',
                        overflow: TextOverflow.visible,
                        maxLines: 10,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.orange.shade900.withOpacity(1),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title, style: TextStyle(color: color ?? Colors.black, fontSize: 14)),
      trailing: endIcon
          ? Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.grey.withOpacity(0.1),
              ),
              child: const Icon(Icons.arrow_forward_ios,
                  size: 15.0, color: Colors.grey),
            )
          : null,
    );
  }
}
