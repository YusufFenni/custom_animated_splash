import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;

void main() async {
  print('Working directory: ${Directory.current.path}');
  final pubspec = File('pubspec.yaml');
  print('pubspec.yaml exists: ${pubspec.existsSync()}');
  if (!pubspec.existsSync()) {
    print('pubspec.yaml not found.');
    exit(1);
  }

  final yaml = loadYaml(pubspec.readAsStringSync());
  final splashConfig = yaml['custom_animated_splash'];
  print('custom_animated_splash config found: ${splashConfig != null}');
  if (splashConfig == null) {
    print('custom_animated_splash section not found in pubspec.yaml.');
    exit(1);
  }

  // Sadece renk pubspec.yaml'dan alınacak, diğerleri sabit.
  String defaultColor() => '#FFFFFF';
  final color = splashConfig['color'] ?? defaultColor();

  final splashDir = Directory('lib/src/custom_animated_splash');
  if (!splashDir.existsSync()) {
    splashDir.createSync(recursive: true);
    print('lib/src/custom_animated_splash directory created.');
  }

  final splashFilePath = p.join('lib', 'src', 'custom_animated_splash',
      'custom_animated_splash_page.dart');
  final splashFile = File(splashFilePath);
  print('Target file path: $splashFilePath');

  final splashWidgetCode = """
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';

class CustomAnimatedSplashPage extends StatefulWidget {
  const CustomAnimatedSplashPage({super.key});

  @override
  State<CustomAnimatedSplashPage> createState() => _CustomAnimatedSplashPageState();
}

class _CustomAnimatedSplashPageState extends State<CustomAnimatedSplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => GoPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF${color.replaceAll('#', '')}),
      body: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Lottie.asset('assets/splash.json'),
        ),
      ),
    );
  }

  
}
""";

  splashFile.writeAsStringSync(splashWidgetCode);
  print('File written: ${splashFile.existsSync()}');
  print('lib/src/custom_animated_splash/custom_animated_splash_page.dart created and settings written!');

  // --- RENK HEX ---
  final colorHex = color.replaceAll('#', '').toUpperCase();

  // --- ANDROID SPLASH RENK GÜNCELLEME ---
  const androidColorsPath = 'android/app/src/main/res/values/colors.xml';
  const androidLaunchBgPath =
      'android/app/src/main/res/drawable/launch_background.xml';
  if (File(androidColorsPath).existsSync()) {
    String colorsXml = File(androidColorsPath).readAsStringSync();
    const colorTag = '<color name="splash_color">';
    if (colorsXml.contains(colorTag)) {
      colorsXml = colorsXml.replaceAll(
          RegExp(r'<color name="splash_color">.*?</color>'),
          '$colorTag#$colorHex</color>');
    } else {
      colorsXml = colorsXml.replaceFirst(
          '</resources>', '  $colorTag#$colorHex</color>\n</resources>');
    }
    File(androidColorsPath).writeAsStringSync(colorsXml);
    print('Android colors.xml splash_color updated: #$colorHex');
  } else {
    print('Android colors.xml not found: $androidColorsPath');
  }
  if (File(androidLaunchBgPath).existsSync()) {
    String launchBgXml = File(androidLaunchBgPath).readAsStringSync();
    launchBgXml = launchBgXml.replaceAll(
        RegExp(r'android:fillColor="#[A-Fa-f0-9]{6,8}"'),
        'android:fillColor="#$colorHex"');
    File(androidLaunchBgPath).writeAsStringSync(launchBgXml);
    print('Android launch_background.xml splash color updated.');
  } else {
    print('Android launch_background.xml not found: $androidLaunchBgPath');
  }

  // --- IOS SPLASH RENK GÜNCELLEME ---
  const iosStoryboardPath = 'ios/Runner/Base.lproj/LaunchScreen.storyboard';
  if (File(iosStoryboardPath).existsSync()) {
    String storyboard = File(iosStoryboardPath).readAsStringSync();
    final rgb = _hexToRgb(color);
    storyboard = storyboard.replaceAll(
        RegExp(r'red="[0-9.]+" green="[0-9.]+" blue="[0-9.]+"'),
        'red="${rgb[0]}" green="${rgb[1]}" blue="${rgb[2]}"');
    File(iosStoryboardPath).writeAsStringSync(storyboard);
    print('iOS LaunchScreen.storyboard splash color updated.');
  } else {
    print('iOS LaunchScreen.storyboard not found: $iosStoryboardPath');
  }

  print('\nSplash screen colors updated for both Android and iOS!');
}

/// HEX renk kodunu [0-1] arası RGB değerlerine çevirir.
List<String> _hexToRgb(String hex) {
  final hexColor = hex.replaceAll('#', '');
  final r = int.parse(hexColor.substring(0, 2), radix: 16) / 255.0;
  final g = int.parse(hexColor.substring(2, 4), radix: 16) / 255.0;
  final b = int.parse(hexColor.substring(4, 6), radix: 16) / 255.0;
  return [r.toStringAsFixed(6), g.toStringAsFixed(6), b.toStringAsFixed(6)];
}
