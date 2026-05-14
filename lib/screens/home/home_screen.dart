// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/user_model.dart';
import 'package:flutter_chat_app/screens/auth/login_screen.dart';
import 'package:flutter_chat_app/screens/profile/profile_screen.dart';
import 'package:flutter_chat_app/services/auth_service.dart';
import 'package:flutter_chat_app/utils/constants.dart';
import 'package:flutter_chat_app/widgets/custom_text_field.dart';
import 'package:flutter_chat_app/widgets/user_tile.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  int _currentIndex = 0;
  String _searchQuery = '';
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentUser();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final userId = _authService.currentUserId;
    if (userId != null) {
      if (state == AppLifecycleState.resumed) {
        _authService.updateUserOnlineStatus(userId, true);
      } else {
        _authService.updateUserOnlineStatus(userId, false);
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: AppConstants.primaryColor,
              title: Text(
                _currentIndex == 0 ? 'Users' : 'Chats',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              actions: [
                if (_currentIndex == 0)
                  IconButton(
                    onPressed: () {
                      _navigatorToProfile(context);
                    },
                    icon: Icon(Icons.person, color: Colors.white),
                  ),
                IconButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  icon: Icon(Icons.logout, color: Colors.white),
                ),
              ],
            ),
            body: _currentIndex == 0
                ? _buildUserTab() // Placeholder for Users List
                : ZIMKitConversationListView(),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              selectedItemColor: AppConstants.primaryColor,
              unselectedItemColor: AppConstants.textSecondaryColor,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Users',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
              ],
            ), // Placeholder for Chats List
          ),
          ZegoUIKitPrebuiltCallMiniOverlayPage(contextQuery: () => context),
        ],
      ),
    );
  }

  Widget _buildUserTab() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppConstants.paddingMedium),
          color: AppConstants.primaryColor,
          child: SearchTextField(
            controller: _searchController,
            hintText: 'Search users...',
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            onClear: () {
              setState(() {
                _searchQuery = '';
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            stream: _authService.getAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppConstants.primaryColor,
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading users ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return EmptyUserList(
                  message: 'No users found',
                  icon: Icons.people_outline,
                );
              }
              List<UserModel> users = snapshot.data!;
              if (_searchQuery.isNotEmpty) {
                users = users.where((user) {
                  return user.name.toLowerCase().contains(_searchQuery) ||
                      user.email.toLowerCase().contains(_searchQuery);
                }).toList();
              }
              if (users.isEmpty) {
                return EmptyUserList(
                  message: 'No users match your search',
                  icon: Icons.search_off,
                );
              }
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return UserTile(
                    user: user,
                    onTap: () => _openChatWithUser(user),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ZegoSendCallInvitationButton(
                          invitees: [
                            ZegoUIKitUser(id: user.uid, name: user.name),
                          ],
                          isVideoCall: false,
                          iconSize: Size(40, 40),
                          buttonSize: Size(50, 50),
                          onPressed: onSendCallInvitationFinished,
                        ),
                        SizedBox(width: 8),
                        ZegoSendCallInvitationButton(
                          invitees: [
                            ZegoUIKitUser(id: user.uid, name: user.name),
                          ],
                          isVideoCall: true,
                          iconSize: Size(40, 40),
                          buttonSize: Size(50, 50),
                          onPressed: onSendCallInvitationFinished,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _openChatWithUser(UserModel user) async {
    await ZIMKit()
        .connectUser(id: _currentUser!.uid, name: _currentUser!.name)
        .then((v) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ZIMKitMessageListPage(
                conversationID: user.uid,
                conversationType: ZIMConversationType.peer,
                appBarActions: [
                  ZegoSendCallInvitationButton(
                    invitees: [ZegoUIKitUser(id: user.uid, name: user.name)],
                    isVideoCall: false,
                    iconSize: Size(40, 40),
                    buttonSize: Size(50, 50),
                    onPressed: onSendCallInvitationFinished,
                  ),
                  SizedBox(width: 8),
                  ZegoSendCallInvitationButton(
                    invitees: [ZegoUIKitUser(id: user.uid, name: user.name)],
                    isVideoCall: true,
                    iconSize: Size(40, 40),
                    buttonSize: Size(50, 50),
                    onPressed: onSendCallInvitationFinished,
                  ),
                ],
              ),
            ),
          );
        });
  }

  void onSendCallInvitationFinished(
    String code,
    String message,
    List<String> errorInvitees,
  ) {
    if (errorInvitees.isNotEmpty) {
      var userIDs = '';
      for (var index = 0; index < errorInvitees.length; index++) {
        if (index >= 5) {
          userIDs += '...';
          break;
        }
        final userID = errorInvitees.elementAt(index);
        userIDs += '$userID ';
      }
      if (userIDs.isNotEmpty) {
        userIDs = userIDs.substring(0, userIDs.length - 1);
      }
      var message = 'Users does not exist: $userIDs';
      if (code.isNotEmpty) {
        message += ', (Code: $code, Message: $message)';
      }
      Fluttertoast.showToast(msg: message);
    } else if (code.isNotEmpty) {
      print(message);
    }
  }

  void _navigatorToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _logout(context);
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      showDialog(
        context: context,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: AppConstants.primaryColor),
        ),
        barrierDismissible: false,
      );
      await ZIMKit().disconnectUser();
      await FirebaseAuth.instance.signOut();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Error logging out: $e",
        backgroundColor: AppConstants.accentColor,
      );
    }
  }
}
