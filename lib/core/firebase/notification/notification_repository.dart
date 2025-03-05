import 'notification_data_source.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationRepository {
  final NotificationDataSource _dataSource;

  NotificationRepository(this._dataSource);

  Future<String?> fetchFCMToken() async {
    return await _dataSource.getFCMToken();
  }

  void listenToMessages(Function(RemoteMessage) onMessage) {
    _dataSource.onMessageListener(onMessage);
  }
}
