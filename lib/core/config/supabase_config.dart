/// Cấu hình kết nối Supabase, dùng cho Phase 11 (đồng bộ ghi chú giao dịch).
///
/// [anonKey] là "anon/public" key — được Supabase thiết kế để nhúng an toàn
/// trong client app (không phải bí mật như `service_role` key). Quyền truy
/// cập thật sự được kiểm soát bằng Row Level Security ở phía Supabase (xem
/// supabase/schema.sql), không phải bằng việc giấu key này.
///
/// Bảng `transaction_notes` (xem supabase/schema.sql) CHỈ chứa note do người
/// dùng tự gõ + số tiền/loại/thời gian để nhận diện giao dịch khi xem qua
/// Supabase Table Editor — KHÔNG chứa số tài khoản hay nội dung notification
/// gốc, đúng nguyên tắc local-only cho dữ liệu ngân hàng.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://mqsirzhefygysvayubax.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1xc2lyemhlZnlneXN2YXl1YmF4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYzNDUyMzUsImV4cCI6MjEwMTkyMTIzNX0.o-kT7FOTRyLM3ZoVSiZEB3CD_D71HWN5L9Rzxs6Z7SA';

  static const String notesTable = 'transaction_notes';
}
