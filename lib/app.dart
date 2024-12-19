import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kadai/api/github.dart';
import 'package:kadai/scenes/setting.dart';
import 'package:kadai/ui/github_draw_repositories.dart';

import 'main.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("リポジトリ"),
        actions: [
          IconButton(onPressed: () => {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) => const Setting())
            )
          }, icon: const Icon(Icons.settings))
        ],
      ),
      body: const AppHook(),
    );
  }
}

class AppHook extends HookConsumerWidget {
  const AppHook({super.key});

  AlertDialog _errorDialog(BuildContext context, String message) {
    return AlertDialog(
      title: Text("エラー！", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK")
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final nameController = TextEditingController();
    nameController.text = ref.read(repositoryName);
    ref.read(search.notifier).state = false;

    return GraphQLProvider(
      client: ValueNotifier(Github(ref, null).client),
      child: Center(
        child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: SizedBox(
                        width: deviceWidth,
                        height: 50.0,
                        child: Row(children: [
                          Expanded(
                              flex: 2,
                              child: TextField(
                                controller: nameController,
                                decoration: const InputDecoration(labelText: "リポジトリを検索"),
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                              )
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      backgroundColor: Theme.of(context).colorScheme.inversePrimary
                                  ),
                                  onPressed: () {
                                    final token = ref.watch(githubToken);
                                    print(token);
                                    if (token.isEmpty) {
                                      showDialog(context: context, builder: (context) {
                                        return _errorDialog(context, "Githubトークンが入力されておりません。\n設定画面よりトークンを入力してください。");
                                      });
                                    }
                                    ref.read(repositoryName.notifier).state = nameController.text;
                                    ref.read(search.notifier).state = true;
                                  },
                                  child: Text(
                                      "検索",
                                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface)
                                  )
                              )
                          )
                        ])
                    )
                ),
                const SizedBox(height: 10.0),
                const GithubDrawRepositories(items: 5)
              ],
            )
        ),
      ),
    );
  }
}