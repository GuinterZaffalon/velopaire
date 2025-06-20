import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:velopaire/components/SpotifyNowPlaying.dart';
import 'package:velopaire/components/wheaterCoponent.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  LatLng? _userLocation;
  Stream<Position>? _positionStream;
  double _currentSpeed = 0.0;

  Position? _lastPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    await Permission.location.request();

    if (await Permission.location.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _lastPosition = position;
      });

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      );
      _positionStream!.listen((Position pos) {
        final newLocation = LatLng(pos.latitude, pos.longitude);

        setState(() {
          _currentSpeed = pos.speed >= 0 ? pos.speed : 0.0;
        });

        if (_lastPosition != null) {
          double distance = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            pos.latitude,
            pos.longitude,
          );

          setState(() {
            _userLocation = newLocation;
            _lastPosition = pos;
          });
        } else {
          setState(() {
            _userLocation = newLocation;
            _lastPosition = pos;
          });
        }

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(newLocation),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão de localização negada')),
      );
    }
  }

  String _formatDistance() {
    if (_currentSpeed < 1000) {
      return '${_currentSpeed.toStringAsFixed(0)}m';
    } else {
      return '${(_currentSpeed / 1000).toStringAsFixed(2)}km';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromRGBO(255, 72, 0, 1),
              Color.fromRGBO(42, 42, 89, 1),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  SizedBox(
                    width: 420,
                    child: _userLocation == null
                        ? const Center(child: CircularProgressIndicator())
                        : GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _userLocation!,
                              zoom: 18,
                            ),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            onMapCreated: (controller) => _mapController = controller,
                          ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.speed, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${(_currentSpeed * 3.6).toStringAsFixed(1)} km/h',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                SizedBox(
                    width: 360,
                    height: 140,
                    child: SpotifyNowPlayingScreen()),
                SizedBox(
                    width: 360,
                    height: 200,
                    child: WeatherComponent(
                        lat: _userLocation!.latitude,
                        long: _userLocation!.longitude))
              ],
            )
          ],
        ),
      ),
    );
  }
}
