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
    final serviceProviderId =
        user?.uid;

    return FutureBuilder<List<ServiceModel>>(
      future: _fetchServices(serviceProviderId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No services available.'));
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              SizedBox(
                height: 220,
                child: CarouselSlider.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index, realIndex) {
                    final service = services[index];
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
                                child: service.servicePicture.isNotEmpty
                                    ? Image.network(
                                        service.servicePicture,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                    : const Placeholder(),
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
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: service.name,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '  ${service.price} PHP',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: 220,
                    viewportFraction: 0.8,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
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
