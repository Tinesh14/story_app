import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/features/login/cubit/login_cubit.dart';
import 'package:story_app/features/login/cubit/login_state.dart';
import 'package:story_app/utils/snackbar.dart';
import 'package:story_app/widget/error.dart';
import 'package:story_app/widget/offline.dart';

class LoginUi extends StatefulWidget {
  final Function() onLogin;
  final Function() onRegister;
  const LoginUi({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  State<LoginUi> createState() => _LoginUiState();
}

class _LoginUiState extends State<LoginUi> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Screen"),
      ),
      body: BlocProvider<LoginCubit>(
        create: (context) => LoginCubit(
          ApiService(),
        ),
        child: BlocConsumer<LoginCubit, LoginState>(
          buildWhen: (previous, current) =>
              current is! LoginSuccess || current is! LoginMessage,
          builder: (BuildContext context, LoginState state) {
            if (state is LoginInitial || state is LoginLoading) {
              var isLoading = state is LoginLoading;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email.';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: "Email",
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: "Password",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: () {
                                  if (formKey.currentState?.validate() ??
                                      false) {
                                    BlocProvider.of<LoginCubit>(context).login(
                                        emailController.text,
                                        passwordController.text);
                                  }
                                },
                                child: const Text(
                                  'Login',
                                ),
                              ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            emailController.clear();
                            passwordController.clear();
                            widget.onRegister();
                          },
                          child: const Text("Register"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is LoginOffline) {
              return OfflineAnimation(
                onPressed: () {
                  BlocProvider.of<LoginCubit>(context)
                      .login(emailController.text, passwordController.text);
                },
              );
            } else if (state is LoginError) {
              return ErrorAnimation(
                onPressed: () {
                  BlocProvider.of<LoginCubit>(context)
                      .login(emailController.text, passwordController.text);
                },
                message: state.message,
              );
            } else {
              return const SizedBox.shrink();
            }
          },
          listener: (BuildContext context, LoginState state) {
            if (state is LoginSuccess) {
              emailController.clear();
              passwordController.clear();
              widget.onLogin();
            } else if (state is LoginMessage) {
              showShortSnackBar(context, state.message);
            } else if (state is LoginError || state is LoginOffline) {}
          },
        ),
      ),
    );
  }
}
