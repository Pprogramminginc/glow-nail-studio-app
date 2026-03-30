import 'package:flutter/material.dart';
import 'staff_navigation_screen.dart';

class StaffPinScreen extends StatefulWidget {
  const StaffPinScreen({super.key});

  @override
  State<StaffPinScreen> createState() => _StaffPinScreenState();
}

class _StaffPinScreenState extends State<StaffPinScreen> {
  // 6 digit staff PIN
  static const String staffPin = '123456';

  final TextEditingController pinController = TextEditingController();

  String? errorText;
  bool obscurePin = true;

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  void _verifyPin() {
    if (pinController.text.trim() == staffPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StaffNavigationScreen()),
      );
    } else {
      setState(() {
        errorText = 'Incorrect staff PIN';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F1),
      appBar: AppBar(
        title: const Text('Staff Access'),
        backgroundColor: const Color(0xFF7B5B43),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 54,
                    color: Color(0xFF7B5B43),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Enter Staff PIN',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6F4E37),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Authorized staff only',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    obscureText: obscurePin,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: '6-digit PIN',
                      errorText: errorText,
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFFF8F5F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePin
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePin = !obscurePin;
                          });
                        },
                      ),
                    ),
                    onChanged: (_) {
                      if (errorText != null) {
                        setState(() {
                          errorText = null;
                        });
                      }
                    },
                    onSubmitted: (_) => _verifyPin(),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B5B43),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _verifyPin,
                      child: const Text(
                        'Enter',
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
      ),
    );
  }
}
