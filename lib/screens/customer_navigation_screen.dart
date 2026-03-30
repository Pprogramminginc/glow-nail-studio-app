import 'package:flutter/material.dart';
import '../data/appointment_store.dart';
import '../data/studio_settings_store.dart';
import '../models/appointment.dart';
import 'home_screen.dart';

class CustomerNavigationScreen extends StatefulWidget {
  const CustomerNavigationScreen({super.key});

  @override
  State<CustomerNavigationScreen> createState() =>
      _CustomerNavigationScreenState();
}

class _CustomerNavigationScreenState extends State<CustomerNavigationScreen> {
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
        return const AppointmentsScreen();
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Book',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final List<String> allTimeSlots = const [
    '9:00 AM',
    '9:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '1:00 PM',
    '1:30 PM',
    '2:00 PM',
    '2:30 PM',
    '3:00 PM',
    '3:30 PM',
    '4:00 PM',
    '4:30 PM',
    '5:00 PM',
    '5:30 PM',
  ];

  String _selectedFilter = 'All';

  final List<String> _filters = const [
    'All',
    'Confirmed',
    'Completed',
    'Canceled',
  ];

  bool _isWorkingDay(DateTime day) {
    return day.weekday != DateTime.sunday && day.weekday != DateTime.monday;
  }

  DateTime _getFirstValidBookingDate() {
    DateTime date = DateTime.now();

    while (!_isWorkingDay(date)) {
      date = date.add(const Duration(days: 1));
    }

    return DateTime(date.year, date.month, date.day);
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
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

  String _formatDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

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

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];

    return '$weekday, $month ${date.day}, ${date.year}';
  }

  String _formatMoney(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
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
                      firstDate: _getFirstValidBookingDate(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      selectableDayPredicate: _isWorkingDay,
                      onDateChanged: (DateTime newDate) {
                        final slots = _availableTimeSlotsForDate(
                          newDate,
                          appointment,
                        );
                        setModalState(() {
                          localSelectedDate = newDate;
                          availableSlots = slots;
                          if (slots.contains(localSelectedTime)) {
                            return;
                          }
                          localSelectedTime = slots.isNotEmpty
                              ? slots.first
                              : null;
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
                                  _selectedFilter = 'Confirmed';
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
          title: const Text('Cancel Appointment'),
          content: const Text(
            'Are you sure you want to cancel this appointment?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  appointment.status = 'Canceled';
                  _selectedFilter = 'Canceled';
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appointment canceled.')),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Color _statusChipColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Canceled':
        return Colors.redAccent;
      case 'Confirmed':
        return const Color(0xFF6F4E37);
      default:
        return Colors.grey;
    }
  }

  Color _statusChipBackground(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green.withValues(alpha: 0.12);
      case 'Canceled':
        return Colors.redAccent.withValues(alpha: 0.12);
      case 'Confirmed':
        return const Color(0xFF6F4E37).withValues(alpha: 0.12);
      default:
        return Colors.grey.withValues(alpha: 0.12);
    }
  }

  Widget _buildAppointmentCard(Appointment appt) {
    final bool isConfirmed = appt.status == 'Confirmed';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      color: Colors.white,
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              runSpacing: 8,
              spacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  appt.serviceName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6F4E37),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusChipBackground(appt.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appt.status,
                    style: TextStyle(
                      color: _statusChipColor(appt.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 4),
            Text(
              'Duration: ${appt.durationMinutes} mins',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD6CCC2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Summary',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6F4E37),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Total: ${_formatMoney(appt.totalPrice)}',
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Deposit Paid: ${_formatMoney(appt.depositAmount)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6F4E37),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Remaining Balance: ${_formatMoney(appt.remainingBalance)}',
                    style: const TextStyle(fontSize: 15),
                  ),
                  if (isConfirmed) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'A 10% deposit secures your appointment. The remaining balance is due at the time of service.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (appt.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F5F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD6CCC2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6F4E37),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      appt.notes,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
            if (isConfirmed) ...[
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _cancelAppointment(appt),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8A6547) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8A6547)
                : const Color(0xFFD6CCC2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6F4E37),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  List<Appointment> _getFilteredAppointments() {
    final appointments = [...AppointmentStore.appointments]
      ..sort((a, b) {
        final aDateTime = _combineDateAndTime(a.date, a.time);
        final bDateTime = _combineDateAndTime(b.date, b.time);
        return bDateTime.compareTo(aDateTime);
      });

    switch (_selectedFilter) {
      case 'Confirmed':
        return appointments.where((appt) => appt.status == 'Confirmed').toList();
      case 'Completed':
        return appointments.where((appt) => appt.status == 'Completed').toList();
      case 'Canceled':
        return appointments.where((appt) => appt.status == 'Canceled').toList();
      case 'All':
      default:
        return appointments;
    }
  }

  String _getEmptyMessage() {
    switch (_selectedFilter) {
      case 'Confirmed':
        return 'No confirmed appointments yet.';
      case 'Completed':
        return 'No completed appointments yet.';
      case 'Canceled':
        return 'No canceled appointments yet.';
      case 'All':
      default:
        return 'No appointments yet.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAppointments = _getFilteredAppointments();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6F4F1),
      body: Column(
        children: [
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _filters.map(_buildFilterChip).toList(),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: filteredAppointments.isEmpty
                ? Center(
                    child: Text(
                      _getEmptyMessage(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filteredAppointments.length,
                    itemBuilder: (context, index) {
                      final appt = filteredAppointments[index];
                      return _buildAppointmentCard(appt);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Guest Client',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '(312) 555-0188',
  );
  final TextEditingController _emailController = TextEditingController(
    text: '',
  );
  final TextEditingController _specificTechController = TextEditingController();

  String _preferredTechOption = 'Next Available';

  final List<String> _techOptions = const [
    'Next Available',
    'Specific Nail Tech',
  ];

  String _formatCutoffHour() {
    final hour = StudioSettingsStore.sameDayCutoffHour;
    final display = hour > 12 ? hour - 12 : hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$display:00 $period';
  }

  InputDecoration _profileInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD6CCC2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF7B5B43), width: 1.5),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F4E37),
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _specificTechController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      backgroundColor: const Color(0xFFF6F4F1),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionCard(
              title: 'Account',
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: _profileInputDecoration('Full Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _profileInputDecoration(
                      'Phone Number (Login Identity)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _profileInputDecoration('Email'),
                  ),
                ],
              ),
            ),
            _buildSectionCard(
              title: 'Preferences',
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _preferredTechOption,
                    decoration: _profileInputDecoration('Preferred Nail Tech'),
                    items: _techOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _preferredTechOption = value ?? 'Next Available';
                        if (_preferredTechOption != 'Specific Nail Tech') {
                          _specificTechController.clear();
                        }
                      });
                    },
                  ),
                  if (_preferredTechOption == 'Specific Nail Tech') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _specificTechController,
                      decoration: _profileInputDecoration(
                        'Enter Nail Tech Name',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _buildSectionCard(
              title: 'Payment Method',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No saved payment method on file.',
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'For security, full card details are not stored in this version of the app.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Saved card support will be added in a future update.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.credit_card),
                      label: const Text('Add Payment Method'),
                    ),
                  ),
                ],
              ),
            ),
            _buildSectionCard(
              title: 'Booking Policy Overview',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deposit: ${StudioSettingsStore.depositPolicy}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cancellation: ${StudioSettingsStore.cancellationPolicy}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Late Policy: ${StudioSettingsStore.lateArrivalPolicy}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Same-Day Cutoff: ${_formatCutoffHour()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B5B43),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile changes saved locally.'),
                    ),
                  );
                },
                child: const Text(
                  'Save Profile',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}