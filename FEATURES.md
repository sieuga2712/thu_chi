# Tổng kết tính năng — Thu Chi

Ứng dụng quản lý thu chi cá nhân, tự động đọc thông báo biến động số dư từ **VietinBank iPay**, lưu 100% local trên máy. Không đăng nhập ngân hàng, không gửi dữ liệu giao dịch lên server.

## 1. Bắt giao dịch tự động

- Đọc thông báo VietinBank iPay ngay khi thông báo hiện ra trên máy, qua Android `NotificationListenerService` — chạy độc lập với việc app đang mở hay đã tắt (chỉ cần đã cấp quyền Notification Access và chưa bị "Buộc dừng"/force-stop).
- Phân tích tự động thành giao dịch có cấu trúc: loại (tiền vào/tiền ra), số tiền, tài khoản, nội dung, số dư sau giao dịch, mã giao dịch, thời gian — dựa trên tập regex có thể mở rộng khi ngân hàng đổi định dạng thông báo.
- Xóa thông báo khỏi thanh thông báo **không** ảnh hưởng đến giao dịch đã bắt — dữ liệu được lưu ngay tại thời điểm thông báo hiện ra.
- Có hàng đợi bền vững phía native: nếu thông báo đến lúc app chưa mở, dữ liệu vẫn được giữ lại và app đọc nốt vào lần mở tiếp theo.
- Nút **"Quét lại thông báo đang hiển thị"** (Cài đặt): quét các thông báo VietinBank hiện vẫn còn trên thanh thông báo — hữu ích khi vừa cấp quyền hoặc lỡ mất một giao dịch nào đó.

## 2. Chống trùng giao dịch

- Mỗi giao dịch có một "dấu vân tay" (fingerprint SHA-256) tính từ tài khoản + số tiền + thời gian + nội dung + số dư.
- Unique index ở tầng SQLite tự động bỏ qua giao dịch trùng khi insert — áp dụng đồng nhất cho **mọi nguồn** thêm giao dịch (bắt tự động, quét lại thông báo, nhập CSV, thêm thủ công).

## 3. Thêm giao dịch thủ công

- Màn hình riêng (nút **+** ở góc màn hình Giao dịch): dán nguyên văn nội dung thông báo ngân hàng (ví dụ copy được từ thông báo đã lỡ xóa), dùng cho trường hợp không bắt tự động được.
- Dùng lại đúng bộ phân tích của luồng tự động — cùng định dạng thì ra cùng kết quả.
- Hiển thị bản xem trước (số tiền, loại, thời gian, nội dung, tài khoản, số dư) trước khi xác nhận thêm — có thể sửa lại nếu đọc sai.
- Tự động chống trùng: nếu nội dung dán vào trùng với giao dịch đã có (kể cả đã bắt tự động trước đó), app báo rõ và không thêm lại.
- Giao dịch nhập thủ công được đánh dấu nguồn "Nhập thủ công" ở màn hình chi tiết.

## 4. Nhóm chi tiêu (category)

- Gán nhãn nhóm chi tiêu cho từng giao dịch ở màn hình chi tiết (ví dụ: Ăn uống, Ăn vặt, Đồ thiết yếu, Xăng xe, Hóa đơn, Mua sắm, Sức khỏe, Giải trí...).
- Nhập tự do — không giới hạn trong danh sách có sẵn, kèm chip gợi ý (danh sách preset + các nhóm đã từng dùng) để chọn nhanh bằng một chạm.
- Hiển thị ngay trên danh sách giao dịch (cạnh ngày giờ) để dễ nhận diện.
- Chỉ lưu local, không đồng bộ Supabase.

## 5. Ghi chú giao dịch + đồng bộ đa thiết bị

- Ghi chú tự do cho từng giao dịch (ví dụ diễn giải nội dung thông báo cryptic).
- Đồng bộ **chỉ** ghi chú + số tiền/loại/thời gian lên Supabase (tài khoản của người dùng) — **không bao giờ** gửi số tài khoản hay nội dung thông báo gốc.
- Xem/sửa ghi chú từ máy tính trực tiếp qua Supabase Table Editor, không cần web app riêng.
- Nút "Đồng bộ ghi chú từ Supabase" (Cài đặt) để kéo ghi chú đã sửa từ nơi khác về máy.
- Nếu đồng bộ thất bại (mất mạng...), ghi chú vẫn được lưu local an toàn, đồng bộ lại sau.

## 6. Dashboard

- Tổng quan thu/chi theo khoảng thời gian, biểu đồ trực quan (fl_chart).
- Danh sách giao dịch gần đây.

## 7. Danh sách & chi tiết giao dịch

- Tìm kiếm theo nội dung, lọc theo loại (tiền vào/tiền ra).
- Chi tiết đầy đủ một giao dịch: số tiền, thời gian, tài khoản, số dư sau giao dịch, mã giao dịch, nội dung gốc, nhóm chi tiêu, ghi chú.
- Xóa từng giao dịch (có xác nhận).

## 8. Cài đặt

- Trạng thái + cấp quyền Notification Access.
- Gửi thông báo thử nghiệm (kiểm tra pipeline bắt/parse hoạt động đúng).
- Quét lại thông báo đang hiển thị (mục 1).
- Xuất/nhập dữ liệu qua file CSV — nhập CSV báo rõ số giao dịch mới thêm và số bị bỏ qua vì trùng.
- Xóa toàn bộ dữ liệu (có xác nhận).
- Đồng bộ ghi chú từ Supabase (mục 5).
- Giới thiệu app.

## 9. Riêng tư & bảo mật

- Không đăng nhập VietinBank, không gọi API ngân hàng, không lưu username/password/OTP.
- Toàn bộ dữ liệu giao dịch (số tài khoản, nội dung, số dư...) chỉ lưu local trong SQLite trên máy — không rời khỏi thiết bị.
- Phần duy nhất rời khỏi máy là ghi chú cá nhân + số tiền/loại/thời gian, do người dùng chủ động đồng bộ lên Supabase của chính họ.
- Hoạt động offline hoàn toàn (trừ lúc chủ động đồng bộ ghi chú).
