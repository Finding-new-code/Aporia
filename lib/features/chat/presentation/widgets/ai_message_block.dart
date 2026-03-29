import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:aporia/core/theme/app_theme.dart';
import 'package:aporia/features/chat/presentation/dataflows/chat_dataflow.dart';
import 'process_disclosure.dart';

class AiMessageBlock extends StatelessWidget {
  final String content;
  final bool isThinking;
  final String statusText;

  const AiMessageBlock({
    super.key,
    required this.content,
    required this.isThinking,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isThinking) ProcessDisclosure(statusText: statusText),
          if (content.isNotEmpty)
            MarkdownBody(
              data: content,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
                h1: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                h2: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                h3: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                code: TextStyle(
                  color: Colors.greenAccent,
                  backgroundColor: AppTheme.surfaceGray.withValues(alpha: 0.5),
                  fontFamily: 'monospace',
                ),
                codeblockDecoration: BoxDecoration(
                  color: AppTheme.surfaceGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                listBullet: const TextStyle(color: Colors.white),
              ),
            ),
          if (content.isNotEmpty && !isThinking) ...[
            const SizedBox(height: 12),
            _buildActionButtons(context),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _buildIconButton(
          icon: Icons.copy_rounded,
          onTap: () {
            Clipboard.setData(ClipboardData(text: content));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Copied to clipboard'),
                duration: Duration(seconds: 2),
                backgroundColor: AppTheme.backgroundDarkGray,
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        _buildIconButton(
          icon: Icons.replay_rounded,
          onTap: () {
            RetryLastMessageAction().execute();
          },
        ),
        const SizedBox(width: 8),
        _buildIconButton(
          icon: Icons.thumb_up_alt_outlined,
          onTap: () {
             // Mock feedback implementation
          },
        ),
        const SizedBox(width: 8),
        _buildIconButton(
          icon: Icons.thumb_down_alt_outlined,
          onTap: () {
             // Mock feedback implementation
          },
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLightGray.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppTheme.textGray,
          size: 16,
        ),
      ),
    );
  }
}
