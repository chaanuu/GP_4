class WorkoutExercise {
  final String name;
  final String imagePath;
  final int sets;
  final int reps;
  final double weight;

  WorkoutExercise({
    required this.name,
    required this.imagePath,
    required this.sets,
    required this.reps,
    required this.weight,
  });

  // Map(JSON)에서 WorkoutExercise 객체로 변환
  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      name: json['name'],
      imagePath: json['imagePath'],
      sets: json['sets'],
      reps: json['reps'],
      weight: json['weight'],
    );
  }

  // WorkoutExercise 객체를 Map(JSON)으로 변환
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imagePath': imagePath,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }
}

class WorkoutProgram {
  final String title;
  final String date;
  final List<WorkoutExercise> exercises;

  WorkoutProgram({
    required this.title,
    required this.date,
    required this.exercises,
  });

  // Map(JSON)에서 WorkoutProgram 객체로 변환
  factory WorkoutProgram.fromJson(Map<String, dynamic> json) {
    var exerciseList = json['exercises'] as List;
    List<WorkoutExercise> exercises = exerciseList.map((e) => WorkoutExercise.fromJson(e)).toList();
    return WorkoutProgram(
      title: json['title'],
      date: json['date'],
      exercises: exercises,
    );
  }

  // WorkoutProgram 객체를 Map(JSON)으로 변환
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}