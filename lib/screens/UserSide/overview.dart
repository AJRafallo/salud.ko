import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

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
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
                side: const BorderSide(color: Color(0xFF1A62B7)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(80, 40),
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
                backgroundColor: const Color(0xFF1A62B7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(80, 40),
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

  Widget _buildStepsCard() {
    Color progressColor = const Color(0xFFFFA8B4);
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFCCE3FF),
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_walk,
                    size: 22, color: Colors.black),
              ),
              const SizedBox(width: 12),
              const Text(
                "Steps",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${(_monthlyStepsPercentage * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Total this month",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: _monthlyStepsPercentage,
                      strokeWidth: 3,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF1A62B7), width: 3),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _milesWalked.toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            "miles",
                            style:
                                TextStyle(fontSize: 10, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightHeightCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF9ECBFF), width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(25)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Weight",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: _showEditDialog,
                icon: const Icon(Icons.more_horiz, color: Color(0xFF1A62B7)),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  _formatNumber(_weight),
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 4),
              const Flexible(
                child: Text(
                  "KG",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A62B7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Height",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  _formatNumber(_height),
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 4),
              const Flexible(
                child: Text(
                  "CM",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A62B7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 6,
                  child: _buildStepsCard(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: _buildWeightHeightCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
