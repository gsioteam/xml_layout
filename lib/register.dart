class Register {
  bool _registered = false;

  void Function() initializer;
  Register(this.initializer);

  void call() {
    if (!_registered) {
      _registered = true;
      initializer();
    }
  }
}
