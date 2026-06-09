import 'package:get/get.dart';
import 'package:skylark/app/modules/arrival/arrival_binding.dart';
import 'package:skylark/app/modules/arrival/arrival_screen.dart';
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
import 'package:skylark/app/modules/prs_closure/sub_screen/prs_closure_detail_screen.dart';
import 'package:skylark/app/modules/drs/drs_binding.dart';
import 'package:skylark/app/modules/drs/drs_screen.dart';
import 'package:skylark/app/modules/drs_closure/drs_closure_binding.dart';
import 'package:skylark/app/modules/drs_closure/drs_closure_screen.dart';
import 'package:skylark/app/modules/drs_closure/sub_screen/drs_closure_detail_screen.dart';
import 'package:skylark/app/modules/pod_upload/pod_upload_binding.dart';
import 'package:skylark/app/modules/pod_upload/pod_upload_screen.dart';
import 'package:skylark/app/modules/stock_update/stock_update_binding.dart';
import 'package:skylark/app/modules/stock_update/stock_update_screen.dart';
import 'package:skylark/app/modules/stock_update/sub_screen/stock_update_detail_screen.dart';
import 'package:skylark/app/modules/expense/expense_binding.dart';
import 'package:skylark/app/modules/expense/expense_screen.dart';
import 'package:skylark/app/modules/manifest/manifest_binding.dart';
import 'package:skylark/app/modules/manifest/manifest_screen.dart';
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
      name: AppRoutes.arrival,
      page: () => const ArrivalScreen(),
      binding: ArrivalBinding(),
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
      name: AppRoutes.prsClosureDetail,
      page: () => const PrsClosureDetailScreen(),
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
    GetPage(
      name: AppRoutes.drsClosureDetail,
      page: () => const DrsClosureDetailScreen(),
      binding: DrsClosureBinding(),
    ),
    GetPage(
      name: AppRoutes.podUpload,
      page: () => const PODUploadScreen(),
      binding: PODUploadBinding(),
    ),
    GetPage(
      name: AppRoutes.expense,
      page: () => const ExpenseScreen(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: AppRoutes.manifest,
      page: () => const ManifestScreen(),
      binding: ManifestBinding(),
    ),
  ];
}
