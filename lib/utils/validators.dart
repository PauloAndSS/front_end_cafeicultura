bool cpfValidator(String cpf){
  cpf = cpf.trim();
  cpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
  if (cpf.length != 11) {
    return false;
  }
  return true;
}

bool emailValidator(String email){
  email = email.trim();
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  
  return email.isNotEmpty && emailRegex.hasMatch(email);
}