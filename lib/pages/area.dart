import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AreaConverterPage extends StatefulWidget {
  const AreaConverterPage({super.key});

  @override
  State<AreaConverterPage> createState() => _AreaConverterPageState();
}

class _AreaConverterPageState extends State<AreaConverterPage> {
  static const Color _primaryColor = Color(0xFF4A55A2);

  final TextEditingController _inputController = TextEditingController();

  final List<String> _areaUnits = const [
    'Square Millimeters',
    'Square Centimeters',
    'Square Meters',
    'Square Kilometers',
    'Square Inches',
    'Square Feet',
    'Square Yards',
    'Acres',
    'Hectares',
    'Square Miles',
  ];

  static const Map<String, double> _squareMetersPerUnit = {
    'Square Millimeters': 0.000001,
    'Square Centimeters': 0.0001,
    'Square Meters': 1,
    'Square Kilometers': 1000000,
    'Square Inches': 0.00064516,
    'Square Feet': 0.09290304,
    'Square Yards': 0.83612736,
    'Acres': 4046.8564224,
    'Hectares': 10000,
    'Square Miles': 2589988.110336,
  };

  String _fromUnit = 'Square Meters';
  String _toUnit = 'Square Feet';
  String _result = '—';
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_convert);
  }

  @override
  void dispose() {
    _inputController.removeListener(_convert);
    _inputController.dispose();
    super.dispose();
  }

  void _convert() {
    final String text = _inputController.text.trim();

    if (text.isEmpty) {
      setState(() {
        _errorText = null;
        _result = '—';
      });
      return;
    }

    final double? value = double.tryParse(text);
    if (value == null) {
      setState(() {
        _errorText = 'Enter a valid number';
        _result = '—';
      });
      return;
    }

    final double valueInSquareMeters = value * _squareMetersPerUnit[_fromUnit]!;
    final double converted = valueInSquareMeters / _squareMetersPerUnit[_toUnit]!;

    setState(() {
      _errorText = null;
      _result = _formatNumber(converted);
    });
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toStringAsFixed(0);
    }
    String s = value.toStringAsFixed(8);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
    return s;
  }

  void _swapUnits() {
    setState(() {
      final String temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    _convert();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      appBar: AppBar(
        title: const Text('Area Calculator'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputCard(),
              const SizedBox(height: 18),
              _buildUnitRow(),
              const SizedBox(height: 18),
              _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _inputController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            labelText: 'Enter area',
            errorText: _errorText,
            prefixIcon: const Icon(Icons.crop, color: _primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryColor, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitRow() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _buildDropdown('From', _fromUnit, (value) {
                setState(() => _fromUnit = value!);
                _convert();
              }),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: IconButton(
                onPressed: _swapUnits,
                icon: const Icon(Icons.swap_horiz, color: _primaryColor),
                tooltip: 'Swap units',
              ),
            ),
            Expanded(
              child: _buildDropdown('To', _toUnit, (value) {
                setState(() => _toUnit = value!);
                _convert();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          items: _areaUnits
              .map(
                (unit) => DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 2,
      color: _primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Result',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              '$_result $_toUnit',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}