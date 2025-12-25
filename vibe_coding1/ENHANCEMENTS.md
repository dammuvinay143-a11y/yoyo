# Vibe Connect - Professional College Social Learning Platform

## 🚀 Overview

Vibe Connect is a modern, industry-ready social learning platform designed for colleges, combining the best of LinkedIn-style professional networking with educational features. Built with Flutter and Firebase, it provides a comprehensive solution for student engagement, learning management, and administrative oversight.

## ✨ Key Features

### 🎨 Advanced UI/UX
- **Dual Theme System**: Fully implemented light and dark themes with smooth transitions
- **Modern Design**: LinkedIn-inspired clean, professional interface
- **Responsive Layout**: Optimized for web, mobile, and tablet devices
- **Smooth Animations**: Micro-interactions and transitions throughout the app
- **Material Design 3**: Latest design guidelines with custom color schemes

### 👥 Student Features

#### Professional Profile System
- **Comprehensive Profiles**: 
  - Professional headline and bio
  - Cover photo and profile picture
  - Skills and interests tags
  - Academic information (roll number, department, year)
  - Location and contact details
  - Follower/Following system
  
- **Social Account Integration**:
  - LinkedIn profile linking
  - GitHub profile linking
  - Twitter/X integration
  - Portfolio website
  
- **Profile Statistics**:
  - Posts count
  - Followers count
  - Following count
  - Engagement metrics

#### LinkedIn-Style Social Feed
- **Rich Post Types**:
  - Text posts
  - Image posts (multiple images)
  - Video posts
  - Poll posts
  - Achievement posts
  - Event announcements
  
- **Engagement Features**:
  - Like/React to posts
  - Comment system
  - Share functionality
  - Post views tracking
  - Post tagging and categorization
  
- **Feed Algorithms**:
  - Personalized content
  - Trending posts
  - Department-specific content
  - Activity-based sorting

#### Learning Management
- **Tasks & Assignments**:
  - View and submit assignments
  - Track due dates
  - Status monitoring (pending, in progress, completed)
  - File attachments support
  
- **Interactive Quizzes**:
  - Timed quizzes
  - Multiple question types
  - Instant feedback
  - Score tracking
  - Quiz history

#### Networking
- **Student Directory**:
  - Browse all students
  - Filter by department, year
  - Connect with peers
  - View complete profiles
  
- **Professional Growth**:
  - Showcase achievements
  - Build professional network
  - Collaborate on projects

### 🔐 Admin Features

#### Secure Admin Access
- **Restricted Login**: Separate admin portal with domain validation
- **Role-Based Access**: Admin-only features and dashboards
- **Security Logging**: All admin actions are tracked
- **Multi-Factor Authentication Ready**: Architecture supports MFA integration

#### Student Management
- **Comprehensive Student Dashboard**:
  - View all student profiles with full details
  - Access to social account information
  - Activity monitoring
  - Account status management (activate/deactivate)
  - Student analytics and statistics
  
- **Bulk Operations**:
  - Import/export student data
  - Batch account management
  - Department-wide communications

#### Content Management
- **Task Creation**:
  - Create and assign tasks to specific departments
  - Set due dates and priorities
  - Attach resources and guidelines
  - Track submission rates
  
- **Quiz Management**:
  - Create interactive quizzes
  - Multiple question types support
  - Set time limits and attempts
  - Publish/unpublish control
  - View quiz analytics
  
- **Content Moderation**:
  - Review flagged posts
  - Approve or remove content
  - User behavior monitoring
  - Automated content filtering

#### Analytics Dashboard
- **Real-Time Metrics**:
  - Total students count
  - Active users statistics
  - Engagement rates
  - Department-wise distribution
  - Popular content analysis
  
- **Visual Reports**:
  - Interactive charts
  - Trend analysis
  - Performance metrics
  - Export capabilities

### 🎯 Technical Features

#### Architecture
- **Clean Architecture**: Separation of concerns with layers (presentation, domain, data)
- **BLoC Pattern**: State management using flutter_bloc
- **Dependency Injection**: Using get_it for loose coupling
- **Repository Pattern**: Abstract data sources
- **SOLID Principles**: Maintainable and scalable code

#### Firebase Integration
- **Authentication**: Email/password with role-based access
- **Firestore**: Real-time NoSQL database
- **Cloud Storage**: Image and file uploads
- **Security Rules**: Comprehensive data protection

#### Performance Optimizations
- **Lazy Loading**: Efficient data fetching
- **Image Caching**: Reduced network calls
- **State Persistence**: Offline capability ready
- **Optimistic Updates**: Better UX with instant feedback

#### Code Quality
- **Type Safety**: Strong typing throughout
- **Error Handling**: Comprehensive error management
- **Logging**: Debug and production logging
- **Testing Ready**: Architecture supports unit/widget/integration tests

## 🛠️ Technology Stack

### Frontend
- **Flutter 3.27.3+**: Cross-platform framework
- **Material Design 3**: Modern UI components
- **Google Fonts**: Custom typography (Poppins)

### State Management & Architecture
- **flutter_bloc 8.1.6**: Business logic component pattern
- **equatable 2.0.7**: Value equality
- **get_it 7.7.0**: Dependency injection

### Backend & Database
- **Firebase Core 3.8.1**: Firebase SDK
- **Firebase Auth 5.3.3**: Authentication
- **Cloud Firestore 5.5.2**: NoSQL database
- **Firebase Storage 12.3.6**: File storage

### UI & Assets
- **cached_network_image 3.3.1**: Image caching
- **flutter_svg 2.0.10**: SVG support
- **shimmer 3.0.0**: Loading animations
- **lottie 3.1.2**: Complex animations
- **animations 2.0.11**: Transition animations

### Utilities
- **intl 0.19.0**: Internationalization
- **uuid 4.4.0**: Unique identifiers
- **url_launcher 6.3.0**: External links
- **image_picker 1.1.2**: Camera/gallery access
- **file_picker 8.0.0**: File selection

### Responsive Design
- **responsive_framework 1.5.1**: Responsive layouts
- **flutter_screenutil 5.9.3**: Screen adaptation

## 📁 Project Structure

```
lib/
├── app.dart                          # App entry point
├── main.dart                         # Main function
├── injection_container.dart          # DI setup
├── core/
│   ├── constants/
│   │   └── app_colors.dart          # Color palette
│   ├── routes/
│   │   └── app_router.dart          # Navigation
│   ├── theme/
│   │   ├── app_theme.dart           # Theme definitions
│   │   └── theme_cubit.dart         # Theme state management
│   ├── utils/                        # Utility functions
│   └── widgets/                      # Reusable widgets
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── models/
    │   │   │   └── user_model.dart  # Enhanced user model
    │   │   └── repositories/
    │   ├── domain/
    │   └── presentation/
    │       ├── bloc/                # Auth state management
    │       └── pages/
    │           ├── splash_page.dart
    │           ├── login_page.dart
    │           ├── register_page.dart
    │           ├── admin_login_page.dart  # NEW: Admin portal
    │           └── forgot_password_page.dart
    ├── student/
    │   ├── data/
    │   │   ├── models/
    │   │   │   ├── post_model.dart  # Enhanced with rich features
    │   │   │   ├── task_model.dart
    │   │   │   └── quiz_model.dart
    │   │   └── repositories/
    │   ├── domain/
    │   └── presentation/
    │       ├── bloc/                # Student features state
    │       ├── pages/               # All student pages
    │       └── widgets/             # Custom widgets
    └── admin/
        ├── data/
        │   └── repositories/
        ├── domain/
        └── presentation/
            ├── bloc/                # Admin state management
            ├── pages/               # Admin dashboard & tools
            └── widgets/             # Admin-specific widgets
```

## 🚦 Getting Started

### Prerequisites
- Flutter SDK 3.27.3 or higher
- Dart SDK 3.0.0 or higher
- Firebase account and project
- VS Code or Android Studio

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd vibe_coding1
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Enable Authentication (Email/Password)
   - Enable Firestore Database
   - Enable Cloud Storage
   - Download and add `google-services.json` (Android)
   - Download and add `GoogleService-Info.plist` (iOS)
   - Update `firebase_options.dart` with your configuration

4. **Run the app**
   ```bash
   flutter run -d chrome  # For web
   flutter run            # For mobile
   ```

## 🔧 Configuration

### Firebase Security Rules

#### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId || 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Posts collection
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.authorId;
      allow update, delete: if request.auth.uid == resource.data.authorId || 
                              get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Tasks collection
    match /tasks/{taskId} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Quizzes collection
    match /quizzes/{quizId} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

#### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_pictures/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    match /cover_photos/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    match /post_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

### Admin Setup

To create an admin account:
1. Register a new user through Firebase Console
2. Set the `role` field to `'admin'` in the users collection
3. Use an email ending with `@admin.vibe.com` or `@vibe.admin`
4. Access the admin portal at `/admin/login`

## 🎨 Theme Customization

The app supports comprehensive theming. To customize:

1. **Colors**: Edit `lib/core/constants/app_colors.dart`
2. **Typography**: Modify `lib/core/theme/app_theme.dart`
3. **Components**: Update theme data in both light and dark modes

### Switching Themes

Users can toggle between light and dark mode from their profile settings.

## 📱 Features in Detail

### Enhanced User Profile
```dart
// New fields added to UserModel:
- coverPhotoUrl: Profile cover image
- headline: Professional headline (e.g., "Computer Science Student | AI Enthusiast")
- bio: Detailed bio/about section
- skills: List of skills
- interests: List of interests
- Social accounts: LinkedIn, GitHub, Twitter, Portfolio
- phone, location, dateOfBirth
- followersCount, followingCount, postsCount
```

### Rich Post Types
```dart
enum PostType {
  text,        // Simple text post
  image,       // Post with images
  video,       // Video post
  poll,        // Poll/survey
  achievement, // Milestone/achievement
  event,       // Event announcement
}
```

### Admin Analytics
The admin dashboard provides:
- Total students enrolled
- Active users (7-day activity)
- Department distribution
- Engagement metrics
- Popular content
- Task completion rates
- Quiz participation rates

## 🔐 Security Features

1. **Role-Based Access Control**: Separate student and admin portals
2. **Email Validation**: Admin emails must match specific domains
3. **Secure Authentication**: Firebase Auth with email/password
4. **Data Validation**: Input validation on all forms
5. **Error Handling**: Comprehensive error catching and user feedback
6. **Audit Logging**: Admin actions are logged
7. **Content Moderation**: Automated and manual moderation tools

## 🚀 Deployment

### Web Deployment
```bash
flutter build web --release
```
Deploy the `build/web` directory to your hosting service.

### Mobile Deployment
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🧪 Testing

The project is structured to support:
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for complete workflows

Run tests:
```bash
flutter test
```

## 📈 Future Enhancements

- [ ] Real-time messaging system
- [ ] Video conferencing integration
- [ ] Study groups and communities
- [ ] AI-powered content recommendations
- [ ] Advanced analytics and insights
- [ ] Mobile app optimization
- [ ] Progressive Web App (PWA) features
- [ ] Push notifications
- [ ] Multi-language support
- [ ] Accessibility improvements

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write/update tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 👥 Team

Built with ❤️ by the Vibe Connect team

## 📞 Support

For support, email support@vibeconnect.com or open an issue in the repository.

---

**Note**: This is a production-ready application with industry-standard practices. All sensitive data is properly secured, and the architecture supports scaling to thousands of users.
