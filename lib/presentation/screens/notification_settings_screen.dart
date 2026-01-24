import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/notification_preferences.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final NotificationPreferences _prefs = NotificationPreferences();

  bool _dailyReminderEnabled = false;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 20, minute: 0);
  
  bool _budgetWarningsEnabled = true;
  int _budgetThreshold = 80;
  
  bool _weeklySummaryEnabled = false;
  int _weeklyDay = 7; // Sunday
  TimeOfDay _weeklyTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final dailyEnabled = await _prefs.getDailyReminderEnabled();
    final dailyHour = await _prefs.getDailyReminderHour();
    final dailyMinute = await _prefs.getDailyReminderMinute();
    
    final budgetEnabled = await _prefs.getBudgetWarningsEnabled();
    final threshold = await _prefs.getBudgetThreshold();
    
    final weeklyEnabled = await _prefs.getWeeklySummaryEnabled();
    final weeklyDay = await _prefs.getWeeklySummaryDay();
    final weeklyHour = await _prefs.getWeeklySummaryHour();
    final weeklyMinute = await _prefs.getWeeklySummaryMinute();

    setState(() {
      _dailyReminderEnabled = dailyEnabled;
      _dailyReminderTime = TimeOfDay(hour: dailyHour, minute: dailyMinute);
      _budgetWarningsEnabled = budgetEnabled;
      _budgetThreshold = threshold;
      _weeklySummaryEnabled = weeklyEnabled;
      _weeklyDay = weeklyDay;
      _weeklyTime = TimeOfDay(hour: weeklyHour, minute: weeklyMinute);
    });
  }

  Future<void> _toggleDailyReminder(bool value) async {
    setState(() => _dailyReminderEnabled = value);
    await _prefs.setDailyReminderEnabled(value);
    
    if (value) {
      await _notificationService.scheduleDailyReminder(
        hour: _dailyReminderTime.hour,
        minute: _dailyReminderTime.minute,
      );
    } else {
      await _notificationService.cancelNotification(0);
    }
  }

  Future<void> _selectDailyTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _dailyReminderTime,
    );
    
    if (time != null) {
      setState(() => _dailyReminderTime = time);
      await _prefs.setDailyReminderHour(time.hour);
      await _prefs.setDailyReminderMinute(time.minute);
      
      if (_dailyReminderEnabled) {
        await _notificationService.scheduleDailyReminder(
          hour: time.hour,
          minute: time.minute,
        );
      }
    }
  }

  Future<void> _toggleBudgetWarnings(bool value) async {
    setState(() => _budgetWarningsEnabled = value);
    await _prefs.setBudgetWarningsEnabled(value);
  }

  Future<void> _updateBudgetThreshold(int value) async {
    setState(() => _budgetThreshold = value);
    await _prefs.setBudgetThreshold(value);
  }

  Future<void> _toggleWeeklySummary(bool value) async {
    setState(() => _weeklySummaryEnabled = value);
    await _prefs.setWeeklySummaryEnabled(value);
    
    if (value) {
      await _notificationService.scheduleWeeklySummary(
        dayOfWeek: _weeklyDay,
        hour: _weeklyTime.hour,
        minute: _weeklyTime.minute,
      );
    } else {
      await _notificationService.cancelNotification(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Daily Reminder Section
          _buildSectionHeader('Daily Reminder', Icons.alarm),
          const SizedBox(height: 12),
          _buildCard(
            child: Column(
              children: [
                SwitchListTile(
                  value: _dailyReminderEnabled,
                  onChanged: _toggleDailyReminder,
                  title: const Text('Enable Daily Reminder'),
                  subtitle: const Text('Get reminded to track your expenses'),
                  activeColor: context.theme.colorScheme.primary,
                ),
                if (_dailyReminderEnabled) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Reminder Time'),
                    subtitle: Text(_dailyReminderTime.format(context)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _selectDailyTime,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Budget Warnings Section
          _buildSectionHeader('Budget Warnings', Icons.warning_amber),
          const SizedBox(height: 12),
          _buildCard(
            child: Column(
              children: [
                SwitchListTile(
                  value: _budgetWarningsEnabled,
                  onChanged: _toggleBudgetWarnings,
                  title: const Text('Enable Budget Warnings'),
                  subtitle: const Text('Get notified when approaching budget limits'),
                  activeColor: context.theme.colorScheme.primary,
                ),
                if (_budgetWarningsEnabled) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Warning Threshold', style: context.textTheme.bodyLarge),
                            Text('$_budgetThreshold%', style: context.textTheme.titleMedium?.copyWith(
                              color: context.theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _budgetThreshold.toDouble(),
                          min: 50,
                          max: 100,
                          divisions: 10,
                          label: '$_budgetThreshold%',
                          onChanged: (value) => _updateBudgetThreshold(value.toInt()),
                        ),
                        Text(
                          'You\'ll be notified when you reach $_budgetThreshold% of your category budget',
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Weekly Summary Section
          _buildSectionHeader('Weekly Summary', Icons.summarize),
          const SizedBox(height: 12),
          _buildCard(
            child: Column(
              children: [
                SwitchListTile(
                  value: _weeklySummaryEnabled,
                  onChanged: _toggleWeeklySummary,
                  title: const Text('Enable Weekly Summary'),
                  subtitle: const Text('Get a weekly overview of your spending'),
                  activeColor: context.theme.colorScheme.primary,
                ),
                if (_weeklySummaryEnabled) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Summary Day'),
                    subtitle: Text(_getWeekdayName(_weeklyDay)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _selectWeeklyDay(),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Test Notification Button
          ElevatedButton.icon(
            onPressed: () async {
              await _notificationService.showNotification(
                id: 999,
                title: 'Test Notification',
                body: 'This is how your notifications will look! 🎉',
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test notification sent!')),
                );
              }
            },
            icon: const Icon(Icons.notifications_active),
            label: const Text('Send Test Notification'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: context.theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [context.tokens.cardShadow],
      ),
      child: child,
    );
  }

  String _getWeekdayName(int day) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[day - 1];
  }

  Future<void> _selectWeeklyDay() async {
    final selected = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(7, (index) {
            final day = index + 1;
            return ListTile(
              title: Text(_getWeekdayName(day)),
              selected: _weeklyDay == day,
              onTap: () => Navigator.pop(ctx, day),
            );
          }),
        ),
      ),
    );

    if (selected != null) {
      setState(() => _weeklyDay = selected);
      await _prefs.setWeeklySummaryDay(selected);
      
      if (_weeklySummaryEnabled) {
        await _notificationService.scheduleWeeklySummary(
          dayOfWeek: selected,
          hour: _weeklyTime.hour,
          minute: _weeklyTime.minute,
        );
      }
    }
  }
}
