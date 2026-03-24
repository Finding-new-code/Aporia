import 'dart:async';
import 'package:aporia/core/network/api_client.dart';

class Attachment {
  final String name;
  final String path;
  final String type; // 'image', 'file', 'camera'

  Attachment({required this.name, required this.path, required this.type});
}

class AIModel {
  final String name;
  final String provider;
  final String type;
  final String key;

  AIModel({
    required this.name,
    required this.provider,
    required this.type,
    required this.key,
  });

  factory AIModel.fromJson(Map<String, dynamic> json) {
    return AIModel(
      name: json['name'],
      provider: json['provider'],
      type: json['type'],
      key: json['key'],
    );
  }
}

class ChatStore {
  String inputText = '';
  bool isBottomSheetOpen = false;
  List<AIModel> availableModels = [];
  AIModel? selectedModel;
  List<Attachment> attachments = [];
  List<Map<String, String>> messages = [];
  bool isResponding = false;
}

/// Standalone chat state manager. Uses its own static store so it doesn't
/// collide with the single DataFlow global store slot.
class ChatDataflow {
  ChatDataflow._();

  static final ChatStore _store = ChatStore();
  static ChatStore get store => _store;

  static final _controller = StreamController<ChatStore>.broadcast();
  static Stream<ChatStore> get stream => _controller.stream;

  static void _notify() => _controller.add(_store);

  static void updateInput(String text) {
    _store.inputText = text;
    _notify();
  }

  static void toggleBottomSheet() {
    _store.isBottomSheetOpen = !_store.isBottomSheetOpen;
    _notify();
  }

  static void selectModel(AIModel model) {
    _store.selectedModel = model;
    _notify();
  }

  static void addAttachment(Attachment attachment) {
    _store.attachments = [..._store.attachments, attachment];
    _notify();
  }

  static void removeAttachment(int index) {
    final list = List<Attachment>.from(_store.attachments);
    list.removeAt(index);
    _store.attachments = list;
    _notify();
  }

  static Future<void> loadModels() async {
    try {
      final response = await ApiClient().get('/models');
      if (response.statusCode == 200) {
        final List<dynamic> modelsJson = response.data['models'] ?? [];
        _store.availableModels = modelsJson
            .map((json) => AIModel.fromJson(json))
            .toList();
        if (_store.availableModels.isNotEmpty && _store.selectedModel == null) {
          _store.selectedModel = _store.availableModels.first;
        }
        _notify();
      }
    } catch (e) {
      // Silently fail — models list stays empty
    }
  }

  static Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _store.messages = [
      ..._store.messages,
      {'role': 'user', 'content': message},
    ];
    _store.inputText = '';
    _store.isResponding = true;
    _notify();

    try {
      final model = _store.selectedModel;
      final response = await ApiClient().post(
        '/chat',
        data: {
          'message': {
            'messageId': DateTime.now().millisecondsSinceEpoch.toString(),
            'chatId': 'default-chat-id',
            'content': message,
          },
          'optimizationMode': model?.type ?? 'balanced',
          'sources': [],
          'history': _store.messages
              .where((m) => m['role'] != null && m['content'] != null)
              .map((m) => [m['role'], m['content']])
              .toList(),
          'chatModel': {
            'providerId': model?.provider ?? 'openai',
            'key': model?.key ?? 'gpt-4o-mini',
          },
          'embeddingModel': {
            'providerId': 'openai',
            'key': 'text-embedding-3-small',
          },
        },
      );

      if (response.statusCode == 200) {
        _store.messages = [
          ..._store.messages,
          {
            'role': 'assistant',
            'content': 'Response received from Aporia backend.',
          },
        ];
      } else {
        _store.messages = [
          ..._store.messages,
          {'role': 'assistant', 'content': 'Could not reach the server.'},
        ];
      }
    } catch (e) {
      _store.messages = [
        ..._store.messages,
        {'role': 'assistant', 'content': 'Error: $e'},
      ];
    } finally {
      _store.isResponding = false;
      _notify();
    }
  }
}

// ─── Thin shims so existing widgets compile without changes ──────────────────

void initChatDataflow() {
  // No-op: ChatDataflow now manages its own static state
}

class UpdateInputAction {
  final String text;
  UpdateInputAction(this.text);
  void execute() => ChatDataflow.updateInput(text);
}

class ToggleBottomSheetAction {
  void execute() => ChatDataflow.toggleBottomSheet();
}

class SelectModelAction {
  final AIModel model;
  SelectModelAction(this.model);
  void execute() => ChatDataflow.selectModel(model);
}

class AddAttachmentAction {
  final Attachment attachment;
  AddAttachmentAction(this.attachment);
  void execute() => ChatDataflow.addAttachment(attachment);
}

class RemoveAttachmentAction {
  final int index;
  RemoveAttachmentAction(this.index);
  void execute() => ChatDataflow.removeAttachment(index);
}

class LoadModelsAction {
  Future<void> execute() => ChatDataflow.loadModels();
}

class SendMessageAction {
  final String message;
  SendMessageAction(this.message);
  Future<void> execute() => ChatDataflow.sendMessage(message);
}
