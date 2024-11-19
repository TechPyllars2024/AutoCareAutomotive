import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/automotive_marker_model.dart';
import '../services/pin_location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, this.child});

  final Widget? child;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  final LatLng _initialPosition =
      const LatLng(10.3157, 123.8854); // Cebu, PH coordinates
  final MapService mapService = MapService();
  String nameOfThePlace = '';
  LatLng? _tempMarkerPosition;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _loadMarkers() async {
    final markers = await mapService.fetchMarkersFromFirestore();
    setState(() {
      _markers.addAll(markers);
    });
  }

  Future<void> _getPlaceName(LatLng position) async {
    try {
      // Fetch place details using latitude and longitude
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        // Construct a readable address
        final placeName =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";

        setState(() {
          nameOfThePlace = placeName;
        });

        // Display the address
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

  void _startAddingMarker(LatLng initialPosition) {
    setState(() {
      _tempMarkerPosition = initialPosition;
      _markers.add(
        Marker(
          markerId: const MarkerId("temporary_marker"),
          position: initialPosition,
          draggable: true,
          onDragEnd: (newPosition) {
            _tempMarkerPosition = newPosition; // Update temporary position
          },
          infoWindow: const InfoWindow(title: "Drag to your location"),
        ),
      );
    });
  }

  void _confirmMarkerPlacement(BuildContext context) {
    if (_tempMarkerPosition == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Marker Placement"),
          content: Text(
            "Do you want to add a marker at this location?\n\n"
            "Name of the place: $nameOfThePlace\n\n"
            "Latitude: ${_tempMarkerPosition!.latitude}\n"
            "Longitude: ${_tempMarkerPosition!.longitude}",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (_tempMarkerPosition == null) return;

                try {
                  // Fetch the place name for the selected location
                  await _getPlaceName(_tempMarkerPosition!);

                  // Create a MarkerModel instance
                  final marker = MarkerModel(
                    nameOfThePlace: nameOfThePlace,
                    latitude: _tempMarkerPosition!.latitude,
                    longitude: _tempMarkerPosition!.longitude,
                    title: "Custom Marker",
                    snippet:
                        "Latitude: ${_tempMarkerPosition!.latitude}, Longitude: ${_tempMarkerPosition!.longitude}",
                  );

                  // Add the marker to Firestore
                  await mapService.addMarker(marker);

                  setState(() {
                    // Add the marker to the map
                    _markers.add(
                      Marker(
                        markerId: MarkerId(_tempMarkerPosition.toString()),
                        position: _tempMarkerPosition!,
                        infoWindow: InfoWindow(
                          title: nameOfThePlace,
                          snippet:
                              "Latitude: ${_tempMarkerPosition!.latitude}, Longitude: ${_tempMarkerPosition!.longitude}",
                        ),
                      ),
                    );

                    // Clear the temporary marker
                    _tempMarkerPosition = null;
                    _markers.removeWhere(
                        (m) => m.markerId.value == "temporary_marker");
                  });

                  // Close the dialog after successful marker addition
                  Navigator.of(context).pop();
                } catch (e) {
                  // Handle any errors that occur during the process
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error adding marker: $e")),
                  );
                }
              },
              child: const Text("Confirm"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Integration'),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          markers: _markers,
          onTap: (position) {
            _startAddingMarker(position); // Start adding a marker
          },
          initialCameraPosition: CameraPosition(
            target: _initialPosition,
            zoom: 15.0,
          ),
        ),
      ),
      floatingActionButton: _tempMarkerPosition != null
          ? FloatingActionButton(
              onPressed: () {
                _confirmMarkerPlacement(context); // Confirm placement
              },
              child: const Icon(Icons.check),
            )
          : null,
    );
  }
}
