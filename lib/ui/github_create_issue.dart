import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../api/Github.dart';

class GithubCreateIssue extends HookConsumerWidget {

  final String repoId;
  const GithubCreateIssue({
    super.key,
    required this.repoId
  });

  Widget errorDialog(BuildContext context, String message) {
    return AlertDialog(
      title: Text("エラー！", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: const Text("OK")
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    const titleTextStyle = TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w500
    );
    final titleEditController = TextEditingController();
    final bodyEditController = TextEditingController();
    final buttonStyle = ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      foregroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.onSurface),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
    );
    final count = useState(0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Issueを作成"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("タイトル", style: titleTextStyle),
            const SizedBox(height: 10),
            TextField(
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                controller: titleEditController,
                decoration: const InputDecoration(labelText: "タイトルを入力")
            ),
            const SizedBox(height: 10),
            const Text("内容", style: titleTextStyle),
            const SizedBox(height: 10),
            ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: TextField(
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  controller: bodyEditController,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: "タイトルを入力",
                  ),
                  maxLines: null,
                )
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: width,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.grey),
                    borderRadius: const BorderRadius.all(Radius.circular(15))
                ),
                child: ElevatedButton(
                    style: buttonStyle,
                    onPressed: () {
                      final github = Github(ref, null);
                      final repoId = this.repoId;
                      final title = titleEditController.text;
                      final body = bodyEditController.text;
                      if (title.isEmpty) {
                        count.value = 0;
                        showDialog(
                            context: context,
                            builder: (builder) => errorDialog(context, "タイトルが入力されておりません。")
                        );
                        return;
                      }
                      if (body.isEmpty) {
                        count.value = 0;
                        showDialog(
                            context: context,
                            builder: (builder) => errorDialog(context, "内容が入力されておりません。")
                        );
                        return;
                      }
                      count.value++;
                      if (count.value == 1) {
                        github.createIssue(repoId, title, body).then((_) {
                          SharedAppData.setValue(context, "ReloadIssues", true);
                          Navigator.pop(context);
                        });
                      }
                    },
                    child: const Text("作成")
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}