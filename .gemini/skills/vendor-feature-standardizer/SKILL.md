---
name: vendor-feature-standardizer
description: Standardized workflow for implementing new Vendor app features. Use to maintain folder structure, security patterns, and error handling consistency.
---

# Vendor Feature Standardizer

Use this skill whenever you are tasked with implementing a new feature in the ChefShip Vendor application to ensure structural integrity and code quality.

## 1. Directory Structure Standards
Always follow the feature-based folder structure:
`lib/features/<feature_name>/`
  - `data/`
    - `models/` (JSON mapping with error handling)
    - `services/` (API calls via `ApiClient`)
  - `presentation/`
    - `providers/` (State management via `ChangeNotifier`)
    - `screens/` (UI components)

## 2. Implementation Protocol

### A. Data Layer
1.  **Models**: Always include `fromJson` factory.
2.  **Services**: Use centralized `ApiClient`. Wrap API calls in `try-catch` blocks and return appropriate defaults (e.g., `[]`, `null`) on error.

### B. UI Layer (Presentation)
1.  **Async Gaps**: ALWAYS add `if (!mounted) return;` immediately after every `await` statement before using `context`.
2.  **Error Handling**: Use `utils.SendError` and related helpers to maintain consistent error messaging.
3.  **Loading State**: Use `CircularProgressIndicator` for full-screen loads and `ShimmerLoading` for skeletons.

## 3. Post-Implementation Checklist
1. Run `flutter analyze` to check for warnings.
2. Fix all `use_build_context_synchronously` issues by adding `if (!mounted) return;`.
3. Ensure imports are clean and relative paths are correct (`../../...`).
