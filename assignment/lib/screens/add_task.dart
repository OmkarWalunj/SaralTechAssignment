import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';


class AddTaskScreenState  {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';

  final String createTaskMutation = """
    mutation CreateTask(\$title: String!, \$description: String) {
      createTask(data: { title: \$title, description: \$description }) {
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

    void showBottomSheet(BuildContext context) {

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),

        // isDismissible: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Form(
                  key: _formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const SizedBox(
                          height: 20,
                        ),
                    const Text(
                      "Create Task",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(0, 0, 0, 1)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        const Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Title",
                              style: TextStyle(
                                color: Color.fromRGBO(0, 139, 148, 1),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding:const EdgeInsets.all(8.0),
                          child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  onSaved: (value) {
                    _title = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                                ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // ignore: prefer_const_constructors
                        Row(
                          children: const [
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Description",
                              style: TextStyle(
                                color: Color.fromRGBO(0, 139, 148, 1),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  onSaved: (value) {
                    _description = value ?? '';
                  },
                                ),
                        ),
                       
                     Mutation(
                  options: MutationOptions(
                    document: gql(createTaskMutation),
                    onCompleted: (dynamic resultData) async {
                      if (resultData != null) {
                        // Optionally handle the result here if needed
                        print('Task added successfully');
                      }
                  
                      // Wait for the mutation to complete and then fetch tasks
                                
                      
                      Navigator.pop(context,true);
                    },
                  ),
                  builder: (RunMutation runMutation, QueryResult? result) {
                    return Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();
                            runMutation({
                              'title': _title,
                              'description': _description,
                            });
                          }
                        },
                        child: const Text('Add Task'),
                      ),
                    );
                  },
                                ),
                  ])
                          ]),
                )
                )
                );
        });
  }

}
