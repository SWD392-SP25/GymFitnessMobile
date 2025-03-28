import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/core/network/dio_client.dart';
import 'package:gym_fitness_mobile/core/network/endpoints/chat_api_service.dart';
import 'package:dio/dio.dart'; // Add this import
import 'package:gym_fitness_mobile/core/network/endpoints/staff_api_service.dart'; // Add this import
import 'dart:convert'; // Để sử dụng json, utf8, base64Url
import 'package:shared_preferences/shared_preferences.dart'; // Để sử dụng SharedPreferences


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
  List<Staff> staffList = [];
  String? selectedStaffId;
  Map<String, List<Message>> staffMessages = {};

  final TextEditingController _controller = TextEditingController();
  final ChatApiService _chatApiService = ChatApiService(DioClient().dio);
  final StaffApiService _staffApiService = StaffApiService(DioClient());

  @override
  void initState() {
    super.initState();
    _fetchAllStaff();
  }

  Future<void> _fetchAllStaff() async {
    try {
      final fetchedStaffList = await _staffApiService.getAllStaff();
      
      setState(() {
        staffList = fetchedStaffList;
        selectedStaffId = staffList.isNotEmpty ? staffList[0].staffId : null;
        for (var staff in staffList) {
          staffMessages[staff.staffId] = [];
        }
        if (selectedStaffId != null) {
          _fetchChatHistory();
        }
      });
    } catch (e) {
      print('❌ Error fetching staff list: $e');
    }
  }

  Future<void> _fetchChatHistory() async {
    if (selectedStaffId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final token = prefs.getString('idToken');
      
      if (userId == null) {
        print('❌ No user ID found');
        return;
      }

      print('👤 User ID: $userId');

      final chatHistory = await _chatApiService.getChatHistory(
        userId,
        selectedStaffId!,
        token: token,
      );

      setState(() {
        staffMessages[selectedStaffId!] = chatHistory
            .map((message) => Message(
                  content: message['messageText'] ?? '', // Changed from 'message' to 'messageText'
                  sender: message['isUserMessage'] == true ? 'User' : 'PT', // Changed to use isUserMessage flag
                ))
            .toList();
      });
    } catch (e) {
      print('❌ Error fetching chat history: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty || selectedStaffId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final token = prefs.getString('idToken');
      
      if (userId == null) {
        print('❌ No user ID found');
        return;
      }

      final messageContent = _controller.text;

      await _chatApiService.sendMessage(
        senderId: userId,
        receiverId: selectedStaffId!,
        message: messageContent,
        messageType: 'text',
        token: token,
      );

      setState(() {
        staffMessages[selectedStaffId!]
            ?.add(Message(content: messageContent, sender: 'User'));
        _controller.clear();
      });
    } catch (e) {
      print('❌ Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedStaffId != null
              ? 'Chat with ${staffList.firstWhere((staff) => staff.staffId == selectedStaffId!).email}'
              : 'Chat',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF4A43EC),
        automaticallyImplyLeading: false,
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
                      selectedStaffId = staff.staffId;
                      _fetchChatHistory();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                              'https://images.pexels.com/photos/1229356/pexels-photo-1229356.jpeg'),
                        ),
                        SizedBox(height: 5),
                        Text(
                          staff.email, // Changed from lastName to email
                          style: TextStyle(
                            color: selectedStaffId == staff.staffId
                                ? Colors.blue
                                : Colors.black,
                            fontSize: 12, // Added to ensure text fits
                            overflow: TextOverflow.ellipsis, // Handle long emails
                          ),
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
                                'https://images.pexels.com/photos/1229356/pexels-photo-1229356.jpeg'),
                          ),
                          SizedBox(width: 10),
                          Text(
                            staffList
                                    .firstWhere((staff) =>
                                        staff.staffId == selectedStaffId!)
                                    .lastName ??
                                '',
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
