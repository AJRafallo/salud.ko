import 'package:flutter/material.dart';
import 'package:saludko/screens/widget/records_tab_bar.dart';
import 'package:saludko/screens/UserSide/records_overview_page.dart';
import 'package:saludko/screens/UserSide/medicine_reminders_page.dart';
import 'package:saludko/screens/UserSide/medical.dart';
import 'package:saludko/screens/widget/appbar_2.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  _RecordsScreenState createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  String _selectedPage = "Overview";

  // return the selected content based on the current tab
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
            child: _getSelectedPage(),
          ),
        ],
      ),
    );
  }
}
