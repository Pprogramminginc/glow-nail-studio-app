import 'package:shared_preferences/shared_preferences.dart';

class StudioSettingsStore {
  static String monday = 'Closed';
  static String tuesday = '9:00 AM - 6:00 PM';
  static String wednesday = '9:00 AM - 6:00 PM';
  static String thursday = '9:00 AM - 6:00 PM';
  static String friday = '9:00 AM - 6:00 PM';
  static String saturday = '10:00 AM - 4:00 PM';
  static String sunday = 'Closed';

  static String depositPolicy =
      'A deposit is required to confirm every booking.';
  static String reschedulePolicy =
      'Appointments may be rescheduled in advance based on availability.';
  static String cancellationPolicy =
      'Cancellations may result in deposit forfeiture.';
  static String lateArrivalPolicy =
      'Clients arriving late may need to shorten or reschedule the appointment.';

  static int sameDayCutoffHour = 17;

  static const String _mondayKey = 'hours_monday';
  static const String _tuesdayKey = 'hours_tuesday';
  static const String _wednesdayKey = 'hours_wednesday';
  static const String _thursdayKey = 'hours_thursday';
  static const String _fridayKey = 'hours_friday';
  static const String _saturdayKey = 'hours_saturday';
  static const String _sundayKey = 'hours_sunday';

  static const String _depositPolicyKey = 'policy_deposit';
  static const String _reschedulePolicyKey = 'policy_reschedule';
  static const String _cancellationPolicyKey = 'policy_cancellation';
  static const String _lateArrivalPolicyKey = 'policy_late_arrival';
  static const String _cutoffKey = 'same_day_cutoff';

  static Future<void> loadStudioSettings() async {
    final prefs = await SharedPreferences.getInstance();

    monday = prefs.getString(_mondayKey) ?? monday;
    tuesday = prefs.getString(_tuesdayKey) ?? tuesday;
    wednesday = prefs.getString(_wednesdayKey) ?? wednesday;
    thursday = prefs.getString(_thursdayKey) ?? thursday;
    friday = prefs.getString(_fridayKey) ?? friday;
    saturday = prefs.getString(_saturdayKey) ?? saturday;
    sunday = prefs.getString(_sundayKey) ?? sunday;

    depositPolicy = prefs.getString(_depositPolicyKey) ?? depositPolicy;
    reschedulePolicy =
        prefs.getString(_reschedulePolicyKey) ?? reschedulePolicy;
    cancellationPolicy =
        prefs.getString(_cancellationPolicyKey) ?? cancellationPolicy;
    lateArrivalPolicy =
        prefs.getString(_lateArrivalPolicyKey) ?? lateArrivalPolicy;

    sameDayCutoffHour = prefs.getInt(_cutoffKey) ?? sameDayCutoffHour;
  }

  static Future<void> saveBusinessHours({
    required String mondayValue,
    required String tuesdayValue,
    required String wednesdayValue,
    required String thursdayValue,
    required String fridayValue,
    required String saturdayValue,
    required String sundayValue,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    monday = mondayValue;
    tuesday = tuesdayValue;
    wednesday = wednesdayValue;
    thursday = thursdayValue;
    friday = fridayValue;
    saturday = saturdayValue;
    sunday = sundayValue;

    await prefs.setString(_mondayKey, monday);
    await prefs.setString(_tuesdayKey, tuesday);
    await prefs.setString(_wednesdayKey, wednesday);
    await prefs.setString(_thursdayKey, thursday);
    await prefs.setString(_fridayKey, friday);
    await prefs.setString(_saturdayKey, saturday);
    await prefs.setString(_sundayKey, sunday);
  }

  static Future<void> savePolicies({
    required String depositValue,
    required String rescheduleValue,
    required String cancellationValue,
    required String lateArrivalValue,
    required int cutoffHourValue,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    depositPolicy = depositValue;
    reschedulePolicy = rescheduleValue;
    cancellationPolicy = cancellationValue;
    lateArrivalPolicy = lateArrivalValue;
    sameDayCutoffHour = cutoffHourValue;

    await prefs.setString(_depositPolicyKey, depositPolicy);
    await prefs.setString(_reschedulePolicyKey, reschedulePolicy);
    await prefs.setString(_cancellationPolicyKey, cancellationPolicy);
    await prefs.setString(_lateArrivalPolicyKey, lateArrivalPolicy);
    await prefs.setInt(_cutoffKey, sameDayCutoffHour);
  }
}