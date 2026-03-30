import 'package:flutter/material.dart';
import '../data/appointment_store.dart';
import '../models/appointment.dart';
import 'home_screen.dart';
import 'owner_appointments_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const ConfirmedAppointmentsScreen();
      case 2:
        return const ProfileTabScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF6F4E37),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ConfirmedAppointmentsScreen extends StatefulWidget {
  const ConfirmedAppointmentsScreen({super.key});

  @override
  State<ConfirmedAppointmentsScreen> createState() =>
      _ConfirmedAppointmentsScreenState();
}

class _ConfirmedAppointmentsScreenState
    extends State<ConfirmedAppointmentsScreen> {
  final List<String> allTimeSlots = const [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
  ];

  bool _isWorkingDay(DateTime day) {
    return day.weekday != DateTime.sunday && day.weekday != DateTime.monday;
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  List<String> _availableTimeSlotsForDate(
    DateTime date,
    Appointment currentAppointment,
  ) {
    final sameDayAppointments = AppointmentStore.appointments.where((appt) {
      final sameDay = _dateKey(appt.date) == _dateKey(date);
      final notCanceled = appt.status != 'Canceled';
      final notCurrent = !identical(appt, currentAppointment);
      return sameDay && notCanceled && notCurrent;
    }).toList();

    final bookedTimes = sameDayAppointments.map((appt) => appt.time).toSet();

    return allTimeSlots.where((slot) => !bookedTimes.contains(slot)).toList();
  }

  Future<void> _openRescheduleSheet(Appointment appointment) async {
    DateTime localSelectedDate = appointment.date;
    while (!_isWorkingDay(localSelectedDate)) {
      localSelectedDate = localSelectedDate.add(const Duration(days: 1));
    }

    List<String> availableSlots = _availableTimeSlotsForDate(
      localSelectedDate,
      appointment,
    );

    String? localSelectedTime =
        availableSlots.contains(appointment.time) &&
                appointment.status != 'Canceled'
            ? appointment.time
            : (availableSlots.isNotEmpty ? availableSlots.first : null);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF8F5F2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Reschedule Appointment',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6F4E37),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CalendarDatePicker(
                      initialDate: localSelectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      selectableDayPredicate: _isWorkingDay,
                      onDateChanged: (DateTime newDate) {
                        final slots =
                            _availableTimeSlotsForDate(newDate, appointment);
                        setModalState(() {
                          localSelectedDate = newDate;
                          availableSlots = slots;
                          if (slots.contains(localSelectedTime)) {
                            return;
                          }
                          localSelectedTime =
                              slots.isNotEmpty ? slots.first : null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (availableSlots.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.red.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'No time slots available for this date.',
                          style: TextStyle(fontSize: 15),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: localSelectedTime,
                        decoration: InputDecoration(
                          labelText: 'Select Time',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: availableSlots.map((time) {
                          return DropdownMenuItem<String>(
                            value: time,
                            child: Text(time),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            localSelectedTime = value;
                          });
                        },
                      ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6F4E37),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: localSelectedTime == null
                            ? null
                            : () {
                                setState(() {
                                  appointment.date = localSelectedDate;
                                  appointment.time = localSelectedTime!;
                                  appointment.status = 'Confirmed';
                                });
                                Navigator.pop(sheetContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Appointment rescheduled successfully.',
                                    ),
                                  ),
                                );
                              },
                        child: const Text(
                          'Save Reschedule',
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
            );
          },
        );
      },
    );
  }

  void _cancelAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Cancel Appointment"),
          content: const Text(
            "Are you sure you want to cancel this appointment?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("No"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  appointment.status = 'Canceled';
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Appointment canceled."),
                  ),
                );
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointments = AppointmentStore.appointments
        .where((appt) => appt.status == 'Confirmed')
        .toList()
      ..sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        return a.time.compareTo(b.time);
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmed Appointments'),
        centerTitle: true,
      ),
      body: appointments.isEmpty
          ? const Center(
              child: Text(
                'No confirmed appointments yet.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appt = appointments[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appt.serviceName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6F4E37),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Booked for: ${appt.clientName}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Date: ${_formatDate(appt.date)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Time: ${appt.time}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.brown.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            appt.status,
                            style: const TextStyle(
                              color: Color(0xFF6F4E37),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF6F4E37),
                                  side: const BorderSide(
                                    color: Color(0xFF6F4E37),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => _openRescheduleSheet(appt),
                                child: const Text('Reschedule'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => _cancelAppointment(appt),
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Profile section coming soon.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OwnerAppointmentsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.lock_outline),
                label: const Text('Owner Access'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}