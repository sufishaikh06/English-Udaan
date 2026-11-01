import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.emailVerified,
    this.displayName,
  });

  final String uid;
  final String email;
  final bool emailVerified;
  final String? displayName;

  factory AuthUser.fromFirebase(fb.User user) {
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      emailVerified: user.emailVerified,
      displayName: user.displayName,
    );
  }
}

class AuthService {
  AuthService({fb.FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? _tryFirebaseAuth(),
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final fb.FirebaseAuth? _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  static fb.FirebaseAuth? _tryFirebaseAuth() {
    try {
      return fb.FirebaseAuth.instance;
    } on Object {
      return null;
    }
  }

  bool get isAvailable => _firebaseAuth != null;

  Stream<AuthUser?> get authStateChanges {
    final auth = _firebaseAuth;
    return auth == null
        ? Stream<AuthUser?>.value(null)
        : auth.authStateChanges().map(
            (user) => user == null ? null : AuthUser.fromFirebase(user),
          );
  }

  AuthUser? get currentUser {
    final user = _firebaseAuth?.currentUser;
    return user == null ? null : AuthUser.fromFirebase(user);
  }

  Future<String?> getIdToken([bool forceRefresh = false]) async {
    return _firebaseAuth?.currentUser?.getIdToken(forceRefresh);
  }

  Future<AuthUser> signInWithEmailPassword(String email, String password) async {
    final credential = await _requireAuth().signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) throw Exception('Sign in failed: no user returned');
    return AuthUser.fromFirebase(user);
  }

  Future<AuthUser> registerWithEmailPassword(String email, String password) async {
    final credential = await _requireAuth().createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) throw Exception('Registration failed: no user returned');
    return AuthUser.fromFirebase(user);
  }

  Future<AuthUser?> signInWithGoogle() async {
    final auth = _requireAuth();
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) throw Exception('Google sign in failed: no user returned');
    return AuthUser.fromFirebase(user);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth?.signOut();
  }

  fb.FirebaseAuth _requireAuth() {
    final auth = _firebaseAuth;
    if (auth == null) {
      throw StateError(
        'Firebase authentication is not configured for this platform.',
      );
    }
    return auth;
  }
}
