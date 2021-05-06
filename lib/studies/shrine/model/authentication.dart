import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum AuthState { Uninitialised, UnAuthenticated, Authenticating, Authenticated }

class AuthUser extends ChangeNotifier {
  final _fireAuth = FirebaseAuth.instance;

  AuthState _authState = AuthState.Uninitialised;
  AuthState get authState => _authState;
  String error;
  String aUid;
  bool isLoading = false;
  bool isSuccessful = false;

  // * remeber after sign up
  // * they need to verify their email
  ///
  Future<bool> signUpWithEmail({
    @required String email,
    @required String password,
  }) async {
    try {
      _authState = AuthState.Authenticating;
      isLoading = true;
      await _fireAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await sendEmailVerification();
      await getCurrentUser();
      isSuccessful = true;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      print('Failed to sign up with error code ${e.message}');
      error = e.message;
      _authState = AuthState.UnAuthenticated;
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // * check if mail is verified before login in
  Future<bool> login({
    @required String email,
    @required String password,
  }) async {
    bool isdEmailVerified;
    try {
      _authState = AuthState.Authenticating;
      //* sending and checking with the database
      isLoading = true;
      await _fireAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await getCurrentUser();

      await isEmailVerified().then(
        (value) {
          if (value == true) {
            isdEmailVerified = value;
            _authState = AuthState.Authenticated;
            isSuccessful = true;
          } else {
            isSuccessful = false;
            error =
                'Sorry your email not yet verified. please check your email to verify';
            isdEmailVerified = false;

            _authState = AuthState.UnAuthenticated;
          }
        },
      );

      notifyListeners();
      return isdEmailVerified;
    } on FirebaseAuthException catch (e) {
      print('Failed to login with error code ${e.message}');
      isSuccessful = false;
      error = e.message;
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      _authState = AuthState.Uninitialised;
      notifyListeners();
    }
  }

  Future<void> sendEmailVerification() async {
    var user = _fireAuth.currentUser;
    await user.sendEmailVerification();
    // _authState = AuthState.Authenticating;
    // * reason y we ain't changeing auth state is because it will affect login
  }

  Future<bool> isEmailVerified() async {
    User user = _fireAuth.currentUser;
    user.emailVerified == true
        ? _authState = AuthState.Authenticated
        : _authState = AuthState.UnAuthenticated;
    notifyListeners();
    return user.emailVerified;
  }

  Future<User> getCurrentUser() async {
    var user = _fireAuth.currentUser;
    if (user == null) {
      aUid = null;
    } else {
      aUid = user.uid;
    }

    return user;
  }

  Future<bool> logout() async {
    //made changes here
    try {
      await _fireAuth.signOut();
      aUid = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print('Failed to logout with ${e.message}');
      error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletAcct() async {
    try {
      await _fireAuth.currentUser.delete();
      aUid = "";
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      print("Failed to logout with ${e.message}");
      error = e.message;
      notifyListeners();
      return true;
    }
  }
}

// TODO: Sign up verificaton verify email

// TODO: verify reset password
// TODO: Other Login Option











// class AuthUser extends StateNotifier<Me> {
//   final String Data;

//   AuthUser(this.Data) : super(Me());

//   final dataMe = Me(
//     null,
//   );

//   returnMe<Me> (){
//     final data = authStatChangeProvider;
//     data.
//   }

//   final fireAuth = FirebaseAuth.instance;

//   final fireAuthrrr = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

//   final authStatChangeProvider = StreamProvider<User>((ref) {
//     return FirebaseAuth.instance.authStateChanges();
//   });
  
//   Future<UserCredential> signIn() {
//   print("Signin in .....");

//    return fireauth.createUserWithEmailAndPassword(
//     email: "adedokunemmanuel250+jhbjktu@gmail.com",
//     password: "passwo90hd23578",
//   );
// }

// }

