# 💰 Expense Tracker

A modern, feature-rich expense tracking application built with Flutter and Firebase. Track your expenses, categorize transactions, visualize spending patterns with beautiful charts, and secure your financial data with biometric authentication.

## ✨ Features

### 📊 Expense Management
- **Add & Track Expenses**: Record expenses with amount, category, notes, and receipt images
- **Smart Categorization**: Pre-defined categories with custom icons
- **Search & Filter**: Quickly find transactions by search query or category
- **Date Grouping**: Organized view with TODAY, YESTERDAY, and custom date headers

### 📈 Analytics & Insights
- **Visual Charts**: Beautiful FL Chart visualizations of spending patterns
- **Category Breakdown**: See spending distribution across categories
- **Monthly Reports**: Track your monthly expenses and trends
- **Export Reports**: Generate and export PDF reports

### 🔔 Smart Notifications
- **Budget Alerts**: Get notified when approaching budget limits
- **Recurring Reminders**: Set reminders for recurring expenses
- **Local Notifications**: Powered by flutter_local_notifications

### 🔐 Security & Privacy
- **Biometric Authentication**: Secure app with fingerprint or face recognition
- **Secure Storage**: Sensitive data encrypted with flutter_secure_storage
- **Privacy First**: Your financial data stays private

### ☁️ Cloud Integration
- **Firebase Backend**: Real-time sync with Cloud Firestore
- **Firebase Auth**: Secure user authentication
- **Cloud Storage**: Store receipt images in Firebase Storage
- **Offline Support**: Local SQLite database for offline access

### 🎨 Beautiful UI/UX
- **Modern Design**: Clean, intuitive interface with smooth animations
- **Dark/Light Theme**: Toggle between dark and light modes
- **Responsive Layout**: Optimized for different screen sizes
- **Custom Theme System**: Branded color scheme and typography

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                   # Core utilities & configurations
│   ├── routes/            # App navigation
│   ├── services/          # Notification & other services
│   └── theme/             # Theme & styling
├── data/                   # Data layer
│   ├── datasources/       # Local (SQLite) & Remote (Firebase) data sources
│   ├── models/            # Data models
│   └── repositories/      # Repository implementations
├── domain/                 # Business logic layer
│   ├── entities/          # Domain entities
│   └── repositories/      # Repository interfaces
└── presentation/           # Presentation layer
    ├── providers/         # Riverpod state management
    ├── screens/           # UI screens
    └── widgets/           # Reusable widgets
```

## 🛠️ Tech Stack

### Framework & Language
- **Flutter** `^3.9.2` - Cross-platform mobile framework
- **Dart** - Programming language

### State Management
- **Riverpod** `^2.5.1` - Reactive state management

### Backend & Database
- **Firebase Core** `^2.27.0` - Firebase SDK
- **Cloud Firestore** `^4.15.8` - NoSQL cloud database
- **Firebase Auth** `^4.17.8` - Authentication
- **Firebase Storage** `^11.7.7` - Cloud file storage
- **SQLite** (`sqflite ^2.3.3`) - Local database

### UI & Visualization
- **FL Chart** `^0.66.2` - Beautiful charts
- **Intl** `^0.19.0` - Internationalization & date formatting

### Features & Utilities
- **Image Picker** `^1.2.1` - Capture/select receipt images
- **PDF** `^3.11.3` - PDF generation
- **Printing** `^5.13.1` - PDF export functionality
- **Local Notifications** `^17.0.0` - Push notifications
- **Local Auth** `^2.1.8` - Biometric authentication
- **Secure Storage** `^9.2.2` - Encrypted data storage
- **Permission Handler** `^12.0.1` - Runtime permissions

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.9.2` or higher
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Firebase account and project

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-repo-url/expense_tracker.git
   cd expense_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add Android/iOS apps to your Firebase project
   - Download `google-services.json` (Android) and place in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`
   - Run Firebase configuration:
     ```bash
     flutterfire configure
     ```

4. **Configure Firebase Services**
   - Enable Cloud Firestore
   - Enable Firebase Authentication (Email/Password)
   - Enable Firebase Storage
   - Set up security rules for Firestore and Storage

5. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

**Android**
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

**iOS**
```bash
flutter build ios --release
```

## � Screenshots

### App Logo
<p align="center">
  <img src="assets/images/app_icon.png" alt="Expense Tracker Logo" width="200"/>
</p>

### Home Screen
<p align="center">
  <img src="assets/images/home_screen.jpg" alt="Home Screen" width="300"/>
</p>

The home screen displays:
- **Current Balance** with beautiful gradient card
- **Income & Expenses** summary for the month
- **Monthly Budget Limit** tracking
- **Recent Transactions** with category icons
- Quick navigation with bottom tabs
- Dark/Light theme toggle

## �🔧 Configuration

### App Icon
The app uses `flutter_launcher_icons` for generating app icons. To update:
1. Place your icon in `assets/images/app_icon.png`
2. Run:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

### Theme Customization
Edit theme settings in `lib/core/theme/app_theme.dart`

### Notifications
Configure notification settings in `lib/core/services/notification_service.dart`

## 📝 Usage

### First Launch
1. Complete the onboarding tutorial
2. Set up biometric authentication (optional)
3. Start adding your first expense

### Adding an Expense
1. Tap the "+" button
2. Enter amount and select category
3. Add optional notes and receipt image
4. Save

### Viewing Analytics
- Navigate to Analytics tab
- View spending by category
- Check monthly trends
- Export reports as PDF

## 👥 Project Team

This project was developed by:

- **Eya Ben Ameur**
- **Oussema Guerami**
- **Hiba Chabbouh**
- **Samar Ben Houid**


## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- FL Chart for beautiful visualizations
- All open-source contributors

---

**Made with ❤️ using Flutter by Eya Ben Ameur, Oussema Guerami, Hiba Chabbouh & Samar Ben Houid**
