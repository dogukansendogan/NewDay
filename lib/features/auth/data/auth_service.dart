import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Mevcut kullanıcıyı getir
  User? get currentUser => _auth.currentUser;

  // Google ile Giriş Fonksiyonu
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Google penceresini aç
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Kullanıcı pencereyi kapatırsa null döner, işlemi durdur
      if (googleUser == null) return null;

      // 2. Google'dan kimlik token'larını al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Bu token'larla Firebase için kimlik kartı oluştur
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Firebase'e giriş yap
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Giriş Hatası: $e");
      return null;
    }
  }

  // Çıkış Yap
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Çıkış Hatası: $e");
    }
  }
}

// Servise erişim sağlayan Riverpod sağlayıcısı
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});