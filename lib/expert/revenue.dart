import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';
import '../subBottomBar.dart';

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
  List<int> prices3 = [];
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
    fetchPrices();
    fetchcompletedWithdraw();
  }

  //전체 수익
  Future<void> fetchData() async {
    prices = [];
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
    final orderQuery = await orderCollection.where('seller', isEqualTo: user).get();
    final orderDocs = orderQuery.docs;

    prices2 = []; // 기존 prices2를 초기화

    for (QueryDocumentSnapshot orderDoc in orderDocs) {
      String withdrawStatus = orderDoc['withdraw'] as String;
      if (withdrawStatus == 'N') {
        int price2 = orderDoc['price'] as int;
        prices2.add(price2);
      }
    }

    if (prices2.isNotEmpty) {
      availableEarnings = prices2.reduce((a, b) => a + b).toDouble();
    } else {
      availableEarnings = 0.0; // 빈 리스트일 경우 0으로 설정
    }
  }



  //츨금 완료 내역
  Future<void> fetchcompletedWithdraw() async {
    prices3.clear();
    final orderCollection = _firestore.collection('orders');
    final orderQuery = await orderCollection.where('seller', isEqualTo: user).where('withdraw', isEqualTo: 'Y').get();
    final orderDocs = orderQuery.docs;

    for (QueryDocumentSnapshot orderDoc in orderDocs) {
      int price3 = orderDoc['price'] as int;
      prices3.add(price3);
    }

    // prices3 리스트에는 'withdraw' 필드가 'Y'인 주문의 가격만 저장
    double totalWithdrawals = prices3.fold(0.0, (previous, current) => previous + current);

    setState(() {
      completedWithdrawals = totalWithdrawals;
    });
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
        backgroundColor: Colors.white10,
        elevation: 0,
        title: Text(
          '수익 관리',
          style: TextStyle(
            color: Color(0xff424242),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color(0xff424242),
          onPressed: () {
            Navigator.pop(context);
          },
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
                        child: Text('출금 신청',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                        onPressed: () async {
                          if (availableEarnings == 0.0) {
                            // 출금 가능 수익이 0인 경우 스낵바 표시
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('출금 가능한 수익이 없습니다.'),
                                duration: Duration(seconds: 3), // 스낵바 표시 시간
                              ),
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('출금 신청 확인',style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff424242)),),
                                  content: Text('출금을 신청하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 다이얼로그 닫기
                                      },
                                      child: Text('취소',style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff424242)),),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        // 출금 신청 로직 추가
                                        QuerySnapshot orderQuery = await _firestore
                                            .collection('orders')
                                            .where('seller', isEqualTo: user)
                                            .get();

                                        for (QueryDocumentSnapshot orderDoc in orderQuery.docs) {
                                          await _firestore.collection('orders').doc(orderDoc.id).update({
                                            'withdraw': 'Y',
                                          });
                                        }

                                        // 스낵바 표시
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('출금 신청이 완료되었습니다.', style: TextStyle(fontWeight: FontWeight.bold)),
                                            duration: Duration(seconds: 3), // 스낵바 표시 시간
                                          ),
                                        );

                                        //다이어로그 닫기
                                        Navigator.of(context).pop();

                                        //새로고침
                                        await fetchData();
                                        await fetchPrices();
                                        await fetchcompletedWithdraw();
                                      },
                                      child: Text('출금 신청',style: TextStyle(fontWeight: FontWeight.bold),),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFFFF8C42)
                          ,
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          if (completedWithdrawals == 0.0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('출금 취소 가능한 금액이 없습니다.',style: TextStyle(fontWeight: FontWeight.bold),),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('출금 취소 확인',style: TextStyle(fontWeight: FontWeight.bold),),
                                  content: Text('출금을 취소하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 다이얼로그 닫기
                                      },
                                      child: Text('취소',style: TextStyle(fontWeight: FontWeight.bold),),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        // 출금 취소 로직 추가
                                        QuerySnapshot orderQuery = await _firestore
                                            .collection('orders')
                                            .where('seller', isEqualTo: user)
                                            .where('withdraw', isEqualTo: 'Y')
                                            .get();

                                        for (QueryDocumentSnapshot orderDoc in orderQuery.docs) {
                                          await _firestore.collection('orders').doc(orderDoc.id).update({
                                            'withdraw': 'N',
                                          });
                                        }

                                        // 스낵바 표시
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('출금 취소 신청이 완료되었습니다.', style: TextStyle(fontWeight: FontWeight.bold)),
                                            duration: Duration(seconds: 3), // 스낵바 표시 시간
                                          ),
                                        );

                                        // 다이얼로그 닫기
                                        Navigator.of(context).pop();


                                        //새로고침
                                        await fetchData();
                                        await fetchPrices();
                                        await fetchcompletedWithdraw();
                                      },
                                      child: Text('출금 취소',style: TextStyle(fontWeight: FontWeight.bold),),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                        ),
                        child: Text('출금 취소', style: TextStyle(fontWeight: FontWeight.bold),),
                      )
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
                          color: Color(0xff424242),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                        getTitles: (value) {
                          if (value % 500 == 0) {
                            // 만원 단위로 변환
                            if(value > 9999){
                              int valueInThousands = (value ~/ 10000);
                              return '$valueInThousands 만';
                            }else{
                              //천단위로 콤마
                              final formatter = NumberFormat.decimalPattern('en_KR');
                              return formatter.format(value.toInt());
                            }
                          }
                          return '';
                        },
                        reservedSize: 30,
                      ),
                      rightTitles: SideTitles(showTitles: false),
                      topTitles: SideTitles(showTitles: false),
                      bottomTitles: SideTitles(
                        showTitles: true,
                        getTextStyles: (context, value) => TextStyle(
                          color: Color(0xff424242),
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
                            colors: [Color(0xFFFF8C42)],
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
      bottomNavigationBar: SubBottomBar(),
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
            color: Color(0xff424242),
          ),
        ),
        Text(
          '${value.toInt()} 원',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xff424242),
          ),
        ),
      ],
    );
  }
}
