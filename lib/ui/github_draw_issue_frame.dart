import 'package:flutter/material.dart';

import '../api/issue.dart';
import '../api/repository.dart';
import 'github_draw_issue_comments.dart';

class GithubDrawIssueFrame extends StatelessWidget {
  final Repository repository;
  final String repoId;
  final Issue issue;
  const GithubDrawIssueFrame({
    super.key,
    required this.repository,
    required this.repoId,
    required this.issue
  });

  Widget drawLabels(BuildContext context) {
    final issueLabels = issue.issueLabels;
    final draw = issueLabels.map((issueLabel) {
      final Color backColor;
      final Color fontColor;
      if (MediaQuery.platformBrightnessOf(context) == Brightness.light) {
        backColor = Colors.transparent;
        fontColor = Colors.black;
      }
      else {
        backColor = Color.fromARGB(
          255,
          ((issueLabel.color.red - 255 * 0.4)).toInt().abs(),
          (issueLabel.color.green - 255 * 0.4).toInt().abs(),
          (issueLabel.color.blue - 255 * 0.4).toInt().abs(),
        );
        fontColor = issueLabel.color;
      }
      return Row(children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: backColor,
            border: Border.all(color: issueLabel.color, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(17))
          ),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Text(issueLabel.name, style: TextStyle(color: fontColor))
          ),
        ),
        const SizedBox(width: 5)
        ]
      );
    }).toList();
    if (issueLabels.isEmpty) {
      return Text("ラベルはありません。", style: TextStyle(color: Theme.of(context).colorScheme.onSurface));
    }
    else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: draw
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleTextStyle = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 24,
      color: Theme.of(context).colorScheme.onSurface
    );
    const authorTextStyle = TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: Colors.grey
    );
    final buttonStyle = ButtonStyle(
      textStyle: WidgetStatePropertyAll(TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      foregroundColor: const WidgetStatePropertyAll(Colors.transparent),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))
        )
      ),
      alignment: Alignment.topLeft,
      padding: const WidgetStatePropertyAll(EdgeInsets.all(10))
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2.0),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: SizedBox(
        width: width,
        height: 130,
        child: ElevatedButton(
          style: buttonStyle,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (builder) =>
                GithubDrawIssueComments(
                  repository: repository,
                  repoId: repoId,
                  issue: issue,
                ))
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(issue.title, style: titleTextStyle),
              const SizedBox(height: 10),
              drawLabels(context),
              const SizedBox(height: 10),
              Text(issue.author ?? "Unknown", style: authorTextStyle),
            ],
          )
        ),
      )
    );
  }
}