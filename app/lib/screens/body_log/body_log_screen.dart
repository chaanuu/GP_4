import 'package:flutter/material.dart';

class BodyLogScreen extends StatelessWidget {
  const BodyLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 로컬 저장소에서 눈바디 사진 경로 및 날짜 목록 불러오기
    // final List<BodyLogImage> bodyImages = LocalStorageService.getImages();
    final List<Map<String, String>> bodyImages = [
      {'path': 'assets/images/body1.png', 'date': '2025년 10월 12일'},
      {'path': 'assets/images/body2.png', 'date': '2025년 10월 11일'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('눈바디 분석', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 한 줄에 2개의 이미지
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: bodyImages.length,
        itemBuilder: (context, index) {
          final image = bodyImages[index];
          return GestureDetector(
            onTap: () {
              // TODO: 상세 보기 및 비교 분석 화면으로 이동
              // Navigator.push(context, MaterialPageRoute(builder: (context) => BodyLogDetailScreen(imagePath: image['path']!)));
            },
            child: GridTile(
              footer: GridTileBar(
                backgroundColor: Colors.black45,
                title: Text(image['date']!, textAlign: TextAlign.center),
              ),
              child: Image.asset(image['path']!, fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }
}