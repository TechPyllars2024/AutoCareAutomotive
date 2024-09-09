
import 'package:autocare_automotiveshops/ProfileManagement/widgets/text_field.dart';
import 'package:flutter/material.dart';


class AutomotiveEditProfile extends StatefulWidget {
  const AutomotiveEditProfile({super.key});

  @override
  State<AutomotiveEditProfile> createState() => _AutomotiveEditProfileState();
}

class _AutomotiveEditProfileState extends State<AutomotiveEditProfile> {
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

              servicesCarousel(),



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

  Widget buildCoverImage() => Container(
    color: Colors.grey,
    width: double.infinity,
    height: coverHeight,

  );

  Widget buildProfileImage() => Stack(
    children: [
      CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey.shade800,
        child: ClipOval(
          child: Icon(
            Icons.person,
            size: profileHeight,
            color: Colors.white,

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

              onPressed: () {}, icon: const Icon(Icons.add))
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
                // ClipRRect to add curved corners and crop the bottom
                Container(
                  margin: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20), // Curve on the left
                      topRight: Radius.circular(20), // Curve on the right
                    ),
                    child: FractionallySizedBox(
                      heightFactor: 0.80,
                      // Crop to 75% height of the container
                      alignment: Alignment.topCenter,
                      // Align top portion
                      child: Image.network(
                        'https://wallpapers.com/images/featured/blank-white-7sn5o1woonmklx1h.jpg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
                // Overlay Text in the bottom 25% space
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50, // Allocating 25% space for text

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
}

