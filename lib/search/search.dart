import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("검색"),),
      body: Container(
        child: Column(
          children: [
            TextField(
              autofocus: true,
            )
          ],
        ),
      ),
    );
  }
}
