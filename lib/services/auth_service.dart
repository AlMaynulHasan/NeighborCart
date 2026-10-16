import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/auth_mode.dart';

/// Thrown when someone logs in with the wrong mode selected — e.g. a
/// customer account trying to sign in through the Wholesaler toggle.
/// Kept as a distinct exception so the UI can show a clear message
/// instead of a generic auth error.
class AuthRoleMismatchException implements Exception {
  final AuthMode actualRole;
  final AuthMode attemptedRole;
  AuthRoleMismatchException({required this.actualRole, required this.attemptedRole});

  @override
  String toString() {
    final actual = actualRole == AuthMode.wholesaler ? 'a Wholesaler' : 'a Customer';
    return 'This account is registered as $actual. Switch modes above and try again.';
  }
}

/// Wraps Firebase Authentication + the matching `users/{uid}` Firestore
/// profile doc. All Firebase calls for sign in/up/out live here — screens
/// never touch FirebaseAuth or Firestore directly (Master Prompt section
/// 18: "Keep Firebase operations inside service/repository classes").
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Creates a Firebase Auth account and its matching Firestore profile.
  /// `profile` holds the mode-specific fields (customer: name; wholesaler:
  /// businessName + contactName) — kept generic here so this service
  /// doesn't need to know about screen-level form shapes.
  Future<User> signUp({
    required String email,
    required String password,
    required AuthMode role,
    required Map<String, dynamic> profile,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = credential.user!;
    await _firestore.collection('users').doc(user.uid).set({
      'role': role.name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      ...profile,
    });
    return user;
  }

  /// Signs in, then checks the account's stored role against the mode
  /// the person selected on the toggle. Mismatches sign the user back out
  /// immediately and throw, rather than silently letting a customer into
  /// the wholesaler dashboard or vice versa.
  Future<User> signIn({
    required String email,
    required String password,
    required AuthMode expectedRole,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = credential.user!;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final storedRoleName = doc.data()?['role'] as String?;
    final storedRole = storedRoleName == 'wholesaler' ? AuthMode.wholesaler : AuthMode.customer;

    if (storedRoleName == null) {
      // No profile doc somehow — treat as a data problem, not a silent pass.
      await _auth.signOut();
      throw Exception('No profile found for this account. Please sign up again.');
    }
    if (storedRole != expectedRole) {
      await _auth.signOut();
      throw AuthRoleMismatchException(actualRole: storedRole, attemptedRole: expectedRole);
    }
    return user;
  }

  Future<void> signOut() => _auth.signOut();

  /// Turns a FirebaseAuthException into a short, person-readable message.
  static String friendlyError(Object error) {
    if (error is AuthRoleMismatchException) return error.toString();
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'An account already exists with that email.';
        case 'invalid-email':
          return 'That email address looks invalid.';
        case 'weak-password':
          return 'Password is too weak — use at least 6 characters.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'network-request-failed':
          return 'Network error — check your connection and try again.';
        default:
          return error.message ?? 'Something went wrong. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
