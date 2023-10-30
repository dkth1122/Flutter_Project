import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Revenue extends StatefulWidget {
  @override
  _RevenueState createState() => _RevenueState();
}

class _RevenueState extends State<Revenue> {
  List<String> dates = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
  List<double> earnings = [1000, 1500, 1200, 2200, 1800, 2100, 2300];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('수익 관리'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('수익 그래프'),
            Container(
              height: 300,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTitles: (value) {
                        double minEarnings = 1000;
                        double maxEarnings = 2500;
                        for (var i = minEarnings; i <= maxEarnings; i += 500) {
                          if (value == i) {
                            return i.toStringAsFixed(0);
                          }
                        }
                        return '';
                      },
                    ),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: (value) {
                        if (value.toInt() >= 0 && value.toInt() < dates.length) {
                          return dates[value.toInt()];
                        }
                        return '';
                      },
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minY: 1000,
                  maxY: 2500,
                  barGroups: dates
                      .asMap()
                      .entries
                      .map(
                        (entry) => BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          y: earnings[entry.key],
                          width: 16,
                          colors: [Colors.amber],
                        ),
                      ],
                    ),
                  )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
