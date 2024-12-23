import '../default_localizations.dart';

class EnLocalizations extends GiphyGetUILocalizationLabels {
  @override
  final String searchInputLabel;

  @override
  final String emojisLabel;

  @override
  final String gifsLabel;

  @override
  final String stickersLabel;

  @override
  final String moreBy;

  @override
  final String viewOnGiphy;

  @override
  final String poweredByGiphy;

  @override
  final String trendingOnGiphy;

  const EnLocalizations({
    this.searchInputLabel = 'Search',
    this.emojisLabel = 'Emojis',
    this.gifsLabel = 'GIFs',
    this.stickersLabel = 'Stickers',
    this.moreBy = 'More by',
    this.viewOnGiphy = 'View on GIPHY',
    this.poweredByGiphy = 'Powered by GIPHY',
    this.trendingOnGiphy = 'Trending on GIPHY',
  });
}
