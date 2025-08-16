import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/auth/role_selection_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/otp_verification_screen.dart';
import '../../presentation/screens/imam/imam_dashboard_screen.dart';
import '../../presentation/screens/donor/donor_dashboard_screen.dart';
import '../../presentation/screens/beneficiary/beneficiary_dashboard_screen.dart';
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
          builder: (context, state) => const ImamDashboardScreen(),
        ),
        
        // Donor Routes
        GoRoute(
          path: '/donor/dashboard',
          builder: (context, state) => const DonorDashboardScreen(),
        ),
        
        // Beneficiary Routes
        GoRoute(
          path: '/beneficiary/dashboard',
          builder: (context, state) => const BeneficiaryDashboardScreen(),
        ),
      ],
    );
  }
}