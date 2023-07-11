import 'package:graphql_flutter/graphql_flutter.dart';
import "package:gql/ast.dart";

class QueryMutation {
  DocumentNode createUser(String name, String lastName, int phone) {
    return gql("""
      mutation{
          createUser(
            data: {
              name: "$name", lastName: "$lastName", phone: $phone
            }
          ) {
            id
            lastName
          }
      }
    """);
  }

  DocumentNode getAll() {
    return gql(""" 
      {
        users{
          id
          name
          lastName
          phone
        }
      }
    """);
  }

  DocumentNode deleteUser(id) {
    return gql("""
      mutation{
        deleteUser( where: {
          id: "$id"
        }) {
          id
          lastName
        }
      } 
    """);
  }

  DocumentNode updateUser(String id, String name, String lastName, int phone) {
    return gql("""
      mutation{
          updateUser(
            data: {
              name: "$name", lastName: "$lastName", phone: $phone
            }
            where: {
              id: "$id"
            }
          ) {
            id
            lastName
          }
      }    
     """);
  }
}
