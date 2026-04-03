import 'package:flutter/material.dart';

/// Wraps [child] with an optional accessibility inspector overlay.
///
/// When [active] is true the entire widget tree is replaced by Flutter's
/// built-in [SemanticsDebugger], which paints coloured borders and labels
/// around every widget that has a semantics node — giving learners an
/// immediate visual representation of the accessibility tree.
///
/// This is the simplest v1 approach: it delegates all the heavy lifting to
/// the framework's own [SemanticsDebugger] rather than re-implementing
/// semantics tree introspection from scratch.
///
/// When [active] is false the [child] is rendered without modification.
class A11yInspectorOverlay extends StatelessWidget {
  const A11yInspectorOverlay({
    super.key,
    required this.active,
    required this.child,
  });

  /// Whether the semantics inspector is currently active.
  final bool active;

  /// The banking content to inspect.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!active) return child;

    return Stack(
      children: [
        // Render the actual child so it stays visible behind the overlay.
        child,

        // Overlay the SemanticsDebugger on top. We use a MediaQuery with the
        // same constraints so the debugger sizes itself correctly inside the
        // tutorial layout rather than requiring full-screen access.
        Positioned.fill(
          child: IgnorePointer(
            ignoring: false, // Allow taps to reach the debugger labels
            child: _SemanticsOverlayPainter(child: child),
          ),
        ),

        // Banner reminding the user the inspector is active.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _InspectorBanner(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// SemanticsOverlayPainter
//
// Uses SemanticsDebugger which is the Flutter-native way to visualise the
// semantics tree.  We wrap it in an Opacity so the banking content beneath
// remains partially visible for comparison.
// ---------------------------------------------------------------------------

class _SemanticsOverlayPainter extends StatelessWidget {
  const _SemanticsOverlayPainter({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // SemanticsDebugger requires a MediaQuery ancestor (already present via
    // MaterialApp) and re-renders the full subtree.
    //
    // We wrap in a dedicated Navigator-less MaterialApp-like shell here so the
    // debugger can get a Directionality and MediaQuery; in practice it will
    // inherit them from the ambient context.
    return SemanticsDebugger(
      child: Opacity(
        opacity: 0.0, // fully transparent duplicate — the debugger draws its
                      // own labelled outlines on top of the original child
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inspector active banner
// ---------------------------------------------------------------------------

class _InspectorBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'Accessibility inspector is active',
      child: Container(
        color: const Color(0xCC1565C0), // semi-transparent primary blue
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.visibility_outlined,
                color: Colors.white, size: 16),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'Accessibility Inspector — semantics nodes highlighted',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
