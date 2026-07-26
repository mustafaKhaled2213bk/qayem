class RecommendationModel {
  const RecommendationModel({
    required this.title,
    required this.author,
    required this.description,
    required this.category,
  });

  final String title;
  final String author;
  final String description;
  final String category;
}

abstract final class StaticRecommendations {
  static const List<RecommendationModel> items = [
    RecommendationModel(
      title: 'فن اللامبالاة',
      author: 'مارك مانسون',
      description: 'دليل عملي للعيش بوعي أكبر والتركيز على ما يهم حقاً.',
      category: 'تطوير ذات',
    ),
    RecommendationModel(
      title: 'العادات الذرية',
      author: 'جيمس كلير',
      description: 'كيف تبني عادات صغيرة تقود إلى نتائج كبيرة ومستدامة.',
      category: 'تطوير ذات',
    ),
    RecommendationModel(
      title: 'مقدمة ابن خلدون',
      author: 'ابن خلدون',
      description: 'مرجع كلاسيكي في فهم العمران والتاريخ والاجتماع.',
      category: 'تاريخ',
    ),
    RecommendationModel(
      title: 'كوسموس',
      author: 'كارل ساجان',
      description: 'رحلة مدهشة في الكون تجمع بين العلم والدهشة.',
      category: 'علوم',
    ),
    RecommendationModel(
      title: 'الأسود يليق بك',
      author: 'أحلام مستغانمي',
      description: 'رواية عربية معاصرة عن الحب والفقد والذاكرة.',
      category: 'أدب',
    ),
    RecommendationModel(
      title: 'لماذا ننام؟',
      author: 'ماثيو ووكر',
      description: 'استكشاف علمي لأهمية النوم وتأثيره على الصحة والأداء.',
      category: 'علوم',
    ),
  ];
}
