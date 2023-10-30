import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Revenue extends StatefulWidget {
  @override
  _RevenueState createState() => _RevenueState();
}

class _RevenueState extends State<Revenue> {
  List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  List<double> earnings = [1000, 1500, 1200, 2200, 1800, 2100, 2300, 1000, 1500, 1200, 2200, 1800];
  double availableEarnings = 1000.0;
  double expectedEarnings = 2000.0;
  double completedWithdrawals = 500.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white, // 배경색
          elevation: 0, // 그림자 효과 제거
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.black, // 좌측 아이콘 색상
            ),
            onPressed: () {
              // 좌측 아이콘을 눌렀을 때 수행할 작업
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.black, // 검색 아이콘 색상
              ),
              onPressed: () {
                // 검색 아이콘을 눌렀을 때 수행할 작업
              },
            ),
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: Colors.black, // 알림 아이콘 색상
              ),
              onPressed: () {
                // 알림 아이콘을 눌렀을 때 수행할 작업
              },
            ),
          ],
          title: Text(
            '수익관리',
            style: TextStyle(
              color: Colors.black, // 타이틀 색상
              fontSize: 24.0, // 타이틀 폰트 크기
            ),
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[300]!, // Container의 외곽 보더 색상
                  width: 1.0,              // Container의 외곽 보더 두께
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatRow("출금 가능 수익금", availableEarnings),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // 출금 신청 로직을 추가
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.amber, // 버튼 색상 설정
                        ),
                        child: Text('출금 신청'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // 출금 취소 로직을 추가
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey, // 버튼 색상 설정
                        ),
                        child: Text('출금 취소'),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey[300]!, // 구분선의 색상
                    thickness: 1.0,            // 구분선의 두께
                  ),
                  _buildStatRow("예상 수익금", expectedEarnings),
                  Divider(
                    color: Colors.grey[300]!, // 구분선의 색상
                    thickness: 1.0,            // 구분선의 두께
                  ),
                  _buildStatRow("출금 완료 수익금", completedWithdrawals),
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                height: 300,
                width: 500,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300]!, // Container의 외곽 보더 색상
                    width: 1.0,              // Container의 외곽 보더 두께
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: BarChart(
                  BarChartData(
                    titlesData: FlTitlesData(
                      leftTitles: SideTitles(
                        showTitles: true,
                        //Y축에 담을 정보 내용
                        getTextStyles: (context, value) => TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                        getTitles: (value) {
                          if (value % 500 == 0) {
                            return value.toInt().toString();
                          }
                          return '';
                        },
                      ),
                      bottomTitles: SideTitles(
                        showTitles: true,
                        getTextStyles: (context, value) => TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        getTitles: (value) {
                          int index = value.toInt();
                          if (index >= 0 && index < months.length) {
                            return months[index];
                          }
                          return '';
                        },
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    gridData: FlGridData(
                      show: false,
                    ),
                    minY: 0,
                    //추후 1~12월 거래액 중 최대값을 maxY에 넣기
                    maxY: 2500,
                    barGroups: List.generate(
                      months.length,
                          (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            y: earnings[index],
                            width: 16,
                            colors: [Colors.amber],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
