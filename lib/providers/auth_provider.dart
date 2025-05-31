import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? _user;
  User? get user => _user;

  AuthProvider() {
    _user = _supabase.auth.currentUser;
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.userUpdated) {
        _user = data.session?.user;
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
      }
      notifyListeners();
    });
  }

  // We can add methods for sign-in, sign-up, sign-out later
  // e.g., Future<void> signInWithEmail(String email, String password) async { ... }
  // e.g., Future<void> signOut() async { ... }
}
