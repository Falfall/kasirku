// supabase_services.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Singleton pattern (supaya bisa diakses dari mana saja)
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Supabase client
  final SupabaseClient client = Supabase.instance.client;

  // Register user
  Future<AuthResponse> signUp(String email, String password) async {
    final response = await client.auth.signUp(email: email, password: password);
    return response;
  }

  // Login user
  Future<AuthResponse> signIn(String email, String password) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // Logout
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Cek apakah user sedang login
  User? get currentUser => client.auth.currentUser;
}
