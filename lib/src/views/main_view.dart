import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:giphy_get/src/providers/sheet_provider.dart';
import 'package:giphy_get/src/views/appbar/searchappbar.dart';
import 'package:giphy_get/src/views/tab/giphy_tab_bar.dart';
import 'package:giphy_get/src/views/tab/giphy_tab_bottom.dart';
import 'package:giphy_get/src/views/tab/giphy_tab_top.dart';
import 'package:giphy_get/src/views/tab/giphy_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:giphy_get/src/providers/app_bar_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giphy_get/src/providers/tab_provider.dart';
import 'package:flutter/rendering.dart';

class MainView extends StatefulWidget {
  MainView({
    Key? key,
    required this.sharedPreferences,
    this.showEmojis = true,
    this.showGIFs = true,
    this.showStickers = true,
    this.whiteBackground = false,
    this.topDragColor,
    this.tabTopBuilder,
    this.tabBottomBuilder,
    this.searchAppBarBuilder,
    this.addMediaTopWidget,
  }) : super(key: key);
  final SharedPreferences sharedPreferences;
  final Widget? addMediaTopWidget;
  final Color? topDragColor;
  final bool whiteBackground;
  final bool showGIFs;
  final bool showStickers;
  final bool showEmojis;
  final TabTopBuilder? tabTopBuilder;
  final TabBottomBuilder? tabBottomBuilder;
  final SearchAppBarBuilder? searchAppBarBuilder;

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView>
    with SingleTickerProviderStateMixin {
  // Scroll Controller
  late ScrollController _scrollController;

  // Sheet Provider
  late SheetProvider _sheetProvider;

  // Tab Controller
  late TabController _tabController;

  int lastGiphyTabSaved = 0;

  late TextEditingController textEditingController;
  FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();

    textEditingController = new TextEditingController(
        text: Provider.of<AppBarProvider>(context, listen: false).queryText);

    lastGiphyTabSaved =
        widget.sharedPreferences.getInt("lastGiphyTabSaved") ?? 0;

    int currentFeaturesLength = [
      widget.showGIFs,
      widget.showEmojis,
      widget.showStickers,
    ].where((isShown) => isShown).length;

    if (lastGiphyTabSaved > currentFeaturesLength) {
      lastGiphyTabSaved = 0;
    }

    _tabController = TabController(
      initialIndex: lastGiphyTabSaved,
      length: currentFeaturesLength,
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final _tabProvider = Provider.of<TabProvider>(context, listen: false);

      if (widget.addMediaTopWidget != null) {
        _tabProvider.setShowAddTopMediaWidgets(true);
      }
    });
  }

  @override
  void didChangeDependencies() {
    _sheetProvider = Provider.of<SheetProvider>(context, listen: false);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    widget.sharedPreferences.setInt("lastGiphyTabSaved", _tabController.index);
  }

  @override
  Widget build(BuildContext context) {
    return _draggableScrollableSheet();
  }

  Widget _draggableScrollableSheet() => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: FractionallySizedBox(
          heightFactor: SheetProvider.maxExtent,
          child: DraggableScrollableSheet(
              expand: _sheetProvider.isExpanded,
              minChildSize: SheetProvider.minExtent,
              maxChildSize: SheetProvider.maxExtent,
              initialChildSize: _sheetProvider.initialExtent,
              builder: (ctx, scrollController) {
                // Set ScrollController

                this._scrollController = scrollController;
                return _bottomSheetBody();
              })));

  Widget _bottomSheetBody() {
    DragStartDetails? startVerticalDragDetails;
    DragUpdateDetails? updateVerticalDragDetails;
    return Center(
        child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    topLeft: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 10,
                      spreadRadius: 16,
                      color: widget.whiteBackground
                          ? Colors.white.withOpacity(0.21)
                          : Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 16))
                ]),
            child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    topLeft: Radius.circular(16)),
                child: BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: 40.0,
                      sigmaY: 40.0,
                    ),
                    child: Container(
                        decoration: BoxDecoration(
                            color: widget.whiteBackground
                                ? Colors.white.withOpacity(0.27)
                                : Colors.black.withOpacity(0.5),
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                                topLeft: Radius.circular(16)),
                            border: Border.all(
                              width: 1.5,
                              color: Colors.transparent,
                            )),
                        child: Center(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            widget.tabTopBuilder?.call(context) ??
                                GiphyTabTop(topDragColor: widget.topDragColor),
                            SizedBox(
                              height: 13,
                            ),
                            SearchAppBar(
                              scrollController: this._scrollController,
                              searchAppBarBuilder: widget.searchAppBarBuilder,
                              textEditingController: textEditingController,
                              focus: _focusNode,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Consumer<TabProvider>(
                                builder: (tabProviderContext, tabProvider, _) {
                              if (widget.addMediaTopWidget != null &&
                                  textEditingController.text.isEmpty &&
                                  !_focusNode.hasFocus) {
                                return AnimatedContainer(
                                    duration: Duration(milliseconds: 310),
                                    height: tabProvider.showAddTopMediaWidgets
                                        ? null
                                        : 0,
                                    child: tabProvider.showAddTopMediaWidgets
                                        ? GestureDetector(
                                            onVerticalDragStart: (dragDetails) {
                                              startVerticalDragDetails =
                                                  dragDetails;
                                            },
                                            onVerticalDragUpdate:
                                                (dragDetails) {
                                              updateVerticalDragDetails =
                                                  dragDetails;
                                            },
                                            onVerticalDragEnd: (endDetails) {
                                              if (startVerticalDragDetails !=
                                                      null &&
                                                  updateVerticalDragDetails !=
                                                      null) {
                                                double dx =
                                                    updateVerticalDragDetails!
                                                            .globalPosition.dx -
                                                        startVerticalDragDetails!
                                                            .globalPosition.dx;
                                                double dy =
                                                    updateVerticalDragDetails!
                                                            .globalPosition.dy -
                                                        startVerticalDragDetails!
                                                            .globalPosition.dy;
                                                double? velocity =
                                                    endDetails.primaryVelocity;

                                                //Convert values to be positive
                                                if (dx < 0) dx = -dx;
                                                if (dy < 0) dy = -dy;

                                                if (velocity != null &&
                                                    velocity < 0) {
                                                  //scroll up
                                                  if (tabProvider
                                                      .showAddTopMediaWidgets)
                                                    tabProvider
                                                        .setShowAddTopMediaWidgets(
                                                            false);
                                                } else {
                                                  //scroll down
                                                  //   print("yyyyyyyyyy");
                                                }
                                              }
                                            },
                                            child: Container(
                                                margin: EdgeInsets.only(
                                                    top: 17, bottom: 20),
                                                child:
                                                    widget.addMediaTopWidget))
                                        : SizedBox());
                              } else {
                                return SizedBox();
                              }
                            }),
                            widget.tabBottomBuilder?.call(context) ??
                                GiphyTabBottom(),
                            GiphyTabBar(
                              tabController: _tabController,
                              showGIFs: widget.showGIFs,
                              showStickers: widget.showStickers,
                              showEmojis: widget.showEmojis,
                            ),
                            Expanded(
                              child: GiphyTabView(
                                tabController: _tabController,
                                scrollController: this._scrollController,
                                showGIFs: widget.showGIFs,
                                showStickers: widget.showStickers,
                                showEmojis: widget.showEmojis,
                              ),
                            ),
                          ],
                        )))))));
  }
}
