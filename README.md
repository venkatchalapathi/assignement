# VideoCall App

A Flutter application with real-time video calling capabilities using Agora SDK, REST API integration, and offline caching.

## Features

### Authentication & Login
- Simple login screen with email and password validation
- Mock authentication with hardcoded credentials
- Form validation for empty fields and email format
- Persistent login state

### Video Calling
- One-to-one video calling using Agora SDK
- Join meetings using channel names
- Local and remote video streams
- Mute/unmute audio and enable/disable video
- Switch camera functionality
- Screen sharing capability
- Real-time call controls

### User Management
- Fetch users from ReqRes API
- Display users in a scrollable list with avatars
- Offline caching with local storage
- Pull-to-refresh functionality
- User details modal

### App Lifecycle & Store Readiness
- Splash screen with app branding
- App icons and proper naming
- Camera and microphone permissions
- Android and iOS configuration
- Error handling and loading states

### State Management
- Provider pattern for state management
- Separate providers for authentication, users, and video calls
- Reactive UI updates

## Technical Stack

- **Framework**: Flutter 3.8.1+
- **Video SDK**: Agora RTC Engine 6.3.0
- **State Management**: Provider 6.1.2
- **HTTP Client**: Dio 5.7.0 & HTTP 1.2.2
- **Local Storage**: SharedPreferences 2.3.2 & SQLite 2.4.0
- **Permissions**: Permission Handler 11.3.1
- **Image Caching**: Cached Network Image 3.4.1

## Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode
- Agora.io account (for production use)

## Setup Instructions

### 1. Clone the Repository
```bash
git clone <repository-url>
cd assignement
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Agora SDK Configuration

The app is pre-configured with a test Agora App ID: `e9ee********************bc35`

For production use:
1. Create an account at [Agora.io](https://www.agora.io/)
2. Create a new project and get your App ID
3. Replace the App ID in `lib/services/agora_service.dart`:
```dart
static const String appId = 'YOUR_AGORA_APP_ID';
```

### 4. Platform Configuration

#### Android
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Permissions are already configured in `android/app/src/main/AndroidManifest.xml`

#### iOS
- Minimum iOS: 11.0
- Permissions are configured in `ios/Runner/Info.plist`

### 5. Run the App

#### Debug Mode
```bash
# Android
flutter run

# iOS
flutter run -d ios
```

#### Release Mode
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Demo Credentials

For testing purposes, use these credentials:
- **Email**: test@example.com
- **Password**: password

## API Integration

The app uses the ReqRes API for user data:
- **Base URL**: https://reqres.in/api
- **Endpoints**:
  - `GET /users` - Fetch users list
  - `GET /users/{id}` - Fetch specific user

## Offline Support

The app includes offline caching:
- Users data is cached locally using SharedPreferences
- Cached data is valid for 1 hour
- App works offline with cached data
- Pull-to-refresh updates the cache

## Architecture

```
lib/
├── models/           # Data models
├── services/         # API and storage services
├── providers/        # State management
├── screens/          # UI screens
└── utils/            # Utilities and constants
```

## Key Components

### Services
- **AgoraService**: Handles video calling functionality
- **ApiService**: Manages REST API calls
- **StorageService**: Handles local data persistence

### Providers
- **AuthProvider**: Manages authentication state
- **UsersProvider**: Manages users data and caching
- **VideoCallProvider**: Manages video call state

### Screens
- **SplashScreen**: App launch screen
- **LoginScreen**: User authentication
- **HomeScreen**: Main dashboard
- **VideoCallScreen**: Video calling interface
- **UsersListScreen**: Users list with offline support

## Permissions

### Android
- `INTERNET` - Network access
- `CAMERA` - Video calling
- `RECORD_AUDIO` - Audio calling
- `MODIFY_AUDIO_SETTINGS` - Audio control
- `ACCESS_NETWORK_STATE` - Network monitoring
- `WAKE_LOCK` - Keep screen on during calls

### iOS
- `NSCameraUsageDescription` - Camera access
- `NSMicrophoneUsageDescription` - Microphone access

## Testing

### Video Call Testing
1. Install the app on two devices or emulators
2. Use the same channel name on both devices
3. Test video, audio, and camera switching

### Offline Testing
1. Load the users list
2. Turn off network connection
3. Verify cached data is displayed
4. Test pull-to-refresh behavior

## Build Instructions

### Android APK
```bash
flutter build apk --release
```

### iOS IPA
```bash
flutter build ios --release
```

## Troubleshooting

### Common Issues

1. **Camera/Microphone not working**
   - Check device permissions
   - Verify Agora App ID is correct
   - Ensure device has camera and microphone

2. **Users not loading**
   - Check internet connection
   - Verify API endpoint is accessible
   - Check console for error messages

3. **Video call not connecting**
   - Verify both devices are using the same channel name
   - Check Agora App ID configuration
   - Ensure proper network connectivity

### Debug Mode
Enable debug logging by setting:
```dart
// In agora_service.dart
print('Debug: $message');
```
