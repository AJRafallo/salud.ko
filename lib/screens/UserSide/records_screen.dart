import 'package:flutter/material.dart';
import 'package:saludko/screens/widget/RecordsTabBar.dart';
import 'package:saludko/screens/UserSide/records_overview_page.dart';
import 'package:saludko/screens/UserSide/medicine_reminders_page.dart';
import 'package:saludko/screens/UserSide/medical_files_page.dart';
import 'package:saludko/screens/widget/appbar_2.dart'; // Custom app bar

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  _RecordsScreenState createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  String _selectedPage = "Overview"; // Default to "Overview"

  // This method will return the selected content based on the current tab
  Widget _getSelectedPage() {
    switch (_selectedPage) {
      case "Medicine Reminders":
        return const MedicineRemindersPage();
      case "Medical Files":
        return const MedicalFilesPage();
      case "Overview":
      default:
        return const OverviewPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SaludkoAppBar(),
          SliverToBoxAdapter(
            child: RecordsNavigation(
              selectedPage: _selectedPage,
              onPageSelected: (String page) {
                setState(() {
                  _selectedPage = page;
                });
              },
            ),
          ),
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _getSelectedPage(),
            ),
          ),
        ],
      ),
    );
  }
}
