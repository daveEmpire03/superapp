import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure(
      [super.message = 'Server encountered an error. Please try again.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure(
      [super.message = 'No internet connection detected. Check your network.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load cached local data.']);
}

class AuthFailure extends Failure {
  const AuthFailure(
      [super.message = 'Authentication failed. Please verify credentials.']);
}
