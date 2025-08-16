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
import '../../presentation/screens/donor/donor_main_screen.dart';
import '../../presentation/screens/donor/case_details_screen.dart';
import '../../presentation/screens/donor/donation_screen.dart';
import '../../presentation/screens/beneficiary/beneficiary_main_screen.dart';
import '../../presentation/screens/beneficiary/case_progress_screen.dart';
import '../../presentation/screens/shared/search_screen.dart';
import '../../presentation/screens/shared/notifications_screen.dart';
import '../../presentation/screens/shared/settings_screen.dart';
import '../../presentation/screens/shared/help_screen.dart';
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
      ],
    );
  }
}