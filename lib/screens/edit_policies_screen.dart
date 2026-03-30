import 'package:flutter/material.dart';
import '../data/studio_settings_store.dart';

class EditPoliciesScreen extends StatefulWidget {
  const EditPoliciesScreen({super.key});

  @override
  State<EditPoliciesScreen> createState() => _EditPoliciesScreenState();
}

class _EditPoliciesScreenState extends State<EditPoliciesScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _depositController;
  late final TextEditingController _rescheduleController;
  late final TextEditingController _cancellationController;
  late final TextEditingController _lateArrivalController;

  late int _cutoffHour;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _depositController = TextEditingController(
      text: StudioSettingsStore.depositPolicy,
    );
    _rescheduleController = TextEditingController(
      text: StudioSettingsStore.reschedulePolicy,
    );
    _cancellationController = TextEditingController(
      text: StudioSettingsStore.cancellationPolicy,
    );
    _lateArrivalController = TextEditingController(
      text: StudioSettingsStore.lateArrivalPolicy,
    );
    _cutoffHour = StudioSettingsStore.sameDayCutoffHour;
  }

  @override
  void dispose() {
    _depositController.dispose();
    _rescheduleController.dispose();
    _cancellationController.dispose();
    _lateArrivalController.dispose();
    super.dispose();
  }

  Future<void> _savePolicies() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    await StudioSettingsStore.savePolicies(
      depositValue: _depositController.text.trim(),
      rescheduleValue: _rescheduleController.text.trim(),
      cancellationValue: _cancellationController.text.trim(),
      lateArrivalValue: _lateArrivalController.text.trim(),
      cutoffHourValue: _cutoffHour,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking policies updated')),
    );

    Navigator.pop(context, true);
  }

  String _formatHourLabel(int hour) {
    final displayHour = hour > 12 ? hour - 12 : hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$displayHour:00 $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B5B43),
        foregroundColor: Colors.white,
        title: const Text('Manage Policies'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildCard(
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _depositController,
                        label: 'Deposit Policy',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _rescheduleController,
                        label: 'Reschedule Policy',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _cancellationController,
                        label: 'Cancellation Policy',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _lateArrivalController,
                        label: 'Late Arrival Policy',
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _cutoffHour,
                        decoration: InputDecoration(
                          labelText: 'Same-Day Booking Cutoff Time',
                          prefixIcon: const Icon(
                            Icons.schedule_outlined,
                            color: Color(0xFF7B5B43),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F5F2),
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
                        items: List.generate(12, (index) {
                          final hour = index + 8; // 8 AM through 7 PM
                          return DropdownMenuItem<int>(
                            value: hour,
                            child: Text(_formatHourLabel(hour)),
                          );
                        }),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _cutoffHour = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _savePolicies,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 44),
          child: Icon(
            Icons.policy_outlined,
            color: Color(0xFF7B5B43),
          ),
        ),
        filled: true,
        fillColor: const Color(0xFFF8F5F2),
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
    );
  }
}