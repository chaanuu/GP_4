// lib/widgets/qr_card.dart

import 'package:flutter/material.dart';

class QrCard extends StatelessWidget {
  final VoidCallback onTap;
  const QrCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: Container(
          height: 120,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QR\n이미지',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Icon(Icons.qr_code_scanner, size: 60, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}