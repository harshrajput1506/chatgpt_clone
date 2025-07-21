
# 🤖 ChatGPT Clone App

A pixel-perfect ChatGPT clone built with **Flutter**, using **BLoC + Repository architecture**, optimized for both **Android and iOS**. It uses **MongoDB** for backend chat history, **Hive CE** for **local offline caching**, and **Cloudinary** for image uploads. Powered by **OpenAI** or any LLM API.

---

## 🚀 Features

- ✅ ChatGPT-style interface (UI replicated)
- ✅ GPT-powered text responses
- ✅ Image message upload support via Cloudinary
- ✅ MongoDB backend for chat history
- ✅ Typing indicator, timestamp, retry, and regenerate logic
- ✅ BLoC + Repository (No usecases for reduced boilerplate)
- ✅ `Either<Left, Right>` for functional error handling
- ✅ Dependency Injection using GetIt

---

## 📦 Tech Stack

| Layer             | Technology             |
|------------------|------------------------|
| **Frontend**     | Flutter                |
| **State Mgmt**   | BLoC                   |
| **Dependency**   | get_it                 |
| **Networking**   | dio                    |
| **Error Handling**| dartz (`Either`)      |
| **Local Storage**| Hive CE                |
| **Remote DB**    | MongoDB (via REST or Realm) |
| **Media Upload** | Cloudinary             |
| **AI Engine**    | OpenAI (or custom)     |

---

## 🧱 Project Structure

```

lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── services/                   # GPT, Cloudinary, Mongo
│   └── utils/                      # Failures, formatters
│
├── config/
│   ├── routes.dart
│   └── injector.dart
│
├── features/
│   ├── chat/                       # Main chat screen + logic
│   ├── home/                       # Chat history list
│   ├── settings/                   # Theme, reset, API key
│   └── shared/                     # Shared widgets
│
└── .env                            # API keys and secrets

````

---

## 📦 Required Packages

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_bloc: ^8.1.3
  dio: ^5.4.0
  get_it: ^7.6.4
  dartz: ^0.10.1
  cloudinary_public: ^0.9.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  uuid: ^4.0.0
  path_provider: ^2.1.2
  flutter_dotenv: ^5.1.0
  flutter_markdown: ^0.6.14
  file_picker: ^6.1.1
  go_router: ^13.1.0
  equatable: ^2.0.5
````

---

## 🔐 .env Setup

```env
MONGO_API_URL=https://your-api.com
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_UPLOAD_PRESET=your_upload_preset
OPENAI_API_KEY=your_openai_api_key
```

Load with `flutter_dotenv` in `main.dart`.

---

## 💽 Local Storage (Offline Chat History)

Using **Hive CE** (added in Phase 4) for fast chat history read/write:

* `chat_<chatId>.box` stores messages per conversation.
* No need to wait for MongoDB to load for old messages.
* Auto-sync logic can be implemented in background.

### Example

```dart
await Hive.initFlutter();
Hive.registerAdapter(MessageModelAdapter());
final box = await Hive.openBox<MessageModel>('chat_$chatId');
await box.add(MessageModel(...));
final messages = box.values.toList();
```

---

## 🧩 App Phases

### 📦 Phase 1 – MVP (Core Chat)

* [x] Chat UI: Chat screen layout + message bubbles
* [x] Send user message
* [x] Receive GPT response
* [x] MongoDB integration for chat history

### 🖼️ Phase 2 – Media & Enhancements

* [x] Cloudinary image upload & preview
* [x] Markdown rendering (code blocks, bold, italic)
* [x] Typing indicator
* [ ] Regenerate response
* [ ] Retry failed message

### ⚙️ Phase 3 – Utility & Settings

* [x] Light/Dark mode toggle
* [ ] Model selector (GPT-3.5, GPT-4)
* [ ] API key input (user-based)
* [ ] Clear remote history

### 🔄 Phase 4 – Sync & Offline Mode

* [ ] Add Hive CE for local offline chat caching
* [ ] Auto-sync local ↔ remote messages
* [ ] User auth + session support
* [ ] Notifications

---

## 🧠 Error Handling

Use `dartz` for clean error flow:

```dart
final result = await chatRepo.sendMessage(...);
result.fold(
  (failure) => emit(ChatError(failure.message)),
  (success) => emit(ChatLoaded(success)),
);
```

---

## 🛠️ How to Run

```bash
flutter pub get
flutter run
```

Ensure you have:

* MongoDB and Cloudinary endpoints ready
* `.env` file properly configured

---

