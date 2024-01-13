class Patients {
  String? UserUID;
  String? UserName;
  String? UserEmail;
  String? UserPhone;
  String? UserAvatarUrl;

  Patients({
    this.UserUID,
    this.UserName,
    this.UserEmail,
    this.UserPhone,
    this.UserAvatarUrl,
  });

  Patients.fromJson(Map<String, dynamic> json) {
    UserUID = json["UserUID"];
    UserName = json["UserName"];
    UserEmail = json["UserEmail"];
    UserPhone = json["UserPhone"];
    UserAvatarUrl = json["UserAvatarUrl"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data["UserUID"] = UserUID;
    data["UserName"] = UserName;
    data["UserEmail"] = UserEmail;
    data["UserPhone"] = UserPhone;
    data["UserAvatarUrl"] = UserAvatarUrl;
    return data;
  }
}
