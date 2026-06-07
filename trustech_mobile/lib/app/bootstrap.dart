import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Keep startup non-blocking when a local .env is absent or not bundled.
  // Env.fromSystem() already provides safe defaults for mobile builds.
  await dotenv.load(fileName: ".env", isOptional: true);

  final prefs = await SharedPreferences.getInstance();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  return prefs;
}
