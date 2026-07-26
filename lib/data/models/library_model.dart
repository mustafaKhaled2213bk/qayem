class LibraryModel {
  const LibraryModel({
    required this.name,
    required this.description,
    required this.urlHint,
  });

  final String name;
  final String description;
  final String urlHint;
}

abstract final class KnownLibrariesData {
  static const List<LibraryModel> items = [
    LibraryModel(
      name: 'مكتبة نور',
      description: 'مكتبة عربية واسعة تضم آلاف الكتب الإلكترونية المجانية.',
      urlHint: 'www.noor-book.com',
    ),
    LibraryModel(
      name: 'مكتبة الإسكندرية الرقمية',
      description: 'محتوى معرفي وثقافي متنوع من مصادر موثوقة.',
      urlHint: 'www.bibalex.org',
    ),
    LibraryModel(
      name: 'Archive.org',
      description: 'أرشيف رقمي عالمي يضم كتباً ووثائق تاريخية.',
      urlHint: 'archive.org',
    ),
    LibraryModel(
      name: 'Project Gutenberg',
      description: 'كتب كلاسيكية مجانية في الملك العام بعدة لغات.',
      urlHint: 'www.gutenberg.org',
    ),
    LibraryModel(
      name: 'هنداوي',
      description: 'منصة عربية للكتب والمقالات العلمية والثقافية.',
      urlHint: 'www.hindawi.org',
    ),
  ];
}
