import 'dart:io';
import 'package:yaml/yaml.dart';

void main() async {
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    print('pubspec.yaml bulunamadı.');
    exit(1);
  }

  final yaml = loadYaml(pubspec.readAsStringSync());
  final splashConfig = yaml['custom_animated_splash'];
  if (splashConfig == null || splashConfig['color'] == null) {
    print('pubspec.yaml içinde custom_animated_splash: color: bulunamadı.');
    exit(1);
  }

  final color = splashConfig['color'];
  print('Splash rengi: $color');

  // ANDROID
  final androidColorsPath = 'android/app/src/main/res/values/colors.xml';
  final androidLaunchBgPath =
      'android/app/src/main/res/drawable/launch_background.xml';
  await updateAndroidSplashColor(androidColorsPath, color);
  await updateAndroidLaunchBackground(androidLaunchBgPath);

  // iOS (Otomatik backgroundColor güncelle)
  final iosStoryboardPath = 'ios/Runner/Base.lproj/LaunchScreen.storyboard';
  await updateIOSLaunchScreenBackground(iosStoryboardPath, color);

  print('\nSplash renk güncellemesi tamamlandı!');
}

Future<void> updateIOSLaunchScreenBackground(String path, String color) async {
  final file = File(path);
  if (!file.existsSync()) {
    print('iOS LaunchScreen.storyboard bulunamadı: $path');
    return;
  }
  String content = file.readAsStringSync();

  // Yedek al
  final backupPath = path + '.bak';
  if (!File(backupPath).existsSync()) {
    file.copySync(backupPath);
    print('LaunchScreen.storyboard için yedek oluşturuldu: $backupPath');
  }

  // Renk kodunu storyboard formatına çevir (ör: #FF0000 -> 1.0 0.0 0.0 1)
  final rgba = hexToStoryboardColor(color);
  final regex = RegExp(r'<color key="backgroundColor"[^>]*/>');
  if (regex.hasMatch(content)) {
    content = content.replaceAll(regex,
        '<color key="backgroundColor" ${rgba} colorSpace="custom" customColorSpace="sRGB"/>');
    file.writeAsStringSync(content);
    print('iOS LaunchScreen.storyboard backgroundColor güncellendi.');
  } else {
    print(
        'LaunchScreen.storyboard içinde <color key="backgroundColor" ... /> bulunamadı. Manuel değiştirmeniz gerekebilir.');
  }
}

String hexToStoryboardColor(String hex) {
  // #RRGGBB veya #AARRGGBB destekler
  String hexCode = hex.replaceAll('#', '');
  double a = 1.0, r = 1.0, g = 1.0, b = 1.0;
  if (hexCode.length == 6) {
    r = int.parse(hexCode.substring(0, 2), radix: 16) / 255.0;
    g = int.parse(hexCode.substring(2, 4), radix: 16) / 255.0;
    b = int.parse(hexCode.substring(4, 6), radix: 16) / 255.0;
  } else if (hexCode.length == 8) {
    a = int.parse(hexCode.substring(0, 2), radix: 16) / 255.0;
    r = int.parse(hexCode.substring(2, 4), radix: 16) / 255.0;
    g = int.parse(hexCode.substring(4, 6), radix: 16) / 255.0;
    b = int.parse(hexCode.substring(6, 8), radix: 16) / 255.0;
  }
  return 'red=\"${r.toStringAsFixed(6)}\" green=\"${g.toStringAsFixed(6)}\" blue=\"${b.toStringAsFixed(6)}\" alpha=\"${a.toStringAsFixed(6)}\"';
}

Future<void> updateAndroidSplashColor(String path, String color) async {
  final file = File(path);
  if (!file.existsSync()) {
    print('Android colors.xml bulunamadı: $path');
    return;
  }
  String content = file.readAsStringSync();
  final regex = RegExp(r'<color name="splash_color">(.*?)<\/color>');
  if (regex.hasMatch(content)) {
    content =
        content.replaceAll(regex, '<color name="splash_color">$color</color>');
  } else {
    // splash_color yoksa ekle
    content = content.replaceFirst('</resources>',
        '  <color name="splash_color">$color</color>\n</resources>');
  }
  file.writeAsStringSync(content);
  print('Android splash_color güncellendi.');
}

Future<void> updateAndroidLaunchBackground(String path) async {
  final file = File(path);
  if (!file.existsSync()) {
    print('Android launch_background.xml bulunamadı: $path');
    return;
  }
  String content = file.readAsStringSync();
  final regex = RegExp(r'<item android:drawable="@color/splash_color" ?/>');
  if (!regex.hasMatch(content)) {
    // splash_color referansı yoksa ekle
    content = content.replaceFirst(
        '<layer-list xmlns:android="http://schemas.android.com/apk/res/android">',
        '<layer-list xmlns:android="http://schemas.android.com/apk/res/android">\n  <item android:drawable="@color/splash_color" />');
    file.writeAsStringSync(content);
    print('Android launch_background.xml splash_color referansı eklendi.');
  } else {
    print(
        'Android launch_background.xml zaten splash_color referansı içeriyor.');
  }
}
