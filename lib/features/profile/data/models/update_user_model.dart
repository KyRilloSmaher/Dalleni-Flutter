class UpdateUserAccount {
  const UpdateUserAccount({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.userName,
    this.phoneNumber,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String userName;
  final String? phoneNumber;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'phoneNumber': phoneNumber,
      // Adding PascalCase versions commonly expected by .NET if serialization settings differ
      'Id': id,
      'FirstName': firstName,
      'LastName': lastName,
      'UserName': userName,
      'PhoneNumber': phoneNumber,
    };
  }
}
