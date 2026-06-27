import 'package:flutter/material.dart';

class DateConverterPage extends StatefulWidget {
  const DateConverterPage({super.key});

  @override
  State<DateConverterPage> createState() => _DateConverterPageState();
}

class _DateConverterPageState extends State<DateConverterPage> {
  static const Color _primaryColor = Color(0xFF4A55A2);
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  Future<void> _pickDate(bool isStart) async {
    final DateTime initial = (isStart ? _startDate : _endDate) ?? DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    setState(() {
      if (isStart) {
        _startDate = DateTime(date.year, date.month, date.day);
      } else {
        _endDate = DateTime(date.year, date.month, date.day);
      }
    });
  }

  Future<void> _pickTime(bool isStart) async {
    final TimeOfDay initial = (isStart ? _startTime : _endTime) ?? TimeOfDay.now();

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (time == null) return;

    setState(() {
      if (isStart) {
        _startTime = time;
      } else {
        _endTime = time;
      }
    });
  }

  void _clearTime(bool isStart) {
    setState(() {
      if (isStart) {
        _startTime = null;
      } else {
        _endTime = null;
      }
    });
  }

  void _swapDates() {
    setState(() {
      final DateTime? tempDate = _startDate;
      final TimeOfDay? tempTime = _startTime;
      _startDate = _endDate;
      _startTime = _endTime;
      _endDate = tempDate;
      _endTime = tempTime;
    });
  }

  DateTime _combine(DateTime date, TimeOfDay? time) {
    return DateTime(date.year, date.month, date.day, time?.hour ?? 0, time?.minute ?? 0);
  }

  _DateDifference? get _difference {
    if (_startDate == null || _endDate == null) return null;

    final bool includeTime = _startTime != null || _endTime != null;
    final DateTime startDt = _combine(_startDate!, _startTime);
    final DateTime endDt = _combine(_endDate!, _endTime);

    return _calculateDifference(startDt, endDt, includeTime: includeTime);
  }

  _DateDifference _calculateDifference(DateTime a, DateTime b, {required bool includeTime}) {
    DateTime from = a;
    DateTime to = b;
    bool isNegative = false;

    if (to.isBefore(from)) {
      final DateTime temp = from;
      from = to;
      to = temp;
      isNegative = true;
    }

    int years = to.year - from.year;
    int months = to.month - from.month;
    int days = to.day - from.day;
    int hours = to.hour - from.hour;
    int minutes = to.minute - from.minute;

    if (minutes < 0) {
      minutes += 60;
      hours -= 1;
    }
    if (hours < 0) {
      hours += 24;
      days -= 1;
    }
    if (days < 0) {
      // Day 0 of "to"'s month rolls back to the last day of the previous month.
      final int daysInPrevMonth = DateTime(to.year, to.month, 0).day;
      days += daysInPrevMonth;
      months -= 1;
    }
    if (months < 0) {
      months += 12;
      years -= 1;
    }

    return _DateDifference(
      years: years,
      months: months,
      days: days,
      hours: hours,
      minutes: minutes,
      totalDuration: to.difference(from),
      isNegative: isNegative,
      includeTime: includeTime,
    );
  }

  String _formatDate(DateTime dt) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(TimeOfDay t) {
    final int hour12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final String period = t.hour >= 12 ? 'PM' : 'AM';
    final String minute = t.minute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final _DateDifference? diff = _difference;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      appBar: AppBar(
        title: const Text('Date Converter'),
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
              _buildDateTimeCard(
                sectionLabel: 'START',
                date: _startDate,
                time: _startTime,
                onTapDate: () => _pickDate(true),
                onTapTime: () => _pickTime(true),
                onClearTime: () => _clearTime(true),
              ),
              Center(
                child: IconButton(
                  onPressed: (_startDate != null || _endDate != null) ? _swapDates : null,
                  icon: const Icon(Icons.swap_vert, color: _primaryColor),
                  tooltip: 'Swap start and end',
                ),
              ),
              _buildDateTimeCard(
                sectionLabel: 'END',
                date: _endDate,
                time: _endTime,
                onTapDate: () => _pickDate(false),
                onTapTime: () => _pickTime(false),
                onClearTime: () => _clearTime(false),
              ),
              const SizedBox(height: 18),
              _buildResultCard(diff),
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

  Widget _buildDateTimeCard({
    required String sectionLabel,
    required DateTime? date,
    required TimeOfDay? time,
    required VoidCallback onTapDate,
    required VoidCallback onTapTime,
    required VoidCallback onClearTime,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Text(
                    sectionLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            _buildPickerRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: date == null ? 'Tap to select' : _formatDate(date),
              isSet: date != null,
              onTap: onTapDate,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildPickerRow(
              icon: Icons.access_time,
              label: 'Time (optional)',
              value: time == null ? 'Not set' : _formatTime(time),
              isSet: time != null,
              onTap: onTapTime,
              trailing: time != null
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.black38),
                      onPressed: onClearTime,
                      tooltip: 'Clear time',
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // The trailing widget (clear button or chevron) is a SIBLING of the
  // InkWell, not a child of it — so tapping "clear" never also triggers
  // the row's onTap for opening the time picker.
  Widget _buildPickerRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isSet,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: _primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSet ? Colors.black87 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: trailing ?? const Icon(Icons.chevron_right, color: Colors.black38, size: 20),
        ),
      ],
    );
  }

  Widget _buildResultCard(_DateDifference? diff) {
    if (diff == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Text(
          'Pick a date for both Start and End to see the difference.\nTime is optional — add it for hour and minute precision.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black45),
        ),
      );
    }

    return Card(
      elevation: 2,
      color: _primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              diff.isNegative ? 'Start is after end' : 'Time difference',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Text(
              diff.readableBreakdown,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white30, height: 1),
            const SizedBox(height: 16),
            diff.includeTime
                ? _buildTotalsRow(diff)
                : _buildTotalItem('Total days', diff.totalDuration.inDays.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsRow(_DateDifference diff) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTotalItem('Days', diff.totalDuration.inDays.toString()),
        _buildTotalItem('Hours', diff.totalDuration.inHours.toString()),
        _buildTotalItem('Minutes', diff.totalDuration.inMinutes.toString()),
      ],
    );
  }

  Widget _buildTotalItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _DateDifference {
  final int years;
  final int months;
  final int days;
  final int hours;
  final int minutes;
  final Duration totalDuration;
  final bool isNegative;
  final bool includeTime;

  _DateDifference({
    required this.years,
    required this.months,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.totalDuration,
    required this.isNegative,
    required this.includeTime,
  });

  String get readableBreakdown {
    final List<String> parts = [];
    if (years > 0) parts.add('$years ${years == 1 ? 'year' : 'years'}');
    if (months > 0) parts.add('$months ${months == 1 ? 'month' : 'months'}');
    if (days > 0) parts.add('$days ${days == 1 ? 'day' : 'days'}');

    if (includeTime) {
      if (hours > 0) parts.add('$hours ${hours == 1 ? 'hour' : 'hours'}');
      if (minutes > 0 || parts.isEmpty) {
        parts.add('$minutes ${minutes == 1 ? 'minute' : 'minutes'}');
      }
    } else if (parts.isEmpty) {
      parts.add('0 days');
    }

    return parts.join(', ');
  }
}