import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MyApp());
}

class Todo {
  bool isDone;
  String title;

  Todo(this.title, {this.isDone = false});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '할 일 관리',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoListPage(),
    );
  }
}

// TodoListPage 클래스
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

// TodoListPage의 State 클래스
class _TodoListPageState extends State<TodoListPage> {
  final _todoController = TextEditingController();

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  // 할 일 객체를 ListTitle 형태로 변경하는 매서드
  Widget _buildItemWidget(DocumentSnapshot doc) {
    final todo = Todo(doc['title'], isDone: doc['isDone']);

    return ListTile(
      onTap: () => _toggleTodo(doc), // 완료/미완료
      title: Text(todo.title, // 할 일
          style: todo.isDone // 완료일 떄는 스타일 적용
              ? const TextStyle(
                  decoration: TextDecoration.lineThrough, // 취소선
                  fontStyle: FontStyle.italic, //이탤릭체
                )
              : null // 아무 스타일도 적용 안 함
          ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_forever),
        onPressed: () => _deleteTodo(doc), // 삭제
      ),
    );
  }

  // 할 일 추가 메서드
  void _addTodo(Todo todo) {
    FirebaseFirestore.instance
        .collection('todo')
        .add({'title': todo.title, 'isDone': todo.isDone});
    _todoController.text = ''; // 할 일 입력 필드를 비움
  }

  // 할 일 삭제 메서드
  void _deleteTodo(DocumentSnapshot doc) {
    if (doc.exists) {
      // DocumentSnapshot이 유효한지 확인합니다.
      FirebaseFirestore.instance
          .collection('todo')
          .doc(doc.id) // doc.id를 사용하여 DocumentReference를 만듭니다.
          .delete();
    }
  }

  // 할 일 완료/미완료 메서드
  void _toggleTodo(DocumentSnapshot doc) {
    FirebaseFirestore.instance.collection('todo').doc(doc.id).update({
      'isDone': !doc['isDone'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('남은 할 일'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _todoController,
                    ),
                  ),
                  ElevatedButton(
                    child: const Text('추가'),
                    onPressed: () => _addTodo(Todo(_todoController.text)),
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance.collection('todo').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final documents = snapshot.data!.docs;
                    return Expanded(
                      child: ListView(
                        children: documents
                            .map((doc) => _buildItemWidget(doc))
                            .toList(),
                      ),
                    );
                  })
            ],
          ),
        ));
  }
}
