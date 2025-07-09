# custom_animated_splash

A Flutter package to automate the creation and integration of a customizable animated splash screen, including native splash background color synchronization for both Android and iOS—**without any dependency on external splash plugins**.

---

## Features
- Reads splash background color from your app's `pubspec.yaml` under `custom_animated_splash:`
- Generates a Flutter splash page that displays a Lottie animation (`assets/splash.json`)
- Automatically updates native splash background color for Android and iOS
- One-command setup for both native and Flutter splash screens

---

## Getting started

1. **Add this package to your app's dependencies:**
   ```yaml
   dependencies:
     custom_animated_splash:
     
   ```

2. **Add the splash color to your app's pubspec.yaml:**
   ```yaml
   custom_animated_splash:
     color: "#FF0000" # Use any hex color you want
   ```

3. **Add your splash animation asset:**
   - Place your Lottie animation file at `assets/splash.json`
   - Register the asset in your pubspec.yaml:
     ```yaml
     flutter:
       assets:
         - assets/splash.json
     ```

4. **Run the splash creation script from your app root:**
   ```sh
   dart run custom_animated_splash:bin/create_animated_splash.dart
   ```
   - This generates the Flutter splash page and updates native splash colors.

5. **Rebuild your project:**
   ```sh
   flutter clean
   flutter run
   ```

---

## Usage

- Import and use the generated splash page in your app:
  ```dart
  import 'package:custom_animated_splash/src/custom_animated_splash/custom_animated_splash_page.dart';
  // Use CustomAnimatedSplashPage() as your initial route/page
  ```
- The splash page will show your animation for 3 seconds, then navigate to `GoPage()` (replace or implement as needed).

---

## How it works
- Reads the color you set in `custom_animated_splash.color` in your app's pubspec.yaml
- Updates Android's `colors.xml` and `launch_background.xml` and iOS's `LaunchScreen.storyboard` with the specified color
- Generates a Flutter splash widget that uses the same color and plays the Lottie animation
- No external splash dependency required

---

## Additional information
- If you change the color or animation, re-run the script and rebuild your app
- If you encounter issues, please file an issue on the repository
- PRs and contributions are welcome!
# custom_animated_splash
