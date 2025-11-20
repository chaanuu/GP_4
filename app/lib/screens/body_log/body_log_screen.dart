import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io'; // 파일 로드용
import '../../providers/nav_provider.dart';

class BodyLogScreen extends ConsumerStatefulWidget {
  const BodyLogScreen({super.key});

  @override
  ConsumerState<BodyLogScreen> createState() => _BodyLogScreenState();
}

class _BodyLogScreenState extends ConsumerState<BodyLogScreen> {
  List<Map<String, String>> _bodyImages = [];

  // 선택된 이미지들의 인덱스를 저장하는 Set
  final Set<int> _selectedIndexes = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  // 저장된 이미지 목록 불러오기
  Future<void> _loadImages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedData = prefs.getStringList('body_images') ?? [];

    // 더미 데이터 (초기 테스트용 - 시간 정보 추가됨)
    if (savedData.isEmpty) {
      _bodyImages = [
        {'path': 'assets/images/body1.png', 'date': '2025년 10월 12일 09:00', 'isAsset': 'true'},
        {'path': 'assets/images/body2.png', 'date': '2025년 10월 11일 18:30', 'isAsset': 'true'},
      ];
    } else {
      // 저장된 데이터 파싱 ("경로|날짜 시간")
      _bodyImages = savedData.map((item) {
        final split = item.split('|');
        return {
          'path': split[0],
          'date': split.length > 1 ? split[1] : '날짜 없음',
          'isAsset': 'false',
        };
      }).toList().reversed.toList(); // 최신순 정렬
    }
    setState(() {});
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else {
        if (_selectedIndexes.length < 2) {
          _selectedIndexes.add(index);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('비교할 사진은 2장까지만 선택 가능합니다.')),
          );
        }
      }
      _isSelectionMode = _selectedIndexes.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            if (_isSelectionMode) {
              setState(() {
                _selectedIndexes.clear();
                _isSelectionMode = false;
              });
            } else {
              ref.read(navIndexProvider.notifier).state = -1;
            }
          },
        ),
        title: Text(
          _isSelectionMode ? '${_selectedIndexes.length}장 선택됨' : '눈바디 분석',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isSelectionMode)
            TextButton(
              onPressed: () {
                setState(() {
                  _isSelectionMode = true;
                });
              },
              child: const Text('비교하기', style: TextStyle(fontSize: 16)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _bodyImages.length,
              itemBuilder: (context, index) {
                final image = _bodyImages[index];
                final isSelected = _selectedIndexes.contains(index);
                final isAsset = image['isAsset'] == 'true';

                return GestureDetector(
                  onTap: () {
                    if (_isSelectionMode) {
                      _toggleSelection(index);
                    } else {
                      // TODO: 사진 상세 보기 (크게 보기)
                    }
                  },
                  onLongPress: () {
                    if (!_isSelectionMode) {
                      setState(() {
                        _isSelectionMode = true;
                        _toggleSelection(index);
                      });
                    }
                  },
                  child: GridTile(
                    footer: GridTileBar(
                      backgroundColor: Colors.black45,
                      // 날짜와 시간이 잘 보이도록 폰트 크기 조정
                      title: Text(
                        image['date']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11), // 글자 크기를 줄여서 한 줄에 나오도록 유도
                      ),
                      trailing: _isSelectionMode
                          ? Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? Colors.blue : Colors.white,
                      )
                          : null,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        isAsset
                            ? Image.asset(
                          image['path']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                            );
                          },
                        )
                            : Image.file(
                          File(image['path']!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                            );
                          },
                        ),
                        if (isSelected)
                          Container(
                            color: Colors.white.withOpacity(0.3),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isSelectionMode)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _selectedIndexes.length == 2
                      ? () {
                    List<Map<String, String>> selectedImages = _selectedIndexes
                        .map((i) => _bodyImages[i])
                        .toList();

                    Navigator.pushNamed(
                      context,
                      '/compare_result',
                      arguments: selectedImages,
                    );

                    setState(() {
                      _selectedIndexes.clear();
                      _isSelectionMode = false;
                    });
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    '선택한 2장 비교 분석하기',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}