import 'dart:io';
import 'dart:ui';
import 'package:autocare_automotiveshops/Authentication/screens/onboardingPage3.dart';

import '../widgets/button.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/timeSelection.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/dropdown.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/daysOftheWeek.dart';
import 'package:autocare_automotiveshops/Service%20Management/models/category_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/automotive_shop_profile_model.dart';
import '../services/automotive_shop_edit_profile_services.dart';

class AutomotiveCompleteProfileScreen extends StatefulWidget {
  const AutomotiveCompleteProfileScreen({super.key, this.child});

  final Widget? child;

  @override
  State<AutomotiveCompleteProfileScreen> createState() => _AutomotiveCompleteProfileScreenState();
}

class _AutomotiveCompleteProfileScreenState extends State<AutomotiveCompleteProfileScreen> {
  final DropdownController dropdownController = Get.put(DropdownController());
  final DaysOfTheWeekController daysOfTheWeekController =
      Get.put(DaysOfTheWeekController());

  File? _coverImage;
  File? _profileImage;
  String? _coverImageUrl;
  String? _profileImageUrl;
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final AutomotiveShopEditProfileServices _automotiveShopEditProfileServices =
      AutomotiveShopEditProfileServices();

  final double coverHeight = 160;
  final double profileHeight = 100;
  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;

  String? uid;
  AutomotiveProfileModel? editProfile;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadProfileData();
  }

  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
    }
  }

  Future<void> _loadProfileData() async {
    if (uid != null) {
      final fetchedProfile = await _automotiveShopEditProfileServices.fetchProfileData(uid!);
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

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      List<String> emptyFields = [];

      // Check for empty fields
      if (_shopNameController.text.isEmpty) {
        emptyFields.add('Shop Name');
      }

      if (_locationController.text.isEmpty) {
        emptyFields.add('Location');
      }

      if (_openingTime == null || _closingTime == null) {
        emptyFields.add('Operating hours');
      }

      // If there are empty fields, show a snackbar and return
      if (emptyFields.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'The following fields are empty: ${emptyFields.join(', ')}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true; // Set loading state to true
      });

      try {
          // If this is the first time the user is entering the details (editProfile is null)
          if (editProfile == null) {
            await _automotiveShopEditProfileServices.saveProfile(
              uid: user.uid,
              serviceProviderUid: user.uid,
              shopName: _shopNameController.text,
              location: _locationController.text,
              coverImage: _coverImage,
              profileImage: _profileImage,
              daysOfTheWeek: List<String>.from(daysOfTheWeekController.selectedOptionList),
              operationTime: '${_openingTime?.format(context)} - ${_closingTime?.format(context)}',
              serviceSpecialization: List<String>.from(dropdownController.selectedOptionList),
              verificationStatus: 'Not Submitted',
              totalRatings: 0.0,
              numberOfRatings: 0,
            );

          // Show success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to the next page (e.g., a welcome or home page)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Onboardingpage3()), // Replace with your actual page
          );
        } else {
          // Check if the profile is being edited with an existing name
          if (editProfile!.shopName == _shopNameController.text) {
            Navigator.pop(context); // Just pop the page if the name is unchanged
            return;
          }

          // Proceed to save the profile
          await _automotiveShopEditProfileServices.saveProfile(
            uid: user.uid,
            serviceProviderUid: user.uid,
            shopName: _shopNameController.text,
            location: _locationController.text,
            coverImage: _coverImage,
            profileImage: _profileImage,
            daysOfTheWeek: List<String>.from(daysOfTheWeekController.selectedOptionList),
            operationTime: '${_openingTime?.format(context)} - ${_closingTime?.format(context)}',
            serviceSpecialization: List<String>.from(dropdownController.selectedOptionList),
            verificationStatus: 'Not Submitted',
            totalRatings: 0.0,
            numberOfRatings: 0,
          );

          // Show success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved successfully'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context); // Return to the previous screen
        }
      } catch (e) {
        // Show failure snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save profile'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false; // Set loading state to false
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double top = coverHeight - profileHeight / 2;

    double bottomPadding = MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 80.0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Complete Your Shop Profile', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        backgroundColor: Colors.orange.shade900,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  buildTopSection(top),
                  buildInputs(),
                  dayOfTheWeekSelection(),
                  timeSelection(),
                  serviceSpecialization(),

                  buildSaveButton(),
                  const SizedBox(height: 20), // Add space to avoid overlapping with buttons
                ],
              ),
            ),
          ),
          if (_isLoading)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(), // Show loading indicator
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildSaveButton() => WideButtons(
    onTap: _saveProfile,
    text: 'Save',
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

  Widget buildInputs() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0),
    child: Column(
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
    ),
  );

  Widget buildCoverImage() => Stack(
    children: [
      Container(
        color: Colors.grey.shade400,
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
          width: 40,
          height: 40,
          decoration:  BoxDecoration(
            color: Colors.orange.shade900,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 20,
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
        backgroundColor: Colors.grey.shade500,
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
          size: 80,
          color: Colors.white,
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: 40,
          height: 40,
          decoration:  BoxDecoration(
            color: Colors.orange.shade900,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 20,
            ),
            onPressed: _pickProfileImage,
          ),
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
            fontSize: 18,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 55),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TimePickerDisplay(
                      initialTime: const TimeOfDay(hour: 0, minute: 0),
                      onTimeSelected: (selectedTime) {
                        setState(() {
                          _openingTime = selectedTime;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Close'),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 55),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TimePickerDisplay(
                      initialTime: const TimeOfDay(hour: 0, minute: 0),
                      onTimeSelected: (selectedTime) {
                        setState(() {
                          _closingTime = selectedTime;
                        });
                      },
                    ),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        CustomDropdown(
          options: CategoryList.categories,
          hintText: 'Service Specialization',
          controller: dropdownController,
          onSelectionChanged: (selectedOptions) {
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
            fontSize: 18,
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
          },
        ),
      ],
    ),
  );
}
