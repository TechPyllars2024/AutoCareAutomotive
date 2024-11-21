import 'dart:async';
import 'dart:io';
import 'package:autocare_automotiveshops/ProfileManagement/services/profile_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import '../services/pin_location.dart';
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
import 'automotive_pin_location.dart';

class AutomotiveEditProfileScreen extends StatefulWidget {
  const AutomotiveEditProfileScreen({super.key, this.child});

  final Widget? child;

  @override
  State<AutomotiveEditProfileScreen> createState() =>
      _AutomotiveEditProfileScreenState();
}

class _AutomotiveEditProfileScreenState
    extends State<AutomotiveEditProfileScreen> {
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
  final Logger logger = Logger();
  final double coverHeight = 160;
  final double profileHeight = 100;
  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;
  List<String>? _daysOfTheWeek;
  List<String>? _serviceSpecialization;
  late String _verificationStatus = '';
  late double _totalRatings;
  late int _numberOfRatings;
  int? _numberOfBookingPerHour = 1;
  String? uid;
  AutomotiveProfileModel? editProfile;
  late Map<String, Map<String, int>> remainingSlots;
  late GoogleMapController mapController;
  LatLng? _initialLocation;
  User? user = FirebaseAuth.instance.currentUser;
  final MapService mapService = MapService();
  final Set<Marker> _markers = {};
  Timer? _locationUpdateTimer;
  bool isLoading = true;

  @override
  void dispose() {
    _shopNameController.dispose();
    _locationController.dispose();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _initializeLocationAndFetchStations();
    _updateMarkers();
    _startLocationUpdates();
    _loadProfileData();
    logger.i(_markers);
  }

  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
    }
  }

  // Start periodic location updates using Timer
  void _startLocationUpdates() {
    _locationUpdateTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _updateMarkers();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _initializeLocationAndFetchStations() async {
    setState(() {
      isLoading = true;
    });

    final initialPosition = await _getUserCurrentLocation();

    if (initialPosition != null) {
      setState(() {
        _initialLocation =
            LatLng(initialPosition.latitude, initialPosition.longitude);
      });
    } else {
      // Handle error if no location is found (optional)
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<Position?> _getUserCurrentLocation() async {
    try {
      await Geolocator.requestPermission();
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      logger.i("Error getting location: $e");
      return null;
    }
  }

  Future<void> _updateMarkers() async {
    if (user == null) return;

    try {
      // Fetch marker data based on the user ID.
      final existingMarker = await mapService.fetchMarkerByUserId(user!.uid);

      if (existingMarker != null) {
        final newLocation =
            LatLng(existingMarker.latitude, existingMarker.longitude);

        // Only update if the location has changed
        if (_initialLocation == null || newLocation != _initialLocation) {
          setState(() {
            _initialLocation = newLocation;
            _markers.clear();
            _markers.add(Marker(
              markerId: MarkerId(existingMarker.latitude.toString() +
                  existingMarker.longitude.toString()),
              position: _initialLocation!,
              infoWindow: InfoWindow(
                title: existingMarker.nameOfThePlace,
                snippet:
                    "Latitude: ${_initialLocation!.latitude}, Longitude: ${_initialLocation!.longitude}",
              ),
            ));
          });
          logger.i("Marker updated at: $_initialLocation");

          // Animate the camera to the new marker location
          mapController.animateCamera(
            CameraUpdate.newLatLng(
                _initialLocation!), // Move camera to the new location
          );
        }
      } else {
        logger.e('No marker found for this user.');
      }
    } catch (e) {
      logger.e('Error loading marker: $e');
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator once done.
      });
    }
  }

  void _onTap(LatLng location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapPage(), // Replace with actual screen
      ),
    );
  }

  Future<void> _loadProfileData() async {
    final fetchedProfile = await ProfileService().fetchProfileData();
    setState(() {
      editProfile = fetchedProfile;
      if (editProfile != null) {
        isLoading = false;
        _coverImageUrl = editProfile!.coverImage;
        _profileImageUrl = editProfile!.profileImage;
        _shopNameController.text = editProfile!.shopName;
        _locationController.text = editProfile!.location;

        // Get the selected days from the profile
        _daysOfTheWeek = editProfile!.daysOfTheWeek;
        // Set the selected days in the controller
        if (_daysOfTheWeek != null) {
          daysOfTheWeekController.selectedOptionList.value = _daysOfTheWeek!;
          daysOfTheWeekController.updateSelectedOption();
        }

        _serviceSpecialization = editProfile!.serviceSpecialization;
        _verificationStatus = editProfile!.verificationStatus;
        _totalRatings = editProfile!.totalRatings;
        _numberOfRatings = editProfile!.numberOfRatings;
        _numberOfBookingPerHour = editProfile!.numberOfBookingsPerHour;
        remainingSlots = editProfile!.remainingSlots;

        // Parse the operation time from the profile
        final times = editProfile!.operationTime.split(' - ');
        if (times.length == 2) {
          _openingTime = _parseTimeOfDay(times[0]) ??
              const TimeOfDay(
                  hour: 12, minute: 0); // Fallback to 12:00 AM if null
          _closingTime = _parseTimeOfDay(times[1]) ??
              const TimeOfDay(
                  hour: 17, minute: 0); // Fallback to 5:00 PM if null
        } else {
          // If the format is incorrect, fallback to defaults
          _openingTime =
              const TimeOfDay(hour: 12, minute: 0); // Default to 12:00 AM
          _closingTime =
              const TimeOfDay(hour: 17, minute: 0); // Default to 5:00 PM
        }
      }
    });
  }

  TimeOfDay? _parseTimeOfDay(String time) {
    try {
      final sanitizedTime =
          time.trim().replaceAll('\u00A0', ' ').replaceAll(RegExp(r'\s+'), ' ');
      final timeParts = sanitizedTime.split(' ');

      if (timeParts.length != 2) {
        logger.i("Invalid time format. Expected 'HH:MM AM/PM'");
        return null;
      }

      final timeString = timeParts[0];
      final period = timeParts[1].toUpperCase();

      // Ensure the period is AM or PM
      if (period != 'AM' && period != 'PM') {
        logger.i("Invalid period. Expected 'AM' or 'PM'.");
        return null;
      }

      final timeComponents = timeString.split(':');
      if (timeComponents.length != 2) {
        logger.i("Invalid time format. Expected 'HH:MM'.");
        return null;
      }

      int hour = int.parse(timeComponents[0]);
      int minute = int.parse(timeComponents[1]);

      if (period == 'PM' && hour != 12) hour += 12; // Convert to 24-hour format
      if (period == 'AM' && hour == 12) hour = 0; // Handle midnight case

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      logger.i("Error parsing time: $e");
      return null;
    }
  }

  // Pick a cover image for the profile
  Future<void> _pickCoverImage() async {
    final image = await _automotiveShopEditProfileServices.pickCoverImage();
    if (image != null) {
      setState(() {
        _coverImage = image;
      });
    }
  }

  // Pick a profile image for the profile
  Future<void> _pickProfileImage() async {
    final image = await _automotiveShopEditProfileServices.pickProfileImage();
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  // Save the profile data to Firestore
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
      try {
        await _automotiveShopEditProfileServices.saveProfile(
            uid: user.uid,
            serviceProviderUid: user.uid,
            shopName: _shopNameController.text,
            location: _locationController.text,
            coverImage: _coverImage,
            profileImage: _profileImage,
            daysOfTheWeek:
                List<String>.from(daysOfTheWeekController.selectedOptionList),
            operationTime:
                '${_openingTime?.format(context)} - ${_closingTime?.format(context)}',
            serviceSpecialization:
                List<String>.from(dropdownController.selectedOptionList),
            verificationStatus: _verificationStatus,
            totalRatings: _totalRatings,
            numberOfRatings: _numberOfRatings,
            numberOfBookingsPerHour: _numberOfBookingPerHour!,
            remainingSlots: remainingSlots);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double top = coverHeight - profileHeight / 2;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Edit Your Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.black,
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
              numberOfBookingsSelection(),
              serviceSpecialization(),
              buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Save button
  Widget buildSaveButton() => WideButtons(
        onTap: _saveProfile,
        text: 'Save',
      );

  // Top section of the profile
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

  // Input fields for the profile
  // Inputs
  Widget buildInputs() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Name TextField with Label
            const Text('Shop Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: _shopNameController,
              decoration: InputDecoration(
                hintText: 'Enter your shop name',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange.shade900),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 10),

            // Location TextField with Label
            const Text('Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Enter location',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange.shade900),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 10),

            // "Pin Your Location Here" label
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Pin Your Location Here:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            // Google Map for pinning location
            isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(), // Show loading until location is set
                  )
                : (_initialLocation == null
                    ? const Center(child: Text('Location not available'))
                    : SizedBox(
                        height:
                            200, // Adjust the size for a better visual appearance
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4.0,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target:
                                  _initialLocation ?? const LatLng(0.0, 0.0),
                              zoom: 18.0,
                            ),
                            onMapCreated: _onMapCreated,
                            onTap: _onTap,
                            markers: Set.from(_markers),
                          ),
                        ),
                      )),
          ],
        ),
      );

  // Cover image for the profile
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
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

  // Profile image for the profile
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
              decoration: BoxDecoration(
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

  // Time selection for the profile
  Widget timeSelection() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Operating hours',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Open',
                        style: TextStyle(fontSize: 14),
                      ),
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
                      const Text(
                        'Close',
                        style: TextStyle(fontSize: 14),
                      ),
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

  // Service specialization for the profile
  Widget serviceSpecialization() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Service Specialization',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            CustomDropdown(
              options: CategoryList.categories,
              hintText: 'Service Specialization',
              controller: dropdownController,
              initialSelectedOptions: const [],
              onSelectionChanged: (selectedOptions) {
                setState(() {
                  _serviceSpecialization = selectedOptions.cast<String>();
                });
              },
            ),
          ],
        ),
      );

  // Days of the week selection for the profile
  Widget dayOfTheWeekSelection() => Padding(
        padding:
            const EdgeInsets.all(16.0), // Increased padding for better spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Days of the Week',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Slightly darker for better contrast
              ),
            ),

            // Improved hint text with a more descriptive placeholder
            Text(
              'Choose your preferred days of the week:',
              style: TextStyle(
                color: Colors.grey[700], // Light gray for description
                fontSize: 12,
              ),
            ),

            // Day of the Week Selector
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
              initialSelectedOptions: const [],
              onSelectionChanged: (selectedOptions) {
                // Optionally handle the selection change here
              },
            ),
          ],
        ),
      );

  // Number of bookings per hour selection for the profile
  Widget numberOfBookingsSelection() => Padding(
        padding:
            const EdgeInsets.all(16.0), // Increased padding for better spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Number of Bookings per Hour',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _numberOfBookingPerHour!.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9, // For 1 to 10
                    label: _numberOfBookingPerHour.toString(),
                    activeColor:
                        Colors.orange.shade900, // Slider color when active
                    inactiveColor:
                        Colors.grey.shade300, // Slider color when inactive
                    onChanged: (double value) {
                      setState(() {
                        _numberOfBookingPerHour = value.toInt();
                      });
                    },
                  ),
                ),
                const SizedBox(
                    width: 8), // Space between slider and number text
                Text(
                  '$_numberOfBookingPerHour',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 14, color: Colors.grey), // Info icon
                const SizedBox(width: 5),
                Text(
                  'Adjust the number of bookings allowed per hour.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
