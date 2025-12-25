class FirebaseConstants {
  // Collections
  static const String usersCollection = 'users';
  static const String studentProfilesCollection = 'student_profiles';
  static const String postsCollection = 'posts';
  static const String tasksCollection = 'tasks';
  static const String taskSubmissionsCollection = 'task_submissions';
  static const String quizzesCollection = 'quizzes';
  static const String quizAttemptsCollection = 'quiz_attempts';

  // Storage Paths
  static const String profilePhotosPath = 'profile_photos';
  static const String postImagesPath = 'post_images';
  static const String taskSubmissionsPath = 'task_submissions';

  // Fields
  static const String uidField = 'uid';
  static const String emailField = 'email';
  static const String nameField = 'name';
  static const String roleField = 'role';
  static const String createdAtField = 'createdAt';
  static const String isActiveField = 'isActive';

  // Roles
  static const String studentRole = 'student';
  static const String adminRole = 'admin';
}
