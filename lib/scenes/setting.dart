import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("設定"),
      ),
      body: const SettingState(),
    );
  }
}

class SettingState extends StatefulWidget {
  const SettingState({super.key});

  @override
  State<StatefulWidget> createState() => _SettingState();
}

class _SettingState extends State<SettingState> {
  final double _space = 10.0;

  void pasteToken(TextEditingController controller, BuildContext context) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      controller.text = data.text!;
      SharedAppData.setValue(context, "GithubToken", data.text!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController tokenController = TextEditingController();
    final TextStyle titleTextStyle = TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 24,
        fontWeight: FontWeight.w500
    );
    tokenController.text = SharedAppData.getValue(context, "GithubToken", () => "");

    return Padding(
      padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Githubトークン", style: titleTextStyle),
                TextButton(onPressed: () => pasteToken(tokenController, context),
                    child: const Text("ペースト"))
              ],
            ),
            SizedBox(height: _space),
            TextField(
              controller: tokenController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: const InputDecoration(labelText: "トークン"),
              onChanged: (value) {
                SharedAppData.setValue(context, "GithubToken", value);
              },
            ),
          ],
        )
      );
  }
}