import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/auth_repository.dart';

sealed class ProfileState { const ProfileState(); }
final class ProfileLoading extends ProfileState { const ProfileLoading(); }
final class ProfileReady extends ProfileState { const ProfileReady(this.user); final SessionUser user; }
final class ProfileFailure extends ProfileState { const ProfileFailure(this.message); final String message; }

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this.repository) : super(const ProfileLoading());
  final AuthRepository repository;
  Future<void> load() async {
    emit(const ProfileLoading());
    try { emit(ProfileReady(await repository.me())); }
    catch (_) { emit(const ProfileFailure('Unable to load your profile. Please try again.')); }
  }
}
