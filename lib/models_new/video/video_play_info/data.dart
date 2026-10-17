import 'package:PiliPlus/models_new/video/video_play_info/interaction.dart';
import 'package:PiliPlus/models_new/video/video_play_info/subtitle_info.dart';
import 'package:PiliPlus/models_new/video/video_play_info/view_point.dart';

class PlayInfoData {
  int? lastPlayCid;
  int? lastPlayTime;
  SubtitleInfo? subtitle;
  List<ViewPoint>? viewPoints;
  Interaction? interaction;

  PlayInfoData({
    this.lastPlayCid,
    this.lastPlayTime,
    this.subtitle,
    this.viewPoints,
    this.interaction,
  });

  factory PlayInfoData.fromJson(Map<String, dynamic> json) => PlayInfoData(
    lastPlayCid: (json['last_play_cid'] as num?)?.toInt(),
    lastPlayTime: (json['last_play_time'] as num?)?.toInt(),
    subtitle: json['subtitle'] == null
        ? null
        : SubtitleInfo.fromJson(json['subtitle'] as Map<String, dynamic>),
    viewPoints: (json['view_points'] as List?)
        ?.map((e) => ViewPoint.fromJson(e))
        .toList(),
    interaction: json["interaction"] == null
        ? null
        : Interaction.fromJson(json["interaction"]),
  );
}
