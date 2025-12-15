# Project-Specific Instructions for Claude Code

## Flutter Version Management

This project uses **fvm (Flutter Version Manager)** to ensure consistent Flutter versions across all developers.

### CRITICAL: Always Use fvm Commands

**NEVER** execute Flutter commands directly. **ALWAYS** prefix Flutter commands with `fvm`.

#### Correct Usage ✅
```bash
fvm flutter pub get
fvm flutter run
fvm flutter build
fvm flutter doctor
fvm flutter test
fvm flutter analyze
fvm flutter clean
```

#### Incorrect Usage ❌
```bash
flutter pub get      # DON'T USE
flutter run          # DON'T USE
flutter build        # DON'T USE
```

### Why This Matters

- The project is configured to use **Flutter 3.35.7** (specified in `.fvmrc`)
- Using `flutter` directly uses the global Flutter version (currently 3.22.2), which is outdated
- Using `fvm flutter` ensures you're using the correct project-specific Flutter version
- This prevents version mismatch issues and "works on my machine" problems

### Current Configuration

- **Flutter Version**: 3.35.7 (stable)
- **Dart Version**: 3.9.2
- **Dart SDK Constraint**: ^3.9.0 (pubspec.yaml)
- **fvm Configuration**: .fvmrc

### For New Developers

When setting up this project for the first time:
```bash
fvm use  # Reads .fvmrc and installs/uses the correct Flutter version
fvm flutter pub get
```
