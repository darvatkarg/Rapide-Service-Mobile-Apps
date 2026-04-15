import 'package:equatable/equatable.dart';

abstract class PhoneAuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state
class PhoneAuthInitial extends PhoneAuthState {}

/// Loading state while sending OTP
class PhoneAuthSendingOTP extends PhoneAuthState {}

/// OTP sent successfully
class PhoneAuthOTPSent extends PhoneAuthState {
  final String verificationId;
  final String message;

  PhoneAuthOTPSent({required this.verificationId, required this.message});

  @override
  List<Object?> get props => [verificationId, message];
}

/// Loading state while verifying OTP
class PhoneAuthVerifyingOTP extends PhoneAuthState {}

/// OTP verified successfully and idToken obtained
class PhoneAuthOTPVerified extends PhoneAuthState {
  final String idToken;
  final String message;

  PhoneAuthOTPVerified({required this.idToken, required this.message});

  @override
  List<Object?> get props => [idToken, message];
}

/// Loading state while authenticating with backend
class PhoneAuthAuthenticating extends PhoneAuthState {}

/// Authentication successful with backend
class PhoneAuthSuccess extends PhoneAuthState {
  final String message;
  final String accessToken;

  PhoneAuthSuccess({required this.message, required this.accessToken});

  @override
  List<Object?> get props => [message, accessToken];
}

/// Phone authentication failed
class PhoneAuthFailure extends PhoneAuthState {
  final String error;

  PhoneAuthFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

/// Registration in progress after OTP verification
class PhoneAuthRegistering extends PhoneAuthState {}

/// Registration successful
class PhoneAuthRegistrationSuccess extends PhoneAuthState {
  final String message;
  final String accessToken;

  PhoneAuthRegistrationSuccess({
    required this.message,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [message, accessToken];
}

class PhoneAuthUserNotFound extends PhoneAuthState {
  final String message;
  PhoneAuthUserNotFound({required this.message});
}
