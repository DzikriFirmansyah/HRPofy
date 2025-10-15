class EmployeeModel {
  final String id;
  final String idCard;
  final String name;
  final String phone;
  final String birthPlace;
  final String birthDate;
  final String addressKTP;
  final String addressNow;
  final String ktaNumber;
  final String ktaExpired;
  final String joinDate;
  final String placement;
  final String status;
  final String bpjsHealth;
  final String bpjsTK;
  final double salaryBasic;
  final double allowanceHouse;
  final double allowanceMeal;
  final double allowanceTransport;
  final double allowancePosition;
  final double deductionBPJSHealth;
  final double deductionBPJSTK;
  final double takeHomePay;
  final String photoPath;

  EmployeeModel({
    required this.id,
    required this.idCard,
    required this.name,
    required this.phone,
    required this.birthPlace,
    required this.birthDate,
    required this.addressKTP,
    required this.addressNow,
    required this.ktaNumber,
    required this.ktaExpired,
    required this.joinDate,
    required this.placement,
    required this.status,
    required this.bpjsHealth,
    required this.bpjsTK,
    required this.salaryBasic,
    required this.allowanceHouse,
    required this.allowanceMeal,
    required this.allowanceTransport,
    required this.allowancePosition,
    required this.deductionBPJSHealth,
    required this.deductionBPJSTK,
    required this.takeHomePay,
    required this.photoPath,
  });

  // Convert dari Map (untuk ambil data dari database)
  factory EmployeeModel.fromMap(Map<String, dynamic> json) => EmployeeModel(
        id: json['id'],
        idCard: json['idCard'],
        name: json['name'],
        phone: json['phone'],
        birthPlace: json['birthPlace'],
        birthDate: json['birthDate'],
        addressKTP: json['addressKTP'],
        addressNow: json['addressNow'],
        ktaNumber: json['ktaNumber'],
        ktaExpired: json['ktaExpired'],
        joinDate: json['joinDate'],
        placement: json['placement'],
        status: json['status'],
        bpjsHealth: json['bpjsHealth'],
        bpjsTK: json['bpjsTK'],
        salaryBasic: (json['salaryBasic'] ?? 0).toDouble(),
        allowanceHouse: (json['allowanceHouse'] ?? 0).toDouble(),
        allowanceMeal: (json['allowanceMeal'] ?? 0).toDouble(),
        allowanceTransport: (json['allowanceTransport'] ?? 0).toDouble(),
        allowancePosition: (json['allowancePosition'] ?? 0).toDouble(),
        deductionBPJSHealth: (json['deductionBPJSHealth'] ?? 0).toDouble(),
        deductionBPJSTK: (json['deductionBPJSTK'] ?? 0).toDouble(),
        takeHomePay: (json['takeHomePay'] ?? 0).toDouble(),
        photoPath: json['photoPath'] ?? '',
      );

  // Convert ke Map (untuk simpan ke database)
  Map<String, dynamic> toMap() => {
        'id': id,
        'idCard': idCard,
        'name': name,
        'phone': phone,
        'birthPlace': birthPlace,
        'birthDate': birthDate,
        'addressKTP': addressKTP,
        'addressNow': addressNow,
        'ktaNumber': ktaNumber,
        'ktaExpired': ktaExpired,
        'joinDate': joinDate,
        'placement': placement,
        'status': status,
        'bpjsHealth': bpjsHealth,
        'bpjsTK': bpjsTK,
        'salaryBasic': salaryBasic,
        'allowanceHouse': allowanceHouse,
        'allowanceMeal': allowanceMeal,
        'allowanceTransport': allowanceTransport,
        'allowancePosition': allowancePosition,
        'deductionBPJSHealth': deductionBPJSHealth,
        'deductionBPJSTK': deductionBPJSTK,
        'takeHomePay': takeHomePay,
        'photoPath': photoPath,
      };
}
