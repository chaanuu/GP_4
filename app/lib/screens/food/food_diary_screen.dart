import 'package:flutter/material.dart';

// TODO: 음식 로그 데이터 모델 정의 (예: lib/models/food_log.dart)
class FoodLog {
  final String imageUrl;
  final String name;
  final String portion;
  final int calories;
  final String mealType; // 아침, 점심, 저녁, 간식
  final String date;

  FoodLog({
    required this.imageUrl,
    required this.name,
    required this.portion,
    required this.calories,
    required this.mealType,
    required this.date,
  });
}

class FoodDiaryScreen extends StatelessWidget {
  const FoodDiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 백엔드에서 음식 기록 데이터 가져오기 (아래는 임시 데이터)
    final List<FoodLog> foodLogs = [
      FoodLog(imageUrl: 'assets/images/sandwich.jpg', name: '샌드위치', portion: '100g', calories: 198, mealType: '점심', date: '9/19'),
      FoodLog(imageUrl: 'assets/images/pizza.jpg', name: '피자', portion: '90g', calories: 237, mealType: '저녁', date: '9/19'),
      FoodLog(imageUrl: 'assets/images/bread.jpg', name: '빵', portion: '120g', calories: 302, mealType: '아침', date: '9/20'),
      FoodLog(imageUrl: 'assets/images/salmon.jpg', name: '연어 구이', portion: '180g', calories: 502, mealType: '점심', date: '9/20'),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
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
                  child: Image.asset(log.imageUrl, width: 70, height: 70, fit: BoxFit.cover),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${log.mealType} - ${log.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(log.portion, style: TextStyle(color: Colors.grey[600])),
                      Text('${log.calories}kcal', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                Text(log.date, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        },
      ),
    );
  }
}