// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registrar_viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RegistrarViewmodel on RegistrarViewmodelBase, Store {
  late final _$isLoadingAtom = Atom(
    name: 'RegistrarViewmodelBase.isLoading',
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
    name: 'RegistrarViewmodelBase.errorMessage',
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

  late final _$successMessageAtom = Atom(
    name: 'RegistrarViewmodelBase.successMessage',
    context: context,
  );

  @override
  String? get successMessage {
    _$successMessageAtom.reportRead();
    return super.successMessage;
  }

  @override
  set successMessage(String? value) {
    _$successMessageAtom.reportWrite(value, super.successMessage, () {
      super.successMessage = value;
    });
  }

  late final _$showPasswordAtom = Atom(
    name: 'RegistrarViewmodelBase.showPassword',
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
    name: 'RegistrarViewmodelBase.showConfirmPassword',
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

  late final _$registerWithEmailAndPasswordAsyncAction = AsyncAction(
    'RegistrarViewmodelBase.registerWithEmailAndPassword',
    context: context,
  );

  @override
  Future<bool> registerWithEmailAndPassword(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) {
    return _$registerWithEmailAndPasswordAsyncAction.run(
      () => super.registerWithEmailAndPassword(
        name,
        email,
        password,
        confirmPassword,
      ),
    );
  }

  late final _$signInWithGoogleAsyncAction = AsyncAction(
    'RegistrarViewmodelBase.signInWithGoogle',
    context: context,
  );

  @override
  Future<bool> signInWithGoogle() {
    return _$signInWithGoogleAsyncAction.run(() => super.signInWithGoogle());
  }

  late final _$RegistrarViewmodelBaseActionController = ActionController(
    name: 'RegistrarViewmodelBase',
    context: context,
  );

  @override
  void togglePasswordVisibility() {
    final _$actionInfo = _$RegistrarViewmodelBaseActionController.startAction(
      name: 'RegistrarViewmodelBase.togglePasswordVisibility',
    );
    try {
      return super.togglePasswordVisibility();
    } finally {
      _$RegistrarViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleConfirmPasswordVisibility() {
    final _$actionInfo = _$RegistrarViewmodelBaseActionController.startAction(
      name: 'RegistrarViewmodelBase.toggleConfirmPasswordVisibility',
    );
    try {
      return super.toggleConfirmPasswordVisibility();
    } finally {
      _$RegistrarViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearMessages() {
    final _$actionInfo = _$RegistrarViewmodelBaseActionController.startAction(
      name: 'RegistrarViewmodelBase.clearMessages',
    );
    try {
      return super.clearMessages();
    } finally {
      _$RegistrarViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
errorMessage: ${errorMessage},
successMessage: ${successMessage},
showPassword: ${showPassword},
showConfirmPassword: ${showConfirmPassword}
    ''';
  }
}
