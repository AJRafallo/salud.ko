import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:uuid/uuid.dart';
import 'package:saludko/screens/widget/Overview/steps.dart';
import 'package:saludko/screens/widget/Overview/weight_and_height.dart';
import 'package:saludko/screens/widget/Overview/all_health_data.dart';
import 'package:saludko/screens/widget/Overview/Sleep/sleep_hours.dart';
import 'package:saludko/screens/widget/Overview/BP/bp.dart';
import 'package:saludko/screens/widget/Overview/SelfMonitoring/SMFBG.dart';
import 'package:saludko/screens/widget/Overview/Sleep/add_sleep.dart';
import 'package:saludko/screens/widget/Overview/BP/add_bp.dart';
import 'package:saludko/screens/widget/Overview/SelfMonitoring/add_SMFBG.dart';
import 'package:saludko/screens/widget/Overview/reset.dart';
import 'package:saludko/screens/widget/Overview/edit_entries.dart';
import 'package:saludko/screens/widget/Overview/health_models.dart';

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
  final int _monthlyStepGoal = 100000;
  double _monthlyStepsPercentage = 0.0;
  double _milesWalked = 0.0;

  double _weight = 0.0;
  double _height = 0.0;

  List<SleepEntry> _sleepData = [];
  bool _showSleepData = true;

  List<BloodPressureEntry> _bpData = [];
  bool _showBloodPressure = true;

  List<BloodGlucoseEntry> _glucoseData = [];
  bool _showBloodGlucose = true;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndHealth();
    _initPedometer();
  }

  @override
  void dispose() {
    _stepCountSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserDataAndHealth() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final docRef = _firestore.collection('users').doc(user.uid);
      final snap = await docRef.get();
      if (!snap.exists) return;

      final data = snap.data() ?? {};
      setState(() {
        _weight = (data['weight'] as num?)?.toDouble() ?? 0.0;
        _height = (data['height'] as num?)?.toDouble() ?? 0.0;
      });

      final List sleepList = data['sleepData'] ?? [];
      _sleepData = sleepList
          .map((m) => SleepEntry.fromMap(m as Map<String, dynamic>))
          .toList();

      final List bpList = data['bpData'] ?? [];
      _bpData = bpList
          .map((m) => BloodPressureEntry.fromMap(m as Map<String, dynamic>))
          .toList();

      final List glucoseList = data['glucoseData'] ?? [];
      _glucoseData = glucoseList
          .map((m) => BloodGlucoseEntry.fromMap(m as Map<String, dynamic>))
          .toList();

      setState(() {});
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
        onError: (error) => print("Pedometer Error: $error"),
      );
    } catch (e) {
      print("Error initializing pedometer: $e");
    }
  }

  void _calculateMetrics() {
    _monthlyStepsPercentage = (_steps / _monthlyStepGoal).clamp(0.0, 1.0);
    final strideLength = 0.415 * (_height / 100);
    final totalMeters = _steps * strideLength;
    _milesWalked = totalMeters / 1609.34;
  }

  String _formatNumber(double number) {
    return (number % 1 == 0)
        ? number.toInt().toString()
        : number.toStringAsFixed(2);
  }

  // ---------------- SLEEP ----------------
  Future<void> _saveSleepData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docRef = _firestore.collection('users').doc(user.uid);

    final mapped = _sleepData.map((e) => e.toMap()).toList();
    await docRef.update({'sleepData': mapped}).catchError((err) {
      print("Error saving sleepData: $err");
    });
  }

  void _addNewSleepEntry() {
    showDialog(
      context: context,
      builder: (_) => AddSleepEntryDialog(
        onSave: (double hours, DateTime date) async {
          final id = const Uuid().v4();
          _sleepData.add(SleepEntry(id: id, hours: hours, date: date));
          setState(() {});
          await _saveSleepData();
        },
      ),
    );
  }

  void _resetSleepData() {
    ConfirmResetDialog.showResetConfirmation(
      context: context,
      dataName: "Sleep Data",
      onConfirm: () async {
        _sleepData.clear();
        setState(() {});
        await _saveSleepData();
      },
    );
  }

  void _toggleSleepVisibility() =>
      setState(() => _showSleepData = !_showSleepData);

  void _editSleepEntries() {
    EditEntriesDialog.show<SleepEntry>(
      context: context,
      title: "Edit Sleep Entries",
      entries: _sleepData,
      displayString: (entry) =>
          "Hours: ${entry.hours}\nDate: ${_md(entry.date)}",
      onEditSelected: (entry) {
        Navigator.pop(context); // close list
        _showEditSingleSleepEntry(entry);
      },
    );
  }

  void _showEditSingleSleepEntry(SleepEntry entry) {
    showDialog(
      context: context,
      builder: (_) {
        return AddSleepEntryDialog(
          initialHours: entry.hours,
          initialDate: entry.date,
          dialogTitle: "Edit Sleep Entry",
          onSave: (double hours, DateTime date) async {
            entry.hours = hours;
            entry.date = date;
            setState(() {});
            await _saveSleepData();
          },
        );
      },
    );
  }

  // ---------------- BLOOD PRESSURE ----------------
  Future<void> _saveBPData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docRef = _firestore.collection('users').doc(user.uid);

    final mapped = _bpData.map((e) => e.toMap()).toList();
    await docRef.update({'bpData': mapped}).catchError((err) {
      print("Error saving bpData: $err");
    });
  }

  void _addBloodPressureEntry() {
    showDialog(
      context: context,
      builder: (_) => AddBloodPressureDialog(
        onSave: (double systolicVal, double diastolicVal, DateTime date) async {
          final id = const Uuid().v4();
          _bpData.add(BloodPressureEntry(
            id: id,
            systolic: systolicVal,
            diastolic: diastolicVal,
            date: date,
          ));
          setState(() {});
          await _saveBPData();
        },
      ),
    );
  }

  void _resetBPData() {
    ConfirmResetDialog.showResetConfirmation(
      context: context,
      dataName: "Blood Pressure",
      onConfirm: () async {
        _bpData.clear();
        setState(() {});
        await _saveBPData();
      },
    );
  }

  void _toggleBPVisibility() =>
      setState(() => _showBloodPressure = !_showBloodPressure);

  void _editBPEntries() {
    EditEntriesDialog.show<BloodPressureEntry>(
      context: context,
      title: "Edit Blood Pressure Entries",
      entries: _bpData,
      displayString: (entry) =>
          "BP: ${entry.systolic}/${entry.diastolic}\nDate: ${_md(entry.date)}",
      onEditSelected: (entry) {
        Navigator.pop(context);
        _showEditSingleBPEntry(entry);
      },
    );
  }

  void _showEditSingleBPEntry(BloodPressureEntry entry) {
    showDialog(
      context: context,
      builder: (_) {
        return AddBloodPressureDialog(
          initialSystolic: entry.systolic,
          initialDiastolic: entry.diastolic,
          initialDate: entry.date,
          dialogTitle: "Edit Blood Pressure",
          onSave: (double s, double d, DateTime date) async {
            entry.systolic = s;
            entry.diastolic = d;
            entry.date = date;
            setState(() {});
            await _saveBPData();
          },
        );
      },
    );
  }

  // ---------------- BLOOD GLUCOSE ----------------
  Future<void> _saveGlucoseData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docRef = _firestore.collection('users').doc(user.uid);

    final mapped = _glucoseData.map((e) => e.toMap()).toList();
    await docRef.update({'glucoseData': mapped}).catchError((err) {
      print("Error saving glucoseData: $err");
    });
  }

  void _addBloodGlucoseEntry() {
    showDialog(
      context: context,
      builder: (_) => AddSelfMonitoringDialog(
        onSave: (double val, DateTime date) async {
          final id = const Uuid().v4();
          _glucoseData.add(BloodGlucoseEntry(id: id, value: val, date: date));
          setState(() {});
          await _saveGlucoseData();
        },
      ),
    );
  }

  void _resetGlucoseData() {
    ConfirmResetDialog.showResetConfirmation(
      context: context,
      dataName: "Blood Glucose",
      onConfirm: () async {
        _glucoseData.clear();
        setState(() {});
        await _saveGlucoseData();
      },
    );
  }

  void _toggleGlucoseVisibility() =>
      setState(() => _showBloodGlucose = !_showBloodGlucose);

  void _editGlucoseEntries() {
    EditEntriesDialog.show<BloodGlucoseEntry>(
      context: context,
      title: "Edit Blood Glucose Entries",
      entries: _glucoseData,
      displayString: (entry) => "Val: ${entry.value}\nDate: ${_md(entry.date)}",
      onEditSelected: (entry) {
        Navigator.pop(context);
        _showEditSingleGlucoseEntry(entry);
      },
    );
  }

  void _showEditSingleGlucoseEntry(BloodGlucoseEntry entry) {
    showDialog(
      context: context,
      builder: (_) {
        return AddSelfMonitoringDialog(
          initialValue: entry.value,
          initialDate: entry.date,
          dialogTitle: "Edit Glucose Entry",
          onSave: (double val, DateTime date) async {
            entry.value = val;
            entry.date = date;
            setState(() {});
            await _saveGlucoseData();
          },
        );
      },
    );
  }

  // ---------------- WEIGHT / HEIGHT ----------------
  Future<void> _saveWeightHeight() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).update({
      'weight': _weight,
      'height': _height,
      'lastUpdated': FieldValue.serverTimestamp(),
    }).catchError((err) => print("Error updating weight/height: $err"));
  }

  void _editWeightHeight() {
    final weightCtrl = TextEditingController(text: _weight.toString());
    final heightCtrl = TextEditingController(text: _height.toString());

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Center(
            child: Text(
              "Edit Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Weight (KG)", style: TextStyle(fontSize: 14)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: weightCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFD9D9D9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Height (CM)", style: TextStyle(fontSize: 14)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: heightCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFD9D9D9),
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
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: Color(0xFF1A62B7)),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Color(0xFF1A62B7)),
              ),
            ),
            TextButton(
              onPressed: () async {
                final wTxt = weightCtrl.text.trim();
                final hTxt = heightCtrl.text.trim();
                if (wTxt.isNotEmpty && hTxt.isNotEmpty) {
                  final wVal = double.tryParse(wTxt);
                  final hVal = double.tryParse(hTxt);
                  if (wVal != null && hVal != null) {
                    setState(() {
                      _weight = wVal;
                      _height = hVal;
                      _calculateMetrics();
                    });
                    await _saveWeightHeight();
                  }
                }
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF1A62B7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // --------------- VISIBILITY ----------------
  void _editHealthDataVisibility() {
    EditHealthDataVisibilityDialog.show(
      context: context,
      showSleep: _showSleepData,
      showBP: _showBloodPressure,
      showGlucose: _showBloodGlucose,
      onApply: (bool sleep, bool bp, bool glucose) {
        setState(() {
          _showSleepData = sleep;
          _showBloodPressure = bp;
          _showBloodGlucose = glucose;
        });
      },
    );
  }

  void _chooseHealthDataToAdd() {
    HealthDataBottomSheet.show(
      context: context,
      onAddSleep: _addNewSleepEntry,
      onAddBP: _addBloodPressureEntry,
      onAddGlucose: _addBloodGlucoseEntry,
    );
  }

  String _md(DateTime d) => "${d.month}/${d.day}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Column(
            children: [
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
                        onEditPressed: _editWeightHeight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AllHealthDataHeader(
                onAddTapped: _chooseHealthDataToAdd,
                onEditTapped: _editHealthDataVisibility,
              ),
              const SizedBox(height: 16),
              if (_showSleepData)
                SleepTrackingWidget(
                  sleepData: _sleepData
                      .map(
                          (e) => {'id': e.id, 'hours': e.hours, 'date': e.date})
                      .toList(),
                  onAddEntry: _addNewSleepEntry,
                  onReset: _resetSleepData,
                  onHide: _toggleSleepVisibility,
                  onEditEntries: _editSleepEntries,
                ),
              if (_showSleepData) const SizedBox(height: 16),
              if (_showBloodPressure)
                BloodPressureWidget(
                  data: _bpData.map((e) {
                    return {
                      'id': e.id,
                      'systolic': e.systolic,
                      'diastolic': e.diastolic,
                      'date': e.date,
                    };
                  }).toList(),
                  onAddEntry: _addBloodPressureEntry,
                  onReset: _resetBPData,
                  onHide: _toggleBPVisibility,
                  onEditEntries: _editBPEntries,
                ),
              if (_showBloodPressure) const SizedBox(height: 16),
              if (_showBloodGlucose)
                SelfMonitoringWidget(
                  data: _glucoseData
                      .map((e) => {
                            'id': e.id,
                            'value': e.value,
                            'date': e.date,
                          })
                      .toList(),
                  onAddEntry: _addBloodGlucoseEntry,
                  onReset: _resetGlucoseData,
                  onHide: _toggleGlucoseVisibility,
                  onEditEntries: _editGlucoseEntries,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
