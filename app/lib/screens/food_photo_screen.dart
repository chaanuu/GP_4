import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/primary_button.dart';

class FoodPhotoScreen extends ConsumerStatefulWidget {
  const FoodPhotoScreen({super.key});
  @override
  ConsumerState<FoodPhotoScreen> createState() => _FoodPhotoScreenState();
}

class _FoodPhotoScreenState extends ConsumerState<FoodPhotoScreen> {
  String? imagePath;
  Map<String, dynamic>? nutrients;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('음식 사진 분석'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: imagePath == null ? const Text('이미지 선택') : Text('선택됨: $imagePath'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: '이미지 선택(더미)',
                    onPressed: () => setState(() => imagePath = 'path/to/food.jpg'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: '분석 실행(더미)',
                    onPressed: imagePath == null
                        ? null
                        : () {
                      setState(() {
                        nutrients = {'메뉴': '비빔밥','칼로리(kcal)': 560,'탄수화물(g)': 75,'단백질(g)': 18,'지방(g)': 18};
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (nutrients != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: nutrients!.entries
                        .map((e) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text(e.key), Text('${e.value}')],
                    ))
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
