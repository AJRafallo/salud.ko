import 'package:flutter/material.dart';
import 'package:saludko/screens/widget/MedicineReminders/common_functions.dart';

class DosesListWidget extends StatefulWidget {
  final List<String> doses;
  final Function(List<String>) onDosesChanged;
  final bool initialIsRoundTheClock;
  final int initialInterval;
  final int initialTimes;
  final String initialStartTime;

  // Callbacks that the parent uses to update its own state
  final ValueChanged<bool> onRoundTheClockChanged;
  final ValueChanged<int> onIntervalChanged;
  final ValueChanged<int> onTimesChanged;
  final ValueChanged<String> onStartTimeChanged;

  const DosesListWidget({
    super.key,
    required this.doses,
    required this.onDosesChanged,
    required this.initialIsRoundTheClock,
    required this.initialInterval,
    required this.initialTimes,
    required this.initialStartTime,
    required this.onRoundTheClockChanged,
    required this.onIntervalChanged,
    required this.onTimesChanged,
    required this.onStartTimeChanged,
  });

  @override
  State<DosesListWidget> createState() => _DosesListWidgetState();
}

class _DosesListWidgetState extends State<DosesListWidget> {
  late List<String> _manualDoses;
  late List<String> _localDoses;
  late List<TextEditingController> _controllers;

  // round-the-clock state
  late bool _useRoundTheClock;
  late TimeOfDay _startTime;
  late int _intervalHours;
  late int _numTimes;

  @override
  void initState() {
    super.initState();

    // copy the initial doses
    _manualDoses = List.from(widget.doses);
    _localDoses = List.from(widget.doses);
    _controllers =
        _localDoses.map((dose) => TextEditingController(text: dose)).toList();

    _useRoundTheClock = widget.initialIsRoundTheClock;
    _intervalHours = widget.initialInterval;
    _numTimes = widget.initialTimes;
    _startTime = _tryParseTimeOfDay(widget.initialStartTime);

    if (_useRoundTheClock) {
      _recalcRoundClock();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFC1EFC3),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Center(
            child: Text(
              'Doses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Round-the-Clock row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Round-the-Clock?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Switch(
                value: _useRoundTheClock,
                onChanged: (val) {
                  // 1) Child sets its own local state
                  setState(() {
                    _useRoundTheClock = val;
                  });
                  // 2) Defer parent callback to avoid "setState during build"
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onRoundTheClockChanged(val);
                  });

                  if (val) {
                    if (_manualDoses.isNotEmpty) {
                      _startTime = _tryParseTimeOfDay(_manualDoses.first);
                    }
                    _recalcRoundClock();
                  } else {
                    // Turn off => restore manual
                    _localDoses = List.from(_manualDoses);
                    _resetControllers();
                    // Also defer the parent's onDosesChanged callback
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      widget.onDosesChanged(_localDoses);
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_useRoundTheClock) ...[
            // Start time
            _buildStartTimePicker(),
            const SizedBox(height: 12),
            _buildIntervalTimesRow(),
            const SizedBox(height: 12),
            // No manual dose list if round-the-clock is ON
          ] else ...[
            // Manual dose list
            for (int i = 0; i < _localDoses.length; i++) ...[
              Text(
                '${ordinal(i + 1)} Dose',
                style: TextStyle(color: Colors.black.withOpacity(0.8)),
              ),
              const SizedBox(height: 4),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _controllers[i],
                        onChanged: (val) {
                          _localDoses[i] = val;
                          // Defer parent callback
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            widget.onDosesChanged(_localDoses);
                          });
                        },
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText: 'e.g. 8:00 AM',
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.access_time,
                        color: Color(0xFF4B72D2),
                        size: 18,
                      ),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          final newTime = formatTimeOfDay(picked);
                          setState(() {
                            _controllers[i].text = newTime;
                            _localDoses[i] = newTime;
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            widget.onDosesChanged(_localDoses);
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.black.withOpacity(0.8),
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _localDoses.removeAt(i);
                          _controllers.removeAt(i);
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          widget.onDosesChanged(_localDoses);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],

            // + button
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _localDoses.add('8:00 AM');
                    _controllers.add(TextEditingController(text: '8:00 AM'));
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onDosesChanged(_localDoses);
                  });
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1),
                    color: Colors.transparent,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStartTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Start Time',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  formatTimeOfDay(_startTime),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.access_time,
                  color: Color(0xFF4B72D2),
                  size: 18,
                ),
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _startTime,
                  );
                  if (picked != null) {
                    setState(() {
                      _startTime = picked;
                    });
                    // Defer the parent callback
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      widget.onStartTimeChanged(formatTimeOfDay(_startTime));
                    });
                    _recalcRoundClock();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntervalTimesRow() {
    return Row(
      children: [
        // Interval
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Interval (hrs)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_intervalHours > 1) {
                            _intervalHours--;
                          }
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          widget.onIntervalChanged(_intervalHours);
                        });
                        _recalcRoundClock();
                      },
                      child: const Icon(Icons.remove, size: 18),
                    ),
                    Expanded(
                      child: Center(
                        child: Text('$_intervalHours',
                            style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _intervalHours++;
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          widget.onIntervalChanged(_intervalHours);
                        });
                        _recalcRoundClock();
                      },
                      child: const Icon(Icons.add, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Times
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Times',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_numTimes > 1) {
                            _numTimes--;
                          }
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          widget.onTimesChanged(_numTimes);
                        });
                        _recalcRoundClock();
                      },
                      child: const Icon(Icons.remove, size: 18),
                    ),
                    Expanded(
                      child: Center(
                        child: Text('$_numTimes',
                            style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _numTimes++;
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          widget.onTimesChanged(_numTimes);
                        });
                        _recalcRoundClock();
                      },
                      child: const Icon(Icons.add, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _recalcRoundClock() {
    final newTimes = <String>[];
    var curHour = _startTime.hour;
    var curMin = _startTime.minute;

    for (int i = 0; i < _numTimes; i++) {
      newTimes.add(formatTimeOfDay(TimeOfDay(hour: curHour, minute: curMin)));
      curHour += _intervalHours;
      while (curHour >= 24) {
        curHour -= 24;
      }
    }

    setState(() {
      _localDoses = newTimes;
      _resetControllers();
    });
    // Defer parent's onDosesChanged
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDosesChanged(_localDoses);
    });
  }

  void _resetControllers() {
    for (final c in _controllers) {
      c.dispose();
    }
    _controllers =
        _localDoses.map((dose) => TextEditingController(text: dose)).toList();
  }

  TimeOfDay _tryParseTimeOfDay(String timeStr) {
    final now = DateTime.now();
    try {
      final parts = timeStr.split(' ');
      if (parts.length != 2) return const TimeOfDay(hour: 8, minute: 0);

      final hhmm = parts[0].split(':');
      int hour = int.parse(hhmm[0]);
      int minute = int.parse(hhmm[1]);
      final amPm = parts[1].toUpperCase();

      if (amPm == 'PM' && hour < 12) hour += 12;
      if (amPm == 'AM' && hour == 12) hour = 0;

      hour = hour.clamp(0, 23);
      minute = minute.clamp(0, 59);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return TimeOfDay(hour: now.hour, minute: now.minute);
    }
  }
}
