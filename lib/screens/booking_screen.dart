import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../data/appointment_store.dart';
import '../data/studio_settings_store.dart';
import 'client_info_screen.dart';

class BookingScreen extends StatefulWidget {
  final int totalDuration;
  final List<CartItem> services;

  const BookingScreen({
    super.key,
    required this.totalDuration,
    required this.services,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  static const int cleanupBufferMinutes = 15;
  static const int slotIntervalMinutes = 30;
  static const int minimumAdvanceHours = 2;
  static const int maxBookingDaysAhead = 30;

  late DateTime selectedDate;
  String? selectedTime;

  int get sameDayCutoffHour => StudioSettingsStore.sameDayCutoffHour;

  @override
  void initState() {
    super.initState();
    selectedDate = _getFirstValidBookingDate();
  }

  DateTime _stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _getStoredHoursForDate(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return StudioSettingsStore.monday;
      case DateTime.tuesday:
        return StudioSettingsStore.tuesday;
      case DateTime.wednesday:
        return StudioSettingsStore.wednesday;
      case DateTime.thursday:
        return StudioSettingsStore.thursday;
      case DateTime.friday:
        return StudioSettingsStore.friday;
      case DateTime.saturday:
        return StudioSettingsStore.saturday;
      case DateTime.sunday:
        return StudioSettingsStore.sunday;
      default:
        return 'Closed';
    }
  }

  bool _isWithinBookingWindow(DateTime day) {
    final today = _stripTime(DateTime.now());
    final lastBookableDate = today.add(
      const Duration(days: maxBookingDaysAhead),
    );

    return !day.isBefore(today) && !day.isAfter(lastBookableDate);
  }

  bool isWorkingDay(DateTime day) {
    return _getStoredHoursForDate(day).trim().toLowerCase() != 'closed';
  }

  bool _isDateSelectable(DateTime day) {
    return isWorkingDay(day) && _isWithinBookingWindow(day);
  }

  DateTime _getFirstValidBookingDate() {
    DateTime date = _stripTime(DateTime.now());
    final DateTime lastBookableDate = date.add(
      const Duration(days: maxBookingDaysAhead),
    );

    while (!_isDateSelectable(date)) {
      date = date.add(const Duration(days: 1));

      if (date.isAfter(lastBookableDate)) {
        return _stripTime(DateTime.now());
      }
    }

    return date;
  }

  DateTime _combineDateAndTime(DateTime date, String time) {
    final parts = time.split(' ');
    final hm = parts[0].split(':');
    int hour = int.parse(hm[0]);
    final int minute = int.parse(hm[1]);
    final String period = parts[1];

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  TimeOfDay? _parseTime(String input) {
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

  DateTime? _timeOfDayToDateTime(DateTime date, TimeOfDay? time) {
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  List<DateTime>? _getOpeningAndClosingDateTimes(DateTime date) {
    final storedHours = _getStoredHoursForDate(date);

    if (storedHours.trim().toLowerCase() == 'closed') {
      return null;
    }

    final parts = storedHours.split(' - ');
    if (parts.length != 2) {
      return null;
    }

    final openTime = _parseTime(parts[0]);
    final closeTime = _parseTime(parts[1]);

    final openDateTime = _timeOfDayToDateTime(date, openTime);
    final closeDateTime = _timeOfDayToDateTime(date, closeTime);

    if (openDateTime == null || closeDateTime == null) {
      return null;
    }

    return [openDateTime, closeDateTime];
  }

  bool _violatesAdvanceNotice(DateTime slotStart) {
    final earliestAllowed = DateTime.now().add(
      const Duration(hours: minimumAdvanceHours),
    );
    return slotStart.isBefore(earliestAllowed);
  }

  bool _violatesSameDayCutoff(DateTime slotStart) {
    final now = DateTime.now();
    final today = _stripTime(now);
    final slotDay = _stripTime(slotStart);

    if (!_isSameDay(today, slotDay)) {
      return false;
    }

    final cutoff = DateTime(now.year, now.month, now.day, sameDayCutoffHour, 0);

    return now.isAfter(cutoff);
  }

  bool _doesTimeSlotConflict(String slot, DateTime date) {
    final proposedStart = _combineDateAndTime(date, slot);
    final proposedEnd = proposedStart.add(
      Duration(minutes: widget.totalDuration + cleanupBufferMinutes),
    );

    final sameDayAppointments = AppointmentStore.appointments.where((appt) {
      return _dateKey(appt.date) == _dateKey(date) && appt.status != 'Canceled';
    }).toList();

    for (final appt in sameDayAppointments) {
      final existingStart = _combineDateAndTime(appt.date, appt.time);
      final existingEnd = existingStart.add(
        Duration(minutes: appt.durationMinutes + cleanupBufferMinutes),
      );

      final overlaps =
          proposedStart.isBefore(existingEnd) &&
          proposedEnd.isAfter(existingStart);

      if (overlaps) {
        return true;
      }
    }

    return false;
  }

  String _formatDateTimeToSlot(DateTime dateTime) {
    final localizations = MaterialLocalizations.of(context);
    final timeOfDay = TimeOfDay.fromDateTime(dateTime);
    return localizations.formatTimeOfDay(timeOfDay);
  }

  List<String> _availableTimeSlotsForSelectedDate() {
    if (!_isDateSelectable(selectedDate)) {
      return [];
    }

    final hours = _getOpeningAndClosingDateTimes(selectedDate);
    if (hours == null) return [];

    final openingTime = hours[0];
    final closingTime = hours[1];

    final latestAllowedStart = closingTime.subtract(
      Duration(minutes: widget.totalDuration + cleanupBufferMinutes),
    );

    if (latestAllowedStart.isBefore(openingTime)) {
      return [];
    }

    final List<String> slots = [];
    DateTime current = openingTime;

    while (!current.isAfter(latestAllowedStart)) {
      final slot = _formatDateTimeToSlot(current);

      final violatesAdvanceNotice = _violatesAdvanceNotice(current);
      final violatesSameDayCutoff = _violatesSameDayCutoff(current);
      final conflicts = _doesTimeSlotConflict(slot, selectedDate);

      if (!violatesAdvanceNotice && !violatesSameDayCutoff && !conflicts) {
        slots.add(slot);
      }

      current = current.add(const Duration(minutes: slotIntervalMinutes));
    }

    return slots;
  }

  String _formatCutoffHourLabel() {
    final displayHour = sameDayCutoffHour > 12
        ? sameDayCutoffHour - 12
        : sameDayCutoffHour;
    final period = sameDayCutoffHour >= 12 ? 'PM' : 'AM';
    return '$displayHour:00 $period';
  }

  String _getAvailabilityMessage(List<String> availableSlots) {
    if (!_isWithinBookingWindow(selectedDate)) {
      return 'Appointments can only be booked up to $maxBookingDaysAhead days in advance.';
    }

    if (!isWorkingDay(selectedDate)) {
      return 'Glow Nail Studio is closed on this day.';
    }

    if (_isSameDay(_stripTime(selectedDate), _stripTime(DateTime.now()))) {
      final now = DateTime.now();
      final cutoff = DateTime(
        now.year,
        now.month,
        now.day,
        sameDayCutoffHour,
        0,
      );

      if (now.isAfter(cutoff)) {
        return 'Same-day booking is no longer available after ${_formatCutoffHourLabel()}.';
      }
    }

    if (availableSlots.isEmpty) {
      return 'No available time slots for this date.';
    }

    return '';
  }

  void _confirmBooking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientInfoScreen(
          selectedDate: selectedDate,
          selectedTime: selectedTime!,
          duration: widget.totalDuration,
          services: widget.services,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime firstDate = _stripTime(DateTime.now());
    final DateTime lastDate = firstDate.add(
      const Duration(days: maxBookingDaysAhead),
    );

    if (!_isDateSelectable(selectedDate)) {
      selectedDate = _getFirstValidBookingDate();
      selectedTime = null;
    }

    final availableSlots = _availableTimeSlotsForSelectedDate();

    if (selectedTime != null && !availableSlots.contains(selectedTime)) {
      selectedTime = null;
    }

    final availabilityMessage = _getAvailabilityMessage(availableSlots);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Appointment Time"),
        backgroundColor: const Color(0xFF7B5B43),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF6F4F1),
      body: Column(
        children: [
          CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: firstDate,
            lastDate: lastDate,
            selectableDayPredicate: _isDateSelectable,
            onDateChanged: (date) {
              setState(() {
                selectedDate = date;
                selectedTime = null;
              });
            },
          ),
          const SizedBox(height: 10),
          const Text(
            "Available Times",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: availableSlots.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        availabilityMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: availableSlots.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.2,
                        ),
                    itemBuilder: (context, index) {
                      final time = availableSlots[index];
                      final isSelected = selectedTime == time;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTime = time;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF7B5B43)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF7B5B43)),
                          ),
                          child: Center(
                            child: Text(
                              time,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B5B43),
                  foregroundColor: Colors.white,
                ),
                onPressed: selectedTime == null ? null : _confirmBooking,
                child: const Text("Continue", style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
