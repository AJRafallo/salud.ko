import 'package:flutter/material.dart';

class QuantityDurationWidget extends StatefulWidget {
  final int quantity;
  final int quantityLeft;
  final String quantityUnit;
  final String durationType;
  final int durationValue;

  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<int> onQuantityLeftChanged;
  final ValueChanged<String> onQuantityUnitChanged;
  final ValueChanged<String> onDurationTypeChanged;
  final ValueChanged<int> onDurationValueChanged;

  const QuantityDurationWidget({
    super.key,
    required this.quantity,
    required this.quantityLeft,
    required this.quantityUnit,
    required this.durationType,
    required this.durationValue,
    required this.onQuantityChanged,
    required this.onQuantityLeftChanged,
    required this.onQuantityUnitChanged,
    required this.onDurationTypeChanged,
    required this.onDurationValueChanged,
  });

  @override
  State<QuantityDurationWidget> createState() => _QuantityDurationWidgetState();
}

class _QuantityDurationWidgetState extends State<QuantityDurationWidget> {
  late TextEditingController _quantityController;
  late TextEditingController _quantityLeftController;
  late TextEditingController _durationController;
  late String _durationType;
  late String _quantityUnit;

  @override
  void initState() {
    super.initState();
    _quantityController =
        TextEditingController(text: widget.quantity.toString());
    _quantityLeftController =
        TextEditingController(text: widget.quantityLeft.toString());
    _durationController =
        TextEditingController(text: widget.durationValue.toString());
    _durationType = widget.durationType;
    _quantityUnit = widget.quantityUnit;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityLeftController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Quantity
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFDEEDFF),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: _incrementQuantity,
                            child:
                                const Icon(Icons.keyboard_arrow_up, size: 20),
                          ),
                          SizedBox(
                            width: 40,
                            child: TextField(
                              controller: _quantityController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black.withOpacity(0.8)),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) {
                                final intValue = int.tryParse(val) ?? 0;
                                widget.onQuantityChanged(intValue);
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: _decrementQuantity,
                            child:
                                const Icon(Icons.keyboard_arrow_down, size: 20),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _quantityUnit,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        ':',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      // Quantity Left
                      Column(
                        children: [
                          GestureDetector(
                            onTap: _incrementQuantityLeft,
                            child:
                                const Icon(Icons.keyboard_arrow_up, size: 20),
                          ),
                          SizedBox(
                            width: 40,
                            child: TextField(
                              controller: _quantityLeftController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black.withOpacity(0.8)),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) {
                                final intValue = int.tryParse(val) ?? 0;
                                widget.onQuantityLeftChanged(intValue);
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: _decrementQuantityLeft,
                            child:
                                const Icon(Icons.keyboard_arrow_down, size: 20),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Left',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Duration
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFDEEDFF),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      'Frequency',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    'Days',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD9D9D9)),
                    ),
                    child: DropdownButton<String>(
                      value: _durationType,
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                      iconEnabledColor: Colors.black87,
                      underline: const SizedBox.shrink(),
                      alignment: Alignment.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.0,
                        color: Colors.black.withOpacity(0.8),
                      ),
                      items: <String>['Everyday', 'Every X Days', 'Days']
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e, textAlign: TextAlign.center),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _durationType = val;
                          });
                          widget.onDurationTypeChanged(val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Duration (unchanged)
                  Text(
                    'Duration',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD9D9D9)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Decrement
                        GestureDetector(
                          onTap: _decrementDuration,
                          child: const Icon(Icons.remove, size: 20),
                        ),
                        SizedBox(
                          width: 40,
                          child: TextField(
                            controller: _durationController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black.withOpacity(0.8),
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 2,
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (val) {
                              final newVal = int.tryParse(val);
                              if (newVal != null && newVal > 0) {
                                widget.onDurationValueChanged(newVal);
                              }
                            },
                          ),
                        ),
                        // Increment
                        GestureDetector(
                          onTap: _incrementDuration,
                          child: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _incrementQuantity() {
    final currentVal = int.tryParse(_quantityController.text) ?? 0;
    final newVal = currentVal + 1;
    setState(() {
      _quantityController.text = newVal.toString();
    });
    widget.onQuantityChanged(newVal);
  }

  void _decrementQuantity() {
    final currentVal = int.tryParse(_quantityController.text) ?? 0;
    if (currentVal > 0) {
      final newVal = currentVal - 1;
      setState(() {
        _quantityController.text = newVal.toString();
      });
      widget.onQuantityChanged(newVal);
    }
  }

  void _incrementQuantityLeft() {
    final currentVal = int.tryParse(_quantityLeftController.text) ?? 0;
    final newVal = currentVal + 1;
    setState(() {
      _quantityLeftController.text = newVal.toString();
    });
    widget.onQuantityLeftChanged(newVal);
  }

  void _decrementQuantityLeft() {
    final currentVal = int.tryParse(_quantityLeftController.text) ?? 0;
    if (currentVal > 0) {
      final newVal = currentVal - 1;
      setState(() {
        _quantityLeftController.text = newVal.toString();
      });
      widget.onQuantityLeftChanged(newVal);
    }
  }

  void _incrementDuration() {
    final currentVal = int.tryParse(_durationController.text) ?? 0;
    final newVal = currentVal + 1;
    setState(() {
      _durationController.text = newVal.toString();
    });
    widget.onDurationValueChanged(newVal);
  }

  void _decrementDuration() {
    final currentVal = int.tryParse(_durationController.text) ?? 0;
    if (currentVal > 1) {
      final newVal = currentVal - 1;
      setState(() {
        _durationController.text = newVal.toString();
      });
      widget.onDurationValueChanged(newVal);
    }
  }
}
