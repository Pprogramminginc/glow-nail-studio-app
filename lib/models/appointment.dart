import 'dart:convert';

class Appointment {
  final String clientName;
  final String serviceName;
  final String phoneNumber;
  final String email;
  final String notes;

  DateTime date;
  String time;
  int durationMinutes;

  double totalPrice;
  double depositAmount;
  double remainingBalance;
  double amountCollected;

  String status;

  Appointment({
    required this.clientName,
    required this.serviceName,
    required this.phoneNumber,
    required this.email,
    required this.notes,
    required this.date,
    required this.time,
    required this.durationMinutes,
    required this.totalPrice,
    required this.depositAmount,
    required this.remainingBalance,
    double? amountCollected,
    this.status = 'Confirmed',
  }) : amountCollected = amountCollected ?? depositAmount;

  Map<String, dynamic> toMap() {
    return {
      'clientName': clientName,
      'serviceName': serviceName,
      'phoneNumber': phoneNumber,
      'email': email,
      'notes': notes,
      'date': date.toIso8601String(),
      'time': time,
      'durationMinutes': durationMinutes,
      'totalPrice': totalPrice,
      'depositAmount': depositAmount,
      'remainingBalance': remainingBalance,
      'amountCollected': amountCollected,
      'status': status,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    final deposit = (map['depositAmount'] ?? 0).toDouble();

    return Appointment(
      clientName: map['clientName'] ?? '',
      serviceName: map['serviceName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      notes: map['notes'] ?? '',
      date: DateTime.parse(map['date']),
      time: map['time'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 0,
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      depositAmount: deposit,
      remainingBalance: (map['remainingBalance'] ?? 0).toDouble(),
      amountCollected: (map['amountCollected'] ?? deposit).toDouble(),
      status: map['status'] ?? 'Confirmed',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Appointment.fromJson(String source) =>
      Appointment.fromMap(jsonDecode(source));
}