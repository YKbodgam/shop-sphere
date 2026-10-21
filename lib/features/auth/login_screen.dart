import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/shopsphere_components.dart';
import 'auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final form = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;
  bool remember = false;
  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.go('/onboarding'),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                ),
              ),
              SizedBox(height: 22.h),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to continue shopping',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 26.h),
              TextFormField(
                controller: username,
                autofillHints: const [AutofillHints.username],
                decoration: const InputDecoration(
                  hintText: 'username',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v == null || v.trim().length < 3
                    ? 'Enter a valid username'
                    : null,
              ),
              SizedBox(height: 14.h),
              TextFormField(
                controller: password,
                autofillHints: const [AutofillHints.password],
                obscureText: obscure,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: 'Show password',
                    onPressed: () => setState(() => obscure = !obscure),
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: (v) => v == null || v.length < 6
                    ? 'Use at least 6 characters'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: remember,
                    onChanged: (value) =>
                        setState(() => remember = value ?? false),
                    activeColor: AppTheme.primary,
                  ),
                  const Text('Remember me', style: TextStyle(fontSize: 12)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (_, state) => state is AuthFailure
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          state.message,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (_, state) => PrimaryButton(
                  label: 'Login',
                  onPressed: state is AuthLoading
                      ? null
                      : () {
                          if (form.currentState!.validate()) {
                            context.read<AuthCubit>().login(
                              username.text.trim(),
                              password.text,
                            );
                          }
                        },
                ),
              ),
              SizedBox(height: 24.h),
              const _Divider(),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Text(
                  'G',
                  style: TextStyle(
                    color: Color(0xFF4285F4),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                label: const Text('Continue with Google'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.apple, color: Colors.black),
                label: const Text('Continue with Apple'),
              ),
              SizedBox(height: 28.h),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Don't have an account?  Sign Up"),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text('or', style: Theme.of(context).textTheme.bodySmall),
      ),
      const Expanded(child: Divider()),
    ],
  );
}
