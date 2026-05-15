# Project Engineering Standards

## Flutter & Dart Standards

### Handling BuildContext across Async Gaps
When using `BuildContext` after an `await` expression (e.g., in `onPressed` callbacks), you MUST ensure the context is still valid or avoid using it after the gap.

**Preferred Pattern (Capture before await):**
Capture the necessary objects (like `Navigator` or `ScaffoldMessenger`) *before* the async gap. This is the most reliable way to satisfy the linter and prevent issues.

```dart
onPressed: () async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  
  await someAsyncOperation();
  
  messenger.showSnackBar(...); // Safe
  navigator.pop(); // Safe
}
```

**Alternative Pattern (Guard after await):**
If you must use the context after the gap, always use `if (!context.mounted) return;` immediately before accessing it.

```dart
onPressed: () async {
  await someAsyncOperation();
  if (!context.mounted) return; // Guard against async gap
  ScaffoldMessenger.of(context).showSnackBar(...);
}
```

Reference: [Official Dart Documentation on use_build_context_synchronously](https://dart.dev/tools/diagnostics/use_build_context_synchronously)
