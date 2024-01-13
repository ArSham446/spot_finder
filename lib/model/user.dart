class Patients {
  String? userUID;
  String? userName;
  String? userEmail;
  String? userPhone;
  String? userAvatarUrl;

  Patients({
    this.userUID,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.userAvatarUrl,
  });

  Patients.fromJson(Map<String, dynamic> json) {
    userUID = json["UserUID"];
    userName = json["UserName"];
    userEmail = json["UserEmail"];
    userPhone = json["UserPhone"];
    userAvatarUrl = json["UserAvatarUrl"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data["UserUID"] = userUID;
    data["UserName"] = userName;
    data["UserEmail"] = userEmail;
    data["UserPhone"] = userPhone;
    data["UserAvatarUrl"] = userAvatarUrl;
    return data;
  }
}
