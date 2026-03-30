import 'package:shared_preferences/shared_preferences.dart';

class BusinessStore {
  static String owner = 'Glow Nail Studio Owner';
  static String phone = '(312) 555-0148';
  static String email = 'hello@glownailstudio.com';
  static String location = 'Chicago, IL';
  static String about =
      'Glow Nail Studio offers relaxing, modern nail care with a clean and elevated salon experience.';

  static String mondayHours = 'Closed';
  static String tuesdayHours = '9:00 AM - 6:00 PM';
  static String wednesdayHours = '9:00 AM - 6:00 PM';
  static String thursdayHours = '9:00 AM - 6:00 PM';
  static String fridayHours = '9:00 AM - 6:00 PM';
  static String saturdayHours = '10:00 AM - 4:00 PM';
  static String sundayHours = 'Closed';

  static String depositPolicy =
      'A deposit is required to confirm every booking.';
  static String reschedulePolicy =
      'Appointments may be rescheduled in advance based on availability.';
  static String cancellationPolicy =
      'Cancellations may result in deposit forfeiture.';
  static String latePolicy =
      'Clients arriving late may need to shorten or reschedule the appointment.';

  static const String _ownerKey = 'business_owner';
  static const String _phoneKey = 'business_phone';
  static const String _emailKey = 'business_email';
  static const String _locationKey = 'business_location';
  static const String _aboutKey = 'business_about';

  static const String _mondayHoursKey = 'business_monday_hours';
  static const String _tuesdayHoursKey = 'business_tuesday_hours';
  static const String _wednesdayHoursKey = 'business_wednesday_hours';
  static const String _thursdayHoursKey = 'business_thursday_hours';
  static const String _fridayHoursKey = 'business_friday_hours';
  static const String _saturdayHoursKey = 'business_saturday_hours';
  static const String _sundayHoursKey = 'business_sunday_hours';

  static const String _depositPolicyKey = 'business_deposit_policy';
  static const String _reschedulePolicyKey = 'business_reschedule_policy';
  static const String _cancellationPolicyKey = 'business_cancellation_policy';
  static const String _latePolicyKey = 'business_late_policy';

  static Future<void> loadBusinessProfile() async {
    final prefs = await SharedPreferences.getInstance();

    owner = prefs.getString(_ownerKey) ?? owner;
    phone = prefs.getString(_phoneKey) ?? phone;
    email = prefs.getString(_emailKey) ?? email;
    location = prefs.getString(_locationKey) ?? location;
    about = prefs.getString(_aboutKey) ?? about;

    mondayHours = prefs.getString(_mondayHoursKey) ?? mondayHours;
    tuesdayHours = prefs.getString(_tuesdayHoursKey) ?? tuesdayHours;
    wednesdayHours = prefs.getString(_wednesdayHoursKey) ?? wednesdayHours;
    thursdayHours = prefs.getString(_thursdayHoursKey) ?? thursdayHours;
    fridayHours = prefs.getString(_fridayHoursKey) ?? fridayHours;
    saturdayHours = prefs.getString(_saturdayHoursKey) ?? saturdayHours;
    sundayHours = prefs.getString(_sundayHoursKey) ?? sundayHours;

    depositPolicy = prefs.getString(_depositPolicyKey) ?? depositPolicy;
    reschedulePolicy =
        prefs.getString(_reschedulePolicyKey) ?? reschedulePolicy;
    cancellationPolicy =
        prefs.getString(_cancellationPolicyKey) ?? cancellationPolicy;
    latePolicy = prefs.getString(_latePolicyKey) ?? latePolicy;
  }

  static Future<void> saveBusinessProfile({
    required String ownerName,
    required String phoneNumber,
    required String emailAddress,
    required String businessLocation,
    required String aboutText,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    owner = ownerName;
    phone = phoneNumber;
    email = emailAddress;
    location = businessLocation;
    about = aboutText;

    await prefs.setString(_ownerKey, owner);
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_locationKey, location);
    await prefs.setString(_aboutKey, about);
  }

  static Future<void> saveBusinessHours({
    required String monday,
    required String tuesday,
    required String wednesday,
    required String thursday,
    required String friday,
    required String saturday,
    required String sunday,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    mondayHours = monday;
    tuesdayHours = tuesday;
    wednesdayHours = wednesday;
    thursdayHours = thursday;
    fridayHours = friday;
    saturdayHours = saturday;
    sundayHours = sunday;

    await prefs.setString(_mondayHoursKey, mondayHours);
    await prefs.setString(_tuesdayHoursKey, tuesdayHours);
    await prefs.setString(_wednesdayHoursKey, wednesdayHours);
    await prefs.setString(_thursdayHoursKey, thursdayHours);
    await prefs.setString(_fridayHoursKey, fridayHours);
    await prefs.setString(_saturdayHoursKey, saturdayHours);
    await prefs.setString(_sundayHoursKey, sundayHours);
  }

  static Future<void> savePolicies({
    required String deposit,
    required String reschedule,
    required String cancellation,
    required String late,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    depositPolicy = deposit;
    reschedulePolicy = reschedule;
    cancellationPolicy = cancellation;
    latePolicy = late;

    await prefs.setString(_depositPolicyKey, depositPolicy);
    await prefs.setString(_reschedulePolicyKey, reschedulePolicy);
    await prefs.setString(_cancellationPolicyKey, cancellationPolicy);
    await prefs.setString(_latePolicyKey, latePolicy);
  }
}