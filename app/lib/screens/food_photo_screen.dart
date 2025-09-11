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
  int? appliedPortion; // 선택한 섭취 비율 저장(선택 후 스낵바 외 표시에 사용하고 싶으면)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('음식 사진 분석'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
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
                  child: imagePath == null
                      ? const Text('이미지 선택')
                      : Text('선택됨: $imagePath'),
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
                        // 분석 결과 더미 생성
                        setState(() {
                          nutrients = {
                            '메뉴': '비빔밥',
                            '칼로리(kcal)': 560,
                            '탄수화물(g)': 75,
                            '단백질(g)': 18,
                            '지방(g)': 18
                          };
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ====== 분석 결과 카드 ======
              if (nutrients != null) ...[
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0.5,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: nutrients!.entries
                          .map(
                            (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text(e.key), Text('${e.value}')],
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ====== 카드 바로 아래: 섭취 데이터 반영 버튼 ======
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: '섭취 데이터 반영',
                    onPressed: () async {
                      final percent = await _selectPortionPercentage(context, initial: 100);
                      if (percent != null && mounted) {
                        setState(() => appliedPortion = percent);
                        // TODO: 실제 반영 로직 (상태/백엔드 호출 등)
                        // ref.read(intakeProvider.notifier).apply(photoId, percent);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('섭취 비율 $percent% 반영됨')),
                        );
                      }
                    },
                  ),
                ),

                if (appliedPortion != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('선택된 섭취 비율: $appliedPortion%'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 10% 단위(0~100, 기본 100%)로 섭취 비율을 고르는 다이얼로그
Future<int?> _selectPortionPercentage(BuildContext context, {int initial = 100}) async {
  int current = initial.clamp(0, 100);

  return showDialog<int>(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('섭취 비율 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$current%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Slider(
              value: current.toDouble(),
              min: 0,
              max: 100,
              divisions: 10, // 10% 단위
              label: '$current%',
              onChanged: (v) => setState(() => current = v.round()),
            ),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, current), child: const Text('확인')),
        ],
      ),
    ),
  );
}

