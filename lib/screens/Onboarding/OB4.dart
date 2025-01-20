import 'package:flutter/material.dart';
import 'package:saludko/screens/Onboarding/OB3.dart';
import 'package:saludko/screens/Opening/login_screen.dart';

class Onboarding4 extends StatelessWidget {
  const Onboarding4({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: screenHeight * 0.35,
                child: const Image(
                  image: AssetImage('lib/assets/images/ob4.png'),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                child: Text(
                  "EMERGENCY CONTACTS AT YOUR FINGERTIPS",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A62B7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                child: Text(
                  "Access important emergency numbers in Naga City instantly. Stay prepared in case of any urgent health situations.",
                  style: TextStyle(fontSize: 17),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 20),
              buildDotsIndicator(3),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Onboarding3()),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(
                          Icons.chevron_left,
                          size: 18,
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
                            builder: (context) => const MyLogin()),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.2,
                        vertical: 10,
                      ),
                      child: const Text(
                        'Get Started',
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
