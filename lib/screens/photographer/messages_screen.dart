// lib/screens/photographer/messages_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

const kNavy = Color(0xFF0A192F);
const kCobalt = Color(0xFF172A45);
const kSlate = Color(0xFF8892B0);
const kSky = Color(0xFF64FFDA);

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<dynamic> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await MessageService.getConversations() as Map<String, dynamic>;
      setState(() {
        _conversations = data['conversations'] ?? data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Messages')),
    body: _loading
        ? const LoadingWidget(message: 'Loading messages…')
        : _conversations.isEmpty
            ? const EmptyState(
                icon: Icons.message_outlined,
                title: 'No conversations yet',
                subtitle: 'Messages from clients will appear here',
              )
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  itemCount: _conversations.length,
                  itemBuilder: (ctx, i) {
                    final c = _conversations[i];
                    final auth = context.read<AuthProvider>();
                    
                    // Force text conversions to matching types for deep logic evaluation
                    final other = c['sender_id'].toString() == auth.user?.id.toString()
                        ? c['receiver']
                        : c['sender'];
                    final isUnread = c['is_read'] == false;

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24, backgroundColor: kCobalt,
                        child: Text(
                          (other?['name'] ?? 'U').substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      title: Text(other?['name'] ?? 'User',
                          style: TextStyle(
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
                      subtitle: Text(
                        c['message'] ?? '',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isUnread ? kNavy : kSlate,
                          fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            c['created_at']?.substring(11, 16) ?? '',
                            style: TextStyle(
                                fontSize: 11,
                                color: isUnread ? kCobalt : kSlate),
                          ),
                          if (isUnread) ...[
                            const SizedBox(height: 4),
                            Container(width: 10, height: 10,
                                decoration: const BoxDecoration(
                                    color: kCobalt, shape: BoxShape.circle)),
                          ],
                        ],
                      ),
                      onTap: () {
                        final rawId = other?['id'];
                        final int? parsedId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            userId: parsedId,
                            userName: other?['name'] ?? 'User',
                          ),
                        )).then((_) => _load());
                      },
                    );
                  },
                ),
              ),
  );
}

class ChatScreen extends StatefulWidget {
  final int? userId;
  final String userName;
  const ChatScreen({super.key, this.userId, required this.userName});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> _messages = [];
  bool _loading = true;
  bool _sending = false;
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.userId == null) return;
    setState(() => _loading = true);
    try {
      final data = await MessageService.getConversation(widget.userId!);
      setState(() {
        _messages = data;
        _loading  = false;
      });
      _scrollToBottom();
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || widget.userId == null) return;
    _msgCtrl.clear();
    setState(() => _sending = true);
    try {
      await MessageService.sendMessage(
        receiverId: widget.userId!,
        message: text,
      );
      _load();
    } catch (_) {
      _msgCtrl.text = text;
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: kSky,
              child: Text(
                widget.userName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: kNavy, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.userName, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const LoadingWidget()
                : _messages.isEmpty
                    ? const EmptyState(
                        icon: Icons.chat_bubble_outline,
                        title: 'No messages yet',
                        subtitle: 'Say hello!',
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (ctx, i) {
                          final m = _messages[i];
                          final isMe = m['sender_id'].toString() == auth.user?.id.toString();
                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(ctx).size.width * 0.72,
                              ),
                              decoration: BoxDecoration(
                                color: isMe ? kCobalt : const Color(0xFFF0F6FB),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 16),
                                ),
                              ),
                              child: Text(
                                m['message'] ?? '',
                                style: TextStyle(
                                  color: isMe ? Colors.white : kNavy,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type a message…',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: const Color(0xFFF5F5F5),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sending ? null : _send,
                    child: CircleAvatar(
                      backgroundColor: kCobalt,
                      radius: 22,
                      child: _sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
