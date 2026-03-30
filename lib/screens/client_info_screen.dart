import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/appointment.dart';
import '../data/appointment_store.dart';
import '../data/cart_store.dart';
import 'customer_navigation_screen.dart';

class ClientInfoScreen extends StatefulWidget {
  final DateTime selectedDate;
  final String selectedTime;
  final int duration;
  final List<CartItem> services;

  const ClientInfoScreen({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.duration,
    required this.services,
  });

  @override
  State<ClientInfoScreen> createState() => _ClientInfoScreenState();
}

class _ClientInfoScreenState extends State<ClientInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    notesController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    return widget.services.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice.toDouble(),
    );
  }

  double get _depositAmount {
    return double.parse((_totalPrice * 0.10).toStringAsFixed(2));
  }

  double get _remainingBalance {
    return double.parse((_totalPrice - _depositAmount).toStringAsFixed(2));
  }

  void _confirmBooking() {
    if (!_formKey.currentState!.validate()) return;

    final servicesString = widget.services.map((e) => e.title).join(", ");

    AppointmentStore.appointments.add(
      Appointment(
        clientName: nameController.text.trim(),
        serviceName: servicesString,
        phoneNumber: phoneController.text.trim(),
        email: emailController.text.trim(),
        notes: notesController.text.trim(),
        date: widget.selectedDate,
        time: widget.selectedTime,
        durationMinutes: widget.duration,
        totalPrice: _totalPrice,
        depositAmount: _depositAmount,
        remainingBalance: _remainingBalance,
      ),
    );

    CartStore.clearCart();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerNavigationScreen(),
      ),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Booking confirmed. \$${_depositAmount.toStringAsFixed(2)} deposit collected.',
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD6CCC2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF7B5B43),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceNames = widget.services.map((e) => e.title).join(", ");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Client Information"),
        backgroundColor: const Color(0xFF7B5B43),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF6F4F1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Booking Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B5B43),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("Services: $serviceNames"),
                        const SizedBox(height: 4),
                        Text("Time: ${widget.selectedTime}"),
                        const SizedBox(height: 4),
                        Text("Duration: ${widget.duration} mins"),
                        const SizedBox(height: 8),
                        Text(
                          "Total: \$${_totalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Required Deposit (10%): \$${_depositAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6F4E37),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Remaining Balance: \$${_remainingBalance.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8E0),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFD6CCC2),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Deposit Policy",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6F4E37),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "A 10% Deposit is required to secure your appointment. "
                        "Cancellations or reschedules must be made atleast 48 hours in advance "
                        "in order for your deposit to be refundable, DPMO. "
                        "The remaining balance will be due at the time of service. "
                        "Late arrivals may result in a shortened service or rescheduling depending on availability.",
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration("Client Name"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter client name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration("Phone Number"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Phone number required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration("Email (optional)"),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesController,
                  textInputAction: TextInputAction.done,
                  decoration: _inputDecoration("Notes (optional)"),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B5B43),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _confirmBooking,
                    child: Text(
                      "Pay \$${_depositAmount.toStringAsFixed(2)} Deposit & Book",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}