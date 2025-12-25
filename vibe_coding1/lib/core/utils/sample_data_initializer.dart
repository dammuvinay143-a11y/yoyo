import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class to initialize sample data for the application
/// Call initializeSampleData() once to populate the database
class SampleDataInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeSampleData() async {
    try {
      print('Starting sample data initialization...');

      // Check if data already exists
      final existingPosts = await _firestore.collection('posts').limit(1).get();
      if (existingPosts.docs.isNotEmpty) {
        print('Sample data already exists. Skipping initialization.');
        return;
      }

      // Create sample students
      await _createSampleStudents();

      // Create sample posts
      await _createSamplePosts();

      // Create sample tasks
      await _createSampleTasks();

      // Create sample quizzes
      await _createSampleQuizzes();

      print('Sample data initialization completed successfully!');
    } catch (e) {
      print('Error initializing sample data: $e');
    }
  }

  Future<void> _createSampleStudents() async {
    print('Creating sample students...');

    final sampleStudents = [
      {
        'email': 'alice.johnson@student.com',
        'name': 'Alice Johnson',
        'role': 'student',
        'department': 'Computer Science',
        'year': 3,
        'rollNumber': '21CS101',
        'bio': 'Passionate about AI and Machine Learning. Love coding and problem solving!',
        'headline': 'CS Student | AI Enthusiast | Competitive Programmer',
        'skills': ['Python', 'Java', 'Machine Learning', 'Data Structures'],
        'interests': ['AI', 'Web Development', 'Gaming', 'Photography'],
        'linkedinUrl': 'https://linkedin.com/in/alicejohnson',
        'githubUrl': 'https://github.com/alicejohnson',
        'isActive': true,
        'followersCount': 45,
        'followingCount': 38,
        'postsCount': 12,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'email': 'bob.smith@student.com',
        'name': 'Bob Smith',
        'role': 'student',
        'department': 'Information Technology',
        'year': 2,
        'rollNumber': '22IT205',
        'bio': 'Full-stack developer and tech blogger. Building cool projects!',
        'headline': 'Full Stack Developer | Tech Blogger',
        'skills': ['React', 'Node.js', 'MongoDB', 'Flutter'],
        'interests': ['Web Dev', 'Mobile Apps', 'Blogging', 'Music'],
        'linkedinUrl': 'https://linkedin.com/in/bobsmith',
        'githubUrl': 'https://github.com/bobsmith',
        'portfolioUrl': 'https://bobsmith.dev',
        'isActive': true,
        'followersCount': 52,
        'followingCount': 41,
        'postsCount': 18,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'email': 'carol.white@student.com',
        'name': 'Carol White',
        'role': 'student',
        'department': 'Electronics',
        'year': 4,
        'rollNumber': '20EC087',
        'bio': 'IoT and embedded systems enthusiast. Hardware + Software = ❤️',
        'headline': 'IoT Developer | Hardware Hacker',
        'skills': ['C++', 'Arduino', 'Raspberry Pi', 'IoT'],
        'interests': ['Robotics', 'IoT', 'DIY Projects', 'Reading'],
        'githubUrl': 'https://github.com/carolwhite',
        'isActive': true,
        'followersCount': 31,
        'followingCount': 29,
        'postsCount': 8,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var student in sampleStudents) {
      await _firestore.collection('users').add(student);
    }

    print('Sample students created successfully!');
  }

  Future<void> _createSamplePosts() async {
    print('Creating sample posts...');

    // Get current user or use first sample student
    final usersSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .limit(3)
        .get();

    if (usersSnapshot.docs.isEmpty) {
      print('No users found to create posts');
      return;
    }

    final samplePosts = [
      {
        'authorId': usersSnapshot.docs[0].id,
        'authorName': usersSnapshot.docs[0]['name'],
        'authorPhotoUrl': usersSnapshot.docs[0]['photoUrl'],
        'content':
            '🎉 Just completed my Machine Learning project! Built a sentiment analysis model with 92% accuracy. Feeling proud! #MachineLearning #AI',
        'imageUrls': [],
        'likes': [usersSnapshot.docs[1].id, usersSnapshot.docs[2].id],
        'comments': [
          {
            'userId': usersSnapshot.docs[1].id,
            'userName': usersSnapshot.docs[1]['name'],
            'text': 'Awesome work! Can you share the GitHub link?',
            'createdAt': FieldValue.serverTimestamp(),
          }
        ],
        'shares': [],
        'tags': ['MachineLearning', 'AI', 'Project'],
        'type': 'text',
        'isFlagged': false,
        'viewsCount': 45,
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 2))),
      },
      {
        'authorId': usersSnapshot.docs[1].id,
        'authorName': usersSnapshot.docs[1]['name'],
        'authorPhotoUrl': usersSnapshot.docs[1]['photoUrl'],
        'content':
            '💻 Working on a new React + Node.js project. Anyone interested in collaborating? Looking for backend developers! DM me 🚀',
        'imageUrls': [],
        'likes': [usersSnapshot.docs[0].id],
        'comments': [],
        'shares': [],
        'tags': ['React', 'NodeJS', 'Collaboration'],
        'type': 'text',
        'isFlagged': false,
        'viewsCount': 38,
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 5))),
      },
      {
        'authorId': usersSnapshot.docs[2].id,
        'authorName': usersSnapshot.docs[2]['name'],
        'authorPhotoUrl': usersSnapshot.docs[2]['photoUrl'],
        'content':
            '🤖 Just finished building a home automation system using Arduino and IoT! Controlling lights, fans, and temperature from my phone. Next step: voice control! #IoT #Arduino #SmartHome',
        'imageUrls': [],
        'likes': [
          usersSnapshot.docs[0].id,
          usersSnapshot.docs[1].id,
        ],
        'comments': [
          {
            'userId': usersSnapshot.docs[0].id,
            'userName': usersSnapshot.docs[0]['name'],
            'text': 'This is so cool! Would love to see a demo!',
            'createdAt': FieldValue.serverTimestamp(),
          },
          {
            'userId': usersSnapshot.docs[1].id,
            'userName': usersSnapshot.docs[1]['name'],
            'text': 'Amazing project! Can you write a blog post about it?',
            'createdAt': FieldValue.serverTimestamp(),
          }
        ],
        'shares': [usersSnapshot.docs[0].id],
        'tags': ['IoT', 'Arduino', 'SmartHome'],
        'type': 'text',
        'isFlagged': false,
        'viewsCount': 67,
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 12))),
      },
      {
        'authorId': usersSnapshot.docs[0].id,
        'authorName': usersSnapshot.docs[0]['name'],
        'authorPhotoUrl': usersSnapshot.docs[0]['photoUrl'],
        'content':
            '📚 Final exams starting next week! Time to hit the books. Good luck to everyone! 💪 #ExamSeason #StudyMode',
        'imageUrls': [],
        'likes': [usersSnapshot.docs[1].id, usersSnapshot.docs[2].id],
        'comments': [
          {
            'userId': usersSnapshot.docs[1].id,
            'userName': usersSnapshot.docs[1]['name'],
            'text': 'All the best! We got this! 💪',
            'createdAt': FieldValue.serverTimestamp(),
          }
        ],
        'shares': [],
        'tags': ['Exams', 'Study'],
        'type': 'text',
        'isFlagged': false,
        'viewsCount': 52,
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 1))),
      },
      {
        'authorId': usersSnapshot.docs[1].id,
        'authorName': usersSnapshot.docs[1]['name'],
        'authorPhotoUrl': usersSnapshot.docs[1]['photoUrl'],
        'content':
            '🎯 Just solved 100 problems on LeetCode! The journey continues... #CodingLife #LeetCode #100DaysOfCode',
        'imageUrls': [],
        'likes': [usersSnapshot.docs[0].id, usersSnapshot.docs[2].id],
        'comments': [],
        'shares': [],
        'tags': ['LeetCode', 'Coding', '100DaysOfCode'],
        'type': 'achievement',
        'isFlagged': false,
        'viewsCount': 41,
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 2))),
      },
    ];

    for (var post in samplePosts) {
      await _firestore.collection('posts').add(post);
    }

    print('Sample posts created successfully!');
  }

  Future<void> _createSampleTasks() async {
    print('Creating sample tasks...');

    final sampleTasks = [
      {
        'title': 'Web Development Assignment',
        'description':
            'Create a responsive website using HTML, CSS, and JavaScript. The website should include a homepage, about page, and contact form.',
        'subject': 'Web Technology',
        'dueDate':
            Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
        'totalMarks': 50,
        'attachments': [],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Data Structures Lab Report',
        'description':
            'Write a comprehensive lab report on implementing Binary Search Trees and AVL Trees. Include time complexity analysis and code examples.',
        'subject': 'Data Structures',
        'dueDate':
            Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
        'totalMarks': 30,
        'attachments': [],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Database Design Project',
        'description':
            'Design and implement a database for a library management system. Include ER diagram, normalized tables, and SQL queries.',
        'subject': 'Database Management',
        'dueDate':
            Timestamp.fromDate(DateTime.now().add(const Duration(days: 10))),
        'totalMarks': 100,
        'attachments': [],
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var task in sampleTasks) {
      await _firestore.collection('tasks').add(task);
    }

    print('Sample tasks created successfully!');
  }

  Future<void> _createSampleQuizzes() async {
    print('Creating sample quizzes...');

    final sampleQuizzes = [
      {
        'title': 'Object-Oriented Programming Basics',
        'description':
            'Test your knowledge of OOP concepts including inheritance, polymorphism, and encapsulation.',
        'subject': 'Object-Oriented Programming',
        'duration': 30,
        'totalMarks': 20,
        'questions': [
          {
            'question': 'What is encapsulation in OOP?',
            'options': [
              'Hiding implementation details',
              'Creating multiple objects',
              'Inheriting properties',
              'Overloading methods'
            ],
            'correctAnswer': 0,
            'marks': 5,
          },
          {
            'question': 'Which keyword is used for inheritance in Java?',
            'options': ['implements', 'extends', 'inherits', 'super'],
            'correctAnswer': 1,
            'marks': 5,
          },
        ],
        'isPublished': true,
        'startTime': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 2))),
        'endTime':
            Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Database Normalization Quiz',
        'description':
            'Test your understanding of database normalization forms (1NF, 2NF, 3NF, BCNF).',
        'subject': 'Database Management',
        'duration': 20,
        'totalMarks': 15,
        'questions': [
          {
            'question': 'What does 1NF require?',
            'options': [
              'No repeating groups',
              'No partial dependencies',
              'No transitive dependencies',
              'All of the above'
            ],
            'correctAnswer': 0,
            'marks': 5,
          },
        ],
        'isPublished': true,
        'startTime': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 1))),
        'endTime':
            Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var quiz in sampleQuizzes) {
      await _firestore.collection('quizzes').add(quiz);
    }

    print('Sample quizzes created successfully!');
  }
}
