enum GamePhase {
  setup,
  playerTurn,
  engineThinking,
  animating,
  gameOver,
  paused;

  bool get canReceiveInput => this == GamePhase.playerTurn;
}

enum GameMode {
  vsAi,
  localPvp;

  bool get isVsAi => this == GameMode.vsAi;
  bool get isLocalPvp => this == GameMode.localPvp;
}
