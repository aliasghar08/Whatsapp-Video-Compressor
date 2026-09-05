import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/premium_provider.dart';
import '../../providers/compression_provider.dart';
import '../widgets/native_video_player.dart';
import '../widgets/loading_view.dart';
import '../widgets/app_drawer.dart';
import '../widgets/glass_card.dart';
import '../widgets/action_card.dart';
import 'ai_support_screen.dart';
import 'package:video_compress/video_compress.dart';
import 'dart:math';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String formatBytes(int? bytes) {
    if (bytes == null || bytes <= 0) return "Unknown size";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(premiumProvider);
    final compressionState = ref.watch(compressionProvider);

    ref.listen<CompressionState>(compressionProvider, (previous, next) {
      if (next.snackbarMessage != null && next.snackbarMessage != previous?.snackbarMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.snackbarMessage!),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Future.microtask(() => ref.read(compressionProvider.notifier).clearSnackbar());
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          'PureStatus',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!isPremium)
            IconButton(
              icon: const Icon(Icons.workspace_premium, color: Colors.amber),
              onPressed: () => ref.read(premiumProvider.notifier).purchasePremium(),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A0845),
              Color(0xFF6441A5),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: compressionState.isCompressing || compressionState.isSplitting
                  ? GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: LoadingView(
                          message: compressionState.isSplitting 
                            ? "Splitting video..." 
                            : "Compressing in HD... ${compressionState.progress.toStringAsFixed(1)}%"),
                      ),
                    )
                  : _buildMainContent(context, ref, compressionState),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AiSupportScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('AI Assistant', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, WidgetRef ref, CompressionState state) {
    if (state.compressedVideoPath != null) {
      return _buildResultState(context, ref, state);
    } else if (state.selectedVideoPath != null && !state.isSplitting && state.splitVideoPaths.isEmpty) {
      return _buildAnalysisState(context, ref, state);
    } else {
      return _buildInitialState(context, ref, state);
    }
  }

  Widget _buildResultState(BuildContext context, WidgetRef ref, CompressionState state) {
    return Column(
      children: [
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Ready for WhatsApp!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: NativeVideoPlayer(
                        videoUrl: state.compressedVideoPath!),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text('Original', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text(formatBytes(state.originalVideoSize), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Icon(Icons.arrow_forward, color: Colors.white54),
                      Column(
                        children: [
                          const Text('Compressed', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text(formatBytes(state.compressedVideoSize), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => ref.read(compressionProvider.notifier).clearAnalysis(),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Compress Another Video"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisState(BuildContext context, WidgetRef ref, CompressionState state) {
    return Column(
      children: [
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Video Analysis',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => ref.read(compressionProvider.notifier).clearAnalysis(),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text("Original Size: ${formatBytes(state.originalVideoSize)}", style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                const Text("Select Compression Quality:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildQualityOption(ref, state, VideoQuality.HighestQuality, "Highest Quality", "~10% smaller", Icons.hd),
                _buildQualityOption(ref, state, VideoQuality.DefaultQuality, "Default Quality", "~30% smaller", Icons.balance),
                _buildQualityOption(ref, state, VideoQuality.MediumQuality, "Medium Quality", "~50% smaller", Icons.sd),
                _buildQualityOption(ref, state, VideoQuality.LowQuality, "Low Quality", "~80% smaller", Icons.compress),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => ref.read(compressionProvider.notifier).startCompression(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Compress Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQualityOption(WidgetRef ref, CompressionState state, VideoQuality quality, String title, String estimate, IconData icon) {
    final isSelected = state.selectedQuality == quality;
    return GestureDetector(
      onTap: () => ref.read(compressionProvider.notifier).setQuality(quality),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.white : Colors.white24, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
                  Text("Estimated reduction: $estimate", style: TextStyle(color: isSelected ? Colors.greenAccent : Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.greenAccent)
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context, WidgetRef ref, CompressionState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state.splitVideoPaths.isNotEmpty) ...[
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Split into ${state.splitVideoPaths.length} parts!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.splitVideoPaths.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 150,
                          margin: const EdgeInsets.only(right: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: NativeVideoPlayer(
                                videoUrl: state.splitVideoPaths[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
        ActionCard(
          title: 'Compress Video',
          subtitle: 'Reduce size while keeping quality',
          icon: Icons.compress,
          onTap: () => ref.read(compressionProvider.notifier).pickAndAnalyzeVideo(),
        ),
        const SizedBox(height: 24),
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Splitting Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<int>(
                  value: state.splitDuration,
                  dropdownColor: const Color(0xFF6441A5),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  isExpanded: true,
                  underline: Container(
                    height: 1,
                    color: Colors.white54,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 15,
                      child: Text('15 Seconds (Instagram Stories)'),
                    ),
                    DropdownMenuItem(
                      value: 30,
                      child: Text('30 Seconds (WhatsApp Status)'),
                    ),
                    DropdownMenuItem(
                      value: 60,
                      child: Text('60 Seconds (YouTube Shorts)'),
                    ),
                  ],
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      ref.read(compressionProvider.notifier).setSplitDuration(newValue);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ActionCard(
          title: 'Split Video',
          subtitle: 'Cut into perfectly sized parts',
          icon: Icons.cut_rounded,
          onTap: () => ref.read(compressionProvider.notifier).pickAndSplitVideo(),
        ),
      ],
    );
  }
}
