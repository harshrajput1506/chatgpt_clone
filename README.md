
# 🤖 ChatGPT Clone

A feature-complete ChatGPT clone built with **Flutter** and **Node.js**, featuring a pixel-perfect UI, real-time chat functionality, and comprehensive backend API integration.

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?logo=node.js&logoColor=white)
![Express](https://img.shields.io/badge/Express-000000?logo=express&logoColor=white)
![Prisma](https://img.shields.io/badge/Prisma-2D3748?logo=prisma&logoColor=white)
![Material Design](https://img.shields.io/badge/Material%20Design%203-757575?logo=material-design&logoColor=white)

---

## 🚀 Quick Start

### Frontend (Flutter)
```bash
# Clone the repository
git clone https://github.com/harshrajput1506/chatgpt_clone.git
cd chatgpt_clone

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Backend (Node.js + Express)
```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your API keys and database URLs

# Run database migrations
npx prisma migrate dev

# Start the server
npm run dev                         
```

---

## ✨ Features

### 🎯 **Core Features (Fully Implemented)**
- ✅ **ChatGPT-style UI** - Pixel-perfect interface with smooth animations
- ✅ **Real-time Chat** - Live messaging with OpenAI GPT models
- ✅ **Multiple AI Models** - Support for GPT-4o, GPT-4.1, GPT-4o-mini
- ✅ **Chat Management** - Create, rename, delete, and search conversations
- ✅ **Image Support** - Upload and send images with Cloudinary integration
- ✅ **Message Features** - Copy, regenerate, and retry failed messages
- ✅ **Responsive Design** - Optimized for all screen sizes
- ✅ **Material Design 3** - Modern theming with adaptive colors

### �️ **Advanced Features**
- ✅ **BLoC State Management** - Reactive state management with flutter_bloc
- ✅ **Clean Architecture** - Domain-driven design with Repository pattern
- ✅ **Error Handling** - Comprehensive error management with retry logic
- ✅ **Local Storage** - Offline capabilities with SharedPreferences
- ✅ **File Management** - Image and file picker integration
- ✅ **Navigation** - Modern routing with go_router
- ✅ **Backend API** - Complete REST API with Prisma ORM

### 🎨 **UI/UX Features**
- ✅ **Sidebar Navigation** - Collapsible chat history drawer
- ✅ **Message Bubbles** - Styled message display with markdown support
- ✅ **Typing Indicators** - Real-time response and regeneration status
- ✅ **Search Functionality** - Search through chat history
- ✅ **Loading States** - Smooth loading animations and indicators
- ✅ **Options Menu** - Context menus for chat and message actions

---

## 📦 Tech Stack

### Frontend
| Component        | Technology             | Description                    |
|-----------------|-------------------------|--------------------------------|
| **Framework**   | Flutter 3.7.2+        | Cross-platform UI framework   |
| **Language**    | Dart                   | Programming language           |
| **State Mgmt**  | BLoC Pattern           | Reactive state management      |
| **Navigation**  | go_router              | Declarative routing            |
| **Networking**  | Dio HTTP Client        | HTTP requests and interceptors |
| **Storage**     | SharedPreferences      | Local data persistence         |
| **UI/UX**       | Material Design 3      | Modern design system           |
| **Icons**       | SVG Icons              | Scalable vector graphics       |

### Backend
| Component        | Technology             | Description                    |
|-----------------|-------------------------|--------------------------------|
| **Runtime**     | Node.js                | JavaScript runtime             |
| **Framework**   | Express.js             | Web application framework      |
| **Database**    | MongoDB + Prisma      | NoSQL database with ORM        |
| **AI API**      | OpenAI GPT Models      | Chat completion API            |
| **Media**       | Cloudinary             | Image upload and management    |

### Development
| Tool            | Purpose                | Status                         |
|-----------------|------------------------|--------------------------------|
| **Dependencies**| get_it                 | ✅ Dependency injection       |
| **Utils**       | uuid, logger           | ✅ Utilities and logging      |
| **Media**       | image_picker           | ✅ Image selection from camera/gallery |
| **Permissions**| permission_handler     | ✅ Device permissions         |

---

## 🏗️ Project Structure

### Frontend Architecture
```
lib/
├── 📱 main.dart                         # App entry point with BLoC providers
├── 🔧 config/                          # App configuration
│   ├── injector.dart                    # Dependency injection setup
│   └── routes.dart                      # Navigation routes
├── 🎨 core/                            # Core functionality
│   ├── constants/
│   │   └── app_constants.dart           # API endpoints, models, UI constants
│   ├── theme/
│   │   └── app_theme.dart               # Material Design 3 themes
│   ├── utils/                           # Utilities & helpers
│   └── services/                        # External service integrations
└── 🚀 features/                        # Feature modules (Clean Architecture)
    └── chat/                           # Chat feature module
        ├── 📊 data/                    # Data layer
        │   ├── datasources/            # API and local data sources
        │   ├── models/                 # Data models with JSON serialization
        │   └── repositories/           # Repository implementations
        ├── 🎯 domain/                  # Domain layer
        │   ├── entities/               # Business entities
        │   │   ├── chat.dart           # Chat entity
        │   │   ├── message.dart        # Message entity with roles/types
        │   │   └── chat_image.dart     # Image entity
        │   ├── repositories/           # Repository interfaces
        │   └── usecases/               # Business logic use cases
        └── 🎨 presentation/            # Presentation layer
            ├── bloc/                   # BLoC state management
            │   ├── chat_list_bloc.dart # Chat list management
            │   ├── current_chat_bloc.dart # Active chat state
            │   ├── image_upload_bloc.dart # Image upload handling
            │   └── chat_ui_cubit.dart  # UI state management
            ├── pages/
            │   └── chat_page.dart      # Main chat interface
            └── widgets/                # Reusable UI components
                ├── chat_drawer.dart    # Sidebar navigation
                ├── message_bubble.dart # Message display component
                ├── message_input.dart  # Input with image support
                └── options_menu.dart   # Context menus
```

### Backend Architecture
```
backend/
├── 📄 package.json                     # Dependencies and scripts
├── 🗄️ prisma/
│   └── schema.prisma                   # Database schema definition
└── 📁 src/
    ├── 🚀 index.js                     # Server entry point
    ├── 🏗️ app.js                       # Express app configuration
    ├── 🔧 config/                      # Configuration files
    ├── 🎮 controllers/                 # Route controllers
    │   ├── chatController.js           # Chat CRUD operations
    │   ├── messageController.js        # Message handling
    │   └── imageController.js          # Image upload management
    ├── 🛡️ middleware/                  # Express middleware
    ├── 🛣️ routes/                      # API routes definition
    └── 🔧 utils/                       # Utility functions
```

---

## 🎯 Getting Started

### Prerequisites
- Flutter SDK 3.7.2 or higher
- Dart SDK 3.0 or higher
- Node.js 18+ and npm
- MongoDB database (local or Atlas)
- OpenAI API key
- Cloudinary account (for image uploads)

### 1. **Setup Backend**
```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
```

Edit `.env` file with your configuration:
```env
# Database (MongoDB)
DATABASE_URL="mongodb://localhost:27017/chatgpt_clone"
# For MongoDB Atlas (cloud): 
# DATABASE_URL="mongodb+srv://username:password@cluster.mongodb.net/chatgpt_clone"

# OpenAI API
OPENAI_API_KEY="your_openai_api_key_here"

# Cloudinary (for image uploads)
CLOUDINARY_CLOUD_NAME="your_cloud_name"
CLOUDINARY_API_KEY="your_api_key"
CLOUDINARY_API_SECRET="your_api_secret"

# Server Configuration
PORT=5000
NODE_ENV=development
```

```bash
# Generate Prisma client for MongoDB
npx prisma generate

# Start the development server
npm run dev
```

### 2. **Setup Frontend**
```bash
# Install Flutter dependencies
flutter pub get

# Run the app (make sure backend is running)
flutter run
```

### 3. **Configure API Integration**
The app will automatically connect to the backend API running on `http://localhost:5000`. If you need to change the API endpoint, update the `baseUrl` in `lib/core/constants/app_constants.dart`.

---

## 🎨 Screenshots & Features

### 💬 Chat Interface
- **Message Bubbles**: Styled user and assistant messages with proper spacing
- **Typing Indicators**: Real-time "Responding..." and "Regenerating..." status
- **Markdown Support**: Rich text rendering with GPT markdown package
- **Message Actions**: Copy content, regenerate responses, retry failed messages
- **Image Support**: Send and display images with Cloudinary integration
- **Auto-scroll**: Automatic scrolling to latest messages

### 📱 Navigation & Layout
- **Sidebar Drawer**: Collapsible chat history with search functionality
- **Chat List**: All conversations with timestamps and latest message preview
- **Search**: Real-time search through chat titles and content
- **Responsive Design**: Optimized for phones, tablets, and different orientations

### ⚙️ Chat Management
- **Create Chats**: Start new conversations instantly
- **Rename Chats**: Custom titles with validation
- **Delete Chats**: Confirmation dialogs with proper cleanup
- **Chat Selection**: Visual indicators for active chat
- **Loading States**: Smooth animations for all operations

### 🤖 AI Integration
- **Multiple Models**: Support for GPT-4o, GPT-4.1, GPT-4o-mini, GPT-4.1-mini
- **Model Selection**: Easy switching between different AI models
- **Error Handling**: Graceful handling of API failures with retry options
- **Response Streaming**: Real-time response display (backend ready)

### 🎨 UI/UX Features
- **Material Design 3**: Modern design system with adaptive theming
- **Dark/Light Modes**: Automatic theme switching based on system preferences
- **Custom Icons**: Beautiful SVG icons throughout the interface
- **Smooth Animations**: Polished transitions and micro-interactions
- **Loading Indicators**: Contextual progress indicators

---

## 🔧 Development & Architecture

### State Management (BLoC Pattern)
```dart
// Chat List Management
ChatListBloc: Handles chat CRUD operations, search functionality
- LoadChatsEvent: Fetch all user chats
- SearchChatsEvent: Filter chats by search query
- DeleteChatEvent: Remove chat with confirmation
- UpdateChatTitleEvent: Rename chat functionality

// Current Chat Management  
CurrentChatBloc: Manages active chat session
- LoadChatEvent: Load specific chat with messages
- SendMessageEvent: Send text/image messages to AI
- StartNewChatEvent: Initialize new conversation
- RegenerateResponseEvent: Retry AI responses

// UI State Management
ChatUICubit: Handles UI-specific state
- Model selection, input focus, theme preferences

// Image Upload Management
ImageUploadBloc: Manages image selection and upload
- SelectImageEvent: Image picker integration
- UploadImageEvent: Cloudinary upload handling
```

### Clean Architecture Layers
```dart
// Domain Layer (Business Logic)
- Entities: Core business objects (Message, Chat, ChatImage)
- Repositories: Abstract interfaces for data operations
- Use Cases: Specific business logic operations

// Data Layer (External Interfaces)
- Models: Data transfer objects with JSON serialization
- Repositories: Concrete implementations
- Data Sources: API clients and local storage

// Presentation Layer (UI)
- Pages: Full screen widgets
- Widgets: Reusable UI components  
- BLoC: State management and business logic
```

### API Integration
The backend provides comprehensive REST API endpoints:
- **Chat Management**: CRUD operations for conversations
- **Message Handling**: Send/receive with AI integration
- **Image Upload**: Cloudinary integration for media
- **User Management**: User-specific data isolation
- **Search**: Full-text search across chats and messages

For complete API documentation, see [`backend/API_DOCUMENTATION.md`](backend/API_DOCUMENTATION.md)

---

##  Deployment

### Frontend (Flutter)
```bash
# Build for production
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android App Bundle
flutter build ios --release          # iOS
flutter build web --release          # Web
```

### Backend (Node.js)
```bash
# Production build
npm run build

# Deploy with PM2 (recommended)
pm2 start ecosystem.config.js

# Or deploy to platforms like:
# - Heroku, Railway, Render
# - AWS EC2, Google Cloud, Azure
# - Vercel, Netlify (for serverless)
```

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### 🐛 **Bug Reports**
- Use GitHub Issues to report bugs
- Include detailed reproduction steps
- Provide system information and logs

### ✨ **Feature Requests**  
- Check existing issues before creating new ones
- Describe the feature and its use case
- Consider implementation complexity

### 💻 **Code Contributions**
1. 🍴 Fork the repository
2. 🌟 Create a feature branch (`git checkout -b feature/amazing-feature`)
3. 💻 Make your changes with proper documentation
4. 🧪 Add tests for new functionality  
5. ✅ Ensure all tests pass (`flutter test`)
6. � Update documentation if needed
7. �📤 Submit a pull request

### 📋 **Development Guidelines**
- Follow Flutter/Dart style guidelines
- Use meaningful commit messages
- Keep PRs focused and small
- Include tests for new features
- Update documentation for API changes

## 🔒 Security

- Report security vulnerabilities privately via email
- Use environment variables for sensitive data
- Follow OWASP guidelines for web security
- Regular dependency updates with security patches

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 🆘 Support & Community

- 🐛 **Issues**: [GitHub Issues](https://github.com/harshrajput1506/chatgpt_clone/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/harshrajput1506/chatgpt_clone/discussions)  
- 📧 **Contact**: [harshrajput2906@gmail.com](mailto:harshrajput2906@gmail.com)
- 🌟 **Star the repo**: If this project helped you!

## 🎉 Acknowledgments

- 🤖 **OpenAI** - For the amazing GPT models and API
- 💙 **Flutter Team** - For the excellent cross-platform framework
- � **Material Design** - For the beautiful design system
- 🌐 **Cloudinary** - For reliable image upload and management
- 📦 **Prisma** - For the excellent database ORM
- 🚀 **Open Source Community** - For amazing packages and inspiration

---

<div align="center">

**⭐ Star this repository if it helped you build something awesome! ⭐**

**Built with ❤️ by [Harsh Rajput](https://github.com/harshrajput1506)**

</div>

