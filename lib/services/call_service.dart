import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  bool _isInitialized = false;
  bool _isInCall = false;
  bool _isMuted = false;
  
  final String _emergencyNumber = "tel:112";
  final String _caregiverNumber = "tel:0123456789";
  
  bool get isInCall => _isInCall;
  bool get isMuted => _isMuted;
  
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      if (kIsWeb) {
        _isInitialized = true;
      } else {
        await [Permission.microphone, Permission.camera].request();
        _isInitialized = true;
      }
    } catch (e) {
      _isInitialized = false;
    }
  }
  
  Future<bool> startEmergencyCall() async {
    if (!_isInitialized) await init();
    if (_isInCall) return true;
    
    try {
      await Future.delayed(const Duration(seconds: 1));
      _isInCall = true;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> endEmergencyCall() async {
    if (!_isInCall) return;
    
    try {
      _isInCall = false;
      _isMuted = false;
    } catch (e) {
      // Handle error
    }
  }
  
  Future<bool> makePhoneCall({bool isEmergency = false}) async {
    try {
      final phoneNumber = isEmergency ? _emergencyNumber : _caregiverNumber;
      final Uri phoneUri = Uri.parse(phoneNumber);
      
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  
  Future<void> setMicrophoneMuted(bool muted) async {
    if (!_isInCall) return;
    
    try {
      _isMuted = muted;
    } catch (e) {
      // Handle error
    }
  }
  
  void dispose() {
    if (_isInCall) {
      endEmergencyCall();
    }
    _isInitialized = false;
  }
}
