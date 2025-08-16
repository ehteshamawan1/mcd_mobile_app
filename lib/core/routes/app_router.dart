import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/auth/role_selection_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/otp_verification_screen.dart';
import '../../presentation/screens/imam/imam_main_screen.dart';
import '../../presentation/screens/imam/case_details_screen.dart';
import '../../presentation/screens/imam/create_case_screen.dart';
import '../../presentation/screens/imam/edit_case_screen.dart';
import '../../presentation/screens/imam/beneficiary_verification_screen.dart';
import '../../presentation/screens/imam/imam_notifications_screen.dart';
import '../../presentation/screens/donor/donor_main_screen.dart';
import '../../presentation/screens/donor/donor_notifications_screen.dart';
import '../../presentation/screens/donor/browse_cases_screen.dart';
import '../../presentation/screens/donor/donation_history_screen.dart';
import '../../presentation/screens/beneficiary/beneficiary_notifications_screen.dart';
import '../../presentation/screens/donor/case_details_screen.dart';
import '../../presentation/screens/donor/donation_screen.dart';
import '../../presentation/screens/beneficiary/beneficiary_main_screen.dart';
import '../../presentation/screens/beneficiary/case_progress_screen.dart';
import '../../presentation/screens/beneficiary/submit_case_screen.dart';
import '../../presentation/screens/beneficiary/my_cases_screen.dart';
import '../../presentation/screens/shared/search_screen.dart';
import '../../presentation/screens/shared/notifications_screen.dart';
import '../../presentation/screens/shared/settings_screen.dart';
import '../../presentation/screens/shared/help_screen.dart';
import '../../presentation/screens/shared/mosque_library_screen.dart';
import '../../data/models/user_model.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  static GoRouter router(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isAuthRoute = state.matchedLocation == '/splash' ||
            state.matchedLocation == '/role-selection' ||
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/otp-verification';

        if (!isAuthenticated && !isAuthRoute) {
          return '/role-selection';
        }

        if (isAuthenticated && isAuthRoute && state.matchedLocation != '/splash') {
          // Redirect to appropriate dashboard based on role
          final userRole = authProvider.user?.role;
          switch (userRole) {
            case UserRole.imam:
              return '/imam/dashboard';
            case UserRole.donor:
              return '/donor/dashboard';
            case UserRole.beneficiary:
              return '/beneficiary/dashboard';
            default:
              return '/role-selection';
          }
        }

        return null;
      },
      routes: [
        // Auth Routes
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/role-selection',
          builder: (context, state) => const RoleSelectionScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final role = extra?['role'] as UserRole? ?? UserRole.donor;
            return LoginScreen(selectedRole: role);
          },
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final role = extra?['role'] as UserRole? ?? UserRole.donor;
            return RegisterScreen(selectedRole: role);
          },
        ),
        GoRoute(
          path: '/otp-verification',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final phoneNumber = extra?['phoneNumber'] as String? ?? '';
            return OtpVerificationScreen(phoneNumber: phoneNumber);
          },
        ),
        
        // Imam Routes
        GoRoute(
          path: '/imam/dashboard',
          builder: (context, state) => const ImamMainScreen(),
        ),
        GoRoute(
          path: '/imam/case-details/:id',
          builder: (context, state) {
            final caseId = state.pathParameters['id'] ?? '';
            return ImamCaseDetailsScreen(caseId: caseId);
          },
        ),
        GoRoute(
          path: '/imam/create-case',
          builder: (context, state) => const CreateCaseScreen(),
        ),
        GoRoute(
          path: '/imam/edit-case/:id',
          builder: (context, state) {
            final caseId = state.pathParameters['id'] ?? '';
            return EditCaseScreen(caseId: caseId);
          },
        ),
        GoRoute(
          path: '/imam/verify',
          builder: (context, state) => const BeneficiaryVerificationScreen(),
        ),
        GoRoute(
          path: '/imam/notifications',
          builder: (context, state) => const ImamNotificationsScreen(),
        ),
        
        // Donor Routes
        GoRoute(
          path: '/donor/dashboard',
          builder: (context, state) => const DonorMainScreen(),
        ),
        GoRoute(
          path: '/donor/case-details/:id',
          builder: (context, state) {
            final caseId = state.pathParameters['id'] ?? '';
            return CaseDetailsScreen(caseId: caseId);
          },
        ),
        GoRoute(
          path: '/donor/donate/:id',
          builder: (context, state) {
            final caseId = state.pathParameters['id'] ?? '';
            return DonationScreen(caseId: caseId);
          },
        ),
        GoRoute(
          path: '/donor/notifications',
          builder: (context, state) => const DonorNotificationsScreen(),
        ),
        GoRoute(
          path: '/donor/browse',
          builder: (context, state) => const BrowseCasesScreen(),
        ),
        GoRoute(
          path: '/donor/history',
          builder: (context, state) => const DonationHistoryScreen(),
        ),
        
        // Beneficiary Routes
        GoRoute(
          path: '/beneficiary/dashboard',
          builder: (context, state) => const BeneficiaryMainScreen(),
        ),
        GoRoute(
          path: '/beneficiary/case-progress/:id',
          builder: (context, state) {
            final caseId = state.pathParameters['id'] ?? '';
            return CaseProgressScreen(caseId: caseId);
          },
        ),
        GoRoute(
          path: '/beneficiary/notifications',
          builder: (context, state) => const BeneficiaryNotificationsScreen(),
        ),
        GoRoute(
          path: '/beneficiary/submit-case',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final editId = extra?['editId'] as String?;
            return SubmitCaseScreen(editCaseId: editId);
          },
        ),
        GoRoute(
          path: '/beneficiary/my-cases',
          builder: (context, state) => const MyCasesScreen(),
        ),
        
        // Shared Routes
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/help',
          builder: (context, state) => const HelpScreen(),
        ),
        GoRoute(
          path: '/mosque-library',
          builder: (context, state) => const MosqueLibraryScreen(),
        ),
      ],
    );
  }
}