class Budget {
  final int? id;
  final double amount;
  final String startDate;

  Budget({
    this.id,
    required this.amount,
    required this.startDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'start_date': startDate,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      amount: map['amount'],
      startDate: map['start_date'],
    );
  }
}