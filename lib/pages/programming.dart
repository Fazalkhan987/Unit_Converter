import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProgrammingConverterPage extends StatefulWidget {
  const ProgrammingConverterPage({super.key});

  @override
  State<ProgrammingConverterPage> createState() =>
      _ProgrammingConverterPageState();
}

class _ProgrammingConverterPageState extends State<ProgrammingConverterPage> {
  static const Color _primaryColor = Color(0xFF4A55A2);

  final TextEditingController _inputController = TextEditingController();

  final List<String> _bases = const ['Binary', 'Octal', 'Decimal', 'Hexadecimal'];

  static const Map<String, int> _radixOf = {
    'Binary': 2,
    'Octal': 8,
    'Decimal': 10,
    'Hexadecimal': 16,
  };

  String _fromBase = 'Decimal';
  String? _errorText;

  // Using BigInt (not int) on purpose — a plain int overflows silently
  // on large hex/binary values (e.g. 64+ bit constants), which would
  // give a wrong answer instead of an error. BigInt has no upper limit.
  String _binaryResult = '';
  String _octalResult = '';
  String _decimalResult = '';
  String _hexResult = '';

  bool get _hasResult => _decimalResult.isNotEmpty;

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

  RegExp _patternFor(String base) {
    switch (base) {
      case 'Binary':
        return RegExp(r'^-?[01]*$');
      case 'Octal':
        return RegExp(r'^-?[0-7]*$');
      case 'Hexadecimal':
        return RegExp(r'^-?[0-9a-fA-F]*$');
      default:
        return RegExp(r'^-?[0-9]*$');
    }
  }

  void _onBaseChanged(String? value) {
    if (value == null) return;
    setState(() {
      _fromBase = value;
      // Old text may contain characters invalid in the new base
      // (e.g. "F" left over after switching from Hex to Binary),
      // so start fresh rather than show a stale, invalid value.
      _inputController.clear();
      _errorText = null;
      _binaryResult = '';
      _octalResult = '';
      _decimalResult = '';
      _hexResult = '';
    });
  }

  void _convert() {
    final String text = _inputController.text.trim();

    if (text.isEmpty || text == '-') {
      setState(() {
        _errorText = null;
        _binaryResult = '';
        _octalResult = '';
        _decimalResult = '';
        _hexResult = '';
      });
      return;
    }

    BigInt? value;
    try {
      value = BigInt.parse(text, radix: _radixOf[_fromBase]!);
    } catch (_) {
      value = null;
    }

    if (value == null) {
      setState(() {
        _errorText = 'Invalid $_fromBase value';
        _binaryResult = '';
        _octalResult = '';
        _decimalResult = '';
        _hexResult = '';
      });
      return;
    }

    setState(() {
      _errorText = null;
      _binaryResult = value!.toRadixString(2);
      _octalResult = value.toRadixString(8);
      _decimalResult = value.toRadixString(10);
      _hexResult = value.toRadixString(16).toUpperCase();
    });
  }

  // Groups digits from the right for readability, e.g.
  // binary "10110100" -> "1011 0100", decimal "123456" -> "123,456".
  String _group(String value, int size, String separator) {
    final bool isNegative = value.startsWith('-');
    final String digits = isNegative ? value.substring(1) : value;

    final List<String> groups = [];
    for (int i = digits.length; i > 0; i -= size) {
      final int start = (i - size) < 0 ? 0 : (i - size);
      groups.insert(0, digits.substring(start, i));
    }
    final String grouped = groups.join(separator);
    return isNegative ? '-$grouped' : grouped;
  }

  void _copy(String rawValue, String label) {
    if (rawValue.isEmpty) return;
    Clipboard.setData(ClipboardData(text: rawValue));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      appBar: AppBar(
        title: const Text('Programming Converter'),
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
              _buildResultsCard(),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'From',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            DropdownButton<String>(
              value: _fromBase,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: _bases
                  .map(
                    (base) =>
                        DropdownMenuItem<String>(value: base, child: Text(base)),
                  )
                  .toList(),
              onChanged: _onBaseChanged,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _inputController,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(_patternFor(_fromBase)),
              ],
              decoration: InputDecoration(
                labelText: 'Enter $_fromBase value',
                errorText: _errorText,
                prefixIcon: const Icon(Icons.code, color: _primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _primaryColor, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildResultRow(
            label: 'Binary',
            value: _hasResult ? _group(_binaryResult, 4, ' ') : '—',
            rawValue: _binaryResult,
            isInputBase: _fromBase == 'Binary',
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildResultRow(
            label: 'Octal',
            value: _hasResult ? _octalResult : '—',
            rawValue: _octalResult,
            isInputBase: _fromBase == 'Octal',
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildResultRow(
            label: 'Decimal',
            value: _hasResult ? _group(_decimalResult, 3, ',') : '—',
            rawValue: _decimalResult,
            isInputBase: _fromBase == 'Decimal',
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildResultRow(
            label: 'Hexadecimal',
            value: _hasResult ? _group(_hexResult, 2, ' ') : '—',
            rawValue: _hexResult,
            isInputBase: _fromBase == 'Hexadecimal',
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow({
    required String label,
    required String value,
    required String rawValue,
    required bool isInputBase,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    if (isInputBase) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'INPUT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: rawValue.isEmpty ? null : () => _copy(rawValue, label),
            icon: const Icon(Icons.copy, size: 18),
            color: Colors.black45,
            tooltip: 'Copy',
          ),
        ],
      ),
    );
  }
}