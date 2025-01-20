import 'package:flutter/material.dart';
import 'package:saludko/screens/Onboarding/OB1.dart';
import 'package:saludko/screens/Onboarding/OB3.dart';

class Onboarding2 extends StatelessWidget {
  const Onboarding2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage('lib/assets/images/ob2.png'),
                ),
                const Text(
                  "HEALTHCARE INFORMATION ACCESS",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A62B7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "Easily find doctors, hospitals, and clinics in Naga City. Get the information you need, all in one place.",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 20),
                buildDotsIndicator(1),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Onboarding1(),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.chevron_left,
                            size: 20,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Onboarding3(),
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
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 85,
                          vertical: 10,
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
