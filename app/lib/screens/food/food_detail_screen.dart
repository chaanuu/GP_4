// lib/screens/food/food_detail_screen.dart

import 'package:flutter/material.dart';
import 'dart:io';

class FoodDetailScreen extends StatelessWidget {
  final String logEntry;

  const FoodDetailScreen({super.key, required this.logEntry});

  // 로그 문자열을 파싱하여 화면에 표시할 Map 형태로 변환
  Map<String, String> _parseLogEntry() {
    final parts = logEntry.split('|');

    // 최소 9개의 요소(0~8)가 있어야 탄단지까지 모두 포함
    if (parts.length < 9) {
      // 구형 로그 형식이거나 오류가 있는 경우
      return {
        'imagePath': parts.length > 0 ? parts[0] : '',
        '음식': '로그 파싱 오류: 데이터 부족',
        '섭취량': 'N/A',
        '섭취 칼로리': 'N/A',
        '탄수화물': 'N/A',
        '단백질': 'N/A',
        '지방': 'N/A',
        '기록 시간': 'N/A',
      };
    }

    final imagePath = parts[0];
    final foodName = parts[1];
    final servingSize = parts[2];
    final calories = parts[3];
    final carbs = parts[4];
    final protein = parts[5];
    final fat = parts[6];
    final mealType = parts[7];
    final dateTime = parts[8];

    return {
      'imagePath': imagePath,
      '음식': '$mealType - $foodName', // 상세 페이지에서는 식사 유형을 이름에 포함
      '섭취량': servingSize,
      '섭취 칼로리': calories,
      '탄수화물': carbs,
      '단백질': protein,
      '지방': fat,
      '기록 시간': dateTime,
    };
  }

  @override
  Widget build(BuildContext context) {
    final nutritionData = _parseLogEntry();
    final imagePath = nutritionData['imagePath']!;
    final displayTitle = nutritionData['음식']!.split(' - ').last; // AppBar에는 음식 이름만 표시

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
        title: Text(displayTitle, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 표시
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: imagePath.isNotEmpty && File(imagePath).existsSync()
                  ? Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                width: double.infinity,
                height: 300,
              )
                  : Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Text('이미지 파일을 찾을 수 없습니다.'),
              ),
            ),
            const SizedBox(height: 24),

            // 기록 시간 표시
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text('기록 시간: ${nutritionData['기록 시간']}',
                  style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
            ),

            // 영양 정보 표시
            _buildNutritionInfo('음식', nutritionData['음식']!),
            _buildNutritionInfo('섭취량', nutritionData['섭취량']!),
            _buildNutritionInfo('섭취 칼로리', nutritionData['섭취 칼로리']!),
            const Divider(height: 40),
            _buildNutritionInfo('탄수화물', nutritionData['탄수화물']!),
            _buildNutritionInfo('단백질', nutritionData['단백질']!),
            _buildNutritionInfo('지방', nutritionData['지방']!),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}