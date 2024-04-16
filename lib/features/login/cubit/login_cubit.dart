import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/features/login/cubit/login_state.dart';

import '../../../utils/preferences_helper.dart';

class LoginCubit extends Cubit<LoginState> {
  final ApiService apiService;
  final PreferencesHelper _preferencesHelper =
      PreferencesHelper(sharedPreferences: SharedPreferences.getInstance());
  LoginCubit(this.apiService) : super(LoginInitial());

  login(String email, String password) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        emit(LoginLoading());
        var response = await apiService.login(email, password);
        if (response.loginResult?.token?.isNotEmpty ?? false) {
          _preferencesHelper.setBearerToken(response.loginResult?.token ?? '');
          emit(LoginSuccess());
        } else {
          emit(LoginMessage(message: response.message ?? 'Gagal Login !!!'));
        }
        emit(LoginInitial());
      } catch (e) {
        if (e is SocketException) {
          emit(LoginOffline());
        } else {
          emit(const LoginError(message: 'Something Went Wrong !!!'));
        }
      }
    } else {
      emit(const LoginMessage(
          message: 'Email atau Password tidak boleh kosong'));
    }
  }
}
