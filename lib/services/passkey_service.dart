import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import 'auth_service.dart';

class PasskeyService {
  static final PasskeyAuthenticator _authenticator = PasskeyAuthenticator();

  static Future<bool> isSupported() async {
    return await _authenticator.canAuthenticate();
  }

  static Future<void> registerWithPasskey(String username, String displayName) async {
    try {
      final options = await AuthService.startRegistration(username, displayName);

      final request = RegisterRequestType(
        challenge: options['challenge'],
        relyingParty: RelyingPartyType(
          id: options['rpId'],
          name: options['rpName'],
        ),
        user: UserType(
          id: options['user']['id'],
          name: options['user']['name'],
          displayName: options['user']['displayName'],
        ),
        excludeCredentials: [],
        pubKeyCredParams: [
          PubKeyCredParamType(alg: -7, type: 'public-key'),
          PubKeyCredParamType(alg: -257, type: 'public-key'),
        ],
        timeout: options['timeout'],
        authSelectionType: AuthenticatorSelectionType(
          requireResidentKey: true,
          residentKey: 'required',
          userVerification: 'required',
        ),
      );

      final response = await _authenticator.register(request);

      final verification = await AuthService.finishRegistration(
        username,
        {
          'id': response.id,
          'clientDataJSON': response.clientDataJSON,
          'attestationObject': response.attestationObject,
        },
      );

      if (verification['success'] != true) {
        throw Exception('Registration verification failed');
      }
    } catch (e) {
      throw Exception('Passkey registration failed: $e');
    }
  }

  static Future<bool> authenticateWithPasskey(String username) async {
    try {
      final options = await AuthService.startAuthentication(username);

      final request = AuthenticateRequestType(
        challenge: options['challenge'],
        relyingPartyId: options['rpId'],
        timeout: options['timeout'],
        userVerification: 'required',
        mediation: MediationType.Optional,
        preferImmediatelyAvailableCredentials: false,
      );

      final response = await _authenticator.authenticate(request);

      final verification = await AuthService.finishAuthentication(
        username,
        {
          'id': response.id,
          'clientDataJSON': response.clientDataJSON,
          'authenticatorData': response.authenticatorData,
          'signature': response.signature,
        },
      );

      return verification['success'] == true;
    } catch (e) {
      throw Exception('Passkey authentication failed: $e');
    }
  }
}