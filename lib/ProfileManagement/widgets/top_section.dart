import 'package:flutter/material.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import '../models/automotive_shop_profile_model.dart';

class TopSection extends StatelessWidget {
  final double coverHeight;
  final double profileHeight;
  final AutomotiveProfileModel? profile;
  final double rating;
  final int numberOfRating;

  const TopSection({
    super.key,
    required this.coverHeight,
    required this.profileHeight,
    required this.profile,
    this.rating = 3,
    this.numberOfRating = 33,
  });

  @override
  Widget build(BuildContext context) {
    final double top = coverHeight - profileHeight / 2;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: profileHeight / 2),
          child: buildCoverImage(profile),
        ),
        Positioned(
          left: 20,
          top: top,
          child: buildProfileImage(profile),
        ),
        Positioned(
          right: 20,
          top: coverHeight + 10,
          child: Row(
            children: [
              PannableRatingBar(
                rate: rating,
                items: List.generate(
                  5,
                      (index) => const RatingWidget(
                    selectedColor: Colors.orange,
                    unSelectedColor: Colors.grey,
                    child: Icon(
                      Icons.star,
                      size: 20,
                    ),
                  ),
                ),
                onChanged: (value) {},
              ),
              const SizedBox(width: 5),
              Text(
                '$numberOfRating ratings',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCoverImage(AutomotiveProfileModel? profile) => Container(
    color: Colors.grey.shade700,
    width: double.infinity,
    height: coverHeight,
    child: profile != null && profile.coverImage.isNotEmpty
        ? Image.network(
      profile.coverImage,
      fit: BoxFit.cover,
    )
        : Container(),
  );

  Widget buildProfileImage(AutomotiveProfileModel? profile) => CircleAvatar(
    radius: profileHeight / 2,
    backgroundColor: Colors.grey.shade600,
    child: profile != null && profile.profileImage.isNotEmpty
        ? ClipOval(
      child: Image.network(
        profile.profileImage,
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
  );
}
