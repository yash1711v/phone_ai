import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// Theme state
class ThemeState extends Equatable {
  final bool isDarkMode;

  const ThemeState({required this.isDarkMode});

  @override
  List<Object> get props => [isDarkMode];
}

/// Theme cubit to manage theme state
class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences prefs;
  static const String _themeKey = 'is_dark_mode';

  ThemeCubit({required this.prefs}) : super(ThemeState(isDarkMode: false)) {
    _loadTheme();
  }

  /// Load theme from shared preferences
  Future<void> _loadTheme() async {
    final isDark = prefs.getBool(_themeKey) ?? false;
    emit(ThemeState(isDarkMode: isDark));
  }

  /// Toggle theme
  Future<void> toggleTheme() async {
    final newTheme = !state.isDarkMode;
    await prefs.setBool(_themeKey, newTheme);
    emit(ThemeState(isDarkMode: newTheme));
  }

  /// Set dark mode
  Future<void> setDarkMode(bool isDark) async {
    await prefs.setBool(_themeKey, isDark);
    emit(ThemeState(isDarkMode: isDark));
  }
}
