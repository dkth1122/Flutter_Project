import 'package:flutter/material.dart';

class ProductPayment extends StatefulWidget {
  final String productName;
  final String price;

  const ProductPayment({
    required this.productName,
    required this.price,
  });

  @override
  State<ProductPayment> createState() => _ProductPaymentState();
}

class _ProductPaymentState extends State<ProductPayment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제 페이지'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '상품명: ${widget.productName}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              '가격: ${widget.price} 원',
              style: const TextStyle(fontSize: 16),
            ),
            // ... 결제 페이지의 내용 추가 ...
          ],
        ),
      ),
    );
  }
}
