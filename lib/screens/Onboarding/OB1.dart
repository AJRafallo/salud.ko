import 'package:flutter/material.dart';
import 'package:saludko/screens/Onboarding/OB2.dart';
import 'package:saludko/screens/Opening/login_screen.dart';

class Onboarding1 extends StatelessWidget {
  const Onboarding1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Text(
                "Welcome to",
                style: TextStyle(
                  fontSize: 30,
                  //fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                "salud.ko",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF1A62B7),
                ),
              ),
              const Image(
                image: AssetImage('lib/assets/images/ob1.png'),
              ),
              const Text(
                "Naga City’s go-to app for all your health needs.",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              buildDotsIndicator(0),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyLogin(),
                        ),
                      );
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Onboarding2(),
                        ),
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF3C8BE9),
                            Color(0xFF134784),
                          ],
                          stops: [0.0, 1.0],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(25),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(70, 10, 70, 10),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDotsIndicator(int currentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                currentIndex == index ? const Color(0xFF1A62B7) : Colors.white,
            border: Border.all(
              color:
                  currentIndex == index ? const Color(0xFF1A62B7) : Colors.grey,
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}
