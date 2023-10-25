import 'package:flutter/material.dart';

class ProductView extends StatefulWidget {
  final String productName;
  final String price;
  final String imageUrl;
  final bool isFavorite;

  const ProductView({
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.isFavorite,
  });

  @override
  _ProductViewState createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("상세보기"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '상품 상세'),
            Tab(text: '후기'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductDetailTab(),
          _buildReviewTab(),
        ],
      ),
    );
  }

  Widget _buildProductDetailTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            widget.imageUrl,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20),
          Text(
            widget.productName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '가격: ${widget.price} 원',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildReviewTab() {
    return Center(
      child: Text(
        '후기',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
