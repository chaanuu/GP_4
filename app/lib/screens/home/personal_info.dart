import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/program_provider.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  // ✅ 신체 정보 컨트롤러 (나이 추가됨)
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController(); // 나이
  String _gender = 'male';

  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadAllUserInfo();
  }

  Future<void> _loadAllUserInfo() async {
    final api = ref.read(apiServiceProvider);
    final userData = await api.getUserInfo();

    final prefs = await SharedPreferences.getInstance();

    // 서버 값이 우선, 없으면 로컬/기본값
    final height = (userData?['height'] as num?)?.toDouble()
        ?? prefs.getDouble('user_height')
        ?? 175.0;

    final weight = (userData?['weight'] as num?)?.toDouble()
        ?? prefs.getDouble('user_weight')
        ?? 70.0;

    final age = (userData?['age'] as num?)?.toInt()
        ?? prefs.getInt('user_age')
        ?? 25;

    final gender = prefs.getString('user_gender') ?? 'M';

  // 기존값이 male/female이면 변환
    if (gender == 'male') _gender = 'm';
    else if (gender == 'female') _gender = 'f';
    else _gender = gender;

    if (mounted) {
      setState(() {
        if (userData != null) {
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';

          // gender 변환
          final g = userData['gender'];
          if (g == 'male') _gender = 'm';
          else if (g == 'female') _gender = 'f';
          else _gender = g ?? 'm';
        }
        _heightController.text = height.toString();
        _weightController.text = weight.toString();
        _ageController.text = age.toString();


        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserInfo() async {
    setState(() => _isLoading = true);

    final api = ref.read(apiServiceProvider);
    final success = await api.updateUserInfo(
      _nameController.text.trim(),
      height: double.tryParse(_heightController.text),
      weight: double.tryParse(_weightController.text),
      age: int.tryParse(_ageController.text),
      gender: _gender,
    );

    // 원하면 SharedPreferences는 캐시 용도로만 사용
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_height', double.tryParse(_heightController.text) ?? 175.0);
    await prefs.setDouble('user_weight', double.tryParse(_weightController.text) ?? 70.0);
    await prefs.setInt('user_age', int.tryParse(_ageController.text) ?? 25);
    await prefs.setString('user_gender', _gender);

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '정보가 수정되었습니다.' : '일부 정보(서버) 수정에 실패했습니다.'),
      ),
    );
  }


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose(); // dispose 추가
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: () {
                if (_isEditing) {
                  _saveUserInfo();
                } else {
                  setState(() => _isEditing = true);
                }
              },
              child: Text(
                _isEditing ? '저장' : '수정',
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('기본 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            _buildTextField('이메일', _emailController, readOnly: true),
            const SizedBox(height: 16),
            _buildTextField('이름', _nameController, readOnly: !_isEditing),

            const SizedBox(height: 32),
            const Text('신체 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // ✅ 키, 몸무게, 나이를 한 줄에 배치
            Row(
              children: [
                Expanded(child: _buildTextField('키 (cm)', _heightController, readOnly: !_isEditing, isNumber: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('몸무게 (kg)', _weightController, readOnly: !_isEditing, isNumber: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('나이', _ageController, readOnly: !_isEditing, isNumber: true)),
              ],
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _gender,
              decoration: InputDecoration(
                labelText: '성별',
                border: const OutlineInputBorder(),
                filled: !_isEditing,
                fillColor: _isEditing ? Colors.white : const Color(0xFFF5F5F5),
              ),
              items: const [
                DropdownMenuItem(value: 'm', child: Text('남성')),
                DropdownMenuItem(value: 'f', child: Text('여성')),
              ],
              onChanged: _isEditing ? (value) {
                setState(() {
                  _gender = value!;
                });
              } : null,
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await ref.read(apiServiceProvider).logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('로그아웃', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false, bool isNumber = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: readOnly,
        fillColor: readOnly ? const Color(0xFFF5F5F5) : Colors.white,
      ),
    );
  }
}