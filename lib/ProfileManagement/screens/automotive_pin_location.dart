import 'package:autocare_automotiveshops/ProfileManagement/screens/automotive_edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import '../services/pin_location.dart';

class MapPage extends StatefulWidget {
  final String location;
  const MapPage({super.key, this.child, required this.location});

  final Widget? child;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  final MapService mapService = MapService();
  String nameOfThePlace = '';
  LatLng? _centerPosition;
  User? user = FirebaseAuth.instance.currentUser;
  final Logger logger = Logger();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    _initializeLocationAndFetchStations();
  }

  Future<void> _initializeLocationAndFetchStations() async {
    // Get the initial position based on the location string
    final initialPosition = await _getUserCurrentLocation(widget.location);
    final currentPosition = await _getUserCurrentLocation1();

    if (initialPosition != null) {
      setState(() {
        // Convert the Position to a LatLng for map usage
        _centerPosition =
            LatLng(initialPosition.latitude, initialPosition.longitude);
      });
    } else {
      logger.i(
          "Failed to determine initial position for location: ${widget.location}");
      setState(() {
        _centerPosition =
            LatLng(currentPosition!.latitude, currentPosition.longitude);
      });
    }
  }

  Future<Position?> _getUserCurrentLocation1() async {
    try {
      await Geolocator.requestPermission();
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      logger.i("Error getting location: $e");
      return null;
    }
  }

  Future<Position?> _getUserCurrentLocation(String location) async {
    try {
      // Convert location string to coordinates
      List<Location> locations = await locationFromAddress(location);

      // Get the first result (most relevant)
      if (locations.isNotEmpty) {
        Location place = locations.first;
        logger.i("Location found: ${place.latitude}, ${place.longitude}");
        return Position(
          latitude: place.latitude,
          longitude: place.longitude,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 00,
          headingAccuracy: 00,
        );
      } else {
        logger.i("No coordinates found for location: $location");
        return null;
      }
    } catch (e) {
      logger.i("Error converting location: $e");
      return null;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _loadMarkers() async {
    if (user == null) return;

    final existingMarker = await mapService.fetchMarkerByUserId(user!.uid);

    setState(() {
      if (existingMarker != null) {
        _centerPosition =
            LatLng(existingMarker.latitude, existingMarker.longitude);
        logger.i(_centerPosition);
        nameOfThePlace = existingMarker.nameOfThePlace;
        _markers.add(
          Marker(
            markerId: MarkerId(existingMarker.latitude.toString() +
                existingMarker.longitude.toString()),
            position: _centerPosition!,
            infoWindow: InfoWindow(
              title: existingMarker.nameOfThePlace,
              snippet:
                  "Latitude: ${_centerPosition!.latitude}, Longitude: ${_centerPosition!.longitude}",
            ),
          ),
        );
      }
    });
  }

  void _confirmMarkerPlacement(BuildContext context) async {
    if (isLoading) return;

    final position = _centerPosition;

    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Marker Placement",
              style: TextStyle(fontSize: 18)),
          content: Text(
            "Do you want to add a marker at this location?\n\n"
            "Latitude: ${position!.latitude}\n"
            "Longitude: ${position.longitude}",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const AutomotiveEditProfileScreen()));

                // Proceed with marker placement
                final existingMarker =
                    await mapService.fetchMarkerByUserId(user!.uid);

                if (existingMarker != null &&
                    existingMarker.latitude != position.latitude &&
                    existingMarker.longitude != position.longitude) {
                  // Update existing marker's location
                  await mapService.updateMarker(
                      existingMarker, position, nameOfThePlace);

                  setState(() {
                    // Update the marker in the set
                    final updatedMarker = Marker(
                      markerId: MarkerId(position.toString()),
                      position: position,
                      infoWindow: InfoWindow(
                        title: nameOfThePlace,
                        snippet:
                            "Latitude: ${position.latitude}, Longitude: ${position.longitude}",
                      ),
                    );
                    _markers.removeWhere((marker) =>
                        marker.markerId.value ==
                        existingMarker.latitude.toString() +
                            existingMarker.longitude.toString());
                    _markers.add(updatedMarker);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Marker location updated!"),
                        backgroundColor: Colors.green),
                  );
                }
                setState(() {
                  isLoading = false;
                });
              },
              child: Text("Confirm",
                  style: TextStyle(color: Colors.orange.shade900)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text('Pin Your Location',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            )),
      ),
      body: _centerPosition == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text("Getting your location...",
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ) // Show loading state with message
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  onCameraMove: (position) {
                    setState(() {
                      _centerPosition = position.target;
                    });
                  },
                  initialCameraPosition: CameraPosition(
                    target: _centerPosition!,
                    zoom: 20.0,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                ),
                Center(
                  child: Icon(
                    Icons.location_pin,
                    color: Colors.red.withOpacity(0.7),
                    size: 50.0,
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading
            ? null
            : () async {
                _confirmMarkerPlacement(context);
              },
        backgroundColor: isLoading ? Colors.grey : Colors.orange.shade900,
        child: isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Icon(Icons.check, color: Colors.white),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
    );
  }
}
