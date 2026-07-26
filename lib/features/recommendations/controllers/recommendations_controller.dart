import 'package:get/get.dart';

import '../../../data/models/recommendation_model.dart';

class RecommendationsController extends GetxController {
  List<RecommendationModel> get items => StaticRecommendations.items;
}
