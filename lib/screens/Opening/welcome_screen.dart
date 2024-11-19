import 'package:flutter/material.dart';
import 'package:saludko/screens/Opening/login_screen.dart';
import 'package:saludko/screens/Opening/signup_screen.dart';
import 'package:saludko/screens/Opening/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'salud.ko',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: [
                const Icon(
                  Icons.monitor_heart_rounded,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to salud.ko',
                  style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 250),
                ElevatedButton(
                  onPressed: () {
                    if (!mounted) {
                      return; 
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyLogin()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A62B7),
                      fixedSize: const Size(300, 50)),
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      if (!mounted) {
                        return; 
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MySignup()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A62B7),
                        fixedSize: const Size(300, 50)),
                    child: const Text(
                      'Signup',
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
