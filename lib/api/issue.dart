import 'package:kadai/api/issue_label.dart';

class Issue {
  final int number;
  final String title;
  final bool closed;
  final List<IssueLabel> issueLabels;
  final String? author;

  Issue(this.number, this.title, this.closed, this.issueLabels, this.author);
}