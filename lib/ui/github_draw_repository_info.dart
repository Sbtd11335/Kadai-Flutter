import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/repository.dart';
import 'github_create_issue.dart';
import 'github_draw_issues.dart';
import 'navigation_card.dart';

class GithubDrawRepositoryInfo extends StatelessWidget {
  final Repository repository;
  const GithubDrawRepositoryInfo({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    final titleTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 32,
      fontWeight: FontWeight.w500
    );
    final subTitleTextStyle = TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 24,
        fontWeight: FontWeight.w500
    );
    const urlTextStyle = TextStyle(
        color: Colors.grey,
        fontSize: 16,
    );
    final descriptionTextStyle = TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
    );
    final urlTextButtonStyle = ButtonStyle(
      padding: WidgetStateProperty.all(const EdgeInsets.all(0))
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(repository.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(repository.name, style: titleTextStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
            TextButton(
              style: urlTextButtonStyle,
              onPressed: (){
                Clipboard.setData(ClipboardData(text: repository.url));
              },
              child: Text(repository.url, style: urlTextStyle, maxLines: 1, overflow: TextOverflow.ellipsis)
            ),
            Text("説明", style: subTitleTextStyle),
            const SizedBox(height: 10),
            Text(
              repository.description ?? "説明はありません。",
              style: descriptionTextStyle,
              maxLines: 5,
              overflow: TextOverflow.ellipsis
            ),
            const SizedBox(height: 10),
            Text("アクション", style: subTitleTextStyle),
            const SizedBox(height: 10),
            NavigationCard(
              label: Text("Issues", style: subTitleTextStyle),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (builder) => GithubCreateIssue(repoId: repository.id))
                    );
                  },
                  icon: const Icon(Icons.add)
                )
              ],
              child: GithubDrawIssues(repository: repository, items: 8),
            )
          ],
        )
      ),
    );
  }
}