import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing notification read/unread states and deletion preferences.
class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _keyReadIds = 'harvion_notif_read_ids';
  static const String _keyDeletedIds = 'harvion_notif_deleted_ids';

  final Set<String> _readIds = {};
  final Set<String> _deletedIds = {};
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final readList = prefs.getStringList(_keyReadIds) ?? [];
      final deletedList = prefs.getStringList(_keyDeletedIds) ?? [];
      _readIds.addAll(readList);
      _deletedIds.addAll(deletedList);
      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[NotificationService] Init error: $e');
    }
  }

  bool isRead(String id) => _readIds.contains(id);

  bool isDeleted(String id) => _deletedIds.contains(id);

  /// Returns count of notifications that are neither read nor deleted
  int getUnreadCount(Iterable<String> activeIds) {
    return activeIds.where((id) => !_readIds.contains(id) && !_deletedIds.contains(id)).length;
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String id) async {
    if (_readIds.add(id)) {
      notifyListeners();
      await _persistReadIds();
    }
  }

  /// Mark all active notifications as read (e.g. when user clicks bell icon)
  Future<void> markAllAsRead(Iterable<String> activeIds) async {
    bool changed = false;
    for (final id in activeIds) {
      if (_readIds.add(id)) {
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      await _persistReadIds();
    }
  }

  /// Delete/dismiss a notification so it no longer appears in UI or badge
  Future<void> deleteNotification(String id) async {
    if (_deletedIds.add(id)) {
      _readIds.add(id);
      notifyListeners();
      await _persistDeletedIds();
      await _persistReadIds();
    }
  }

  /// Delete multiple notifications at once
  Future<void> clearAllNotifications(Iterable<String> activeIds) async {
    for (final id in activeIds) {
      _deletedIds.add(id);
      _readIds.add(id);
    }
    notifyListeners();
    await _persistDeletedIds();
    await _persistReadIds();
  }

  /// Undo delete for a notification
  Future<void> undoDelete(String id) async {
    if (_deletedIds.remove(id)) {
      notifyListeners();
      await _persistDeletedIds();
    }
  }

  Future<void> _persistReadIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyReadIds, _readIds.toList());
    } catch (e) {
      debugPrint('[NotificationService] Persist read error: $e');
    }
  }

  Future<void> _persistDeletedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyDeletedIds, _deletedIds.toList());
    } catch (e) {
      debugPrint('[NotificationService] Persist deleted error: $e');
    }
  }
}

