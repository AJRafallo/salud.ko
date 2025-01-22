import 'package:flutter/material.dart';

class EditEntriesDialog {
  static void show<T>({
    required BuildContext context,
    required String title,
    required List<T> entries,
    required String Function(T entry) displayString,
    required void Function(T entry) onEditSelected,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Center(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: SizedBox(
            height: 300,
            width: double.minPositive,
            child: entries.isEmpty
                ? const Center(child: Text("No entries to edit."))
                : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final text = displayString(entry);
                      return Card(
                        child: ListTile(
                          title: Text(text),
                          onTap: () => onEditSelected(entry),
                        ),
                      );
                    },
                  ),
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
                "Close",
                style: TextStyle(color: Color(0xFF1A62B7)),
              ),
            ),
          ],
        );
      },
    );
  }
}
