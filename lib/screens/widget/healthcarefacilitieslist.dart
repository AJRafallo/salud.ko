import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saludko/screens/HospitalAdminSide/HospitalAdDetailScreen.dart';

class HealthcareFacilities extends StatefulWidget {
  const HealthcareFacilities({super.key});

  @override
  _HealthcareFacilitiesState createState() => _HealthcareFacilitiesState();
}

class _HealthcareFacilitiesState extends State<HealthcareFacilities> {
  final PageController _pageController = PageController();

  // Method to move to the next or previous page
  void _movePage(int delta) {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('hospital')
          .where('isVerified', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text('No verified healthcare facilities available.'));
        }

        final facilities = snapshot.data!.docs;

        return Column(
          children: [
            const Padding(padding: EdgeInsets.all(0)),
            SizedBox(
              height: 250, // Adjust height based on your design
              width: 350,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // PageView for facilities
                  PageView.builder(
                    controller: _pageController,
                    itemCount: facilities.length,
                    itemBuilder: (context, index) {
                      final facility =
                          facilities[index].data() as Map<String, dynamic>;
                      var profileImageUrl = facility['profileImage'] ??
                          ''; // Get facility's profile image URL, if available

                      return GestureDetector(
                        onTap: () {
                          // Navigate to the provider detail screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  HospitalAdDetailScreen(facility: facility),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Profile Image as Rectangular Container
                              SizedBox(
                                width: 300, // Adjust the width
                                height: 150, // Adjust the height
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        20), // Rounded corners
                                    image: DecorationImage(
                                      image: profileImageUrl.isNotEmpty
                                          ? NetworkImage(profileImageUrl)
                                          : const AssetImage(
                                                  'lib/assets/images/avatar.png')
                                              as ImageProvider,
                                      fit: BoxFit
                                          .cover, // Makes the image cover the entire box
                                    ),
                                  ),
                                  child: (profileImageUrl.isEmpty)
                                      ? const Center(
                                          child: Icon(
                                            Icons.camera_alt,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(
                                  height: 10), // Spacing between image and text

                              // Provider's Name
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(50, 0, 50, 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      facility['workplace'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            5), // Spacing between name and address

                                    // Provider's Address
                                    Text(
                                      facility['address']?.length > 50
                                          ? '${facility['address']?.substring(0, 50)}...'
                                          : facility['address'] ?? '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Left Arrow Button
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_left,
                        size: 40,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                  // Right Arrow Button
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_right,
                        size: 40,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
