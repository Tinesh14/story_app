import 'dart:convert';
import 'dart:typed_data';

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
      return jsonDecode(response.body);
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
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> addNewStory(String description, List<int> bytes, String fileName,
      {double? lat, double? lon}) async {
    try {
      var token =
          await _preferencesHelper.bearerTokenValue; //get token from storage
      var request =
          http.MultipartRequest('POST', Uri.parse("$_baseUrl/stories"));
      final multiPartFile = http.MultipartFile.fromBytes(
        "photo",
        bytes,
        filename: fileName,
      );
      final Map<String, String> fields = {
        "description": description,
      };
      if (lat != null) fields['lat'] = lat.toString();
      if (lon != null) fields['lon'] = lon.toString();
      final Map<String, String> headers = {
        "Content-type": "multipart/form-data",
        "Authorization": "Bearer $token",
      };
      request.files.add(multiPartFile);
      request.fields.addAll(fields);
      request.headers.addAll(headers);
      final http.StreamedResponse streamedResponse = await request.send();
      final int statusCode = streamedResponse.statusCode;

      final Uint8List responseList = await streamedResponse.stream.toBytes();
      final String responseData = String.fromCharCodes(responseList);
      if (statusCode == 201) {
        return jsonDecode(responseData);
      } else {
        throw Exception("Upload file error");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ListStory> getAllStories({int? page, int? size, int? location}) async {
    try {
      var token =
          await _preferencesHelper.bearerTokenValue; //get token from storage
      final response = await http.get(
        Uri.parse("$_baseUrl/stories"),
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

  Future<DetailStory> detailStory(String id) async {
    try {
      var token =
          await _preferencesHelper.bearerTokenValue; //get token from storage
      final response = await http.get(
        Uri.parse("$_baseUrl/stories/$id"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        return DetailStory.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to getAllStories');
      }
    } catch (e) {
      rethrow;
    }
  }
}
