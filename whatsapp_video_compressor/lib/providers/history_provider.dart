import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class HistoryItem {
  final int originalSize;
  final int compressedSize;
  final String path;
  final String quality;
  final int timestamp;

  HistoryItem({
    required this.originalSize,
    required this.compressedSize,
    required this.path,
    required this.quality,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'originalSize': originalSize,
      'compressedSize': compressedSize,
      'path': path,
      'quality': quality,
      'timestamp': timestamp,
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      originalSize: map['originalSize'] ?? 0,
      compressedSize: map['compressedSize'] ?? 0,
      path: map['path'] ?? '',
      quality: map['quality'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<HistoryItem>>(() {
  return HistoryNotifier();
});

class HistoryNotifier extends Notifier<List<HistoryItem>> {
  static const _historyKey = 'video_history';
  SharedPreferences? _prefs;

  @override
  List<HistoryItem> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadHistory();
  }

  void _loadHistory() {
    if (_prefs == null) return;
    
    final String? historyJson = _prefs!.getString(_historyKey);
    if (historyJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(historyJson);
        final List<HistoryItem> items = decoded.map((e) => HistoryItem.fromMap(e)).toList();
        
        // Filter out items where the file no longer exists
        final existingItems = items.where((item) => File(item.path).existsSync()).toList();
        
        // Sort by newest first
        existingItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        state = existingItems;
        _saveHistory(existingItems); // Save filtered list
      } catch (e) {
        state = [];
      }
    }
  }

  void _saveHistory(List<HistoryItem> items) {
    if (_prefs == null) return;
    final List<Map<String, dynamic>> mappedList = items.map((e) => e.toMap()).toList();
    _prefs!.setString(_historyKey, jsonEncode(mappedList));
  }

  void addHistoryItem({
    required int originalSize,
    required int compressedSize,
    required String path,
    required String quality,
  }) {
    final newItem = HistoryItem(
      originalSize: originalSize,
      compressedSize: compressedSize,
      path: path,
      quality: quality,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    
    final updatedList = [newItem, ...state];
    state = updatedList;
    _saveHistory(updatedList);
  }

  void clearHistory() {
    // Delete actual files
    for (var item in state) {
      try {
        final file = File(item.path);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {}
    }
    
    state = [];
    _saveHistory([]);
  }
}
