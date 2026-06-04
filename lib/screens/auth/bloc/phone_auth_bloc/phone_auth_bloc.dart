import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hyper_local/config/global.dart';
import 'package:hyper_local/screens/auth/repo/auth_repo.dart';
import 'package:hyper_local/screens/auth/repo/phone_auth_repo.dart';
import 'dart:io';
import 'phone_auth_event.dart';
import 'phone_auth_state.dart';

class PhoneAuthBloc extends Bloc<PhoneAuthEvent, PhoneAuthState> {
  final PhoneAuthRepository _phoneAuthRepository = PhoneAuthRepository();

  PhoneAuthBloc() : super(PhoneAuthInitial()) {
    on<SendOTPEvent>(_onSendOTP);
    on<SendOTPForRegistrationEvent>(_onSendOTPForRegistration);
    on<VerifyOTPEvent>(_onVerifyOTP);
    on<VerifyOTPAndRegisterEvent>(_onVerifyOTPAndRegister);
    on<AutoVerificationCompletedEvent>(_onAutoVerificationCompleted);
    on<ResendOTPEvent>(_onResendOTP);
    on<ResetPhoneAuthEvent>(_onResetPhoneAuth);
  }

  Future<void> _onSendOTP(
    SendOTPEvent event,
    Emitter<PhoneAuthState> emit,
  ) async {
    emit(PhoneAuthSendingOTP());
    try {
      if (kDebugMode) {
        debugPrint('📱 Sending OTP to: ${event.phoneNumber}');
      }

      final result = await _phoneAuthRepository.sendOTP(
        phoneNumber: event.phoneNumber,
      );

      if (!emit.isDone) {
        if (result['autoVerified'] == true) {
          // Auto verification completed
          add(
            AutoVerificationCompletedEvent(
              credential: result['credential'] as PhoneAuthCredential,
            ),
          );
        } else {
          // OTP sent successfully
          emit(
            PhoneAuthOTPSent(
              verificationId: result['verificationId'],
              message: 'OTP sent successfully to ${event.phoneNumber}',
            ),
          );
        }
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(PhoneAuthFailure(error: e.toString()));
      }
    }
  }

  Future<void> _onVerifyOTP(
    VerifyOTPEvent event,
    Emitter<PhoneAuthState> emit,
  ) async {
    emit(PhoneAuthVerifyingOTP());
    try {
      // Verify OTP and get idToken
      final verifyResult = await _phoneAuthRepository.verifyOTP(
        verificationId: event.verificationId,
        otp: event.otp,
      );

      if (verifyResult['success'] == true) {
        final String idToken = verifyResult['idToken'];

        emit(
          PhoneAuthOTPVerified(
            idToken: idToken,
            message: 'OTP verified successfully',
          ),
        );

        // Send idToken to backend
        emit(PhoneAuthAuthenticating());

        final response = await _phoneAuthRepository.sendIdTokenToBackend(
          idToken: idToken,
        );

        if (response.success) {
          final accessToken = response.accessToken ?? '';

          if (kDebugMode) {
            debugPrint('💾 Saving tokens...');
            debugPrint('Access Token: $accessToken');
            debugPrint('ID Token: $idToken');
          }

          // Store both idToken and accessToken
          await Global.setUserToken(accessToken);
          await Global.setIdToken(idToken);

          // Refresh cached token to ensure it's loaded
          await Global.refreshCachedToken();

          if (kDebugMode) {
            final savedToken = await Global.getUserToken();
            debugPrint(
              '✅ Token saved and verified: ${savedToken?.isNotEmpty ?? false}',
            );
            debugPrint('Saved Token: $savedToken');
          }

          emit(
            PhoneAuthSuccess(
              message: response.message,
              accessToken: accessToken,
            ),
          );
        } else {
          emit(PhoneAuthFailure(error: response.message));
        }
      } else {
        emit(PhoneAuthFailure(error: 'OTP verification failed'));
      }
    } on UserNotFoundException catch (e) {
      await _phoneAuthRepository.signOut();
      emit(PhoneAuthUserNotFound(message: e.message));
    } catch (e) {
      emit(PhoneAuthFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAutoVerificationCompleted(
    AutoVerificationCompletedEvent event,
    Emitter<PhoneAuthState> emit,
  ) async {
    emit(PhoneAuthVerifyingOTP());
    try {
      // Sign in with credential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        event.credential,
      );

      // Get ID Token
      String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        emit(PhoneAuthFailure(error: 'Failed to get ID token'));
        return;
      }

      emit(
        PhoneAuthOTPVerified(
          idToken: idToken,
          message: 'Phone verified automatically',
        ),
      );

      // Send idToken to backend
      emit(PhoneAuthAuthenticating());

      final response = await _phoneAuthRepository.sendIdTokenToBackend(
        idToken: idToken,
      );

      if (response.success) {
        final accessToken = response.accessToken ?? '';

        if (kDebugMode) {
          debugPrint('💾 [Auto-Verify] Saving tokens...');
          debugPrint('Access Token: $accessToken');
          debugPrint('ID Token: $idToken');
        }

        // Store both idToken and accessToken
        await Global.setUserToken(accessToken);
        await Global.setIdToken(idToken);

        // Refresh cached token to ensure it's loaded
        await Global.refreshCachedToken();

        if (kDebugMode) {
          final savedToken = await Global.getUserToken();
          debugPrint(
            '✅ [Auto-Verify] Token saved: ${savedToken?.isNotEmpty ?? false}',
          );
        }

        emit(
          PhoneAuthSuccess(message: response.message, accessToken: accessToken),
        );
      } else {
        emit(PhoneAuthFailure(error: response.message));
      }
    } on UserNotFoundException catch (e) {
      await _phoneAuthRepository.signOut();
      emit(PhoneAuthUserNotFound(message: e.message));
    } catch (e) {
      emit(PhoneAuthFailure(error: e.toString()));
    }
  }

  Future<void> _onResendOTP(
    ResendOTPEvent event,
    Emitter<PhoneAuthState> emit,
  ) async {
    emit(PhoneAuthSendingOTP());
    try {
      final result = await _phoneAuthRepository.resendOTP(
        phoneNumber: event.phoneNumber,
      );

      if (!emit.isDone) {
        if (result['autoVerified'] == true) {
          // Auto verification completed
          add(
            AutoVerificationCompletedEvent(
              credential: result['credential'] as PhoneAuthCredential,
            ),
          );
        } else {
          // OTP sent successfully
          emit(
            PhoneAuthOTPSent(
              verificationId: result['verificationId'],
              message: 'OTP resent successfully',
            ),
          );
        }
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(PhoneAuthFailure(error: e.toString()));
      }
    }
  }

  Future<void> _onResetPhoneAuth(
    ResetPhoneAuthEvent event,
    Emitter<PhoneAuthState> emit,
  ) async {
    emit(PhoneAuthInitial());
  }

  Future<void> _onSendOTPForRegistration(
    SendOTPForRegistrationEvent event,
    Emitter<PhoneAuthState> emit,
  ) async {
    emit(PhoneAuthSendingOTP());
    try {
      if (kDebugMode) {
        debugPrint('📱 Sending OTP for registration to: ${event.phoneNumber}');
      }

      final result = await _phoneAuthRepository.sendOTP(
        phoneNumber: event.phoneNumber,
      );

      if (!emit.isDone) {
        if (result['autoVerified'] == true) {
          // Auto verification completed - proceed with registration
          final userCredential = await FirebaseAuth.instance
              .signInWithCredential(
                result['credential'] as PhoneAuthCredential,
              );
          String? idToken = await userCredential.user?.getIdToken();

          if (idToken != null) {
            // Call register API directly
            add(
              VerifyOTPAndRegisterEvent(
                verificationId: '',
                otp: '',
                registrationData: event.registrationData,
              ),
            );
          } else {
            emit(PhoneAuthFailure(error: 'Failed to get ID token'));
          }
        } else {
          // OTP sent successfully
          emit(
            PhoneAuthOTPSent(
              verificationId: result['verificationId'],
              message: 'OTP sent successfully to ${event.phoneNumber}',
            ),
          );
        }
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(PhoneAuthFailure(error: e.toString()));
      }
    }
  }

  Future<void> _onVerifyOTPAndRegister(
    VerifyOTPAndRegisterEvent event,
    Emitter<PhoneAuthState> emit,
  ) async {
    emit(PhoneAuthVerifyingOTP());
    try {
      // Verify OTP and get idToken
      final verifyResult = await _phoneAuthRepository.verifyOTP(
        verificationId: event.verificationId,
        otp: event.otp,
      );

      if (verifyResult['success'] == true) {
        final String idToken = verifyResult['idToken'];

        emit(
          PhoneAuthOTPVerified(
            idToken: idToken,
            message: 'OTP verified successfully',
          ),
        );

        // Call registration API
        emit(PhoneAuthRegistering());

        final regData = event.registrationData;

        if (kDebugMode) {
          debugPrint('📝 Starting registration with OTP verified...');
        }

        final response = await AuthRepository().register(
          name: regData['name'],
          email: regData['email'],
          mobile: regData['mobile'],
          country: regData['country'],
          iso2: regData['iso2'],
          password: regData['password'],
          confirmPassword: regData['confirmPassword'],
          address: regData['address'],
          driverLicenseNumber: regData['driverLicenseNumber'],
          vehicleType: regData['vehicleType'],
          deliveryZoneId: regData['deliveryZoneId'],
          driverLicenseFile: regData['driverLicenseFile'] as File,
          vehicleRegistrationFile: regData['vehicleRegistrationFile'] as File,
        );

        if (response['success'] == true) {
          final accessToken = response['access_token']?.toString() ?? '';

          if (kDebugMode) {
            debugPrint('💾 Registration successful! Saving tokens...');
            debugPrint('Access Token: $accessToken');
          }

          // Store tokens
          await Global.setUserToken(accessToken);
          await Global.setIdToken(idToken);
          await Global.refreshCachedToken();

          if (kDebugMode) {
            final savedToken = await Global.getUserToken();
            debugPrint(
              '✅ Token saved after registration: ${savedToken?.isNotEmpty ?? false}',
            );
          }

          emit(
            PhoneAuthRegistrationSuccess(
              message: response['message'] ?? 'Registration successful',
              accessToken: accessToken,
            ),
          );
        } else {
          emit(
            PhoneAuthFailure(
              error: response['message'] ?? 'Registration failed',
            ),
          );
        }
      } else {
        emit(PhoneAuthFailure(error: 'OTP verification failed'));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Registration error: $e');
      }
      emit(PhoneAuthFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
