-- Bảng lưu ghi chú giao dịch để đồng bộ giữa các thiết bị (Phase 11).
--
-- QUAN TRỌNG VỀ PRIVACY: bảng này CHỈ chứa note do người dùng tự gõ + vài
-- metadata không nhạy cảm để nhận diện giao dịch khi xem trên Table Editor
-- (số tiền, loại, thời gian). KHÔNG chứa số tài khoản, nội dung notification
-- gốc, hay bất kỳ dữ liệu ngân hàng nào khác — đúng theo nguyên tắc local-only
-- cho dữ liệu ngân hàng đã thống nhất khi thêm phase này.
create table if not exists transaction_notes (
  id uuid primary key default gen_random_uuid(),

  -- Khóa khớp với Transaction.fingerprint ở app (SHA-256 từ
  -- account+amount+time+description+balance) — KHÔNG suy ngược lại được số
  -- tài khoản gốc, chỉ dùng để đối chiếu đúng giao dịch giữa các thiết bị.
  fingerprint text not null unique,

  note text not null default '',

  -- Metadata hiển thị, để nhận ra giao dịch nào khi sửa trực tiếp qua Table
  -- Editor mà không cần mở app tra cứu chéo.
  amount bigint not null,
  transaction_type text not null check (transaction_type in ('income', 'expense')),
  transaction_time timestamptz not null,

  updated_at timestamptz not null default now()
);

-- Tự động cập nhật updated_at mỗi khi note thay đổi.
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_transaction_notes_updated_at on transaction_notes;
create trigger trg_transaction_notes_updated_at
  before update on transaction_notes
  for each row
  execute function set_updated_at();

-- RLS bật kèm policy cho phép đầy đủ qua anon key — vì đây là app cá nhân
-- một người dùng, không có hệ thống đăng nhập. Nếu sau này chia sẻ project
-- Supabase cho nhiều người dùng khác nhau, cần thêm cột user_id + Supabase
-- Auth và thắt chặt lại policy này.
alter table transaction_notes enable row level security;

drop policy if exists "Allow anon full access" on transaction_notes;
create policy "Allow anon full access"
  on transaction_notes
  for all
  to anon
  using (true)
  with check (true);
