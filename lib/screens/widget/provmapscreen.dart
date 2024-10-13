import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


class ProvMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const ProvMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });
  
  
  @override
  _ProvMapScreenState createState() => _ProvMapScreenState();
  
}
  class _ProvMapScreenState extends State<ProvMapScreen> {
  GoogleMapController? mapController;

  // Initialize variables for the user's location
  double? userLatitude;
  double? userLongitude;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Get the current location when the screen is initialized
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if the location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled, handle appropriately
        return;
      }

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Handle the case when the user denies permission
          return;
        }
      }

      // Get the current location
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        userLatitude = position.latitude;
        userLongitude = position.longitude;
      });
    } catch (e) {
      // Handle exceptions (e.g., permission denied, service disabled)
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    // Use the user's location or the provided latitude/longitude
    double targetLatitude = userLatitude ?? widget.latitude;
    double targetLongitude = userLongitude ?? widget.longitude;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Map Location',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: const Color(0xFF1A62B7),
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(targetLatitude, targetLongitude),
          zoom: 17,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('provider_location'),
            position: LatLng(targetLatitude, targetLongitude),
            infoWindow: const InfoWindow(title: 'Healthcare Provider Location'),
          ),
        
          if (userLatitude != null && userLongitude != null) // Only show if location is available
            Marker(
              markerId: const MarkerId('user'),
              position: LatLng(userLatitude!, userLongitude!),
              infoWindow: const InfoWindow(title: 'Your Location'),
            ),
        },
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}




