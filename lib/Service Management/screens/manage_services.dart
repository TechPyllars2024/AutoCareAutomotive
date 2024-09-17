import 'dart:io';
import 'package:autocare_automotiveshops/Service%20Management/models/category_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/services_model.dart';
import '../services/image_service.dart';
import '../services/service_management.dart';

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
              title: Text(service == null ? 'Add Service' : 'Update Service'),
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
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButton<String>(
                    value: category,
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
                  ElevatedButton(
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
                    child: const Text('Pick Image'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text(service == null ? 'Add' : 'Update'),
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        priceController.text.isNotEmpty) {
                      if (service == null) {
                        // Add new service
                        await _serviceManagement.addService(
                          serviceProviderId: user!.uid,
                          name: nameController.text,
                          description: descriptionController.text,
                          price: double.parse(priceController.text),
                          category: category,
                          imageFile: _selectedImage,
                        );
                      } else {
                        // Update existing service
                        await _serviceManagement.updateService(
                          serviceId: service.serviceId,
                          name: nameController.text,
                          description: descriptionController.text,
                          price: double.parse(priceController.text),
                          category: category,
                          imageFile: _selectedImage,
                        );
                      }
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
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.of(context).pop();
                  _addOrUpdateService(context, service: service);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
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
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: Text(
          'Manage Services',
          style:
              TextStyle(fontWeight: FontWeight.w900, color: Colors.grey[800]),
        ),
        backgroundColor: Colors.grey.shade300,
        elevation: 0,
      ),
      body: StreamBuilder<List<ServiceModel>>(
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
                crossAxisCount: 2, // Number of items per row
                crossAxisSpacing: 10, // Horizontal spacing between items
                mainAxisSpacing: 10, // Vertical spacing between items
                childAspectRatio: 3 / 4, // Adjust this for image and text alignment
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return GestureDetector(
                  onTap: () => _showServiceOptions(
                      context, service), // Method for showing service options
                  child: Card(
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
                              service
                                  .servicePicture, // Image URL from the service
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback in case the image fails to load
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
                                  fontSize: 18,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 1, // Limit to a single line
                                overflow:
                                    TextOverflow.ellipsis, // Handle overflow
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                '${service.price.toStringAsFixed(2)} PHP',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                service.description,
                                style: TextStyle(
                                  fontSize: 12,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateService(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
