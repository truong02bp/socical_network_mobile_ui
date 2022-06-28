
const IP = "192.168.0.105";
const version = "v1";
final host = "http://$IP:8080";
final minioHost = "http://$IP:9000/media";

final mediaUrl = host + "/api/$version/media";
final userUrl = host + "/api/$version/user";
final mailUrl = host + "/api/$version/mail";
final authenticateUrl = host + "/api/$version/authenticate";