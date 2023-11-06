import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';

class Revenue extends StatefulWidget {
  @override
  _RevenueState createState() => _RevenueState();
}

class _RevenueState extends State<Revenue> {
  // 월 목록
  List<String> months = [
    '1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'
  ];

  // 수익 데이터 (초기값은 0)
  List<double> earnings = List.generate(12, (index) => 0.0);

  // 출금 가능 수익금, 예상 수익금, 출금 완료 수익금
  double availableEarnings = 1000.0;
  double expectedEarnings = 2000.0;
  double completedWithdrawals = 500.0;

  // Firestore 인스턴스 생성
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 사용자 정보 및 데이터 리스트
  String user = "";

  @override
  void initState() {
    super.initState();

    // 사용자 정보 가져오기
    UserModel um = Provider.of<UserModel>(context, listen: false);
    if (um.isLogin) {
      user = um.userId!;
      print(user);
    } else {
      user = "없음";
      print("로그인 안됨");
    }

    // 데이터 가져오기
    fetchData();
  }

  Future<void> fetchData() async {
    // Firestore 컬렉션 초기화
    final productCollection = _firestore.collection('products');
    final orderCollection = _firestore.collection('orders');

    // 사용자와 관련된 상품 데이터 가져오기
    final productQuery = await productCollection.where('user', isEqualTo: user).get();
    final productDocs = productQuery.docs;

    // 상품 이름 리스트 생성
    final productNames = productDocs.map((doc) => doc['pName'] as String).toList();

    // 주문 데이터 가져오기
    final orderQuery = await orderCollection.where('productName', whereIn: productNames).get();
    final orderDocs = orderQuery.docs;

    // 주문 데이터 처리 및 그래프 업데이트
    updateGraphData(orderDocs);
  }

  void updateGraphData(List<QueryDocumentSnapshot> orderDocs) {
    // 그래프 데이터 초기화
    for (int i = 0; i < months.length; i++) {
      earnings[i] = 0.0;
    }

    // 주문 데이터에서 월별 수익 합산
    for (final orderDoc in orderDocs) {
      final orderInfo = json.decode(orderDoc['user']) as Map<String, dynamic>;
      final price = orderInfo['price'] as int;
      final timestamp = orderDoc['timestamp'] as Timestamp;
      final timestampDateTime = timestamp.toDate();

      // 월별 수익 업데이트
      for (int i = 0; i < months.length; i++) {
        if (timestampDateTime.month == (i + 1)) {
          earnings[i] += price.toDouble();
        }
      }
    }

    // 그래프 데이터 업데이트
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '수익관리',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24.0,
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
                  color: Colors.grey[300]!,
                  width: 1.0,
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
                          primary: Colors.amber,
                        ),
                        child: Text('출금 신청'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // 출금 취소 로직을 추가
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                        ),
                        child: Text('출금 취소'),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey[300]!,
                    thickness: 1.0,
                  ),
                  _buildStatRow("예상 수익금", expectedEarnings),
                  Divider(
                    color: Colors.grey[300]!,
                    thickness: 1.0,
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
                    color: Colors.grey[300]!,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: BarChart(
                  BarChartData(
                    titlesData: FlTitlesData(
                      leftTitles: SideTitles(
                        showTitles: true,
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
                    maxY: earnings.reduce((a, b) => a > b ? a : b), // 최대 수익값 설정
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
