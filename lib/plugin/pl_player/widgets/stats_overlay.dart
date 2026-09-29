import 'dart:async';
import 'package:flutter/material.dart';
import 'package:PiliPlus/plugin/pl_player/controller.dart';
import 'package:media_kit/media_kit.dart';

class StatsOverlay extends StatefulWidget {
  final PlPlayerController controller;

  const StatsOverlay({
    super.key,
    required this.controller,
  });

  @override
  State<StatsOverlay> createState() => _StatsOverlayState();
}

class _StatsOverlayState extends State<StatsOverlay> {
  Timer? _timer;
  Offset _offset = const Offset(16, 48);

  String _hwdec = '-';
  String _dropCount = '0';
  String _voDropCount = '0';
  String _estimatedFps = '-';
  String _containerFps = '-';
  String _videoCodec = '-';
  String _bitrate = '-';
  String _res = '-';
  String _speed = '1.0x';
  String _avsync = '-';

  double? _estimatedFpsVal;
  double? _containerFpsVal;
  double _speedVal = 1.0;
  double? _avsyncVal;

  @override
  void initState() {
    super.initState();
    _updateStats();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted) {
        _updateStats();
      }
    });
  }

  void _updateStats() {
    final player = widget.controller.videoPlayerController;
    if (player is NativePlayer) {
      final hwdec = player.getProperty('hwdec-current');
      final dropCount = player.getProperty('decoder-frame-drop-count') ??
          player.getProperty('frame-drop-count') ??
          '0';
      final voDropCount = player.getProperty('vo-drop-frame-count') ?? '0';
      final estimatedFpsStr = player.getProperty('estimated-vf-fps');
      final containerFpsStr = player.getProperty('container-fps');
      final videoCodec = player.getProperty('video-codec');
      final bitrateStr = player.getProperty('video-bitrate');
      final avsyncStr = player.getProperty('avsync');
      final state = player.state;

      double? estimatedFpsVal;
      String formattedFps = '-';
      if (estimatedFpsStr != null && estimatedFpsStr.isNotEmpty) {
        final val = double.tryParse(estimatedFpsStr);
        if (val != null) {
          estimatedFpsVal = val;
          formattedFps = val.toStringAsFixed(1);
        } else {
          formattedFps = estimatedFpsStr;
        }
      }

      double? containerFpsVal;
      String formattedContainerFps = '-';
      if (containerFpsStr != null && containerFpsStr.isNotEmpty) {
        final val = double.tryParse(containerFpsStr);
        if (val != null) {
          containerFpsVal = val;
          formattedContainerFps = val.toStringAsFixed(1);
        } else {
          formattedContainerFps = containerFpsStr;
        }
      }

      double? avsyncVal;
      String formattedAvsync = '-';
      if (avsyncStr != null && avsyncStr.isNotEmpty) {
        final sec = double.tryParse(avsyncStr);
        if (sec != null) {
          avsyncVal = sec * 1000;
          formattedAvsync = '${(sec * 1000).toStringAsFixed(1)} ms';
        }
      }

      String formattedBitrate = '-';
      if (bitrateStr != null && bitrateStr.isNotEmpty) {
        final bps = double.tryParse(bitrateStr);
        if (bps != null && bps > 0) {
          if (bps >= 1000000) {
            formattedBitrate = '${(bps / 1000000).toStringAsFixed(1)} Mbps';
          } else {
            formattedBitrate = '${(bps / 1000).toStringAsFixed(0)} Kbps';
          }
        }
      }

      setState(() {
        _hwdec = hwdec ?? 'no';
        _dropCount = dropCount;
        _voDropCount = voDropCount;
        _estimatedFps = formattedFps;
        _containerFps = formattedContainerFps;
        _estimatedFpsVal = estimatedFpsVal;
        _containerFpsVal = containerFpsVal;
        _videoCodec = videoCodec ?? '-';
        _bitrate = formattedBitrate;
        _res = '${state.width}x${state.height}';
        _speed = '${state.rate.toStringAsFixed(1)}x';
        _speedVal = state.rate;
        _avsync = formattedAvsync;
        _avsyncVal = avsyncVal;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int drops = int.tryParse(_dropCount) ?? 0;
    final int voDrops = int.tryParse(_voDropCount) ?? 0;
    final int totalDrops = drops + voDrops;
    final isHwdec = _hwdec != 'no' && _hwdec != '-';

    final double targetFps = (_containerFpsVal ?? 0) * _speedVal;
    final bool isStuttering = targetFps > 5 &&
        _estimatedFpsVal != null &&
        _estimatedFpsVal! < (targetFps * 0.88);
    final double deficit = isStuttering ? (targetFps - _estimatedFpsVal!) : 0;
    final bool isDesync = _avsyncVal != null && (_avsyncVal! < -80 || _avsyncVal! > 80);

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta;
          });
        },
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xDD121212),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (totalDrops > 0 || isStuttering)
                    ? const Color(0x88FF5252)
                    : const Color(0x33FFFFFF),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 14,
                      color: (totalDrops > 0 || isStuttering)
                          ? const Color(0xFFFF5252)
                          : const Color(0xFF00E5FF),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '实时性能监控 (可拖拽)',
                      style: TextStyle(
                        color: (totalDrops > 0 || isStuttering)
                            ? const Color(0xFFFF5252)
                            : const Color(0xFF00E5FF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () {
                        widget.controller.toggleStats(false);
                      },
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Divider(color: Color(0x22FFFFFF), height: 1),
                const SizedBox(height: 6),
                _buildRow(
                  '实时帧率 (FPS)',
                  targetFps > 0
                      ? '$_estimatedFps / ${targetFps.toStringAsFixed(1)} fps ($_speed)'
                      : '$_estimatedFps fps',
                  valueColor: isStuttering
                      ? const Color(0xFFFF5252)
                      : (_estimatedFps == '-'
                          ? Colors.white
                          : const Color(0xFF69F0AE)),
                ),
                _buildRow(
                  '丢帧/流畅度',
                  totalDrops > 0
                      ? '$totalDrops 帧 (解码主动丢弃)'
                      : (isStuttering
                          ? '严重欠帧 (每秒缺 ${deficit.toStringAsFixed(1)} 帧)'
                          : '0 帧 (满帧流畅)'),
                  valueColor: (totalDrops > 0 || isStuttering)
                      ? const Color(0xFFFF5252)
                      : const Color(0xFF69F0AE),
                ),
                _buildRow(
                  '硬解模式 (Hwdec)',
                  isHwdec
                      ? (_hwdec.contains('-copy')
                          ? '$_hwdec (显存回传内存)'
                          : '$_hwdec (零拷贝直通)')
                      : '$_hwdec (软解/CPU负载)',
                  valueColor: isHwdec
                      ? (_hwdec.contains('-copy')
                          ? const Color(0xFFFFB74D)
                          : const Color(0xFF40C4FF))
                      : const Color(0xFFFF5252),
                ),
                _buildRow('视频分辨率', _res),
                _buildRow('视频编码', _videoCodec),
                _buildRow('当前码率', _bitrate),
                _buildRow(
                  '音画同步 (Sync)',
                  isDesync ? '$_avsync (音画脱节)' : _avsync,
                  valueColor: isDesync ? const Color(0xFFFF5252) : Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
