# REPORT

## Thông tin cá nhân

- **Họ và tên:** Nguyễn Ngọc Hiếu
- **Mã số:** 2A202600187

## Bước 1 

### Xác định và giải thích bộ siêu tham số tốt nhất

- **n_estimators:** 400
- **max_depth:** 25
- **min_samples_split:** 2

**Lý do:** Đây là bộ tham số mang lại Accuracy cao nhất (0.7540) sau khi đã huấn luyện trên toàn bộ tập dữ liệu (bao gồm cả dữ liệu bổ sung ở Bước 3). Việc tăng `n_estimators` giúp mô hình ổn định hơn và `max_depth` lớn cho phép mô hình học được các quan hệ phức tạp trong dữ liệu Wine Quality.

## Bước 2 & 3

### Kết quả pipeline

- **Accuracy (Bước 2 - 2998 mẫu):** 0.6440
- **Accuracy (Bước 3 - 5996 mẫu):** 0.7540
- **Trạng thái CI/CD:** Tất cả các job (Test, Train, Eval, Deploy) đều chạy thành công trên GitHub Actions.
- **Serving:** Endpoint `/predict` hoạt động chính xác trên VM.

### Khó khăn và cách giải quyết

1. **Lỗi xác thực DVC:** Ban đầu gặp lỗi khi `dvc pull` trong GitHub Actions do chưa cấu hình đúng `GOOGLE_APPLICATION_CREDENTIALS`. Đã giải quyết bằng cách ghi secret vào file tạm `/tmp/sa-key.json` và set biến môi trường.
2. **Ngưỡng Accuracy:** Ở Bước 2, accuracy chỉ đạt 0.64, thấp hơn ngưỡng 0.70 nên job Deploy bị chặn. Đây là hành vi đúng như thiết kế của Eval gate. Sau khi thêm dữ liệu ở Bước 3, accuracy đã vượt ngưỡng và mô hình được deploy tự động.
