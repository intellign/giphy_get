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
  const MainView({
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
      // final _tabProvider = Provider.of<TabProvider>(context, listen: false);
    });
  }

  @override
  void didChangeDependencies() {
    _sheetProvider = Provider.of<SheetProvider>(context, listen: false);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // Dispose of resources properly
    widget.sharedPreferences.setInt("lastGiphyTabSaved", _tabController.index);
    super.dispose();
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

  Widget GestureWidget(
      {required Widget child, required TabProvider tabProvider}) {
    DragStartDetails? startVerticalDragDetails;
    DragUpdateDetails? updateVerticalDragDetails;
    return GestureDetector(
        onVerticalDragStart: (dragDetails) {
          startVerticalDragDetails = dragDetails;
        },
        onVerticalDragUpdate: (dragDetails) {
          updateVerticalDragDetails = dragDetails;
        },
        onVerticalDragEnd: (endDetails) {
          if (startVerticalDragDetails != null &&
              updateVerticalDragDetails != null) {
            double dx = updateVerticalDragDetails!.globalPosition.dx -
                startVerticalDragDetails!.globalPosition.dx;
            double dy = updateVerticalDragDetails!.globalPosition.dy -
                startVerticalDragDetails!.globalPosition.dy;
            double? velocity = endDetails.primaryVelocity;

            //Convert values to be positive
            if (dx < 0) dx = -dx;
            if (dy < 0) dy = -dy;

            if (velocity != null && velocity < 0) {
              //scroll up
              if (widget.addMediaTopWidget != null &&
                  tabProvider.showAddTopMediaWidgets)
                tabProvider.setShowAddTopMediaWidgets(false);
            } else {
              //scroll down
              //   print("yyyyyyyyyy");
            }
          }
        },
        child: child);
  }

  Widget _bottomSheetBody() {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                topLeft: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  spreadRadius: 16,
                  color: widget.whiteBackground
                      ? Colors.white.withOpacity(0.21)
                      : Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                topLeft: Radius.circular(16),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 10.0,
                  sigmaY: 10.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.whiteBackground
                        ? Colors.white.withOpacity(0.27)
                        : Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      topLeft: Radius.circular(16),
                    ),
                    border: Border.all(
                      width: 1.5,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.tabTopBuilder?.call(context) ??
                    GiphyTabTop(topDragColor: widget.topDragColor),
                SizedBox(height: 13),
                SearchAppBar(
                  scrollController: this._scrollController,
                  searchAppBarBuilder: widget.searchAppBarBuilder,
                  textEditingController: textEditingController,
                  focus: _focusNode,
                ),
                SizedBox(height: 3.7),
                Expanded(
                  child: NestedScrollView(
                    controller: _scrollController,
                    floatHeaderSlivers: true,
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverToBoxAdapter(
                          child: Container(
                              // duration: const Duration(milliseconds: 310),
                              child: Column(children: [
                        if (widget.addMediaTopWidget != null &&
                            textEditingController.text.isEmpty)
                          widget.addMediaTopWidget!,
                        widget.tabBottomBuilder?.call(context) ??
                            GiphyTabBottom(),
                        GiphyTabBar(
                          tabController: _tabController,
                          showGIFs: widget.showGIFs,
                          showStickers: widget.showStickers,
                          showEmojis: widget.showEmojis,
                        ),
                      ])))
                    ],
                    body:
                        /* NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollEndNotification) {
                          if (_scrollController.position.extentAfter == 0) {
                            print("bottommmmmmmmmmmmmm");
                            // User has scrolled to the bottom of the list
                            // Handle the event here
                          }
                        }
                        return false;
                      },
                      child:
                      */
                        GiphyTabView(
                      tabController: _tabController,
                      scrollController: _scrollController,
                      showGIFs: widget.showGIFs,
                      showStickers: widget.showStickers,
                      showEmojis: widget.showEmojis,
                    ),
                    // ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
