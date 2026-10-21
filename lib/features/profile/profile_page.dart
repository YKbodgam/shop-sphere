import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'profile_cubit.dart';

class ProfilePageView extends StatelessWidget {
  const ProfilePageView({super.key, required this.onLogout});
  final VoidCallback onLogout;
  @override
  Widget build(BuildContext context) => BlocBuilder<ProfileCubit, ProfileState>(
    builder: (context, state) {
      if (state is ProfileLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state is ProfileFailure) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.message),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.read<ProfileCubit>().load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
      final user = (state as ProfileReady).user;
      return RefreshIndicator(
        onRefresh: () => context.read<ProfileCubit>().load(),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            CircleAvatar(
              radius: 48,
              child: Text(user.firstName.isEmpty ? '?' : user.firstName[0]),
            ),
            const SizedBox(height: 16),
            Text(
              '${user.firstName} ${user.lastName}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(user.email, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: const Text('Phone'),
                subtitle: Text(user.phone),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(onPressed: onLogout, child: const Text('Log out')),
          ],
        ),
      );
    },
  );
}
