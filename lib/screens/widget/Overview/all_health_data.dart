import 'package:flutter/material.dart';

class AllHealthDataHeader extends StatelessWidget {
  final VoidCallback onAddTapped;
  final VoidCallback onEditTapped;

  const AllHealthDataHeader({
    super.key,
    required this.onAddTapped,
    required this.onEditTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "All Health Data",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: onAddTapped,
              child: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  size: 18,
                  color: Colors.black,
                ),
              ),
            ),
            GestureDetector(
              onTap: onEditTapped,
              child: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class HealthDataBottomSheet {
  static void show({
    required BuildContext context,
    required VoidCallback onAddSleep,
    required VoidCallback onAddBP,
    required VoidCallback onAddGlucose,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    Text(
                      "Which Health Data to Add?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                thickness: 0.5,
                color: Colors.black26,
                height: 10,
              ),
              ListTile(
                leading: const Icon(Icons.bedtime, color: Color(0xFF1A62B7)),
                title: const Text(
                  "Add Sleep Hours",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onAddSleep();
                },
              ),
              ListTile(
                leading: const Icon(Icons.monitor_heart_outlined,
                    color: Color(0xFFB7561A)),
                title: const Text(
                  "Add Blood Pressure",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onAddBP();
                },
              ),
              ListTile(
                leading: const Icon(Icons.monitor, color: Color(0xFFb71a70)),
                title: const Text(
                  "Add Blood Glucose",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onAddGlucose();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

class EditHealthDataVisibilityDialog {
  static void show({
    required BuildContext context,
    required bool showSleep,
    required bool showBP,
    required bool showGlucose,
    required void Function(bool sleep, bool bp, bool glucose) onApply,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        bool tempSleep = showSleep;
        bool tempBP = showBP;
        bool tempGlucose = showGlucose;

        return StatefulBuilder(
          builder: (BuildContext ctx, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: const Column(
                children: [
                  Icon(
                    Icons.visibility,
                    size: 40,
                    color: Color(0xFF1A62B7),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Edit Health Data Visibility',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Sleep Hours"),
                      Switch(
                        value: tempSleep,
                        onChanged: (val) =>
                            setStateDialog(() => tempSleep = val),
                        activeColor: const Color(0xFF1A62B7),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Blood Pressure"),
                      Switch(
                        value: tempBP,
                        onChanged: (val) => setStateDialog(() => tempBP = val),
                        activeColor: const Color(0xFF1A62B7),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Blood Glucose"),
                      Switch(
                        value: tempGlucose,
                        onChanged: (val) =>
                            setStateDialog(() => tempGlucose = val),
                        activeColor: const Color(0xFF1A62B7),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1A62B7)),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Color(0xFF1A62B7)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onApply(tempSleep, tempBP, tempGlucose);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF1A62B7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Apply",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
