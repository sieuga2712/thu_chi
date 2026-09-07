# Tổng kết tính năng — Thu Chi

Ứng dụng quản lý thu chi cá nhân, tự động đọc thông báo biến động số dư từ **VietinBank iPay**, lưu 100% local trên máy. Không đăng nhập ngân hàng, không gửi dữ liệu giao dịch lên server.

**Giao diện:** phong cách pixel/RPG retro (kiểu GBA) áp dụng toàn app — font VT323 (đã kiểm tra hỗ trợ đầy đủ dấu tiếng Việt) cho AppBar/bottom nav/nút bấm/chip/nhãn input, viền dày sắc cạnh thay bo góc mềm. Số tiền, số dư, nội dung giao dịch **cố tình giữ font mặc định** để không ảnh hưởng độ dễ đọc số liệu tài chính.

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
- Quản lý tag (Cài đặt → Giao dịch → Quản lý nhóm chi tiêu): xem toàn bộ tag đang có, xóa tag không cần nữa — xóa sẽ gỡ tag khỏi mọi giao dịch đang dùng và ẩn vĩnh viễn khỏi gợi ý sau này.

## 5. Ghi chú giao dịch + đồng bộ đa thiết bị

- Ghi chú tự do cho từng giao dịch (ví dụ diễn giải nội dung thông báo cryptic).
- Đồng bộ **chỉ** ghi chú + số tiền/loại/thời gian lên Supabase (tài khoản của người dùng) — **không bao giờ** gửi số tài khoản hay nội dung thông báo gốc.
- Xem/sửa ghi chú từ máy tính trực tiếp qua Supabase Table Editor, không cần web app riêng.
- Nút "Đồng bộ ghi chú từ Supabase" (Cài đặt) để kéo ghi chú đã sửa từ nơi khác về máy.
- Nếu đồng bộ thất bại (mất mạng...), ghi chú vẫn được lưu local an toàn, đồng bộ lại sau.

## 5b. Ngân sách

- Đặt 1 hạn mức chi tiêu tổng theo **Ngày / Tuần / Tháng** (vào từ Cài đặt → Giao dịch → Ngân sách). Mặc định gợi ý: kỳ Ngày, 200.000đ.
- Tiến trình (progress bar + đã chi/hạn mức/còn lại hoặc đã vượt) luôn tính trực tiếp từ giao dịch chi tiêu trong kỳ hiện tại — không lưu trạng thái riêng, tự "sang kỳ mới" khi ngày thay đổi.
- Sửa hoặc xóa ngân sách bất kỳ lúc nào.

## 5c. Hoạt động (checkbox / thói quen)

- Tab riêng (thanh điều hướng dưới) — chỉ còn hoạt động kiểu **tick xong trong ngày** (hoạt động **tính giờ** đã chuyển sang tab Thành tựu, xem mục 5d). Mỗi hoạt động có icon (chọn từ bộ icon Material có sẵn, khoảng 16 icon phổ biến) + tên + tần suất mục tiêu **Hằng ngày** (tick tự do) hoặc **Theo tuần** (nhập số buổi cần đạt, ví dụ 4 buổi/tuần, tick ngày nào trong tuần cũng được).
- Danh sách hoạt động luôn hiện ở đầu trang — bấm cả dòng để tick/bỏ tick ngay cho hôm nay, cập nhật tức thì (không cần tải lại). Hoạt động Theo tuần hiện thêm dòng tiến độ "X/Y buổi tuần này".
- Nút lịch trên AppBar cho chọn **hôm nay hoặc 1 ngày trong quá khứ** (không cho chọn tương lai) để tick bù/sửa lại — chọn xong hiện banner "Đang tích cho ngày dd/MM/yyyy" + nút "Về hôm nay". Tick cho **hôm nay** thì tự do như bình thường; tick cho **ngày quá khứ** luôn có hộp thoại xác nhận trước khi lưu.
- Xem theo **Tuần / Tháng** (chuyển bằng nút chọn ngay dưới danh sách; không còn view "Ngày" riêng vì danh sách ở đầu trang đã là "hôm nay"):
  - Tuần: lưới 7 dòng (Thứ 2 → Chủ nhật), mỗi dòng hiện icon các hoạt động đã tick hôm đó — lướt qua/lại tuần khác bằng nút ◀ ▶, có nút "Về tuần này" khi đang xem tuần khác.
  - Tháng: giữ nguyên giao diện lưới nhiệt kiểu GitHub contribution (đậm nhạt theo số hoạt động đã tick mỗi ngày).
- Lưu trữ tạm bằng SharedPreferences (JSON, tái dùng cơ chế session của hoạt động tính giờ — mỗi lần tick là 1 "session" thời lượng 0) — xem mục 10.

## 5d. Thành tựu (hoạt động tính giờ)

- Tab riêng — nơi sống của hoạt động **tính giờ** kiểu "Đọc sách" (tự định nghĩa tên, lĩnh vực Sức khỏe/Học tập/Công việc/Sinh hoạt, kiểu đồng hồ đếm lên tự do hoặc đếm ngược cố định, chế độ giám sát Thoải mái/Nghiêm ngặt) — coi là hoạt động "tích lũy dần" theo thời gian.
- Section "Đang theo dõi" ở đầu trang: bấm Bắt đầu/Dừng ngay trên từng hoạt động — chỉ 1 đồng hồ chạy tại một thời điểm (hoạt động khác tự khóa nút Bắt đầu khi có cái đang chạy). Chế độ Nghiêm ngặt: rời app trong lúc đồng hồ chạy tự ghi lại thành đoạn "sao nhãng" (không trừ điểm, chỉ hiển thị để tự xem lại). *Bản hiện tại dùng vòng đời app của Flutter nên chưa phân biệt được "khóa màn hình" (không nên tính) và "chuyển sang app khác" (nên tính) — cả hai đều tính là sao nhãng; cần thêm code native Android để tinh chỉnh, chưa làm.* Đếm ngược cố định tự dừng và lưu phiên khi hết giờ.
- Xóa hoạt động (có xác nhận) ngay trên từng card — chỉ xóa được khi hoạt động đó **không** đang chạy (phải bấm Dừng trước).
- Bên dưới: streak tổng hiện tại + streak dài nhất (tính từ ngày có ≥1 hoạt động tính giờ, không tách riêng theo từng hoạt động — check-in của hoạt động checkbox ở tab Hoạt động **không** tính vào đây), tổng số ngày có hoạt động (toàn thời gian), tổng thời gian mỗi hoạt động trong **tháng này**.
- *Chưa có: huy hiệu mốc lớn (ngưỡng chưa chốt), số tuần "hoàn thành đủ" (định nghĩa chưa chốt) — xem mục 10.*

## 6. Dashboard

- Tổng quan thu/chi theo khoảng thời gian (4 ô Tiền vào/Tiền ra/Chênh lệch/Số giao dịch).
- Card "Hoạt động hôm nay": streak thói quen (dựa trên hoạt động checkbox), "X/Y hoạt động hôm nay", nút "Tick nhanh: ..." cho hoạt động Hằng ngày đầu tiên chưa tick (bấm là tick luôn tại chỗ, không điều hướng đi đâu). Bấm vào card chuyển sang tab Hoạt động.
- Card "Thành tựu nổi bật": streak dài nhất + tổng số ngày có hoạt động — chỉ tính hoạt động **tính giờ** (không lẫn check-in checkbox). Bấm vào card chuyển sang tab Thành tựu.
- *Danh sách giao dịch gần đây: tạm ẩn (widget `RecentTransactionsSection` vẫn còn trong code, chỉ không render ở `DashboardScreen`).*

## 7. Danh sách & chi tiết giao dịch

- Tìm kiếm theo nội dung, lọc theo loại (tiền vào/tiền ra).
- Danh sách gom theo **Ngày / Tuần / Tháng** (chuyển bằng nút chọn ngay dưới bộ lọc, giống cách chọn ở tab Hoạt động) — mỗi dòng hiện tổng tiền vào/tiền ra + số giao dịch trong khoảng đó, mới nhất trước. Bấm vào 1 dòng mở màn hình riêng liệt kê đầy đủ giao dịch trong khoảng đó (tự cập nhật ngay khi sửa/xóa giao dịch bên trong).
- Chi tiết đầy đủ một giao dịch: số tiền, thời gian, tài khoản, số dư sau giao dịch, mã giao dịch, nội dung gốc, nhóm chi tiêu, ghi chú.
- Xóa từng giao dịch (có xác nhận).

## 8. Cài đặt

- Trạng thái + cấp quyền Notification Access.
- Gửi thông báo thử nghiệm (kiểm tra pipeline bắt/parse hoạt động đúng).
- Quét lại thông báo đang hiển thị (mục 1).
- Quản lý nhóm chi tiêu — xóa tag (mục 4).
- Xuất/nhập dữ liệu qua file CSV — nhập CSV báo rõ số giao dịch mới thêm và số bị bỏ qua vì trùng.
- Xóa toàn bộ dữ liệu (có xác nhận).
- Đồng bộ ghi chú từ Supabase (mục 5).
- Giới thiệu app.

## 9. Riêng tư & bảo mật

- Không đăng nhập VietinBank, không gọi API ngân hàng, không lưu username/password/OTP.
- Toàn bộ dữ liệu giao dịch (số tài khoản, nội dung, số dư...) chỉ lưu local trong SQLite trên máy — không rời khỏi thiết bị.
- Phần duy nhất rời khỏi máy là ghi chú cá nhân + số tiền/loại/thời gian, do người dùng chủ động đồng bộ lên Supabase của chính họ.
- Hoạt động offline hoàn toàn (trừ lúc chủ động đồng bộ ghi chú).

---

## 10. Quản lý đời sống — phần còn lại (CHƯA code)

Mục "Hoạt động" (checkbox/thói quen, xem theo Tuần/Tháng), "Thành tựu" (hoạt động tính giờ + streak + thống kê thời gian), và Tổng quan mở rộng (card Hoạt động hôm nay + Thành tựu nổi bật) đã xong — xem mục 5c, 5d, 6. Bottom nav hiện đã đủ 5 tab: Tổng quan / Giao dịch / Hoạt động / Thành tựu / Cài đặt. Còn lại theo thiết kế gốc:

1. **Huy hiệu mốc lớn** ở Thành tựu (ngưỡng cụ thể chưa chốt), số tuần "hoàn thành đủ" *(định nghĩa đề xuất: mỗi ngày trong tuần có ≥1 hoạt động — chưa chốt)*.
2. **Phân biệt khóa màn hình vs chuyển app** ở chế độ Nghiêm ngặt — cần thêm code native Android theo dõi sự kiện màn hình sáng/tắt (hiện tại cả hai đều tính là sao nhãng, xem mục 5d).
3. Gộp tab Giao dịch + Hoạt động thành 1 tab (đã bàn tới lúc còn ở mức 4 tab để chừa chỗ — nay đã dùng hết 5 tab cho Thành tựu nên khó gộp thêm nếu không bỏ bớt tab khác; cần bàn lại nếu muốn làm).
4. Goal/Milestone/Task, Kế hoạch ngày, Timeline — các phần mở rộng lớn hơn, chưa thiết kế chi tiết.

### Còn bỏ ngỏ
1. Định nghĩa chính xác "tuần hoàn thành đủ".
2. Có tạo sẵn vài hoạt động mẫu khi mở tính năng lần đầu không.
3. Nhắc nhở hàng ngày (notification) — tạm gác lại làm sau.
4. Ngưỡng cụ thể cho huy hiệu thành tựu.
5. Cấu trúc Goal/Milestone/Task chi tiết.
