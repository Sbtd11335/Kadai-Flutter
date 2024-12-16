import 'package:flutter/material.dart';
import 'package:kadai/api/repository.dart';

import '../module/sublist.dart';
import 'github_repository_frame.dart';
import '../api/github.dart';

class GithubDrawRepositories extends StatefulWidget {
  final List<Repository> repositories;
  final int items;
  final int currentPage;
  final Function(int) nextPage;
  final Function() backPage;
  final ScrollController scrollController;
  final bool isLoading;

  const GithubDrawRepositories({
    super.key,
    required this.repositories,
    required this.items,
    required this.currentPage,
    required this.nextPage,
    required this.backPage,
    required this.scrollController,
    required this.isLoading
  });

  @override
  State<StatefulWidget> createState() => _GithubDrawRepositories();

}

class _GithubDrawRepositories extends State<GithubDrawRepositories> {
  int _maxPage = 1;

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
  Widget build(BuildContext context) {
    final ret = widget.repositories.map((repo) => GithubRepositoryFrame(repository: repo)).toList();
    _maxPage = (ret.length - 1) ~/ widget.items + 1;
    final displayList = subList(
        ret,
        (widget.currentPage - 1) * widget.items,
        widget.currentPage * widget.items
    );
    final textStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface
    );

    return Expanded(child: Column(
      children: [
        Expanded(
          child: _switch(
            !widget.isLoading,
            const Center(child: CircularProgressIndicator()),
            _switch(widget.repositories.isEmpty,
              RefreshIndicator(
                child: ListView(
                controller: widget.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: displayList,
                ),
                onRefresh: () {
                  return Future.value([SharedAppData.setValue(context, "RefreshRepositories", true)]);
              }),
              Text(
                "リポジトリが見つかりませんでした。",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface)
              )
            )
          )
        ),
        SizedBox(
          height: 100,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _hidden(
                    widget.currentPage == 1,
                    Center(
                      child: TextButton(onPressed: () {
                        widget.backPage();
                        widget.scrollController.jumpTo(0.0);
                      }, child: Text("<", style: textStyle))
                    )
                  )
                ),
                Expanded(
                  child: Center(
                    child: _hidden(
                      widget.repositories.isEmpty,
                      Text("${widget.currentPage} / $_maxPage", style: textStyle)
                    )
                  )
                ),
                Expanded(
                  child: _hidden(
                    widget.currentPage == _maxPage,
                    Center(
                      child: TextButton(onPressed: () {
                        widget.nextPage(_maxPage);
                        widget.scrollController.jumpTo(0.0);
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