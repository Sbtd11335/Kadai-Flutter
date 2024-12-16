import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kadai/api/issue_comment.dart';
import 'package:kadai/api/issue_label.dart';
import 'package:kadai/api/repository.dart';

import '../module/Color.dart';
import 'issue.dart';

class Github {
  late final GraphQLClient client;
  late final String token;

  Github(BuildContext context, String? token) {
    this.token = token ?? SharedAppData.getValue(context, "GithubToken", () => "");
    final link = HttpLink(
      "https://api.github.com/graphql",
      defaultHeaders: {
        "Authorization": "Bearer ${this.token}"
    });
    client = GraphQLClient(link: link, cache: GraphQLCache());
  }

  Future<List<Repository>> getRepositories() async {
    List<Repository> repositories = [];
    const query = """
    query GithubRepositories(\$first: Int!, \$after: String) {
      viewer {
        repositories(first: \$first, after: \$after) {
          nodes {
            name
            url
            description
            id
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    }
  """;
    String? after = null;
    while(true) {
      QueryOptions queryOptions = QueryOptions(
          document: gql(query),
          variables: {
            "first": 100,
            "after": after
          }
      );
      final result = await client.query(queryOptions);
      if (result.data != null) {
        final data = result.data!;
        for(var repo in data["viewer"]["repositories"]["nodes"]) {
          final String name = repo["name"];
          final String url = repo["url"];
          final String? description = repo["description"];
          final String id = repo["id"];
          final repository = Repository(name, url, description, id);
          repositories.add(repository);
        }
        if (data["viewer"]["repositories"]["pageInfo"]["hasNextPage"]) {
          after = data["viewer"]["repositories"]["pageInfo"]["endCursor"];
        }
        else {
          break;
        }
      }
      else {
        break;
      }
    }
    return repositories.reversed.toList();
  }
  Future<Set<Object>> getIssues(String repositoryName) async {
    const query = """
      query GithubIssues(\$repository: String!, \$first: Int!, \$after: String) {
        viewer {
          repository(name: \$repository) {
            id
            issues(first: \$first, after: \$after) {
              nodes {
                number
                title
                closed
                labels(first: 100) {
                  nodes {
                    name
                    color
                  }
                }
                author {
                  login
                }
              }
              pageInfo {
                hasNextPage
                endCursor
              }
            }
          }
        }
      }
    """;
    List<Issue> ret = [];
    String? after;
    String? repoId;
    while(true) {
      final queryOptions = QueryOptions(
        document: gql(query),
        variables: {
          "repository": repositoryName,
          "first": 100,
          "after": after
        }
      );
      final result = await client.query(queryOptions);
      if (result.data != null) {
        final data = result.data!;
        final repo = data["viewer"]["repository"]!;
        repoId = data["viewer"]["repository"]["id"]!;
        final bool hasNextPage = data["viewer"]["repository"]["issues"]["pageInfo"]["hasNextPage"];
        final String? endCursor = data["viewer"]["repository"]["issues"]["pageInfo"]["endCursor"];
        for (var node in data["viewer"]["repository"]["issues"]["nodes"]) {
          final issueLabels = <IssueLabel>[];
          final int number = node["number"];
          final String title = node["title"];
          final bool closed = node["closed"];
          final String? author = node["author"]["login"];
          for (var labelNode in node["labels"]["nodes"]) {
            final String labelName = labelNode["name"];
            final Color labelColor = colorFromHex(labelNode["color"]);
            issueLabels.add(IssueLabel(labelName, labelColor));
          }
          ret.add(Issue(number, title, closed, issueLabels, author));
        }
        if (!hasNextPage) {
          break;
        }
        else {
          after = endCursor;
        }
      }
      else {
        break;
      }
    }
    return {repoId ?? "", ret.reversed.toList()};
  }
  Future<List<IssueComment>> getIssueComments(String repositoryName, int number) async {
    const String query = """
    query GithubIssueComments(\$repository: String!, \$number: Int!, \$after: String) {
      viewer {
        repository(name: \$repository) {
          name
          issue(number: \$number) {
            title
            body
            author {
              login
            }
            comments(first: 100, after: \$after) {
              nodes {
                body
                author {
                  login
                }
              }
            pageInfo {
                hasNextPage
                endCursor
              }
            }
          }
        }
      }
    }
    """;
    final ret = <IssueComment>[];
    IssueComment? mainComment;
    String? after;
    while(true) {
      final queryOptions = QueryOptions(
        document: gql(query),
        variables: {
          "repository": repositoryName,
          "number": number,
          "after": after
        }
      );
      final result = await client.query(queryOptions);
      if (result.data != null) {
        final data = result.data!["viewer"]["repository"]["issue"];
        final mainAuthor = data["author"]["login"];
        final mainBody = data["body"];
        mainComment = IssueComment(mainAuthor, mainBody);
        for(var node in data["comments"]["nodes"]) {
          final author = node["author"]["login"];
          final body = node["body"];
          ret.add(IssueComment(author, body));
        }
        if (data["comments"]["pageInfo"]["hasNextPage"]) {
          after = data["comments"]["pageInfo"]["endCursor"];
        }
        else {
          break;
        }
      }
      else {
        break;
      }
    }
    if (mainComment != null) {
      ret.insert(0, mainComment);
    }
    return ret;
  }
  Future<void> createIssue(String repoId, String title, String body) async {
    const query = """
    mutation CreateIssue(\$input: CreateIssueInput!) {
      createIssue(input: \$input) {
        clientMutationId
      }
    }
    """;
    final mutationOptions = MutationOptions(
      document: gql(query),
      variables: {
        "input": {
          "repositoryId": repoId,
          "title": title,
          "body": body
        }
    });
    await client.mutate(mutationOptions);
  }
}