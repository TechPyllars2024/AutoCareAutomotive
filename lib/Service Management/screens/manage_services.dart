import 'dart:io';
import 'package:autocare_automotiveshops/Service%20Management/models/category_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../ProfileManagement/services/get_verified_services.dart';
import '../models/services_model.dart';
import '../services/image_service.dart';
import '../services/service_management.dart';
import '../widgets/service_status_alert_box.dart';

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key, this.child});

  final Widget? child;

  @override
  State<ServiceManagementScreen> createState() =>
      _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final ServiceManagement _serviceManagement = ServiceManagement();
  final ImageService _imageService = ImageService();
  File? _selectedImage;
  String category = CategoryList.categories[0];
  bool _isLoading = false;

  void _addOrUpdateService(BuildContext context, {ServiceModel? service}) {
    final nameController = TextEditingController(text: service?.name);
    final descriptionController =
        TextEditingController(text: service?.description);

    final priceController =
        TextEditingController(text: service?.price.toString());

    String category = service?.category.isNotEmpty == true
        ? service!.category[0]
        : 'Electrical Works';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // StatefulBuilder allows updating the dialog UI.
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(service == null ? 'Add Service' : 'Update Service', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      hintText: 'Enter price greater than 0',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: (value) {
                      final price = double.tryParse(value);
                      if (price != null && price <= 0) {
                        priceController.clear(); // Clear the input if invalid
                      }
                    },
                  ),
                  DropdownButton<String>(
                    value: category,
                    isExpanded: true,
                    onChanged: (newValue) {
                      setState(() {
                        category = newValue!;
                      });
                    },
                    items: CategoryList.categories
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      minimumSize: const Size(250, 45),
                      backgroundColor: Colors.deepOrange.shade700,
                    ),
                    onPressed: () async {
                      // Let the user pick an image source
                      final source = await _pickImageSource();
                      if (source != null) {
                        File? pickedImage =
                            await _imageService.pickImage(source);
                        setState(() {
                          _selectedImage = pickedImage;
                        });
                      }
                    },
                    child: const Text('Pick Image', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: _isLoading
                      ? const CircularProgressIndicator() // Show loading indicator
                      : Text(service == null ? 'Add' : 'Update', style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        priceController.text.isNotEmpty &&
                        priceController.text != '0.00' &&
                        _selectedImage != null) {
                      setState(() {
                        _isLoading = true; // Set loading state to true
                      });

                      if (service == null) {
                        await _serviceManagement.addService(
                          serviceProviderId: user!.uid,
                          name: nameController.text,
                          description: descriptionController.text,
                          price: double.parse(priceController.text),
                          category: category,
                          imageFile: _selectedImage,
                        );
                      } else {
                        await _serviceManagement.updateService(
                          serviceId: service.serviceId,
                          name: nameController.text,
                          description: descriptionController.text,
                          price: double.parse(priceController.text),
                          category: category,
                          imageFile: _selectedImage,
                        );
                      }

                      setState(() {
                        _isLoading = false; // Set loading state to false
                      });

                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Pick an image source
  Future<ImageSource?> _pickImageSource() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Camera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_album),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        );
      },
    );
  }

  // Service options dialog
  void _showServiceOptions(BuildContext context, ServiceModel service) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(service.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.grey),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.of(context).pop();
                  _addOrUpdateService(context, service: service);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () async {
                  await _serviceManagement.deleteService(service.serviceId);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Manage Services',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey[800]),
        ),
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
      ),
      body: StreamBuilder<String?>(
        stream: GetVerifiedServices().fetchStatus(user!.uid).asStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching verification status'));
          }

          String status = snapshot.data ?? 'Pending';
          bool isVerified = status == 'Verified';

          return Column(
            children: [
              ServiceStatusAlertBox(isVerified: isVerified), // Use the new widget
              Expanded(
                child: StreamBuilder<List<ServiceModel>>(
                  stream: _serviceManagement.fetchServices(user!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No services available'));
                    }

                    final services = snapshot.data!;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 3 / 4,
                        ),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          return GestureDetector(
                            onTap: () => _showServiceOptions(context, service),
                            child: Card(
                              color: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16.0),
                                        topRight: Radius.circular(16.0),
                                      ),
                                      child: Image.network(
                                        service.servicePicture,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.broken_image,
                                            size: 60,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.grey[800],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          '${service.price.toStringAsFixed(2)} PHP',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          service.description,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade900,
        onPressed: () => _addOrUpdateService(context),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
          weight: 20,
        ),
      ),
    );
  }
}
