import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kadai/api/github.dart';
import 'package:kadai/api/repository.dart';
import 'package:kadai/scenes/setting.dart';
import 'package:kadai/ui/github_draw_repositories.dart';

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
      body: const AppState(),
    );
  }
}

class AppState extends StatefulWidget {
  const AppState({super.key});

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<AppState> {

  Github? _github;
  List<Repository> _repositories = [];
  int _currentPage = 1;
  bool isLoading = false;
  final nameController = TextEditingController();

  void setGithub(Github github) {
    setState(() {
      _github = github;
    });
  }
  void setRepositories(List<Repository> repositories) {
    setState(() {
      _repositories = repositories;
    });
  }
  void searchRepositories(BuildContext context, String name, Function(bool) isLoading) async {
    isLoading(true);
    final token = SharedAppData.getValue(context, "GithubToken", () => "");
    final github = Github(context, token);

    if (token.isEmpty) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            isLoading(false);
            return _errorDialog(context, "トークンが入力されておりません。\n設定画面からトークンを入力してください。");
          }
      );
    }
    else {
      github.getRepositories().then((result) {
        setRepositories(result.where((repo) {
          isLoading(false);
          return repo.name.toLowerCase().contains(name);
        }).toList());
      });
    }

  }
  void nextPage(int maxPage) {
    setState(() {
      if (_currentPage < maxPage) {
        _currentPage++;
      }
    });
  }
  void backPage() {
    setState(() {
      if (_currentPage > 1) {
        _currentPage--;
      }
    });
  }

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
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final scrollController = ScrollController();
    _github = Github(context, null);

    WidgetsBinding.instance.addPostFrameCallback((_){
      if (SharedAppData.getValue(context, "RefreshRepositories", () => false)) {
        searchRepositories(context, nameController.text, (isLoading) {
          this.isLoading = isLoading;
        });
        SharedAppData.setValue(context, "RefreshRepositories", null);
      }
    });

    return GraphQLProvider(
      client: ValueNotifier(_github!.client),
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
                          searchRepositories(context, nameController.text, (isLoading) {
                            this.isLoading = isLoading;
                          });
                          setState(() {
                            _currentPage = 1;
                          });
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
              GithubDrawRepositories(
                repositories: _repositories,
                items: 10,
                currentPage: _currentPage,
                nextPage: nextPage,
                backPage: backPage,
                scrollController: scrollController,
                isLoading: isLoading
              )
            ],
          )
        ),
      ),
    );
  }
}