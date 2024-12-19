import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kadai/module/sublist.dart';

import '../api/Github.dart';
import '../api/issue.dart';
import '../api/repository.dart';
import 'github_draw_issue_frame.dart';

class GithubDrawIssues extends HookConsumerWidget {

  final Repository repository;
  final int items;

  const GithubDrawIssues({
    super.key,
    required this.repository,
    required this.items
  });

  void _nextPage(ValueNotifier<int> page, ValueNotifier<int> maxPage) {
    if (page.value < maxPage.value) {
      page.value++;
    }
  }
  void _backPage(ValueNotifier<int> page) {
    if (page.value > 1) {
      page.value--;
    }
  }
  Widget _hidden(bool hide, Widget child) {
    if (!hide) {
      return child;
    }
    else {
      return const SizedBox(width: 0, height: 0);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issueLoader = useState(Github(ref, null).getIssues(repository.name));
    final issues = useFuture(issueLoader.value);
    final currentPage = useState(1);
    final maxPage = useState(1);
    Widget drawFrames = const SizedBox(width: 0, height: 0);

    if (issues.connectionState == ConnectionState.waiting) {
      drawFrames = const Align(
        alignment: Alignment.topCenter,
        child: CircularProgressIndicator()
      );
    }
    else if (issues.hasData) {
      final data = issues.data;
      if (data != null && (data.elementAt(1) as List<Issue>).isNotEmpty) {
        final repoId = data.elementAt(0) as String;
        final getIssues = data.elementAt(1) as List<Issue>;
        final List<Column> drawList = [];
        maxPage.value = (getIssues.length - 1) ~/ items + 1;
        if (currentPage.value > maxPage.value) {
          currentPage.value = maxPage.value;
        }
        for (int issueNum = 0; issueNum < getIssues.length; issueNum++) {
          drawList.add(Column(
            children: [
              GithubDrawIssueFrame(
                repository: repository,
                repoId: repoId,
                issue: getIssues[issueNum],
              ),
              const SizedBox(height: 10.0)
            ],
          ));
        }
        final displayList = subList(drawList, (currentPage.value - 1) * items, currentPage.value * items);
        drawFrames = Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Expanded(child: Align(
                alignment: Alignment.topCenter,
                child: RefreshIndicator(
                  onRefresh: () {
                    return Future.value(
                      (() async {
                        issueLoader.value = Github(ref, null).getIssues(repository.name);
                      })()
                    );
                  },
                  child: ListView(
                    children: displayList,
                  )
                )
              )),
            ],
          ),
        );
      }
      else {
        drawFrames = const Align(
          alignment: Alignment.topCenter,
          child: Text("Issuesはありません。")
        );
      }
    }

    return Column (
      children: [
        Expanded(child: drawFrames),
        SizedBox(
          height: 100,
          child: Row(
            children: [
              Expanded(
                child: _hidden(
                  currentPage.value <= 1,
                  Center(
                    child: TextButton(onPressed: () { _backPage(currentPage); }, child: const Text("<"))
                  )
                )
              ),
              Expanded(child: Center(child: Text("${currentPage.value} / ${maxPage.value}"))),
              Expanded(
                child: _hidden(
                  currentPage.value >= maxPage.value,
                  Center(
                    child: TextButton(onPressed: () { _nextPage(currentPage, maxPage); }, child: const Text(">"))
                  )
                )
              )
            ],
          ),
        )
      ],
    );
  }
}