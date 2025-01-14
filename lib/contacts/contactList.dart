import "package:flutter/material.dart";
import "package:graphql_flutter/graphql_flutter.dart";

import "profileInputDialog.dart";
import "user.dart";
import "graphQLConf.dart";
import "queryMutation.dart";

class ContactList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContactList();
}

class _ContactList extends State<ContactList> {
  List<User> listUser = [];
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();

  void fillList() async {
    QueryMutation queryMutation = QueryMutation();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.query(
      QueryOptions(
        document: queryMutation.getAll(),
      ),
    );
    if (!result.hasErrors) {
      for (var i = 0; i < result.data["users"].length; i++) {
        setState(() {
          listUser.add(
            User(
              result.data["users"][i]["id"],
              result.data["users"][i]["name"],
              result.data["users"][i]["lastName"],
              result.data["users"][i]["phone"],
            ),
          );
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fillList();
  }

  void _addUser(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        ProfileInputDialog profileInputDialog =
            new ProfileInputDialog(isAdd: true);
        return profileInputDialog;
      },
    ).whenComplete(() {
      listUser.clear();
      fillList();
    });
  }

  void _editDeleteUser(context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        ProfileInputDialog profileInputDialog =
            new ProfileInputDialog(isAdd: false, user: user);
        return profileInputDialog;
      },
    ).whenComplete(() {
      listUser.clear();
      fillList();
    });
  }

  @override
  Widget build(BuildContext context) {
    String readRepositories = """
  query ReadRepositories(\$nRepositories: Int!) {
    viewer {
      repositories(last: \$nRepositories) {
        nodes {
          id
          name
          viewerHasStarred
        }
      }
    }
  }
""";
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact List"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () => _addUser(context),
            tooltip: "Insert new user",
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 5.0),
            child: ListView.builder(
              itemCount: listUser.length,
              itemBuilder: (context, index) {
                User user = listUser[index];
                return ListTile(
                  selected: user == null ? false : true,
                  title: Text(
                    "${user.getName()}",
                  ),
                  onTap: () {
                    _editDeleteUser(context, user);
                  },
                );
              },
            ),
          ),
          Query(
            options: QueryOptions(
              document: gql(
                  readRepositories), // this is the query string you just created
              variables: {
                'nRepositories': 50,
              },
              pollInterval: const Duration(seconds: 10),
            ),
            // Just like in apollo refetch() could be used to manually trigger a refetch
            // while fetchMore() can be used for pagination purpose
            builder: (QueryResult result,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.hasException) {
                return Text(result.exception.toString());
              }

              if (result.isLoading) {
                return const Text('Loading');
              }

              List? repositories =
                  result.data?['viewer']?['repositories']?['nodes'];

              if (repositories == null) {
                return const Text('No repositories');
              }

              return ListView.builder(
                  itemCount: repositories.length,
                  itemBuilder: (context, index) {
                    final repository = repositories[index];

                    return Text(repository['name'] ?? '');
                  });
            },
          ),
        ],
      ),
    );
  }
}
