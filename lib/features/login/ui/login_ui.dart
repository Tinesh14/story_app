import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/features/login/cubit/login_cubit.dart';
import 'package:story_app/features/login/cubit/login_state.dart';
import 'package:story_app/utils/snackbar.dart';
import 'package:story_app/widget/error.dart';
import 'package:story_app/widget/offline.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    var locale = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(locale!.loginTitle),
      ),
      body: BlocProvider<LoginCubit>(
        create: (context) => LoginCubit(
          ApiService(),
          locale: locale,
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
                              return locale.validateEmail;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: locale.email,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: locale.password,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return locale.validatePassword;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  if (formKey.currentState?.validate() ??
                                      false) {
                                    BlocProvider.of<LoginCubit>(context).login(
                                        emailController.text,
                                        passwordController.text);
                                  }
                                },
                                child: Text(
                                  locale.login,
                                ),
                              ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            emailController.clear();
                            passwordController.clear();
                            widget.onRegister();
                          },
                          child: Text(locale.register),
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
