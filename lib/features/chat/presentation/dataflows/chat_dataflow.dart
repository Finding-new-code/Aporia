import 'package:dataflow/dataflow.dart';

class ChatStore extends DataStore {
  String inputText = '';
  bool isBottomSheetOpen = false;
  String selectedModel = 'Aporia-X';
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
