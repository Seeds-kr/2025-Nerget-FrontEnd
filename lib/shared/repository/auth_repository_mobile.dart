import 'dart:io' show Platform;

import 'package:google_sign_in/google_sign_in.dart';
import 'package:omakase_app/shared/api/env.dart' as appenv;

/// Mobile-specific AuthRepository implementation using `google_sign_in`.
/// This file must NOT import `dart:html` or any web-only APIs.
class AuthRepository {
  AuthRepository();

  /// Called when an ID token (JWT) is available from Google Sign-In.
  void Function(String idToken)? onIdToken;

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
    // The google_sign_in plugin expects the *server/web* client ID as
    // `serverClientId` so that an ID token is returned. Use the Web client
    // ID environment variable (GSI_CLIENT_ID_WEB). The Android client ID
    // (GSI_CLIENT_ID_ANDROID) is used only when registering the Android
    // OAuth client in Google Cloud Console (package name + SHA-1).
    serverClientId: appenv.Env.googleClientIdWeb.isNotEmpty
        ? appenv.Env.googleClientIdWeb
        : null,
  );

  /// Sign in with Google on mobile platforms (Android/iOS).
  /// Returns the signed-in account or null if the user cancelled.
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    // Only attempt GoogleSignIn on Android and iOS. On desktop (Windows/Mac/Linux)
    // the google_sign_in plugin is not supported and will not work reliably.
    if (!(Platform.isAndroid || Platform.isIOS)) {
      // ignore: avoid_print
      print(
        '[AuthRepository] signInWithGoogle: unsupported platform ${Platform.operatingSystem}',
      );
      return null;
    }

    try {
      // Diagnostic info
      // ignore: avoid_print
      print(
        '[AuthRepository] signInWithGoogle start on ${Platform.operatingSystem}',
      );
      // Print both configured client IDs so we can detect misconfiguration.
      // ignore: avoid_print
      print(
        '[AuthRepository] Env.googleClientIdWeb: "${appenv.Env.googleClientIdWeb}"',
      );
      // ignore: avoid_print
      print(
        '[AuthRepository] Env.googleClientIdAndroid: "${appenv.Env.googleClientIdAndroid}"',
      );

      // Provide a reasonable timeout so UI doesn't hang indefinitely
      final Future<GoogleSignInAccount?> signInFuture = _googleSignIn.signIn();
      final account = await signInFuture.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          // ignore: avoid_print
          print('[AuthRepository] signInWithGoogle timed out');
          return null;
        },
      );

      if (account == null) {
        // ignore: avoid_print
        print(
          '[AuthRepository] signInWithGoogle: account is null (cancelled or timeout)',
        );
        return null; // user canceled or timeout
      }

      // ignore: avoid_print
      print(
        '[AuthRepository] signInWithGoogle: account email=${account.email}, id=${account.id}',
      );

      final auth = await account.authentication;
      final idToken = auth.idToken;
      // ignore: avoid_print
      print(
        '[AuthRepository] signInWithGoogle: idToken present=${idToken != null}',
      );
      if (idToken != null) {
        onIdToken?.call(idToken);
      }
      return account;
    } catch (e, st) {
      // ignore: avoid_print
      print('[AuthRepository] signInWithGoogle error: $e');
      // ignore: avoid_print
      print(st);
      return null;
    }
  }

  /// Sign the current user out.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  /// No-op for mobile: rendering a web GSI button isn't applicable.
  void renderGoogleButton(String containerId) {
    // intentionally no-op on mobile
  }
}
