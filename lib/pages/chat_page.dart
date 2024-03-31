import 'dart:io';

import 'package:c3_app/models/chat.dart';
import 'package:c3_app/models/message.dart';
import 'package:c3_app/models/user_profile.dart';
import 'package:c3_app/services/auth_service.auth.dart';
import 'package:c3_app/services/database_service.dart';
import 'package:c3_app/services/media_service.dart';
import 'package:c3_app/services/storage_service.dart';
import 'package:c3_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;

  const ChatPage({super.key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatUser? currentUser, otherUser;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;
  final GetIt getIt = GetIt.instance;

  @override
  void initState() {
    super.initState();
    _authService = getIt.get<AuthService>();
    _databaseService = getIt.get<DatabaseService>();
    _mediaService = getIt.get<MediaService>();
    _storageService = getIt.get<StorageService>();
    currentUser = ChatUser(
      id: _authService.user!.uid,
      firstName: _authService.user!.displayName,
    );
    otherUser = ChatUser(
      id: widget.chatUser.uid!,
      firstName: widget.chatUser.name,
      profileImage: widget.chatUser.pfpURL,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((widget.chatUser.name ?? "Chat")),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
        stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
        builder: (context, snapshot) {
          Chat? chat = snapshot.data?.data();
          List<ChatMessage> messages = [];
          if (chat != null && chat.messages != null) {
            messages = _generateChatMessagesList(chat.messages!);
          }
          return DashChat(
              messageOptions:
                  MessageOptions(showOtherUsersAvatar: true, showTime: true),
              inputOptions: InputOptions(alwaysShowSend: true, trailing: [
                _mediaMessageButton(),
              ]),
              currentUser: currentUser!,
              onSend: _sendMessage,
              messages: messages);
        });
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
            senderID: chatMessage.user.id,
            content: chatMessage.medias!.first.url,
            messageType: MessageType.Image,
            sentAt: Timestamp.fromDate(chatMessage.createdAt));
        await _databaseService.sendMessage(
            currentUser!.id, otherUser!.id, message);
      }
    } else {
      Message message = Message(
          senderID: currentUser!.id,
          content: chatMessage.text,
          messageType: MessageType.Text,
          sentAt: Timestamp.fromDate(chatMessage.createdAt));

      await _databaseService.sendMessage(
          currentUser!.id, otherUser!.id, message);
    }
  }

  List<ChatMessage> _generateChatMessagesList(List<Message> messages) {

    List<ChatMessage> chatMessages = messages.map((message) {

      if(message.messageType == MessageType.Image){
        return ChatMessage(
          user: message.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: message.sentAt!.toDate(),
          medias: [
            ChatMedia(
              url: message.content!,
              fileName: '',
              type: MediaType.image,
            ),
          ],
        );
      }else{

      return ChatMessage(
        text: message.content!,
        user: message.senderID == currentUser!.id ? currentUser! : otherUser!,
        createdAt: message.sentAt!.toDate(),
      );
      }
    }).toList();

    chatMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return chatMessages;
  }

  Widget _mediaMessageButton() {
    return IconButton(
      icon: const Icon(Icons.image),
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Camera"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text("Gallery"),
                  onTap: () async {
                    File? file = await _mediaService.getImageGallery();

                    if (file != null) {
                      String chatID = generateChatID(
                          uid1: currentUser!.id, uid2: otherUser!.id);
                      String? downloadUrl =
                          await _storageService.uploadChatImage(file, chatID);
                      if (downloadUrl != null) {
                        ChatMessage chatMessage = ChatMessage(
                          user: currentUser!,
                          createdAt: DateTime.now(),
                          medias: [
                            ChatMedia(
                                url: downloadUrl,
                                fileName: '',
                                type: MediaType.image)
                          ],
                        );

                        _sendMessage(chatMessage);
                      }
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
