import 'package:flutter/material.dart';

class SingleExerciseListScreen extends StatelessWidget {
  const SingleExerciseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('단일 운동 선택'),
      ),
      body: const Center(
        child: Text('단일 운동 목록이 표시될 화면입니다.'),
      ),
    );
  }
}