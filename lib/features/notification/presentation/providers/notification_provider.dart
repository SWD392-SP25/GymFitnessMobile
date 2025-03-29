import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../core/firebase/notification/notification_data_source.dart';
import '../../../../core/firebase/notification/notification_repository.dart';
import '../../../../core/firebase/notification/notification_service.dart';

final notificationProvider = Provider<NotificationRepository>((ref) {
  final dataSource = NotificationDataSource();
  return NotificationRepository(dataSource);
});

final notificationListenerProvider = Provider<void>((ref) {
  final repository = ref.read(notificationProvider);
  repository.listenToMessages((message) {
    NotificationService.showNotification(message);
  });
});
