# Clean Architecture Refactoring Plan
## Manga Lounge Membership App

---

## A. CONTEXT

### Project Overview
- **Type**: Flutter mobile app for manga lounge membership management
- **Current State**: MVP/Prototype with ~2,400 lines of Dart code
- **Primary Features**:
  - Phone authentication (Firebase)
  - User profile management
  - Membership QR code generation
  - Check-in/out status tracking

### Motivation for Refactoring
1. **Improve Testability**: Current tight coupling to Firebase makes unit testing nearly impossible
2. **Enhance Maintainability**: Monolithic provider mixing concerns makes changes risky
3. **Enable AI Agent Development**: Clear structure and separation of concerns helps AI agents understand and modify code accurately
4. **Future Scalability**: Prepare for feature expansion without technical debt accumulation

### Key Stakeholders
- Development team (including AI coding agents)
- QA/Testing team
- Future maintainers

---

## B. GOALS

### Primary Objectives
1. ✅ **Separation of Concerns**: Isolate business logic from Firebase SDK, UI, and framework code
2. ✅ **Testability**: Enable unit testing of all business logic without Firebase or Flutter dependencies
3. ✅ **Flexibility**: Allow swapping Firebase for other backends (Supabase, custom API) with minimal changes
4. ✅ **AI-Friendly Structure**: Predictable patterns, small focused files, clear dependencies
5. ✅ **Maintainability**: Single Responsibility Principle - each class/file has one clear purpose

### Secondary Objectives
1. ✅ Consistent navigation using go_router (already a dependency)
2. ✅ Proper error handling with domain-specific failures
3. ✅ Local caching strategy for offline support
4. ✅ Dependency injection for better testability
5. ✅ Clear documentation for AI agents

### Success Metrics
- **Before**: 0% unit test coverage, 100% Firebase coupling
- **After**:
  - 80%+ test coverage on domain layer
  - 60%+ test coverage on data layer
  - 0% Firebase coupling in domain layer
  - All business logic testable without Firebase emulators

---

## C. CURRENT ARCHITECTURE

### High-Level Structure
```
┌─────────────────────────────────────────────────┐
│              UI Screens (Presentation)           │
│  - SplashScreen, PhoneInputScreen, etc.         │
└──────────────────┬──────────────────────────────┘
                   │ context.watch/read
                   ▼
┌─────────────────────────────────────────────────┐
│         AuthProvider (ChangeNotifier)            │
│  - State management                              │
│  - Firebase Auth calls (DIRECT)                  │
│  - Firestore calls (DIRECT)                      │
│  - Business logic mixed in                       │
└──────────────────┬──────────────────────────────┘
                   │ direct calls
                   ▼
┌─────────────────────────────────────────────────┐
│         Firebase SDK (External Service)          │
│  - Firebase Auth                                 │
│  - Cloud Firestore                               │
└─────────────────────────────────────────────────┘
```

### Layer Analysis

**Current Layers** (from outer to inner):
1. **Presentation**: Screens/Widgets
2. **State Management**: AuthProvider (but contains everything!)
3. **External Services**: Firebase (tightly coupled)

**Missing Layers**:
- ❌ Domain layer (business rules, entities, use cases)
- ❌ Data layer abstraction (repositories, data sources)
- ❌ Dependency injection
- ❌ Error handling abstraction

### Dependency Flow
```
Screens → AuthProvider → Firebase
         ↑______________|
         (state updates via notifyListeners)
```

**Problem**: All dependencies point outward to Firebase (violates Dependency Inversion Principle)

---

## D. EXISTING COMPONENTS

### Component Inventory

#### Models (1 file)
- **UserModel** (`models/user_model.dart`)
  - Contains: Firestore serialization logic
  - Problem: Domain entity mixed with data layer concerns
  - Lines: 119

#### Providers (1 file)
- **AuthProvider** (`providers/auth_provider.dart`)
  - Responsibilities: Auth state, Firebase Auth, Firestore CRUD, business logic
  - Problem: God object with 5+ responsibilities
  - Lines: 254

#### Screens (8 files)
- **Auth Flow**: SplashScreen, PhoneInputScreen, OTPVerificationScreen, RegistrationScreen
- **Main App**: HomeScreen, QRCodeScreen, ProfileEditScreen, SettingsScreen
- Problem: Some business logic leaking into screens (validation, navigation logic)
- Total Lines: ~1,800

#### Config (1 file)
- **FirebaseConfig** (`config/firebase_config.dart`)
  - Purpose: Firebase initialization
  - Status: Acceptable, but could be moved to infrastructure layer
  - Lines: 33

#### Utils (2 files)
- **Constants** (`utils/constants.dart`): App-wide constants
- **AppTheme** (`utils/theme.dart`): Material 3 theme configuration
- Status: Acceptable, can remain with minor reorganization

### Dependency Analysis
```yaml
# State Management
provider: ^6.1.1           # ✅ Keep (works well with clean architecture)

# Firebase (currently tightly coupled)
firebase_core: ^3.6.0      # ⚠️ Move to data layer only
firebase_auth: ^5.3.1      # ⚠️ Move to data layer only
cloud_firestore: ^5.4.4    # ⚠️ Move to data layer only

# Navigation (declared but not used!)
go_router: ^13.0.0         # ⚠️ Start using consistently

# UI Components (fine as-is)
qr_flutter, intl_phone_field, pin_code_fields, etc.

# Missing (needed for clean architecture):
# - get_it or injectable (dependency injection)
# - dartz or fpdart (functional error handling)
# - equatable (value equality for entities)
```

---

## E. PROPOSED ARCHITECTURE

### Clean Architecture Layers

Following Uncle Bob's Clean Architecture with Flutter adaptations:

```
┌────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │   Screens    │  │   Widgets    │  │    Providers    │  │
│  │              │  │              │  │ (State Mgmt)    │  │
│  └──────┬───────┘  └──────────────┘  └────────┬────────┘  │
│         │                                      │            │
│         └──────────────┬───────────────────────┘            │
└────────────────────────┼──────────────────────────────────┘
                         │ calls
                         ▼
┌────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER (CORE)                     │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │  Entities  │  │  Use Cases   │  │   Repository     │   │
│  │  (Models)  │  │ (Bus. Logic) │  │   Interfaces     │   │
│  └────────────┘  └──────────────┘  └──────────────────┘   │
│                                                             │
│  Pure Dart - NO Flutter, NO Firebase, NO external deps     │
└────────────────────────┬───────────────────────────────────┘
                         │ implements
                         ▼
┌────────────────────────────────────────────────────────────┐
│                      DATA LAYER                             │
│  ┌─────────────────┐  ┌──────────────────────────────┐    │
│  │  Repository     │  │      Data Sources            │    │
│  │  Implementations│  │  - Remote (Firebase)         │    │
│  │                 │  │  - Local (Cache/SharedPrefs) │    │
│  └─────────────────┘  └──────────────────────────────┘    │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐                         │
│  │   Models    │  │   Mappers   │                         │
│  │   (DTOs)    │  │ (DTO↔Entity)│                         │
│  └─────────────┘  └─────────────┘                         │
└────────────────────────┬───────────────────────────────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │   External Services   │
              │  - Firebase Auth      │
              │  - Cloud Firestore    │
              └──────────────────────┘
```

### Dependency Rule
**Critical**: Dependencies ONLY point inward
- Presentation depends on Domain
- Data depends on Domain
- Domain depends on NOTHING (pure Dart)

### Proposed Folder Structure

```
lib/
├── core/                                 # Shared across all features
│   ├── error/
│   │   ├── failures.dart                # Abstract Failure classes
│   │   └── exceptions.dart              # Concrete exceptions (ServerException, etc.)
│   ├── usecases/
│   │   └── usecase.dart                 # Base UseCase<Type, Params> class
│   ├── utils/
│   │   ├── constants.dart               # App-wide constants (moved from utils/)
│   │   └── validators.dart              # Shared validation logic
│   └── network/
│       └── network_info.dart            # Connectivity checker (for offline support)
│
├── features/                             # Feature-based organization
│   │
│   ├── authentication/                   # Feature 1: Authentication
│   │   │
│   │   ├── domain/                      # Pure business logic (no dependencies)
│   │   │   ├── entities/
│   │   │   │   └── auth_user.dart       # Pure Dart class (uid, phoneNumber)
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart # Abstract interface (contract)
│   │   │   └── usecases/
│   │   │       ├── send_otp.dart        # Use case: SendOTP
│   │   │       ├── verify_otp.dart      # Use case: VerifyOTP
│   │   │       ├── sign_out.dart        # Use case: SignOut
│   │   │       └── get_auth_state.dart  # Use case: GetAuthState (stream)
│   │   │
│   │   ├── data/                        # Data access implementation
│   │   │   ├── models/
│   │   │   │   └── auth_user_model.dart # Extends AuthUser entity, adds fromJson/toJson
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart       # Abstract interface
│   │   │   │   └── firebase_auth_remote_datasource.dart  # Firebase implementation
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart # Implements AuthRepository interface
│   │   │
│   │   └── presentation/                # UI and state management
│   │       ├── providers/
│   │       │   └── auth_provider.dart   # Calls use cases, manages UI state
│   │       ├── screens/
│   │       │   ├── splash_screen.dart
│   │       │   ├── phone_input_screen.dart
│   │       │   ├── otp_verification_screen.dart
│   │       │   └── registration_screen.dart
│   │       └── widgets/                 # Reusable widgets for this feature
│   │           └── (feature-specific widgets)
│   │
│   └── user_profile/                     # Feature 2: User Profile
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   └── user.dart            # Pure User entity (business rules)
│       │   ├── repositories/
│       │   │   └── user_repository.dart # Abstract interface
│       │   └── usecases/
│       │       ├── create_user_profile.dart
│       │       ├── get_user_profile.dart
│       │       ├── update_user_profile.dart
│       │       ├── check_profile_exists.dart
│       │       └── validate_user_age.dart   # Business rule: age >= 13
│       │
│       ├── data/
│       │   ├── models/
│       │   │   └── user_model.dart      # DTO with Firestore serialization
│       │   ├── datasources/
│       │   │   ├── user_remote_datasource.dart      # Abstract
│       │   │   ├── firestore_user_remote_datasource.dart
│       │   │   ├── user_local_datasource.dart       # Abstract
│       │   │   └── shared_prefs_user_local_datasource.dart
│       │   └── repositories/
│       │       └── user_repository_impl.dart
│       │
│       └── presentation/
│           ├── providers/
│           │   └── user_provider.dart
│           ├── screens/
│           │   ├── home_screen.dart
│           │   ├── profile_edit_screen.dart
│           │   ├── qr_code_screen.dart
│           │   └── settings_screen.dart
│           └── widgets/
│               ├── membership_card.dart
│               └── profile_form_fields.dart
│
├── config/                               # App-wide configuration
│   ├── routes/
│   │   ├── app_router.dart              # go_router configuration
│   │   └── route_names.dart             # Centralized route constants
│   ├── theme/
│   │   └── app_theme.dart               # Moved from utils/
│   └── di/
│       └── injection_container.dart     # Dependency injection setup (get_it)
│
└── main.dart                             # Entry point
```

### Key Architectural Decisions

#### 1. Use Cases (Application Layer)
**Why**: Encapsulate business logic in reusable, testable units

**Example**:
```dart
// domain/usecases/send_otp.dart
class SendOTP extends UseCase<void, SendOTPParams> {
  final AuthRepository repository;

  SendOTP(this.repository);

  @override
  Future<Either<Failure, void>> call(SendOTPParams params) async {
    // Business rule: Phone must be E.164 format
    if (!_isValidE164(params.phoneNumber)) {
      return Left(InvalidPhoneNumberFailure());
    }

    return await repository.sendOTP(params.phoneNumber);
  }
}
```

**Benefits for AI Agents**:
- Clear input (params) and output (Either<Failure, Result>)
- Single file per use case = easy to locate and modify
- No dependencies on Firebase = can mock for testing

#### 2. Repository Pattern
**Why**: Abstract data sources behind interfaces

**Example**:
```dart
// domain/repositories/auth_repository.dart (INTERFACE)
abstract class AuthRepository {
  Future<Either<Failure, void>> sendOTP(String phoneNumber);
  Future<Either<Failure, AuthUser>> verifyOTP(String verificationId, String otpCode);
  Future<Either<Failure, void>> signOut();
  Stream<AuthUser?> getAuthStateChanges();
}

// data/repositories/auth_repository_impl.dart (IMPLEMENTATION)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> sendOTP(String phoneNumber) async {
    try {
      await remoteDataSource.sendOTP(phoneNumber);
      return Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
  // ... other methods
}
```

**Benefits for AI Agents**:
- Interface in domain = clear contract to implement
- Can swap Firebase for mock in tests
- Easy to add caching: check local first, then remote

#### 3. Entities vs Models (DTOs)
**Why**: Separate business logic from data serialization

**Example**:
```dart
// domain/entities/user.dart (PURE DART)
class User {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final Gender gender;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final CheckInStatus status;

  User({required this.uid, ...});

  // Business logic methods
  String get fullName => '$firstName $lastName';
  bool get isCheckedIn => status == CheckInStatus.checkedIn;
  bool get isAdult => _calculateAge() >= 18;

  int _calculateAge() {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}

// data/models/user_model.dart (DTO)
class UserModel extends User {
  UserModel({required super.uid, ...});

  // Firestore-specific serialization
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      firstName: data['firstName'],
      // ... Firestore-specific parsing
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      // ... Firestore-specific serialization
    };
  }
}
```

**Benefits for AI Agents**:
- Entity contains business rules (easy to test with pure Dart)
- Model handles serialization (can change without affecting business logic)
- Clear separation: domain/entities/ vs data/models/

#### 4. Dependency Injection (get_it)
**Why**: Control dependencies from one place, easy to swap for tests

**Example**:
```dart
// config/di/injection_container.dart
final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  //! Features - Authentication
  // Providers
  sl.registerFactory(() => AuthProvider(
    sendOTP: sl(),
    verifyOTP: sl(),
    signOut: sl(),
    getAuthState: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => SendOTP(sl()));
  sl.registerLazySingleton(() => VerifyOTP(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetAuthState(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => FirebaseAuthRemoteDataSource(firebaseAuth: sl()),
  );

  //! External
  final firebaseAuth = FirebaseAuth.instance;
  sl.registerLazySingleton(() => firebaseAuth);
}
```

**Benefits for AI Agents**:
- Single file shows all dependencies
- Easy to see what depends on what
- Can create test_injection_container.dart with mocks

#### 5. Error Handling with Either<Failure, Success>
**Why**: Explicit error handling, no throwing exceptions in business logic

**Example**:
```dart
// core/error/failures.dart
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure() : super('Server error occurred');
}

class InvalidPhoneNumberFailure extends Failure {
  InvalidPhoneNumberFailure() : super('Invalid phone number format');
}

// Usage in UI
final result = await sendOTP(phoneNumber);
result.fold(
  (failure) => _showError(failure.message),  // Left = error
  (_) => _navigateToOTP(),                    // Right = success
);
```

**Benefits for AI Agents**:
- Errors are values, not exceptions (easier to track)
- Type-safe: must handle both cases
- Clear what can go wrong

---

## F. IMPACTED AREAS

### High-Impact Changes (Requires Significant Refactoring)

#### 1. AuthProvider (providers/auth_provider.dart)
**Current State**: 254 lines, 10+ responsibilities
**Impact**: 🔴 HIGH
**Changes Required**:
- Extract Firebase Auth calls → AuthRemoteDataSource
- Extract Firestore calls → UserRemoteDataSource (different feature!)
- Extract business logic → Use cases
- Reduce to only UI state management
- Call use cases instead of Firebase directly

**After Refactoring**:
```dart
class AuthProvider extends ChangeNotifier {
  final SendOTP sendOTP;
  final VerifyOTP verifyOTP;
  final SignOut signOut;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> sendOTPCode(String phoneNumber) async {
    _setLoading(true);
    final result = await sendOTP(SendOTPParams(phoneNumber));
    result.fold(
      (failure) => _setError(failure.message),
      (_) => _setError(null),
    );
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
}
```

**Lines Reduction**: 254 → ~80 (70% reduction)

#### 2. UserModel (models/user_model.dart)
**Current State**: 119 lines, mixed entity + DTO concerns
**Impact**: 🟡 MEDIUM
**Changes Required**:
- Split into User entity (domain) and UserModel DTO (data)
- Move business logic methods to entity
- Keep serialization in model
- Move to feature-based folders

**Migration**:
```
Before: lib/models/user_model.dart
After:  lib/features/user_profile/domain/entities/user.dart (business logic)
        lib/features/user_profile/data/models/user_model.dart (serialization)
```

#### 3. All Screens (8 files)
**Current State**: Mixed concerns, some business logic
**Impact**: 🟡 MEDIUM per screen
**Changes Required**:
- Update provider dependencies (use feature-specific providers)
- Replace direct Firebase errors with Failure handling
- Move to feature-based folders
- Extract reusable widgets

**Example Migration**:
```
Before: lib/screens/auth/phone_input_screen.dart
After:  lib/features/authentication/presentation/screens/phone_input_screen.dart
```

#### 4. Navigation (All screens + main.dart)
**Current State**: Mixed named routes + MaterialPageRoute
**Impact**: 🟡 MEDIUM
**Changes Required**:
- Implement go_router configuration
- Define route paths and navigation logic
- Update all Navigator.push calls to context.go()
- Add type-safe route parameters

#### 5. Firebase Config (config/firebase_config.dart)
**Current State**: Standalone config file
**Impact**: 🟢 LOW
**Changes Required**:
- Move to config/di/ or keep as-is
- Ensure called before DI setup in main.dart

### Low-Impact Changes (Mostly Moving Files)

#### 6. Constants & Theme (utils/)
**Impact**: 🟢 LOW
**Changes Required**:
- Move constants.dart → core/utils/constants.dart
- Move theme.dart → config/theme/app_theme.dart
- Update imports across project

#### 7. main.dart
**Impact**: 🟡 MEDIUM
**Changes Required**:
- Call DI initialization before runApp
- Replace MultiProvider with DI-based providers
- Set up go_router instead of named routes

**New Structure**:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
  await initDependencies();  // NEW: Dependency injection
  runApp(const MangaLoungeApp());
}
```

### Files Created (New)

**Total New Files**: ~35 files

| Category | Count | Examples |
|----------|-------|----------|
| Domain entities | 2 | auth_user.dart, user.dart |
| Repository interfaces | 2 | auth_repository.dart, user_repository.dart |
| Use cases | 9 | send_otp.dart, verify_otp.dart, create_user_profile.dart, etc. |
| Data sources (interfaces) | 4 | auth_remote_datasource.dart, user_remote/local_datasource.dart |
| Data sources (implementations) | 4 | firebase_auth_remote_datasource.dart, etc. |
| Repository implementations | 2 | auth_repository_impl.dart, user_repository_impl.dart |
| Models (DTOs) | 2 | auth_user_model.dart, user_model.dart |
| Core utilities | 4 | failures.dart, exceptions.dart, usecase.dart, validators.dart |
| Config | 3 | injection_container.dart, app_router.dart, route_names.dart |
| Providers (refactored) | 2 | auth_provider.dart, user_provider.dart |

### Files Modified (Existing)

**Total Modified Files**: ~14 files (all screens + main.dart + tests)

### Files Deleted

**Total Deleted**: 3 files
- `lib/models/user_model.dart` (split into entity + model)
- `lib/providers/auth_provider.dart` (moved to feature folder)
- `lib/utils/constants.dart`, `lib/utils/theme.dart` (moved to config/)

### Import Changes

**All files will need import updates** (automated with IDE refactoring)

**Before**:
```dart
import 'package:manga_lounge/models/user_model.dart';
import 'package:manga_lounge/providers/auth_provider.dart';
```

**After**:
```dart
import 'package:manga_lounge/features/user_profile/domain/entities/user.dart';
import 'package:manga_lounge/features/authentication/presentation/providers/auth_provider.dart';
```

---

## G. PITFALLS & RISK MITIGATION

### Critical Pitfalls to Avoid

#### 1. ⚠️ Over-Engineering (YAGNI Violation)
**Risk**: Creating abstractions we don't need yet

**Examples of Over-Engineering**:
- Creating multiple data source implementations when we only use Firebase
- Building complex caching strategies before we have offline requirements
- Adding analytics, logging, monitoring before core features work
- Creating abstract factories for simple object creation

**Mitigation**:
✅ Start with minimal clean architecture (repository + use cases)
✅ Add complexity only when requirements demand it
✅ Follow principle: "Make it work, make it right, make it fast" (in that order)
✅ Keep use cases simple - no chaining, no complex state machines

**Decision Point**:
- ✅ DO: Create repository interfaces (we know we'll test this)
- ❌ DON'T: Create repository factories (only one implementation needed now)

#### 2. ⚠️ Breaking Changes During Migration
**Risk**: App becomes non-functional mid-refactoring

**Scenarios**:
- Refactoring AuthProvider breaks all screens
- Moving files breaks import chains
- Changing state management breaks widget trees

**Mitigation**:
✅ **Incremental Migration**: Refactor one feature at a time
✅ **Feature Flags**: Use conditional logic to run old vs new code paths
✅ **Parallel Implementation**: Build new structure alongside old, then swap

**Strategy - Strangler Fig Pattern**:
```dart
// Step 1: Create new repository alongside old provider
class AuthRepositoryImpl implements AuthRepository { ... }

// Step 2: AuthProvider uses BOTH old Firebase and new repository
class AuthProvider {
  final AuthRepository _newRepo;  // NEW
  final FirebaseAuth _oldAuth;    // OLD (deprecated)

  Future<void> sendOTP(String phone) async {
    // TODO: Remove when migration complete
    if (useNewArchitecture) {
      await _newRepo.sendOTP(phone);
    } else {
      await _oldAuth.verifyPhoneNumber(...); // OLD PATH
    }
  }
}

// Step 3: After testing, remove old code path
```

#### 3. ⚠️ Dependency Injection Complexity
**Risk**: DI setup becomes hard to maintain, circular dependencies

**Scenarios**:
- Forgetting to register a dependency (runtime crash)
- Creating circular dependencies (A needs B, B needs A)
- Registration order matters but isn't obvious

**Mitigation**:
✅ **Clear Registration Order**: External → Data → Domain → Presentation
✅ **Type Safety**: Use `registerLazySingleton<Interface>(() => Implementation())`
✅ **Validate on Startup**: Call `sl.get<ImportantService>()` in main.dart to fail fast
✅ **Documentation**: Comment why each dependency is registered

**Example**:
```dart
Future<void> init() async {
  //! External (no dependencies)
  final firebaseAuth = FirebaseAuth.instance;
  sl.registerLazySingleton(() => firebaseAuth);

  //! Data (depends on External)
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => FirebaseAuthRemoteDataSource(firebaseAuth: sl()),
  );

  //! Domain (depends on Data)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // NEVER: Circular dependency
  // sl.registerLazySingleton(() => ServiceA(serviceB: sl()));
  // sl.registerLazySingleton(() => ServiceB(serviceA: sl())); // ❌ CRASH
}
```

#### 4. ⚠️ Testing Complexity Increase
**Risk**: Writing tests becomes harder, not easier

**Scenarios**:
- Too many layers = too many mocks needed
- Use cases are hard to test because they depend on repositories
- Widget tests break because of DI changes

**Mitigation**:
✅ **Start with Domain Tests**: Easiest to test (pure Dart)
✅ **Mock at Repository Level**: Don't mock data sources in use case tests
✅ **Use mocktail**: Null-safe mocking library
✅ **Test Helpers**: Create shared mock factories

**Example Test Structure**:
```dart
// Good: Test use case with mocked repository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SendOTP usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = SendOTP(mockRepository);
  });

  test('should call repository with correct phone number', () async {
    // Arrange
    when(() => mockRepository.sendOTP(any()))
        .thenAnswer((_) async => Right(null));

    // Act
    await usecase(SendOTPParams('+1234567890'));

    // Assert
    verify(() => mockRepository.sendOTP('+1234567890')).called(1);
  });
}
```

#### 5. ⚠️ State Management Confusion
**Risk**: Mixing Provider patterns with DI, unclear state ownership

**Scenarios**:
- Provider gets dependencies from DI but also creates its own
- Multiple providers for same feature with unclear responsibility
- State not properly reset between screens

**Mitigation**:
✅ **Clear Rule**: Providers are ONLY for UI state (loading, error, etc.)
✅ **Use Cases for Logic**: All business logic in use cases, not providers
✅ **One Provider per Feature**: AuthProvider, UserProfileProvider (not split further)
✅ **DI for Dependencies**: Provider gets use cases from DI, never creates them

**Example Anti-Pattern** (DON'T DO):
```dart
// ❌ BAD: Provider creates its own repository
class AuthProvider {
  final repository = AuthRepositoryImpl(
    FirebaseAuthRemoteDataSource(FirebaseAuth.instance),
  );
}

// ✅ GOOD: Provider receives dependencies
class AuthProvider {
  final SendOTP sendOTP;
  final VerifyOTP verifyOTP;

  AuthProvider({required this.sendOTP, required this.verifyOTP});
}
```

#### 6. ⚠️ Navigation Migration Breaks Flow
**Risk**: Moving to go_router breaks authentication flow, deep links

**Scenarios**:
- SplashScreen can't redirect to /home with auth state
- OTP screen can't pass verificationId to registration
- Back button behavior changes unexpectedly

**Mitigation**:
✅ **Migrate Navigation Last**: Get architecture working first
✅ **Test All Flows**: Auth flow, profile edit flow, settings flow
✅ **Use Redirect Logic**: go_router supports auth-based redirects
✅ **Type-Safe Routes**: Define route parameters explicitly

**Example go_router Setup**:
```dart
final router = GoRouter(
  redirect: (context, state) {
    final isAuthenticated = sl<GetAuthState>().isAuthenticated;
    final isOnAuthPage = state.matchedLocation.startsWith('/auth');

    if (!isAuthenticated && !isOnAuthPage) {
      return '/auth/phone-input';
    }
    if (isAuthenticated && isOnAuthPage) {
      return '/home';
    }
    return null; // No redirect
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth/phone-input',
      builder: (context, state) => const PhoneInputScreen(),
    ),
    // ... etc
  ],
);
```

#### 7. ⚠️ Data Layer Complexity
**Risk**: Models, DTOs, Entities, Mappers become confusing

**Scenarios**:
- When to use User vs UserModel vs UserEntity?
- Forgetting to map from DTO to Entity (runtime errors)
- Duplicating fields across entity and model

**Mitigation**:
✅ **Clear Naming Convention**:
  - `User` (domain entity) - business logic
  - `UserModel` (data model) - extends User, adds serialization
✅ **Mapper Functions**: Explicit conversion functions
✅ **Documentation**: Comment why each class exists

**Example**:
```dart
// Domain: Pure business logic
class User {
  final String uid;
  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName';
}

// Data: Extends domain, adds Firestore serialization
class UserModel extends User {
  UserModel({
    required super.uid,
    required super.firstName,
    required super.lastName,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
```

#### 8. ⚠️ Firebase-Specific Challenges
**Risk**: Firebase's realtime nature conflicts with repository pattern

**Scenarios**:
- AuthStateChanges is a Stream, not a Future (how to return Either?)
- Firestore snapshots are realtime (how to cache?)
- Firebase errors are specific (FirebaseAuthException) but we return generic Failures

**Mitigation**:
✅ **Streams in Repositories**: Return `Stream<Either<Failure, T>>` for realtime data
✅ **Error Mapping**: Catch Firebase exceptions, map to domain Failures
✅ **Cache Streams**: Use rxdart or StreamController for caching

**Example**:
```dart
abstract class AuthRepository {
  // Streams for realtime data
  Stream<Either<Failure, AuthUser?>> watchAuthState();

  // Futures for one-time operations
  Future<Either<Failure, void>> sendOTP(String phoneNumber);
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  @override
  Stream<Either<Failure, AuthUser?>> watchAuthState() {
    try {
      return _firebaseAuth.authStateChanges().map((firebaseUser) {
        if (firebaseUser == null) return Right(null);
        return Right(AuthUserModel.fromFirebaseUser(firebaseUser));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure()));
    }
  }

  @override
  Future<Either<Failure, void>> sendOTP(String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) {},
        verificationFailed: (e) => throw e,
        codeSent: (verificationId, resendToken) {},
        codeAutoRetrievalTimeout: (verificationId) {},
      );
      return Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseError(e));
    }
  }

  Failure _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return InvalidPhoneNumberFailure();
      case 'too-many-requests':
        return TooManyRequestsFailure();
      default:
        return ServerFailure(e.message);
    }
  }
}
```

#### 9. ⚠️ AI Agent Confusion
**Risk**: Folder structure too complex, AI agents can't find files

**Scenarios**:
- "Where is the user profile update logic?" (could be in use case, repository, data source)
- Too many files with similar names (user.dart, user_model.dart, user_repository.dart)
- Unclear which file to modify for a feature change

**Mitigation**:
✅ **Clear File Naming**: `<feature>_<type>.dart` (e.g., `send_otp_usecase.dart`)
✅ **README per Feature**: Document architecture in each feature folder
✅ **Consistent Patterns**: Every feature follows same structure
✅ **File Headers**: Comments explaining purpose

**Example Feature README**:
```markdown
# Authentication Feature

## Structure
- `domain/entities/auth_user.dart` - User identity entity (uid, phoneNumber)
- `domain/repositories/auth_repository.dart` - Contract for authentication operations
- `domain/usecases/send_otp.dart` - Send OTP code via SMS
- `domain/usecases/verify_otp.dart` - Verify OTP code and sign in
- `data/models/auth_user_model.dart` - Firebase serialization of AuthUser
- `data/datasources/firebase_auth_remote_datasource.dart` - Firebase Auth SDK wrapper
- `data/repositories/auth_repository_impl.dart` - Implementation of AuthRepository
- `presentation/providers/auth_provider.dart` - UI state for authentication screens
- `presentation/screens/` - UI screens for authentication flow

## To modify authentication logic:
1. Change business rules: Edit use cases in `domain/usecases/`
2. Change Firebase calls: Edit `data/datasources/firebase_auth_remote_datasource.dart`
3. Change UI state: Edit `presentation/providers/auth_provider.dart`
4. Change UI: Edit screens in `presentation/screens/`
```

#### 10. ⚠️ pubspec.yaml Dependency Issues
**Risk**: New packages conflict, version constraints break

**Scenarios**:
- Adding `get_it` conflicts with `provider`
- Adding `dartz` or `fpdart` increases bundle size significantly
- Dart SDK version conflicts (3.9.2 vs 3.10.0 issue already present!)

**Mitigation**:
✅ **Resolve Dart SDK First**: Update pubspec.yaml to `sdk: '>=3.9.0 <4.0.0'`
✅ **Minimal Dependencies**: Only add what's necessary
✅ **Test After Each Addition**: Run `fvm flutter pub get` and `fvm flutter run`
✅ **Version Constraints**: Use compatible versions

**Required New Dependencies**:
```yaml
dependencies:
  get_it: ^8.0.0          # Dependency injection (~30 KB)
  dartz: ^0.10.1          # Functional programming (Either) (~100 KB)
  equatable: ^2.0.5       # Value equality for entities (~20 KB)

dev_dependencies:
  mocktail: ^1.0.0        # Mocking for tests
```

**Note**: Total size increase ~150 KB (acceptable for benefits gained)

---

## H. MIGRATION STRATEGY

### Phase-by-Phase Plan

#### Phase 0: Preparation (1 day)
**Goal**: Set up foundation without breaking existing code

**Tasks**:
1. ✅ Fix Dart SDK version constraint in pubspec.yaml
2. ✅ Add new dependencies (get_it, dartz, equatable, mocktail)
3. ✅ Create folder structure (empty folders for now)
4. ✅ Create base classes:
   - `core/usecases/usecase.dart`
   - `core/error/failures.dart`
   - `core/error/exceptions.dart`
5. ✅ Run `fvm flutter pub get` and verify app still runs
6. ✅ Commit: "chore: prepare for clean architecture migration"

**Success Criteria**: App runs without changes to existing code

---

#### Phase 1: User Profile Feature (3-4 days)
**Goal**: Migrate user profile to clean architecture (easier than auth)

**Why User Profile First?**
- Simpler than authentication (no complex Firebase callbacks)
- CRUD operations are straightforward
- Less risk of breaking auth flow

**Tasks**:

**Day 1: Domain Layer**
1. Create `features/user_profile/domain/entities/user.dart` (from existing UserModel)
2. Create `features/user_profile/domain/repositories/user_repository.dart` (interface)
3. Create use cases:
   - `get_user_profile.dart`
   - `create_user_profile.dart`
   - `update_user_profile.dart`
   - `check_profile_exists.dart`
4. Write unit tests for use cases
5. Commit: "feat(user_profile): add domain layer"

**Day 2: Data Layer**
1. Create `features/user_profile/data/models/user_model.dart` (extends User entity)
2. Create `features/user_profile/data/datasources/user_remote_datasource.dart` (interface)
3. Create `features/user_profile/data/datasources/firestore_user_remote_datasource.dart` (implementation)
4. Create `features/user_profile/data/repositories/user_repository_impl.dart`
5. Write tests for data layer
6. Commit: "feat(user_profile): add data layer"

**Day 3: Presentation Layer**
1. Set up dependency injection for user profile feature
2. Create `features/user_profile/presentation/providers/user_provider.dart` (calls use cases)
3. Update existing screens to use new provider:
   - HomeScreen
   - ProfileEditScreen
   - QRCodeScreen
4. Test manually - all features should work
5. Commit: "feat(user_profile): migrate to clean architecture"

**Day 4: Cleanup & Testing**
1. Delete old `lib/models/user_model.dart`
2. Remove user profile logic from old AuthProvider (if any)
3. Write widget tests for updated screens
4. Update documentation
5. Commit: "feat(user_profile): complete migration and cleanup"

**Success Criteria**:
- User profile CRUD works
- Tests pass
- No dependency on old structure

---

#### Phase 2: Authentication Feature (4-5 days)
**Goal**: Migrate authentication to clean architecture

**Why Second?**
- More complex (Firebase phone auth has callbacks)
- Critical flow - higher risk
- Depends on understanding from Phase 1

**Tasks**:

**Day 1: Domain Layer**
1. Create `features/authentication/domain/entities/auth_user.dart`
2. Create `features/authentication/domain/repositories/auth_repository.dart` (interface)
3. Create use cases:
   - `send_otp.dart`
   - `verify_otp.dart`
   - `sign_out.dart`
   - `get_auth_state.dart` (stream-based)
4. Write unit tests
5. Commit: "feat(auth): add domain layer"

**Day 2-3: Data Layer**
1. Create `features/authentication/data/models/auth_user_model.dart`
2. Create `features/authentication/data/datasources/auth_remote_datasource.dart` (interface)
3. Create `features/authentication/data/datasources/firebase_auth_remote_datasource.dart`
   - Handle verificationCompleted callback
   - Handle verificationFailed callback
   - Handle codeSent callback
   - Store verificationId for later use
4. Create `features/authentication/data/repositories/auth_repository_impl.dart`
5. Map Firebase exceptions to domain Failures
6. Write tests
7. Commit: "feat(auth): add data layer"

**Day 4: Presentation Layer**
1. Set up DI for authentication feature
2. Create new `features/authentication/presentation/providers/auth_provider.dart`
3. Keep old AuthProvider temporarily (parallel implementation)
4. Add feature flag: `const useNewAuth = true;`
5. Update screens to use new provider when flag is true:
   - SplashScreen
   - PhoneInputScreen
   - OTPVerificationScreen
   - RegistrationScreen
6. Test manually with flag = true
7. Commit: "feat(auth): add new presentation layer (parallel)"

**Day 5: Cutover & Cleanup**
1. Remove feature flag, use new auth everywhere
2. Delete old `lib/providers/auth_provider.dart`
3. Test entire auth flow thoroughly
4. Write widget tests
5. Commit: "feat(auth): complete migration and cleanup"

**Success Criteria**:
- Phone auth works end-to-end
- OTP verification works
- Sign out works
- Tests pass

---

#### Phase 3: Dependency Injection (1 day)
**Goal**: Centralize all dependencies

**Tasks**:
1. Create `config/di/injection_container.dart`
2. Register all dependencies (in order):
   - External (Firebase instances)
   - Data sources
   - Repositories
   - Use cases
   - Providers
3. Update `main.dart` to call `initDependencies()`
4. Update all screens to get providers from DI instead of MultiProvider
5. Test entire app
6. Commit: "feat: centralize dependency injection"

**Success Criteria**:
- All dependencies managed from one place
- App initializes correctly
- No runtime DI errors

---

#### Phase 4: Navigation (2 days)
**Goal**: Migrate to go_router

**Tasks**:

**Day 1: Setup go_router**
1. Create `config/routes/app_router.dart`
2. Create `config/routes/route_names.dart` (constants)
3. Define all routes with type-safe parameters
4. Add auth redirect logic (splash screen logic)
5. Update `main.dart` to use go_router
6. Commit: "feat: add go_router configuration"

**Day 2: Update Screens**
1. Replace all `Navigator.pushNamed` with `context.go()`
2. Replace all `Navigator.push(MaterialPageRoute(...))` with `context.push()`
3. Update parameter passing to use go_router extras
4. Test all navigation flows
5. Remove old named routes from main.dart
6. Commit: "feat: migrate all screens to go_router"

**Success Criteria**:
- All navigation uses go_router
- Deep links work (if applicable)
- Back button behavior is correct

---

#### Phase 5: Error Handling & Polish (1-2 days)
**Goal**: Improve error handling, add logging

**Tasks**:
1. Ensure all use cases return `Either<Failure, Success>`
2. Update all screens to handle Failure objects
3. Create user-friendly error messages
4. Add error logging (Firebase Crashlytics or Sentry)
5. Test error scenarios:
   - Network errors
   - Invalid phone numbers
   - OTP timeout
   - Firestore errors
6. Commit: "feat: improve error handling"

**Success Criteria**:
- All errors handled gracefully
- User sees helpful messages
- Errors logged for debugging

---

#### Phase 6: Testing & Documentation (2-3 days)
**Goal**: Comprehensive testing and documentation

**Tasks**:
1. Write unit tests for all use cases (target: 100% coverage)
2. Write unit tests for repositories (target: 80% coverage)
3. Write widget tests for critical screens
4. Create feature READMEs:
   - `features/authentication/README.md`
   - `features/user_profile/README.md`
5. Update main README with architecture diagram
6. Create architecture decision record (ADR)
7. Commit: "docs: add comprehensive documentation and tests"

**Success Criteria**:
- Test coverage > 70% overall
- Documentation explains architecture clearly
- AI agents can understand structure

---

### Total Timeline Estimate
**14-18 days** (accounting for testing and unexpected issues)

### Rollback Plan
If migration fails at any phase:
1. Revert to last stable commit
2. Feature flags allow running old code
3. No changes to database schema (safe to rollback)

---

## I. SUCCESS METRICS & VALIDATION

### Quantitative Metrics

**Before Refactoring**:
- Lines of code: ~2,400
- Files: 14 Dart files
- Test coverage: ~0%
- Firebase coupling: 100% (direct calls everywhere)
- Average file size: 171 lines
- God objects: 1 (AuthProvider with 254 lines, 10+ responsibilities)

**After Refactoring Targets**:
- Lines of code: ~3,500-4,000 (40-60% increase, but better organized)
- Files: ~50 Dart files
- Test coverage: >70% overall, >90% domain layer
- Firebase coupling: 0% in domain layer
- Average file size: <100 lines (more focused files)
- God objects: 0 (max 3 responsibilities per class)

### Qualitative Validation

**Architecture Quality**:
- ✅ Domain layer has zero Flutter/Firebase dependencies
- ✅ Use cases can be tested with pure Dart
- ✅ Repositories can be mocked for testing
- ✅ UI state management separated from business logic
- ✅ Feature folders are self-contained

**Developer Experience**:
- ✅ New features follow clear pattern
- ✅ AI agents can locate relevant files quickly
- ✅ Changes to Firebase don't affect business logic
- ✅ Tests run fast (no Firebase emulators needed for domain tests)

**Code Maintainability**:
- ✅ Each file has single clear purpose
- ✅ Dependencies flow inward (Dependency Inversion Principle)
- ✅ Business rules are explicit in use cases
- ✅ Error handling is type-safe

### Testing Checklist

**Phase-by-Phase Validation**:

After Phase 1 (User Profile):
- [ ] Can create user profile
- [ ] Can update user profile
- [ ] Can view user profile
- [ ] Domain tests pass
- [ ] Data layer tests pass

After Phase 2 (Authentication):
- [ ] Can send OTP
- [ ] Can verify OTP
- [ ] Can sign out
- [ ] Auth state changes trigger UI updates
- [ ] Domain tests pass
- [ ] Data layer tests pass

After Phase 3 (DI):
- [ ] App initializes without errors
- [ ] All dependencies resolve correctly
- [ ] Can swap implementations for testing

After Phase 4 (Navigation):
- [ ] All screens accessible via routes
- [ ] Auth redirects work
- [ ] Deep links work (if applicable)

After Phase 5 (Error Handling):
- [ ] Network errors show user-friendly messages
- [ ] Firebase errors mapped to domain failures
- [ ] Errors logged for debugging

After Phase 6 (Testing):
- [ ] Domain layer >90% coverage
- [ ] Data layer >70% coverage
- [ ] Critical user flows have widget tests

---

## J. NEXT STEPS

### Immediate Actions (Before Starting Refactoring)

1. **Get Approval**: Review this plan with team, adjust based on feedback
2. **Set Up Branch**: Create `refactor/clean-architecture` branch
3. **Fix Dart SDK**: Resolve version mismatch (3.9.2 vs 3.10.0)
4. **Backup**: Ensure all code committed and pushed

### Phase 0 Kickoff (When Approved)

**Command to run**:
```bash
# Fix Dart SDK version
# Update pubspec.yaml sdk constraint to: '>=3.9.0 <4.0.0'

# Add dependencies
fvm flutter pub add get_it dartz equatable
fvm flutter pub add --dev mocktail

# Create base folder structure
mkdir -p lib/core/{error,usecases,utils,network}
mkdir -p lib/features/authentication/{domain/{entities,repositories,usecases},data/{models,datasources,repositories},presentation/{providers,screens,widgets}}
mkdir -p lib/features/user_profile/{domain/{entities,repositories,usecases},data/{models,datasources,repositories},presentation/{providers,screens,widgets}}
mkdir -p lib/config/{routes,theme,di}

# Verify app still runs
fvm flutter run
```

### Decision Points

**After Phase 1**: Review test coverage and code quality before proceeding
**After Phase 2**: Validate authentication flow thoroughly before moving DI
**After Phase 4**: Consider if navigation is working well before error handling

### Long-Term Vision (Post-Refactoring)

**Future Enhancements Enabled by Clean Architecture**:
1. Offline-first mode (local data sources already abstracted)
2. Backend swap (Firebase → Supabase/Custom API)
3. Multi-platform (Web, Desktop) - business logic is framework-agnostic
4. Advanced testing (integration tests, e2e tests)
5. Feature flags and A/B testing
6. Analytics and monitoring
7. i18n/l10n (internationalization)

---

## K. CONCLUSION

This refactoring plan transforms the Manga Lounge app from a simple MVP to a production-ready architecture following clean architecture principles. The migration is incremental, low-risk, and designed to improve testability, maintainability, and AI-agent compatibility.

**Key Takeaways**:
- **Incremental Migration**: Feature-by-feature reduces risk
- **Test-Driven**: Write tests as we go, not after
- **YAGNI-Compliant**: Build only what's needed now
- **AI-Friendly**: Clear structure, predictable patterns, good documentation
- **Flexible**: Easy to swap implementations (Firebase → other backends)

**Total Effort**: 14-18 days
**Risk Level**: Medium (mitigated by incremental approach)
**Value**: High (enables testing, future scalability, AI development)

---

**Ready to proceed?**
Let's start with Phase 0: Preparation. 🚀
