import 'dart:io';

import 'package:autocare_automotiveshops/ProfileManagement/models/automotive_shop_profile_model.dart';
// import 'package:autocare_automotiveshops/ProfileManagement/screens/automotive_profile.dart';
import 'package:autocare_automotiveshops/ProfileManagement/services/automotive_shop_edit_profile_services.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/button.dart';
// import 'package:autocare_automotiveshops/ProfileManagement/widgets/text_field.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/timeSelection.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/dropdown.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/daysOftheWeek.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart'; 

import 'package:flutter/material.dart';

class AutomotiveEditProfile extends StatefulWidget {
  const AutomotiveEditProfile({super.key});

  @override
  State<AutomotiveEditProfile> createState() => _AutomotiveEditProfileState();
}

class _AutomotiveEditProfileState extends State<AutomotiveEditProfile> {
  final DropdownController dropdownController = Get.put(DropdownController());
  final DaysOfTheWeekController daysOfTheWeekController =
      Get.put(DaysOfTheWeekController());


  File? _coverImage;
  File? _profileImage;
  String? _coverImageUrl;
  String? _profileImageUrl;
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final AutomotiveShopEditProfileServices _automotiveShopEditProfileServices = AutomotiveShopEditProfileServices();

  final double coverHeight = 220;
  final double profileHeight = 130;

  String? uid;
  AutomotiveProfileModel? editProfile;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadProfileData();
  }

  Future<AutomotiveProfileModel?> fetchProfileData(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('automotiveShops_profile')
        .doc(uid)
        .get();

    if (doc.exists) {
      return AutomotiveProfileModel.fromDocument(doc.data() as Map<String, dynamic>, doc.id);
    } else {
      return null;
    }
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final fetchedProfile = await fetchProfileData(user.uid);
      setState(() {
        editProfile = fetchedProfile;
        if (editProfile != null) {
          _coverImageUrl = editProfile!.coverImage;
          _profileImageUrl = editProfile!.profileImage;
          _shopNameController.text = editProfile!.shopName;
          _locationController.text = editProfile!.location;
        }
      });
    }
  }

  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
    }
  }

  Future<void> _pickCoverImage() async {
    final image = await _automotiveShopEditProfileServices.pickCoverImage();
    if (image != null) {
      setState(() {
        _coverImage = image;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final image = await _automotiveShopEditProfileServices.pickProfileImage();
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  Future<String> _uploadImage(File image, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && uid != null) {
      List<String> emptyFields = [];

      if (_shopNameController.text.isEmpty) {
        emptyFields.add('Shop Name');
      }

      if (_locationController.text.isEmpty) {
        emptyFields.add('Location');
      }

      if (emptyFields.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The following fields are empty: ${emptyFields.join(', ')}'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Prevent saving changes if there are empty fields
      }

      Map<String, dynamic> updatedData = {};

      if (_coverImage != null) {
        final coverImageUrl = await _uploadImage(_coverImage!, 'coverImages/$uid.jpg');
        updatedData['coverImage'] = coverImageUrl;
      }

      if (_profileImage != null) {
        final profileImageUrl = await _uploadImage(_profileImage!, 'profileImages/$uid.jpg');
        updatedData['profileImage'] = profileImageUrl;
      }

      updatedData['shopName'] = _shopNameController.text;
      updatedData['location'] = _locationController.text;

      if (updatedData.isNotEmpty) {
        await FirebaseFirestore.instance.collection('automotiveShops_profile').doc(user.uid).update(updatedData);
        Navigator.pop(context, updatedData);
      } else {
        print('No data to update');
      }
    } else {
      print('User ID is null or images are not selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double top = coverHeight - profileHeight / 2;

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.black, // Ensures text is visible on AppBar
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              buildTopSection(top),
              const SizedBox(height: 20),
              buildInputs(),
              dayOfTheWeekSelection(),
              timeSelection(),
              buildSaveButton(),
              servicesCarousel(),
              serviceSpecialization(),
              //ServicesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSaveButton() => WideButtons(
        onTap: _saveProfile,
        text: 'Save Changes',
      );

  Widget buildTopSection(double top) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: profileHeight / 2),
          child: buildCoverImage(),
        ),
        Positioned(
          left: 20,
          top: top,
          child: buildProfileImage(),
        ),
      ],
    );
  }

  Widget buildInputs() => Column(
        children: [
          TextField(
            controller: _shopNameController,
            decoration: const InputDecoration(
              hintText: 'Shop Name',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              hintText: 'Location',
            ),
          ),
        ],
      );

  Widget buildCoverImage() => Stack(
      children: [
        Container(
          color: Colors.grey.shade700,
          width: double.infinity,
          height: coverHeight,
          child: _coverImage != null
              ? Image.file(_coverImage!, fit: BoxFit.cover)
              : (_coverImageUrl != null && _coverImageUrl!.isNotEmpty)
                  ? Image.network(_coverImageUrl!, fit: BoxFit.cover)
                  : null,
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 24,
              ),
              onPressed: _pickCoverImage,
            ),
          ),
        ),
      ],
    );

  Widget buildProfileImage() => Stack(
      children: [
        CircleAvatar(
          radius: profileHeight / 2,
          backgroundColor: Colors.grey.shade600,
          child: _profileImage != null
              ? ClipOval(
                  child: Image.file(
                    _profileImage!,
                    fit: BoxFit.cover,
                    width: 130,
                    height: 130,
                  ),
                )
              : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                  ? ClipOval(
                      child: Image.network(
                        _profileImageUrl!,
                        fit: BoxFit.cover,
                        width: 130,
                        height: 130,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.white,
                    ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 24,
              ),
              onPressed: _pickProfileImage,
            ),
          ),
        ),
      ],
    );

  Widget servicesCarousel() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  'Services',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ), // Rounded corners
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            // Set width to 80% of screen width
                            padding: const EdgeInsets.all(20.0),
                            // Add some padding inside the modal
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Add Service',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Static Upload Photo Option with GestureDetector
                                GestureDetector(
                                  onTap: () {
                                    // Add your upload photo logic here
                                    print('Upload photo tapped');
                                  },
                                  child: Container(
                                    height: 100,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.camera_alt,
                                            size: 40, color: Colors.grey),
                                        SizedBox(height: 10),
                                        Text('Upload Photo',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                const TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Service name',
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Starting price',
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the modal
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    const SizedBox(width: 10),
                                    TextButton(
                                      onPressed: () {
                                        // Handle adding the service logic here
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Add Service'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: CarouselView(
              itemExtent: 280,
              children: List.generate(10, (int index) {
                return Container(
                  color: Colors.orangeAccent.shade100,
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: FractionallySizedBox(
                            heightFactor: 0.80,
                            alignment: Alignment.topCenter,
                            child: Image.network(
                              'https://wallpapers.com/images/featured/blank-white-7sn5o1woonmklx1h.jpg',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.all(10),
                          child: const Text(
                            textAlign: TextAlign.center,
                            'Service',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      );

  Widget timeSelection() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Operating hours',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Open'),
                      const SizedBox(height: 5),
                      // Add some space between the text and container
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border:
                              Border.all(color: Colors.grey), // Border color
                        ),
                        child: const TimePickerDisplay(initialTime: TimeOfDay(hour: 0, minute: 0)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Close'),
                      const SizedBox(height: 5),
                      // Add some space between the text and container
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border:
                              Border.all(color: Colors.grey), // Border color
                        ),
                        child: const TimePickerDisplay(initialTime: TimeOfDay(hour: 12, minute: 0)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget serviceSpecialization() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Service Specialization',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            CustomDropdown(
              options: const [
                'Electrical Works',
                'Mechanical Works',
                'Air-conditioning',
                'Paint and Body Works',
                'Car Wash and Auto-Detailing'
              ],
              hintText: 'Service Specialization',
              controller: dropdownController,
              onSelectionChanged: (selectedOptions) {
                print('Selected Options: $selectedOptions');
              },
            ),
          ],
        ),
      );



  Widget dayOfTheWeekSelection() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Days of the Week',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        DayOfTheWeek(
          options: const [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday'
          ],
          hintText: 'Select Days',
          controller: daysOfTheWeekController,
          onSelectionChanged: (selectedOptions) {
            print('Selected Options: $selectedOptions');
          },

        ),
      ],
    ),
  );

}
