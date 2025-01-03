import '../default_localizations.dart';

class LvLocalizations extends GiphyGetUILocalizationLabels {
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

  const LvLocalizations({
    this.searchInputLabel = 'Meklēt',
    this.emojisLabel = 'Emoji',
    this.gifsLabel = 'GIF’i',
    this.stickersLabel = 'Stikeri',
    this.moreBy = 'Vairāk no',
    this.viewOnGiphy = 'Apskatīt GIPHY',
    this.poweredByGiphy = 'Nodrošina GIPHY',
    this.trendingOnGiphy = 'Populāri GIPHY',
  });
}
