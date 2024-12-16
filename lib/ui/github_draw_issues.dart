import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kadai/module/sublist.dart';

import '../api/Github.dart';
import '../api/issue.dart';
import '../api/repository.dart';
import 'github_draw_issue_frame.dart';

class GithubDrawIssues extends StatefulWidget {

  final Repository repository;
  final int items;
  const GithubDrawIssues({
    super.key,
    required this.repository,
    required this.items
  });

  @override
  State<StatefulWidget> createState() => _GithubDrawIssues();
}

class _GithubDrawIssues extends State<GithubDrawIssues> {

  late Future<Set<Object>> _issues;
  int _currentPage = 1;
  int _maxPage = 1;

  void _reloadIssues() {
    setState(() {
      _issues = Github(context, null).getIssues(widget.repository.name);
    });
  }
  void _nextPage() {
    setState(() {
      if (_currentPage < _maxPage) {
        _currentPage++;
      }
    });
  }
  void _backPage() {
    setState(() {
      if (_currentPage > 1) {
        _currentPage--;
      }
    });
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
  Widget build(BuildContext context) {
    _issues = Github(context, null).getIssues(widget.repository.name);
    return FutureBuilder(
      future: _issues,
      builder: (builder, snapshot) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (SharedAppData.getValue(context, "ReloadIssues", () => false)) {
            SharedAppData.setValue(context, "ReloadIssues", null);
            _reloadIssues();
          }
        });

        final Widget drawFrames;
        if (snapshot.connectionState == ConnectionState.waiting) {
          drawFrames = const Align(
              alignment: Alignment.topCenter,
              child: CircularProgressIndicator()
          );
        }
        else if (snapshot.hasData) {
          if (snapshot.data != null && (snapshot.data!.elementAt(1) as List<Issue>).isNotEmpty) {
            final repoId = snapshot.data!.elementAt(0) as String;
            final issues = snapshot.data!.elementAt(1) as List<Issue>;
            final List<Column> drawList = [];
            _maxPage = (issues.length - 1) ~/ widget.items + 1;
            for (int issueNum = 0; issueNum < issues.length; issueNum++) {
              drawList.add(Column(
                children: [
                  GithubDrawIssueFrame(
                    repository: widget.repository,
                    repoId: repoId,
                    issue: issues[issueNum],
                  ),
                  const SizedBox(height: 10.0)
                ],
              ));
            }
            final displayList = subList(drawList, (_currentPage - 1) * widget.items, _currentPage * widget.items);
            drawFrames = Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Expanded(child: Align(
                      alignment: Alignment.topCenter,
                      child: RefreshIndicator(
                        onRefresh: () {
                         return Future.value([_reloadIssues()]);
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
            return const Align(
                alignment: Alignment.topCenter,
                child: Text("Issuesはありません。")
            );
          }
        }
        else {
          drawFrames = const Align(
              alignment: Alignment.topCenter,
              child: Text("Issuesはありません。")
          );
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
                      _currentPage <= 1,
                      Center(
                        child: TextButton(onPressed: _backPage, child: const Text("<"))
                      )
                    )
                  ),
                  Expanded(child: Center(child: Text("$_currentPage / $_maxPage"))),
                  Expanded(
                    child: _hidden(
                      _currentPage >= _maxPage,
                      Center(
                        child: TextButton(onPressed: _nextPage, child: const Text(">"))
                      )
                    )
                  )
                ],
              ),
            )
          ],
        );
      }
    );
  }
}