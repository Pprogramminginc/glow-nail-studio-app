import 'package:flutter/material.dart';
import '../data/appointment_store.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final appointments = [...AppointmentStore.appointments]
      ..sort((a, b) {
        final aDateTime = _combineDateAndTime(a.date, a.time);
        final bDateTime = _combineDateAndTime(b.date, b.time);
        return aDateTime.compareTo(bDateTime);
      });

    final todaysAppointments = appointments
        .where((appt) => _isSameDay(appt.date, now))
        .toList();

    final upcomingAppointments = appointments.where((appt) {
      final appointmentDateTime = _combineDateAndTime(appt.date, appt.time);
      return appt.status == 'Confirmed' &&
          (appointmentDateTime.isAfter(now) || _isSameDay(appt.date, now));
    }).toList();

    final completedAppointments = appointments
        .where((appt) => appt.status == 'Completed')
        .toList();

    final canceledAppointments = appointments
        .where((appt) => appt.status == 'Canceled')
        .toList();

    final todayConfirmed = todaysAppointments
        .where((appt) => appt.status == 'Confirmed')
        .toList();

    final activeAppointments = appointments
        .where((appt) => appt.status != 'Canceled')
        .toList();

    final todaysActiveAppointments = todaysAppointments
        .where((appt) => appt.status != 'Canceled')
        .toList();

    final double totalBookedValue = activeAppointments.fold(
      0.0,
      (sum, appt) => sum + appt.totalPrice,
    );

    final double depositsCollected = activeAppointments.fold(
      0.0,
      (sum, appt) => sum + appt.depositAmount,
    );

    final double amountCollected = activeAppointments.fold(
      0.0,
      (sum, appt) => sum + appt.amountCollected,
    );

    final double todaysBookedValue = todaysActiveAppointments.fold(
      0.0,
      (sum, appt) => sum + appt.totalPrice,
    );

    final double todaysDepositsCollected = todaysActiveAppointments.fold(
      0.0,
      (sum, appt) => sum + appt.depositAmount,
    );

    final double todaysAmountCollected = todaysActiveAppointments.fold(
      0.0,
      (sum, appt) => sum + appt.amountCollected,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F1),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Owner Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2E22),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Today: ${_formatDate(now)}',
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _DashboardStatCard(
                    title: 'Today',
                    value: '${todaysAppointments.length}',
                    icon: Icons.today_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardStatCard(
                    title: 'Upcoming',
                    value: '${upcomingAppointments.length}',
                    icon: Icons.schedule_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DashboardStatCard(
                    title: 'Completed',
                    value: '${completedAppointments.length}',
                    icon: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardStatCard(
                    title: 'Canceled',
                    value: '${canceledAppointments.length}',
                    icon: Icons.cancel_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Revenue Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2E22),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MoneyStatCard(
                    title: 'Total Booked',
                    value: _formatMoney(totalBookedValue),
                    subtitle: 'All active appointments',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MoneyStatCard(
                    title: 'Deposits',
                    value: _formatMoney(depositsCollected),
                    subtitle: 'Collected at booking',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MoneyStatCard(
                    title: 'Amount Collected',
                    value: _formatMoney(amountCollected),
                    subtitle: 'Deposits + completed balances',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MoneyStatCard(
                    title: 'Today’s Deposits',
                    value: _formatMoney(todaysDepositsCollected),
                    subtitle: 'Today only',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF9B7A63),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today’s Schedule',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    todayConfirmed.isEmpty
                        ? 'No confirmed appointments today.'
                        : '${todayConfirmed.length} confirmed appointment(s) scheduled.',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Today’s booked value: ${_formatMoney(todaysBookedValue)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Today’s amount collected: ${_formatMoney(todaysAmountCollected)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (todayConfirmed.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No appointments booked for today yet.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              ...todayConfirmed.map(
                (appt) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appt.time,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6F4E37),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          appt.clientName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appt.serviceName,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Phone: ${appt.phoneNumber.isEmpty ? "Not provided" : appt.phoneNumber}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Amount Collected: ${_formatMoney(appt.amountCollected)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6F4E37),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Remaining Balance: ${_formatMoney(appt.remainingBalance)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (appt.notes.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F5F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFD6CCC2),
                              ),
                            ),
                            child: Text(
                              'Notes: ${appt.notes}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DashboardStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Colors.black12, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF7B5B43), size: 26),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2E22),
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _MoneyStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _MoneyStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Colors.black12, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6F4E37),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
