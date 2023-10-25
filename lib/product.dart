import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/productView.dart';

class Product extends StatefulWidget {
  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  late Stream<QuerySnapshot>? productStream;
  List<bool> isFavoriteList = [];

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then((value) {
      setState(() {
        productStream = FirebaseFirestore.instance.collection("product").snapshots();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (productStream == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("상품페이지"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("상품페이지"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder<QuerySnapshot>(
          stream: productStream!,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('상품이 없습니다.');
            }

            final productList = snapshot.data!.docs;

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: productList.length,
              itemBuilder: (context, index) {
                final document = productList[index];
                final productName = document['product_name'] as String;
                final price = document['price'] as String;
                final imageUrl = document['image_url'] as String;

                // 초기 값은 모두 false로 설정
                if (isFavoriteList.length <= index) {
                  isFavoriteList.add(false);
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductView(
                          productName: productName,
                          price: price,
                          imageUrl: imageUrl,
                          isFavorite: isFavoriteList[index],
                        ),
                      ),
                    ).then((value) {
                      setState(() {
                        isFavoriteList[index] = value ?? false;
                      });
                    });
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.0),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductView(
                                    productName: productName,
                                    price: price,
                                    imageUrl: imageUrl,
                                    isFavorite: isFavoriteList[index],
                                  ),
                                ),
                              ).then((value) {
                                setState(() {
                                  isFavoriteList[index] = value ?? false;
                                });
                              });
                            },
                            child: Icon(
                              isFavoriteList[index] ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductView(
                                        productName: productName,
                                        price: price,
                                        imageUrl: imageUrl,
                                        isFavorite: isFavoriteList[index],
                                      ),
                                    ),
                                  ).then((value) {
                                    setState(() {
                                      isFavoriteList[index] = value ?? false;
                                    });
                                  });
                                },
                                child: Text(
                                  productName,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductView(
                                        productName: productName,
                                        price: price,
                                        imageUrl: imageUrl,
                                        isFavorite: isFavoriteList[index],
                                      ),
                                    ),
                                  ).then((value) {
                                    setState(() {
                                      isFavoriteList[index] = value ?? false;
                                    });
                                  });
                                },
                                child: Text(
                                  '가격: $price 원',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}