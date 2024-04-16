import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_app/data/model/login.dart';
import 'package:story_app/data/model/story.dart';
import 'package:story_app/utils/preferences_helper.dart';

class ApiService {
  static const String _baseUrl = 'https://story-api.dicoding.dev/v1';
  final PreferencesHelper _preferencesHelper =
      PreferencesHelper(sharedPreferences: SharedPreferences.getInstance());
  Future<Map> register(String name, String email, String password) async {
    try {
      Map<String, dynamic> data = {
        "name": name,
        "email": email,
        "password": password,
      };
      final response = await http.post(
        Uri.parse("$_baseUrl/register"),
        body: data,
      );
      // if (response.statusCode == 201) {
      return jsonDecode(response.body);
      // } else {
      //   throw Exception('Failed to register');
      // }
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginResult> login(String email, String password) async {
    try {
      Map<String, dynamic> data = {
        "email": email,
        "password": password,
      };
      final response = await http.post(
        Uri.parse("$_baseUrl/login"),
        body: data,
      );
      return LoginResult.fromJson(jsonDecode(response.body));
      // if () {
      //   return LoginResult.fromJson(jsonDecode(response.body));
      // } else {
      //   throw Exception('Failed to login');
      // }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addNewStory(String description, File photo,
      {double? lat, double? lon}) async {
    try {
      Map<String, dynamic> data = {
        "description": description,
        "photo": photo,
        "lat": lat,
        "lon": lon,
      };
      var token = _preferencesHelper.bearerTokenValue; //get token from storage
      final response = await http.post(
        Uri.parse("$_baseUrl/stories"),
        headers: {
          "Content-Type": "multipart/form-data",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to addNewStory');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ListStory> getAllStories({int? page, int? size, int? location}) async {
    try {
      var token = _preferencesHelper.bearerTokenValue; //get token from storage
      final response = await http.get(
        Uri.parse("$_baseUrl/stories?page=$page&size=$size&location=$location"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        return ListStory.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to getAllStories');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Story> detailStory(String id) async {
    try {
      var token = _preferencesHelper.bearerTokenValue; //get token from storage
      final response = await http.get(
        Uri.parse("$_baseUrl/stories/$id"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        return Story.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to getAllStories');
      }
    } catch (e) {
      rethrow;
    }
  }
}
