import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_flutter/subBottomBar.dart';
import 'package:provider/provider.dart';
import '../join/userModel.dart';

class MyCoupon extends StatefulWidget {
  const MyCoupon({Key? key}) : super(key: key);

  @override
  _MyCouponState createState() => _MyCouponState();
}

class _MyCouponState extends State<MyCoupon> {
  Widget _listCoupon() {
    UserModel userModel = Provider.of<UserModel>(context, listen: false);
    final userId = userModel.userId;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("coupon")
          .where("user", isEqualTo: userId)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snap.data!.docs[index];
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            return Card(
              margin: EdgeInsets.all(8.0),
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1.0,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 8,),
                  ListTile(
                    title: Text(
                      data['cName'],
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF8C42)),
                    ),
                    subtitle: Text(
                      '${data['discount']}% 할인 쿠폰',
                      style: TextStyle(fontSize: 16),
                    ),
                    leading: Icon(Icons.card_giftcard, color: Color(0xFFFF8C42)),
                    trailing: Text(
                      "유효 기간: 2023-12-31",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "쿠폰",
          style: TextStyle(color: Color(0xff424242), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1.0,
        iconTheme: IconThemeData(color: Color(0xff424242)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _listCoupon(),
      bottomNavigationBar: SubBottomBar(),
    );
  }
}
