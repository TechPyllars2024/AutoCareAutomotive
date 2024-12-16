import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:autocare_automotiveshops/Authentication/screens/onboardingPage3.dart';
import 'package:autocare_automotiveshops/ProfileManagement/screens/pinLocation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
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

class AutomotiveCompleteProfileScreen extends StatefulWidget {
  const AutomotiveCompleteProfileScreen({super.key, this.child});

  final Widget? child;

  @override
  State<AutomotiveCompleteProfileScreen> createState() =>
      _AutomotiveCompleteProfileScreenState();
}

class _AutomotiveCompleteProfileScreenState
    extends State<AutomotiveCompleteProfileScreen> {
  final Logger logger = Logger();
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
  int _numberOfBookingPerHour = 1;
  Map<String, Map<String, int>> remainingSlots = {};
  List<String>? _serviceSpecialization;
  late GoogleMapController mapController;
  LatLng? _initialLocation;
  User? user = FirebaseAuth.instance.currentUser;
  final MapService mapService = MapService();
  final Set<Marker> _markers = {};
  Timer? _locationUpdateTimer;

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
      _isLoading = true;
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
      _isLoading = false;
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
        _isLoading = false;
      });
    }
  }

  void _onTap(LatLng location) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              InitialMapPage(location: _locationController.text)),
    );
  }

  // Get the current user
  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
    }
  }

  // Load the profile data
  Future<void> _loadProfileData() async {
    if (uid != null) {
      final fetchedProfile =
          await _automotiveShopEditProfileServices.fetchProfileData(uid!);
      setState(() {
        editProfile = fetchedProfile;
        if (editProfile != null) {
          _coverImageUrl = editProfile!.coverImage;
          _profileImageUrl = editProfile!.profileImage;
          _shopNameController.text = editProfile!.shopName;
        }
      });
    }
  }

  // Pick the cover image
  Future<void> _pickCoverImage() async {
    final image = await _automotiveShopEditProfileServices.pickCoverImage();
    if (image != null) {
      setState(() {
        _coverImage = image;
      });
    }
  }

  // Pick the profile image
  Future<void> _pickProfileImage() async {
    final image = await _automotiveShopEditProfileServices.pickProfileImage();
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  // Save the profile
  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      List<String> emptyFields = [];

      if (_shopNameController.text.isEmpty) {
        emptyFields.add('Shop Name');
      }

      if (_locationController.text.isEmpty) {
        emptyFields.add('Location');
      }

      if (_openingTime == null || _closingTime == null) {
        emptyFields.add('Operating hours');
      }

      if(dropdownController.selectedOptionList.isEmpty || _serviceSpecialization!.isEmpty){
        emptyFields.add('Service Specialization');
      }

      if (daysOfTheWeekController.selectedOptionList.isEmpty) {
        emptyFields.add('Days of the Week');
      }

      if (_numberOfBookingPerHour == 0) {
        emptyFields.add('Number of Bookings per Hour');
      }

      if (_markers.isEmpty) {
        emptyFields.add('Markers');
      }

      if (_coverImage == null) {
        emptyFields.add('Cover Image');
      }

      if (_profileImage == null) {
        emptyFields.add('Profile Image');
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

      setState(() {
        _isLoading = true;
      });

      try {
        if (editProfile == null) {
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
              verificationStatus: 'Not Submitted',
              totalRatings: 0.0,
              numberOfRatings: 0,
              numberOfBookingsPerHour: _numberOfBookingPerHour,
              remainingSlots: remainingSlots);

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Onboardingpage3()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save profile'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double top = coverHeight - profileHeight / 2;
    double bottomPadding =
        MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 80.0;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Complete Your Shop Profile',
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
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
                  const SizedBox(height: 10),
                  buildInputs(),
                  dayOfTheWeekSelection(),
                  timeSelection(),
                  numberOfBookingsSelection(),
                  serviceSpecialization(),
                  buildSaveButton(),
                  const SizedBox(height: 10),
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
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Save button
  Widget buildSaveButton() => WideButtons(
        onTap: _saveProfile,
        text: 'Save',
      );

  // Top section
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

  // Inputs
  Widget buildInputs() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Name TextField with Label
            const Text('Shop Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            FocusScope(
              child: TextField(
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
            ),
            const SizedBox(height: 10),

            // Location TextField with Label
            const Text('Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            FocusScope(
              child: GooglePlaceAutoCompleteTextField(
                textEditingController: _locationController,
                googleAPIKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
                inputDecoration: InputDecoration(
                  hintText: 'Enter your location',
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange.shade900),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                debounceTime: 400,
                showError: false,
                containerVerticalPadding: 2,
                containerHorizontalPadding: 2,
                boxDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                countries: const ['ph'],
                isLatLngRequired: true,
                itemClick: (prediction) {
                  _locationController.text = prediction.description!;
                },
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
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
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

  // Cover image
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

  // Profile image
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

  // Time selection
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

  // Service specialization
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

  // Days of the week selection
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

  // Number of bookings per hour selection
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
                    value: _numberOfBookingPerHour.toDouble(),
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
