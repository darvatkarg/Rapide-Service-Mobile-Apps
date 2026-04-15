import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hyper_local/router/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      log('⚠️ NotificationManager already initialized');
      return;
    }

    try {
      log('🔔 Initializing NotificationManager...');

      // Request permission
      await requestPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Setup message handlers
      _setupMessageHandlers();

      // Handle terminated state (initial message)
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        log('🚀 App launched from notification (terminated): ${initialMessage.messageId}');
        // Small delay to ensure router is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationTap(initialMessage);
        });
      }

      // Get and save FCM token
      await _retrieveAndSaveFCMToken();

      _initialized = true;
      log('✅ NotificationManager initialization complete');
    } catch (e) {
      log('❌ NotificationManager initialization error: $e');
      rethrow;
    }
  }

  Future<void> requestPermission() async {
    try {
      log('📱 Requesting notification permission...');

      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      log('📱 Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('✅ User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        log('✅ User granted provisional permission');
      } else {
        log('⚠️ User declined or has not accepted permission');
      }
    } catch (e) {
      log('❌ Error requesting permission: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
  }

  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📨 Foreground message received: ${message.messageId}');
      log('Title: ${message.notification?.title}');
      log('Body: ${message.notification?.body}');
      log('Data: ${message.data}');

      _showLocalNotification(message);
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('📬 Notification tapped (background): ${message.messageId}');
      _handleNotificationTap(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _retrieveAndSaveFCMToken() async {
    try {
      log('🔑 Retrieving FCM token...');

      // For iOS, get APNS token first
      if (Platform.isIOS) {
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        log('🍎 APNS Token: $apnsToken');

        if (apnsToken == null) {
          // Wait a bit and try again
          await Future.delayed(Duration(seconds: 3));
          apnsToken = await _firebaseMessaging.getAPNSToken();
          log('🍎 APNS Token (retry): $apnsToken');
        }
      }

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      log('🔑 FCM Token retrieved: $token');

      if (token != null && token.isNotEmpty) {
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
        log('✅ FCM Token saved to SharedPreferences');
      } else {
        log('⚠️ FCM Token is null or empty');
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        log('🔄 FCM Token refreshed: $newToken');
        _saveTokenToPrefs(newToken);
      });
    } catch (e) {
      log('❌ Error retrieving FCM token: $e');
    }
  }

  Future<String?> getFCMToken() async {
    try {
      log('🔍 getFCMToken() called...');

      // First try to get from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? cachedToken = prefs.getString('fcm_token');
      log('📦 CACHED FCM TOKEN: $cachedToken');

      if (cachedToken != null && cachedToken.isNotEmpty) {
        return cachedToken;
      }

      // If not in cache, get from Firebase
      log('🔥 Getting token from Firebase...');
      String? token = await _firebaseMessaging.getToken();
      log('🔑 Firebase returned token: $token');

      if (token != null && token.isNotEmpty) {
        // Save to cache
        await prefs.setString('fcm_token', token);
        log('✅ Token saved to cache');
        return token;
      }

      log('⚠️ Unable to get FCM token');
      return null;
    } catch (e) {
      log('❌ Error in getFCMToken: $e');
      return null;
    }
  }

  Future<void> _saveTokenToPrefs(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      log('✅ Token saved: $token');
    } catch (e) {
      log('❌ Error saving token: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    log('🔔 Local notification tapped: ${response.payload}');
    // Handle notification tap
  }

  void _handleNotificationTap(RemoteMessage message) {
    log('📬 Handling notification tap: ${message.data}');
    final type = message.data['type']?.toString();
    final metadata = message.data; // The whole data map can be treated as metadata
    
    if (type != null) {
      handleTypeRedirection(type, metadata);
    }
  }

  void handleTypeRedirection(String type, dynamic metadata) {
    log('🧭 Redirecting for type: $type');
    
    try {
      switch (type) {
        case 'wallet_transaction':
          MyAppRoute.router.push(AppRoutes.allEarnings);
          break;
        case 'withdrawal_request':
        case 'withdrawal_process':
          MyAppRoute.router.push(AppRoutes.withdrawalHistory);
          break;
        case 'settlement_process':
        case 'settlement_create':
          MyAppRoute.router.push(AppRoutes.earnings);
          break;
        case 'order_ready_for_pickup':
        case 'delivery':
          // FeedPage available orders tab
          MyAppRoute.router.push('${AppRoutes.feed}?tab=0');
          break;
        case 'return_order_available':
        case 'return_order':
          // FeedPage return orders tab
          MyAppRoute.router.push('${AppRoutes.feed}?tab=2');
          break;
        case 'order_update':
          if (metadata != null && metadata['order_id'] != null) {
             MyAppRoute.router.push(AppRoutes.orderDetails, extra: {
              'orderId': int.parse(metadata['order_id'].toString()),
              'from': true,
            });
          }
          break;
        default:
          log('⚠️ Unknown notification type: $type');
          // Default to notifications list if type is unknown but tapped
          MyAppRoute.router.push(AppRoutes.notifications);
      }
    } catch (e) {
      log('❌ Redirection error: $e');
    }
  }

  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
      log('✅ FCM token deleted');
    } catch (e) {
      log('❌ Error deleting token: $e');
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('📨 Background message received: ${message.messageId}');
  log('Title: ${message.notification?.title}');
  log('Body: ${message.notification?.body}');
  log('Data: ${message.data}');
}
