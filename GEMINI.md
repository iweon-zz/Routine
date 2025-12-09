# GEMINI.md - AI Assistant Guide

## 1. Role
**Role**: SwiftUI / iOS Code Generation & Refactoring Assistant
**Objective**: Assist the user in building the "Routine" iOS app by generating clean, idiomatic, and maintainable SwiftUI code using the MVVM architecture.

## 2. Prompt Templates

### New View Creation
```text
Create a new SwiftUI View named `[ViewName]`.
- Feature: [Timer / Task / Report]
- Requirements:
  - [Requirement 1]
  - [Requirement 2]
- Components: Use `[ExistingComponent]` if applicable.
- Preview: Include a preview with dummy data.
```

### ViewModel Creation
```text
Create a ViewModel for `[ViewName]`.
- Name: `[ViewName]ViewModel`
- Responsibilities:
  - Handle [Logic 1]
  - Manage state for [Property 1]
- Inputs: [User Actions]
- Outputs: Published properties for the View.
```

### Bug Report & Fix
```text
I found a bug in `[FileName]`.
- Symptom: [Describe what happens]
- Expected: [Describe what should happen]
- Context: [Error message or screenshot description]
Please analyze the code and rewrite the ENTIRE file with the fix.
```

## 3. Code Generation Rules

### ⚠️ Critical Rule: Full File Rewrites
When modifying an existing file, **DO NOT** output only the changed lines or partial snippets (e.g., "Replace line 10 with...").
**ALWAYS** generate the **COMPLETE** file content from top to bottom. This ensures context is preserved and prevents copy-paste errors.

### Style & Standards
- **Indentation**: 4 spaces (Standard Swift).
- **SwiftLint**: Ensure code does not trigger common SwiftLint warnings (e.g., force unwrapping `!`, long lines > 120 chars).
- **Imports**: Only import necessary frameworks.
- **Access Control**: Use `private` / `private(set)` where appropriate.

## 4. CLI / Work Examples

### Requesting Unit Tests
```text
Create a Unit Test file for `TimerViewModel`.
- Test Cases:
  - `testStartTimer`: Verify state changes to .running
  - `testPauseTimer`: Verify state changes to .paused
  - `testCompleteTimer`: Verify notification is triggered
- Location: `RoutineTests/Features/Timer/TimerViewModelTests.swift`
```

### Requesting Widget Code
```text
Create a Home Screen Widget named `RoutineWidget`.
- TimelineEntry: Should include `currentTask` and `remainingTime`.
- View: Small and Medium sizes supported.
- Provider: Use dummy data for placeholder.
- Location: `RoutineWidget/RoutineWidget.swift`
```
