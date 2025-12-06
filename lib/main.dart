import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

// --- API KEY ---
const String kGeminiKey = 'AIzaSyDN3P4sBZS7LJO4vwd2sMrgSPpYNQfSNnk';

// --- THEME CONSTANTS ---
const Color kObsidian = Color(0xFF121212);
const Color kCharcoal = Color(0xFF1E1E1E);
const Color kPlatinum = Color(0xFFF5F5F5);
const Color kGold = Color(0xFFC5A059);
const Color kTextPrimary = Color(0xFF121212);
const Color kTextSecondary = Color(0xFF757575);

void main() {
  Gemini.init(apiKey: kGeminiKey);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const CAbleApp());
}

class CAbleApp extends StatelessWidget {
  const CAbleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'C-ABLE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: kObsidian,
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.light(
          primary: kObsidian,
          secondary: kGold,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: kObsidian),
          titleTextStyle: TextStyle(
            color: kObsidian,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kObsidian,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kPlatinum,
          contentPadding: const EdgeInsets.all(20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: kObsidian, width: 1),
          ),
          labelStyle: const TextStyle(color: kTextSecondary),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/linkedin': (context) => const LinkedInInputScreen(),
        '/events': (context) => const EventListScreen(),
        '/event_detail': (context) => const EventDetailScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/live_map': (context) => const LiveMapScreen(),
      },
    );
  }
}

// ==========================================
// 1. SPLASH SCREEN
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/linkedin');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 180,
              child: Image.asset(
                'assets/avatars/splash.gif',
                fit: BoxFit.contain,
                errorBuilder: (c, o, s) => const Icon(Icons.hub, color: kObsidian, size: 80),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "C - A B L E",
              style: TextStyle(
                color: kObsidian,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 8.0,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "CURATING CONNECTIONS",
              style: TextStyle(
                color: kTextSecondary,
                fontSize: 10,
                letterSpacing: 3.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. LINKEDIN INPUT SCREEN
// ==========================================
class LinkedInInputScreen extends StatefulWidget {
  const LinkedInInputScreen({Key? key}) : super(key: key);

  @override
  State<LinkedInInputScreen> createState() => _LinkedInInputScreenState();
}

class _LinkedInInputScreenState extends State<LinkedInInputScreen> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  List<String> tags = [];

  final String mockProfileText = """
Wei Song Lee
15x Hackathon Wins | Founder @ ABLEs Sdn. Bhd. | R&D Software Engineering Intern & Part-Time @ ViTrox
Universiti Tunku Abdul Rahman (UTAR)
... (Truncated for brevity, logic remains the same) ...
AI Software Development, Artificial Intelligence (AI) and +3 skills
""";

  void _analyzeProfile() async {
    setState(() {
      isLoading = true;
      tags = [];
    });

    final gemini = Gemini.instance;
    try {
      final response = await gemini.prompt(parts: [
        Part.text("Analyze this LinkedIn profile text. Identify 5 UNIQUE, DISTINCTIVE, and HIGH-IMPACT keywords or short phrases that define this specific person's niche (e.g., 'Blind Assist AI', 'R&D Specialist'). Avoid generic terms like 'Student' or 'Developer'. Return ONLY the comma-separated list, nothing else.\n\n$mockProfileText")
      ]);

      final result = response?.output;

      if (result != null) {
        List<String> parsedTags = result.split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        setState(() {
          tags = parsedTags;
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Identity",
                style: TextStyle(
                  color: kTextSecondary,
                  fontSize: 12,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Define your\nPresence.",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                  color: kObsidian,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 60),
              TextField(
                controller: _controller,
                style: const TextStyle(color: kObsidian, letterSpacing: 0.5),
                decoration: InputDecoration(
                  labelText: "LinkedIn URL",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: FaIcon(FontAwesomeIcons.linkedin, color: const Color(0xFF0077B5), size: 20),
                  ),
                ),
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  "UNIQUE SIGNATURE",
                  style: TextStyle(color: kGold, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: kGold.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: kGold.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                        ],
                      ),
                      child: Text(
                        tag.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: kObsidian,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _analyzeProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tags.isEmpty ? kObsidian : Colors.white,
                    foregroundColor: tags.isEmpty ? Colors.white : kObsidian,
                    side: tags.isEmpty ? BorderSide.none : const BorderSide(color: kObsidian),
                  ),
                  child: isLoading
                      ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: kGold, strokeWidth: 2))
                      : Text(tags.isEmpty ? "ANALYZE PROFILE" : "RE-ANALYZE"),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: tags.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () => Navigator.pushReplacementNamed(
            context,
            '/events',
            arguments: tags
        ),
        backgroundColor: kObsidian,
        foregroundColor: kGold,
        icon: const Icon(Icons.arrow_forward),
        label: const Text("CONFIRM IDENTITY"),
      )
          : null,
    );
  }
}

// ==========================================
// 3. EVENT LIST SCREEN
// ==========================================
// ==========================================
// 3. EVENT LIST SCREEN (Updated with Marker Thumbnails)
// ==========================================
class EventListScreen extends StatelessWidget {
  const EventListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AGENDA")),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          _buildSectionHeader("LIVE NOW"),
          const SizedBox(height: 24),
          // Event 1: Cursor Hackathon (Uses marker 1)
          _buildEventCard(
            context,
            "Cursor x Anthropic Hackathon Malaysia",
            "Monash University Malaysia",
            "assets/markers/1.png", // <--- MARKER IMAGE
            true,
          ),

          const SizedBox(height: 32),
          _buildSectionHeader("NEARBY EXHIBITIONS"),
          const SizedBox(height: 24),

          // Event 2: Sunway Expo (Uses marker 2)
          _buildEventCard(
            context,
            "Sunway Smart City Expo",
            "Sunway Pyramid Convention Centre",
            "assets/markers/2.jpg", // <--- MARKER IMAGE
            false,
          ),

          const SizedBox(height: 24),

          // Event 3: Deep Tech (Uses marker 3)
          _buildEventCard(
            context,
            "Deep Tech Future Conf",
            "Asia Pacific University (APU)",
            "assets/markers/2.jpg", // <--- MARKER IMAGE
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        color: kTextSecondary,
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, String title, String loc, String imagePath, bool isFeatured) {
    final List<String> myTags = ModalRoute.of(context)?.settings.arguments as List<String>? ?? [];
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
            context,
            '/event_detail',
            arguments: {
              'eventName': title,
              'tags': myTags
            }
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: kPlatinum),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- THUMBNAIL AREA ---
            SizedBox(
              height: isFeatured ? 180 : 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Try to load the Marker Image
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // 2. Fallback if image missing: Dark background with Icon
                      return Container(
                        color: kCharcoal,
                        child: Center(
                          child: Icon(
                            Icons.qr_code_2, // Changed to QR icon to imply marker
                            size: 40,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      );
                    },
                  ),
                  // 3. Optional Gradient Overlay for text readability (if you add text over image)
                  if (isFeatured)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // --- TEXT CONTENT ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: kObsidian,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: kGold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                loc,
                                style: const TextStyle(
                                  color: kTextSecondary,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.arrow_forward, color: kObsidian, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. EVENT DETAIL SCREEN
// ==========================================
class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final String title = args['eventName'];
    final List<String> tags = args['tags'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: kObsidian),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(color: kPlatinum),
          ),
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.4,
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "EXCLUSIVE EVENT",
                    style: TextStyle(color: kGold, letterSpacing: 2.0, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: kObsidian),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Build with the best way to code with AI. Build with Cursor.",
                    style: TextStyle(fontSize: 16, height: 1.6, color: kTextSecondary),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context,
                            '/chatbot',
                            arguments: {
                              'eventName': title,
                              'tags': tags
                            }
                        );
                      },
                      child: const Text("CHECK-IN"),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 5. CHATBOT SCREEN
// ==========================================
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];
  List<Content> history = [];

  bool isTyping = false;
  bool isReadyToConnect = false;
  bool hasStarted = false;

  List<String> userTags = [];
  String eventName = "Tech Event";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!hasStarted) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        eventName = args['eventName'] ?? "Tech Event";
        userTags = (args['tags'] as List<dynamic>?)?.cast<String>() ?? [];
      } else if (args is String) {
        eventName = args;
      }
      _startConversation();
      hasStarted = true;
    }
  }

  void _startConversation() {
    String tagsString = userTags.isNotEmpty ? userTags.join(", ") : "Unknown";
    final String systemPrompt = """
You are C-ABLE, a chill, socially savvy wingman at '$eventName'.
CONTEXT INJECTION:
- User's Background (Tags): $tagsString.
- Event: $eventName.
STRICT INSTRUCTION: Do not explicitly mention the tags. Use them to infer interests. Focus 100% on the EVENT.
YOUR ROLE: Friendly, relaxed, supportive. Help the guest figure out what they want (team, jobs, networking).
STYLE: Short replies (1-2 sentences). No lists. Casual.
FINAL ACTION: End with "READY_TO_CONNECT" when you understand their goal.
Start now.
""";
    _sendMessage(systemPrompt, isUser: true, isHidden: true);
  }

  void _sendMessage(String text, {bool isUser = true, bool isHidden = false}) {
    if (!isHidden) {
      setState(() {
        messages.add(ChatMessage(text: text, isUser: isUser));
        isTyping = !isUser;
      });
      _scrollToBottom();
    }
    history.add(Content(
      role: isUser ? 'user' : 'model',
      parts: [Part.text(text)],
    ));

    if (isUser) {
      setState(() => isTyping = true);
      gemini.chat(history, modelName: "gemini-flash-lite-latest").then((value) {
        String? response = value?.output;
        if (response != null) {
          if (response.contains("READY_TO_CONNECT")) {
            setState(() => isReadyToConnect = true);
            response = response.replaceAll("READY_TO_CONNECT", "");
          }
          _sendMessage(response, isUser: false);
        }
      }).catchError((e) {
        setState(() => isTyping = false);
      });
    } else {
      setState(() => isTyping = false);
    }
  }

  void _handleUserSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _sendMessage(text, isUser: true);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CONCIERGE")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return const Padding(
                    padding: EdgeInsets.only(left: 0, bottom: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("C-ABLE is typing...", style: TextStyle(color: kTextSecondary, fontSize: 12)),
                    ),
                  );
                }
                final msg = messages[index];
                return ChatNode(text: msg.text, isBot: !msg.isUser);
              },
            ),
          ),
          if (isReadyToConnect)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: kPlatinum)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context,
                          '/live_map',
                          arguments: {'tags': userTags}
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner_outlined, size: 20),
                    label: const Text("ACTIVATE AR & CONNECT"),
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _handleUserSubmit(),
                          decoration: InputDecoration(
                            hintText: "Type your reply...",
                            hintStyle: const TextStyle(color: kTextSecondary),
                            fillColor: kPlatinum,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: kObsidian,
                        onPressed: _handleUserSubmit,
                        child: const Icon(Icons.arrow_upward, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatNode extends StatelessWidget {
  final String text;
  final bool isBot;
  const ChatNode({Key? key, required this.text, required this.isBot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isBot ? kPlatinum : kObsidian,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(4),
            topRight: const Radius.circular(4),
            bottomLeft: isBot ? const Radius.circular(0) : const Radius.circular(4),
            bottomRight: isBot ? const Radius.circular(4) : const Radius.circular(0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isBot ? kObsidian : Colors.white,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 6. LIVE MAP SCREEN (Social AR + Real Unity Data)
// ==========================================
class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({Key? key}) : super(key: key);

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  // REAL SERVER URL
  final String serverUrl = 'ws://10.150.107.168:8080';
  late IOWebSocketChannel channel;

  UnityWidgetController? _unityWidgetController;

  // State
  Map<String, MapUser> otherUsers = {};
  Offset myPosition = Offset.zero;
  String myStatus = 'open'; // 'open', 'busy', 'team'
  List<String> myTags = [];

  // Assets
  List<ui.Image> profileImages = [];
  bool isImagesLoaded = false;
  final String myDeviceId = "user_${Random().nextInt(9999)}"; // Random Session ID

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['tags'] != null) {
      myTags = (args['tags'] as List).cast<String>();
    } else {
      myTags = ['AI', 'Java', 'Founder'];
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfileImages();
    _connectToServer();
    _generateGhostUsers(); // Initial population for UX (Real data will overwrite/add)
  }

  void _generateGhostUsers() {
    setState(() {
      otherUsers['ghost_1'] = MapUser(
        id: '789-890',
        position: const Offset(1.5, 1.5),
        imageId: 1,
        tags: ['Marketing', 'Sales'],
        status: 'busy',
      );
      otherUsers['ghost_2'] = MapUser(
        id: '123-456',
        position: const Offset(-1.2, 0.5),
        imageId: 4,
        tags: ['IoT', 'Full-Stack'],
        status: 'open',
      );
    });
  }

  Future<void> _loadProfileImages() async {
    try {
      for (int i = 1; i <= 4; i++) {
        final ByteData data = await rootBundle.load('assets/avatars/$i.png');
        final Uint8List bytes = data.buffer.asUint8List();
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo fi = await codec.getNextFrame();
        profileImages.add(fi.image);
      }
      setState(() => isImagesLoaded = true);
    } catch (e) {
      print("Error loading images: $e");
    }
  }

  void _connectToServer() {
    try {
      channel = IOWebSocketChannel.connect(serverUrl);
      channel.stream.listen((message) {
        final data = jsonDecode(message);

        // Filter out my own messages if echo occurs
        if (data['id'] == myDeviceId) return;

        if (mounted) {
          setState(() {
            otherUsers[data['id']] = MapUser(
              id: data['id'] ?? 'unknown',
              position: Offset(
                  (data['x'] ?? 0).toDouble(),
                  (data['y'] ?? 0).toDouble()
              ),
              // Use provided metadata or fallback to random/defaults
              imageId: data['imageId'] ?? 1,
              tags: (data['tags'] as List<dynamic>?)?.cast<String>() ?? [],
              status: data['status'] ?? 'open',
            );
          });
        }
      });
    } catch (e) {
      print("WS Error: $e");
    }
  }

  // --- UNITY HANDLERS ---
  void onUnityCreated(controller) {
    _unityWidgetController = controller;
  }

  void onUnityMessage(message) {
    if (message != null) {
      try {
        var data = jsonDecode(message.toString());
        // Unity sends X and Y (where Y is Z in 3D world space)
        double uX = data['x'].toDouble();
        double uY = data['y'].toDouble();

        // 1. Update My Local Position (UI)
        setState(() {
          myPosition = Offset(uX, uY);
        });

        // 2. Broadcast My RICH Data to Server (so others see my tags)
        final fullPayload = {
          'id': myDeviceId,
          'x': uX,
          'y': uY,
          'imageId': 0, // Me (mapped to avatar 1)
          'tags': myTags,
          'status': myStatus
        };
        channel.sink.add(jsonEncode(fullPayload));
      } catch (e) {
        print("Error parsing Unity message: $e");
      }
    }
  }

  // --- TAP INTERACTION LOGIC ---
  void _handleMapTap(TapUpDetails details, Size mapSize) {
    final center = Offset(mapSize.width / 2, mapSize.height / 2);
    final double scale = 40.0;

    otherUsers.forEach((id, user) {
      double userScreenX = center.dx + (user.position.dx * scale);
      double userScreenY = center.dy - (user.position.dy * scale);
      double distance = (Offset(userScreenX, userScreenY) - details.localPosition).distance;

      if (distance < 40) {
        _showProfileModal(user);
      }
    });
  }

  void _showProfileModal(MapUser user) {
    int matchCount = user.tags.where((t) => myTags.contains(t)).length;
    bool isHighMatch = matchCount >= (user.tags.length / 2);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: isImagesLoaded ?
                  Image.asset('assets/avatars/${user.imageId}.png').image : null,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Social Icons Row
                    Row(
                      children: [
                        Text(
                            "Guest #${user.id.substring(0, min(4, user.id.length))}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                        ),
                        const SizedBox(width: 12),

                        // --- SOCIAL ICONS ---
                        GestureDetector(
                          onTap: () => print("Open LinkedIn"),
                          child: const FaIcon(FontAwesomeIcons.linkedin, size: 18, color: Color(0xFF0077B5)),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => print("Open Instagram"),
                          child: const FaIcon(FontAwesomeIcons.instagram, size: 18, color: Color(0xFFE1306C)),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => print("Open Facebook"),
                          child: const FaIcon(FontAwesomeIcons.facebook, size: 18, color: Color(0xFF1877F2)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(user.status.toUpperCase(), style: const TextStyle(color: kTextSecondary, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                if (isHighMatch)
                  const Icon(Icons.star, color: kGold, size: 30)
              ],
            ),
            const SizedBox(height: 20),
            const Text("VIBES / TAGS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kTextSecondary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: user.tags.map((t) => Chip(
                label: Text(t),
                backgroundColor: myTags.contains(t) ? kGold.withOpacity(0.2) : kPlatinum,
                labelStyle: TextStyle(color: myTags.contains(t) ? kObsidian : kTextSecondary, fontSize: 12),
              )).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connection Request Sent!")));
                },
                child: const Text("CONNECT"),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.9),
          title: const Text("EVENT HUB"),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: kObsidian,
            labelColor: kObsidian,
            unselectedLabelColor: kTextSecondary,
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            tabs: [
              Tab(text: "LIVE MESH"),
              Tab(text: "STORIES"),
            ],
          ),
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // TAB 1: AR + LIVE MESH
            Stack(
              children: [
                // 1. AR LAYER (Back)
                UnityWidget(
                  onUnityCreated: onUnityCreated,
                  onUnityMessage: onUnityMessage,
                ),

                // 2. UI OVERLAY (Front)
                Positioned.fill(
                  child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          onTapUp: (details) => _handleMapTap(details, constraints.biggest),
                          child: Container(
                            // Transparent background to show AR
                            color: Colors.white.withOpacity(0.05),
                            child: isImagesLoaded
                                ? CustomPaint(
                              painter: MapPainter(otherUsers, myPosition, profileImages, myTags, myStatus),
                            )
                                : const Center(child: CircularProgressIndicator(color: kObsidian)),
                          ),
                        );
                      }
                  ),
                ),

                // 3. STATUS SELECTOR
                Positioned(
                  bottom: 40,
                  left: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildStatusDot('open', Colors.green),
                        const SizedBox(width: 12),
                        _buildStatusDot('busy', Colors.red),
                        const SizedBox(width: 12),
                        _buildStatusDot('team', Colors.blue),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 45,
                  left: 140,
                  child: Text(
                    "STATUS: ${myStatus.toUpperCase()}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                  ),
                )
              ],
            ),

            // TAB 2: STORIES
            const StoriesTabScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDot(String status, Color color) {
    bool isSelected = myStatus == status;
    return GestureDetector(
      onTap: () => setState(() => myStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 24 : 16,
        height: isSelected ? 24 : 16,
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isSelected ? Border.all(color: kObsidian, width: 2) : null,
            boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)] : null
        ),
      ),
    );
  }
}

// ==========================================
// MAP PAINTER
// ==========================================
class MapPainter extends CustomPainter {
  final Map<String, MapUser> users;
  final Offset myPos;
  final List<ui.Image> images;
  final List<String> myTags;
  final String myStatus;

  MapPainter(this.users, this.myPos, this.images, this.myTags, this.myStatus);

  Color getStatusColor(String status) {
    switch(status) {
      case 'busy': return Colors.redAccent;
      case 'team': return Colors.blueAccent;
      case 'open':
      default: return Colors.greenAccent;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Draw Marker Center
    canvas.drawRect(Rect.fromCenter(center: center, width: 10, height: 10), Paint()..color = kObsidian);

    double scale = 40.0;

    // CHANGED: Added 'id' parameter at the end
    void drawAvatar(Offset pos, ui.Image? img, String status, List<String> userTags, bool isMe, {String? id}) {
      double avatarSize = 50.0;
      double radius = avatarSize / 2;

      // --- 1. GLOW LOGIC (Only for Ghost 2) ---
      // Check if this specific user is 'ghost_2'
      if (id == '123-456') {
        double glowRadius = radius * 3.5;

        final glowPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              kGold.withOpacity(0.8), // Strong Gold
              kGold.withOpacity(0.4),
              kGold.withOpacity(0.0)
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(center: pos, radius: glowRadius));

        // Soft Aura
        canvas.drawCircle(pos, glowRadius, glowPaint);

        // Sharp Ring
        canvas.drawCircle(pos, radius + 6, Paint()
          ..style = PaintingStyle.stroke
          ..color = kGold
          ..strokeWidth = 1.5
        );
      }

      // --- 2. SHADOW ---
      canvas.drawCircle(pos, radius + 2, Paint()..color = Colors.black.withOpacity(0.15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

      // --- 3. WHITE BACKGROUND ---
      canvas.drawCircle(pos, radius, Paint()..color = Colors.white);

      // --- 4. IMAGE ---
      Rect rect = Rect.fromCenter(center: pos, width: avatarSize, height: avatarSize);
      canvas.save();
      canvas.clipPath(Path()..addOval(rect));

      if (img != null) {
        paintImage(canvas: canvas, rect: rect, image: img, fit: BoxFit.cover);
      } else {
        canvas.drawRect(rect, Paint()..color = Colors.grey[300]!);
      }
      canvas.restore();

      // --- 5. STATUS BORDER ---
      final borderPaint = Paint()..style = PaintingStyle.stroke..color = getStatusColor(status)..strokeWidth = 3.0;
      canvas.drawCircle(pos, radius, borderPaint);

      // --- 6. ME INDICATOR ---
      if (isMe) {
        canvas.drawCircle(pos, radius + 6, Paint()..style=PaintingStyle.stroke..color=kObsidian..strokeWidth=2.0);
      }
    }

    /// Draw ME
    double myX = center.dx + (myPos.dx * scale);
    double myY = center.dy - (myPos.dy * scale);
    // Pass 'me' as ID, though it's handled by isMe=true
    drawAvatar(Offset(myX, myY), images.isNotEmpty ? images[0] : null, myStatus, myTags, true, id: 'me');

    // Draw OTHERS
    users.forEach((id, user) {
      double otherX = center.dx + (user.position.dx * scale);
      double otherY = center.dy - (user.position.dy * scale);

      int imgId = (user.imageId - 1);
      if (images.isNotEmpty && imgId >= 0) imgId = imgId % images.length;

      ui.Image? img = (images.isNotEmpty && imgId >= 0) ? images[imgId] : null;

      // CHANGED: We now pass the 'id' (e.g., 'ghost_2') to the function
      drawAvatar(Offset(otherX, otherY), img, user.status, user.tags, false, id: id);
    });
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) => true;
}

class MapUser {
  final String id;
  final Offset position;
  final int imageId;
  final List<String> tags;
  final String status;

  MapUser({
    required this.id,
    required this.position,
    required this.imageId,
    required this.tags,
    required this.status,
  });
}

// ==========================================
// 7. STORIES TAB
// ==========================================
class StoriesTabScreen extends StatefulWidget {
  const StoriesTabScreen({Key? key}) : super(key: key);

  @override
  State<StoriesTabScreen> createState() => _StoriesTabScreenState();
}

class _StoriesTabScreenState extends State<StoriesTabScreen> {
  final List<String> videoAssets = [
    'assets/video/video1.mp4',
    'assets/video/video2.mp4',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videoAssets.length,
        itemBuilder: (context, index) {
          return StoryPlayerItem(videoUrl: videoAssets[index]);
        },
      ),
    );
  }
}

class StoryPlayerItem extends StatefulWidget {
  final String videoUrl;
  const StoryPlayerItem({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<StoryPlayerItem> createState() => _StoryPlayerItemState();
}

class _StoryPlayerItemState extends State<StoryPlayerItem> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
          _controller.play();
          _controller.setLooping(true);
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator(color: kGold));
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: 20,
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: kGold,
                child: const Icon(Icons.person, size: 20, color: Colors.black),
              ),
              const SizedBox(width: 10),
              const Text(
                "Event Highlights",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Text(
                "Live",
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              )
            ],
          ),
        ),
      ],
    );
  }
}