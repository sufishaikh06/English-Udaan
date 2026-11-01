import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_client.dart';
import '../../progress/data/progress_repository.dart';
import '../data/cloud_progress_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentAuthUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final authService = ref.watch(authServiceProvider);
  final client = ApiClient(
    tokenProvider: () => authService.getIdToken(),
  );
  debugPrint('[api] configured_base=${client.baseUrl}');
  return client;
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

final cloudProgressServiceProvider = Provider<CloudProgressService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final authService = ref.watch(authServiceProvider);
  final localRepo = ref.watch(progressRepositoryProvider);
  return CloudProgressService(
    apiClient: apiClient,
    authService: authService,
    localRepo: localRepo,
  );
});
