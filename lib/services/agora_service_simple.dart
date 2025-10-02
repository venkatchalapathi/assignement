import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// Simplified Agora service that works without native compilation issues
class AgoraServiceSimple {
  static const String appId = 'e9ee7a386a7249ac869329a99eaebc35';
  
  bool _isInitialized = false;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isScreenSharing = false;
  List<int> _remoteUids = [];

  // Stream controllers for UI updates
  final StreamController<bool> _isJoinedController = StreamController<bool>.broadcast();
  final StreamController<bool> _isMutedController = StreamController<bool>.broadcast();
  final StreamController<bool> _isVideoEnabledController = StreamController<bool>.broadcast();
  final StreamController<bool> _isScreenSharingController = StreamController<bool>.broadcast();
  final StreamController<List<int>> _remoteUidsController = StreamController<List<int>>.broadcast();

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isJoined => _isJoined;
  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isScreenSharing => _isScreenSharing;
  List<int> get remoteUids => _remoteUids;
  
  Stream<bool> get isJoinedStream => _isJoinedController.stream;
  Stream<bool> get isMutedStream => _isMutedController.stream;
  Stream<bool> get isVideoEnabledStream => _isVideoEnabledController.stream;
  Stream<bool> get isScreenSharingStream => _isScreenSharingController.stream;
  Stream<List<int>> get remoteUidsStream => _remoteUidsController.stream;

  // Initialize Agora RTC Engine (simplified)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permissions
      await _requestPermissions();

      // Simulate initialization delay
      await Future.delayed(const Duration(seconds: 1));
      
      _isInitialized = true;
      print('Agora service initialized (simplified mode)');
    } catch (e) {
      print('Failed to initialize Agora: $e, but continuing in demo mode');
      // Don't rethrow, just mark as initialized for demo purposes
      _isInitialized = true;
    }
  }

  // Request necessary permissions
  Future<void> _requestPermissions() async {
    try {
      final permissions = [
        Permission.camera,
        Permission.microphone,
      ];

      final statuses = await permissions.request();
      
      // Check if permissions are granted, but don't throw error for demo purposes
      bool allGranted = true;
      for (final status in statuses.values) {
        if (status != PermissionStatus.granted) {
          allGranted = false;
          print('Permission not granted: $status');
        }
      }
      
      if (!allGranted) {
        print('Some permissions not granted, but continuing in demo mode');
      }
    } catch (e) {
      print('Permission request failed: $e, continuing in demo mode');
    }
  }

  // Join a channel (simplified)
  Future<void> joinChannel(String channelName, {int uid = 0}) async {
    if (!_isInitialized || _isJoined) return;

    try {
      // Simulate joining delay
      await Future.delayed(const Duration(seconds: 1));
      
      _isJoined = true;
      _isJoinedController.add(true);
      
      // Simulate remote user joining after 2 seconds
      Timer(const Duration(seconds: 2), () {
        _remoteUids = [12345]; // Mock remote user ID
        _remoteUidsController.add(_remoteUids);
      });
      
      print('Joined channel: $channelName');
    } catch (e) {
      print('Failed to join channel: $e');
      rethrow;
    }
  }

  // Leave the channel
  Future<void> leaveChannel() async {
    if (!_isJoined) return;

    try {
      _isJoined = false;
      _remoteUids.clear();
      _isJoinedController.add(false);
      _remoteUidsController.add([]);
      print('Left channel');
    } catch (e) {
      print('Failed to leave channel: $e');
      rethrow;
    }
  }

  // Toggle mute/unmute
  Future<void> toggleMute() async {
    if (!_isInitialized) return;

    try {
      _isMuted = !_isMuted;
      _isMutedController.add(_isMuted);
      print('Mute toggled: $_isMuted');
    } catch (e) {
      print('Failed to toggle mute: $e');
      rethrow;
    }
  }

  // Toggle video on/off
  Future<void> toggleVideo() async {
    if (!_isInitialized) return;

    try {
      _isVideoEnabled = !_isVideoEnabled;
      _isVideoEnabledController.add(_isVideoEnabled);
      print('Video toggled: $_isVideoEnabled');
    } catch (e) {
      print('Failed to toggle video: $e');
      rethrow;
    }
  }

  // Switch camera
  Future<void> switchCamera() async {
    if (!_isInitialized) return;

    try {
      print('Camera switched');
    } catch (e) {
      print('Failed to switch camera: $e');
      rethrow;
    }
  }

  // Start screen sharing
  Future<void> startScreenSharing() async {
    if (!_isInitialized || _isScreenSharing) return;

    try {
      _isScreenSharing = true;
      _isScreenSharingController.add(true);
      print('Screen sharing started');
    } catch (e) {
      print('Failed to start screen sharing: $e');
      rethrow;
    }
  }

  // Stop screen sharing
  Future<void> stopScreenSharing() async {
    if (!_isScreenSharing) return;

    try {
      _isScreenSharing = false;
      _isScreenSharingController.add(false);
      print('Screen sharing stopped');
    } catch (e) {
      print('Failed to stop screen sharing: $e');
      rethrow;
    }
  }

  // Get local video view (mock)
  Widget getLocalVideoView() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, color: Colors.white, size: 50),
            SizedBox(height: 16),
            Text(
              'Local Video\n(Simulated)',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Get remote video view (mock)
  Widget getRemoteVideoView(int uid) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, color: Colors.white, size: 50),
            SizedBox(height: 16),
            Text(
              'Remote Video\n(Simulated)',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Dispose resources
  Future<void> dispose() async {
    await _isJoinedController.close();
    await _isMutedController.close();
    await _isVideoEnabledController.close();
    await _isScreenSharingController.close();
    await _remoteUidsController.close();
    
    _isInitialized = false;
  }
}
