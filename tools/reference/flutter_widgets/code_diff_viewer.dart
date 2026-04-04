import 'package:flutter/material.dart';

import '../chapter_model.dart';

/// Displays a before/after code diff with basic syntax highlighting.
///
/// Layout:
/// - Width > 600 px: side-by-side "Before" and "After" panels.
/// - Width <= 600 px: stacked panels (Before on top, After below).
///
/// A toggle button switches between side-by-side and unified (stacked) view
/// regardless of screen width.
///
/// Syntax highlighting rules (Dart-flavoured):
/// - Keywords → blue
/// - Strings → green
/// - Comments → grey
/// - Semantics-related identifiers → orange
class CodeDiffViewer extends StatefulWidget {
  const CodeDiffViewer({super.key, required this.diff});

  final CodeDiff diff;

  @override
  State<CodeDiffViewer> createState() => _CodeDiffViewerState();
}

class _CodeDiffViewerState extends State<CodeDiffViewer> {
  bool _forceStacked = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSideBySide =
            !_forceStacked && constraints.maxWidth > 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File path chip + layout toggle
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      widget.diff.filePath,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  const Spacer(),
                  Tooltip(
                    message: _forceStacked
                        ? 'Switch to side-by-side view'
                        : 'Switch to stacked view',
                    child: IconButton(
                      iconSize: 18,
                      icon: Icon(
                        _forceStacked
                            ? Icons.view_column_outlined
                            : Icons.view_agenda_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _forceStacked = !_forceStacked),
                    ),
                  ),
                ],
              ),
            ),

            // Code panels
            if (useSideBySide)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _CodePanel(
                        label: 'Before',
                        code: widget.diff.before,
                        isAfter: false,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _CodePanel(
                        label: 'After',
                        code: widget.diff.after,
                        isAfter: true,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  _CodePanel(
                    label: 'Before',
                    code: widget.diff.before,
                    isAfter: false,
                  ),
                  const SizedBox(height: 4),
                  _CodePanel(
                    label: 'After',
                    code: widget.diff.after,
                    isAfter: true,
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Single code panel (Before or After)
// ---------------------------------------------------------------------------

class _CodePanel extends StatelessWidget {
  const _CodePanel({
    required this.label,
    required this.code,
    required this.isAfter,
  });

  final String label;
  final String code;
  final bool isAfter;

  @override
  Widget build(BuildContext context) {
    final headerColor = isAfter
        ? const Color(0xFF1B5E20) // dark green
        : const Color(0xFF7F0000); // dark red
    final headerBg = isAfter
        ? const Color(0xFFE8F5E9) // green 50
        : const Color(0xFFFFEBEE); // red 50

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: headerBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: headerColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ),

        // Code body
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(6)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: _HighlightedCode(code: code),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Syntax-highlighted code widget
// ---------------------------------------------------------------------------

class _HighlightedCode extends StatelessWidget {
  const _HighlightedCode({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: Color(0xFFD4D4D4), // default code text
        ),
        children: _tokenize(code),
      ),
    );
  }

  List<TextSpan> _tokenize(String source) {
    // We walk through the source character-by-character, building spans.
    // Priority order: comments > strings > keywords > semantics identifiers
    //                 > default text.
    final spans = <TextSpan>[];
    int i = 0;

    while (i < source.length) {
      // Single-line comment
      if (i + 1 < source.length &&
          source[i] == '/' &&
          source[i + 1] == '/') {
        final end = source.indexOf('\n', i);
        final text = end == -1 ? source.substring(i) : source.substring(i, end);
        spans.add(TextSpan(
          text: text,
          style: const TextStyle(color: Color(0xFF6A9955)), // grey-green
        ));
        i += text.length;
        continue;
      }

      // String literal (single or double quoted, no escaping handled)
      if (source[i] == '"' || source[i] == "'") {
        final quote = source[i];
        int j = i + 1;
        while (j < source.length && source[j] != quote) {
          if (source[j] == '\\') j++; // skip escaped char
          j++;
        }
        if (j < source.length) j++; // include closing quote
        spans.add(TextSpan(
          text: source.substring(i, j),
          style: const TextStyle(color: Color(0xFF6A9955)), // green
        ));
        i = j;
        continue;
      }

      // Collect a word token to check against keyword/identifier lists
      if (_isIdentStart(source[i])) {
        int j = i;
        while (j < source.length && _isIdentPart(source[j])) {
          j++;
        }
        final word = source.substring(i, j);
        final color = _colorForWord(word);
        spans.add(TextSpan(
          text: word,
          style: color != null ? TextStyle(color: color) : null,
        ));
        i = j;
        continue;
      }

      // Default character
      spans.add(TextSpan(text: source[i]));
      i++;
    }

    return spans;
  }

  bool _isIdentStart(String ch) {
    return RegExp(r'[a-zA-Z_$]').hasMatch(ch);
  }

  bool _isIdentPart(String ch) {
    return RegExp(r'[a-zA-Z0-9_$]').hasMatch(ch);
  }

  Color? _colorForWord(String word) {
    const semanticsIds = {
      'Semantics',
      'MergeSemantics',
      'ExcludeSemantics',
      'SemanticsService',
    };

    const dartKeywords = {
      'class',
      'final',
      'const',
      'return',
      'if',
      'else',
      'void',
      'Widget',
      'override',
      'bool',
      'int',
      'String',
      'true',
      'false',
      'null',
      'this',
      'super',
      'new',
      'import',
      'extends',
      'implements',
      'abstract',
      'static',
      'var',
      'dynamic',
      'late',
      'required',
      'for',
      'while',
      'do',
      'switch',
      'case',
      'break',
      'continue',
      'try',
      'catch',
      'finally',
      'throw',
      'async',
      'await',
      'yield',
      'enum',
      'typedef',
      'mixin',
      'in',
      'is',
      'as',
    };

    if (semanticsIds.contains(word)) {
      return const Color(0xFFCE9178); // orange
    }
    if (dartKeywords.contains(word)) {
      return const Color(0xFF569CD6); // blue
    }
    return null;
  }
}
