import 'package:flutter/material.dart';
import 'glass_card.dart';

class ActionCard extends StatelessWidget {
  final VoidCallback onTap;

  const ActionCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: const Column(
            children: [
              Icon(
                Icons.video_library_rounded,
                size: 64,
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                'Select Video',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Compress without losing quality',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
