enum BotPersonality {
  playful(nameVi: 'Tinh nghịch'),
  cautious(nameVi: 'Cẩn trọng'),
  balanced(nameVi: 'Cân bằng'),
  aggressive(nameVi: 'Tấn công dồn dập'),
  tactical(nameVi: 'Chiến thuật sắc bén'),
  ruthless(nameVi: 'Tàn nhẫn');

  final String nameVi;
  const BotPersonality({required this.nameVi});
}
