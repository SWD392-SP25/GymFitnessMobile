import 'package:flutter/material.dart';

class Message {
  final String content;
  final String sender;

  Message({required this.content, required this.sender});
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<String> ptNames = ['Tên PT 1', 'Tên PT 2', 'Tên PT 3', 'Tên PT 4', 'Tên PT 5', 'Tên PT 6', 'Tên PT 7', 'Tên PT 8'];
  String selectedPT = 'Tên PT 1';

  Map<String, List<Message>> ptMessages = {
    'Tên PT 1': [
      Message(content: 'Hi, how can I help you?', sender: 'PT'),
      Message(content: 'Let’s get started with your training!', sender: 'PT'),
    ],
    'Tên PT 2': [
      Message(content: 'Hello! Ready for your session?', sender: 'PT'),
      Message(content: 'Let me know what your goals are.', sender: 'PT'),
    ],
    'Tên PT 3': [
      Message(content: 'Hey! Time to train!', sender: 'PT'),
      Message(content: 'Are you ready for today’s workout?', sender: 'PT'),
    ],
    'Tên PT 4': [],
    'Tên PT 5': [],
    'Tên PT 6': [],
    'Tên PT 7': [],
    'Tên PT 8': [],
  };

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with PT', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4A43EC),
        automaticallyImplyLeading: false, // Remove back arrow
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: const Offset(0, 2)),
              ],
            ),
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ptNames.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPT = ptNames[index];
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage('https://images.pexels.com/photos/1229356/pexels-photo-1229356.jpeg'),
                        ),
                        SizedBox(height: 5),
                        Text(
                          ptNames[index],
                          style: TextStyle(color: selectedPT == ptNames[index] ? Colors.blue : Colors.black),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage('https://images.pexels.com/photos/1229356/pexels-photo-1229356.jpeg'),
                        ),
                        SizedBox(height: 5),
                        Text(
                          selectedPT,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: ptMessages[selectedPT]?.length ?? 0,
                      itemBuilder: (context, index) {
                        Message message = ptMessages[selectedPT]![index];
                        return Row(
                          mainAxisAlignment: message.sender == 'User'
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                color: message.sender == 'User'
                                    ? Colors.blue.shade100
                                    : Colors.blue.shade200,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                message.content,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      if (_controller.text.isNotEmpty) {
                        ptMessages[selectedPT]?.add(Message(content: _controller.text, sender: 'User'));
                        _controller.clear();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatbotPage extends StatelessWidget {
  const ChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Center(
        child: Text(
          'Chatbot', // Text in the center
          style: TextStyle(
            fontSize: 24, // Set font size
            fontWeight: FontWeight.bold, // Make the text bold
            color: Colors.black, // Set text color to black
          ),
        ),
      ),
    );
  }
}
