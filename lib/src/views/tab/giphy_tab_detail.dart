import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:giphy_get/src/client/client.dart';
import 'package:giphy_get/src/client/models/collection.dart';
import 'package:giphy_get/src/client/models/gif.dart';
import 'package:giphy_get/src/client/models/type.dart';
import 'package:giphy_get/src/providers/app_bar_provider.dart';
import 'package:giphy_get/src/providers/tab_provider.dart';
import 'package:provider/provider.dart';

class GiphyTabDetail extends StatefulWidget {
  final String type;
  final ScrollController scrollController;
  const GiphyTabDetail(
      {Key? key, required this.type, required this.scrollController})
      : super(key: key);

  @override
  _GiphyTabDetailState createState() => _GiphyTabDetailState();
}

class _GiphyTabDetailState extends State<GiphyTabDetail> {
  // Tab Provider
  late TabProvider _tabProvider;

  //scrollingProvider
  late ScrollingProvider _scrollingProvider;

  // AppBar Provider
  late AppBarProvider _appBarProvider;

  // Collection
  GiphyCollection? _collection;

  // List of gifs
  List<GiphyGif> _list = [];

  // Direction
  final Axis _scrollDirection = Axis.vertical;

  // Axis count
  late int _crossAxisCount;

  // Spacing between gifs in grid
  double _spacing = 8.0;

  // Default gif with
  late double _gifWidth;

  // Limit of query
  late int _limit;

  // is Loading gifs
  bool _isLoading = false;

  // Offset
  int offset = 0;

  @override
  void initState() {
    super.initState();

    // Tab Provider
    _tabProvider = Provider.of<TabProvider>(context, listen: false);

    // Scrolling Provider
    _scrollingProvider = Provider.of<ScrollingProvider>(context, listen: false);

    // AppBar Provider
    _appBarProvider = Provider.of<AppBarProvider>(context, listen: false);

    // Gif WIDTH
    switch (widget.type) {
      case GiphyType.gifs:
        _gifWidth = 200.0;
        break;
      case GiphyType.stickers:
        _gifWidth = 150.0;
        break;
      case GiphyType.emoji:
        _gifWidth = 80.0;
        break;
      default:
        break;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set items count responsive
      _crossAxisCount =
          ((context.size?.width ?? MediaQuery.of(context).size.width) /
                  _gifWidth)
              .round();

      // Set vertical max items count
      int _mainAxisCount =
          ((MediaQuery.of(context).size.height - 30) / _gifWidth).round();

      _limit = _crossAxisCount * _mainAxisCount;
      if (_limit > 100) _limit = 100;
      // Initial offset
      offset = 0;

      // Load Initial Data
      _loadMore();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ScrollController
    widget.scrollController..addListener(_scrollListener);

    // Listen query
    _appBarProvider.addListener(_listenerQuery);
  }

  @override
  void dispose() {
    // Dispose of resources properly
    widget.scrollController.removeListener(_scrollListener);
    _appBarProvider.removeListener(_listenerQuery);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_list.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return MasonryGridView.count(
      addAutomaticKeepAlives: true,
      physics: const ClampingScrollPhysics(), // Ensure proper scroll physics,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      scrollDirection: _scrollDirection,
      controller: widget.scrollController,
      itemCount: _list.length,
      crossAxisCount: _crossAxisCount,
      mainAxisSpacing: _spacing,
      crossAxisSpacing: _spacing,
      itemBuilder: (ctx, idx) {
        GiphyGif _gif = _list[idx];
        return _item(_gif);
      },
    );
  }

  Widget _item(GiphyGif gif) {
    double _aspectRatio = (double.parse(gif.images!.fixedWidth.width) /
        double.parse(gif.images!.fixedWidth.height));

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        onTap: () => _selectedGif(gif),
        child: gif.images == null || gif.images?.fixedWidth.webp == null
            ? Container()
            : ExtendedImage.network(
                gif.images!.fixedWidth.webp!,
                semanticLabel: gif.title,
                cache: true,
                gaplessPlayback: true,
                fit: BoxFit.fill,
                headers: const {'accept': 'image/*'},
                loadStateChanged: (state) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: gif.images == null
                      ? Container()
                      : case2(
                          state.extendedImageLoadState,
                          {
                            LoadState.loading: AspectRatio(
                              aspectRatio: _aspectRatio,
                              child: Container(
                                alignment: Alignment.center,
                                color: Colors.transparent,
                                height: 30,
                                width: 30,
                                child: const CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white54),
                                  strokeWidth: 1,
                                ),
                              ),
                            ),
                            LoadState.completed: AspectRatio(
                              aspectRatio: _aspectRatio,
                              child: ExtendedRawImage(
                                fit: BoxFit.fill,
                                image: state.extendedImageInfo?.image,
                              ),
                            ),
                            LoadState.failed: AspectRatio(
                              aspectRatio: _aspectRatio,
                              child: Container(
                                color: Theme.of(context).cardColor,
                              ),
                            ),
                          },
                          AspectRatio(
                            aspectRatio: _aspectRatio,
                            child: Container(
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                        ),
                ),
              ),
      ),
    );
  }

  Future<void> _loadMore() async {
    print("Total of collections: ${_collection?.pagination?.totalCount}");
    //Return if is loading or no more gifs
    if (_isLoading || _collection?.pagination?.totalCount == _list.length) {
      print("No more object");
      return;
    }

    _isLoading = true;

    // Giphy Client from library
    GiphyClient client = GiphyClient(
        apiKey: _tabProvider.apiKey, randomId: _tabProvider.randomID);

    // Offset pagination for query
    if (_collection == null) {
      offset = 0;
    } else {
      offset = _collection!.pagination!.offset + _collection!.pagination!.count;
    }

    // Get Gif or Emoji
    if (widget.type == GiphyType.emoji) {
      _collection = await client.emojis(offset: offset, limit: _limit);
    } else {
      // If query text is not null search gif else trendings
      if (_appBarProvider.queryText.isNotEmpty) {
        _collection = await client.search(_appBarProvider.queryText,
            lang: _tabProvider.lang,
            offset: offset,
            rating: _tabProvider.rating,
            type: widget.type,
            limit: _limit);
      } else {
        _collection = await client.trending(
            lang: _tabProvider.lang,
            offset: offset,
            rating: _tabProvider.rating,
            type: widget.type,
            limit: _limit);
      }
    }

    // Set result to list
    if (_collection!.data.isNotEmpty && mounted) {
      setState(() {
        _list.addAll(_collection!.data);
      });
    }

    _isLoading = false;
  }

  // Scroll listener. if scroll end load more gifs
  void _scrollListener() {
    //Back to top botton will show on scroll offset 10.0
    double showoffset = 10.0;

    //Scrolled to top < 10.0
    /* if (widget.scrollController.offset < showoffset) {
      if (_scrollingProvider.showScrollbtn) {
        _scrollingProvider.updateScrolling(false);
      }
    } else if (widget.scrollController.position.pixels ==
        widget.scrollController.position.maxScrollExtent) {
      _scrollingProvider.updateScrolling(true);
    }
    */

    if ((widget.scrollController.positions.last.extentAfter.lessThan(500)) &&
        !_isLoading) {
      // Load more gifs
      _loadMore();
    }
  }

  // Return selected gif
  void _selectedGif(GiphyGif gif) {
    Navigator.pop(context, gif);
  }

  // listener query
  void _listenerQuery() {
    // Reset pagination
    _collection = null;

    // Reset list
    _list = [];

    // Load data
    _loadMore();
  }

  TValue? case2<TOptionType, TValue>(
    TOptionType selectedOption,
    Map<TOptionType, TValue> branches, [
    TValue? defaultValue = null,
  ]) {
    if (!branches.containsKey(selectedOption)) {
      return defaultValue;
    }

    return branches[selectedOption];
  }
}
