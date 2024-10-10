import 'package:flutter/material.dart';
import 'package:saludko/screens/AdminSide/AdminProfile.dart';

class AdminAppBar extends StatefulWidget {
  const AdminAppBar({super.key});

  @override
  _AdminAppBarState createState() => _AdminAppBarState();
}

class _AdminAppBarState extends State<AdminAppBar> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.redAccent,
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      pinned: true, // Keeps the top part of the app bar visible when scrolling
      expandedHeight: 150.0, // Adjust height as needed
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Admin Dashboard",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminProfile(),
                ),
              );
            },
            child: const Icon(
              Icons.person,
              size: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
      flexibleSpace: const FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10), // Adjusts the space to push content down
              Text(
                "Hello, Admin!",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Manage salud.ko",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 20), // Space between the text and search box
              /*Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: InputTextField(
                  textEditingController: searchController,
                  hintText: "search",
                  icon: Icons.search,
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
