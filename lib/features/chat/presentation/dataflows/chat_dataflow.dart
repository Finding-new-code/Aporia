import 'package:dataflow/dataflow.dart';

class Attachment {
  final String name;
  final String path;
  final String type; // 'image', 'file', 'camera'

  Attachment({required this.name, required this.path, required this.type});
}

class ChatStore extends DataStore {
  String inputText = '';
  bool isBottomSheetOpen = false;
  String selectedModel = 'Aporia-X';
  List<Attachment> attachments = [];
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
  final String model;

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
