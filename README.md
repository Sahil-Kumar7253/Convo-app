# Convo App 💬

A real-time chat application built with Flutter for the mobile client and Node.js/Express for the backend. This application enables users to connect with friends, send messages in real-time, share images, and manage their social connections.

## 🌟 Features

### User Management
- **User Authentication**: Secure registration and login with JWT token authentication
- **Profile Management**: Users can update their profile information and upload profile pictures
- **Friend System**: Send, accept, and reject friend requests
- **Find Users**: Search and discover other users on the platform

### Chat & Messaging
- **Real-time Messaging**: Instant message delivery using Socket.IO
- **Private Chats**: One-on-one conversations with friends
- **Image Sharing**: Send and receive images in chats
- **Message History**: View complete chat history with any friend
- **Message Deletion**: Delete messages from conversations

### Additional Features
- **Friend Requests**: Send and manage friend requests
- **Friends List**: View and manage your friends
- **Online Status**: Real-time tracking of online users
- **Profile Pictures**: Upload and display custom profile pictures with Cloudinary integration

## 🏗️ Architecture

The project is divided into two main parts:

### Backend (`/Backend`)
- **Framework**: Express.js (Node.js)
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT (JSON Web Tokens)
- **Real-time Communication**: Socket.IO
- **Image Storage**: Cloudinary
- **Password Hashing**: Bcrypt

### Mobile App (`/convo_app`)
- **Framework**: Flutter
- **State Management**: Provider
- **HTTP Client**: http package
- **Real-time Communication**: socket_io_client
- **Local Storage**: shared_preferences
- **Image Handling**: image_picker & image packages

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

### For Backend:
- [Node.js](https://nodejs.org/) (v22.x)
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)
- [MongoDB](https://www.mongodb.com/) account or local MongoDB installation

### For Mobile App:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (SDK: ^3.8.1)
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/) (for iOS)
- A physical device or emulator for testing

## 🚀 Getting Started

### Backend Setup

1. **Navigate to the Backend directory:**
   ```bash
   cd Backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment variables:**
   
   Create a `.env` file in the Backend directory with the following variables:
   ```env
   PORT=3000
   JWT_SECRET_KEY=your_jwt_secret_key_here
   MONGO_URI=your_mongodb_connection_string
   CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
   CLOUDINARY_API_KEY=your_cloudinary_api_key
   CLOUDINARY_API_SECRET=your_cloudinary_api_secret
   ```

   **Important:** Replace the placeholder values with your actual credentials:
   - Get MongoDB URI from [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
   - Get Cloudinary credentials from [Cloudinary Console](https://cloudinary.com/console)
   - Generate a strong, random string for JWT_SECRET_KEY

4. **Start the backend server:**
   ```bash
   npm start
   ```

   The server will start on `http://localhost:3000` (or the PORT specified in .env)

### Mobile App Setup

1. **Navigate to the Flutter app directory:**
   ```bash
   cd convo_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint:**
   
   Update the API base URL in `/convo_app/lib/utils/constants.dart` to point to your backend server:
   ```dart
   // For Android emulator
   const String baseUrl = 'http://10.0.2.2:3000';
   
   // For iOS simulator
   const String baseUrl = 'http://localhost:3000';
   
   // For physical device
   const String baseUrl = 'http://YOUR_LOCAL_IP:3000';
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

   Or use your IDE's run configuration (Android Studio, VS Code, etc.)

## 📱 API Endpoints

### User Routes (`/api/users`)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/register` | Register a new user | No |
| POST | `/login` | Login user | No |
| GET | `/` | Get all users | Yes |
| PUT | `/profile` | Update user profile | Yes |
| POST | `/profile/image` | Upload profile image | Yes |
| GET | `/friends` | Get user's friends list | Yes |
| DELETE | `/friends/:friendId` | Remove a friend | Yes |
| GET | `/friends-requests/received` | Get received friend requests | Yes |
| POST | `/friends-request/sent/:receiverId` | Send friend request | Yes |
| PUT | `/friends-request/accept/:senderId` | Accept friend request | Yes |
| PUT | `/friends-request/reject/:senderId` | Reject friend request | Yes |

### Message Routes (`/api/messages`)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/:receiverId` | Get chat history with a user | Yes |
| POST | `/send` | Send a text message | Yes |
| POST | `/image` | Send an image message | Yes |
| DELETE | `/:id` | Delete a message | Yes |

### Socket Events

| Event | Direction | Description |
|-------|-----------|-------------|
| `register_user` | Client → Server | Register user's socket connection |
| `send_private_message` | Client → Server | Send a private message |
| `receive_private_message` | Server → Client | Receive a private message |
| `disconnect` | Client → Server | User disconnected |

## 🗂️ Project Structure

```
Convo-app/
├── Backend/
│   ├── config/
│   │   └── mongooseConfig.js    # MongoDB configuration
│   ├── controller/
│   │   ├── messageController.js # Message logic
│   │   ├── socketController.js  # Socket.IO handlers
│   │   └── userController.js    # User logic
│   ├── middleware/
│   │   └── authMiddleware.js    # JWT authentication
│   ├── models/
│   │   ├── messageModel.js      # Message schema
│   │   └── userModel.js         # User schema
│   ├── routes/
│   │   ├── messageRoutes.js     # Message endpoints
│   │   └── userRoutes.js        # User endpoints
│   ├── .env                     # Environment variables
│   ├── app.js                   # Express app setup
│   ├── index.js                 # Server entry point
│   └── package.json             # Node.js dependencies
│
└── convo_app/
    ├── lib/
    │   ├── models/              # Data models
    │   ├── providers/           # State management
    │   ├── screens/             # UI screens
    │   ├── services/            # API & Socket services
    │   ├── utils/               # Utilities & constants
    │   ├── widgets/             # Reusable widgets
    │   └── main.dart            # App entry point
    ├── android/                 # Android config
    ├── ios/                     # iOS config
    └── pubspec.yaml             # Flutter dependencies
```

## 🛠️ Technologies Used

### Backend
- **Express.js** - Web framework
- **MongoDB** - NoSQL database
- **Mongoose** - MongoDB ODM
- **Socket.IO** - Real-time bidirectional communication
- **JWT** - Authentication tokens
- **Bcrypt** - Password hashing
- **Cloudinary** - Image storage and CDN
- **Multer** - File upload handling
- **CORS** - Cross-origin resource sharing

### Mobile App
- **Flutter** - UI framework
- **Provider** - State management
- **Socket.IO Client** - Real-time communication
- **HTTP** - REST API calls
- **Shared Preferences** - Local storage
- **JWT Decode** - Token parsing
- **Image Picker** - Image selection
- **Image** - Image processing

## 🔐 Security Features

- **Password Hashing**: All passwords are hashed using bcrypt before storage
- **JWT Authentication**: Secure token-based authentication for API endpoints
- **Middleware Protection**: Protected routes require valid JWT tokens
- **Environment Variables**: Sensitive data stored in environment variables

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit your changes** (`git commit -m 'Add some AmazingFeature'`)
4. **Push to the branch** (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**

### Development Guidelines
- Follow the existing code style and conventions
- Write clear commit messages
- Test your changes thoroughly before submitting
- Update documentation as needed

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👨‍💻 Author

**Sahil Kumar**
- GitHub: [@Sahil-Kumar7253](https://github.com/Sahil-Kumar7253)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Express.js and Node.js communities
- MongoDB for the database solution
- Socket.IO for real-time capabilities
- Cloudinary for image storage

## 📞 Support

If you have any questions or need help, please:
- Open an issue in the GitHub repository
- Contact the maintainer through GitHub

## 🔮 Future Enhancements

Potential features for future development:
- Group chat functionality
- Voice and video calls
- Message reactions and emoji support
- Read receipts
- Typing indicators
- Push notifications
- Dark mode
- Message search
- File sharing (documents, videos, etc.)
- User blocking functionality

---

⭐ If you find this project useful, please consider giving it a star!
