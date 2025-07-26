import 'base_view_model.dart';
import 'mood_view_model.dart';

/// ViewModel for the main navigation
class NavigationViewModel extends BaseViewModel {
  int _selectedIndex = 0;
  MoodViewModel? _moodViewModel;

  NavigationViewModel(this._moodViewModel);

  int get selectedIndex => _selectedIndex;
  MoodViewModel? get moodViewModel => _moodViewModel;

  /// Change the selected tab index
  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  /// Update the mood view model dependency
  NavigationViewModel updateMoodViewModel(MoodViewModel moodViewModel) {
    _moodViewModel = moodViewModel;
    notifyListeners();
    return this;
  }

  /// Initialize the navigation view model
  Future<void> initialize() async {
    if (_moodViewModel != null) {
      await _moodViewModel!.loadMoodEntries();
    }
  }
}
