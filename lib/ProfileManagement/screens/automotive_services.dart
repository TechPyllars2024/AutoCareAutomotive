import 'package:flutter/material.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/text_field.dart';

class Service {
  final String name;
  final String imageUrl;
  final double startingPrice; // Added this field

  Service(this.name, this.imageUrl, this.startingPrice); // Updated constructor
}

class AutomotiveServices extends StatefulWidget {
  const AutomotiveServices({super.key});

  @override
  State<AutomotiveServices> createState() => _AutomotiveServicesState();
}

class _AutomotiveServicesState extends State<AutomotiveServices> {
  List<Service> services = [
    Service('Car Wash', 'https://cardetailexpress.net/cdn/shop/articles/Man_Cleaning_a_Car.jpg', 200.0),
    Service('Oil Change', 'https://parkers-images.bauersecure.com/wp-images/177357/gettyimages-adding-engine-oil.jpg', 1500.0),
    Service('Tire Service', 'https://tyretreaders.co.uk/wp-content/uploads/2022/02/tyre-fitting.jpg', 5000.0),
    Service('Battery Check', 'https://tontio.com/wp-content/uploads/2019/03/car-battery-testing-multimeter_M.jpg', 800.0),
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  void _showServiceDetails(Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        title: Text(
          service.name,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
        ),
        content: Container(
          color: Colors.grey[200],
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  service.imageUrl,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width * 0.8,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Details about ${service.name}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 8.0),
              // TextFieldInput(
              //   hintText: 'Service Name',
              //   textInputType: TextInputType.text,
              //  // controller: _nameController,
              // ),
              // SizedBox(height: 8.0),
              // TextFieldInput(
              //   hintText: 'Starting Price',
              //   textInputType: TextInputType.number,
              //  // controller: _priceController,
              // ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Save',
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        title: Text(
          'Add New Service',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
        ),
        content: Container(
          color: Colors.grey[200],
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  // Handle image upload
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Center(
                    child: Icon(Icons.camera_alt, size: 50, color: Colors.grey[600]),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              // TextFieldInput(
              //   hintText: 'Service Name',
              //   textInputType: TextInputType.text,
              //  // controller: _nameController,
              // ),
              // SizedBox(height: 8.0),
              // TextFieldInput(
              //   hintText: 'Starting Price',
              //   textInputType: TextInputType.number,
              //  // controller: _priceController,
              // ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Handle the save action to add the new service
              double price = double.tryParse(_priceController.text) ?? 0.0;
              setState(() {
                services.add(Service(
                  _nameController.text,
                  'https://example.com/default_image.jpg', // Placeholder image URL
                  price,
                ));
              });
              Navigator.of(context).pop();
            },
            child: Text(
              'Add',
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: Text(
          'Services',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey[800]),
        ),
        backgroundColor: Colors.grey.shade300,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.grey[800]),
            onPressed: _addNewService,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 2 / 1, // 2:1 aspect ratio
            ),
            itemCount: services.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => _showServiceDetails(services[index]),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          bottomLeft: Radius.circular(16.0),
                        ),
                        child: Image.network(
                          services[index].imageUrl,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              services[index].name,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Starting Price: \P${services[index].startingPrice.toStringAsFixed(2)}', // Display price
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
