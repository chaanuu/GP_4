import 'package:flutter/material.dart';
import 'dart:io';

class CompareResultScreen extends StatefulWidget {
  const CompareResultScreen({super.key});

  @override
  State<CompareResultScreen> createState() => _CompareResultScreenState();
}

class _CompareResultScreenState extends State<CompareResultScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _analysisResult;

  @override
  void initState() {
    super.initState();
    _analyzeImages();
  }

  // 서버 통신 시뮬레이션
  Future<void> _analyzeImages() async {
    // 실제로는 여기서 선택된 이미지 파일을 서버로 전송하고 결과를 받습니다.
    await Future.delayed(const Duration(seconds: 2)); // 2초 로딩

    if (mounted) {
      setState(() {
        _isLoading = false;
        // 가짜 분석 결과 데이터
        _analysisResult = {
          'score': 85,
          'muscle_change': '+2.5%',
          'fat_change': '-1.2%',
          'feedback': '전반적으로 근육 선명도가 좋아졌습니다!\n특히 어깨 라인이 눈에 띄게 발달했습니다. 복부 지방도 약간 감소한 것으로 보입니다.',
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 이전 화면에서 전달받은 2장의 이미지 리스트
    final images = ModalRoute.of(context)!.settings.arguments as List<Map<String, String>>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('분석 결과', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.black),
            SizedBox(height: 16),
            Text('AI가 두 사진을 분석하고 있습니다...'),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 비교 사진 나란히 보여주기
            Row(
              children: [
                Expanded(child: _buildImageCard(images[0], 'Before')),
                const SizedBox(width: 16),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                const SizedBox(width: 16),
                Expanded(child: _buildImageCard(images[1], 'After')),
              ],
            ),
            const SizedBox(height: 32),

            // 2. 분석 결과 요약
            const Text('변화 분석', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildResultCard('근육량 변화', _analysisResult!['muscle_change'], Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildResultCard('체지방 변화', _analysisResult!['fat_change'], Colors.red)),
              ],
            ),
            const SizedBox(height: 24),

            // 3. 상세 피드백
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI 피드백', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    _analysisResult!['feedback'],
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(Map<String, String> image, String label) {
    final isAsset = image['isAsset'] == 'true';
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              image: DecorationImage(
                image: isAsset
                    ? AssetImage(image['path']!) as ImageProvider
                    : FileImage(File(image['path']!)),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(image['date']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildResultCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}