import 'package:flutter/material.dart';
import 'package:saludko/screens/widget/appbar_2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class HotlinesScreen extends StatefulWidget {
  const HotlinesScreen({super.key});

  @override
  _HotlinesScreenState createState() => _HotlinesScreenState();
}

class _HotlinesScreenState extends State<HotlinesScreen> {
  int _currentPage = 0; // Keeps track of the current page index

  final List<Widget> _pages = [
    _buildPage1(),
    _buildPage2(),
    _buildPage3(),
  ];

  static Widget _buildPage1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Transform.translate(
            offset: const Offset(0, -5),
            child: const Icon(Icons.warning, size: 50, color: Colors.red),
          ),
          const SizedBox(height: 10),
          const Text(
            "FOR EMERGENCY PURPOSES ONLY",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                Text(
                  "Please be informed that dialing the following contact information is strictly for emergencies only.",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18),
                Text(
                  "Making false or prank calls is a serious offense.",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildPage2() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Under House Bill 3851:",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "\"An Act Penalizing Prank Callers to Emergency Hotlines\"",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontSize: 24,
              color: Color(0xffea80000),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                SizedBox(height: 5),
                Text(
                  "Individuals who intentionally make mischievous and malicious calls will face penalties, including potential jail time.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "This law recognizes the importance of maintaining accessible emergency hotlines and penalizes those who waste government resources and ridicule the system for personal gain.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildPage3() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, size: 50, color: Colors.red),
          SizedBox(height: 15),
          Text(
            "Please use Emergency Hotlines responsibly!",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show the welcome pop-up when the user enters the Hotlines screen
    Future.microtask(() => _showWelcomeDialog(context));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SaludkoAppBar(),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 5),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          "EMERGENCY HOTLINES",
                          style: TextStyle(
                            color: Color(0xFFDB0000),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                ...hotlines.map((hotline) {
                  return Column(
                    children: [
                      HotlineContainer(
                          hotline: hotline), // Pass the hotline data
                      const SizedBox(height: 10),
                      const Center(
                        child: SizedBox(
                          width: 340,
                          child: Divider(
                            color: Color(0xFFA1A1A1),
                            thickness: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Welcome dialog function
  void _showWelcomeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          backgroundColor: const Color(0xFFFFF0EE),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Transform.translate(
                      offset: const Offset(8.0, 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ),
                  ),
                  _pages[_currentPage],
                  const SizedBox(height: 30),

                  // Progress indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index <= _currentPage
                              ? Colors.black
                              : Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 1.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 13),

                  SizedBox(
                    width: double.infinity,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A62B7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            if (_currentPage < 2) {
                              _currentPage++;
                            } else {
                              Navigator.of(context).pop();
                            }
                          });
                        },
                        child: const Text(
                          "Next",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class Hotline {
  final String name;
  final List<String> numbers;

  Hotline({required this.name, required this.numbers});
}

final List<Hotline> hotlines = [
  Hotline(
    name: "ONE HOSPITAL COMMAND",
    numbers: ["+63 9617272688", "+63 977 2780385"],
  ),
  Hotline(
    name: "BICOL MEDICAL CENTER",
    numbers: ["+63 9617272688", "+63 977 2780385"],
  ),
  Hotline(
    name: "NAGA CITY HOSPITAL",
    numbers: ["+63 9617272688", "+63 977 2780385"],
  ),
  Hotline(
    name: "NICC HOSPITAL",
    numbers: ["+63 9617272688", "+63 977 2780385"],
  ),
];

// hotlines interface
class HotlineContainer extends StatelessWidget {
  final Hotline hotline;

  const HotlineContainer({super.key, required this.hotline});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        //margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFD1DBE1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotline.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hotline.numbers.join(" | "),
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                showDisclaimerDialog(context, hotline); // Pass the hotline data
              },
              icon: const Icon(Icons.call),
              color: const Color(0xFF188b15),
              iconSize: 40,
            ),
          ],
        ),
      ),
    );
  }

  // Disclaimer dialog function (Red pop-up)
  void showDisclaimerDialog(BuildContext context, Hotline hotline) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
            side: const BorderSide(color: Color(0xFFDB0000), width: 2),
          ),
          backgroundColor: const Color(0xFFFFF0EE),
          contentPadding: const EdgeInsets.all(0),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 300,
              maxHeight: 470,
            ),
            child: Stack(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 35),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 50,
                        color: Color(0xFFDB0000),
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "Are you sure you want to call?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 22,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          "You might have mistakenly tapped the call button.",
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text.rich(
                          TextSpan(
                            text: 'Please tap the ',
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: 'Proceed to call Button',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' if you want to proceed with the emergency call.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 22),
                      ElevatedButton(
                        onPressed: () {
                          // Close the red pop-up and open the green one
                          Navigator.of(context).pop();
                          showNumberSelectionDialog(context,
                              hotline); // Pass hotline to number selection
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDB0000),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text("Proceed to call"),
                      ),
                      const SizedBox(height: 3),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.black54,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 5.0,
                  top: 5.0,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    color: const Color(0xFFDB0000),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showNumberSelectionDialog(BuildContext context, Hotline hotline) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
            side: const BorderSide(color: Color(0xFF088205), width: 2),
          ),
          backgroundColor: const Color(0xFFF6FFF1),
          contentPadding: const EdgeInsets.all(0),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 300,
              maxHeight: 405,
            ),
            child: Stack(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Icon(
                        Icons.call,
                        size: 50,
                        color: Color(0xFF088205),
                      ),
                      const SizedBox(height: 15),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "CHOOSE ANY NUMBER TO CALL",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "You are calling ",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          hotline.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Call Buttons
                      ...hotline.numbers.map((number) {
                        return Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                var status = await Permission.phone.status;
                                if (status.isDenied) {
                                  status = await Permission.phone.request();
                                }

                                if (status.isGranted) {
                                  try {
                                    await FlutterPhoneDirectCaller.callNumber(
                                        number);
                                  } catch (e) {
                                    print("Error calling: $e");
                                  }
                                } else {
                                  print("Permission denied to make calls.");
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF088205),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text(number),
                            ),
                            if (number != hotline.numbers.last)
                              const SizedBox(
                                width: 150,
                                child: Divider(
                                  color: Color(0xFFA1A1A1),
                                  thickness: 1,
                                ),
                              ),
                          ],
                        );
                      }),

                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 5.0,
                  top: 5.0,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    color: const Color(0xFF088205),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
