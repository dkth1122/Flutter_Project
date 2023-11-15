import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final int cnt;
  final DateTime timestamp;


  SalesItem({
    required this.pName,
    required this.category,
    required this.imgUrl,
    required this.price,
    required this.cnt,
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
  String selectedSort = '기본 순';
  List<String> sortOptions = [
    '기본 순',
    '조회수 높은 순',
    '최신 등록 순',
    '가격 높은 순',
    '가격 낮은 순',
  ];



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
    });
    Navigator.pop(context); // 필터 모달 닫기
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
        backgroundColor: MaterialStateProperty.all(Colors.white), // 배경색: 하얏트 (흰색)
        foregroundColor: MaterialStateProperty.all(Color(0xff424242)), // 글자색: 진한 회색
        overlayColor: MaterialStateProperty.all(Colors.orange), // 버튼 누를 때 밑줄 색상: 오렌지
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.black, // 아래쪽 선의 색상 설정
              width: 1.0, // 아래쪽 선의 너비 설정
            ),
            borderRadius: BorderRadius.circular(8), // 버튼의 둥근 모서리 설정
          ),
        ),
      ),
      onPressed: onPressed,
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
            cnt: doc['cnt'] as int,
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
          style: TextStyle(color:Color(0xff424242), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xff424242)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _filterButton(
                icon: Icons.arrow_drop_down,
                text: '상품유형',
                onPressed: () {
                  _showFilterOptions(context, optionsButton1);
                },
              ),
              SizedBox(width: 10), // 버튼 사이에 간격을 추가합니다
              DropdownButton<String>(
                value: selectedSort,
                items: sortOptions.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedSort = value!;
                  });
                },
                style: TextStyle(color: Colors.black), // 드롭다운에서 선택된 항목의 텍스트 스타일
                icon: Icon(Icons.arrow_drop_down, color: Colors.white), // 드롭다운 화살표 아이콘
                iconSize: 24, // 아이콘 크기
                elevation: 16, // 드롭다운 메뉴의 elevation
                dropdownColor: Colors.white, // 드롭다운 메뉴의 배경색다운 메뉴의 배경색
                underline: Container(),
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

                  if (selectedCategory.isNotEmpty && selectedCategory != '전체') {
                    filteredSales = filteredSales.where((item) => item.category == selectedCategory).toList();
                  }

                  if (selectedSort == '조회수 높은 순') {
                    filteredSales.sort((a, b) {
                      return b.cnt.compareTo(a.cnt);
                    });
                  } else if (selectedSort == '최신 등록 순') {
                    filteredSales.sort((a, b) {
                      return b.timestamp.compareTo(a.timestamp);
                    });
                  } else if (selectedSort == '가격 높은 순') {
                    filteredSales.sort((a, b) {
                      return b.price.compareTo(a.price);
                    });
                  } else if (selectedSort == '가격 낮은 순') {
                    filteredSales.sort((a, b) {
                      return a.price.compareTo(b.price);
                    });
                  }

                  return ListView.builder(
                    itemCount: filteredSales.length,
                    itemBuilder: (context, index) {
                      SalesItem salesItem = filteredSales[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Text(salesItem.pName),
                            subtitle: Text(salesItem.category),
                            leading: Image.network(salesItem.imgUrl),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _showDeleteConfirmationDialog(context, salesItem.pName);
                                  },
                                  child: Icon(Icons.delete, color: Colors.red),
                                ),
                                SizedBox(width: 16),
                                Text('${NumberFormat('#,###').format(salesItem.price)}원'),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductView(
                                    productName: salesItem.pName,
                                    price: salesItem.price.toString(),
                                    imageUrl: salesItem.imgUrl,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10),
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
      bottomNavigationBar: BottomAppBar(),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String productName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제 확인'),
          content: Text('정말로 $productName 상품을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(productName);
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(String productName) async {
    try {
      await FirebaseFirestore.instance
          .collection('product')
          .where('pName', isEqualTo: productName)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      await FirebaseFirestore.instance
          .collection('like')
          .where('pName', isEqualTo: productName)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      setState(() {});
    } catch (e) {
      print('상품 삭제 중 오류 발생: $e');
    }
  }

}
