# Social Wandura

Công cụ quản lý bài đăng mạng xã hội cho team: **Facebook, Instagram, X (Twitter), Discord, YouTube**, chạy local bằng Docker.
Nền tảng: [Postiz](https://github.com/gitroomhq/postiz-app), mã nguồn mở theo giấy phép AGPL-3.0.

## Tính năng

| Nhóm | Có gì |
|---|---|
| Soạn & đăng đa nền tảng | Viết một lần, đăng lên nhiều kênh, chỉnh nội dung riêng cho từng kênh, thư viện media |
| Lên lịch | Hẹn giờ đăng, lịch dạng ngày/tuần/tháng, kéo thả đổi lịch, đăng lặp lại |
| Thống kê | Lượt xem, tương tác theo từng kênh và từng bài |
| AI | Gợi ý caption, hashtag, tạo ảnh (cần `OPENAI_API_KEY`) |
| Làm việc nhóm | Mời thành viên, phân quyền, bình luận trên bài, xem trước trước khi đăng |

## Kiến trúc

```
Trình duyệt ──► postiz (web + API, cổng 4007)
                   ├── postiz-postgres  (dữ liệu bài đăng, người dùng)
                   ├── postiz-redis     (cache, hàng đợi)
                   └── temporal         (bộ máy hẹn giờ đăng bài)
                         ├── temporal-postgresql
                         ├── temporal-elasticsearch
                         └── temporal-ui (http://127.0.0.1:8080, theo dõi job)
```

## Chạy miễn phí trên GitHub Codespaces (không cần cài gì)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/tampttapero/social-Wandura?quickstart=1)

1. Bấm nút trên (hoặc **Code → Codespaces → Create codespace on main**).
2. Chờ 3–5 phút. Codespace tự tạo `.env`, khởi động Docker và mở tool ở tab mới. Nếu tab không tự mở: vào tab **PORTS**, bấm biểu tượng quả địa cầu ở cổng **4007**.
3. Đăng ký tài khoản đầu tiên (admin).
4. Điền API key vào file `.env` ngay trong Codespace, sau đó chạy:
   ```bash
   docker compose -f docker-compose.yaml -f docker-compose.codespaces.yaml up -d
   ```
5. Muốn đồng nghiệp truy cập: tab **PORTS** → chuột phải cổng 4007 → **Port Visibility → Public**, rồi gửi họ link. Tool vẫn có trang đăng nhập riêng.

Giới hạn của gói miễn phí:
- Mỗi tài khoản cá nhân có 120 core-giờ/tháng, tức khoảng **60 giờ chạy** với máy 2 nhân. Xem mức đã dùng tại github.com/settings/billing.
- Codespace **tự dừng sau 30 phút không dùng** (có thể tăng lên tối đa 4 giờ tại github.com/settings/codespaces). Khi Codespace dừng, **bài đã hẹn giờ sẽ không được đăng**. Dữ liệu vẫn được giữ, mở lại Codespace là tool chạy tiếp.
- Mỗi Codespace có địa chỉ riêng. Nếu xóa đi tạo lại, phải cập nhật lại Callback URL trong app Facebook/X/Google/Discord.

→ Codespaces phù hợp để dùng thử và soạn bài. Muốn hẹn giờ đăng 24/7 thì cần chạy trên máy luôn bật (Windows + WSL2 bên dưới) hoặc VPS.

## Cài đặt (Windows)

1. Cài Docker Desktop (cần WSL2), khởi động lại máy nếu được yêu cầu, rồi mở Docker Desktop:
   ```powershell
   winget install --id Docker.DockerDesktop -e --source winget
   ```
2. Clone repo và chạy:
   ```powershell
   git clone https://github.com/tampttapero/social-Wandura.git
   cd social-Wandura
   .\scripts\setup.ps1
   ```
   Script sẽ tạo `.env` với mật khẩu ngẫu nhiên, tải image, khởi động và mở `http://localhost:4007`.
3. Đăng ký tài khoản đầu tiên. Tài khoản này là chủ workspace (admin).
4. Mời đồng nghiệp: **Settings → Teams**. Khi đã mời đủ người, đặt `DISABLE_REGISTRATION=true` trong `.env` rồi chạy `docker compose up -d`.

> Máy cần khoảng 4 GB RAM trống cho Docker (Elasticsearch và Temporal khá nặng).

## Kết nối mạng xã hội

Mỗi nền tảng cần một "app" developer để lấy key. Điền key vào `.env`, sau đó chạy `docker compose up -d` để áp dụng.
Callback URL luôn có dạng: `{FRONTEND_URL}/integrations/social/<tên>`, ví dụ `http://localhost:4007/integrations/social/x`.

| Nền tảng | Tạo app tại | Biến trong `.env` | Callback |
|---|---|---|---|
| Facebook Page | developers.facebook.com → Create App (loại Business) | `FACEBOOK_APP_ID`, `FACEBOOK_APP_SECRET` | `/integrations/social/facebook` |
| Instagram Business | Cùng app Facebook ở trên, thêm sản phẩm Instagram Graph API; tài khoản IG phải là Business/Creator và liên kết với Page | (dùng chung key Facebook) | `/integrations/social/instagram` |
| Instagram (độc lập) | developers.facebook.com → Instagram API with Instagram Login | `INSTAGRAM_APP_ID`, `INSTAGRAM_APP_SECRET` | `/integrations/social/instagram-standalone` |
| X (Twitter) | developer.x.com → Project & App → bật OAuth 1.0a, quyền Read and Write | `X_API_KEY`, `X_API_SECRET` | `/integrations/social/x` |
| Discord | discord.com/developers/applications → OAuth2 + tạo Bot, mời bot vào server | `DISCORD_CLIENT_ID`, `DISCORD_CLIENT_SECRET`, `DISCORD_BOT_TOKEN_ID` | `/integrations/social/discord` |
| YouTube | console.cloud.google.com → bật YouTube Data API v3 → OAuth Client (Web) | `YOUTUBE_CLIENT_ID`, `YOUTUBE_CLIENT_SECRET` | `/integrations/social/youtube` |
| AI | platform.openai.com → API keys | `OPENAI_API_KEY` | — |

Lưu ý:
- **Facebook/Instagram**: ở chế độ Development, chỉ tài khoản có vai trò trong app mới kết nối được. Muốn dùng rộng rãi thì phải gửi App Review.
- **X**: gói API miễn phí giới hạn số bài đăng mỗi tháng; nếu đăng nhiều cần gói trả phí.
- **YouTube**: khi app Google còn ở trạng thái "Testing", hãy thêm email của team vào danh sách Test users.
- Chi tiết từng nền tảng: https://docs.postiz.com/self-host/providers/overview

## Quy trình làm việc của team (gợi ý)

1. **Biên tập viên** soạn bài, dùng AI gợi ý caption, chọn kênh và giờ đăng.
2. Lưu ở dạng **nháp/xem trước**, gửi link preview cho trưởng nhóm.
3. **Trưởng nhóm** bình luận trực tiếp trên bài rồi duyệt bằng cách lên lịch đăng.
4. Theo dõi kết quả ở mục **Analytics** và điều chỉnh lịch nội dung tuần sau.

> Postiz hiện chưa có bước "phê duyệt bắt buộc" riêng. Nếu team cần khóa không cho đăng khi chưa duyệt, hãy giới hạn quyền đăng cho trưởng nhóm, hoặc fork Postiz để bổ sung tính năng này.

## Vận hành

| Việc | Lệnh |
|---|---|
| Khởi động | `docker compose up -d` |
| Dừng | `docker compose down` |
| Xem log | `docker compose logs -f postiz` |
| Sao lưu DB | `.\scripts\backup.ps1` (lưu vào `backups\`) |
| Cập nhật | `.\scripts\update.ps1` (tự sao lưu trước) |

## Bảo mật

- Không commit `.env`: file này chứa mật khẩu và API key, đã được liệt kê trong `.gitignore`.
- Mặc định tool chỉ chạy trên `localhost`. Nếu muốn đưa lên server cho cả team truy cập, cần dùng HTTPS và đổi `MAIN_URL`, `FRONTEND_URL`, `NEXT_PUBLIC_BACKEND_URL`.

## Giấy phép

Repo này đóng gói Postiz theo **AGPL-3.0** (xem `LICENSE`). Nếu sửa mã nguồn Postiz rồi cung cấp cho người khác dùng qua mạng, bạn phải công bố mã nguồn đã sửa.
