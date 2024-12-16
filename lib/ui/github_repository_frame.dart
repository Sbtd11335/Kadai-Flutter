import 'package:flutter/material.dart';

import '../api/repository.dart';
import 'github_draw_repository_info.dart';

class GithubRepositoryFrame extends StatelessWidget {
  final Repository repository;

  const GithubRepositoryFrame({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    TextStyle nameTextStyle = TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface
    );
    TextStyle urlTextStyle = const TextStyle(
        fontSize: 17,
        color: Colors.grey
    );
    TextStyle descriptionTextStyle = TextStyle(
        fontSize: 17,
        color: Theme.of(context).colorScheme.onSurface
    );

    final buttonStyle = ButtonStyle(
      textStyle: WidgetStatePropertyAll(TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      foregroundColor: const WidgetStatePropertyAll(Colors.transparent),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15)))),
      padding: const WidgetStatePropertyAll(EdgeInsets.all(10)),
    );

    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.grey),
            borderRadius: const BorderRadius.all(Radius.circular(15))
          ),
          child: SizedBox(
            width: width - 20,
            height: 200,
            child: ElevatedButton(
              style: buttonStyle,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GithubDrawRepositoryInfo(repository: repository)
                  )
                );
              },
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      repository.name,
                      style: nameTextStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(repository.url, style: urlTextStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),
                    Text(
                      repository.description ?? "説明はありません。",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: descriptionTextStyle,
                    )
                  ],
                )
              )
            )
          )
        ),
        const SizedBox(height: 10)
      ]
    );
  }
}
