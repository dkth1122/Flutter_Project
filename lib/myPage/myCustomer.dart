import 'package:flutter/material.dart';
import 'package:project_flutter/myPage/purchaseManagement.dart';

class MyCustomer extends StatelessWidget {
  const MyCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                "내 프로젝트",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                child: Column(
                  children: [
                    Text("요구사항을 작성하시고, 딱 맞는 전문가와의 거래를 진행하세요"),
                    ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.white),
                        side: MaterialStateProperty.all(
                          BorderSide(
                            color: Color(0xff424242),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Text(
                        "프로젝트 의뢰하기",
                        style: TextStyle(color: Color(0xff424242)),
                      ),
                    ),
                  ],
                ),
                margin: EdgeInsets.all(20.0),
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.grey,
          thickness: 5.0,
        ),
        ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ListTile(
              leading: Icon(Icons.shopping_bag_outlined),
              title: Text('구매관리'),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PurchaseManagementPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.credit_card),
              title: Text('결제/환불내역'),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                // 두 번째 아이템이 클릭됐을 때 수행할 작업
              },
            ),
            ListTile(
              leading: Icon(Icons.question_mark),
              title: Text('고객센터'),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                // 세 번째 아이템이 클릭됐을 때 수행할 작업
              },
            ),
            ListTile(
              leading: Icon(Icons.star),
              title: Text('네 번째 아이템'),
              subtitle: Text('네 번째 아이템 설명'),
              onTap: () {
                // 네 번째 아이템이 클릭됐을 때 수행할 작업
              },
            ),
          ],
        ),

      ],
    );
  }
}
