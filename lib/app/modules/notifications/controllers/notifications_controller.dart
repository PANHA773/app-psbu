import 'package:get/get.dart';
import '../../../data/services/notification_service.dart';

class NotificationsController extends GetxController {
  var isLoading = true.obs;
  var notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  void fetchNotifications() async {
    try {
      isLoading(true);
      var fetchedNotifications = await NotificationService.getNotifications();
      // Sort by date, newest first
      fetchedNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifications.assignAll(fetchedNotifications);
    } finally {
      isLoading(false);
    }
  }

  void markNotificationAsRead(String notificationId) async {
    try {
      await NotificationService.markAsRead(notificationId);
      int index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !notifications[index].isRead) {
        // Create a new instance with updated isRead status
        var old = notifications[index];
        notifications[index] = NotificationModel(
          id: old.id,
          recipient: old.recipient,
          sender: old.sender,
          type: old.type,
          link: old.link,
          isRead: true, // The only change
          message: old.message,
          createdAt: old.createdAt,
          updatedAt: DateTime.now(), // Assume client time for update
        );
        notifications.refresh();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark notification as read.');
    }
  }

  void markAllAsRead() async {
    try {
      isLoading(true);
      // Inefficient for a large number of notifications, but works without a dedicated API endpoint.
      for (var notification in notifications) {
        if (!notification.isRead) {
          await NotificationService.markAsRead(notification.id);
        }
      }
      fetchNotifications(); // Refresh the entire list
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark all as read.');
    } finally {
      isLoading(false);
    }
  }

  void clearAll() {
    // Note: This is a client-side clear only.
    // TODO: Implement a service call to delete notifications on the server.
    notifications.clear();
    Get.snackbar('Success', 'All notifications cleared locally.');
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}
