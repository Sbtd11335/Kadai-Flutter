import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kadai/main.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("設定"),
      ),
      body: const SettingHook(),
    );
  }
}

class SettingHook extends ConsumerWidget {
  const SettingHook({super.key});

  final double _space = 10.0;

  void pasteToken(TextEditingController controller, BuildContext context, WidgetRef ref) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      controller.text = data.text!;
      ref.read(githubToken.notifier).state = controller.text;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController tokenController = TextEditingController();
    final TextStyle titleTextStyle = TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 24,
        fontWeight: FontWeight.w500
    );
    tokenController.text = ref.read(githubToken.notifier).state;

    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Githubトークン", style: titleTextStyle),
                TextButton(onPressed: () => pasteToken(tokenController, context, ref),
                    child: const Text("ペースト"))
              ],
            ),
            SizedBox(height: _space),
            TextField(
              controller: tokenController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: const InputDecoration(labelText: "トークン"),
              onChanged: (value) {
                ref.read(githubToken.notifier).state = tokenController.text;
              },
            ),
          ],
        )
    );
  }
}