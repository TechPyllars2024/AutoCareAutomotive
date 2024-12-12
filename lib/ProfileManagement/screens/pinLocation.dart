import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import '../models/automotive_marker_model.dart';
import '../services/pin_location.dart';

class InitialMapPage extends StatefulWidget {
  final String location;
  const InitialMapPage({super.key, this.child, required this.location});

  final Widget? child;

  @override
  State<InitialMapPage> createState() => _InitialMapPageState();
}

class _InitialMapPageState extends State<InitialMapPage> {
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
        _centerPosition = LatLng(initialPosition.latitude, initialPosition.longitude);
      });
    } else {
      logger.i("Failed to determine initial position for location: ${widget.location}");
      setState(() {
        _centerPosition = LatLng(currentPosition!.latitude, currentPosition.longitude);
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

  Future<void> _getPlaceName(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        final placeName =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";

        setState(() {
          nameOfThePlace = placeName;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Place: $placeName")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _confirmMarkerPlacement(BuildContext context) async {
    if (isLoading) return;

    final position = _centerPosition;

    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Confirm Marker Placement",
            style: TextStyle(fontSize: 18),
          ),
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
                Navigator.of(context).pop();

                // Proceed with marker placement
                Navigator.of(context).pop();

                final existingMarker =
                    await mapService.fetchMarkerByUserId(user!.uid);

                if (existingMarker != null) {
                  // Update existing marker
                  await mapService.updateMarker(
                      existingMarker, position, nameOfThePlace);

                  setState(() {
                    // Remove the old marker
                    _markers.removeWhere((marker) =>
                        marker.markerId.value ==
                        existingMarker.latitude.toString() +
                            existingMarker.longitude.toString());

                    nameOfThePlace = _getPlaceName(position) as String;
                    // Add the updated marker
                    _markers.add(
                      Marker(
                        markerId: MarkerId(position.toString()),
                        position: position,
                        infoWindow: InfoWindow(
                          title: nameOfThePlace,
                          snippet:
                              "Latitude: ${position.latitude}, Longitude: ${position.longitude}",
                        ),
                      ),
                    );
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Marker updated!")),
                  );

                  // Pop the dialog or screen
                  Navigator.of(context).pop();

                  // Ensure loading state is reset
                  setState(() {
                    isLoading = false;
                  });
                } else {
                  // Add a new marker
                  final marker = MarkerModel(
                    serviceProviderUid: user!.uid,
                    nameOfThePlace: nameOfThePlace,
                    latitude: position.latitude,
                    longitude: position.longitude,
                    title: "Custom Marker",
                    snippet:
                        "Latitude: ${position.latitude}, Longitude: ${position.longitude}",
                  );

                  await mapService.addMarker(marker);

                  setState(() {
                    nameOfThePlace = _getPlaceName(position) as String;
                    _markers.add(
                      Marker(
                        markerId: MarkerId(position.toString()),
                        position: position,
                      ),
                    );
                    isLoading = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Marker added!")),
                  );
                }

                setState(() {
                  isLoading = false; // Reset loading state
                });
              },
              child: Text(
                "Confirm",
                style: TextStyle(color: Colors.orange.shade900),
              ),
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
            : const Icon(Icons.check),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat, // Center the FAB
    );
  }
}
