import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class StudentProfileModel extends Equatable {
  final String uid;
  final String phone;
  final String bio;
  final String? githubUrl;
  final String? leetcodeUrl;
  final String? hackerrankUrl;
  final String? linkedinUrl;
  final String? portfolioUrl;
  final List<String> skills;
  final List<ProjectModel> projects;
  final double? cgpa;

  const StudentProfileModel({
    required this.uid,
    this.phone = '',
    this.bio = '',
    this.githubUrl,
    this.leetcodeUrl,
    this.hackerrankUrl,
    this.linkedinUrl,
    this.portfolioUrl,
    this.skills = const [],
    this.projects = const [],
    this.cgpa,
  });

  factory StudentProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudentProfileModel(
      uid: doc.id,
      phone: data['phone'] ?? '',
      bio: data['bio'] ?? '',
      githubUrl: data['githubUrl'],
      leetcodeUrl: data['leetcodeUrl'],
      hackerrankUrl: data['hackerrankUrl'],
      linkedinUrl: data['linkedinUrl'],
      portfolioUrl: data['portfolioUrl'],
      skills: List<String>.from(data['skills'] ?? []),
      projects: (data['projects'] as List<dynamic>?)
              ?.map((p) => ProjectModel.fromMap(p))
              .toList() ??
          [],
      cgpa: data['cgpa']?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'phone': phone,
      'bio': bio,
      'githubUrl': githubUrl,
      'leetcodeUrl': leetcodeUrl,
      'hackerrankUrl': hackerrankUrl,
      'linkedinUrl': linkedinUrl,
      'portfolioUrl': portfolioUrl,
      'skills': skills,
      'projects': projects.map((p) => p.toMap()).toList(),
      'cgpa': cgpa,
    };
  }

  StudentProfileModel copyWith({
    String? phone,
    String? bio,
    String? githubUrl,
    String? leetcodeUrl,
    String? hackerrankUrl,
    String? linkedinUrl,
    String? portfolioUrl,
    List<String>? skills,
    List<ProjectModel>? projects,
    double? cgpa,
  }) {
    return StudentProfileModel(
      uid: uid,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      githubUrl: githubUrl ?? this.githubUrl,
      leetcodeUrl: leetcodeUrl ?? this.leetcodeUrl,
      hackerrankUrl: hackerrankUrl ?? this.hackerrankUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      cgpa: cgpa ?? this.cgpa,
    );
  }

  @override
  List<Object?> get props => [uid, phone, bio, skills, projects, cgpa];
}

class ProjectModel extends Equatable {
  final String title;
  final String description;
  final String? url;
  final List<String> technologies;

  const ProjectModel({
    required this.title,
    required this.description,
    this.url,
    this.technologies = const [],
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      url: map['url'],
      technologies: List<String>.from(map['technologies'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'technologies': technologies,
    };
  }

  @override
  List<Object?> get props => [title, description, url, technologies];
}
