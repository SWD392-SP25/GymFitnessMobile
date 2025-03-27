import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/core/network/dio_client.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/chat_api_service.dart';
import 'package:dio/dio.dart'; // Add this import

class Message {
  final String content;
  final String sender;

  Message({required this.content, required this.sender});
}

class Staff {
  final String id;
  final String name;
  final String imageUrl;

  Staff({required this.id, required this.name, required this.imageUrl});

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['staffId'],
      name: json['email'], // Use email as the name
      imageUrl: json['imageUrl'] ??
          'https://via.placeholder.com/150', // Default image if null
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<String> staffIds = [
    "C946AC9B-6F8D-4452-B339-26ADCCF3F96A",
    "C8F1475F-D642-4827-8E1B-8453F22850EC",
    "9E0EFE3F-DAC8-4ABA-8661-CE61506B2DF2",
    "A8979074-1503-40C8-8122-F790A3E9EAE7"
  ];

  List<Staff> staffList = [];
  String? selectedStaffId;

  Map<String, List<Message>> staffMessages = {};

  final TextEditingController _controller = TextEditingController();
  final ChatApiService _chatApiService = ChatApiService(DioClient().dio);

  @override
  void initState() {
    super.initState();
    _fetchStaffDetails();
  }

  Future<void> _fetchStaffDetails() async {
    try {
      List<Staff> fetchedStaffList = [];
      for (String staffId in staffIds) {
        print("🔍 Fetching staff details for ID: $staffId");
        final response = await DioClient().dio.get(
              '/api/Staff/$staffId',
              queryParameters: null,
              options: Options(
                headers: {
                  'Authorization':
                      'Bearer YOUR_TOKEN_HERE', // Replace with actual token
                },
              ),
            );
        print("✅ Staff Data: ${response.data}");
        fetchedStaffList.add(Staff.fromJson(response.data));
      }

      setState(() {
        staffList = fetchedStaffList;
        selectedStaffId = staffList.isNotEmpty ? staffList[0].id : null;
        for (var staff in staffList) {
          staffMessages[staff.id] = [];
        }
        _fetchChatHistory();
      });
    } catch (e) {
      print('❌ Error fetching staff details: $e');
    }
  }

  Future<void> _fetchChatHistory() async {
    if (selectedStaffId == null) return;

    try {
      final token =
          'YOUR_TOKEN_HERE'; // Replace with actual token retrieval logic
      final userId = 'user-id-placeholder'; // Replace with actual user ID
      final chatHistory = await _chatApiService.getChatHistory(
        userId,
        selectedStaffId!,
        token: token, // Pass token
      );

      setState(() {
        staffMessages[selectedStaffId!] = chatHistory
            .map((message) => Message(
                  content: message['message'],
                  sender: message['senderId'] == userId ? 'User' : 'PT',
                ))
            .toList();
      });
    } catch (e) {
      print('Error fetching chat history: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty || selectedStaffId == null) return;

    try {
      final userId = 'user-id-placeholder'; // Replace with actual user ID
      final messageContent = _controller.text;

      await _chatApiService.sendMessage(
        senderId: userId,
        receiverId: selectedStaffId!,
        message: messageContent,
        messageType: 'text',
        token: token, // Pass token
      );

      setState(() {
        staffMessages[selectedStaffId!]
            ?.add(Message(content: messageContent, sender: 'User'));
        _controller.clear();
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

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
              itemCount: staffList.length,
              itemBuilder: (context, index) {
                final staff = staffList[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedStaffId = staff.id;
                      _fetchChatHistory();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(staff.imageUrl),
                        ),
                        SizedBox(height: 5),
                        Text(
                          staff.name,
                          style: TextStyle(
                              color: selectedStaffId == staff.id
                                  ? Colors.blue
                                  : Colors.black),
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
                  if (selectedStaffId != null)
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              staffList
                                  .firstWhere(
                                      (staff) => staff.id == selectedStaffId!)
                                  .imageUrl,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            staffList
                                .firstWhere(
                                    (staff) => staff.id == selectedStaffId!)
                                .name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: staffMessages[selectedStaffId]?.length ?? 0,
                      itemBuilder: (context, index) {
                        Message message =
                            staffMessages[selectedStaffId!]![index];
                        return Row(
                          mainAxisAlignment: message.sender == 'User'
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
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
                  onPressed: _sendMessage,
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
