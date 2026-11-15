# FoodCat – Food & Grocery Delivery App

FoodCat is a Flutter-based food and grocery delivery application with a friendly cat-themed identity and a pink visual style. The project is designed to bring customers, restaurant partners, delivery riders, and administrators into one application.

## Project Overview

- **Project title:** FoodCat – Food & Grocery Delivery App
- **Platform:** Flutter
- **Language:** Dart
- **Local database:** SQLite
- **State management:** Provider (where used in the project)
- **Brand identity:** Pink FoodCat mascot and delivery theme

## Main Areas

- **Customer:** Browse food and grocery products, explore restaurants and menus, manage a cart, and view orders.
- **Restaurant Partner:** Manage restaurant-related information, products, inventory, and incoming orders.
- **Rider:** Access delivery-related screens and shift controls.
- **Admin:** Access administrative and dispatch-related screens.

> The exact features available depend on the screens and database operations implemented in the current project version.

## Screenshots and Images

Place app screenshots and image assets in the project’s `assets/pictures/` folder. For example:

```text
assets/
  branding/
    foodcat_icon.png
    foodcat_splash.png
 
```
 pictures/
    customer_home.png
    restaurant_list.png
    restaurant_menu.png
    product_details.png

If you add images under `assets/pictures/`, make sure the folder is declared in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/branding/
    - assets/pictures/
```

Use the exact folder names and indentation shown above. If your project already has an `assets:` section, add the new paths to that section rather than creating a second one.

## Requirements

- Flutter SDK (stable channel recommended)
- Dart SDK compatible with the Flutter version in `pubspec.yaml`
- Android Studio or Visual Studio Code
- Android emulator or a physical Android device

## Getting Started

1. Clone this repository:

   ```bash
   git clone <YOUR_GITHUB_REPOSITORY_URL>
   ```

2. Open the project folder:

   ```bash
   cd foodcat_flutter
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Check the project:

   ```bash
   flutter analyze
   ```

5. Run the app:

   ```bash
   flutter run
   ```

## Database

FoodCat uses **SQLite** for local data storage in this project version. Firebase is not required for the SQLite-based build. Any unused Firebase/Cloud Firestore setup files should be removed only after confirming that no Dart code or package dependency still imports or uses Firebase.

## Project Structure

```text
foodcat_flutter/
├── android/
├── assets/
│   ├── branding/
│   └── pictures/
├── ios/
├── lib/
├── test/
├── web/
├── windows/
├── linux/
├── macos/
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
└── README.md
```




## GitHub Upload Notes

Commit the Flutter source code, assets, platform configuration, and dependency manifests. Do not commit generated build output, local IDE settings, or machine-specific cache files.

## Status

FoodCat is a development project. Features, UI, and database workflows may change as development continues.
