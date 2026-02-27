import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // ⚠️ ID de Prueba oficial de Google para Banners
  // Cuando lances la app real a la Play Store, cambiaremos esto por tu ID real con la barra (/)
  static const String BANNER_TEST_ID = 'ca-app-pub-3940256099942544/6300978111';

  /// Inicializa el motor de Google AdMob al abrir la app
  static Future<void> init() async {
    await MobileAds.instance.initialize();
  }

  /// Crea y devuelve un Banner de publicidad
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