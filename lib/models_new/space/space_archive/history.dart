class History {
  int? progress;
  int? duration;

  /// The space archive API uses seconds as the progress unit
  /// while the player expects milliseconds.
  ///
  /// The space archive API uses `-1` to indicate that the video has been fully watched.
  /// When reopened, playback should start from the beginning to avoid resuming from
  /// the last playback position associated with the video streaming account.
  int? get playbackProgress {
    final progress = this.progress;
    if (progress == null) return null;
    return progress == -1 ? 0 : progress * Duration.millisecondsPerSecond;
  }

  History({this.progress, this.duration});

  factory History.fromJson(Map<String, dynamic> json) => History(
    progress: (json['progress'] as num?)?.toInt(),
    duration: (json['duration'] as num?)?.toInt(),
  );
}
