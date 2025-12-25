import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String role;
  final String? rollNumber;
  final String? department;
  final int? year;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    this.rollNumber,
    this.department,
    this.year,
  });

  @override
  List<Object?> get props =>
      [email, password, name, role, rollNumber, department, year];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignOutRequested extends AuthEvent {}

class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
