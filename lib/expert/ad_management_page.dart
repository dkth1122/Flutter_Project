// lib/pages/ad_management_page.dart

import 'package:flutter/material.dart';
import 'ad_model.dart';
import 'ad_form.dart';

class AdManagementPage extends StatefulWidget {
  @override
  _AdManagementPageState createState() => _AdManagementPageState();
}

class _AdManagementPageState extends State<AdManagementPage> {
  final List<Ad> ads = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('광고 관리'),
      ),
      body: ListView.builder(
        itemCount: ads.length,
        itemBuilder: (context, index) {
          final ad = ads[index];
          return ListTile(
            title: Text(ad.title),
            subtitle: Text(ad.description),
            // 추가적인 광고 정보 표시
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdForm()),
          ).then((newAd) {
            if (newAd != null) {
              setState(() {
                ads.add(newAd);
              });
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
