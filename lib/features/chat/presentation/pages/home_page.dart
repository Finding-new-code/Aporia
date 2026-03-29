import 'package:flutter/material.dart';
import 'package:aporia/core/theme/app_theme.dart';
import 'package:aporia/features/chat/presentation/widgets/chat_bottom_sheet.dart';
import 'package:aporia/features/chat/presentation/dataflows/chat_dataflow.dart';
import 'package:aporia/features/chat/presentation/widgets/user_message_bubble.dart';
import 'package:aporia/features/chat/presentation/widgets/ai_message_block.dart';
import 'dart:io';
import 'package:aporia/features/settings/presentation/widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChatBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      backgroundColor: AppTheme.backgroundBlack,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/aura.png'),
              fit: BoxFit.cover,
              isAntiAlias: true,
              opacity: 0.4,
            ),
          ),
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: StreamBuilder<ChatStore>(
                  stream: ChatDataflow.stream,
                  initialData: ChatDataflow.store,
                  builder: (context, snapshot) {
                    final store = snapshot.data ?? ChatDataflow.store;
                    if (store.messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'What can I help with?',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            _buildActionGrid(),
                          ],
                        ),
                      );
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
              _buildAttachmentList(),
              _buildBottomInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentList() {
    return StreamBuilder<ChatStore>(
      stream: ChatDataflow.stream,
      initialData: ChatDataflow.store,
      builder: (context, snapshot) {
        final store = snapshot.data ?? ChatDataflow.store;
        if (store.attachments.isEmpty) return const SizedBox.shrink();
        return Container(
          height: 90,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: store.attachments.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final attachment = store.attachments[index];
              return Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGray,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: attachment.type == 'file'
                          ? const Center(
                              child: Icon(
                                Icons.insert_drive_file,
                                color: Colors.white70,
                              ),
                            )
                          : Image.file(
                              File(attachment.path),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: () => RemoveAttachmentAction(index).execute(),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Drawer Icon
          GestureDetector(
            onTap: _openDrawer,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLightGray.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          // Aporia Title Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLightGray.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Aporia',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const Spacer(),
          // Profile Icon (Placeholder)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLightGray.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          // New Chat Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLightGray.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit_square, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // _ActionButton(
              //   icon: Icons.image_outlined,
              //   iconColor: Colors.greenAccent,
              //   label: 'Create image',
              // ),
              // const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.bar_chart,
                iconColor: Colors.blueAccent,
                label: 'Analyze data',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionButton(
                icon: Icons.code,
                iconColor: Colors.blue,
                label: 'Code',
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.edit_note,
                iconColor: Colors.pinkAccent,
                label: 'Help me write',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInputArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceGray,
          borderRadius: BorderRadius.circular(32),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            // Add Button
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _openAttachmentSheet,
            ),
            // Input Field
            Expanded(
              child: TextField(
                controller: _inputController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ask Aporia',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    SendMessageAction(text.trim()).execute();
                    _inputController.clear();
                  }
                },
              ),
            ),
            // Mic Button
            IconButton(
              icon: const Icon(Icons.mic_none, color: Colors.white),
              onPressed: () {},
            ),
            // Waveform Button
            GestureDetector(
              onTap: () {
                final text = _inputController.text;
                if (text.trim().isNotEmpty) {
                  SendMessageAction(text.trim()).execute();
                  _inputController.clear();
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _ActionButton({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGray.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
