
# 🤖 ChatGPT Clone App

A pixel-perfect ChatGPT clone built with **Flutter**, using **BLoC + Repository architecture**, optimized for both **Android and iOS**. This template provides a complete foundation for building AI chat applications with modern Flutter development practices.

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Material Design](https://img.shields.io/badge/Material%20Design%203-757575?logo=material-design&logoColor=white)

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone <your-repo-url>
cd chatgpt_clone

# Install dependencies
flutter pub get

# Set up environment variables (see .env file)
cp .env.example .env

# Run the app
flutter run
```

---

## ✨ Features

### 🎯 **Implemented (Ready to Use)**
- ✅ **ChatGPT-style UI** - Pixel-perfect interface replication
- ✅ **Material Design 3** - Modern theming with light/dark modes
- ✅ **Message System** - Text messages with timestamps and avatars
- ✅ **Chat History** - List of conversations with navigation
- ✅ **Settings Page** - Theme selection, model configuration, data management
- ✅ **Responsive Design** - Works on all screen sizes
- ✅ **Clean Architecture** - Organized codebase with separation of concerns

### 🔄 **Template Ready (Need API Keys)**
- 🔧 **OpenAI Integration** - GPT API calls (service templates ready)
- 🔧 **Image Upload** - Cloudinary integration for media messages
- 🔧 **Data Persistence** - MongoDB backend + Hive local storage
- 🔧 **BLoC State Management** - Event-driven state management
- 🔧 **Error Handling** - Comprehensive error management with retry logic

---

## 📦 Tech Stack

| Layer             | Technology             | Status      |
|------------------|------------------------|-------------|
| **Frontend**     | Flutter 3.7.2+        | ✅ Ready    |
| **State Mgmt**   | BLoC Pattern          | 🔧 Template |
| **Dependency**   | Custom DI             | ✅ Ready    |
| **Networking**   | Dio HTTP Client       | 🔧 Template |
| **Local Storage**| Hive CE               | 🔧 Template |
| **Remote DB**    | MongoDB REST API      | 🔧 Template |
| **Media Upload** | Cloudinary            | 🔧 Template |
| **AI Engine**    | OpenAI GPT Models     | 🔧 Template |

---

## 🏗️ Project Structure

```
lib/
├── 📱 main.dart                        # App entry point
├── 🎨 core/                           # Core functionality
│   ├── constants/                     # App constants
│   ├── theme/                         # Material Design 3 themes
│   ├── utils/                         # Utilities & error handling
│   └── services/                      # API services (templates)
├── ⚙️ config/                         # Configuration
│   ├── injector.dart                  # Dependency injection
│   └── routes.dart                    # Navigation setup
└── 🚀 features/                       # Feature modules
    ├── shared/                        # Shared components
    │   ├── models/                    # Data models
    │   └── widgets/                   # Reusable widgets
    ├── home/                          # Chat list feature
    ├── chat/                          # Main chat interface
    └── settings/                      # App configuration
```

---

## 🎯 Getting Started

### 1. **Run the Demo App**
The app runs immediately with simulated responses:

```bash
flutter run
```

### 2. **Add Real AI Integration**
Configure your API keys in `.env`:

```env
OPENAI_API_KEY=your_openai_api_key
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_UPLOAD_PRESET=your_upload_preset
MONGO_API_URL=https://your-mongodb-api
```

### 3. **Enable Services**
Uncomment the service integrations in:
- `lib/core/services/openai_service.dart`
- `lib/core/services/cloudinary_service.dart`
- `lib/core/services/mongo_service.dart`

---

## 🎨 Screenshots & Demo

### Light & Dark Mode
The app includes beautiful Material Design 3 theming with automatic dark mode support.

### Chat Interface
- Message bubbles with proper styling
- Typing indicators
- Timestamp formatting
- Avatar integration
- Markdown support (ready to enable)

### Settings & Configuration
- Theme selection (Light/Dark/System)
- AI model selection (GPT-3.5, GPT-4)
- API key management
- Data export/import options

---

## 🔧 Development Phases

### 📦 Phase 1 – MVP Chat ✅
- [x] Basic chat UI and navigation
- [x] Message display system
- [x] Chat history management

### 🖼️ Phase 2 – Enhanced UI ✅
- [x] Material Design 3 theming
- [x] Image attachment UI
- [x] Settings page
- [x] Responsive design

### ⚙️ Phase 3 – Backend Integration 🔧
- [ ] Enable OpenAI API calls
- [ ] Add Cloudinary image uploads
- [ ] Connect MongoDB backend
- [ ] Implement Hive local storage

### 🔄 Phase 4 – Advanced Features 🔮
- [ ] BLoC state management
- [ ] User authentication
- [ ] Chat export/import
- [ ] Voice messages
- [ ] File attachments

---

## � Documentation

- 📖 **[Development Guide](DEVELOPMENT_GUIDE.md)** - Complete setup and architecture guide
- 🏗️ **[API Documentation](docs/api.md)** - Service integration details
- 🎨 **[UI Components](docs/components.md)** - Widget documentation
- 🧪 **[Testing Guide](docs/testing.md)** - Testing strategies

---

## � Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. 🍴 Fork the repository
2. 🌟 Create a feature branch
3. 💻 Make your changes
4. 🧪 Add tests
5. 📤 Submit a pull request

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🆘 Support & Community

- 🐛 **Issues**: [GitHub Issues](https://github.com/your-username/chatgpt_clone/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/your-username/chatgpt_clone/discussions)
- 📧 **Email**: support@yourproject.com

---

## 🎉 Acknowledgments

- 🤖 **OpenAI** for the amazing GPT models
- 💙 **Flutter Team** for the excellent framework
- 🌟 **Community** for the amazing packages and support

---

<div align="center">

**⭐ Star this repository if it helped you build something awesome! ⭐**

</div>

