import 'package:social_network_mobile_ui/constants/host_api.dart';
import 'package:social_network_mobile_ui/models/api_model.dart';
import 'package:social_network_mobile_ui/models/dto/follow_relation_dto.dart';
import 'package:social_network_mobile_ui/repositories/api_repository.dart';

class FollowRepository {
  static final FollowRepository _instance = FollowRepository();
  final ApiRepository apiRepository = new ApiRepository();

  static getInstance() {
    return _instance;
  }

  Future<List<FollowRelationDto>> getFollowers(
      {required int userId,
      required String username,
      required int page,
      required int size}) async {
    List<FollowRelationDto> followRelations = [];
    final model = ApiModel(
        url: followUrl + "/followers",
        params: {
          "userId": "$userId",
          "page": "$page",
          "size": "$size",
          "username": "$username"
        },
        parse: (data) {
          return data
              .map<FollowRelationDto>(
                  (json) => FollowRelationDto.fromJson(json))
              .toList();
        });
    followRelations.addAll(await apiRepository.get(model));
    return followRelations;
  }
}
