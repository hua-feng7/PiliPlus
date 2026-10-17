class UserProgress {
  UserProgress({
    this.lastEpId,
    this.lastTime,
  });

  int? lastEpId;
  int? lastTime;

  /// The PGC season user status API uses seconds as the progress unit
  /// while the player expects milliseconds.
  ///
  /// The PGC API uses `-1` to indicate that the video has been fully watched.
  /// When reopened, playback should start from the beginning to avoid resuming from
  /// the last playback position associated with the video streaming account.
  int? get playbackProgress {
    final lastTime = this.lastTime;
    if (lastTime == null) return null;
    return lastTime == -1 ? 0 : lastTime * Duration.millisecondsPerSecond;
  }

  UserProgress.fromJson(Map<String, dynamic> json) {
    lastEpId = (json['last_ep_id'] as num?)?.toInt();
    lastTime = (json['last_time'] as num?)?.toInt();
  }
}
