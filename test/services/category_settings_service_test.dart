import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thu_chi/services/category_settings_service.dart';

void main() {
  late CategorySettingsService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    service = CategorySettingsService(prefs);
  });

  test('chưa ẩn tag nào thì danh sách rỗng', () {
    expect(service.getHiddenCategories(), isEmpty);
  });

  test('hideCategory thêm đúng tag vào danh sách ẩn', () async {
    await service.hideCategory('Giải trí');

    expect(service.getHiddenCategories(), {'Giải trí'});
  });

  test('ẩn nhiều tag, không trùng lặp khi ẩn lại cùng một tag', () async {
    await service.hideCategory('Giải trí');
    await service.hideCategory('Ăn vặt');
    await service.hideCategory('Giải trí');

    expect(service.getHiddenCategories(), {'Giải trí', 'Ăn vặt'});
  });

  test('danh sách ẩn được giữ lại giữa các instance dùng chung SharedPreferences', () async {
    await service.hideCategory('Xăng xe');

    final prefs = await SharedPreferences.getInstance();
    final anotherInstance = CategorySettingsService(prefs);

    expect(anotherInstance.getHiddenCategories(), {'Xăng xe'});
  });
}
