# Project Skeleton: trustech_mobile

This document describes the directory structure and architectural pattern used in the `trustech_mobile` Flutter project.

## Architecture: Feature-First Layered Structure

The project follows a **Feature-First** approach combined with layered separation inside `src/`. This ensures high modularity and makes it easy to scale by adding new features without affecting existing ones.

### Directory Breakdown

#### `lib/`
- **`app/`**: Application-level configuration.
  - `app_shell.dart`: The root UI wrapper (e.g., handling Bottom Navigation or Drawer).
  - `bootstrap.dart`: App initialization logic (services, dependency injection, etc.).
- **`l10n/`**: Localization.
  - `arb/`: Source translation files.
  - `gen/`: Auto-generated localization code.
- **`src/`**: The main source code.
  - **`core/`**: Foundations and infrastructure.
    - `constants/`, `theme/`, `utils/`, `errors/`, `exceptions/`, `locales/`, `network/`, `platform/`, `storage/`.
  - **`shared/`**: Reusable components.
    - `models/`, `providers/`, `widgets/`.
  - **`features/`**: Business logic modules grouped by feature.

### Feature Module Structure
For features that are **API-first**, we utilize a simplified structure:
- **`presentation/`**: Screens, widgets, and UI-specific logic.
- **`providers/`**: State management (Riverpod/Bloc) and API interaction logic.

#### Example Modules:
- `auth/`: Login, registration, and session management.
- `dashboard/`: Primary landing area and navigation.
- `attendance/`: Tracking and reporting attendance.

## Development Principles
1. **API-First**: Business logic and data flow primarily depend on the remote API.
2. **Modularization**: Keep feature-specific code within its respective `features/` directory.
3. **Shared Core**: Use `src/core` for any logic that is truly app-wide.
