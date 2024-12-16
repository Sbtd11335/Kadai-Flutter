import 'package:flutter/material.dart';
import 'package:kadai/api/issue.dart';

import '../api/Github.dart';
import '../api/repository.dart';

class GithubDrawIssueComments extends StatelessWidget {
  final Repository repository;
  final String repoId;
  final Issue issue;
  const GithubDrawIssueComments({
    super.key,
    required this.repository,
    required this.repoId,
    required this.issue,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
        title: Text(issue.title),
      ),
      body: FutureBuilder(
        future: Github(context, null).getIssueComments(repository.name, issue.number),
        builder: (builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          else {
            final data = snapshot.data!;
            final draw = data.map((issueComment) {
              final CrossAxisAlignment cAlign;
              if (issueComment.author != null && issueComment.author == data[0].author) {
                cAlign = CrossAxisAlignment.start;
              }
              else {
                cAlign = CrossAxisAlignment.end;
              }
              return Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: cAlign,
                    children: [
                      Text(issueComment.author ?? "Unknown"),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: width * 0.8),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            border: Border.all(color: Colors.grey, width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(issueComment.body),
                          ),
                        ),
                      )
                    ]
                  ),
                )
              );
            }).toList();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              scrollController.jumpTo(scrollController.position.maxScrollExtent);
            });
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: draw,
              ),
            );
          }
        }
      ),
    );
  }
}