import 'package:flutter/material.dart';

class HourlyForecast extends StatelessWidget {
  final IconData icon;
  final String value1;
  final String value2;
  const HourlyForecast({
    super.key,
    required this.icon,
    required this.value1,
    required this.value2,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value1,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Icon(
              icon,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value2,
            ),
          ],
        ),
      ),
    );
  }
}
