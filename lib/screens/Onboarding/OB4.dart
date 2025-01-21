import 'package:flutter/material.dart';
import 'package:saludko/screens/Onboarding/OB3.dart';
import 'package:saludko/screens/Opening/login_screen.dart';

class Onboarding4 extends StatelessWidget {
  const Onboarding4({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! < 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyLogin()),
              );
            } else if (details.primaryVelocity != null &&
                details.primaryVelocity! > 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Onboarding3()),
              );
            }
          },
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(
                        image: AssetImage('lib/assets/images/ob4.png'),
                      ),
                      const Text(
                        "EMERGENCY CONTACTS AT YOUR FINGERTIPS",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A62B7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          "Access important emergency numbers in Naga City instantly. Stay prepared in case of any urgent health situations.",
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      const SizedBox(height: 50),
                      buildDotsIndicator(3),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Onboarding3(),
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
                            builder: (context) => const MyLogin(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF3C8BE9), Color(0xFF134784)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 10,
                        ),
                        child: const FittedBox(
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
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
