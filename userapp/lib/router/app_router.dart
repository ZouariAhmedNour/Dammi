import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:userapp/models/appointment_models.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/screens/all_blood_requests_screen.dart';
import 'package:userapp/screens/blood_request_history_screen.dart';
import 'package:userapp/screens/history_rdv_screen.dart';
import 'package:userapp/screens/home_screen.dart';
import 'package:userapp/screens/login_screen.dart';
import 'package:userapp/screens/main_shell.dart';
import 'package:userapp/screens/map_screen.dart';
import 'package:userapp/screens/new_blood_request_screen.dart';
import 'package:userapp/screens/new_rendez_vous_screen.dart';
import 'package:userapp/screens/profile_screen.dart';
import 'package:userapp/screens/questionnaire_eligibilite_screen.dart';
import 'package:userapp/screens/register_screen.dart';
import 'package:userapp/screens/rendez_vous_result_screen.dart';
import 'package:userapp/screens/request_response_questionnaire_screen.dart';
import 'package:userapp/screens/urgent_blood_requests_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final showRegisteredDialog =
              state.uri.queryParameters['registered'] == '1';

          return LoginScreen(showRegisteredDialog: showRegisteredDialog);
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/appointment/new/:pointId',
        builder: (context, state) {
          final pointId = int.parse(state.pathParameters['pointId']!);
          return NewRendezVousScreen(pointId: pointId);
        },
      ),
      GoRoute(
        path: '/appointment/questionnaire',
        builder: (context, state) => const QuestionnaireEligibiliteScreen(),
      ),
      GoRoute(
        path: '/appointment/result',
        builder: (context, state) {
          final args = state.extra as AppointmentResultArgs;
          return RendezVousResultScreen(args: args);
        },
      ),
       GoRoute(
  path: '/request_response_questionnaire/:demandeId',
  builder: (context, state) {
    final demandeId = int.parse(state.pathParameters['demandeId']!);
    return RequestResponseQuestionnaireScreen(demandeId: demandeId);
  },
),

      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
          GoRoute(
            path: '/historyRDV',
            builder: (context, state) => const HistoryRDVScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/request/new',
            builder: (context, state) => const NewBloodRequestScreen(),
          ),
          GoRoute(
            path: '/request/history',
            builder: (context, state) => const BloodRequestHistoryScreen(),
          ),
          GoRoute(
            path: '/demandes-urgentes',
            builder: (context, state) => const UrgentBloodRequestsScreen(),
          ),
          GoRoute(
            path: '/demandes',
            builder: (context, state) => const AllBloodRequestsScreen(),
          ),
         
        ],
      ),
    ],
    redirect: (context, state) {
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      final isLoggedIn = auth.status == AuthStatus.authenticated;

      if (auth.status == AuthStatus.loading ||
          auth.status == AuthStatus.initial) {
        return null;
      }

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },
  );
});
