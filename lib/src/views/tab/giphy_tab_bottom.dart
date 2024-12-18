import 'package:flutter/material.dart';
import 'package:giphy_get/src/l10n/l10n.dart';

class GiphyTabBottom extends StatelessWidget {
  const GiphyTabBottom({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = GiphyGetUILocalizations.labelsOf(context);

    return true
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l.trendingOnGiphy,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                        'assets/img/PoweredBy_200px-Black_HorizLogo.png',
                        package: 'giphy_get',
                        height: 20)),
              )
            ],
          )
        : Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
            child: Center(
              child: _giphyLogo(context),
            ),
          );
  }

  Widget _giphyLogo(BuildContext context) {
    const basePath = "assets/img/";
    String logoPath = Theme.of(context).brightness == Brightness.light
        ? "poweredby_dark.png"
        : "poweredby_light.png";

    return Container(
      width: double.maxFinite,
      height: 15,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fitHeight,
          image: AssetImage(
            "$basePath$logoPath",
            package: 'giphy_get',
          ),
        ),
      ),
    );
  }
}
