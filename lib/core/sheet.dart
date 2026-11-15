import 'package:flutter/material.dart';
import 'theme.dart';

/// Rounded bottom sheet with a drag handle.
Future<T?> sheet<T>(BuildContext c, Widget child) => showModalBottomSheet<T>(
      context: c,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.88),
        decoration: const BoxDecoration(color: C.cream, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: EdgeInsets.fromLTRB(22, 12, 22, MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 22),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 44, height: 5, margin: const EdgeInsets.only(bottom: 18), decoration: BoxDecoration(color: C.line, borderRadius: BorderRadius.circular(3)))),
            child,
          ]),
        ),
      ),
    );

Future<bool> confirm(BuildContext c, {required String title, required String body, String yes = 'Confirm', String no = 'Cancel', bool danger = false}) async {
  final r = await showDialog<bool>(
    context: c,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
      content: Text(body, style: const TextStyle(color: C.muted, height: 1.4)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(no, style: const TextStyle(color: C.muted, fontWeight: FontWeight.w700))),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(yes, style: TextStyle(color: danger ? C.red : C.orange, fontWeight: FontWeight.w800))),
      ],
    ),
  );
  return r ?? false;
}
