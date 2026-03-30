import 'package:flutter/material.dart';
import '../data/studio_settings_store.dart';

class EditBusinessHoursScreen extends StatefulWidget {
  const EditBusinessHoursScreen({super.key});

  @override
  State<EditBusinessHoursScreen> createState() =>
      _EditBusinessHoursScreenState();
}

class _EditBusinessHoursScreenState extends State<EditBusinessHoursScreen> {
  bool _isSaving = false;

  late Map<String, DayHoursData> _days;

  @override
  void initState() {
    super.initState();

    _days = {
      'Monday': DayHoursData.fromStoredValue(StudioSettingsStore.monday),
      'Tuesday': DayHoursData.fromStoredValue(StudioSettingsStore.tuesday),
      'Wednesday': DayHoursData.fromStoredValue(StudioSettingsStore.wednesday),
      'Thursday': DayHoursData.fromStoredValue(StudioSettingsStore.thursday),
      'Friday': DayHoursData.fromStoredValue(StudioSettingsStore.friday),
      'Saturday': DayHoursData.fromStoredValue(StudioSettingsStore.saturday),
      'Sunday': DayHoursData.fromStoredValue(StudioSettingsStore.sunday),
    };
  }

  Future<void> _pickTime({
    required String day,
    required bool isStartTime,
  }) async {
    final dayData = _days[day]!;

    final initialTime = isStartTime
        ? (dayData.startTime ?? const TimeOfDay(hour: 9, minute: 0))
        : (dayData.endTime ?? const TimeOfDay(hour: 18, minute: 0));

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF7B5B43)),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    setState(() {
      if (isStartTime) {
        dayData.startTime = pickedTime;
      } else {
        dayData.endTime = pickedTime;
      }
    });
  }

  bool _validateHours() {
    for (final entry in _days.entries) {
      final day = entry.key;
      final data = entry.value;

      if (!data.isOpen) continue;

      if (data.startTime == null || data.endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select both opening and closing times for $day',
            ),
          ),
        );
        return false;
      }

      final startMinutes = data.startTime!.hour * 60 + data.startTime!.minute;
      final endMinutes = data.endTime!.hour * 60 + data.endTime!.minute;

      if (endMinutes <= startMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$day closing time must be later than opening time'),
          ),
        );
        return false;
      }
    }

    return true;
  }

  Future<void> _saveHours() async {
    if (!_validateHours()) return;

    setState(() {
      _isSaving = true;
    });

    await StudioSettingsStore.saveBusinessHours(
      mondayValue: _days['Monday']!.toStoredValue(context),
      tuesdayValue: _days['Tuesday']!.toStoredValue(context),
      wednesdayValue: _days['Wednesday']!.toStoredValue(context),
      thursdayValue: _days['Thursday']!.toStoredValue(context),
      fridayValue: _days['Friday']!.toStoredValue(context),
      saturdayValue: _days['Saturday']!.toStoredValue(context),
      sundayValue: _days['Sunday']!.toStoredValue(context),
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Business hours updated')));

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B5B43),
        foregroundColor: Colors.white,
        title: const Text('Update Business Hours'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCard(
                child: Column(
                  children: _days.entries.map((entry) {
                    final day = entry.key;
                    final data = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _buildDayHoursCard(day, data),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveHours,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B5B43),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayHoursCard(String day, DayHoursData data) {
    final displayStart = data.startTime == null
        ? 'Select time'
        : _formatTime(data.startTime!);
    final displayEnd = data.endTime == null
        ? 'Select time'
        : _formatTime(data.endTime!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DED6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E2A27),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<bool>(
            value: data.isOpen,
            decoration: InputDecoration(
              labelText: 'Status',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF7B5B43),
                  width: 1.5,
                ),
              ),
            ),
            items: const [
              DropdownMenuItem(value: true, child: Text('Open')),
              DropdownMenuItem(value: false, child: Text('Closed')),
            ],
            onChanged: (value) {
              setState(() {
                data.isOpen = value ?? false;
                if (!data.isOpen) {
                  data.startTime = null;
                  data.endTime = null;
                } else {
                  data.startTime ??= const TimeOfDay(hour: 9, minute: 0);
                  data.endTime ??= const TimeOfDay(hour: 18, minute: 0);
                }
              });
            },
          ),
          if (data.isOpen) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector(
                    label: 'Open Time',
                    value: displayStart,
                    onTap: () => _pickTime(day: day, isStartTime: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeSelector(
                    label: 'Close Time',
                    value: displayEnd,
                    onTap: () => _pickTime(day: day, isStartTime: false),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE1D7CF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7A746E),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.access_time_outlined,
                  size: 18,
                  color: Color(0xFF7B5B43),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF2E2A27),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  String _formatTime(TimeOfDay time) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(time);
  }
}

class DayHoursData {
  bool isOpen;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  DayHoursData({required this.isOpen, this.startTime, this.endTime});

  factory DayHoursData.fromStoredValue(String value) {
    if (value.trim().toLowerCase() == 'closed') {
      return DayHoursData(isOpen: false);
    }

    final parts = value.split(' - ');
    if (parts.length == 2) {
      return DayHoursData(
        isOpen: true,
        startTime: _parseTime(parts[0]),
        endTime: _parseTime(parts[1]),
      );
    }

    return DayHoursData(
      isOpen: true,
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 18, minute: 0),
    );
  }

  String toStoredValue(BuildContext context) {
    if (!isOpen) return 'Closed';

    final localizations = MaterialLocalizations.of(context);
    final openText = localizations.formatTimeOfDay(startTime!);
    final closeText = localizations.formatTimeOfDay(endTime!);

    return '$openText - $closeText';
  }

  static TimeOfDay? _parseTime(String input) {
    final text = input.trim().toUpperCase();

    final regex = RegExp(r'^(\d{1,2}):(\d{2})\s?(AM|PM)$');
    final match = regex.firstMatch(text);

    if (match == null) return null;

    int hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final meridiem = match.group(3)!;

    if (hour == 12) {
      hour = 0;
    }
    if (meridiem == 'PM') {
      hour += 12;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }
}
