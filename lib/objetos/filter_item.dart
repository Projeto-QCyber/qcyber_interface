class FilterItem {
  final int id;
  final String nome;

  FilterItem({required this.id, required this.nome});

  factory FilterItem.fromJson(Map<String, dynamic> json) {
    return FilterItem(id: json['id'], nome: json['nome']);
  }
}