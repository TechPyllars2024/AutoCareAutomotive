import 'package:autocare_automotiveshops/ProfileManagement/widgets/text_field.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/timeSelection.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/dropdown.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/daysOftheWeek.dart';
import 'package:get/get.dart'; // Import GetX for state management

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

  final double coverHeight = 220;
  final double profileHeight = 130;

  void editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AutomotiveEditProfile()),
    );
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
              servicesCarousel(),
              serviceSpecialization(),
              //ServicesSection(),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget buildInputs() => const Column(
        children: [
          TextFieldInput(
            //icon: Icons.email,
            //textEditingController: emailController,
            hintText: 'Name',
            textInputType: TextInputType.emailAddress,
          ),
          TextFieldInput(
            //icon: Icons.email,
            //textEditingController: emailController,
            hintText: 'Location',
            textInputType: TextInputType.emailAddress,
          ),
        ],
      );

  Widget buildCoverImage() => Stack(
        children: [
          Container(
            color: Colors.grey.shade600,
            width: double.infinity,
            height: coverHeight,
          ),
          Positioned(
            bottom: 10, // Positioning from the bottom
            right: 10, // Positioning from the right
            child: Container(
              width: 50, // Width of the circular container
              height: 50, // Height of the circular container
              decoration: const BoxDecoration(
                color: Colors.grey, // Background color of the circle
                shape: BoxShape.circle, // Circular shape
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white, // Set the color of the icon
                  size: 24, // Size of the icon
                ),
                onPressed: () {
                  // Handle camera button press logic
                  print('Camera icon pressed');
                },
              ),
            ),
          ),
        ],
      );

  Widget buildProfileImage() => Stack(
        children: [
          CircleAvatar(
            radius: profileHeight / 2,
            backgroundColor: Colors.grey.shade400,
            child: ClipOval(
              child: Icon(
                Icons.person,
                size: profileHeight,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            // Move the container slightly outside the profile image's bottom edge
            right: 0,
            // Move the container slightly outside the profile image's right edge
            child: Container(
              width: 50, // Match the width of the cover image container
              height: 50, // Match the height of the cover image container
              decoration: const BoxDecoration(
                color: Colors.grey, // Background color of the circle
                shape: BoxShape.circle, // Circular shape
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white, // Set the color of the icon
                  size:
                      24, // Adjust the size of the icon to fit well within the container
                ),
                onPressed: () {
                  // Handle camera button press logic
                  print('Camera icon pressed for profile image');
                },
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
                        child: TimePickerDisplay(initialTime: TimeOfDay.now()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Save'),
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
                        child: TimePickerDisplay(initialTime: TimeOfDay.now()),
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
                'Air-conditioninf',
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
