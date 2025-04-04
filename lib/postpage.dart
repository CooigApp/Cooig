import 'package:carousel_slider/carousel_slider.dart';
//import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooig_firebase/academic_section/branch_page.dart';
import 'package:cooig_firebase/chatmain.dart';
//import 'package:cooig_firebase/lostandfound/lostpostscreen.dart';
//import 'package:cooig_firebase/PDFViewer.dart';
import 'package:cooig_firebase/pdfviewerurl.dart';
import 'package:cooig_firebase/search.dart';
//import 'package:cooig_firebase/postscreen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
//import 'package:path/path.dart';
import 'package:cooig_firebase/post.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:video_player/video_player.dart';
//import 'package:carousel_slider/carousel_slider.dart';

class PostPage extends StatefulWidget {
  dynamic userId;

  PostPage({super.key, required this.userId});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late Future<DocumentSnapshot> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture =
        FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: false,
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BranchPage()),
                );
              },
              icon: const Icon(
                Icons.school,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 1),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MySearchPage(
                            userId: widget.userId,
                          )),
                );
              },
              icon: const Icon(Icons.search, color: Colors.white),
            ),
            const SizedBox(width: 50),
            const Text(
              'Cooig',
              style: TextStyle(color: Colors.white, fontSize: 30.0),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => Notifications(
              //       userId: widget.userId,
              //     ),
              //   ),
              // );
            },
            icon: const Badge(
              backgroundColor: Color(0xFF635A8F),
              textColor: Colors.white,
              label: Text('5'),
              child: Icon(Icons.notifications, color: Colors.white),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => mainChat(
                    currentUserId: widget.userId,
                  ),
                ),
              );
            },
            icon: const Badge(
              backgroundColor: Color(0xFF635A8F),
              textColor: Colors.white,
              label: Text('5'),
              child: Icon(Icons.messenger_outline_rounded, color: Colors.white),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      //bottomNavigationBar: Nav(userId: widget.userId),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserPostInput(widget.userId),
            const SizedBox(height: 16),
            _buildPostStream(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPostInput(userId) {
    return Center(
      child: InkWell(
        splashColor: Colors.blue.withOpacity(0.3),
        highlightColor: Colors.transparent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostScreen(userId: userId),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(top: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          width: 250,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: FutureBuilder<DocumentSnapshot>(
            future: _userDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (!snapshot.hasData || !snapshot.data!.exists) {
                return _buildPlaceholderInput();
              } else {
                var data = snapshot.data!.data() as Map<String, dynamic>;
                String? imageUrl = data['image'] as String?;
                return _buildUserInputRow(imageUrl);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderInput() {
    return const Row(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 5.0),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
        ),
        SizedBox(width: 16),
        Text(
          "What's on your head?",
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInputRow(String? imageUrl) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: CircleAvatar(
            radius: 20,
            backgroundImage:
                NetworkImage(imageUrl ?? 'https://via.placeholder.com/150'),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          "What's on your head?",
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildPostStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts_upload')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!mounted) return const SizedBox.shrink();
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index].data() as Map<String, dynamic>;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(post['userID'])
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final user = userSnapshot.data!.data() as Map<String, dynamic>;
                final userName = user['full_name'] ?? 'Unknown';
                final userImage = user['profilepic'] ?? '';

                return PostWidget(
                  userName: userName,
                  userImage: userImage,
                  text: post['text'] ?? '',
                  mediaUrls: post['media'] != null
                      ? List<String>.from(post['media'])
                      : [],
                  timestamp: post['timestamp'],
                );
              },
            );
          },
        );
      },
    );
  }
}


class PostWidget extends StatelessWidget {
  final String userName;
  final String userImage;
  final String text;
  final List<String> mediaUrls;
  final Timestamp timestamp;

  const PostWidget({
    super.key,
    required this.userName,
    required this.userImage,
    required this.text,
    required this.mediaUrls,
    required this.timestamp,
  });

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute}";
  }

  List<Map<String, dynamic>> _classifyMedia(List<String> urls) {
    return urls.map((url) {
      String extension = url.split('?')[0].split('.').last.toLowerCase();
      String type;
      if (extension == 'mp4' || extension == 'mp3') {
        type = 'video';
      } else if (extension == 'pdf') {
        type = 'pdf';
      } else {
        type = 'image';
      }
      return {'url': url, 'type': type};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> media = _classifyMedia(mediaUrls);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: userImage.isNotEmpty
                    ? NetworkImage(userImage)
                    : const AssetImage('assets/default_avatar.png')
                        as ImageProvider,
                radius: 20,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTimestamp(timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          // Iterate through the documents

          if (media.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                aspectRatio: 16 / 9,
              ),
              items: media.map((medi) {
                if (medi['type'] == 'image') {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: Image.network(
                      medi['url'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                } else if (medi['type'] == 'video') {
                  return VideoPlayerWidget(medi['url']);
                } else if (medi['type'] == 'pdf') {
                  String url = medi['url'];
                  final String fileName = Uri.decodeFull(
                      url.split('/o/').last.split('?').first.split('%2F').last);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PDFViewerFromUrl(
                            pdfUrl: url,
                            fileName: fileName,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: const Color.fromARGB(255, 44, 32, 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.picture_as_pdf,
                              size: 40, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(
                            fileName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget(this.videoUrl, {super.key});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      })
      ..setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? GestureDetector(
            onTap: () {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
              setState(() {});
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                if (!_controller.value.isPlaying)
                  const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 50,
                  ),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}

class PollWidget extends StatefulWidget {
  final String userName;
  final String userImage;
  final String question;
  final List<String> options;
  final List<String> imageUrls;
  final bool isTextOption;

  const PollWidget({
    super.key,
    required this.userName,
    required this.userImage,
    required this.question,
    required this.options,
    required this.imageUrls,
    required this.isTextOption,
  });

  @override
  _PollWidgetState createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  String? selectedOption;
  Map<String, int> votes = {}; // To store votes per option
  int totalVotes = 0; // To store total votes

  void _handleVote(String option) {
    setState(() {
      if (selectedOption == null) {
        selectedOption = option;
        votes[option] = (votes[option] ?? 0) + 1;
        totalVotes += 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: widget.userImage.isNotEmpty
                    ? NetworkImage(widget.userImage)
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
                radius: 20,
              ),
              SizedBox(width: 10),
              Text(
                widget.userName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Iconsax.settings,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            widget.question,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          if (widget.isTextOption)
            ...widget.options.map((option) {
              double percentage =
                  totalVotes > 0 ? (votes[option] ?? 0) / totalVotes : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: selectedOption == null
                          ? () => _handleVote(option)
                          : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: Colors.white, width: 2),
                        ),
                        minimumSize: Size(400, 0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 15,
                        ),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (selectedOption != null) ...[
                      SizedBox(height: 10),
                      LinearPercentIndicator(
                        width: MediaQuery.of(context).size.width - 60,
                        lineHeight: 24.0,
                        percent: percentage,
                        backgroundColor: Colors.grey,
                        progressColor: Colors.purple,
                        center: Text(
                          "${(percentage * 100).toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
/*
class PostWidget extends StatelessWidget {
  final String userName;
  final String userImage;
  final String text;
  final List<String> mediaUrls;
  final Timestamp timestamp;

  const PostWidget({
    super.key,
    required this.userName,
    required this.userImage,
    required this.text,
    required this.mediaUrls,
    required this.timestamp,
  });

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute}";
  }

  List<Map<String, dynamic>> _classifyMedia(List<String> urls) {
    return urls.map((url) {
      String extension = url.split('?')[0].split('.').last.toLowerCase();
      String type;
      if (extension == 'mp4' || extension == 'mp3') {
        type = 'video';
      } else if (extension == 'pdf') {
        type = 'pdf';
      } else {
        type = 'image';
      }
      return {'url': url, 'type': type};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> media = _classifyMedia(mediaUrls);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: userImage.isNotEmpty
                    ? NetworkImage(userImage)
                    : const AssetImage('assets/default_avatar.png')
                        as ImageProvider,
                radius: 20,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTimestamp(timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          // Iterate through the documents
          if (media.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                aspectRatio: 16 / 9,
              ),
              items: media.map((medi) {
                if (medi['type'] == 'image') {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: Image.network(
                      medi['url'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                } else if (medi['type'] == 'video') {
                  return VideoPlayerWidget(medi['url']);
                } else if (medi['type'] == 'pdf') {
                  String url = medi['url'];
                  final String fileName = Uri.decodeFull(
                      url.split('/o/').last.split('?').first.split('%2F').last);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PDFViewerFromUrl(
                            pdfUrl: url,
                            fileName: fileName,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: const Color.fromARGB(255, 44, 32, 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.picture_as_pdf,
                              size: 40, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(
                            fileName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              }).toList(),
            ),
        ],
      ),
    );
  }
}



class _PostPageState extends State<PostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Colors.black,
        centerTitle: false,
        title: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BranchPage()),
                  );
                },
                icon: const Icon(
                  Icons.school,
                  color: Colors.white,
                )),
            const SizedBox(width: 1),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MySearchPage()),
                );
              },
              icon: const Icon(Icons.search, color: Colors.white),
            ),
            const SizedBox(width: 50),
            const Text(
              'Cooig',
              style: TextStyle(color: Colors.white, fontSize: 30.0),
            ),
          ],
        ),
        //backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Notifications(
                      userId: widget.userid,
                    ),
                  ));
            },
            icon: const Badge(
              backgroundColor: Color(0xFF635A8F),
              textColor: Colors.white,
              label: Text('5'),
              child: Icon(Icons.notifications, color: Colors.white),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => mainChat(
                          currentUserId: widget.userid,
                        )),
              );
            },
            icon: const Badge(
              backgroundColor: Color(0xFF635A8F),
              textColor: Colors.white,
              label: Text('5'),
              child: Icon(Icons.messenger_outline_rounded, color: Colors.white),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
  child: IntrinsicHeight(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: InkWell(
            splashColor: Colors.blue.withOpacity(0.3),
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PostScreen(userid: widget.userid)),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(top: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              width: 250,
              height: 100,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: FutureBuilder<DocumentSnapshot>(
                future: _userDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      !snapshot.data!.exists) {
                    return const Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 5.0),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                                'https://via.placeholder.com/150'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          "What's on your head?",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.w400,
                            height: 1.1,
                          ),
                        ),
                      ],
                    );
                  } else {
                    var data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    String? imageUrl = data['image'] as String?;

                    return Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(imageUrl ??
                                'https://via.placeholder.com/150'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "What's on your head?",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.w400,
                            height: 1.1,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16), // Add spacing between widgets
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts_upload')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
      

      body: SingleChildScrollView(
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: InkWell(
                  splashColor: Colors.blue.withOpacity(0.3),
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PostScreen(userid: widget.userid)),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    width: 250,
                    height: 100,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: FutureBuilder<DocumentSnapshot>(
                      future: _userDataFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError ||
                            !snapshot.hasData ||
                            !snapshot.data!.exists) {
                          return const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 5.0),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                      'https://via.placeholder.com/150'),
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                "What's on your head?",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: 'Arial',
                                  fontWeight: FontWeight.w400,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          );
                        } else {
                          var data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          String? imageUrl = data['image'] as String?;

                          return Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(imageUrl ??
                                      'https://via.placeholder.com/150'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "What's on your head?",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: 'Arial',
                                  fontWeight: FontWeight.w400,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
            
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        
        stream: FirebaseFirestore.instance
            .collection('posts_upload')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!mounted) return SizedBox.shrink();
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index].data() as Map<String, dynamic>;
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(post['userID'])
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final user =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final userName = user['full_name'] ?? 'Unknown';
                  final userImage = user['profilepic'] ?? '';

                  return PostWidget(
                    userName: userName,
                    userImage: userImage,
                    text: post['text'] ?? '',
                    mediaUrls: post['media'] != null
                        ? List<String>.from(post['media'])
                        : [],
                    timestamp: post['timestamp'],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
*/