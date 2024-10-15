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
                 Icon(Icons.location_on, color: Colors.orange.shade900, size: 15,),
                const SizedBox(width: 4),
                Text(
                  profile?.location ?? 'Location',

                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: Colors.orange.shade900,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Expanded(  // or Flexible
                  child: Text(
                    (profile?.daysOfTheWeek.join(', ') ?? 'Days of the Week'),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                 Icon(Icons.schedule, color: Colors.orange.shade900, size: 15,),
                const SizedBox(width: 4),
                Text(
                  profile?.operationTime ?? 'Operation Time',
                ),
              ],
            ),
            const SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Icon(Icons.check, color: Colors.orange.shade900, size: 15,),
                    const SizedBox(width: 4),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (profile?.serviceSpecialization.join(', ') ?? 'Specialization'
                                ''),
                            overflow: TextOverflow.visible,
                            maxLines: 2,
                            softWrap: true,

                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
