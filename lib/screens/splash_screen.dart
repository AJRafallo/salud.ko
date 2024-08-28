import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saludko/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
  with SingleTickerProviderStateMixin {
  @override

  void initState(){
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed( const Duration( seconds: 3), (){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'salud.ko',),
        ));
    });
  }

  @override
  void dispose(){
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue,Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter)
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.health_and_safety_rounded,
              size:200,
              color: Colors.red,
              ),
            SizedBox(height: 20),
            Text("salud.ko ",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 30, 
            ),
            ),
          ],
        ),
      ),
    );
  }
}