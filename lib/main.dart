import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/theme/app_theme.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/connectivity_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';
import 'package:skylark/app/routes/app_pages.dart';
import 'package:skylark/app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync(() => StorageService().init());
  Get.put(ApiService());
  await Get.putAsync(() async => ConnectivityService());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Skylark',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}
