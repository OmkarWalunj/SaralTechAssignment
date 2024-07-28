import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  final String _url = 'http://10.0.2.2:1337/graphql';

  ValueNotifier<GraphQLClient> getClient() {
    final HttpLink httpLink = HttpLink(_url);
    return ValueNotifier(
      GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(store: InMemoryStore()),
      ),
    );
  }
}
