import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // ID de Prueba oficial de Google
  static const String BANNER_TEST_ID = 'ca-app-pub-3940256099942544/6300978111';

  static Future<void> init() async {
    await MobileAds.instance.initialize();
  }

  static BannerAd crearBanner() {
    return BannerAd(
      adUnitId: BANNER_TEST_ID,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => print('✅ Banner cargado correctamente'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('❌ El banner falló al cargar: $error');
        },
      ),
    );
  }
}