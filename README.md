# jdonut_app

A Flutter application for browsing J'Donut products, promotions, nearby shops, and rewards. The project follows a feature-first architecture and uses an offline-first approach for local data.

## 1. Environment

| Item              | Version                |
| ----------------- | ---------------------- |
| Flutter (initial) | 3.47.0                 |
| Flutter (current) | 3.47.9                 |
| Dart              | 3.13.7                 |
| State Management  | Riverpod               |
| Navigation        | GoRouter               |
| Local Database    | SQLite                 |
| Secure Storage    | flutter_secure_storage |

## 2. Architecture

The project follows a **Feature-First Clean Architecture** approach.

Each feature is separated into three layers:

- **Presentation:** Screens, widgets, and state management.
- **Domain:** Business rules, entities, repository contracts, and validators.
- **Data:** Data sources, models, and repository implementations.

The Domain layer does not depend on Flutter or external infrastructure.

### Folder Structure

```
lib/
├── core/
│   ├── database/
│   ├── errors/
│   ├── network/
│   ├── router/
│   ├── storage/
│   ├── constants/
│   └── utils/
│
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   ├── widgets/
│   │   │   └── providers/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   ├── usecases/
│   │   │   └── validators/
│   │   └── data/
│   │       ├── datasources/
│   │       ├── models/
│   │       └── repositories/
│   │
│   ├── home/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   ├── product/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   └── rewards/
│       ├── presentation/
│       ├── domain/
│       └── data/
│
├── shared/
│   ├── navigation/
│   ├── theme/
│   └── widgets/
│
├── app.dart
└── main.dart
```

### Layer Responsibilities

| Layer        | Responsibility                                                            |
| ------------ | ------------------------------------------------------------------------- |
| Presentation | UI, Riverpod providers, and screen state                                  |
| Domain       | Entities, repository contracts, use cases, and validation                 |
| Data         | SQLite, local data sources, fake services, and repository implementations |
| Core         | App-wide infrastructure and utilities                                     |
| Shared       | Reusable UI, theme, and navigation components                             |

## 3. State Management

**Riverpod** is used for application state management.

It handles:

- Authentication session state
- Login and registration flow state
- OTP verification state
- Feature-level data providers
- Repository dependency injection

Authentication state is managed through `AuthSessionNotifier`.

Access and refresh tokens are stored using `flutter_secure_storage`.

## 4. Offline Strategy

The application uses local SQLite storage to provide data without requiring a live backend.

Current offline approach:

- SQLite stores local application data.
- Product, banner, and shop repositories seed initial data.
- Local data sources retrieve data from SQLite.
- Repository implementations provide data to the presentation layer.
- Secure Storage keeps authentication tokens on the device.

### Initial Data Seeding

The application seeds local data during startup:

```dart
await container.read(productRepositoryProvider).seedProducts();
await container.read(bannerRepositoryProvider).seedBanners();
await container.read(shopRepositoryProvider).seedShops();
```

## 5. Fake Authentication / OTP

Authentication currently uses a fake authentication implementation for demonstration and testing.

| Item                | Value           |
| ------------------- | --------------- |
| Authentication      | Fake / Demo     |
| OTP Code            | 123456          |
| Backend Integration | Not implemented |

Replace the fake authentication implementation with a real API-backed repository when the backend becomes available.

## 6. UI and Animations

Document the animations actually implemented in the application.

| Component            | Animation                | Status |
| -------------------- | ------------------------ | ------ |
| Home banner carousel | Automatic/manual sliding |
| Bottom navigation    |
| Loading skeletons    |
| Other transitions    |

The home screen is designed to include:

- Member information and membership tier
- Points progress
- Notification count
- Promotional banner carousel
- Seasonal specials
- Popular products
- Order again
- Nearby shops

Loading, empty, and error states are handled at the individual section level.

## 7. Known Gaps / Limitations

- Authentication currently uses a fake service.
- OTP verification is simulated.
- Production error handling and monitoring need further work.

## 8. Time Spent

| Activity                        | Time       |
| ------------------------------- | ---------- |
| Project setup and architecture  | Day 1      |
| Authentication flow             | Day 2      |
| Local database and data seeding | Day 1      |
| Home screen UI                  | Day 1      |
| Animations and UI polish        | Day 2      |
| Testing and bug fixes           | Day 2      |
| **Total**                       | **2 Days** |

**Project:** J'Donut App  
**Framework:** Flutter  
**Architecture:** Feature-First Clean Architecture  
**State Management:** Riverpod  
**Navigation:** GoRouter  
**Storage:** SQLite and Flutter Secure Storage
