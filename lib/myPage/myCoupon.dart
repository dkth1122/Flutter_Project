import 'package:flutter/material.dart';
import 'package:project_flutter/subBottomBar.dart';

class MyCoupon extends StatefulWidget {
  const MyCoupon({super.key});

  @override
  State<MyCoupon> createState() => _MyCouponState();
}

class _MyCouponState extends State<MyCoupon> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "쿠폰",
          style: TextStyle(color:Color(0xff424242), fontWeight: FontWeight.bold),
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
      bottomNavigationBar: SubBottomBar(),
    );
  }
}
