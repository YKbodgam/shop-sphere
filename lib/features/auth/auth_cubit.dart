import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_repository.dart';
import '../../core/errors/failure.dart';

sealed class AuthState {
  const AuthState();
}

class AuthStarting extends AuthState {
  const AuthStarting();
}

class AuthSignedOut extends AuthState {
  const AuthSignedOut([this.message]);
  final String? message;
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSignedIn extends AuthState {
  const AuthSignedIn(this.user);
  final SessionUser user;
}

class AuthFailure extends AuthState {
  const AuthFailure(this.message);
  final String message;
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.repo) : super(const AuthStarting());
  final AuthRepository repo;
  Future<void> restore() async {
    try {
      emit(AuthSignedIn(await repo.restore()));
    } catch (error) {
      if (error is NetworkFailure || error is TimeoutFailure) {
        emit(AuthFailure(error.toString()));
        return;
      }
      await repo.logout();
      emit(
        const AuthSignedOut('Your session has ended. Please sign in again.'),
      );
    }
  }

  Future<void> login(String u, String p) async {
    emit(const AuthLoading());
    try {
      emit(AuthSignedIn(await repo.login(u, p)));
    } catch (error) {
      final message = error is Failure
          ? error.message
          : 'Unable to sign in. Please check your details and try again.';
      emit(AuthFailure(message));
    }
  }

  Future<void> logout([String? message]) async {
    await repo.logout();
    emit(AuthSignedOut(message));
  }
}
