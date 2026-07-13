import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/screens/add_edit_dentist_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/manage_appointments_screen.dart';
import '../../features/admin/presentation/screens/manage_dentists_screen.dart';
import '../../features/admin/presentation/screens/manage_reviews_screen.dart';
import '../../features/admin/presentation/screens/manage_services_screen.dart';
import '../../features/admin/presentation/screens/manage_users_screen.dart';
import '../../features/admin/presentation/screens/statistics_screen.dart';
import '../../features/appointments/presentation/screens/appointment_details_screen.dart';
import '../../features/appointments/presentation/screens/book_appointment_screen.dart';
import '../../features/appointments/presentation/screens/my_appointments_screen.dart';
import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/onboarding_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/dentists/presentation/screens/dentist_details_screen.dart';
import '../../features/dentists/presentation/screens/dentists_list_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/contact_us_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/reviews/presentation/screens/reviews_list_screen.dart';
import '../../features/reviews/presentation/screens/write_review_screen.dart';
import '../../features/services/presentation/screens/clinic_services_screen.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';
import 'router_notifier.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider.notifier);
  final prefs = ref.read(sharedPreferencesProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isAuthenticated = notifier.isAuthenticated;
      final location = state.matchedLocation;

      // Navigate away from splash as soon as Firebase Auth state is known.
      if (location == '/') {
        if (!isAuthenticated) {
          final onboardingShown =
              prefs.getBool(AppConstants.onboardingShownKey) ?? false;
          return onboardingShown ? '/login' : '/onboarding';
        }
        // Firestore may not have loaded yet — default to /home.
        // If user turns out to be admin (loaded in background) the redirect
        // below will fire when the router refreshes.
        final user = notifier.currentUser;
        if (user != null && user.isAdmin) return '/admin/dashboard';
        return '/home';
      }

      // Once the Firestore profile arrives and user is confirmed admin,
      // redirect them from /home to the admin dashboard.
      if (location == '/home') {
        final user = notifier.currentUser;
        if (user != null && user.isAdmin) return '/admin/dashboard';
      }

      const publicPaths = [
        '/onboarding',
        '/login',
        '/register',
        '/forgot-password',
      ];

      if (!isAuthenticated) {
        if (publicPaths.contains(location)) return null;
        return '/login';
      }

      final user = notifier.currentUser;

      // Firestore profile not yet loaded — stay on current page, don't bounce
      // to /login. The router will refresh once the profile arrives.
      if (user == null) return null;

      if (publicPaths.contains(location)) {
        if (user.isAdmin) return '/admin/dashboard';
        return '/home';
      }

      if (location.startsWith('/admin') && !user.isAdmin) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _slideTransition(
          state,
          const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _slideTransition(
          state,
          const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _slideTransition(
          state,
          const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => _slideTransition(
          state,
          const ForgotPasswordScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => _ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _slideTransition(state, const HomeScreen()),
          ),
          GoRoute(
            path: '/dentists',
            pageBuilder: (context, state) =>
                _slideTransition(state, const DentistsListScreen()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) => _slideTransition(
                  state,
                  DentistDetailsScreen(dentistId: state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/services',
            pageBuilder: (context, state) =>
                _slideTransition(state, const ClinicServicesScreen()),
          ),
          GoRoute(
            path: '/appointments',
            pageBuilder: (context, state) =>
                _slideTransition(state, const MyAppointmentsScreen()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) => _slideTransition(
                  state,
                  AppointmentDetailsScreen(
                    appointmentId: state.pathParameters['id']!,
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) =>
                _slideTransition(state, const NotificationsScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                _slideTransition(state, const ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/book/:dentistId',
        pageBuilder: (context, state) => _slideTransition(
          state,
          BookAppointmentScreen(dentistId: state.pathParameters['dentistId']!),
        ),
      ),
      GoRoute(
        path: '/reviews/:dentistId',
        pageBuilder: (context, state) => _slideTransition(
          state,
          ReviewsListScreen(dentistId: state.pathParameters['dentistId']!),
        ),
      ),
      GoRoute(
        path: '/write-review/:dentistId',
        pageBuilder: (context, state) => _slideTransition(
          state,
          WriteReviewScreen(dentistId: state.pathParameters['dentistId']!),
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        pageBuilder: (context, state) =>
            _slideTransition(state, const EditProfileScreen()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) =>
            _slideTransition(state, const SettingsScreen()),
      ),
      GoRoute(
        path: '/contact',
        pageBuilder: (context, state) =>
            _slideTransition(state, const ContactUsScreen()),
      ),
      GoRoute(
        path: '/admin/dashboard',
        pageBuilder: (context, state) =>
            _slideTransition(state, const AdminDashboardScreen()),
      ),
      GoRoute(
        path: '/admin/dentists',
        pageBuilder: (context, state) =>
            _slideTransition(state, const ManageDentistsScreen()),
      ),
      GoRoute(
        path: '/admin/dentists/add',
        pageBuilder: (context, state) =>
            _slideTransition(state, const AddEditDentistScreen()),
      ),
      GoRoute(
        path: '/admin/dentists/:id/edit',
        pageBuilder: (context, state) => _slideTransition(
          state,
          AddEditDentistScreen(dentistId: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: '/admin/appointments',
        pageBuilder: (context, state) =>
            _slideTransition(state, const ManageAppointmentsScreen()),
      ),
      GoRoute(
        path: '/admin/services',
        pageBuilder: (context, state) =>
            _slideTransition(state, const ManageServicesScreen()),
      ),
      GoRoute(
        path: '/admin/users',
        pageBuilder: (context, state) =>
            _slideTransition(state, const ManageUsersScreen()),
      ),
      GoRoute(
        path: '/admin/reviews',
        pageBuilder: (context, state) =>
            _slideTransition(state, const ManageReviewsScreen()),
      ),
      GoRoute(
        path: '/admin/statistics',
        pageBuilder: (context, state) =>
            _slideTransition(state, const StatisticsScreen()),
      ),
    ],
  );
});

CustomTransitionPage _slideTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOutCubic;
      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

class _ScaffoldWithNavBar extends ConsumerStatefulWidget {
  const _ScaffoldWithNavBar({required this.child});
  final Widget child;

  @override
  ConsumerState<_ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<_ScaffoldWithNavBar> {
  int _selectedIndex = 0;

  static const _routes = ['/home', '/dentists', '/appointments', '/notifications', '/profile'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;
    _selectedIndex = _routes.indexWhere((r) => location.startsWith(r));
    if (_selectedIndex < 0) _selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex.clamp(0, 4),
        onTap: (index) {
          if (index != _selectedIndex) {
            context.go(_routes[index]);
            setState(() => _selectedIndex = index);
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context).home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_outline),
            activeIcon: const Icon(Icons.people),
            label: AppLocalizations.of(context).dentists,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            activeIcon: const Icon(Icons.calendar_today),
            label: AppLocalizations.of(context).myAppointments,
          ),
          BottomNavigationBarItem(
            icon: const _NotificationIcon(active: false),
            activeIcon: const _NotificationIcon(active: true),
            label: AppLocalizations.of(context).notifications,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: AppLocalizations.of(context).profile,
          ),
        ],
      ),
    );
  }
}

class _NotificationIcon extends ConsumerWidget {
  const _NotificationIcon({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(active ? Icons.notifications : Icons.notifications_outlined),
      ],
    );
  }
}
