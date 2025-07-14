// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthViewmodel on _AuthViewmodelBase, Store {
  late final _$isLoadingAtom = Atom(
    name: '_AuthViewmodelBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: '_AuthViewmodelBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$showPasswordAtom = Atom(
    name: '_AuthViewmodelBase.showPassword',
    context: context,
  );

  @override
  bool get showPassword {
    _$showPasswordAtom.reportRead();
    return super.showPassword;
  }

  @override
  set showPassword(bool value) {
    _$showPasswordAtom.reportWrite(value, super.showPassword, () {
      super.showPassword = value;
    });
  }

  late final _$showConfirmPasswordAtom = Atom(
    name: '_AuthViewmodelBase.showConfirmPassword',
    context: context,
  );

  @override
  bool get showConfirmPassword {
    _$showConfirmPasswordAtom.reportRead();
    return super.showConfirmPassword;
  }

  @override
  set showConfirmPassword(bool value) {
    _$showConfirmPasswordAtom.reportWrite(value, super.showConfirmPassword, () {
      super.showConfirmPassword = value;
    });
  }

  late final _$signInWithEmailAndPasswordAsyncAction = AsyncAction(
    '_AuthViewmodelBase.signInWithEmailAndPassword',
    context: context,
  );

  @override
  Future<bool> signInWithEmailAndPassword(String email, String password) {
    return _$signInWithEmailAndPasswordAsyncAction.run(
      () => super.signInWithEmailAndPassword(email, password),
    );
  }

  late final _$registerWithEmailAndPasswordAsyncAction = AsyncAction(
    '_AuthViewmodelBase.registerWithEmailAndPassword',
    context: context,
  );

  @override
  Future<bool> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) {
    return _$registerWithEmailAndPasswordAsyncAction.run(
      () => super.registerWithEmailAndPassword(email, password, name),
    );
  }

  late final _$signInWithGoogleAsyncAction = AsyncAction(
    '_AuthViewmodelBase.signInWithGoogle',
    context: context,
  );

  @override
  Future<bool> signInWithGoogle() {
    return _$signInWithGoogleAsyncAction.run(() => super.signInWithGoogle());
  }

  late final _$signOutAsyncAction = AsyncAction(
    '_AuthViewmodelBase.signOut',
    context: context,
  );

  @override
  Future<void> signOut() {
    return _$signOutAsyncAction.run(() => super.signOut());
  }

  late final _$_AuthViewmodelBaseActionController = ActionController(
    name: '_AuthViewmodelBase',
    context: context,
  );

  @override
  void togglePasswordVisibility() {
    final _$actionInfo = _$_AuthViewmodelBaseActionController.startAction(
      name: '_AuthViewmodelBase.togglePasswordVisibility',
    );
    try {
      return super.togglePasswordVisibility();
    } finally {
      _$_AuthViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleConfirmPasswordVisibility() {
    final _$actionInfo = _$_AuthViewmodelBaseActionController.startAction(
      name: '_AuthViewmodelBase.toggleConfirmPasswordVisibility',
    );
    try {
      return super.toggleConfirmPasswordVisibility();
    } finally {
      _$_AuthViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$_AuthViewmodelBaseActionController.startAction(
      name: '_AuthViewmodelBase.clearError',
    );
    try {
      return super.clearError();
    } finally {
      _$_AuthViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
errorMessage: ${errorMessage},
showPassword: ${showPassword},
showConfirmPassword: ${showConfirmPassword}
    ''';
  }
}
