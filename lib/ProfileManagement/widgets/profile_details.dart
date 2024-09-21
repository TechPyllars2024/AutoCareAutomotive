import 'package:flutter/material.dart';
import '../models/automotive_shop_profile_model.dart';

class ProfileDetails extends StatelessWidget {
  final AutomotiveProfileModel? profile;

  const ProfileDetails({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile?.shopName ?? 'Shop Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  profile?.location ?? 'Location',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.orange),
                const SizedBox(width: 4),
                // Convert the list to a comma-separated string if it's a list
                Text(
                  (profile?.daysOfTheWeek.join(', ') ?? 'Days of the Week'),
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.orange),
                const SizedBox(width: 4),
                // Ensure operationTime is a String
                Text(
                  profile?.operationTime ?? 'Operation Time',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.check, color: Colors.orange),
                const SizedBox(width: 4),
                // Ensure operationTime is a String
                Text(
                  (profile?.serviceSpecialization.join(', ') ?? 'Specialization'
                      ''),
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
