import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_call_provider.dart';
import '../utils/constants.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _channelController = TextEditingController(text: AppConstants.defaultChannelName);
  bool _isJoining = false;
  int _rebuildCount = 0;

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }

  Future<void> _joinChannel() async {
    if (_channelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a channel name')),
      );
      return;
    }

    setState(() {
      _isJoining = true;
    });

    try {
      final videoCallProvider = Provider.of<VideoCallProvider>(context, listen: false);
      await videoCallProvider.joinChannel(_channelController.text.trim());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join channel: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  Future<void> _leaveChannel() async {
    try {
      final videoCallProvider = Provider.of<VideoCallProvider>(context, listen: false);
      await videoCallProvider.leaveChannel();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to leave channel: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        backgroundColor: const Color(AppConstants.primaryColorValue),
        foregroundColor: Colors.white,
      ),
      body: Consumer<VideoCallProvider>(
        builder: (context, videoCallProvider, child) {
          _rebuildCount++;
          print('VideoCallScreen Consumer rebuild #$_rebuildCount');
          if (!videoCallProvider.isInitialized) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing video call...'),
                ],
              ),
            );
          }

          if (!videoCallProvider.isJoined) {
            return _buildJoinScreen();
          }

          return _buildCallScreen(videoCallProvider);
        },
      ),
    );
  }

  Widget _buildJoinScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 
                    MediaQuery.of(context).padding.top - 
                    MediaQuery.of(context).padding.bottom - 
                    (AppConstants.defaultPadding * 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // Video Call Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(AppConstants.primaryColorValue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.videocam,
              size: 60,
              color: Color(AppConstants.primaryColorValue),
            ),
          ),
          const SizedBox(height: 30),

          const Text(
            'Join Video Call',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.primaryColorValue),
            ),
          ),
          const SizedBox(height: 10),

          const Text(
            'Enter a channel name to start or join a video call',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Channel Input
          TextField(
            controller: _channelController,
            decoration: const InputDecoration(
              labelText: 'Channel Name',
              prefixIcon: Icon(Icons.tag),
              border: OutlineInputBorder(),
              hintText: 'Enter channel name',
            ),
          ),
          const SizedBox(height: 24),

          // Join Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isJoining ? null : _joinChannel,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppConstants.primaryColorValue),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isJoining
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Join Call',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
      )
    );
  }

  Widget _buildCallScreen(VideoCallProvider videoCallProvider) {
    return Stack(
      children: [
        // Video Views
        _buildVideoViews(videoCallProvider),
        
        // Call Controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildCallControls(videoCallProvider),
        ),
      ],
    );
  }

  Widget _buildVideoViews(VideoCallProvider videoCallProvider) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: videoCallProvider.remoteUids.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_add,
                    size: 60,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Waiting for others to join...',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Channel: ${videoCallProvider.currentChannel}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Remote video (full screen)
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: videoCallProvider.remoteUids.isNotEmpty
                      ? Stack(
                          children: [
                            _buildRemoteVideoView(videoCallProvider),
                            // Debug info
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Remote UIDs: ${videoCallProvider.remoteUids}\nLocal Video: ${videoCallProvider.isVideoEnabled}\nRemote Video States: ${videoCallProvider.agoraService.remoteVideoStates}\nTime: ${DateTime.now().millisecondsSinceEpoch}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          color: Colors.black,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_add,
                                  color: Colors.white54,
                                  size: 60,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Waiting for others to join...',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                
                // Screen sharing indicator
                if (videoCallProvider.isScreenSharing)
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.screen_share,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Screen Sharing (Demo)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Local video (picture-in-picture)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: videoCallProvider.isVideoEnabled 
                          ? videoCallProvider.getLocalVideoView()
                          : Container(
                              color: Colors.black,
                              child: const Center(
                                child: Icon(
                                  Icons.videocam_off,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCallControls(VideoCallProvider videoCallProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute/Unmute
          _buildControlButton(
            icon: videoCallProvider.isMuted ? Icons.mic_off : Icons.mic,
            isActive: !videoCallProvider.isMuted,
            onPressed: () => videoCallProvider.toggleMute(),
          ),
          
          // Video On/Off
          _buildControlButton(
            icon: videoCallProvider.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
            isActive: videoCallProvider.isVideoEnabled,
            onPressed: () => videoCallProvider.toggleVideo(),
          ),
          
          // Switch Camera
          _buildControlButton(
            icon: Icons.switch_camera,
            isActive: true,
            onPressed: () => videoCallProvider.switchCamera(),
          ),
          
          // Screen Share
          _buildControlButton(
            icon: videoCallProvider.isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
            isActive: videoCallProvider.isScreenSharing,
            onPressed: () async {
              if (videoCallProvider.isScreenSharing) {
                await videoCallProvider.stopScreenSharing();
              } else {
                await _showScreenShareDialog(videoCallProvider);
              }
            },
          ),
          
          // End Call
          _buildControlButton(
            icon: Icons.call_end,
            isActive: false,
            backgroundColor: Colors.red,
            onPressed: _leaveChannel,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor ?? (isActive ? Colors.white : Colors.white.withOpacity(0.3)),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: backgroundColor != null ? Colors.white : (isActive ? Colors.black : Colors.white),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildRemoteVideoView(VideoCallProvider videoCallProvider) {
    print('=== BUILD REMOTE VIDEO VIEW DEBUG ===');
    print('Remote UIDs: ${videoCallProvider.remoteUids}');
    print('Remote video states: ${videoCallProvider.agoraService.remoteVideoStates}');
    print('Timestamp: ${DateTime.now().millisecondsSinceEpoch}');
    
    if (videoCallProvider.remoteUids.isEmpty) {
      print('No remote UIDs, showing placeholder');
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text('No remote video', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final remoteUid = videoCallProvider.remoteUids.first;
    final remoteVideoStates = videoCallProvider.agoraService.remoteVideoStates;
    final isRemoteVideoEnabled = remoteVideoStates[remoteUid] ?? true;
    
    print('Remote UID: $remoteUid');
    print('Is remote video enabled: $isRemoteVideoEnabled');
    print('Remote video states map: $remoteVideoStates');
    
    // Show placeholder when remote video is disabled
    if (!isRemoteVideoEnabled) {
      print('Remote video is disabled, showing placeholder');
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person,
                color: Colors.white,
                size: 80,
              ),
              const SizedBox(height: 16),
              const Text(
                'Video is off',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'UID: $remoteUid',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    print('Remote video is enabled, showing Agora video view');
    print('=== END BUILD REMOTE VIDEO VIEW DEBUG ===');
    
    // Show Agora video view when remote video is enabled
    return videoCallProvider.getRemoteVideoView(remoteUid);
  }

  Future<void> _showScreenShareDialog(VideoCallProvider videoCallProvider) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Start Screen Sharing'),
          content: const Text(
            'This will start sharing your screen with other participants. '
            'Note: This is a demo implementation. Real screen sharing requires additional platform-specific setup.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Start Sharing'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await videoCallProvider.startScreenSharing();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Screen sharing started'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to start screen sharing: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
