import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<NotificationModel>> getNotificationsForUser(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> createNotification(NotificationModel notification);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;

  NotificationRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<NotificationModel>> getNotificationsForUser(String userId) {
    return firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final notifications = snapshot.docs
              .map((doc) => NotificationModel.fromSnapshot(doc))
              .toList();
          // Sort locally to avoid needing a Firestore composite index
          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return notifications;
        });
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw ServerException(message: 'Failed to mark notification as read');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = firestore.batch();
      final snapshots = await firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in snapshots.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw ServerException(
        message: 'Failed to mark all notifications as read',
      );
    }
  }

  @override
  Future<void> createNotification(NotificationModel notification) async {
    try {
      final docRef = firestore.collection('notifications').doc();
      final modelWithId = notification.copyWith(id: docRef.id);
      await docRef.set(modelWithId.toJson());
    } catch (e) {
      throw ServerException(message: 'Failed to create notification');
    }
  }
}
