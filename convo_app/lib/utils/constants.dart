class Constants {
  static const String baseUrl = "http://10.0.2.2:3000/api";
  static const String userUrl = "$baseUrl/users";
  static const String loginUrl = "$baseUrl/users/login";
  static const String updateUrl = "$baseUrl/users/profile";
  static const String profileImageUrl = "$baseUrl/users/profile/image";
  static const String registerUrl = "$baseUrl/users/register";
  static const String getAllchats = "$baseUrl/messages/chats";
  static const String sendMsg = "$baseUrl/messages/send";
  static const String sendImage = "$baseUrl/messages/image";
  static const String friendUrl = "$baseUrl/users/friends";
  static const String friendRemoveUrl = "$baseUrl/users/friends";
  static const String friendRequestUrl = "$baseUrl/users/friends-requests/received";
  static const String friendRequestSendUrl = "$baseUrl/users/friends-request/sent";
  static const String friendRequestAcceptUrl = "$baseUrl/users/friends-request/accept";
  static const String friendRequestDeclineUrl = "$baseUrl/users/friends-request/reject";
}