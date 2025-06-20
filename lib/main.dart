import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';
import 'package:video_player/video_player.dart';
import 'services/api_service.dart'; // Tambahkan import ini
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:math';


final String baseUrl = 'https://backend_x.is-web.my.id/api/';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'X Clone',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          color: Colors.black,
          elevation: 0,
        ),
      ),
      home: const XHomePage(), // Ganti LoginPage jadi XHomePage
    );
  }
}

class XHomePage extends StatefulWidget {
  const XHomePage({Key? key}) : super(key: key);

  @override
  State<XHomePage> createState() => _XHomePageState();
}

class _XHomePageState extends State<XHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _postController = TextEditingController();
  bool _isUploading = false;
  dynamic _selectedImageFile; // Added to fix undefined name error

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _uploadPost() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final content = _postController.text.trim();
    if (token == null || content.isEmpty) return;

    setState(() => _isUploading = true);
    try {
      final response = await ApiService.uploadPost(token: token, content: content, imageFile: _selectedImageFile);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Post uploaded!'), backgroundColor: Colors.green),
      );
      _postController.clear();
      // Optionally refresh post list here
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload post: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout based on screen width
          if (constraints.maxWidth > 1200) {
            // Large screen - show all three panels
            return Row(
              children: [
                Expanded(flex: 1, child: LeftSidebar()),
                Container(width: 1, color: Colors.grey[800]),
                Expanded(flex: 2, child: CenterContent(tabController: _tabController)),
                Container(width: 1, color: Colors.grey[800]),
                Expanded(flex: 1, child: RightSidebar()),
              ],
            );
          } else if (constraints.maxWidth > 800) {
            // Medium screen - show left and center panels
            return Row(
              children: [
                Expanded(flex: 1, child: LeftSidebar()),
                Container(width: 1, color: Colors.grey[800]),
                Expanded(flex: 3, child: CenterContent(tabController: _tabController)),
              ],
            );
          } else {
            // Small screen - show only center panel with drawer for left panel
            return Scaffold(
              drawer: Drawer(
                child: LeftSidebar(),
              ),
              appBar: AppBar(
                title: const XLogo(),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ],
              ),
              body: CenterContent(tabController: _tabController),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.black,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.grey,
                currentIndex: 0, // untuk highlight tab aktif
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                  BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notif'),
                  BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Message'),
                ],
                onTap: (index) {
                  // Tambahkan aksi sesuai kebutuhan navigasi nanti
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class XLogo extends StatelessWidget {
  const XLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Image.asset(
        'assets/image/logo_x.png',
        width: 50,
        height: 50
      ),
    );
  }
}

class LeftSidebar extends StatefulWidget {
  LeftSidebar({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.home,
      'label': 'Home',
      'badge': 0,
    },
    {
      'icon': Icons.search,
      'label': 'Explore',
      'badge': 0,
    },
    {
      'icon': Icons.notifications,
      'label': 'Notifications',
      'badge': 2,
    },
    {
      'icon': Icons.mail,
      'label': 'Messages',
      'badge': 0,
    },
    {
      'icon': Icons.flash_on,
      'label': 'Grok',
      'badge': 0,
    },
    {
      'icon': Icons.people,
      'label': 'Communities',
      'badge': 0,
    },
    {
      'icon': Icons.verified,
      'label': 'Premium',
      'badge': 0,
    },
    {
      'icon': Icons.business,
      'label': 'Verified Orgs',
      'badge': 0,
    },
    {
      'icon': Icons.person,
      'label': 'Profile',
      'badge': 0,
    },
    {
      'icon': Icons.more_horiz,
      'label': 'More',
      'badge': 0,
    },
  ];

  @override
  State<LeftSidebar> createState() => _LeftSidebarState();
}

class _LeftSidebarState extends State<LeftSidebar> {
  String name = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      // Redirect to login page if token is not found
      if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      }
      return;
    }
    try {
      final userData = await ApiService.getCurrentUser(token);
      setState(() {
        name = userData['name'] ?? '';
        username = userData['username'] ?? '';
      });
    } catch (e) {
      // Optional: handle error
    }
  }

  void _showComposer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      // Implement draft saving here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: const Text('Draft'),
                  ),
                ],
              ),
              const Divider(),
              // Composer content here
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: const [
                XLogo(),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.menuItems.length,
              itemBuilder: (context, index) {
                final item = widget.menuItems[index];
                return ListTile(
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(item['icon'], size: 28),
                      if (item['badge'] > 0)
                        Positioned(
                          top: -5,
                          right: -5,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${item['badge']}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    item['label'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {},
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showComposer(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Post',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage('assets/image/profil.png'),
            ),
            title: Text(name.isNotEmpty ? name : 'User'),
            subtitle: Text(username.isNotEmpty ? '@$username' : ''),
            trailing: const Icon(Icons.more_horiz),
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class CenterContent extends StatefulWidget {
  final TabController tabController;

  const CenterContent({
    Key? key,
    required this.tabController,
  }) : super(key: key);

  @override
  State<CenterContent> createState() => _CenterContentState();
}

class _CenterContentState extends State<CenterContent> {
  final TextEditingController _composerController = TextEditingController();
  bool _isUploading = false;
  Uint8List? _selectedImageBytes;
  XFile? _selectedImageFile;

  List<dynamic> _apiPosts = [];
  bool _isLoadingPosts = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() => _isLoadingPosts = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        final posts = await ApiService.getAllPosts(token);
        setState(() {
          // Pastikan posts['data'] jika response berupa {: [...]}
            _apiPosts = posts is List ? posts as List<dynamic> : [];
            print(_apiPosts);
        });
      }
    } catch (e) {
      print(e);

      // Optional: handle error
    } finally {
      setState(() => _isLoadingPosts = false);
    }
  }

  Future<void> _uploadPost() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final content = _composerController.text.trim();
    if (token == null || content.isEmpty) return;

    setState(() => _isUploading = true);
    try {
      final response = await ApiService.uploadPost(token: token, content: content, imageFile: _selectedImageFile);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Post uploaded!'), backgroundColor: Colors.green),
      );
      _composerController.clear();
      setState(() => _selectedImageFile= null);
      // Optionally refresh post list here
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload post: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _pickImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
  if (pickedFile != null) {
    final bytes = await pickedFile.readAsBytes();
    setState(() {
      _selectedImageFile = pickedFile;
      _selectedImageBytes = bytes;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar for "For you" and "Following"
        TabBar(
          controller: widget.tabController,
          tabs: const [
            Tab(text: 'For you'),
            Tab(text: 'Following'),
          ],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
        ),
        Divider(height: 1, color: Colors.grey[800]),

        // Tweet composer
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/image/profil.png'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _composerController,
                      decoration: const InputDecoration(
                        hintText: "What's happening?",
                        border: InputBorder.none,
                      ),
                      maxLines: 4,
                      minLines: 2,
                    ),
                   
                    if (_selectedImageBytes != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Stack(
                          children: [
                            Image.memory(_selectedImageBytes!, height: 120),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => setState(() {
                                  _selectedImageBytes = null;
                                  _selectedImageFile = null;
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.image, color: Colors.blue),
                          onPressed: _pickImage,
                        ),
                        IconButton(
                          icon: const Icon(Icons.gif_box, color: Colors.blue),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.flash_on, color: Colors.blue),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.event, color: Colors.blue),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.emoji_emotions, color: Colors.blue),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.location_on, color: Colors.blue),
                          onPressed: () {},
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _isUploading ? null : _uploadPost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: _isUploading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Posting'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Divider(height: 1, color: Colors.grey[800]),
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Show 35 posts', style: TextStyle(color: Colors.blue)),
          ),
        ),
        Divider(height: 1, color: Colors.grey[800]),

        // Tweet feed
        Expanded(
          child: ListView(
            children: [
              if (_isLoadingPosts)
                const Center(child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                )),
              // Render API posts
              ..._apiPosts.map((post) {
  try {

    final random = Random();
    final fakeComments = (random.nextInt(9000) + 1000).toString();
    final fakeRetweets = (random.nextInt(900) + 100).toString();
    final fakeViews = '${random.nextInt(90) + 10}jt';

    return _buildPost(
      username: post['user']?['name'] ?? 'Unknown',
      handle: '@${post['user']?['full_name'] ?? 'unknown'}',
      timeAgo: '${random.nextInt(23) + 1}h',
      isVerified: random.nextBool(),
      content: post['caption'] ?? '',
      imageUrl: (post['media_path'] != null && post['media_path'] != '')
          ? (post['media_path'].toString().startsWith('http')
              ? post['media_path']
              : '${baseUrl}media/${post['media_path']}')
          : null,
      profileImageUrl: 'assets/image/logo_x.png',
      comments: fakeComments,
      retweets: fakeRetweets,
      likes: (post['likes'] is List) ? post['likes'].length.toString() : '0',
      views: fakeViews,
      imageAspectRatio: 1.0,
    );
  } catch (e) {
    print('Error build post: $e');
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text('Error saat menampilkan post dari API', style: TextStyle(color: Colors.red)),
    );
  }
}),
              if (_apiPosts.isNotEmpty)
                Divider(height: 1, color: Colors.grey[800]),
              // Mockup posts (tetap di bawah)
              _buildPost(
                username: 'WOMANFEEDS',
                handle: '@womanfeeds_id',
                timeAgo: '10h',
                isVerified: false,
                content: '[mu] bad experience waktu kalian treatment ada nggak 😭',
                imageUrl: 'assets/image/konten1.jpg',
                profileImageUrl: 'assets/image/profil1.jpg',
                comments: '760',
                retweets: '300',
                likes: '7,4K',
                views: '74,4K',
                imageAspectRatio: 1.0,
              ),
              Divider(height: 1, color: Colors.grey[800]),
              _buildPost(
                username: 'Indomie',
                handle: '@Indomielovers',
                timeAgo: 'Ad',
                isVerified: true,
                content: "OH MY GOOD IT'S INDOMIE!!\n\nIndomie Goreng jadi favorit Minji, Hanni, Danielle, Haerin, dan Hyein juga lhooo!😋\n\nTungguiin terus keseruan lainnya yah, karena masih banyak lagi! 🍜😋",
                profileImageUrl: 'assets/image/profil2.jpg',
                comments: '3K',
                retweets: '58',
                likes: '255K',
                views: '68,3k',
                isVideo: true,
                videoPath: 'assets/image/indomie.mp4',
                videoThumbnail: 'assets/image/konten2.jpg',
                videoLength: '0:10',
                imageAspectRatio: 16/9,
              ),
              Divider(height: 1, color: Colors.grey[800]),
              _buildPost(
                username: 'sosmed keras',
                handle: '@sosmedkeras',
                timeAgo: '23h',
                isVerified: true,
                content: '',
                imageUrl: 'assets/image/konten3.jpg',
                profileImageUrl: 'assets/image/profil3.jpg',
                comments: '3.9k',
                retweets: '882',
                likes: '29',
                views: '74K',
                imageAspectRatio: 4/5,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPost({
    required String username,
    required String handle,
    required String timeAgo,
    required bool isVerified,
    required String content,
    String? imageUrl,
    String? videoPath,
    String? videoThumbnail,
    String? videoLength,
    String? profileImageUrl,
    String likes = '0',
    String comments = '0',
    String retweets = '0',
    String views = '0',
    bool isVideo = false,
    double imageAspectRatio = 16/9, // Default aspect ratio
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: profileImageUrl != null
                ? AssetImage(profileImageUrl)
                : const AssetImage('assets/image/profil4.jpg'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isVerified)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Icon(Icons.verified, color: Colors.blue, size: 16),
                      ),
                    Text(
                      ' $handle · $timeAgo',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Icon(Icons.more_horiz, color: Colors.grey[600]),
                  ],
                ),
                const SizedBox(height: 4),
                Text(content),
                const SizedBox(height: 8),

                // Media content with correct aspect ratio
                if (imageUrl != null && !isVideo)
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: 350, // Fixed width that looks similar to your image post
                      maxHeight: 420, // Set a maximum height that resembles the post image
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl != null && imageUrl.startsWith('http')
    ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image))
    : Image.asset(imageUrl ?? '', fit: BoxFit.cover),
                    ),
                  ),

                // Video post
                if (isVideo && videoThumbnail != null)
                  Container(
                    width: 380, // Lebar sesuai dengan post Twitter/X
                    constraints: BoxConstraints(
                      maxHeight: 400, // Tinggi maksimum yang sesuai dengan post video Twitter/X
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              // Video thumbnail
                              VideoPostPreview(
                                thumbnailPath: videoThumbnail,
                                videoPath: videoPath ?? '',
                                videoLength: videoLength ?? '0:00',
                                aspectRatio: 1.0, // Video di Twitter/X biasanya bisa 1:1 atau portrait
                              ),

                              // Video duration overlay
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    videoLength ?? '0:00',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton(Icons.comment, comments),
                    _buildActionButton(Icons.repeat, retweets),
                    _buildActionButton(Icons.favorite_border, likes),
                    _buildActionButton(Icons.bar_chart, views),
                    _buildActionButton(Icons.bookmark_border, ''),
                    const Icon(Icons.share, size: 20, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}

// Widget for video post preview with play functionality
class VideoPostPreview extends StatefulWidget {
  final String thumbnailPath;
  final String videoPath;
  final String videoLength;
  final double aspectRatio;

  const VideoPostPreview({
    Key? key,
    required this.thumbnailPath,
    required this.videoPath,
    required this.videoLength,
    this.aspectRatio = 16/9,
  }) : super(key: key);

  @override
  State<VideoPostPreview> createState() => _VideoPostPreviewState();
}

class _VideoPostPreviewState extends State<VideoPostPreview> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isInitialized ? _togglePlayPause : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isInitialized && _isPlaying)
                VideoPlayer(_controller)
              else
                Image.asset(
                  widget.thumbnailPath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),

              if (!_isPlaying)
                Icon(
                  Icons.play_circle_fill,
                  color: Colors.white.withOpacity(0.8),
                  size: 48,
                ),

              // Video Length display
              if (!_isPlaying)
                Positioned(
                  bottom: 8,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.videoLength,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RightSidebar extends StatelessWidget {
  RightSidebar({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> trends = [
    {
      'location': 'Indonesia',
      'name': '#jamborekarhutilariau2025',
      'posts': '',
    },
    {
      'location': 'Indonesia',
      'name': 'Senih',
      'posts': '137K posts',
    },
    {
      'location': 'Indonesia',
      'name': 'Vanessa',
      'posts': '22.6K posts',
    },
    {
      'location': 'Indonesia',
      'name': 'kita saling melengkapi',
      'posts': '5,250 posts',
    },
  ];

  final List<Map<String, dynamic>> toFollow = [
    {
      'name': 'Ruang Healing',
      'handle': '@RuangHealing',
      'isVerified': true,
    },
    {
      'name': 'Saint Hoax',
      'handle': '@SaintHoax',
      'isVerified': false,
    },
    {
      'name': 'pais',
      'handle': '@faizsadad_',
      'isVerified': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: const [
                Icon(Icons.search, size: 20),
                SizedBox(width: 8),
                Text('Search', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Premium subscribe section
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subscribe to Premium',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Subscribe to unlock new features and if eligible, receive a share of revenue.',
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Subscribe'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // What's happening section
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "What's happening",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                // Live event
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/image/konten4.jpg',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'From the Desk of Anthony Pompilano',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Trending topics
                ...trends.map((trend) => _buildTrendingTopic(
                  location: trend['location'],
                  name: trend['name'],
                  posts: trend['posts'],
                )),

                TextButton(
                  onPressed: () {},
                  child: const Text('Show more'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Who to follow section
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Who to follow',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                ...toFollow.map((user) => _buildFollowSuggestion(
                  name: user['name'],
                  handle: user['handle'],
                  isVerified: user['isVerified'],
                )),
                TextButton(
                  onPressed: () {},
                  child: const Text('Show more'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Footer links
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFooterLink('Terms of Service'),
              _buildFooterLink('Privacy Policy'),
              _buildFooterLink('Cookie Policy'),
              _buildFooterLink('Accessibility'),
              _buildFooterLink('Ads Info'),
              _buildFooterLink('More ...'),
            ],
          ),
          const SizedBox(height: 8),
          Text('© 2025 X Corp.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTrendingTopic({
    required String location,
    required String name,
    required String posts,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trending in $location',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (posts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      posts,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.more_horiz, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget _buildFollowSuggestion({
    required String name,
    required String handle,
    required bool isVerified,
  }) {
    // Map usernames to profile image assets
    final String profileImage = 'assets/images/profile_${name.toLowerCase().replaceAll(' ', '_')}.jpg';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(profileImage),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isVerified)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Icon(Icons.verified, color: Colors.blue, size: 16),
                      ),
                  ],
                ),
                Text(
                  handle,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Follow'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.grey[600], fontSize: 12),
    );
  }
}