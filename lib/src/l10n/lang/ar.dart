import '../default_localizations.dart';

class ArLocalizations extends GiphyGetUILocalizationLabels {
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

  const ArLocalizations({
    this.searchInputLabel = 'بحث',
    this.emojisLabel = 'الرموز التعبيرية',
    this.gifsLabel = 'صور متحركة',
    this.stickersLabel = 'ملصقات',
    this.moreBy = 'المزيد من',
    this.viewOnGiphy = 'عرض على GIPHY',
    this.poweredByGiphy = 'مدعوم بواسطة GIPHY',
    this.trendingOnGiphy = 'تتجه على GIPHY',
  });
}
