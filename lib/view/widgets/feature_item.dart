
import 'package:flutter/material.dart';
import 'package:godly_seed_app/view/subscription/model/subscription.dart';

class FeatureItem extends StatelessWidget {
  final Feature feature;

  const FeatureItem({Key? key, required this.feature}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: feature.icon == Icons.movie 
                  ? const Color(0xFFFFF3E0)
                  : feature.icon == Icons.download
                      ? const Color(0xFFE3F2FD)
                      : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              feature.icon,
              color: feature.icon == Icons.movie 
                  ? const Color(0xFFFF8C00)
                  : feature.icon == Icons.download
                      ? const Color(0xFF2196F3)
                      : const Color(0xFFF44336),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}