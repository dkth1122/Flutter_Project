import 'package:flutter/material.dart';

class PurchaseManagementPage extends StatelessWidget {

  void _showInfoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      Navigator.of(context).pop(); // 모달 바텀 시트 닫기
                    },
                  ),
                  Text("구매관리 안내", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 12),
              Text("꼭 확인해주세요!", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "주문금액에 대한 세금계산서는 거래주체인 전문가가 직접발행하며, 세금계산서 발행 가능한 사업자전문가의 서비스 구매시에만 신청할 수 있습니다.",
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "구매관리",
          style: TextStyle(color: Colors.grey),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: IconThemeData(color: Colors.grey),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.grey),
            onPressed: () {
              _showInfoModal(context);
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("주문 1"),
            subtitle: Text("상품 1"),
            trailing: Text("가격: \$10"),
          ),
          ListTile(
            title: Text("주문 2"),
            subtitle: Text("상품 2"),
            trailing: Text("가격: \$20"),
          ),
          // 추가적인 주문 항목을 원하는 만큼 반복
        ],
      ),
    );
  }
}
