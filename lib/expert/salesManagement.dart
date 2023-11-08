import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/product/productView.dart';
class SalesManagementPage extends StatefulWidget {
  final String userId;

  const SalesManagementPage({required this.userId, Key? key}) : super(key: key);
  @override
  _SalesManagementPageState createState() => _SalesManagementPageState(userId:userId);
}
class SalesItem {
  final String pName;
  final String category;
  final String imgUrl;
  final int price;
  final DateTime timestamp;


  SalesItem({
    required this.pName,
    required this.category,
    required this.imgUrl,
    required this.price,
    required this.timestamp,
  });
}

class _SalesManagementPageState extends State<SalesManagementPage> {
  final String userId;
  String selectedCategory = ""; // 선택한 상품 유형을 저장하는 변수
  List<SalesItem> salesItems = []; // SalesItem 리스트를 선언
  int _sortBy = 0;



  _SalesManagementPageState({required this.userId});


  List<String> optionsButton1 = [
    'UX기획',
    '웹',
    '커머스',
    '모바일',
    '프로그램',
    '트렌드',
    '데이터',
    '기타',];
  List<String> optionsButton2 = ["최신순", "가격낮은순", "가격높은순", "좋아요높은순", "조회수높은순"];


  Future<void> updateSalesItems(String userId, String categoryFilter) async {
    List<SalesItem> updatedSalesItems = await SalesList(userId, categoryFilter);
    setState(() {
      salesItems = updatedSalesItems;
    });
  }

  void _showInfoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
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
                  Text("판매관리 안내", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  void _showFilterOptions(BuildContext context, List<String> options) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: options.map((option) {
            return ListTile(
              title: Text(option),
              onTap: () {
                applyCategoryFilter(option); // 선택한 상품 유형을 전달하여 함수 호출
              },
            );
          }).toList(),
        );
      },
    );
  }

  void applyCategoryFilter(String option) {
    setState(() {
      selectedCategory = option;
      // print(selectedCategory);
    });
    Navigator.pop(context); // 필터 모달 닫기
  }
  void showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: optionsButton2.asMap().entries.map((entry) {
            int index = entry.key;
            String option = entry.value;
            return ListTile(
              title: Text(option),
              onTap: () {
                setState(() {
                  _sortBy = index + 1;
                });
                sortSalesItems(); // 정렬 함수 호출
                Navigator.pop(context); // 모달을 닫습니다.
              },
            );
          }).toList(),
        );
      },
    );
  }



  void sortSalesItems() {
    switch (_sortBy) {
      case 1: // 가격 낮은순
        salesItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 2: // 가격 높은순
        salesItems.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 3: // 최신순
        salesItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      default:
      // 기본 정렬은 최신순
        salesItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
    }
    setState(() {

    });
  }


  Widget _filterButton({
    IconData? icon, // Make the icon parameter nullable
    String? text, // Make the text parameter nullable
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon ?? Icons.arrow_drop_down),
      label: Text(text ?? "기본 텍스트"),
      style: ButtonStyle(
        side: MaterialStateProperty.all(BorderSide(width: 1.0, color:Color(0xFFFF8C42))),
        backgroundColor: MaterialStateProperty.all(Color(0xFFFF8C42) ),
        foregroundColor: MaterialStateProperty.all(Colors.white),
      ),
      onPressed: onPressed,
    );
  }

  void showDateRangePickerModal(BuildContext context) {
    DateTimeRange? selectedDateRange; // 모달 다이얼로그 내에서만 사용

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('날짜 범위 선택'),
              ElevatedButton(
                onPressed: () async {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );

                  if (picked != null) {
                    selectedDateRange = picked; // 모달 다이얼로그 내에서 변수에 선택한 범위 저장
                  }
                },
                child: Text('날짜 범위 선택'),
              ),
              if (selectedDateRange != null) // 선택한 날짜 범위를 표시
                Text('선택한 시작 날짜: ${selectedDateRange!.start}\n선택한 종료 날짜: ${selectedDateRange!.end}'),
            ],
          ),
        );
      },
    );
  }

  Future<List<SalesItem>> SalesList(String userId, String categoryFilter) async {
    try {
      Query query = FirebaseFirestore.instance.collection('product').where('user', isEqualTo: userId);

      if (categoryFilter.isNotEmpty) {
        query = query.where('category', isEqualTo: categoryFilter);
      }

      QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        List<SalesItem> salesList = querySnapshot.docs.map((doc) {
          return SalesItem(
            pName: doc['pName'] as String,
            category: doc['category'] as String,
            imgUrl: doc['iUrl'] as String,
            price: doc['price'] as int,
            timestamp: (doc['sendTime'] as Timestamp).toDate(),

          );
        }).toList();
        return salesList;
      } else {
        return [];
      }
    } catch (e) {
      print('판매리스트 가져오기 오류: $e');
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "판매관리",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF4E598C),
        elevation: 1.0,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              _showInfoModal(context);
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '검색',
                prefixIcon: Icon(Icons.search),
              ),
              // Implement your search functionality here
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _filterButton(
                icon: Icons.arrow_drop_down,
                text: '상품유형',
                onPressed: () {
                  _showFilterOptions(context, optionsButton1);
                },
              ),
              SizedBox(width: 10), // 버튼 사이에 간격을 추가합니다
              _filterButton(
                icon: Icons.arrow_drop_down,
                text: '정렬',
                onPressed: () {
                  showSortOptions(context);
                },
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<SalesItem>>(
              future: SalesList(userId, selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('데이터가 없습니다.'));
                } else {
                  List<SalesItem> filteredSales = snapshot.data!;

                  if (selectedCategory.isNotEmpty) {
                    filteredSales = filteredSales.where((item) => item.category == selectedCategory).toList();
                  }

                  return ListView.builder(
                    itemCount: filteredSales.length,
                    itemBuilder: (context, index) {
                      SalesItem salesItem = filteredSales[index]; // 필터링된 데이터를 사용
                      return Column(
                        children: [
                          ListTile(
                            title: Text(salesItem.pName),
                            subtitle: Text(salesItem.category),
                            leading: Image.network(salesItem.imgUrl),
                            trailing: Text('${salesItem.price.toString()}원'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProductView(
                                  productName: salesItem.pName,
                                  price: salesItem.price.toString(),
                                  imageUrl: salesItem.imgUrl,
                                )),
                              );
                            },
                          ),
                          SizedBox(height: 10)
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),

        ],
      ),
    );
  }


}
