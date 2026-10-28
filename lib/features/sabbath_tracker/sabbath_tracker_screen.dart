import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SabbathTrackerScreen extends StatefulWidget {
  const SabbathTrackerScreen({super.key});

  @override
  State<SabbathTrackerScreen> createState() => _SabbathTrackerScreenState();
}

class _SabbathTrackerScreenState extends State<SabbathTrackerScreen> {
  late Timer _timer;
  late DateTime _now;

  // Notification preferences state
  bool _notifySunset = true;
  bool _notifyDailyVerse = true;
  bool _notifyBookArrivals = true;
  bool _notifyShippingUpdates = true;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Calculate Friday sunset at 6:30 PM local time
  DateTime _getNextSunset() {
    DateTime candidate = DateTime(_now.year, _now.month, _now.day, 18, 30);
    // Find next Friday (weekday 5) or Saturday (weekday 6)
    if (_now.weekday == DateTime.friday && _now.isBefore(candidate)) {
      return candidate;
    } else if (_now.weekday == DateTime.saturday && _now.isBefore(candidate)) {
      return candidate; // Sunset ending Sabbath
    } else {
      int daysUntilFriday = (DateTime.friday - _now.weekday) % 7;
      if (daysUntilFriday == 0 && _now.isAfter(candidate)) {
        daysUntilFriday = 7;
      }
      return DateTime(_now.year, _now.month, _now.day + daysUntilFriday, 18, 30);
    }
  }

  bool _isCurrentlySabbath() {
    if (_now.weekday == DateTime.friday && _now.hour >= 18 && _now.minute >= 30) {
      return true;
    }
    if (_now.weekday == DateTime.saturday && (_now.hour < 18 || (_now.hour == 18 && _now.minute < 30))) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final nextSunset = _getNextSunset();
    final difference = nextSunset.difference(_now);
    final isSabbath = _isCurrentlySabbath();

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Sabbath Tracker & Sunset Reminders', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Sunset Countdown Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSabbath
                      ? [AppTheme.primaryGreen, const Color(0xFF1B5E20)]
                      : [AppTheme.primaryBlue, const Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isSabbath ? AppTheme.primaryGreen : AppTheme.primaryBlue).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    isSabbath ? Icons.spa : Icons.wb_twilight,
                    color: AppTheme.sacredGold,
                    size: 56,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isSabbath ? 'HAPPY SABBATH!' : 'SABBATH COUNTDOWN',
                    style: const TextStyle(
                      color: AppTheme.sacredGold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSabbath
                      ? 'The holy Sabbath of the Lord has arrived. Rest, worship, and fellowship in His sacred presence.'
                      : 'Preparation for the Holy Seventh-Day Sabbath',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Timer clock
                  if (!isSabbath)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTimeBlock('$hours', 'HOURS'),
                        const SizedBox(width: 12),
                        _buildTimeBlock('$minutes', 'MINS'),
                        const SizedBox(width: 12),
                        _buildTimeBlock('$seconds', 'SECS'),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Isaiah 58:13-14 • Call the Sabbath a Delight',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Next Sunset: Friday 6:30 PM (Nairobi / East Africa Time)',
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Scripture Reflection
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.sacredGold.withOpacity(0.5)),
              ),
              color: const Color(0xFFFFF8E7),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      '"And on the seventh day God ended his work which he had made; and he rested on the seventh day from all his work which he had made. And God blessed the seventh day, and sanctified it."',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, height: 1.5),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Genesis 2:2-3',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryBlue),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Push Notification Preferences
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notification & Alert Preferences',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Friday Sunset Alert', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Receive a peaceful reminder 1 hour before sunset to prepare for Sabbath.'),
                    value: _notifySunset,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (val) {
                      setState(() => _notifySunset = val);
                      _showPrefSnack('Sunset alerts');
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Daily Morning Watch Verses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Inspiring morning Scripture text and Ellen White quote at 6:00 AM.'),
                    value: _notifyDailyVerse,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (val) {
                      setState(() => _notifyDailyVerse = val);
                      _showPrefSnack('Morning verses');
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('New Book & Material Arrivals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Alerts when new Spirit of Prophecy, health, and missionary books arrive in store.'),
                    value: _notifyBookArrivals,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (val) {
                      setState(() => _notifyBookArrivals = val);
                      _showPrefSnack('Book announcements');
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Book Order & Shipping Updates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Real-time updates when your book order is packed, dispatched, and en route.'),
                    value: _notifyShippingUpdates,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (val) {
                      setState(() => _notifyShippingUpdates = val);
                      _showPrefSnack('Shipping updates');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showPrefSnack(String item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$item preference updated.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildTimeBlock(String value, String label) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value.padLeft(2, '0'),
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
