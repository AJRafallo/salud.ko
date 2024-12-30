import 'package:flutter/material.dart';
import 'package:saludko/screens/widget/MedicineReminders/common_functions.dart';

class DosesListWidget extends StatefulWidget {
  final List<String> doses;
  final Function(List<String>) onDosesChanged;

  const DosesListWidget({
    super.key,
    required this.doses,
    required this.onDosesChanged,
  });

  @override
  State<DosesListWidget> createState() => _DosesListWidgetState();
}

class _DosesListWidgetState extends State<DosesListWidget> {
  late List<String> _localDoses;

  @override
  void initState() {
    super.initState();
    _localDoses = List.from(widget.doses);
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
                      initialValue: _localDoses[i],
                      onChanged: (val) {
                        _localDoses[i] = val;
                        widget.onDosesChanged(_localDoses);
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
                        final newTimeStr = formatTimeOfDay(picked);
                        setState(() {
                          _localDoses[i] = newTimeStr;
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
                        widget.onDosesChanged(_localDoses);
                      });
                    },
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 4),
          // Add Dose Button
          Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: () {
                setState(() {
                  _localDoses.add('8:00 AM');
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
      ),
    );
  }
}
