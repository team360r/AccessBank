// tools/generate_content.dart
import 'dart:convert';
import 'dart:io';

import '../lib/tutorial/chapters/chapter_0.dart';
import '../lib/tutorial/chapters/chapter_1.dart';
import '../lib/tutorial/chapters/chapter_2.dart';
import '../lib/tutorial/chapters/chapter_3.dart';
import '../lib/tutorial/chapters/chapter_4.dart';
import '../lib/tutorial/chapters/chapter_5.dart';
import '../lib/tutorial/chapters/chapter_6.dart';
import '../lib/tutorial/chapters/chapter_7.dart';
import '../lib/tutorial/chapters/chapter_8.dart';
import '../lib/tutorial/chapters/chapter_9.dart';

void main() {
  final chapters = [
    chapter0, chapter1, chapter2, chapter3, chapter4,
    chapter5, chapter6, chapter7, chapter8, chapter9,
  ];

  final json = {
    'version': 1,
    'generatedAt': DateTime.now().toIso8601String(),
    'chapters': chapters.map((c) => c.toJson()).toList(),
  };

  final outDir = Directory('tools/shared');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  final outFile = File('tools/shared/tutorial_content.json');
  outFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(json));

  print('✓ Generated ${outFile.path}');
  print('  ${chapters.length} chapters');
  print('  ${chapters.fold(0, (sum, c) => sum + c.steps.length)} steps');
  print('  ${chapters.fold(0, (sum, c) => sum + c.steps.where((s) => s.codeDiff != null).length)} code diffs');
  print('  ${chapters.fold(0, (sum, c) => sum + (c.quiz?.questions.length ?? 0))} quiz questions');
}
