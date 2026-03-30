import 'package:flutter/material.dart';
import '../data/appointment_store.dart';
import '../models/appointment.dart';

class OwnerAppointmentsScreen extends StatefulWidget {
  const OwnerAppointmentsScreen({super.key});

  @override
  State<OwnerAppointmentsScreen> createState() =>
      _OwnerAppointmentsScreenState();
}

class _OwnerAppointmentsScreenState extends State<OwnerAppointmentsScreen> {
  String _selectedFilter = 'All';

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

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatMoney(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Canceled':
        return Colors.red;
      default:
        return const Color(0xFF7B5B43);
    }
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Appointment> _filteredAppointments(List<Appointment> appointments) {
    final now = DateTime.now();

    switch (_selectedFilter) {
      case 'Today':
        return appointments.where((appt) {
          return _isSameDay(appt.date, now);
        }).toList();

      case 'Upcoming':
        return appointments.where((appt) {
          final appointmentDateTime = _combineDateAndTime(appt.date, appt.time);
          return appt.status == 'Confirmed' &&
              appointmentDateTime.isAfter(now);
        }).toList();

      case 'Completed':
        return appointments.where((appt) => appt.status == 'Completed').toList();

      case 'Canceled':
        return appointments.where((appt) => appt.status == 'Canceled').toList();

      case 'All':
      default:
        return appointments;
    }
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF7B5B43),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF6F4E37),
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD6CCC2)),
        ),
        onSelected: (_) {
          setState(() {
            _selectedFilter = label;
          });
        },
      ),
    );
  }

  Future<void> _updateStatus(Appointment appt, String newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(newStatus),
        content: Text(
          'Are you sure you want to mark this appointment as $newStatus?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'Canceled'
                  ? Colors.red
                  : Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      if (newStatus == 'Completed' && appt.status != 'Completed') {
        appt.amountCollected += appt.remainingBalance;
        appt.remainingBalance = 0;
      }

      appt.status = newStatus;
    });

    await AppointmentStore.saveAppointments();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appointment marked as $newStatus'),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF7B5B43),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2E2A27),
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoneyBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withOpacity(0.18),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2A27),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appt) {
    final Color statusColor = _statusColor(appt.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appt.clientName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2A27),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  appt.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            appt.serviceName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7B5B43),
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: _formatDate(appt.date),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: Icons.access_time_outlined,
            label: 'Time',
            value: appt.time,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: Icons.timelapse_outlined,
            label: 'Duration',
            value: '${appt.durationMinutes} mins',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: appt.phoneNumber.isEmpty ? 'Not provided' : appt.phoneNumber,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: appt.email.isEmpty ? 'Not provided' : appt.email,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildMoneyBox(
                label: 'Total',
                value: _formatMoney(appt.totalPrice),
                color: const Color(0xFF7B5B43),
              ),
              const SizedBox(width: 10),
              _buildMoneyBox(
                label: 'Collected',
                value: _formatMoney(appt.amountCollected),
                color: Colors.green,
              ),
              const SizedBox(width: 10),
              _buildMoneyBox(
                label: 'Remaining',
                value: _formatMoney(appt.remainingBalance),
                color: Colors.orange,
              ),
            ],
          ),
          if (appt.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD6CCC2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Client Notes',
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.green.shade200,
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: appt.status == 'Completed' || appt.status == 'Canceled'
                      ? null
                      : () => _updateStatus(appt, 'Completed'),
                  child: const Text('Complete'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.red.shade200,
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: appt.status == 'Canceled' || appt.status == 'Completed'
                      ? null
                      : () => _updateStatus(appt, 'Canceled'),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointments = [...AppointmentStore.appointments]
      ..sort((a, b) {
        final aDateTime = _combineDateAndTime(a.date, a.time);
        final bDateTime = _combineDateAndTime(b.date, b.time);
        return aDateTime.compareTo(bDateTime);
      });

    final filteredAppointments = _filteredAppointments(appointments);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6F4F1),
      body: Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Today'),
                _buildFilterChip('Upcoming'),
                _buildFilterChip('Completed'),
                _buildFilterChip('Canceled'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredAppointments.isEmpty
                ? Center(
                    child: Text(
                      _selectedFilter == 'All'
                          ? 'No appointments booked yet.'
                          : 'No $_selectedFilter appointments found.',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF6F4E37),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
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