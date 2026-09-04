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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(premiumProvider);
    final compressionState = ref.watch(compressionProvider);

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
              Color(0xFF2A0845), // Very dark purple
              Color(0xFF6441A5), // Purple
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: compressionState.isCompressing
                  ? const GlassCard(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: LoadingView(message: "Compressing in HD..."),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (compressionState.compressedVideoPath != null) ...[
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
                                          videoUrl: compressionState.compressedVideoPath!),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                        ActionCard(
                          onTap: () => ref.read(compressionProvider.notifier).pickAndCompressVideo(),
                        ),
                      ],
                    ),
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
}
