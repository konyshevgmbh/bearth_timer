# Bearth Timer - Application Architecture Documentation

## Overview

Bearth Timer is a Flutter-based breathing exercise application that implements a **local-first architecture** with cloud synchronization. The application uses a dual-database approach with Hive for local storage and PostgreSQL (via Supabase) for cloud sync.

## Architecture Pattern

### Local-First Design
- **Primary data storage**: Hive (local NoSQL database)
- **Cloud backup**: PostgreSQL via Supabase 
- **Sync strategy**: Bi-directional with conflict resolution
- **Offline capability**: Full functionality without internet connection

### High-Level Architecture Diagram

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                UI LAYER                                       ║
║                            (Flutter Widgets)                                 ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────────┐   ║
║  │   PAGES     │   │   WIDGETS   │   │  PROVIDERS  │   │   STATE MGMT    │   ║
║  ├─────────────┤   ├─────────────┤   ├─────────────┤   ├─────────────────┤   ║
║  │ 🏠 HomePage │   │ 📊 Progress │   │ ⏱️  Session  │   │ ChangeNotifier  │   ║
║  │ ⚙️  Settings│   │ 📈 Charts   │   │ 💪 Exercise │   │ Provider        │   ║
║  │ 📚 History  │   │ 🎴 ExercCard│   │ 📊 History  │   │ Consumer        │   ║
║  │ 🔐 AuthPage │   │ 🔄 SyncStat │   │ 🔊 Sound   │   │ Reactive UI     │   ║
║  │ 🏋️  Training│   │ 📱 Controls │   │ 📤 Export  │   │                 │   ║
║  └─────────────┘   └─────────────┘   └─────────────┘   └─────────────────┘   ║
║                                         │                                     ║
╚════════════════════════════════════════════════════════════════════════════════╝
                                         │
                                    ┌────┴────┐
                                    │ Events  │
                                    │ & Calls │
                                    └────┬────┘
                                         ▼
╔═══════════════════════════════════════════════════════════════════════════════╗
║                               SERVICE LAYER                                   ║
║                           (Business Logic Hub)                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────────────┐ ║
║ │ StorageServ  │ │  SyncService │ │SessionService│ │    Other Services    │ ║
║ │ (Singleton)  │ │ (Singleton)  │ │ (Provider)   │ │                      │ ║
║ ├──────────────┤ ├──────────────┤ ├──────────────┤ ├──────────────────────┤ ║
║ │ 💾 Local CRUD│ │ 🔐 Auth      │ │ ⏰ Timer     │ │ 🔊 SoundService      │ ║
║ │ ✅ Validation│ │ ☁️  Sync      │ │ 🔄 Phases    │ │ 📤 ExportImport      │ ║
║ │ 🧹 Cleanup   │ │ ⚔️  Conflicts │ │ 📊 Progress  │ │ 🔑 OTPService        │ ║
║ │ 🔄 Auto-sync │ │ 📡 Network   │ │ 🎯 Tracking  │ │ 🎓 InitialTraining   │ ║
║ │ 📦 Hive Mgmt │ │ 🔄 Status    │ │ 📱 UI State  │ │ 💪 ExerciseService   │ ║
║ └──────────────┘ └──────────────┘ └──────────────┘ └──────────────────────┘ ║
║                                         │                                     ║
╚════════════════════════════════════════════════════════════════════════════════╝
                                         │
                                    ┌────┴────┐
                                    │ Data    │
                                    │ Access  │
                                    └────┬────┘
                                         ▼
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                DATA LAYER                                     ║
║                          (Local-First Architecture)                          ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║    ┌─────────────────────────────┐         ┌─────────────────────────────┐   ║
║    │      LOCAL STORAGE          │◄──────► │       CLOUD STORAGE         │   ║
║    │    (Hive - Primary)         │   Sync  │    (Supabase - Backup)      │   ║
║    ├─────────────────────────────┤         ├─────────────────────────────┤   ║
║    │                             │         │                             │   ║
║    │ ┌─────────────────────────┐ │         │ ┌─────────────────────────┐ │   ║
║    │ │     Hive Boxes          │ │         │ │   PostgreSQL Tables     │ │   ║
║    │ ├─────────────────────────┤ │         │ ├─────────────────────────┤ │   ║
║    │ │ 📊 results              │ │         │ │ 📊 training_results     │ │   ║
║    │ │ ⚙️  settings            │ │         │ │ ⚙️  user_settings       │ │   ║
║    │ │ 💪 exercises            │ │         │ │ 💪 breathing_exercises  │ │   ║
║    │ │                         │ │         │ │ 🫁 breath_phases        │ │   ║
║    │ │                         │ │         │ │                         │ │   ║
║    │ │ @HiveType Models:       │ │         │ │ 🔒 Row Level Security   │ │   ║
║    │ │ ├─ TrainingResult (0)   │ │         │ │ 🧹 Auto-cleanup         │ │   ║
║    │ │ ├─ UserSettings (1)     │ │         │ │ 🔗 Foreign Keys         │ │   ║
║    │ │ ├─ BreathPhase (2)      │ │         │ │ ⚡ Indexes              │ │   ║
║    │ │ └─ BreathingExercise(3) │ │         │ │ 🔄 Triggers             │ │   ║
║    │ └─────────────────────────┘ │         │ └─────────────────────────┘ │   ║
║    │                             │         │                             │   ║
║    │ 🚀 Instant Access          │         │ 🌐 Cross-device Sync       │   ║
║    │ 📱 Offline Capable         │         │ 🔐 User Authentication      │   ║
║    │ 🔄 Auto-generated Keys     │         │ ⚔️  Conflict Resolution     │   ║
║    └─────────────────────────────┘         └─────────────────────────────┘   ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

### Service Layer Architecture

The application follows a service-oriented architecture with clear separation of concerns:

```
UI Layer (Pages/Widgets) ←→ Provider Pattern (ChangeNotifier)
                ↓
Service Layer (Business Logic + Data Access)
                ↓
Data Layer (Hive Primary + Supabase Sync)
```

## Database Schema

### Local Storage (Hive)

Hive uses TypeAdapter pattern with the following data models:

```
┌─────────────────────────────────────────────────────────────────┐
│                        HIVE STORAGE                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │   BOXES     │  │   MODELS    │  │    KEYS     │              │
│  ├─────────────┤  ├─────────────┤  ├─────────────┤              │
│  │             │  │             │  │             │              │
│  │ results     │◄─┤TrainingResult│  │timestamp_   │              │
│  │             │  │(@HiveType 0)│  │exerciseId   │              │
│  │             │  │             │  │             │              │
│  │             │  │             │  │             │              │
│  │ settings    │◄─┤UserSettings │  │user_settings│              │
│  │             │  │(@HiveType 1)│  │             │              │
│  │             │  │             │  │             │              │
│  │             │  │             │  │             │              │
│  │ exercises   │◄─┤BreathingExer│  │exercise_id  │              │
│  │             │  │cise         │  │             │              │
│  │             │  │(@HiveType 3)│  │             │              │
│  │             │  │             │  │             │              │
│  │             │  │  ├─phases   │  │             │              │
│  │             │  │  │ BreathPh │  │             │              │
│  │             │  │  │ ase      │  │             │              │
│  │             │  │  │(@HiveT 2)│  │             │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

#### 1. TrainingResult (`@HiveType(typeId: 0)`)
```dart
- date: DateTime              // When the training occurred
- duration: int              // Duration in seconds
- cycles: int                // Number of cycles completed
- exerciseId: String         // Reference to breathing exercise
- deletedAt: DateTime?       // Soft delete timestamp
```

**Storage Box**: `results`
**Key Format**: `${timestamp}_${exerciseId}`
**Features**: 
- Soft delete support
- Score calculation: `duration * cycles`
- Automatic cleanup (30-day retention)

#### 2. UserSettings (`@HiveType(typeId: 1)`)
```dart
- totalCycles: int           // Default number of cycles
- cycleDuration: int         // Default cycle duration in seconds
- soundEnabled: bool         // Audio feedback setting
- vibrationEnabled: bool     // Haptic feedback setting
- defaultDuration: int       // Default duration
- languageCode: String       // UI language preference
```

**Storage Box**: `settings`
**Key**: `user_settings`

#### 3. BreathingExercise (`@HiveType(typeId: 3)`)
```dart
- id: String                 // Unique identifier (UUID)
- name: String               // Display name
- description: String        // Exercise description
- createdAt: DateTime        // Creation timestamp
- updatedAt: DateTime?       // Last modification timestamp
- deletedAt: DateTime?       // Soft delete timestamp
- minCycles: int             // Minimum allowed cycles
- maxCycles: int             // Maximum allowed cycles
- cycleDurationStep: int     // Step size for duration adjustments
- cycles: int                // Current/default cycles
- cycleDuration: int         // Current/default cycle duration
- phases: List<BreathPhase>  // Breathing phases
```

**Storage Box**: `exercises`
**Key Format**: `exerciseId`
**Features**:
- Soft delete support
- Validation constraints
- Calculated properties for UI state

#### 4. BreathPhase (`@HiveType(typeId: 2)`)
```dart
- name: String               // Phase name (e.g., "Inhale", "Hold")
- duration: int              // Phase duration in seconds
- minDuration: int           // Minimum allowed duration
- maxDuration: int           // Maximum allowed duration
- colorValue: int            // Color for UI representation
- claps: int                 // Audio cues count
- deletedAt: DateTime?       // Soft delete timestamp
```

**Features**:
- Color management with Flutter Color conversion
- Duration validation
- Embedded within BreathingExercise

### Cloud Storage (PostgreSQL via Supabase)

#### Schema Design Principles
- **Row Level Security (RLS)** enabled on all tables
- **Soft delete pattern** consistent across all entities
- **Composite primary keys** for user data isolation
- **Foreign key constraints** for data integrity

#### Database Relationship Diagram
```
╔══════════════════════════════════════════════════════════════════════════════════════╗
║                              SUPABASE POSTGRESQL                                    ║
║                            (Cloud Database Schema)                                  ║
╠══════════════════════════════════════════════════════════════════════════════════════╣
║                                                                                      ║
║                               🔐 AUTHENTICATION                                      ║
║  ┌─────────────────────┐                                                            ║
║  │   auth.users        │                                                            ║
║  │ ┌─────────────────┐ │                                                            ║
║  │ │ 🆔 id (UUID)    │ │ ◄─────────────────┐                                       ║
║  │ │ 📧 email        │ │                   │                                       ║
║  │ │ 🔒 password     │ │                   │                                       ║
║  │ │ ⏰ created_at   │ │                   │                                       ║
║  │ └─────────────────┘ │                   │                                       ║
║  └─────────────────────┘                   │                                       ║
║                                            │                                       ║
║                        🔄 USER DATA ISOLATION                                      ║
║                                            │                                       ║
║   ┌─────────────────────┐                  │                  ┌─────────────────┐ ║
║   │  breathing_exercises│                  │                  │ training_results│ ║
║   │ ┌─────────────────┐ │                  │                  │ ┌─────────────┐ │ ║
║   │ │ 👤 user_id (FK) │ │ ◄────────────────┼──────────────────┤ │👤 user_id   │ │ ║
║   │ │ 🆔 id (TEXT)    │ │                  │                  │ │🆔 id (UUID) │ │ ║
║   │ │ 📝 name         │ │                  │                  │ │🏋️ exercise_id│ │ ║
║   │ │ 📄 description  │ │                  │                  │ │📅 date      │ │ ║
║   │ │ ⏰ created_at   │ │                  │                  │ │⏱️  duration  │ │ ║
║   │ │ 🔄 updated_at   │ │                  │                  │ │🔁 cycles    │ │ ║
║   │ │ 🗑️  deleted_at   │ │                  │                  │ │🏆 score     │ │ ║
║   │ │ 🔁 cycles       │ │                  │                  │ │🗑️  deleted_at │ │ ║
║   │ │ ⏱️  cycle_dur    │ │                  │                  │ └─────────────┘ │ ║
║   │ └─────────────────┘ │                  │                  └─────────────────┘ ║
║   └─────────────────────┘                  │                                       ║
║              │                             │                                       ║
║              │ 🔗 FK Relationship          │                                       ║
║              ▼                             │                                       ║
║   ┌─────────────────────┐                  │                  ┌─────────────────┐ ║
║   │    breath_phases    │                  │                  │  user_settings  │ ║
║   │ ┌─────────────────┐ │                  │                  │ ┌─────────────┐ │ ║
║   │ │ 🆔 id (UUID)    │ │                  │                  │ │👤 user_id   │ │ ║
║   │ │ 🏋️  exercise_id  │ │                  │                  │ │🔁 total_cyc │ │ ║
║   │ │ 👤 ex_user_id   │ │ ◄────────────────┘                  │ │⏱️  cycle_dur │ │ ║
║   │ │ 📝 name         │ │                                      │ │🔊 sound_en  │ │ ║
║   │ │ ⏱️  duration     │ │                                      │ │🔈 volume    │ │ ║
║   │ │ ⚡ min_duration │ │                                      │ │⏰ updated   │ │ ║
║   │ │ ⚡ max_duration │ │                                      │ └─────────────┘ │ ║
║   │ │ 🎨 color_value  │ │                                      └─────────────────┘ ║
║   │ │ 📊 phase_order  │ │                                                         ║
║   │ │ 👏 claps        │ │                                                         ║
║   │ │ 🗑️  deleted_at   │ │                                                         ║
║   │ └─────────────────┘ │                                                         ║
║   └─────────────────────┘                                                         ║
║                                                                                    ║
║ 🔒 SECURITY FEATURES:                                                              ║
║ • Row Level Security (RLS) - Users can only access their own data                 ║
║ • Policies: auth.uid() = user_id for all operations (SELECT/INSERT/UPDATE/DELETE) ║
║ • Automatic user_settings creation on registration                                ║
║ • Soft delete pattern with automated cleanup (30 days)                           ║
║ • Indexed queries for performance optimization                                    ║
║                                                                                    ║
╚══════════════════════════════════════════════════════════════════════════════════════╝
```

#### Tables

##### 1. `breathing_exercises`
```sql
CREATE TABLE breathing_exercises (
    id TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ DEFAULT NULL,
    min_cycles INTEGER NOT NULL,
    max_cycles INTEGER NOT NULL,
    cycle_duration_step INTEGER NOT NULL,
    cycles INTEGER NOT NULL,
    cycle_duration INTEGER NOT NULL,
    PRIMARY KEY (user_id, id)
);
```

##### 2. `breath_phases`
```sql
CREATE TABLE breath_phases (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    exercise_id TEXT NOT NULL,
    exercise_user_id UUID NOT NULL,
    name TEXT NOT NULL,
    duration INTEGER NOT NULL,
    min_duration INTEGER NOT NULL,
    max_duration INTEGER NOT NULL,
    color_value BIGINT NOT NULL,
    phase_order INTEGER NOT NULL,
    claps INTEGER DEFAULT 1 NOT NULL,
    deleted_at TIMESTAMPTZ DEFAULT NULL,
    FOREIGN KEY (exercise_user_id, exercise_id) 
        REFERENCES breathing_exercises(user_id, id) ON DELETE CASCADE
);
```

##### 3. `training_results`
```sql
CREATE TABLE training_results (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    exercise_id TEXT,
    date TIMESTAMPTZ NOT NULL,
    duration INTEGER NOT NULL,
    cycles INTEGER NOT NULL,
    score REAL,
    deleted_at TIMESTAMPTZ DEFAULT NULL
);
```

##### 4. `user_settings`
```sql
CREATE TABLE user_settings (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    total_cycles INTEGER DEFAULT 4,
    cycle_duration INTEGER DEFAULT 60,
    sound_enabled BOOLEAN DEFAULT true,
    volume REAL DEFAULT 1.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Security Model

**Row Level Security Policies** ensure users can only access their own data:
- SELECT, INSERT, UPDATE, DELETE policies per table
- Based on `auth.uid() = user_id` condition
- Automatic user settings creation on registration

#### Performance Optimizations

**Indexes**:
- `idx_breathing_exercises_user_id` - User data filtering
- `idx_training_results_date` - Date-based queries
- `idx_breath_phases_order` - Phase ordering
- Partial indexes on `deleted_at` for soft-deleted records

**Triggers**:
- `update_updated_at_column()` - Automatic timestamp updates
- `handle_new_user()` - Default settings creation
- Scheduled cleanup of old deleted records (30-day retention)

## Service Architecture

### Core Services

#### 1. StorageService (lib/services/storage_service.dart)
**Purpose**: Local data persistence and management
**Pattern**: Singleton
**Responsibilities**:
- Hive box management with error handling
- CRUD operations for all data models
- Soft delete implementation
- Data validation and cleanup
- Default data creation

**Key Methods**:
```dart
- loadExercises() -> List<BreathingExercise>
- saveTrainingResult(TrainingResult)
- deleteExercise(String) -> bool
- duplicateExercise(String) -> BreathingExercise?
- getLast30DaysData() -> List<MapEntry<DateTime, double?>>
```

#### 2. SyncService (lib/services/sync_service.dart)
**Purpose**: Cloud synchronization and authentication
**Pattern**: Singleton
**Responsibilities**:
- Supabase authentication (sign up, sign in, sign out)
- Bi-directional data synchronization
- Conflict resolution based on timestamps
- Offline/online state management
- Automatic sync triggers

**Sync Strategy**:
```dart
enum SyncStatus { synced, syncing, offline, error, pendingChanges }
```

**Conflict Resolution**:
1. Compare timestamps (`isMoreRecentThan()`)
2. For same timestamps, prefer better performance (`isBetterThan()`)
3. Preserve deletions (soft delete timestamps)

#### 3. SessionService (lib/services/session_service.dart)
**Purpose**: Training session management
**Pattern**: ChangeNotifier (Provider)
**Responsibilities**:
- Timer management
- Phase transitions
- Progress tracking
- Audio/haptic feedback coordination

#### 4. ExerciseService (lib/services/exercise_service.dart)
**Purpose**: Exercise management and defaults
**Pattern**: ChangeNotifier (Provider)
**Responsibilities**:
- Default exercise creation
- Exercise validation
- Phase calculations
- UI state management

#### 5. HistoryService (lib/services/history_service.dart)
**Purpose**: Historical data analysis
**Pattern**: ChangeNotifier (Provider)
**Responsibilities**:
- Statistics calculation
- Data aggregation
- Chart data preparation
- Performance analytics

#### 6. Additional Services
- **SoundService**: Audio feedback management
- **ExportImportService**: Data export/import functionality
- **OTPService**: One-time password for password resets
- **InitialTrainingService**: Onboarding flow management

## Data Flow Patterns

### Write Operations Flow
```
╔════════════════════════════════════════════════════════════════════════════════╗
║                              WRITE OPERATION                                   ║
╚════════════════════════════════════════════════════════════════════════════════╝

    👤 User               📱 UI                🛠️  Service           💾 Local          ☁️  Cloud
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│             │    │             │    │             │    │             │    │             │
│ ✏️  Action   │──➤ │ 🔘 Button   │──➤ │ 🔄 Process  │──➤ │ 📦 Store    │──➤ │ 🔄 Auto-    │
│             │    │             │    │             │    │             │    │    Sync     │
│ • Add Result│    │ • Form      │    │ • Validate  │    │ • Hive Box  │    │             │
│ • Edit Ex.  │    │ • Dialog    │    │ • Transform │    │ • TypeSafe  │    │ • Queue     │
│ • Settings  │    │ • Gesture   │    │ • BusinessL │    │ • Instant   │    │ • Conflict  │
│             │    │             │    │             │    │             │    │   Resolve   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                                     │
      📡 Status: [Offline] ←────────────────────────────────────────────────────────┘
                 [Syncing] ←── 🌐 Network Available ──➤ [Supabase PostgreSQL]
                 [Synced]  ←── ✅ Success Response ───┘
```

### Read Operations Flow  
```
╔════════════════════════════════════════════════════════════════════════════════╗
║                               READ OPERATION                                   ║
╚════════════════════════════════════════════════════════════════════════════════╝

    📱 UI Request         🛠️  Service           💾 Local Storage      📊 Processing     📱 UI Update
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│             │    │             │    │             │    │             │    │             │
│ 📊 Load Data│──➤ │ 🔍 Query    │──➤ │ 📦 Retrieve │──➤ │ ⚙️  Transform│──➤ │ 🎨 Render   │
│             │    │             │    │             │    │             │    │             │
│ • History   │    │ • Filter    │    │ • Hive Box  │    │ • Calculate │    │ • Charts    │
│ • Stats     │    │ • Sort      │    │ • TypeSafe  │    │ • Aggregate │    │ • Lists     │
│ • Settings  │    │ • Validate  │    │ • Instant   │    │ • Format    │    │ • Forms     │
│             │    │             │    │             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘

         🚀 Instant Response (No Network Required) - Local-First Architecture
```

### Synchronization Flow
```
╔════════════════════════════════════════════════════════════════════════════════╗
║                            SYNCHRONIZATION FLOW                               ║
╚════════════════════════════════════════════════════════════════════════════════╝

🔐 Login/Trigger    📡 Initial Sync     ⚔️  Conflict Res.    🔄 Update         📊 Status
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│             │    │             │    │             │    │             │    │             │
│ 👤 User     │──➤ │ 📥 Download │──➤ │ 🔍 Compare  │──➤ │ 💾 💾 Merge │──➤ │ ✅ Complete │
│   Login     │    │    Cloud    │    │   Changes   │    │ Local+Cloud │    │   Synced    │
│             │    │             │    │             │    │             │    │             │
│ 🔄 Manual   │    │ 📤 Upload   │    │ ⏰ Timestamp │    │ 🧹 Cleanup  │    │ ❌ Error    │
│   Sync      │    │   Local     │    │   Priority  │    │   Old Data  │    │   Retry     │
│             │    │             │    │             │    │             │    │             │
│ ⚡ Auto     │    │ 🔄 Bi-dir   │    │ 🏆 Best     │    │ 📁 Organize │    │ 📶 Status   │
│   Trigger   │    │   Exchange  │    │   Performance│    │   Results   │    │   Update    │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                              │
                ┌─────────────────────────────┴─────────────────────────────┐
                │                 CONFLICT RESOLUTION                       │
                │ 1️⃣  Timestamp Comparison (newer wins)                    │
                │ 2️⃣  Performance Comparison (better score)                │
                │ 3️⃣  Soft Delete Preservation (never lose data)           │
                │ 4️⃣  User Preference (cloud settings priority)            │
                └───────────────────────────────────────────────────────────┘
```

### Conflict Resolution Decision Tree
```
╔════════════════════════════════════════════════════════════════════════════════╗
║                           CONFLICT RESOLUTION                                 ║
╚════════════════════════════════════════════════════════════════════════════════╝

                           ⚔️  CONFLICT DETECTED
                    ┌─────────────────────────────┐
                    │  📊 Data Mismatch Found     │
                    │  Local ≠ Cloud Version      │
                    └─────────────┬───────────────┘
                                  │
                    ┌─────────────▼───────────────┐
                    │    🕐 TIMESTAMP CHECK       │
                    │   Compare Modification      │
                    │      Timestamps             │
                    └─────────────┬───────────────┘
                                  │
               ┌──────────────────┴──────────────────┐
               │                                     │
        ┌──────▼──────┐                      ┌──────▼──────┐
        │ 📱 LOCAL     │                      │ ☁️  CLOUD    │
        │   NEWER      │                      │   NEWER     │
        │ timestamp >  │                      │ timestamp > │
        └──────┬──────┘                      └──────┬──────┘
               │                                     │
        ┌──────▼──────┐                      ┌──────▼──────┐
        │ ✅ USE      │                      │ ✅ USE      │
        │   LOCAL     │                      │   CLOUD     │
        │  VERSION    │                      │  VERSION    │
        └─────────────┘                      └─────────────┘
                                  │
               ┌──────────────────▼──────────────────┐
               │            ⏰ SAME TIME             │
               └──────────────────┬──────────────────┘
                                  │
               ┌──────────────────┴──────────────────┐
               │                                     │
        ┌──────▼──────┐                      ┌──────▼──────┐
        │ 🏆 QUALITY  │                      │ 🗑️  SPECIAL │
        │  COMPARISON │                      │    CASES    │
        │             │                      │             │
        │ • Better    │                      │ • Soft      │
        │   Score     │                      │   Delete    │
        │ • More      │                      │ • Settings  │
        │   Cycles    │                      │   Priority  │
        │ • Longer    │                      │ • User      │
        │   Duration  │                      │   Prefs     │
        └──────┬──────┘                      └──────┬──────┘
               │                                     │
        ┌──────▼──────┐                      ┌──────▼──────┐
        │ ✅ BETTER   │                      │ ✅ PRESERVE │
        │ PERFORMANCE │                      │  DELETION   │
        │    WINS     │                      │   & PREFS   │
        └─────────────┘                      └─────────────┘

        📋 RESOLUTION PRIORITY:
        1️⃣  Timestamp (Most Recent)
        2️⃣  Performance Quality  
        3️⃣  Soft Delete Status
        4️⃣  Data Type Rules
```

### Conflict Resolution Algorithm
1. **Training Results**: Prefer more recent or better performance
2. **Exercises**: Prefer more recent modification
3. **Settings**: Prefer cloud version
4. **Deletions**: Always preserve (soft delete wins)

## Key Design Decisions

### Local-First Benefits
- **Offline capability**: Full functionality without internet
- **Performance**: Instant response times
- **Data ownership**: User data always accessible
- **Reliability**: No dependency on network connectivity

### Soft Delete Implementation
- **Consistency**: Same pattern across local and cloud
- **Data recovery**: Enables undo functionality
- **Sync safety**: Prevents data loss during conflicts
- **Cleanup**: Automatic purging after 30 days

### Service Layer Benefits
- **Separation of concerns**: Clear responsibilities
- **Testability**: Easy to unit test business logic
- **Reusability**: Services can be used across UI components
- **State management**: Provider pattern for reactive UI

### Type Safety
- **Hive TypeAdapters**: Compile-time type safety
- **Code generation**: Automatic serialization
- **Null safety**: Full Dart null-safety compliance
- **Validation**: Runtime data validation

## Configuration

### Hive Configuration
```dart
// Type IDs for Hive adapters
TrainingResult: typeId: 0
UserSettings: typeId: 1
BreathPhase: typeId: 2
BreathingExercise: typeId: 3
```

### Supabase Configuration
```dart
class SupabaseConstants {
    static const String trainingResultsTable = 'training_results';
    static const String userSettingsTable = 'user_settings';
    static const String breathingExercisesTable = 'breathing_exercises';
    static const String breathPhasesTable = 'breath_phases';
}
```

### Storage Configuration
```dart
class StorageConstants {
    static const int maxDataRetentionDays = 30;
}
```

## Error Handling

### Local Storage
- Hive box availability checks
- Corrupted data recovery
- Default value fallbacks
- Transaction safety

### Cloud Sync
- Network connectivity checks
- Authentication state management
- Retry mechanisms
- Graceful degradation

### UI Layer
- Loading states
- Error messages
- Offline indicators
- Sync status display

## Security Considerations

### Local Security
- No sensitive data in Hive storage
- User settings only (no credentials)
- App sandbox protection

### Cloud Security
- Row Level Security (RLS) policies
- User isolation at database level
- Secure authentication (Supabase Auth)
- No direct SQL access from client

### Data Privacy
- User data belongs to user
- Local-first ensures data control
- Optional cloud backup
- Easy data export/import

This architecture provides a robust, scalable, and user-friendly foundation for the breathing exercise application while maintaining data ownership and offline capabilities.