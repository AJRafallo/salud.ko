import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saludko/screens/widget/MedicalFiles/records_tab_bar.dart';
import 'package:saludko/screens/UserSide/overview.dart';
import 'package:saludko/screens/UserSide/medicine_reminders.dart';
import 'package:saludko/screens/UserSide/medical.dart';
import 'package:saludko/screens/widget/records_app_bar.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  _RecordsScreenState createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  String _selectedPage = "Overview";

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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1A62B7),
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
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
              hasScrollBody: false,
              child: _getSelectedPage(),
            ),
          ],
        ),
      ),
    );
  }
}
