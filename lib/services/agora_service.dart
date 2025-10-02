import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  static const String appId = 'e9ee7a386a7249ac869329a99eaebc35';
  
  RtcEngine? _engine;
  bool _isInitialized = false;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isScreenSharing = false;
  List<int> _remoteUids = [];
  Map<int, bool> _remoteVideoStates = {}; // Track remote video states

  // Stream controllers for UI updates
  final StreamController<bool> _isJoinedController = StreamController<bool>.broadcast();
  final StreamController<bool> _isMutedController = StreamController<bool>.broadcast();
  final StreamController<bool> _isVideoEnabledController = StreamController<bool>.broadcast();
  final StreamController<bool> _isScreenSharingController = StreamController<bool>.broadcast();
  final StreamController<List<int>> _remoteUidsController = StreamController<List<int>>.broadcast();
  final StreamController<Map<int, bool>> _remoteVideoStatesController = StreamController<Map<int, bool>>.broadcast();

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isJoined => _isJoined;
  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isScreenSharing => _isScreenSharing;
  List<int> get remoteUids => _remoteUids;
  Map<int, bool> get remoteVideoStates => _remoteVideoStates;
  
  Stream<bool> get isJoinedStream => _isJoinedController.stream;
  Stream<bool> get isMutedStream => _isMutedController.stream;
  Stream<bool> get isVideoEnabledStream => _isVideoEnabledController.stream;
  Stream<bool> get isScreenSharingStream => _isScreenSharingController.stream;
  Stream<List<int>> get remoteUidsStream => _remoteUidsController.stream;
  Stream<Map<int, bool>> get remoteVideoStatesStream => _remoteVideoStatesController.stream;

  // Initialize Agora RTC Engine
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permissions
      await _requestPermissions();

      // Create RTC Engine instance
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(appId: appId));

      // Set up event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            _isJoined = true;
            _isJoinedController.add(true);
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print('User joined: $remoteUid');
            _remoteUids.add(remoteUid);
            _remoteUidsController.add(List.from(_remoteUids));
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            _remoteUids.remove(remoteUid);
            _remoteVideoStates.remove(remoteUid);
            _remoteUidsController.add(List.from(_remoteUids));
          },
          onRemoteVideoStateChanged: (RtcConnection connection, int remoteUid, RemoteVideoState state, RemoteVideoStateReason reason, int elapsed) {
            // Handle remote video state changes
            print('=== REMOTE VIDEO STATE CHANGE DEBUG ===');
            print('Remote video state changed: $state for user $remoteUid');
            print('Reason: $reason, Elapsed: $elapsed');
            
            // Update remote video state - video is enabled only when decoding
            final previousState = _remoteVideoStates[remoteUid];
            _remoteVideoStates[remoteUid] = state == RemoteVideoState.remoteVideoStateDecoding;
            
            print('Previous remote video state for user $remoteUid: $previousState');
            print('New remote video state for user $remoteUid: ${_remoteVideoStates[remoteUid]}');
            print('All remote video states: $_remoteVideoStates');
            
            // Notify UI of the change by triggering a rebuild
            _remoteUidsController.add(List.from(_remoteUids));
            _remoteVideoStatesController.add(Map.from(_remoteVideoStates));
            print('Notified UI of remote video state change');
            print('=== END REMOTE VIDEO STATE CHANGE DEBUG ===');
          },
          onRemoteAudioStateChanged: (RtcConnection connection, int remoteUid, RemoteAudioState state, RemoteAudioStateReason reason, int elapsed) {
            // Handle remote audio state changes
            print('Remote audio state changed: $state for user $remoteUid');
          },
          onError: (ErrorCodeType err, String msg) {
            print('Agora Error: $err - $msg');
          },
        ),
      );

      // Enable video
      await _engine!.enableVideo();
      await _engine!.startPreview();

      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize Agora: $e');
      rethrow;
    }
  }

  // Request necessary permissions
  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
    ];

    final statuses = await permissions.request();
    
    for (final status in statuses.values) {
      if (status != PermissionStatus.granted) {
        throw Exception('Required permissions not granted');
      }
    }
  }

  // Join a channel
  Future<void> joinChannel(String channelName, {int uid = 0}) async {
    if (!_isInitialized || _isJoined) return;

    try {
      await _engine!.joinChannel(
        token: '', // Use empty string for testing, in production use proper token
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
    } catch (e) {
      print('Failed to join channel: $e');
      rethrow;
    }
  }

  // Leave the channel
  Future<void> leaveChannel() async {
    if (!_isJoined) return;

    try {
      await _engine!.leaveChannel();
      _isJoined = false;
      _isJoinedController.add(false);
    } catch (e) {
      print('Failed to leave channel: $e');
      rethrow;
    }
  }

  // Toggle mute/unmute
  Future<void> toggleMute() async {
    if (!_isInitialized) return;

    try {
      await _engine!.muteLocalAudioStream(!_isMuted);
      _isMuted = !_isMuted;
      _isMutedController.add(_isMuted);
    } catch (e) {
      print('Failed to toggle mute: $e');
      rethrow;
    }
  }

  // Toggle video on/off
  Future<void> toggleVideo() async {
    if (!_isInitialized) return;

    try {
      final previousState = _isVideoEnabled;
      _isVideoEnabled = !_isVideoEnabled;
      
      print('=== VIDEO TOGGLE DEBUG ===');
      print('Previous video state: $previousState');
      print('New video state: $_isVideoEnabled');
      print('Calling muteLocalVideoStream with mute: ${!_isVideoEnabled}');
      
      await _engine!.muteLocalVideoStream(!_isVideoEnabled);
      
      print('muteLocalVideoStream completed successfully');
      print('Updating video state controller');
      
      _isVideoEnabledController.add(_isVideoEnabled);
      
      print('Video state controller updated');
      print('Current video state: $_isVideoEnabled');
      print('=== END VIDEO TOGGLE DEBUG ===');
    } catch (e) {
      print('Failed to toggle video: $e');
      rethrow;
    }
  }

  // Switch camera
  Future<void> switchCamera() async {
    if (!_isInitialized) return;

    try {
      await _engine!.switchCamera();
    } catch (e) {
      print('Failed to switch camera: $e');
      rethrow;
    }
  }

  // Start screen sharing
  Future<void> startScreenSharing() async {
    if (!_isInitialized || _isScreenSharing) return;

    try {
      // Request screen sharing permission
      final permission = await Permission.systemAlertWindow.request();
      
      if (permission != PermissionStatus.granted) {
        print('Screen sharing permission not granted, but continuing with demo mode');
        // For demo purposes, we'll continue even without permission
      }
      
      // For demo purposes, we'll simulate screen sharing
      // In a real implementation, you would use platform-specific screen capture
      print('Starting screen sharing (demo mode)...');
      
      // Simulate screen sharing with a delay
      await Future.delayed(const Duration(seconds: 1));
      
      _isScreenSharing = true;
      _isScreenSharingController.add(true);
      
      print('Screen sharing started successfully (demo mode)');
      
      // Note: For real screen sharing, you would need to:
      // 1. Use platform-specific screen capture APIs
      // 2. Create a video stream from screen capture
      // 3. Send it through Agora RTC
      // 4. Handle permissions properly
      
    } catch (e) {
      print('Failed to start screen sharing: $e');
      rethrow;
    }
  }

  // Stop screen sharing
  Future<void> stopScreenSharing() async {
    if (!_isScreenSharing) return;

    try {
      // For demo mode, just update the state
      print('Stopping screen sharing (demo mode)...');
      
      _isScreenSharing = false;
      _isScreenSharingController.add(false);
      
      print('Screen sharing stopped successfully (demo mode)');
    } catch (e) {
      print('Failed to stop screen sharing: $e');
      rethrow;
    }
  }

  // Get local video view
  Widget getLocalVideoView() {
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text('Initializing...', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    if (!_isVideoEnabled) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(
            Icons.videocam_off,
            color: Colors.white,
            size: 30,
          ),
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  // Get remote video view
  Widget getRemoteVideoView(int uid) {
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text('No remote video', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    print('getRemoteVideoView for uid $uid: returning raw Agora view');

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: uid),
        connection: const RtcConnection(channelId: ''),
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
    await _remoteVideoStatesController.close();
    
    if (_engine != null) {
      await _engine!.release();
      _engine = null;
    }
    
    _isInitialized = false;
  }
}
