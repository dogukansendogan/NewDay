import UIKit
import Flutter
import GoogleSignIn // Google Sign-In kütüphanesi
import FirebaseAuth // Firebase Auth

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // Uygulama açılırken Firebase'i başlat (Zaten main.dart'ta da var, garanti için)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // --- KRİTİK KISIM: GOOGLE CEVABINI DİNLEME ---
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // Google Sign-In'ın URL geri çağrısını işlemesini sağlar
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }
    // Eğer Google'dan gelmiyorsa diğer URL'leri işle
    return super.application(app, open: url, options: options)
  }
}