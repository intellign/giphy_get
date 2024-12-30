import 'package:flutter/widgets.dart';
import 'package:giphy_get/src/client/models/languages.dart';
import 'package:giphy_get/src/client/models/rating.dart';

class TabProvider with ChangeNotifier {
  bool isUsingAddTopMediaWidgets;
  bool showAddTopMediaWidgets;
  String apiKey;
  Color? tabColor;
  Color? textSelectedColor;
  Color? textUnselectedColor;
  String? searchText;
  String rating = GiphyRating.g;
  String lang = GiphyLanguage.english;
  String randomID = "";

  String? _tabType;
  String get tabType => _tabType ?? '';
  set tabType(String tabType) {
    _tabType = tabType;
    notifyListeners();
  }

  TabProvider({
    required this.apiKey,
    this.isUsingAddTopMediaWidgets = false,
    this.showAddTopMediaWidgets = false,
    this.tabColor,
    this.textSelectedColor,
    this.textUnselectedColor,
    this.searchText,
    required this.rating,
    required this.randomID,
    required this.lang,
  });

  void setTabColor(Color tabColor0) {
    tabColor = tabColor0;
    notifyListeners();
  }

  void setShowAddTopMediaWidgets(bool state) {
    showAddTopMediaWidgets = state;
    notifyListeners();
  }
}

class ScrollingProvider extends ChangeNotifier {
  bool showScrollbtn = false;

  /// true if scrolled to top, null if user hasn't scrolled yet
  bool? scrolledToTop;

  void updateScrolling(bool state) {
    showScrollbtn = state;
    scrolledToTop = !state;

    notifyListeners();
  }
}
