import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app/screens/home_screen.dart';
import 'package:app/screens/qr_scan_screen.dart';
import 'package:app/screens/workout_assist_screen.dart';
import 'package:app/screens/body_analysis_screen.dart';
import 'package:app/screens/activity_mets_screen.dart';
import 'package:app/screens/food_photo_screen.dart';
import 'package:app/screens/diet_insights_screen.dart';
import 'package:app/screens/inbody_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/qr', builder: (_, __) => const QrScanScreen()),
    GoRoute(path: '/assist', builder: (_, __) => const WorkoutAssistScreen()),
    GoRoute(path: '/body', builder: (_, __) => const BodyAnalysisScreen()),
    GoRoute(path: '/mets', builder: (_, __) => const ActivityMetsScreen()),
    GoRoute(path: '/food', builder: (_, __) => const FoodPhotoScreen()),
    GoRoute(path: '/diet', builder: (_, __) => const DietInsightsScreen()),
    GoRoute(path: '/inbody', builder: (_, __) => const InbodyScreen()),
  ],
);
