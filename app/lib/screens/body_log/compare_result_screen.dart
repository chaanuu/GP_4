import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';

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
    _simulateAnalysis();
  }

  Future<void> _simulateAnalysis() async {
    final randomDelay = (1500 + Random().nextInt(1700)); // 1.5~3.2초 랜덤
    await Future.delayed(Duration(milliseconds: randomDelay));

    final result = _generateDummyAnalysis();

    if (mounted) {
      setState(() {
        _analysisResult = result;
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _generateDummyAnalysis() {
    double randomBefore(double base) => double.parse((base + Random().nextDouble() * 4 - 2).toStringAsFixed(2));
    double randomDiff() => double.parse((Random().nextDouble() * 4 - 2).toStringAsFixed(2)); // -2.0 ~ +2.0

    Map<String, dynamic> buildPart(String key, double base) {
      double before = randomBefore(base);
      double diff = randomDiff();
      double after = double.parse((before + diff).toStringAsFixed(2));

      return {
        key: {"before": before, "after": after, "diff": diff}
      };
    }

    return {
      ...buildPart("waist", 90),
      ...buildPart("thigh", 55),
      ...buildPart("arm", 32),
    };
  }

  @override
  Widget build(BuildContext context) {
    final images = ModalRoute.of(context)!.settings.arguments as List<Map<String, String>>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('눈바디 분석 결과', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading ? _buildLoading() : _buildResult(images),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.black),
          SizedBox(height: 16),
          Text('분석 중입니다...'),
        ],
      ),
    );
  }

  Widget _buildResult(List<Map<String, String>> images) {
    final data = _analysisResult!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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

          const Text('신체 둘레 변화', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          _buildMeasurementCard('허리 둘레', data["waist"]),
          const SizedBox(height: 12),
          _buildMeasurementCard('허벅지 둘레', data["thigh"]),
          const SizedBox(height: 12),
          _buildMeasurementCard('팔 둘레', data["arm"]),

          const SizedBox(height: 28),

          _buildSummarySection(data),
        ],
      ),
    );
  }

  Widget _buildMeasurementCard(String title, Map<String, dynamic> data) {
    final diff = data["diff"] as double;
    final diffColor = diff > 0 ? Colors.redAccent : Colors.blueAccent;

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
      child: Row(
        children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Before: ${data['before']} cm"),
              Text("After: ${data['after']} cm"),
              const SizedBox(height: 6),
              Text(
                "변화: ${diff > 0 ? '+' : ''}$diff cm",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: diffColor),
              )
            ],
          ),
        ],
      ),
    );
  }

  /// 숫자 리스트만 보여주는 summary
  Widget _buildSummarySection(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('측정 결과 요약', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        Text("• 허리: ${data['waist']['diff'] > 0 ? '+' : ''}${data['waist']['diff']} cm",
            style: const TextStyle(fontSize: 15)),
        Text("• 허벅지: ${data['thigh']['diff'] > 0 ? '+' : ''}${data['thigh']['diff']} cm",
            style: const TextStyle(fontSize: 15)),
        Text("• 팔: ${data['arm']['diff'] > 0 ? '+' : ''}${data['arm']['diff']} cm",
            style: const TextStyle(fontSize: 15)),
      ]),
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
}
