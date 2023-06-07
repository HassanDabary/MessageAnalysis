import 'dart:math';

import 'package:flutter/material.dart';
///This is a code written by Hassan Dabary for ABGA Company screening assessment assignment
///contact me at: dabary@proton.me

//This is the main painter class
class MyPieChartPainter extends CustomPainter {
  final Map<String, double> values;
  MyPieChartPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    var startRadian = -pi / 2;
    final total = values.values.reduce((a, b) => a + b);

    for (var entry in values.entries) {
      final sweep = 2 * pi * (entry.value / total);
      final paint = Paint()..color = _getColorForIndex(entry.key);
      canvas.drawArc(Rect.fromLTRB(0, 0, size.width, size.height), startRadian, sweep, true, paint);
      startRadian += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  Color _getColorForIndex(String sender) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];

    final index = sender.hashCode % colors.length;
    return colors[index];
  }
}

//This class handles the creation of pie chart layout
class MyPieChart extends StatelessWidget {
  final Map<String, double> values;

  MyPieChart({required this.values});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // square size
      child: CustomPaint(
        painter: MyPieChartPainter(values: values),
      ),
    );
  }
}

//This class handles the coloring of the different parts of the pie chart
class PieChartLegend extends StatelessWidget {
  final Map<String, double> values;

  PieChartLegend({required this.values});

  Color _getColorForIndex(String sender) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      // Add more colors if needed
    ];

    final index = sender.hashCode % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: values.length * 24.0,  // Adjust this value as per your need
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: values.keys.map((sender) {
          return Row(
            children: [
              Icon(Icons.circle, color: _getColorForIndex(sender), size: 20),
              SizedBox(width: 8),
              Text(sender),
            ],
          );
        }).toList(),
      ),
    );
  }
}

//This class handles the painting process of the pie chart parts
class PieChartPainter extends CustomPainter {
  final List<double> values;

  PieChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..style = PaintingStyle.fill;
    var total = values.fold(0.0, (a, b) => a + b);
    var startRadian = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = 2 * pi * (values[i] / total);
      paint.color = Colors.primaries[i % Colors.primaries.length];
      canvas.drawArc(Offset.zero & size, startRadian, sweep, true, paint);
      startRadian += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

//This class handles the interaction with the label in chart titles
class ChartLabel extends StatelessWidget {
  final String label;
  final Color color;

  const ChartLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}


