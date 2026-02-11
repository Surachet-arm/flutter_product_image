import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

// แอปหลัก
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TravelList()); // กำหนดหน้าแรกเป็น ProductList
  }
}

// สร้าง Widget สำหรับรายการสินค้า
class TravelList extends StatefulWidget {
  const TravelList({super.key});

  @override
  _TravelListState createState() => _TravelListState();
}

class _TravelListState extends State<TravelList> {
  List travels = []; // เก็บข้อมูลสินค้าทั้งหมด
  List filteredTravels = []; // เก็บข้อมูลสินค้าที่ค้นหา
  TextEditingController searchController = TextEditingController(); // ตัวควบคุมช่องค้นหา

  @override
  void initState() {
    super.initState();
    fetchTravels(); // เรียก API เมื่อโหลดหน้าครั้งแรก
  }

  // ฟังก์ชันดึงข้อมูลสินค้าจาก API
  Future<void> fetchTravels() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/flutter_product_image/php_api/show_data_travel.php'),
      );
      if (response.statusCode == 200) {
        setState(() {
          travels = json.decode(response.body); // แปลง JSON เป็น List
          filteredTravels = travels; // เริ่มต้นให้แสดงสินค้าทั้งหมด
        });
      } else {
        print('Failed to load travels: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching travels: $e');
    }
  }

  // ฟังก์ชันกรองสินค้าจากการค้นหา
  void filterTravels(String query) {
    setState(() {
      filteredTravels = travels.where((travel) {
        final name = travel['name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase()); // ค้นหาจากชื่อสินค้า
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Travel List')), // แถบหัวข้อ
      body: Column(
        children: [
          // ช่องค้นหาสินค้า
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search by travel name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterTravels, // เรียก filterProducts เมื่อพิมพ์
            ),
          ),
          // แสดงรายการสินค้า
          Expanded(
            child: filteredTravels.isEmpty
                ? const Center(child: CircularProgressIndicator()) // โหลดข้อมูล
                : ListView.builder(
                    itemCount: filteredTravels.length,
                    itemBuilder: (context, index) {
                      final travel = filteredTravels[index];
                      String imageAsset =
                          'assets/images/${travel['image'] ?? 'default.png'}';
                      return Card(
                        child: ListTile(
                          leading: SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.asset(
                              imageAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error); // กรณีโหลดภาพไม่ได้
                              },
                            ),
                          ),
                          title: Text(travel['name'] ?? 'No Name'), // ชื่อสินค้า
                          subtitle: Text(
                            travel['description'] ?? 'No Description', // รายละเอียดสินค้า
                          ),
                          trailing: Text('฿${travel['price'] ?? '0.00'}'), // ราคา
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TravelDetail(travel: travel),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// หน้ารายละเอียดสินค้า
class TravelDetail extends StatelessWidget {
  final dynamic travel;
  const TravelDetail({super.key, required this.travel});

  @override
  Widget build(BuildContext context) {
    String imageAsset = 'assets/images/${travel['image'] ?? 'default.png'}';

    return Scaffold(
      appBar: AppBar(title: Text(travel['name'] ?? 'Travel Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงภาพสินค้า
            Center(
              child: Image.asset(
                imageAsset,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 100);
                },
              ),
            ),
            const SizedBox(height: 20),
            // ชื่อสินค้า
            Text('Name: ${travel['name'] ?? 'No Name'}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // รายละเอียดสินค้า
            Text('Description: ${travel['description'] ?? 'No Description'}'),
            const SizedBox(height: 10),
            // ราคา
            
          ],
        ),
      ),
    );
  }
}


