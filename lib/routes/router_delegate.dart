import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_app/features/new_story/ui/new_story_ui.dart';
import 'package:story_app/features/register/ui/register_ui.dart';
import 'package:story_app/features/list_story/ui/list_story_ui.dart';
import 'package:story_app/screen/picker_map_screen.dart';

import '../features/login/ui/login_ui.dart';
import '../features/detail_story/ui/detail_story_ui.dart';
import '../screen/splash_screen_ui.dart';
import '../utils/preferences_helper.dart';

class MyRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorKey;
  final PreferencesHelper _preferencesHelper =
      PreferencesHelper(sharedPreferences: SharedPreferences.getInstance());
  bool? isLoggedIn;

  MyRouterDelegate() : _navigatorKey = GlobalKey<NavigatorState>() {
    _init();
  }

  _init() async {
    var token = await _preferencesHelper.bearerTokenValue;
    isLoggedIn = (token?.isNotEmpty ?? false);
    Future.delayed(
        const Duration(
          seconds: 5,
        ), () {
      notifyListeners();
    });
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;
  String? selectedStory;
  List<Page> historyStack = [];
  bool isRegister = false;
  bool isAddStory = false;
  bool isPickerLocation = false;
  Function? refreshListStory;
  Function(geo.Placemark placemark, LatLng location)? callbackPickerLocation;
  LatLng? selectedLocation;
  List<Page> get _splashStack => const [
        MaterialPage(
          key: ValueKey("SplashScreen"),
          child: SplashScreenUi(),
        ),
      ];
  List<Page> get _loggedInStack => [
        MaterialPage(
          key: const ValueKey("StoryListPage"),
          child: ListStoryUi(
            onTapped: (p0) {
              selectedStory = p0;
              notifyListeners();
            },
            onLogout: () async {
              await _preferencesHelper.deleteToken();
              isLoggedIn = false;
              notifyListeners();
            },
            onAddStory: (p0) {
              isAddStory = true;
              refreshListStory = p0;
              notifyListeners();
            },
          ),
        ),
        if (isAddStory)
          MaterialPage(
            key: const ValueKey("Add Story"),
            child: NewStoryUi(
              onRefreshListStory: () {
                refreshListStory?.call();
                isAddStory = false;
                notifyListeners();
              },
              onPickerMap: (p0) {
                isPickerLocation = true;
                selectedLocation = p0;
                notifyListeners();
              },
              onSetLocation: (p0) {
                callbackPickerLocation = p0;
                notifyListeners();
              },
            ),
          ),
        if (isPickerLocation && selectedLocation != null)
          MaterialPage(
            key: ValueKey(selectedLocation),
            child: PickerScreen(
              defaultLocation: selectedLocation!,
              onSetPicker: (p0, p1) {
                isPickerLocation = false;
                selectedLocation = null;
                callbackPickerLocation?.call(p0, p1);
                notifyListeners();
              },
            ),
          ),
        if (selectedStory != null)
          MaterialPage(
            key: ValueKey(selectedStory),
            child: DetailStoryUi(
              id: selectedStory ?? '',
            ),
          ),
      ];

  List<Page> get _loggedOutStack => [
        MaterialPage(
          key: const ValueKey("LoginPage"),
          child: LoginUi(
            onLogin: () {
              isLoggedIn = true;
              notifyListeners();
            },
            onRegister: () {
              isRegister = true;
              notifyListeners();
            },
          ),
        ),
        if (isRegister == true)
          MaterialPage(
            key: const ValueKey("RegisterPage"),
            child: RegisterUi(
              onRegister: () {
                isRegister = false;
                notifyListeners();
              },
              onLogin: () {
                isRegister = false;
                notifyListeners();
              },
            ),
          ),
      ];
  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      historyStack = _splashStack;
    } else if (isLoggedIn == true) {
      historyStack = _loggedInStack;
    } else {
      historyStack = _loggedOutStack;
    }
    return Navigator(
      key: navigatorKey,
      pages: historyStack,
      onPopPage: (route, result) {
        final didPop = route.didPop(result);
        if (!didPop) {
          return false;
        }

        isRegister = false;
        if (isPickerLocation && selectedLocation != null) {
          isPickerLocation = false;
          selectedLocation = null;
        } else {
          isAddStory = false;
          refreshListStory = null;
        }
        selectedStory = null;
        isPickerLocation = false;
        selectedLocation = null;
        notifyListeners();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(configuration) async {}
}
