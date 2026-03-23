import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/glass_card.dart';
import '../services/chatbot_service.dart';

class ChatbotScreen extends StatefulWidget {
  final String? productContext; // Context from scanned product

  const ChatbotScreen({super.key, this.productContext});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatbotService _chatbotService = ChatbotService();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();

    if (widget.productContext != null && widget.productContext!.isNotEmpty) {
      // Context-aware welcome message
      _messages.add(ChatMessage(
        text: "I've analyzed the product you just scanned. Ask me anything about its ingredients, health impact, or safer alternatives!",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } else {
      // Generic welcome message
      _messages.add(ChatMessage(
        text: "Hi! I'm your AI Health Assistant. Ask me anything about ingredients, nutrition, or health!",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> _sendMessage([String? presetMessage]) async {
    final userMessage = presetMessage ?? _messageController.text.trim();
    if (userMessage.isEmpty) return;

    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      // Prepend product context to the message for the API
      String fullMessage = userMessage;
      if (widget.productContext != null && widget.productContext!.isNotEmpty) {
        fullMessage =
            '[Context: The user just scanned a food product. ${widget.productContext}]\n\nUser question: $userMessage';
      }

      final response = await _chatbotService.sendMessage(fullMessage);
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Sorry, I'm having trouble connecting. Please try again.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasContext =
        widget.productContext != null && widget.productContext!.isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color(0xFF2979FF).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy, color: Color(0xFF2979FF), size: 20),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Health Assistant',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                Text(
                  hasContext ? 'Analyzing your product' : 'Online',
                  style: TextStyle(
                    fontSize: 11,
                    color: hasContext ? Color(0xFFFF9800) : Color(0xFF00E676),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF0D0D0D)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Suggestion Chips
              if (_messages.length <= 1)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: hasContext
                        ? [
                            _buildSuggestionChip("Is this safe to eat daily?"),
                            _buildSuggestionChip("What are the main concerns?"),
                            _buildSuggestionChip("Suggest healthier alternatives"),
                            _buildSuggestionChip("Side effects of these ingredients?"),
                          ]
                        : [
                            _buildSuggestionChip("What's aspartame?"),
                            _buildSuggestionChip("Is MSG harmful?"),
                            _buildSuggestionChip("Best natural sweeteners?"),
                          ],
                  ),
                ),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessage(_messages[index]);
                  },
                ),
              ),

              // Input Field
              Container(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: hasContext
                                    ? 'Ask about this product...'
                                    : 'Ask me anything...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _sendMessage(),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFF2979FF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.send, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xFF2979FF).withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFF2979FF).withOpacity(0.25)),
        ),
        child: Text(
          text,
          style: TextStyle(color: Color(0xFF2979FF), fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Color(0xFF2979FF).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy, size: 14, color: Color(0xFF2979FF)),
            ),
          if (!message.isUser) SizedBox(width: 8),
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Color(0xFF00E676).withOpacity(0.12)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: message.isUser
                          ? Color(0xFF00E676).withOpacity(0.2)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                        fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
          if (message.isUser) SizedBox(width: 8),
          if (message.isUser)
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Color(0xFF00E676).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 14, color: Color(0xFF00E676)),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color(0xFF2979FF).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.smart_toy, size: 14, color: Color(0xFF2979FF)),
          ),
          SizedBox(width: 8),
          _TypingDots(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Animated typing dots
class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final delay = i * 0.2;
              final bounce = (((_controller.value + delay) % 1.0) * 2 - 1).abs();
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 3),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2979FF).withOpacity(0.3 + bounce * 0.5),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
