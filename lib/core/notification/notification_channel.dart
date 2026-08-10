import 'package:flutter/services.dart';

import '../constants/channel_constants.dart';

/// Instance MethodChannel/EventChannel dùng chung, tên phải khớp tuyệt đối
/// với hằng số khai báo ở `NotificationConfig.kt` bên native.
class NotificationChannels {
  NotificationChannels._();

  static const MethodChannel method = MethodChannel(ChannelConstants.methodChannel);
  static const EventChannel event = EventChannel(ChannelConstants.eventChannel);
}
