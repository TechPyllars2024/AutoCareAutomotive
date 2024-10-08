import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../Service Management/models/services_model.dart';
import '../../Service Management/services/service_management.dart';

class ServicesCarousel extends StatelessWidget {
  const ServicesCarousel({super.key, this.child});

  final Widget? child;

  Future<List<ServiceModel>> _fetchServices(String serviceProviderId) async {
    final serviceManagement = ServiceManagement();
    final servicesStream = serviceManagement.fetchServices(serviceProviderId);
    final snapshot = await servicesStream.first;
    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final serviceProviderId = user?.uid;

    return FutureBuilder<List<ServiceModel>>(
      future: _fetchServices(serviceProviderId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: const Center(child: Text('No service available yet.')),
          );
        } else {
          final services = snapshot.data!;

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      'Services',
                      style: TextStyle(
                        fontSize: 18, // Font size adjusted
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              SizedBox(
                height: 220, // Keeps the carousel height consistent
                child: CarouselSlider.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index, realIndex) {
                    final service = services[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15), // Border radius
                        color: Colors.grey.shade200, // Grey background color
                      ),
                      margin: const EdgeInsets.all(5),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  color: Colors.grey.shade300, // Background color for image section
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: service.servicePicture.isNotEmpty
                                    ? Image.network(
                                  service.servicePicture,
                                  height: 100,
                                  width: double.infinity, // Ensure the image fills the container's width
                                  fit: BoxFit.cover, // Cover ensures the image fills the container
                                )
                                    : const Placeholder(),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      service.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16, // Font size for service name
                                      ),
                                    ),
                                    Text(
                                      'Starts at Php ${service.price}',
                                      style: const TextStyle(
                                        fontSize: 13, // Font size for price
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: 220, // Carousel height
                    viewportFraction: 0.8, // Width of each item relative to the viewport
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3), // Automatic slide interval
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
