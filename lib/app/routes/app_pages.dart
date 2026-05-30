import 'package:get/get.dart';
import 'package:skylark/app/modules/booking/booking_binding.dart';
import 'package:skylark/app/modules/booking/booking_screen.dart';
import 'package:skylark/app/modules/dashboard/dashboard_binding.dart';
import 'package:skylark/app/modules/dashboard/dashboard_screen.dart';
import 'package:skylark/app/modules/login/login_binding.dart';
import 'package:skylark/app/modules/login/login_screen.dart';
import 'package:skylark/app/modules/splash/splash_binding.dart';
import 'package:skylark/app/modules/splash/splash_screen.dart';
import 'package:skylark/app/modules/prs/prs_binding.dart';
import 'package:skylark/app/modules/prs/prs_screen.dart';
import 'package:skylark/app/modules/prs_closure/prs_closure_binding.dart';
import 'package:skylark/app/modules/prs_closure/prs_closure_screen.dart';
import 'package:skylark/app/modules/drs/drs_binding.dart';
import 'package:skylark/app/modules/drs/drs_screen.dart';
import 'package:skylark/app/modules/drs_closure/drs_closure_binding.dart';
import 'package:skylark/app/modules/drs_closure/drs_closure_screen.dart';
import 'package:skylark/app/modules/stock_update/stock_update_binding.dart';
import 'package:skylark/app/modules/stock_update/stock_update_screen.dart';
import 'package:skylark/app/modules/stock_update/sub_screen/stock_update_detail_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.booking,
      page: () => const BookingScreen(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: AppRoutes.prs,
      page: () => const PrsScreen(),
      binding: PrsBinding(),
    ),
    GetPage(
      name: AppRoutes.prsClosure,
      page: () => const PrsClosureScreen(),
      binding: PrsClosureBinding(),
    ),
    GetPage(
      name: AppRoutes.stockUpdate,
      page: () => const StockUpdateScreen(),
      binding: StockUpdateBinding(),
    ),
    GetPage(
      name: AppRoutes.stockUpdateDetail,
      page: () => const StockUpdateDetailScreen(),
      binding: StockUpdateBinding(),
    ),
    GetPage(
      name: AppRoutes.drsGeneration,
      page: () => const DrsScreen(),
      binding: DrsBinding(),
    ),
    GetPage(
      name: AppRoutes.drsClosure,
      page: () => const DrsClosureScreen(),
      binding: DrsClosureBinding(),
    ),
  ];
}
