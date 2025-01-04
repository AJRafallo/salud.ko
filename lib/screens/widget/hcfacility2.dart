import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saludko/screens/HospitalAdminSide/HADetails.dart';


class HealthcareFacilitiesList extends StatefulWidget {
  const HealthcareFacilitiesList({super.key});

  @override
  _HealthcareFacilitiesListState createState() => _HealthcareFacilitiesListState();
}

class _HealthcareFacilitiesListState extends State<HealthcareFacilitiesList> {
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

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView.builder(
            itemCount: facilities.length,
            itemBuilder: (context, index) {
              final facility =
                  facilities[index].data() as Map<String, dynamic>;
              var profileImageUrl = facility['profileImage'] ?? '';

              return GestureDetector(
                onTap: () {
                  // Navigate to the provider detail screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HospitalAdDetailScreen(facility: facility),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image as Rectangular Container
                      SizedBox(
                        width: double.infinity,
                        height: 150,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: profileImageUrl.isNotEmpty
                                  ? NetworkImage(profileImageUrl)
                                  : const AssetImage(
                                          'lib/assets/images/avatar.png')
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: profileImageUrl.isEmpty
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
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          facility['workplace'] ?? 'Unnamed Facility',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          facility['address']?.length ?? 0 > 50
                              ? '${facility['address']?.substring(0, 50)}...'
                              : facility['address'] ?? 'No address provided',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
