import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences {
  static const String _keyDailyReminder = 'daily_reminder_enabled';
  static const String _keyDailyReminderHour = 'daily_reminder_hour';
  static const String _keyDailyReminderMinute = 'daily_reminder_minute';
  static const String _keyBudgetWarnings = 'budget_warnings_enabled';
  static const String _keyBudgetThreshold = 'budget_threshold';
  static const String _keyWeeklySummary = 'weekly_summary_enabled';
  static const String _keyWeeklySummaryDay = 'weekly_summary_day';
  static const String _keyWeeklySummaryHour = 'weekly_summary_hour';
  static const String _keyWeeklySummaryMinute = 'weekly_summary_minute';

  // Daily Reminder
  Future<bool> getDailyReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDailyReminder) ?? false;
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailyReminder, enabled);
  }

  Future<int> getDailyReminderHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDailyReminderHour) ?? 20; // Default 8 PM
  }

  Future<void> setDailyReminderHour(int hour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDailyReminderHour, hour);
  }

  Future<int> getDailyReminderMinute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDailyReminderMinute) ?? 0;
  }

  Future<void> setDailyReminderMinute(int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDailyReminderMinute, minute);
  }

  // Budget Warnings
  Future<bool> getBudgetWarningsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBudgetWarnings) ?? true; // Default enabled
  }

  Future<void> setBudgetWarningsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBudgetWarnings, enabled);
  }

  Future<int> getBudgetThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyBudgetThreshold) ?? 80; // Default 80%
  }

  Future<void> setBudgetThreshold(int threshold) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBudgetThreshold, threshold);
  }

  // Weekly Summary
  Future<bool> getWeeklySummaryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyWeeklySummary) ?? false;
  }

  Future<void> setWeeklySummaryEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyWeeklySummary, enabled);
  }

  Future<int> getWeeklySummaryDay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyWeeklySummaryDay) ?? 7; // Default Sunday
  }

  Future<void> setWeeklySummaryDay(int day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWeeklySummaryDay, day);
  }

  Future<int> getWeeklySummaryHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyWeeklySummaryHour) ?? 10; // Default 10 AM
  }

  Future<void> setWeeklySummaryHour(int hour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWeeklySummaryHour, hour);
  }

  Future<int> getWeeklySummaryMinute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyWeeklySummaryMinute) ?? 0;
  }

  Future<void> setWeeklySummaryMinute(int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWeeklySummaryMinute, minute);
  }
}
