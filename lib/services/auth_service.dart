// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'package:flutter_chat_app/models/user_model.dart';
import 'package:flutter_chat_app/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      print('Starting signup process for: $email');

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        print('Firebase user created: ${user.uid}');

        await user.updateDisplayName(name);

        UserModel userModel = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          photoUrl: getUserAvatar(name),
          createdAt: DateTime.now(),
          isOnline: true,
        );

        // Save to Firestore
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toMap());

        print('User data saved to Firestore');
        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Unexpected error: $e');
      throw 'An unexpected error occurred: $e';
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        await updateUserOnlineStatus(user.uid, true);

        DocumentSnapshot userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          return UserModel.fromDocument(userDoc);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> signOut() async {
    try {
      if (currentUser != null) {
        await updateUserOnlineStatus(currentUserId!, false);
      }
      await ZegoUIKitPrebuiltCallInvitationService().uninit();
      await ZIMKit().disconnectUser();
      await _auth.signOut();
    } catch (e) {
      throw 'An error occurred while signing out. $e';
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (userDoc.exists) {
        return UserModel.fromDocument(userDoc);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch user data. $e';
    }
  }

  Future<UserModel?> getCurrentUserData() async {
    if (currentUserId != null) {
      return await getUserData(currentUserId!);
    }
    return null;
  }

  Future<void> updateUserProfile({
    String? name,
    String? photoUrl,
    String? bio,
  }) async {
    try {
      if (currentUserId == null) {
        throw 'No user is currently signed in.';
      }
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (bio != null) updates['bio'] = bio;

      if (updates.isNotEmpty) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(currentUserId)
            .update(updates);

        if (name != null) {
          await currentUser?.updateDisplayName(name);
        }
      }
    } catch (e) {
      throw 'Failed to update profile. $e';
    }
  }

  Future<void> updateUserOnlineStatus(String uid, bool isOnline) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(uid).update(
        {
          'isOnline': isOnline,
          'lastSeen': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      throw 'Failed to update online status. $e';
    }
  }

  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where('uid', isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromDocument(doc))
              .toList();
        });
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromDocument(doc))
          .where((user) => user.uid != currentUserId)
          .toList();
    } catch (e) {
      throw 'Failed to search users. $e';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email. $e';
    }
  }

  Future<void> deleteAccount() async {
    try {
      if (currentUserId == null) {
        throw 'No user is currently signed in.';
      }
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .delete();
      await currentUser?.delete();
    } catch (e) {
      throw 'Failed to delete account. $e';
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already in use. Please use a different email.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return AppConstants.networkError;
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
