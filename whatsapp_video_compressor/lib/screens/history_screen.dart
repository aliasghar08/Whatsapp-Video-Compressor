import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_provider.dart';
import '../providers/compression_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  String _formatSize(int bytes) {
    if (bytes == 0) return '0 B';
    final double mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyItems = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Compression History"),
        actions: [
          if (historyItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Clear History?"),
                    content: const Text("This will permanently delete all saved compressed videos from your device. This cannot be undone."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(historyProvider.notifier).clearHistory();
                          Navigator.pop(context);
                        },
                        child: const Text("Clear", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: historyItems.isEmpty
          ? const Center(
              child: Text(
                "No history yet.\nCompressed videos will appear here.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyItems.length,
              itemBuilder: (context, index) {
                final item = historyItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.video_library, color: Colors.white),
                    ),
                    title: Text(item.quality.replaceAll('CustomVideoQuality.', ''), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Original: ${_formatSize(item.originalSize)} ➔ Compressed: ${_formatSize(item.compressedSize)}'),
                        const SizedBox(height: 4),
                        Text(_formatDate(item.timestamp), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.share, color: Colors.green),
                      onPressed: () {
                        ref.read(compressionProvider.notifier).loadFromHistory(
                          item.path,
                          item.originalSize,
                          item.compressedSize,
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
