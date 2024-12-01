import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/card_model.dart';

class GlassCard extends StatelessWidget {
  final CardModel card;

  const GlassCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: 150, // Adjust width as needed
          decoration: BoxDecoration(
            color: card.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(width: 1.5, color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(card.icon, size: 40, color: card.color),
              Text(card.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(card.number),
            ],
          ),
        ),
      ),
    );
  }
}
