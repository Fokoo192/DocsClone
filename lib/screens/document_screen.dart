import 'package:docs_clone/colors.dart';
import 'package:docs_clone/common/widgets/loader.dart';
import 'package:docs_clone/models/document_model.dart';
import 'package:docs_clone/repository/auth_repo.dart';
import 'package:docs_clone/repository/document_repo.dart';
import 'package:docs_clone/repository/socket_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:docs_clone/models/error_model.dart';
import 'dart:async';

import 'package:routemaster/routemaster.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController =
      TextEditingController(text: "Untitled Document");
  quill.QuillController? _controller;
  ErrorModel? errorModel;
  SocketRepo socketRepo = SocketRepo();

  @override
  void initState() {
    super.initState();
    socketRepo.joinRoom(widget.id);
    fetchDocumentData();

    socketRepo.changeListner((data) {
      _controller?.compose(
        quill.Delta.fromJson(data["delta"]),
        _controller?.selection ?? const TextSelection.collapsed(offset: 0),
        quill.ChangeSource.REMOTE,
      );
    });
    // saves every 2 seconds instead of once like it would without Time.periodic()
    Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepo.autoSave(<String, dynamic>{
        "delta": _controller!.document.toDelta(),
        "docId": widget.id,
      });
    });
  }

  void fetchDocumentData() async {
    errorModel = await ref.read(documentRepoProvider).getDocumentById(
          ref.read(userProvider)!.token,
          widget.id,
        );

    if (errorModel!.data != null) {
      titleController.text = (errorModel!.data as DocumentModel).title;
      _controller = quill.QuillController(
        document: errorModel!.data.contents.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(
                quill.Delta.fromJson(errorModel!.data.contents)),
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {}); //rebuild the widget
    }

    _controller!.document.changes.listen((event) {
      //only broadcasting data when changes are made locally, this is to ensure we don't get stuck in an infinite loop
      if (event.item3 == quill.ChangeSource.LOCAL) {
        Map<String, dynamic> map = {"delta": event.item2, "room": widget.id};
        socketRepo.typing(map);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  void updateTitle(WidgetRef ref, String title) {
    ref.read(documentRepoProvider).updateTitle(
        token: ref.read(userProvider)!.token, id: widget.id, title: title);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(
        body: Loader(),
      );
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorWhite,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                        text: "http://localhost:3000/#/document/${widget.id}"),
                  ).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Link copied!",
                        ),
                      ),
                    );
                  });
                },
                icon: const Icon(
                  Icons.lock_sharp,
                  size: 16,
                ),
                label: const Text("Share"),
                style: ElevatedButton.styleFrom(backgroundColor: ColorBlue),
              ),
            )
          ],
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(children: [
              GestureDetector(
                onTap: () {
                  Routemaster.of(context).replace("/");
                },
                child: Image.asset(
                  "assets/images/docs-logo.png",
                  height: 40,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: ColorBlue)),
                      contentPadding: EdgeInsets.only(left: 10)),
                  onSubmitted: (value) => updateTitle(ref, value),
                ),
              )
            ]),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: ColorGrey, width: 0.1)),
            ),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              quill.QuillToolbar.basic(controller: _controller!),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: SizedBox(
                  width: 900,
                  child: Card(
                    color: ColorWhite,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: quill.QuillEditor.basic(
                        controller: _controller!,
                        readOnly: false, // true for view only mode
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
