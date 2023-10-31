import 'package:flutter/material.dart';

class PortfolioItem {
  final String id;
  final String title;
  final String description;

  PortfolioItem({required this.id, required this.title, required this.description});
}

class PortfolioView extends StatelessWidget {
  final PortfolioItem item;

  PortfolioView({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'ID: ${item.id}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '제목: ${item.title}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '설명: ${item.description}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
