import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';

class AppointmentStore {
  static const String _appointmentsKey = 'appointments';

  static List<Appointment> appointments = [];

  static Future<void> loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedAppointments =
        prefs.getStringList(_appointmentsKey) ?? [];

    appointments = savedAppointments
        .map((item) => Appointment.fromJson(item))
        .toList();
  }

  static Future<void> saveAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedAppointments = appointments
        .map((appt) => appt.toJson())
        .toList();

    await prefs.setStringList(_appointmentsKey, encodedAppointments);
  }

  static Future<void> addAppointment(Appointment appointment) async {
    appointments.add(appointment);
    await saveAppointments();
  }

  static Future<void> removeAppointment(Appointment appointment) async {
    appointments.remove(appointment);
    await saveAppointments();
  }

  static Future<void> clearAppointments() async {
    appointments.clear();
    await saveAppointments();
  }
}
