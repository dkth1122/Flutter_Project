import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';

class Revenue extends StatefulWidget {
  @override
  _RevenueState createState() => _RevenueState();
}

class _RevenueState extends State<Revenue> {
  List<String> months = [
    '1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'
  ];

  List<double> earnings = List.generate(12, (index) => 0.0);
  double availableEarnings = 0.0;
  double completedWithdrawals = 0.0;

  List<int> prices = [];
  List<int> prices2 = [];
  List<String> productNames = [];
  List<DateTime> timestamps = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String user = "";

  @override
  void initState() {
    super.initState();

    UserModel um = Provider.of<UserModel>(context, listen: false);
    if (um.isLogin) {
      user = um.userId!;
      print(user);
    } else {
      user = "없음";
      print("로그인 안됨");
    }

    fetchData();
  }

  Future<void> fetchData() async {
    final orderCollection = _firestore.collection('orders');
    final orderQuery = await orderCollection.where('seller', isEqualTo: user).get();
    final orderDocs = orderQuery.docs;

    for (QueryDocumentSnapshot orderDoc in orderDocs) {
      int price = orderDoc['price'] as int;
      Timestamp timestamp = orderDoc['timestamp'] as Timestamp;
      DateTime timestampDateTime = timestamp.toDate();

      prices.add(price);
      timestamps.add(timestampDateTime);
    }

    updateEarningsData();
  }

  //출금 가능 내역 따로
  Future<void> fetchPrices() async {
    final orderCollection = _firestore.collection('orders');
    final orderQuery = await orderCollection.where('seller', isEqualTo: user).where('withdraw', isNotEqualTo: 'Y').get();
    final orderDocs = orderQuery.docs;

    for (QueryDocumentSnapshot orderDoc in orderDocs) {
      int price2 = orderDoc['price'] as int;
      prices2.add(price2);
    }

    // prices2 리스트에는 'withdraw' 필드가 'Y'가 아닌 주문의 가격만 저장
    availableEarnings = prices2.reduce((a, b) => a + b).toDouble();
  }


  void updateEarningsData() {
    List<double> updatedEarnings = List.generate(12, (index) => 0.0);

    for (int i = 0; i < prices.length; i++) {
      DateTime timestamp = timestamps[i];
      int month = timestamp.month;
      updatedEarnings[month - 1] += prices[i].toDouble();
    }

    setState(() {
      earnings = updatedEarnings;
    });
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
                        child: Text('출금 신청'),
                        onPressed: () async {
                          // 출금 신청 시, seller 필드가 user와 같은 문서들을 선택
                          QuerySnapshot orderQuery = await _firestore
                              .collection('orders')
                              .where('seller', isEqualTo: user)
                              .get();

                          // 선택한 문서들을 업데이트
                          for (QueryDocumentSnapshot orderDoc in orderQuery.docs) {
                            await _firestore.collection('orders').doc(orderDoc.id).update({
                              'withdraw': 'Y',
                            });
                          }
                          // 출금 신청 시, 출금 가능 수익금을 0으로 업데이트
                          setState(() {
                            availableEarnings = 0.0;
                          });
                          // 출금 신청 시, 출금 완료 수익금을 신청한 금액만큼 업데이트
                          setState(() {
                            completedWithdrawals += availableEarnings;
                          });

                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.amber,
                        ),
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
                          fontSize: 10,
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
                    maxY: earnings.reduce((a, b) => a > b ? a : b),
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
          '${value.toInt()} 원',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
