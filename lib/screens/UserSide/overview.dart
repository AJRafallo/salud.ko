import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:saludko/screens/widget/Overview/steps.dart';
import 'package:saludko/screens/widget/Overview/weight_and_height.dart';
import 'package:saludko/screens/widget/Overview/sleep_hours.dart';
import 'package:saludko/screens/widget/Overview/add_sleep.dart';
import 'package:saludko/screens/widget/Overview/all_health_data.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<StepCount>? _stepCountSubscription;
  int _steps = 0;

  double _weight = 0.0;
  double _height = 0.0;

  double _monthlyStepsPercentage = 0.0;
  double _milesWalked = 0.0;
  final int _monthlyStepGoal = 100000;

  // Sleep Data
  List<Map<String, dynamic>> _sleepData = [];
  bool _showSleepData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initPedometer();
  }

  @override
  void dispose() {
    _stepCountSubscription?.cancel();
    super.dispose();
  }

  void _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>? ?? {};
        double storedWeight = (data['weight'] as num?)?.toDouble() ?? 0.0;
        double storedHeight = (data['height'] as num?)?.toDouble() ?? 0.0;

        setState(() {
          _weight = storedWeight;
          _height = storedHeight;
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  void _initPedometer() {
    try {
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        (event) {
          setState(() {
            _steps = event.steps;
            _calculateMetrics();
          });
        },
        onError: (error) {
          print("Pedometer Error: $error");
        },
      );
    } catch (e) {
      print("Error initializing pedometer: $e");
    }
  }

  void _calculateMetrics() {
    _monthlyStepsPercentage = (_steps / _monthlyStepGoal).clamp(0.0, 1.0);
    double strideLength = 0.415 * (_height / 100);
    double totalMeters = _steps * strideLength;
    _milesWalked = totalMeters / 1609.34;
  }

  String _formatNumber(double number) {
    if (number % 1 == 0) {
      return number.toInt().toString();
    } else {
      return number.toStringAsFixed(2);
    }
  }

  // Opens dialog to add new sleep entry
  void _addNewSleepEntry() {
    showDialog(
      context: context,
      builder: (_) => AddSleepEntryDialog(
        onSave: (double hours, DateTime date) {
          setState(() {
            _sleepData.add({'hours': hours, 'date': date});
          });
        },
      ),
    );
  }

  // Reset sleep data
  void _resetSleepData() {
    setState(() {
      _sleepData.clear();
    });
  }

  // Toggle Sleep widget
  void _toggleSleepVisibility() {
    setState(() {
      _showSleepData = !_showSleepData;
    });
  }

  // Edit Health Data Visibility (with real-time toggle)
  void _showEditHealthDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        bool tempShowSleep = _showSleepData;

        return StatefulBuilder(
          builder: (BuildContext context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              // Centered & bold header + icon
              title: Column(
                children: [
                  const Icon(
                    Icons.visibility,
                    size: 40,
                    color: Color(0xFF1A62B7),
                  ),
                  const SizedBox(height: 10),
                  const Center(
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
                  // For now, we only have Sleep Hours
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sleep Hours'),
                      Switch(
                        value: tempShowSleep,
                        onChanged: (val) {
                          setStateDialog(() {
                            tempShowSleep = val;
                          });
                        },
                        activeColor: const Color(0xFF1A62B7),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(color: Color(0xFF1A62B7)),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF1A62B7)),
                  ),
                ),
                // Apply Button
                TextButton(
                  onPressed: () {
                    // Update the actual variable
                    setState(() {
                      _showSleepData = tempShowSleep;
                    });
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: const Color(0xFF1A62B7),
                  ),
                  child: const Text(
                    'Apply',
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

  // Edit Weight & Height
  void _showEditDialog() {
    final weightController = TextEditingController(text: _weight.toString());
    final heightController = TextEditingController(text: _height.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Center(
            child: Text(
              'Edit Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'Weight (KG)',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                TextField(
                  controller: weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFD9D9D9),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'Height (CM)',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                TextField(
                  controller: heightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFD9D9D9),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: Color(0xFF1A62B7)),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF1A62B7)),
              ),
            ),
            TextButton(
              onPressed: () async {
                double? newWeight = double.tryParse(weightController.text);
                double? newHeight = double.tryParse(heightController.text);

                if (newWeight != null && newHeight != null) {
                  setState(() {
                    _weight = newWeight;
                    _height = newHeight;
                    _calculateMetrics();
                  });

                  User? user = _auth.currentUser;
                  if (user != null) {
                    await _firestore.collection('users').doc(user.uid).update({
                      'weight': _weight,
                      'height': _height,
                      'lastUpdated': FieldValue.serverTimestamp(),
                    }).catchError((error) {
                      print("Error updating user details: $error");
                    });
                  }

                  Navigator.of(context).pop();
                }
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: const Color(0xFF1A62B7),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Column(
            children: [
              // Row with Steps + Weight & Height
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 6,
                      child: StepsCardWidget(
                        monthlyStepsPercentage: _monthlyStepsPercentage,
                        milesWalked: _milesWalked,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: WeightHeightCardWidget(
                        weight: _weight,
                        height: _height,
                        formatNumber: _formatNumber,
                        onEditPressed: _showEditDialog,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // The new separate widget for the "All Health Data" row
              AllHealthDataHeader(
                onAddTapped: _addNewSleepEntry,
                onEditTapped: _showEditHealthDataDialog,
              ),

              const SizedBox(height: 16),

              // Sleep Hours tracking
              _showSleepData
                  ? SleepTrackingWidget(
                      sleepData: _sleepData,
                      onAddEntry: _addNewSleepEntry,
                      onReset: _resetSleepData,
                      onHide: _toggleSleepVisibility,
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
