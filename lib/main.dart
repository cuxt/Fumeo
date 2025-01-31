import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fumeo/bindings/app.dart';
import 'package:fumeo/pages/im/services/im.dart';
import 'package:fumeo/routes/routes.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  await Hive.openBox('todo_box');

  // 初始化 IM SDK
  await Get.putAsync(() => IMService().init());

  // 初始化 Supabase SDK
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fumeo',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      initialBinding: AppBinding(),
      initialRoute: '/note',
      getPages: Routes.routes,
    );
  }
}
