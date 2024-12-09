import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

class MapViewScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapViewScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _mapController;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  final Logger logger = Logger();
  final Set<Marker> _markers = {};
  BitmapDescriptor? customIcon;


  @override
  void initState() {
    super.initState();
    _initializeLocationAndFetchShops();
    _loadCustomIcon();
  }

  Future<void> _loadCustomIcon() async {
    customIcon = await resizeAssetBitmapDescriptor('assets/images/customer.png', 150, 150);
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _controller.complete(controller);
  }

  Future<void> _initializeLocationAndFetchShops() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final position = await _getUserCurrentLocation();
      if (position != null) {
        _updateMapWithCurrentLocation(position);
      }
    } catch (e) {
      logger.e("Error initializing location: $e");
      setState(() {
        _hasError = true;
        _errorMessage = 'Unable to fetch your location.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<Position?> _getUserCurrentLocation() async {
    try {
      await Geolocator.requestPermission();
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      logger.e("Error getting location: $e");
      return null;
    }
  }

 Future<BitmapDescriptor> resizeAssetBitmapDescriptor(
      String assetPath, int width, int height) async {
    // Load the image from assets
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
      targetHeight: height,
    );
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    final resizedImage = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    // Convert the resized image to BitmapDescriptor
    return BitmapDescriptor.fromBytes(resizedImage!.buffer.asUint8List());
  }

  void _updateMapWithCurrentLocation(Position position) {

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("current_location"),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: "My Location"),
        ),
      );
    });
    _moveCameraToPosition(position.latitude, position.longitude);
  }

  Future<void> _moveCameraToPosition(double latitude, double longitude) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(latitude, longitude), zoom: 14.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    LatLng customerLocation = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Customer Location',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.grey.shade100,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: customerLocation,
              zoom: 14.0,
            ),
            markers: {
              ..._markers,
              Marker(
                markerId: const MarkerId('customer_location'),
                position: customerLocation,
                icon: customIcon ?? BitmapDescriptor.defaultMarker,
                infoWindow: const InfoWindow(
                  title: 'Customer Location',
                  snippet: 'This is the customer\'s address.',
                ),
              ),
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
          if (_hasError)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.red.withOpacity(0.8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
