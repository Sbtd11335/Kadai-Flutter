import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kadai/api/repository.dart';
import 'package:kadai/main.dart';

import '../module/sublist.dart';
import 'github_repository_frame.dart';
import '../api/github.dart';

class GithubDrawRepositories extends HookConsumerWidget {

  final int items;
  const GithubDrawRepositories({
    super.key,
    required this.items
  });

  Widget _hidden(bool hide, Widget child) {
    if (hide) {
      return const SizedBox(width: 0, height: 0);
    }
    else {
      return child;
    }
  }
  Widget _switch(bool flag, Widget child1, Widget child2) {
    if (!flag) {
      return child1;
    }
    else {
      return child2;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repositoriesFuture = useState(Future.value(<Repository>[]));
    final currentPage = useState(1);
    final maxPage = useState(1);
    final repoDraw = useState<Widget>(const SizedBox());
    final scrollController = ScrollController();
    var repositories = useFuture(repositoriesFuture.value);
    final textStyle = TextStyle(
        color: Theme.of(context).colorScheme.onSurface
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.watch(search)) {
        ref.read(search.notifier).state = false;
        repositoriesFuture.value = Github(ref, null).getRepositories();
      }
    });

    if (repositories.connectionState == ConnectionState.waiting) {
      repoDraw.value = const Center(child: const CircularProgressIndicator());
    }
    else {
      var displayList = <Widget>[];
      if (repositories.hasData) {
        final data = repositories.data!;
        final getRepositoryName = ref.watch(repositoryName);
        final ret = data.where((repo) {
          return repo.name.toLowerCase().contains(getRepositoryName.toLowerCase());
        })
            .map((repo) => GithubRepositoryFrame(repository: repo))
            .toList();
        maxPage.value = (ret.length - 1) ~/ items + 1;
        if (currentPage.value > maxPage.value) {
          currentPage.value = maxPage.value;
        }
        displayList = subList(
            ret,
            (currentPage.value - 1) * items,
            currentPage.value * items
        );
        repoDraw.value = _switch(
          ret.isEmpty,
          RefreshIndicator(
              child: ListView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: displayList,
              ),
              onRefresh: () {
                return Future.value((() {
                  repositoriesFuture.value = Github(ref, null).getRepositories();
                })());
              }),
          Text(
              "リポジトリが見つかりませんでした。",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)
          )
        );
      }
      else {
        repoDraw.value = Text(
            "リポジトリが見つかりませんでした。",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)
        );
      }
    }
    return Expanded(child: Column(
      children: [
        Expanded(
            child: repoDraw.value
        ),
        SizedBox(
            height: 100,
            child: Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: _hidden(
                              currentPage.value == 1,
                              Center(
                                  child: TextButton(onPressed: () {
                                    currentPage.value--;
                                    scrollController.jumpTo(0.0);
                                  }, child: Text("<", style: textStyle))
                              )
                          )
                      ),
                      Expanded(
                          child: Center(
                              child: _hidden(
                                  !repositories.hasData,
                                  Text("${currentPage.value} / ${maxPage.value}", style: textStyle)
                              )
                          )
                      ),
                      Expanded(
                          child: _hidden(
                              currentPage.value == maxPage.value,
                              Center(
                                  child: TextButton(onPressed: () {
                                    currentPage.value++;
                                    scrollController.jumpTo(0.0);
                                  }, child: const Text(">"))
                              )
                          )
                      ),
                    ]
                )
            )
        )
      ],
    ));
  }
}