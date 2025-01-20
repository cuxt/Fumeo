import 'package:flutter/material.dart';
import 'package:fumeo/bindings/app.dart';
import 'package:fumeo/routes/routes.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/adapters.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('todo_box');

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
