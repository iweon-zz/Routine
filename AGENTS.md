# AGENTS.md - Routine iOS App

## 1. Project Overview
**Routine** is an AI-assisted iOS study coach application designed to help users manage their learning habits. Key features include a Pomodoro timer, task/exam management, study session recording, and comprehensive weekly reports. The app leverages SwiftUI, Combine, and Core Data, with planned extensions for Widgets and App Intents.

## 2. Folder Structure Rules
The project follows a **Feature-based** architecture. All source code is located in `Routine/Routine/`.

- **App/**: App lifecycle and entry points (`RoutineApp.swift`, `MainTabView.swift`).
- **Features/**: Independent feature modules. Each feature (e.g., `Timer`, `Task`, `Report`) must have its own subfolder containing:
    - `Views/`: SwiftUI Views.
    - `ViewModels/`: ObservableObjects managing state and logic.
    - `Models/`: Feature-specific data models.
- **Core/**: Shared logic and infrastructure.
    - `Data/`: CoreData/CloudKit stacks, DataManagers.
    - `Models/`: Domain models used across multiple features.
    - `Extensions/`: Swift extensions and helpers.
    - `Services/`: App-wide services (Notifications, Settings).
- **Resources/**: Assets and static files.

## 3. Code Style Guide
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Indentation**: 4 spaces
- **Formatting**: Follow standard Swift API Design Guidelines.
- **Concurrency**: Prefer Swift Concurrency (`async`/`await`) over closures where possible.
- **Documentation**: Public methods and complex logic must have documentation comments.

## 4. AI Collaboration Rules (Do's and Don'ts)

### ✅ Do
- Generate boilerplate code (Views, ViewModels, Models).
- Write Unit Tests and UI Tests drafts.
- Suggest refactoring for cleaner, more idiomatic Swift code.
- Write documentation and comments.
- Create SwiftUI Previews for all Views.

### ❌ Don't
- Hardcode sensitive information (API Keys, Secrets, Tokens).
- Implement critical security logic (e.g., StoreKit receipt validation, Cryptography) without explicit user review.
- Modify project build settings (`.xcodeproj`) unless explicitly requested.
- Delete user-created files without confirmation.

## 5. Build & Test Commands
Run these commands from the project root (`Routine/`):

### Build
```bash
xcodebuild -scheme Routine -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### Test
```bash
xcodebuild -scheme Routine -destination 'platform=iOS Simulator,name=iPhone 15' test
```

## 6. PR / Review Checklist
Before finishing a task, ensure the following:
- [ ] **Accessibility**: All UI elements have appropriate `accessibilityLabel` and `accessibilityHint`.
- [ ] **Performance**: No main thread blocking; heavy work is done in background tasks.
- [ ] **Memory**: Check for retain cycles (use `[weak self]` in closures).
- [ ] **Error Handling**: User-facing errors are handled gracefully (e.g., alerts, empty states).
- [ ] **Compliance**: Code follows the structure and style defined in this `AGENTS.md`.
