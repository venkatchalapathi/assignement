import 'package:flutter/material.dart';
import 'dart:io';
import '../services/agora_service.dart';
import '../services/agora_service_simple.dart';

class VideoCallProvider with ChangeNotifier {
  // Use simplified service for Android to avoid NDK issues
  late final dynamic _agoraService;
  
  bool _isInitialized = false;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isScreenSharing = false;
  List<int> _remoteUids = [];
  String? _currentChannel;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isJoined => _isJoined;
  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isScreenSharing => _isScreenSharing;
  List<int> get remoteUids => _remoteUids;
  String? get currentChannel => _currentChannel;
  dynamic get agoraService => _agoraService;

  VideoCallProvider() {
    // Use real Agora service for both platforms now that NDK is fixed
    _agoraService = AgoraService();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _agoraService.initialize();
      _isInitialized = true;
      
      // Listen to Agora service streams
      _agoraService.isJoinedStream.listen((joined) {
        _isJoined = joined;
        notifyListeners();
      });
      
      _agoraService.isMutedStream.listen((muted) {
        _isMuted = muted;
        notifyListeners();
      });
      
      _agoraService.isVideoEnabledStream.listen((enabled) {
        _isVideoEnabled = enabled;
        notifyListeners();
      });
      
      _agoraService.isScreenSharingStream.listen((sharing) {
        _isScreenSharing = sharing;
        notifyListeners();
      });
      
      _agoraService.remoteUidsStream.listen((uids) {
        _remoteUids = uids;
        notifyListeners();
      });
      
      _agoraService.remoteVideoStatesStream.listen((states) {
        // This will trigger a rebuild when remote video states change
        print('=== VIDEO CALL PROVIDER DEBUG ===');
        print('VideoCallProvider: Remote video states changed: $states');
        print('Current remote UIDs: $remoteUids');
        print('Notifying listeners...');
        notifyListeners();
        print('Listeners notified');
        print('=== END VIDEO CALL PROVIDER DEBUG ===');
      });
      
      notifyListeners();
    } catch (e) {
      print('Failed to initialize video call: $e');
    }
  }

  Future<void> joinChannel(String channelName) async {
    if (!_isInitialized) return;
    
    try {
      await _agoraService.joinChannel(channelName);
      _currentChannel = channelName;
    } catch (e) {
      print('Failed to join channel: $e');
      rethrow;
    }
  }

  Future<void> leaveChannel() async {
    if (!_isJoined) return;
    
    try {
      await _agoraService.leaveChannel();
      _currentChannel = null;
      _remoteUids.clear();
    } catch (e) {
      print('Failed to leave channel: $e');
      rethrow;
    }
  }

  Future<void> toggleMute() async {
    if (!_isInitialized) return;
    
    try {
      await _agoraService.toggleMute();
    } catch (e) {
      print('Failed to toggle mute: $e');
      rethrow;
    }
  }

  Future<void> toggleVideo() async {
    if (!_isInitialized) return;
    
    try {
      await _agoraService.toggleVideo();
    } catch (e) {
      print('Failed to toggle video: $e');
      rethrow;
    }
  }

  Future<void> switchCamera() async {
    if (!_isInitialized) return;
    
    try {
      await _agoraService.switchCamera();
    } catch (e) {
      print('Failed to switch camera: $e');
      rethrow;
    }
  }

  Future<void> startScreenSharing() async {
    if (!_isInitialized) return;
    
    try {
      await _agoraService.startScreenSharing();
    } catch (e) {
      print('Failed to start screen sharing: $e');
      rethrow;
    }
  }

  Future<void> stopScreenSharing() async {
    if (!_isInitialized) return;
    
    try {
      await _agoraService.stopScreenSharing();
    } catch (e) {
      print('Failed to stop screen sharing: $e');
      rethrow;
    }
  }

  Widget getLocalVideoView() {
    return _agoraService.getLocalVideoView();
  }

  Widget getRemoteVideoView(int uid) {
    return _agoraService.getRemoteVideoView(uid);
  }

  @override
  void dispose() {
    _agoraService.dispose();
    super.dispose();
  }
}
