import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saludko/screens/widget/appbar_2.dart';

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
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0), // Padding on left and right
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Ensure the column takes up only required space
        crossAxisAlignment: CrossAxisAlignment.center, // Aligns center
        mainAxisAlignment: MainAxisAlignment.start, // Align to top
        children: [
          // Use Transform to nudge the icon upwards if needed
          Transform.translate(
            offset: const Offset(
                0, -5), // Adjust the -10 to fine-tune vertical position
            child: const Icon(Icons.warning, size: 50, color: Colors.red),
          ),

          const SizedBox(height: 10), // Leave space below icon as required
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
      padding:
          EdgeInsets.symmetric(horizontal: 16.0), // Padding on left and right
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
      padding:
          EdgeInsets.symmetric(horizontal: 16.0), // Padding on left and right
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, size: 50, color: Colors.red), // Emergency icon
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
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
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
                      SizedBox(height: 25),

                      // First Container
                      HotlineContainer(),

                      SizedBox(height: 20),

                      Center(
                        child: SizedBox(
                          width: 340,
                          child: Divider(
                            color: Color(0xFFA1A1A1),
                            thickness: 1,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Second Container
                      HotlineContainer(),
                    ],
                  ),
                ),
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
          contentPadding:
              const EdgeInsets.fromLTRB(20, 0, 20, 10), // Set top padding to 0
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button with custom position
                  Align(
                    alignment: Alignment.topRight,
                    child: Transform.translate(
                      offset: const Offset(
                          8.0, 8.0), // Move closer to the top-right
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            size: 18), // Smaller icon size
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ),
                  ),
                  _pages[_currentPage], // Display the current page content
                  const SizedBox(height: 30), // Reduced space before dots

                  // Progress indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 2), // Reduced spacing
                        width: 8, // Smaller width
                        height: 8, // Smaller height
                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? Colors.black // Black for the current page
                              : Colors.white, // White for unselected dots
                          border: Border.all(
                            color: Colors.black,
                            width: 1.5, // Thicker border for hollow dots
                          ),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 13), // Closer to the next button

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    child: SizedBox(
                      height: 50, // Set your desired height here
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
                              _currentPage++; // Go to next page
                            } else {
                              Navigator.of(context)
                                  .pop(); // Close dialog after last page
                            }
                          });
                        },
                        child: const Text(
                          "Next", // Button text
                          style: TextStyle(
                              color: Colors.white), // White text color
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8), // Add space after the button
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// hotlines interface
class HotlineContainer extends StatelessWidget {
  const HotlineContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFD1DBE1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ONE HOSPITAL COMMAND",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "+63 911 12345678 | +63 911 12345678",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  showDisclaimerDialog(context);
                },
                icon: const Icon(Icons.call),
                color: const Color(0xFF188b15),
                iconSize: 40,
              ),
            ],
          ),
        );
      },
    );
  }

  // Disclaimer dialog function (Red pop-up)
  void showDisclaimerDialog(BuildContext context) {
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
                            fontSize: 13, // Adjust font size
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
                          showNumberSelectionDialog(context);
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

  // Number selection dialog with call action (Green pop-up)
  void showNumberSelectionDialog(BuildContext context) {
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
              // Reduce max height to minimize space after the Cancel button
              maxHeight: 410, // Adjust this value as needed
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 20), // Reduce vertical padding
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      const Icon(
                        Icons.call,
                        size: 50,
                        color: Color(0xFF088205),
                      ),
                      const SizedBox(height: 15), // Reduced space here
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
                      const SizedBox(height: 10), // Reduced space here

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
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "ONE HOSPITAL COMMAND",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: () async {
                          const phoneNumber = '+6391112345678';
                          final Uri launchUri = Uri(
                            scheme: 'tel',
                            path: phoneNumber,
                          );
                          try {
                            await launchUrl(launchUri);
                          } catch (e) {
                            print('Error: $e');
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
                        child: const Text("+63 911 12345678"),
                      ),

                      // Divider
                      const SizedBox(
                        width: 150,
                        child: Divider(
                          color: Color(0xFFA1A1A1),
                          thickness: 1,
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () async {
                          const phoneNumber = '+6391112345678';
                          final Uri launchUri = Uri(
                            scheme: 'tel',
                            path: phoneNumber,
                          );
                          try {
                            await launchUrl(launchUri);
                          } catch (e) {
                            print('Error: $e');
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
                        child: const Text("+63 911 12345678"),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Cancel action
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
