import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget pop(context) {
  return GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      Navigator.pop(context);
    },
    child: Container(
        width: 45,
        height: 45,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 20,
          ),
        )),
  );
}
