// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LoginViewModel on LoginViewmodelBase, Store {
  late final _$_chengeObscureTextAtom = Atom(
    name: 'LoginViewmodelBase._chengeObscureText',
    context: context,
  );

  @override
  bool get _chengeObscureText {
    _$_chengeObscureTextAtom.reportRead();
    return super._chengeObscureText;
  }

  @override
  set _chengeObscureText(bool value) {
    _$_chengeObscureTextAtom.reportWrite(value, super._chengeObscureText, () {
      super._chengeObscureText = value;
    });
  }

  late final _$_isLoadingAtom = Atom(
    name: 'LoginViewmodelBase._isLoading',
    context: context,
  );

  @override
  bool get _isLoading {
    _$_isLoadingAtom.reportRead();
    return super._isLoading;
  }

  @override
  set _isLoading(bool value) {
    _$_isLoadingAtom.reportWrite(value, super._isLoading, () {
      super._isLoading = value;
    });
  }

  late final _$_errorMessageAtom = Atom(
    name: 'LoginViewmodelBase._errorMessage',
    context: context,
  );

  @override
  String? get _errorMessage {
    _$_errorMessageAtom.reportRead();
    return super._errorMessage;
  }

  @override
  set _errorMessage(String? value) {
    _$_errorMessageAtom.reportWrite(value, super._errorMessage, () {
      super._errorMessage = value;
    });
  }

  late final _$loginWithGoogleAsyncAction = AsyncAction(
    'LoginViewmodelBase.loginWithGoogle',
    context: context,
  );

  @override
  Future<bool> loginWithGoogle() {
    return _$loginWithGoogleAsyncAction.run(() => super.loginWithGoogle());
  }

  late final _$loginWithEmailAndPasswordAsyncAction = AsyncAction(
    'LoginViewmodelBase.loginWithEmailAndPassword',
    context: context,
  );

  @override
  Future<bool> loginWithEmailAndPassword(String email, String password) {
    return _$loginWithEmailAndPasswordAsyncAction.run(
      () => super.loginWithEmailAndPassword(email, password),
    );
  }

  late final _$registerWithEmailAndPasswordAsyncAction = AsyncAction(
    'LoginViewmodelBase.registerWithEmailAndPassword',
    context: context,
  );

  @override
  Future<bool> registerWithEmailAndPassword(
    String email,
    String password,
    String confirmPassword, {
    String? displayName,
  }) {
    return _$registerWithEmailAndPasswordAsyncAction.run(
      () => super.registerWithEmailAndPassword(
        email,
        password,
        confirmPassword,
        displayName: displayName,
      ),
    );
  }

  late final _$logoutAsyncAction = AsyncAction(
    'LoginViewmodelBase.logout',
    context: context,
  );

  @override
  Future<void> logout() {
    return _$logoutAsyncAction.run(() => super.logout());
  }

  late final _$loginOfflineAsyncAction = AsyncAction(
    'LoginViewmodelBase.loginOffline',
    context: context,
  );

  @override
  Future<bool> loginOffline() {
    return _$loginOfflineAsyncAction.run(() => super.loginOffline());
  }

  late final _$LoginViewmodelBaseActionController = ActionController(
    name: 'LoginViewmodelBase',
    context: context,
  );

  @override
  void toggleObscureText() {
    final _$actionInfo = _$LoginViewmodelBaseActionController.startAction(
      name: 'LoginViewmodelBase.toggleObscureText',
    );
    try {
      return super.toggleObscureText();
    } finally {
      _$LoginViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$LoginViewmodelBaseActionController.startAction(
      name: 'LoginViewmodelBase.clearError',
    );
    try {
      return super.clearError();
    } finally {
      _$LoginViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _setLoading(bool value) {
    final _$actionInfo = _$LoginViewmodelBaseActionController.startAction(
      name: 'LoginViewmodelBase._setLoading',
    );
    try {
      return super._setLoading(value);
    } finally {
      _$LoginViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _setErrorMessage(String? message) {
    final _$actionInfo = _$LoginViewmodelBaseActionController.startAction(
      name: 'LoginViewmodelBase._setErrorMessage',
    );
    try {
      return super._setErrorMessage(message);
    } finally {
      _$LoginViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
