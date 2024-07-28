import 'dart:developer';
import 'package:assignment/screens/add_task.dart';
import 'package:flutter/material.dart';

import 'package:graphql_flutter/graphql_flutter.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final String getTasksQuery = """
    query {
      tasks {
        data {
          id
          attributes {
            title
            description
            complete
          }
        }
      }
    }
  """;

  final String updateTaskMutation = """
    mutation UpdateTask(\$id: ID!, \$complete: Boolean!) {
      updateTask(id: \$id, data: { complete: \$complete }) {
        data {
          id
          attributes {
            complete
          }
        }
      }
    }
  """;

  final String deleteTaskMutation = """
    mutation DeleteTask(\$id: ID!) {
      deleteTask(id: \$id) {
        data {
          id
        }
      }
    }
  """;

  List tasks = [];

  List containerColor = const [
    Color.fromRGBO(250, 232, 232, 1),
    Color.fromRGBO(232, 237, 250, 1),
    Color.fromRGBO(250, 249, 232, 1),
    Color.fromRGBO(250, 232, 250, 1),
  ];

  @override
  Widget build(BuildContext context) {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(2, 167, 177, 1),
        title: const Text(
          "To-do list",
          style:  TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _buildTaskList(client),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
         AddTaskScreenState obj= AddTaskScreenState();
         obj.showBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(GraphQLClient client) {
    return Query(
      options: QueryOptions(
        document: gql(getTasksQuery),
      ),
      builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (result.hasException) {
          return Center(child: Text(result.exception.toString()));
        }

        tasks = result.data!['tasks']['data'];
        log("${tasks[0]['attributes']['description']}");

        return RefreshIndicator(
          onRefresh: () => _fetchTasks(client,refetch: refetch),
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              var task = tasks[index];
              return Card(
                elevation: 8,
                color: containerColor[index % containerColor.length],
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20,top: 10),
                child: ListTile(
                  title: Text(task['attributes']['title'] ?? 'New Task'),
                  subtitle: Text(task['attributes']['description'] ?? 'Empty'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: task['attributes']['complete'] ?? false,
                        onChanged: (value) {
                          _updateTaskStatus(context, task['id'], value ?? false, refetch);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteTask(context, task['id'], refetch);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _fetchTasks(GraphQLClient client,{VoidCallback? refetch}) async {
    refetch?.call();
  }

  void _updateTaskStatus(BuildContext context, String taskId, bool isComplete, VoidCallback? refetch) {
    final MutationOptions options = MutationOptions(
      document: gql(updateTaskMutation),
      variables: {
        'id': taskId,
        'complete': isComplete,
      },
      onCompleted: (dynamic resultData) {
        print('Task updated successfully');
        refetch?.call(); // Refetch the task list after updating
      },
      onError: (error) {
        print('Error updating task: $error');
      },
    );

    GraphQLProvider.of(context).value.mutate(options);
  }

  void _deleteTask(BuildContext context, String taskId, VoidCallback? refetch) {
    final MutationOptions options = MutationOptions(
      document: gql(deleteTaskMutation),
      variables: {
        'id': taskId,
      },
      onCompleted: (dynamic resultData) {
        print('Task deleted successfully');
        refetch?.call(); // Refetch the task list after deletion
      },
      onError: (error) {
        print('Error deleting task: $error');
      },
    );

    GraphQLProvider.of(context).value.mutate(options);
  }
}
