import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';

class FoodAnalysisScreen extends StatelessWidget {
  // final XFile image; // 카메라로 찍은 이미지를 이전 화면에서 전달받음
  const FoodAnalysisScreen({super.key /*, required this.image */});

  @override
  Widget build(BuildContext context) {
    // TODO: 백엔드에서 이미지 분석 결과(영양 정보) 가져오기
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
        title: const Text('음식 분석', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(12.0),
            //   child: Image.file(File(image.path)),
            // ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset('assets/images/pizza.png'), // 임시 이미지
            ),
            const SizedBox(height: 24),
            _buildNutritionInfo('음식', '피자'),
            _buildNutritionInfo('섭취량', '90g'),
            _buildNutritionInfo('섭취 칼로리', '237kcal'),
            const Divider(height: 40),
            _buildNutritionInfo('탄수화물', '25g'),
            _buildNutritionInfo('단백질', '10g'),
            _buildNutritionInfo('지방', '8g'),
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