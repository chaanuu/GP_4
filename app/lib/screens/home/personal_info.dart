import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/personal_info_provider.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  // 사용자가 입력할 값을 제어하기 위한 컨트롤러
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _selectedGender = 'Male'; // 성별 초기값
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // ⭐️ initState에서 저장된 기존 정보를 로드하는 로직을 호출합니다.
    final info = ref.read(personalInfoProvider);
    _heightController.text = info.height.toString();
    _weightController.text = info.weight.toString();
    _ageController.text = info.age.toString();
    _selectedGender = info.gender;
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // 정보 저장
  void _savePersonalInfo() {
    // 1. 입력 값 파싱 및 유효성 검사
    final double? height = double.tryParse(_heightController.text);
    final double? weight = double.tryParse(_weightController.text);
    final int? age = int.tryParse(_ageController.text);

    // 2. 유효성 검사
    if (height != null && height > 0 &&
        weight != null && weight > 0 &&
        age != null && age > 0) {

      // 3. Riverpod 상태 업데이트 (앱 전체에 정보 반영 및 저장소에 저장)
      ref.read(personalInfoProvider.notifier).updateInfo(
        height: height,
        weight: weight,
        age: age,
        gender: _selectedGender,
      );

      // 4. 저장 성공 알림
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('건강 정보가 저장되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
      Future.microtask(() {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } else {
      // 5. 유효하지 않은 정보 알림
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('유효한 숫자 정보를 입력해 주세요.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(personalInfoProvider);

    if (!_isInitialized) {
      _heightController.text = info.height == 0.0 ? '' : info.height.toString();
      _weightController.text = info.weight == 0.0 ? '' : info.weight.toString();
      _ageController.text = info.age == 0 ? '' : info.age.toString();
      _isInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('건강 정보 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // 💡 키 입력 필드
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: '키 (cm)'),
              keyboardType: TextInputType.number,
            ),
            // 💡 몸무게 입력 필드
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: '몸무게 (kg)'),
              keyboardType: TextInputType.number,
            ),
            // 💡 나이 입력 필드
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: '나이'),
              keyboardType: TextInputType.number,
            ),
            // 💡 성별 선택 필드 (예시)
            DropdownButton<String>(
              value: _selectedGender,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue!;
                });
              },
              items: <String>['Male', 'Female']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            // 💡 저장 버튼
            ElevatedButton(
              onPressed: _savePersonalInfo,
              child: const Text('정보 저장'),
            ),
          ],
        ),
      ),
    );
  }
}