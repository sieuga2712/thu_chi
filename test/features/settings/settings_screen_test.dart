import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/core/database/app_database.dart';
import 'package:thu_chi/features/settings/presentation/screens/settings_screen.dart';
import 'package:thu_chi/models/transaction.dart';
import 'package:thu_chi/models/transaction_type.dart';
import 'package:thu_chi/providers/database_providers.dart';
import 'package:thu_chi/providers/notification_providers.dart';
import 'package:thu_chi/providers/supabase_providers.dart';
import 'package:thu_chi/repositories/drift_transaction_repository.dart';

import '../../helpers/fake_native_notification_service.dart';
import '../../helpers/fake_note_sync_service.dart';

void main() {
  late AppDatabase db;
  late FakeNativeNotificationService fakeService;
  late FakeNoteSyncService fakeNoteSync;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fakeService = FakeNativeNotificationService();
    fakeNoteSync = FakeNoteSyncService();
  });

  tearDown(() async => db.close());

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        nativeNotificationServiceProvider.overrideWithValue(fakeService),
        noteSyncServiceProvider.overrideWithValue(fakeNoteSync),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    );
  }

  testWidgets('chưa cấp quyền hiển thị cảnh báo + nút Cấp quyền', (tester) async {
    fakeService.grantedOverride = false;

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Chưa cấp quyền đọc thông báo'), findsOneWidget);
    expect(find.text('Cấp quyền'), findsOneWidget);

    await tester.tap(find.text('Cấp quyền'));
    await tester.pumpAndSettle();

    expect(fakeService.openSettingsCallCount, 1);
  });

  testWidgets('đã cấp quyền hiển thị trạng thái đang theo dõi', (tester) async {
    fakeService.grantedOverride = true;

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Đang theo dõi thông báo'), findsOneWidget);
    expect(find.text('Chưa cấp quyền đọc thông báo'), findsNothing);
  });

  testWidgets('bấm gửi thông báo thử nghiệm gọi đúng vào native service', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gửi thông báo thử nghiệm'));
    await tester.pumpAndSettle();

    expect(fakeService.sendTestNotificationCallCount, 1);
    expect(find.textContaining('Đã gửi thông báo thử nghiệm'), findsOneWidget);
  });

  testWidgets('xóa toàn bộ dữ liệu xóa sạch DB sau khi xác nhận', (tester) async {
    final repo = DriftTransactionRepository(db);
    await repo.insert(
      Transaction(
        type: TransactionType.income,
        amount: 1000,
        currency: 'VND',
        description: 'test',
        transactionTime: DateTime(2026, 1, 1),
        rawNotification: 'raw',
        sourcePackage: 'com.vietinbank.ipay',
      ),
    );
    expect(await repo.getTransactions(), hasLength(1));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Cuộn hẳn xuống đáy danh sách để tile chắc chắn nằm giữa khung hình
    // (không chỉ vừa lọt vào rìa), tránh flaky khi tap ngay sau khi cuộn.
    await tester.fling(find.byType(ListView), const Offset(0, -2000), 3000);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Xóa toàn bộ dữ liệu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa tất cả'));
    await tester.pumpAndSettle();

    expect(await repo.getTransactions(), isEmpty);
    expect(find.text('Đã xóa toàn bộ dữ liệu'), findsOneWidget);
  });

  testWidgets('bấm quét lại thông báo đang hiển thị khi đã cấp quyền', (tester) async {
    fakeService.rescanResult = true;

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quét lại thông báo đang hiển thị'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(fakeService.rescanCallCount, 1);
    expect(find.textContaining('Đã quét xong'), findsOneWidget);
  });

  testWidgets('bấm quét lại thông báo khi chưa cấp quyền báo lỗi rõ ràng', (tester) async {
    fakeService.rescanResult = false;

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quét lại thông báo đang hiển thị'));
    await tester.pumpAndSettle();

    expect(fakeService.rescanCallCount, 1);
    expect(find.textContaining('không quét được'), findsOneWidget);
  });

  testWidgets('bấm đồng bộ ghi chú thành công báo đúng số lượng đã cập nhật', (tester) async {
    fakeNoteSync.pullResult = 3;

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Đồng bộ ghi chú từ Supabase'));
    await tester.pumpAndSettle();

    expect(fakeNoteSync.pullCallCount, 1);
    expect(find.textContaining('Đã cập nhật 3 ghi chú'), findsOneWidget);
  });

  testWidgets('bấm đồng bộ ghi chú khi không có gì mới báo rõ ràng', (tester) async {
    fakeNoteSync.pullResult = 0;

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Đồng bộ ghi chú từ Supabase'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Không có ghi chú nào mới'), findsOneWidget);
  });

  testWidgets('bấm đồng bộ ghi chú khi lỗi mạng báo lỗi rõ ràng, không crash', (tester) async {
    fakeNoteSync.pullError = Exception('network error');

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Đồng bộ ghi chú từ Supabase'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Đồng bộ thất bại'), findsOneWidget);
  });

  testWidgets('mở dialog giới thiệu app', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Mục "Giới thiệu" nằm cuối danh sách, cần cuộn hẳn xuống đáy vì
    // ListView chỉ build các item đang hiển thị trong khung hình test.
    await tester.fling(find.byType(ListView), const Offset(0, -2000), 3000);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Giới thiệu'));
    await tester.pumpAndSettle();

    expect(find.textContaining('không gửi bất kỳ dữ liệu giao dịch nào lên server'), findsOneWidget);
  });
}
