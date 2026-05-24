enum MaterialType {
  video,
  document,
  audio,
  image,
  link;

  String get label => switch (this) {
        MaterialType.video => 'Video',
        MaterialType.document => 'Document',
        MaterialType.audio => 'Audio',
        MaterialType.image => 'Image',
        MaterialType.link => 'Link',
      };
}
