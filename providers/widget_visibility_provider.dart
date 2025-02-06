import 'package:flutter/material.dart';

class WidgetVisibilityProvider extends ChangeNotifier {
  bool _isVisible = true;
  bool get isVisible => _isVisible;

  /// Call this method to hide the widget.
  void removeWidget() {
    _isVisible = false;
    notifyListeners();
  }

  /// (Optional) Call this method to show the widget again.
  void showWidget() {
    _isVisible = true;
    notifyListeners();
  }
}
