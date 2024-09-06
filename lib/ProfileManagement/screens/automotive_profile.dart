import 'package:flutter/material.dart';

class AutomotiveProfile extends StatefulWidget {
  const AutomotiveProfile({super.key});

  @override
  State<AutomotiveProfile> createState() => _AutomotiveProfileState();
}

class _AutomotiveProfileState extends State<AutomotiveProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(title: Text('Profile', style: TextStyle(fontWeight: FontWeight.w900),), backgroundColor: Colors.grey.shade300,),

      body: Stack(
        clipBehavior:Clip.none,
        alignment: Alignment.center,
        children: [
          buildCoverImage(),
          Positioned(
            left: 20,
              bottom: -60,

              child: buildProfileImage())
        ],
      )

    );
  }

}

Widget buildCoverImage() => Container(
  color: Colors.grey,
  child: Image.network('https://www.erieinsurance.com/-/media/images/blog/articlephotos/2018/rentalcarlg.ashx?h=529&w=1100&la=en&hash=B6312A1CFBB03D75789956B399BF6B91E7980061',
    width: double.infinity,
    height: 250,
  fit: BoxFit.cover,
  ),


);

Widget buildProfileImage() => CircleAvatar(
  radius: 70,
  backgroundColor: Colors.grey.shade800,
  backgroundImage: NetworkImage(
      'https://cdn.vectorstock.com/i/500p/57/48/auto-repair-service-logo-badge-emblem-template-vector-49765748.jpg'
  ),
);


