import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
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
      name: json['name'] ?? 'Unknown',
      provider: json['provider'] ?? 'Unknown',
      type: json['type'] ?? 'balanced',
      key: json['key'] ?? '',
    );
  }
}

class AIProvider {
  final String id;
  final String name;

  AIProvider({required this.id, required this.name});

  factory AIProvider.fromJson(Map<String, dynamic> json) {
    return AIProvider(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
    );
  }
}

class ChatMessage {
  final String role; // 'user' or 'assistant'
  String content;
  bool isThinking;
  String statusText;

  ChatMessage({
    required this.role,
    required this.content,
    this.isThinking = false,
    this.statusText = '',
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
    );
  }
}

class ChatSession {
  final String id;
  final String title;

  ChatSession({required this.id, required this.title});

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'New Chat',
    );
  }
}

class ChatStore {
  String? activeChatId;
  String inputText = '';
  bool isBottomSheetOpen = false;
  List<AIProvider> availableProviders = [];
  List<AIModel> availableModels = [];
  AIModel? selectedModel;
  List<Attachment> attachments = [];
  List<ChatMessage> messages = [];
  List<ChatSession> chatHistory = [];
  bool isResponding = false;
  bool isHistoryLoading = false;
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

  static Future<void> loadProviders() async {
    try {
      final response = await ApiClient().get('/providers');
      if (response.statusCode == 200) {
        final List<dynamic> provJson = response.data['providers'] ?? [];
        _store.availableProviders = provJson.map((json) => AIProvider.fromJson(json)).toList();
        _notify();
      }
    } catch (e) {
      // Ignore
    }
  }

  static Future<void> loadProviderModels(String providerId) async {
    try {
      final response = await ApiClient().get('/providers/$providerId/models');
      if (response.statusCode == 200) {
        final List<dynamic> modelsJson = response.data['models'] ?? [];
        _store.availableModels = modelsJson.map((json) => AIModel.fromJson(json)).toList();
        if (_store.availableModels.isNotEmpty && _store.selectedModel == null) {
          _store.selectedModel = _store.availableModels.first;
        }
        _notify();
      }
    } catch (e) {
      // Ignore
    }
  }

  static Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _store.messages = [
      ..._store.messages,
      ChatMessage(role: 'user', content: message),
    ];
    
    // Add an empty assistant message to append to
    final assistantIndex = _store.messages.length;
    _store.messages = [
      ..._store.messages,
      ChatMessage(
        role: 'assistant', 
        content: '',
        isThinking: true,
        statusText: 'Thinking about $message...',
      ),
    ];
    
    _store.inputText = '';
    _store.isResponding = true;
    _notify();

    try {
      final model = _store.selectedModel;
      final response = await ApiClient().dio.post(
        '/chat',
        data: {
          'message': {
            'messageId': DateTime.now().millisecondsSinceEpoch.toString(),
            'chatId': _store.activeChatId,
            'content': message,
          },
          'optimizationMode': model?.type ?? 'balanced',
          'sources': [],
          'history': _store.messages
              .sublist(0, assistantIndex) // exclude the empty assistant message
              .where((m) => m.content.isNotEmpty)
              .map((m) => [m.role, m.content])
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
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      
      await for (final chunk in stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (chunk.trim().isEmpty) continue;
        
        try {
          final event = jsonDecode(chunk);
          final type = event['type'];
          
          if (type == 'updateBlock') {
            final patch = event['patch'] as String? ?? '';
            _store.messages[assistantIndex].content += patch;
            _notify();
          } else if (type == 'block') {
             // Block starts
             _store.messages[assistantIndex].statusText = 'Generating response...';
             _notify();
          } else if (type == 'messageEnd') {
            _store.messages[assistantIndex].isThinking = false;
            _notify();
            break;
          } else if (type == 'error') {
             _store.messages[assistantIndex].isThinking = false;
             _store.messages[assistantIndex].content += '\n\n[Error: ${event['data']}]';
             _notify();
             break;
          }
        } catch (e) {
          // Ignore malformed chunks
        }
      }
    } catch (e) {
      _store.messages[assistantIndex].isThinking = false;
      _store.messages[assistantIndex].content = 'Error: $e';
      _notify();
    } finally {
      _store.isResponding = false;
      if (assistantIndex < _store.messages.length) {
         _store.messages[assistantIndex].isThinking = false;
      }
      _notify();
    }
  }

  static Future<void> retryLastMessage() async {
    if (_store.messages.isEmpty) return;
    
    // Find last user message
    String? lastUserMessage;
    for (var i = _store.messages.length - 1; i >= 0; i--) {
      if (_store.messages[i].role == 'user') {
        lastUserMessage = _store.messages[i].content;
        // Remove everything after this message to "reset" the tail
        _store.messages = _store.messages.sublist(0, i + 1);
        break;
      }
    }
    
    if (lastUserMessage != null) {
      _notify();
      await sendMessage(lastUserMessage);
    }
  }

  static Future<void> loadChats() async {
    _store.isHistoryLoading = true;
    _notify();
    try {
      final response = await ApiClient().get('/chats');
      if (response.statusCode == 200) {
        final List<dynamic> chatsJson = response.data['chats'] ?? [];
        _store.chatHistory = chatsJson.map((json) => ChatSession.fromJson(json)).toList();
      }
    } catch (e) {
      // Handle or ignore
    } finally {
      _store.isHistoryLoading = false;
      _notify();
    }
  }

  static Future<void> loadChat(String id) async {
    _store.activeChatId = id;
    _store.messages = [];
    _store.isHistoryLoading = true;
    _notify();
    try {
      final response = await ApiClient().get('/chats/$id');
      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = response.data['messages'] ?? [];
        _store.messages = messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
      }
    } catch (e) {
      // Handle or ignore
    } finally {
      _store.isHistoryLoading = false;
      _notify();
    }
  }

  static Future<void> deleteChat(String id) async {
    try {
      final response = await ApiClient().delete('/chats/$id');
      if (response.statusCode == 200) {
        _store.chatHistory.removeWhere((session) => session.id == id);
        if (_store.activeChatId == id) {
          _store.activeChatId = null;
          _store.messages = [];
        }
        _notify();
      }
    } catch (e) {
      // Handle or ignore
    }
  }

  static Future<void> reconnectStream(String id) async {
    try {
      // Example endpoint; implementation varies by backend
      await ApiClient().get('/reconnect/$id');
    } catch (e) {
      // Handle or ignore
    }
  }

  static void resetChat() {
    _store.activeChatId = null;
    _store.messages = [];
    _store.attachments = [];
    _notify();
  }

  // ─── Search & Widget APIs ─────────────────────────────────────────────────

  /// POST /search – full-text search across knowledge base.
  static Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      final response = await ApiClient().post(
        '/search',
        data: {'query': query},
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['results'] ?? []);
      }
    } catch (_) {}
    return [];
  }

  /// GET /suggestions – auto-complete suggestions for chat input.
  static Future<List<String>> getSuggestions(String query) async {
    try {
      final response = await ApiClient().get(
        '/suggestions',
        queryParameters: {'query': query},
      );
      if (response.statusCode == 200) {
        return List<String>.from(response.data['suggestions'] ?? []);
      }
    } catch (_) {}
    return [];
  }

  /// POST /images – AI image generation; returns image URL.
  static Future<String?> generateImage(String prompt) async {
    try {
      final response = await ApiClient().post(
        '/images',
        data: {'prompt': prompt},
      );
      if (response.statusCode == 200) {
        return response.data['url'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// POST /videos – AI video generation; returns video URL.
  static Future<String?> generateVideo(String prompt) async {
    try {
      final response = await ApiClient().post(
        '/videos',
        data: {'prompt': prompt},
      );
      if (response.statusCode == 200) {
        return response.data['url'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// GET /weather – get weather widget data for a location.
  static Future<Map<String, dynamic>?> getWeather(String location) async {
    try {
      final response = await ApiClient().get(
        '/weather',
        queryParameters: {'location': location},
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (_) {}
    return null;
  }

  // ─── File Upload API ──────────────────────────────────────────────────────

  /// POST /uploads – uploads a local file, returns remote URL.
  /// Replaces the local attachment path with the remote URL in the store.
  static Future<String?> uploadAttachment(String localPath) async {
    try {
      final response = await ApiClient().uploadFile('/uploads', localPath);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['url'] as String?;
      }
    } catch (_) {}
    return null;
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

class LoadProvidersAction {
  Future<void> execute() => ChatDataflow.loadProviders();
}

class LoadProviderModelsAction {
  final String providerId;
  LoadProviderModelsAction(this.providerId);
  Future<void> execute() => ChatDataflow.loadProviderModels(providerId);
}

class SendMessageAction {
  final String message;
  SendMessageAction(this.message);
  Future<void> execute() => ChatDataflow.sendMessage(message);
}

class LoadChatsAction {
  Future<void> execute() => ChatDataflow.loadChats();
}

class LoadChatAction {
  final String id;
  LoadChatAction(this.id);
  Future<void> execute() => ChatDataflow.loadChat(id);
}

class DeleteChatAction {
  final String id;
  DeleteChatAction(this.id);
  Future<void> execute() => ChatDataflow.deleteChat(id);
}

class ResetChatAction {
  void execute() => ChatDataflow.resetChat();
}

class SearchAction {
  final String query;
  SearchAction(this.query);
  Future<List<Map<String, dynamic>>> execute() => ChatDataflow.search(query);
}

class GetSuggestionsAction {
  final String query;
  GetSuggestionsAction(this.query);
  Future<List<String>> execute() => ChatDataflow.getSuggestions(query);
}

class GenerateImageAction {
  final String prompt;
  GenerateImageAction(this.prompt);
  Future<String?> execute() => ChatDataflow.generateImage(prompt);
}

class GenerateVideoAction {
  final String prompt;
  GenerateVideoAction(this.prompt);
  Future<String?> execute() => ChatDataflow.generateVideo(prompt);
}

class GetWeatherAction {
  final String location;
  GetWeatherAction(this.location);
  Future<Map<String, dynamic>?> execute() => ChatDataflow.getWeather(location);
}

class UploadAttachmentAction {
  final String localPath;
  UploadAttachmentAction(this.localPath);
  Future<String?> execute() => ChatDataflow.uploadAttachment(localPath);
}

class RetryLastMessageAction {
  Future<void> execute() => ChatDataflow.retryLastMessage();
}

