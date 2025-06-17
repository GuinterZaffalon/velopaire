import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const HomeScreen());
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext build) {
    return Container(
        decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.3),
          spreadRadius: 2,
          blurRadius: 7,
          offset: Offset(0, 3),
        ),
      ],
      gradient: LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.bottomLeft,
        colors: [
          Color.fromRGBO(255, 72, 0, 1),
          Color.fromRGBO(42, 42, 89, 1),
        ],
      ),
      borderRadius: BorderRadius.circular(8),
    ));
  }
}
