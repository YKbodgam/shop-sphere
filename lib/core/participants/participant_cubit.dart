import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

class ParticipantState {
  const ParticipantState(this.count);
  final int count;
}

class ParticipantCubit extends Cubit<ParticipantState> {
  ParticipantCubit() : super(const ParticipantState(0)) {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      emit(ParticipantState(state.count + 1));
    });
  }
  late final Timer _timer;
  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
