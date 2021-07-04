class Register {
  static Set<Register> _registers = Set();

  void Function() initializer;
  Register(this.initializer);

  void call() {
    if (!_registers.contains(this)) {
      _registers.add(this);
      initializer();
    }
  }

  @override
  int get hashCode => 0x43000000 | (initializer?.hashCode ?? 0);

  @override
  bool operator ==(Object other) {
    if (other is Register) {
      return initializer == other.initializer;
    }
    return super == other;
  }
}
