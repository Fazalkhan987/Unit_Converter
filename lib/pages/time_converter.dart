import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Time_Converter extends StatefulWidget {
  const Time_Converter({super.key});

  @override
  State<Time_Converter> createState() => _Time_ConverterState();
}

class _Time_ConverterState extends State<Time_Converter> {
  final TextEditingController _inputController = TextEditingController();

  final List<String> _timeUnits = const [
    'Milliseconds',
    'Seconds',
    'Minutes',
    'Hours',
    'Days',
    'Weeks',
    'Months',
    'Years',
  ];

  // How many milliseconds make up ONE unit of each type.
  // Using milliseconds as a common base lets us convert between
  // ANY two units, not just "unit -> milliseconds".
  static const Map<String, double> _msPerUnit = {
    'Milliseconds': 1,
    'Seconds': 1000,
    'Minutes': 1000 * 60,
    'Hours': 1000 * 60 * 60,
    'Days': 1000 * 60 * 60 * 24,
    'Weeks': 1000 * 60 * 60 * 24 * 7,
    'Months': 1000 * 60 * 60 * 24 * 30, // approx. 30-day month
    'Years': 1000 * 60 * 60 * 24 * 365, // approx. 365-day year
  };

  String _fromUnit = 'Seconds';
  String _toUnit = 'Minutes';
  String _result = '—';
  String? _errorText;

  static const Color _primaryColor = Color(0xFF4A55A2);

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
    final text = _inputController.text.trim();

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

    final double valueInMs = value * _msPerUnit[_fromUnit]!;
    final double converted = valueInMs / _msPerUnit[_toUnit]!;

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
      final temp = _fromUnit;
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
        title: const Text('Time Converter'),
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
              const SizedBox(height: 12),
              const Text(
                'Note: 1 month ≈ 30 days, 1 year ≈ 365 days',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
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
            labelText: 'Enter value',
            errorText: _errorText,
            prefixIcon: const Icon(Icons.edit_outlined, color: _primaryColor),
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
          items: _timeUnits
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






























// import 'package:flutter/material.dart';

// class Time_Converter extends StatefulWidget {
//   const Time_Converter({super.key});

//   @override
//   State<Time_Converter> createState() => _Time_ConverterState();
// }

// class _Time_ConverterState extends State<Time_Converter> {
//   String result = "";
//   var uinput = TextEditingController();
//   String dropvalue = "milliseconds";
//   List<String> timeUnits = [
//     "milliseconds",
//     "Seconds",
//     "Minutes",
//     "Hours",
//     "Days",
//     "Weeks",
//     "Months",
//     "Years",
//   ];
//   resvalue() {

//     double res = 0;
//     if (dropvalue == "milliseconds") {
//       res = input / 1000;
//     } else if (dropvalue == "Seconds") {
//       res = input * 1000;
//     } else if (dropvalue == "Minutes") {
//       res = input * 60 * 1000;
//     } else if (dropvalue == "Hours") {
//       res = input * 60 * 60 * 1000;
//     } else if (dropvalue == "Days") {
//       res = input * 24 * 60 * 60 * 1000;
//     } else if (dropvalue == "Weeks") {
//       res = input * 7 * 24 * 60 * 60 * 1000;
//     } else if (dropvalue == "Months") {
//       res = input * 30 * 24 * 60 * 60 * 1000;
//     } else if (dropvalue == "Years") {
//       res = input * 365 * 24 * 60 * 60 * 1000;
//     }
//     setState(() {
//       result = res.toString();
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.orange,
//       appBar: AppBar(title: Text("Time Converter")),
//       body: Container(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Container(
//               color: Colors.blue,
//               width: double.infinity,
//               child: DropdownButton(
//                 value: dropvalue,
//                 items: timeUnits
//                     .map((e) => DropdownMenuItem(child: Text(e), value: e))
//                     .toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     dropvalue = value!;
//                   });
//                 },
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.all(20),
//               child: TextField(
//                 controller: uinput,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   labelText: "Enter value",
//                 ),
//               ),
//             ),
//             Container(
//               color: Colors.blue,
//               width: double.infinity,
//               child: DropdownButton(
//                 value: dropvalue,
//                 items: timeUnits
//                     .map((e) => DropdownMenuItem(child: Text(e), value: e))
//                     .toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     dropvalue = value!;
//                   });
//                 },
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.all(20),
//               child: Text("Result: $result"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
