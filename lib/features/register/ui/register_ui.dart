import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/features/register/cubit/register_cubit.dart';
import 'package:story_app/features/register/cubit/register_state.dart';
import 'package:story_app/utils/snackbar.dart';
import 'package:story_app/widget/error.dart';
import 'package:story_app/widget/offline.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterUi extends StatefulWidget {
  final Function() onLogin;
  final Function() onRegister;
  const RegisterUi({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  State<RegisterUi> createState() => _RegisterUiState();
}

class _RegisterUiState extends State<RegisterUi> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(locale!.registerTitle),
      ),
      body: BlocProvider<RegisterCubit>(
        create: (context) => RegisterCubit(
          ApiService(),
        ),
        child: BlocConsumer<RegisterCubit, RegisterState>(
          buildWhen: (previous, current) =>
              current is! RegisterSuccess || current is! RegisterMessage,
          builder: (context, state) {
            if (state is RegisterInitial || state is RegisterLoading) {
              var isLoading = state is RegisterLoading;
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
                          controller: nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return locale.validateName;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: locale.name,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                                    BlocProvider.of<RegisterCubit>(context)
                                        .register(
                                      nameController.text,
                                      emailController.text,
                                      passwordController.text,
                                    );
                                  }
                                },
                                child: Text(
                                  locale.register,
                                ),
                              ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            nameController.clear();
                            emailController.clear();
                            passwordController.clear();
                            widget.onLogin();
                          },
                          child: Text(
                            locale.login,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is RegisterOffline) {
              return OfflineAnimation(
                onPressed: () {
                  BlocProvider.of<RegisterCubit>(context).register(
                    nameController.text,
                    emailController.text,
                    passwordController.text,
                  );
                },
              );
            } else if (state is RegisterError) {
              return ErrorAnimation(
                onPressed: () {
                  BlocProvider.of<RegisterCubit>(context).register(
                    nameController.text,
                    emailController.text,
                    passwordController.text,
                  );
                },
                message: state.message,
              );
            } else {
              return const SizedBox.shrink();
            }
          },
          listener: (context, state) {
            if (state is RegisterSuccess) {
              nameController.clear();
              emailController.clear();
              passwordController.clear();
              widget.onRegister();
            } else if (state is RegisterMessage) {
              showShortSnackBar(context, state.message);
            }
          },
        ),
      ),
    );
  }
}
