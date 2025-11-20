import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod import
import '../../providers/nav_provider.dart'; // 네비게이션 상태 관리 provider

// 1. ConsumerWidget으로 변경
class FoodDiaryScreen extends ConsumerWidget {
  const FoodDiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 백엔드 데이터 연동 (임시 데이터)
    final List<Map<String, dynamic>> foodLogs = [
      {'imageUrl': 'assets/images/pears.jpg', 'name': '설탕 절인 토마토', 'portion': '100g', 'calories': 73, 'mealType': '간식', 'date': '9/19'},
      {'imageUrl': 'assets/images/pizza.jpg', 'name': '피자', 'portion': '90g', 'calories': 237, 'mealType': '저녁', 'date': '9/19'},
      {'imageUrl': 'assets/images/sandwich.jpg', 'name': '계란 샌드위치', 'portion': '97g', 'calories': 198, 'mealType': '아침', 'date': '9/20'},
      {'imageUrl': 'assets/images/sushi.jpg', 'name': '콩국수', 'portion': '210g', 'calories': 655, 'mealType': '점심', 'date': '9/20'},
    ];

    return Scaffold(
      appBar: AppBar(
        // 2. 뒤로가기 버튼 커스텀: 메인 화면(-1)으로 인덱스 변경
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            ref.read(navIndexProvider.notifier).state = -1;
          },
        ),
        title: const Text('식습관 분석', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: foodLogs.length,
        itemBuilder: (context, index) {
          final log = foodLogs[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  // 이미지가 없을 경우를 대비한 에러 처리
                  child: Image.asset(
                    log['imageUrl'],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[300],
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${log['mealType']} - ${log['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(log['portion'], style: TextStyle(color: Colors.grey[600])),
                      Text('${log['calories']}kcal', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                Text(log['date'], style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        },
      ),
    );
  }
}