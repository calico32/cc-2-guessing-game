import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'gamedata.dart';

LineChartData makeLineChart(GameData gameData) {
  final min = gameData.min;
  final max = gameData.max;
  final guesses = gameData.guesses;
  final targetNumber = gameData.targetNumber;

  final spots = guesses
      .asMap()
      .entries
      .map((e) => FlSpot(e.key.toDouble() + 1, e.value.toDouble()))
      .toList();

  if (spots.length == 1) spots.add(spots[0].copyWith(x: 0));

  final gradientColors = <Color>[
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  return LineChartData(
    gridData: FlGridData(
      show: true,
      drawVerticalLine: true,
      getDrawingHorizontalLine: (value) => FlLine(
        color: const Color(0xff37434d),
        strokeWidth: 1,
      ),
      getDrawingVerticalLine: (value) => FlLine(
        color: const Color(0xff37434d),
        strokeWidth: 1,
      ),
    ),
    titlesData: FlTitlesData(
      show: true,
      bottomTitles: SideTitles(
        showTitles: true,
        reservedSize: 22,
        getTextStyles: (value) => const TextStyle(
          color: Color(0xff68737d),
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      leftTitles: SideTitles(
        showTitles: true,
        getTextStyles: (value) => const TextStyle(
          color: Color(0xff67727d),
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        // reservedSize: 50,
        margin: 12,
      ),
    ),
    borderData: FlBorderData(
      show: true,
      border: Border.all(color: const Color(0xff37434d), width: 1),
    ),
    minX: spots.reduce((a, b) => a.x < b.x ? a : b).x,
    maxX: guesses.length.toDouble(),
    minY: math.max(min.toDouble() - 2, 0),
    maxY: math.max(max.toDouble(), guesses.reduce(math.max).toDouble()),
    lineBarsData: [
      LineChartBarData(
        spots: spots
            .map((spot) => FlSpot(spot.x, targetNumber.toDouble()))
            .toList(),
        isCurved: false,
        colors: [Colors.orange],
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        dashArray: [5, 10],
      ),
      LineChartBarData(
        spots: spots,
        isCurved: false,
        colors: gradientColors,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
      ),
    ],
  );
}
