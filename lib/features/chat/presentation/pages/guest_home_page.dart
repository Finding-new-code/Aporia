import 'package:flutter/material.dart';
import 'package:aporia/core/theme/app_theme.dart';
import 'package:aporia/features/auth/presentation/pages/login_page.dart';
import 'package:aporia/features/settings/presentation/widgets/guest_app_drawer.dart';
import 'package:aporia/features/chat/presentation/widgets/attachment_bottom_sheet.dart';
import 'package:aporia/features/chat/presentation/dataflows/chat_dataflow.dart';
import 'package:aporia/features/chat/presentation/widgets/user_message_bubble.dart';
import 'package:aporia/features/chat/presentation/widgets/ai_message_block.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AttachmentBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundBlack,
      drawer: const GuestAppDrawer(),
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Aporia',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(80, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  'Log in',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<ChatStore>(
                stream: ChatDataflow.stream,
                initialData: ChatDataflow.store,
                builder: (context, snapshot) {
                  final store = snapshot.data ?? ChatDataflow.store;
                  if (store.messages.isEmpty) {
                    return Center(child: Container());
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    itemCount: store.messages.length,
                    itemBuilder: (context, index) {
                      final msg = store.messages[index];
                      if (msg.role == 'user') {
                        return UserMessageBubble(content: msg.content);
                      } else {
                        return AiMessageBlock(
                          content: msg.content,
                          isThinking: msg.isThinking,
                          statusText: msg.statusText,
                        );
                      }
                    },
                  );
                },
              ),
            ),

            // Try something new section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Try something new',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.shuffle,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildSuggestionItem(
                    icon: Icons.edit_rounded,
                    iconColor: Colors.purpleAccent,
                    text: 'Make this shorter but still clear',
                  ),
                  _buildSuggestionItem(
                    icon: Icons.image_search,
                    iconColor: Colors.greenAccent,
                    text: 'Give my photo a colorful smoke silhouette',
                  ),
                  _buildSuggestionItem(
                    icon: Icons.image_search,
                    iconColor: Colors.greenAccent,
                    text: 'Give my photo a colorful smoke silhouette',
                  ),
                  _buildSuggestionItem(
                    icon: Icons.image_search,
                    iconColor: Colors.greenAccent,
                    text: 'See how I\'d look with a different eye color',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bottom Input Area
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLightGray.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: _showAttachmentMenu,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Ask Aporia',
                          hintStyle: TextStyle(color: AppTheme.textGray),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (text) {
                          if (text.trim().isNotEmpty) {
                            SendMessageAction(text.trim()).execute();
                            _inputController.clear();
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic, color: Colors.white),
                      onPressed: () {},
                    ),
                    Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          final text = _inputController.text;
                          if (text.trim().isNotEmpty) {
                            SendMessageAction(text.trim()).execute();
                            _inputController.clear();
                          }
                        },
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
