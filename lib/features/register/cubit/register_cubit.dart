import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/features/register/cubit/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final ApiService apiService;
  RegisterCubit(this.apiService) : super(RegisterInitial());

  register(String name, String email, String password) async {
    if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
      try {
        emit(RegisterLoading());
        var response = await apiService.register(name, email, password);
        if (!(response['error'] ?? false)) {
          emit(RegisterSuccess());
        }
        emit(RegisterMessage(
            message: response['message'] ?? 'Gagal Register !!!'));
        emit(RegisterInitial());
      } catch (e) {
        if (e is SocketException) {
          emit(RegisterOffline());
        } else {
          emit(const RegisterError(message: 'Something Went Wrong !!!'));
        }
      }
    } else {
      emit(const RegisterMessage(message: 'Silahkan isi semua field !!!'));
    }
  }

  loadAgain(String name, String email, String password) async {
    emit(RegisterInitial());
    await register(name, email, password);
  }
}
