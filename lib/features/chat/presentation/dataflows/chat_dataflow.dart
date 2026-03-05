import 'package:dataflow/dataflow.dart';
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

class ChatStore extends DataStore {
  String inputText = '';
  bool isBottomSheetOpen = false;

  List<AIModel> availableModels = [];
  AIModel? selectedModel;

  List<Attachment> attachments = [];

  // Basic chat history and loading state
  List<Map<String, String>> messages = [];
  bool isResponding = false;
}

void initChatDataflow() {
  DataFlow.init<ChatStore>(ChatStore());
}

class UpdateInputAction extends DataAction<ChatStore> {
  final String text;

  UpdateInputAction(this.text);

  @override
  dynamic execute() {
    store.inputText = text;
  }
}

class ToggleBottomSheetAction extends DataAction<ChatStore> {
  @override
  dynamic execute() {
    store.isBottomSheetOpen = !store.isBottomSheetOpen;
  }
}

class SelectModelAction extends DataAction<ChatStore> {
  final AIModel model;

  SelectModelAction(this.model);

  @override
  dynamic execute() {
    store.selectedModel = model;
  }
}

class AddAttachmentAction extends DataAction<ChatStore> {
  final Attachment attachment;

  AddAttachmentAction(this.attachment);

  @override
  dynamic execute() {
    store.attachments = [...store.attachments, attachment];
  }
}

class RemoveAttachmentAction extends DataAction<ChatStore> {
  final int index;

  RemoveAttachmentAction(this.index);

  @override
  dynamic execute() {
    final newList = List<Attachment>.from(store.attachments);
    newList.removeAt(index);
    store.attachments = newList;
  }
}

class LoadModelsAction extends DataAction<ChatStore> {
  @override
  Future<void> execute() async {
    try {
      final response = await ApiClient().get('/models');
      if (response.statusCode == 200) {
        final List<dynamic> modelsJson = response.data['models'];
        store.availableModels = modelsJson
            .map((json) => AIModel.fromJson(json))
            .toList();
        if (store.availableModels.isNotEmpty && store.selectedModel == null) {
          store.selectedModel = store.availableModels.first;
        }
      }
    } catch (e) {
      print('Failed to load models: $e');
    }
  }
}

class SendMessageAction extends DataAction<ChatStore> {
  final String message;

  SendMessageAction(this.message);

  @override
  Future<void> execute() async {
    if (message.trim().isEmpty || store.selectedModel == null) return;

    store.messages = [
      ...store.messages,
      {'role': 'user', 'content': message},
    ];
    store.inputText = '';
    store.isResponding = true;

    DataFlow.notify(this);

    try {
      final response = await ApiClient().post(
        '/chat',
        data: {
          'message': {
            'messageId': DateTime.now().millisecondsSinceEpoch.toString(),
            'chatId': 'default-chat-id',
            'content': message,
          },
          'optimizationMode': store.selectedModel!.type,
          'sources': [],
          'history': store.messages
              .where((m) => m['role'] != null && m['content'] != null)
              .map((m) => [m['role'], m['content']])
              .toList(),
          'chatModel': {
            'providerId': store.selectedModel!.provider,
            'key': store.selectedModel!.key,
          },
          'embeddingModel': {
            'providerId': 'openai',
            'key': 'text-embedding-3-small', // Default fallback mock
          },
        },
      );

      // Simple mock parser: wait for stream/response completion and append
      // In a real app we'd parse the SSE stream block by block using responseType: ResponseType.stream
      if (response.statusCode == 200) {
        store.messages = [
          ...store.messages,
          {
            'role': 'assistant',
            'content': 'Response received from Aporia-Main backend.',
          },
        ];
      } else {
        store.messages = [
          ...store.messages,
          {'role': 'assistant', 'content': 'Could not reach the server.'},
        ];
      }
    } catch (e) {
      store.messages = [
        ...store.messages,
        {'role': 'assistant', 'content': 'An error occurred: $e'},
      ];
    } finally {
      store.isResponding = false;
    }
  }
}
