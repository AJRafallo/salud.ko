import 'package:flutter/material.dart';
import 'package:saludko/screens/Onboarding/OB2.dart';
import 'package:saludko/screens/Onboarding/OB4.dart';

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('lib/assets/images/ob3.png'),
              ),
              const Text(
                "MANAGE YOUR MEDICAL RECORDS",
                style: TextStyle(
                  fontSize: 28,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A62B7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                child: Text(
                  "Keep all your health records organized. From prescriptions to test results, manage everything with ease. Set medication reminders to monitor your health.",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              buildDotsIndicator(2),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      // Navigate to the last page (get started)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Onboarding2()),
                      );
                    },
                    child: const Text(
                      'Back',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to the next page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Onboarding4()),
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF3C8BE9), // Color at 0%
                            Color(0xFF134784), // Color at 100%
                          ],
                          stops: [0.0, 1.0], // Stops at 0% and 100%
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.all(
                            Radius.circular(25)), // Optional: Rounded corners
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
            color: currentIndex == index ? Colors.blue : Colors.grey,
          ),
        );
      }),
    );
  }
}