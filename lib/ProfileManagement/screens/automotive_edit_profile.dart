import 'package:autocare_automotiveshops/ProfileManagement/widgets/dropdown.dart';
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
      MaterialPageRoute(builder: (context) => AutomotiveEditProfile()),
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
              SizedBox(height: 20),
              buildInputs(),

              ServicesCarousel(),
              FeedbackSection(),


              //ServicesSection(),
            ],
          ),
        ),
      ),
    );
  }




  Widget buildTopSection(double top) {
    double rating = 3;
    int numberOfRating = 33;

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







  Widget ServicesCarousel() => Column(
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

              onPressed: () {}, icon: Icon(Icons.add))
        ],
      ),
    ),
    SizedBox(
      height: 220,
      child: CarouselView(
        itemExtent: 280,
        children: List.generate(10, (int index) {
          return Container(
            child: Stack(
              children: [
                // ClipRRect to add curved corners and crop the bottom
                Container(
                  margin: EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20), // Curve on the left
                      topRight: Radius.circular(20), // Curve on the right
                    ),
                    child: FractionallySizedBox(
                      heightFactor: 0.80,
                      // Crop to 75% height of the container
                      alignment: Alignment.topCenter,
                      // Align top portion
                      child: Image.network(
                        'https://soaphandcarwash.com/wp-content/uploads/2019/08/Soap-Hand-Car-Wash-13.jpg',
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

                    padding: EdgeInsets.all(10),
                    child: Text(
                      textAlign: TextAlign.center,
                      'Car Wash',
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
            color: Colors.orangeAccent.shade100,
          );
        }),
      ),
    ),
  ],
);

Widget FeedbackSection() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('Feedbacks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
    ),
    Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Curved edges
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns the text to the left
          children: [
            Text('Paul Vincent Lerado', style: TextStyle(fontWeight: FontWeight.bold),),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Text('I was impressed with the professionalism and efficiency of your team during my recent oil change and brake inspection. '
                  'However, the service took longer than expected, so providing more accurate time estimates would be helpful.'),
            ),
          ],
        ),
      ),
    ),
  ],
);}
