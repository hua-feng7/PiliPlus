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

      String formattedFps = '-';
      if (estimatedFpsStr != null && estimatedFpsStr.isNotEmpty) {
        final val = double.tryParse(estimatedFpsStr);
        if (val != null) {
          formattedFps = val.toStringAsFixed(1);
        } else {
          formattedFps = estimatedFpsStr;
        }
      }

      String formattedContainerFps = '-';
      if (containerFpsStr != null && containerFpsStr.isNotEmpty) {
        final val = double.tryParse(containerFpsStr);
        if (val != null) {
          formattedContainerFps = val.toStringAsFixed(1);
        } else {
          formattedContainerFps = containerFpsStr;
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

      String formattedAvsync = '-';
      if (avsyncStr != null && avsyncStr.isNotEmpty) {
        final sec = double.tryParse(avsyncStr);
        if (sec != null) {
          formattedAvsync = '${(sec * 1000).toStringAsFixed(1)} ms';
        }
      }

      setState(() {
        _hwdec = hwdec ?? 'no';
        _dropCount = dropCount;
        _voDropCount = voDropCount;
        _estimatedFps = formattedFps;
        _containerFps = formattedContainerFps;
        _videoCodec = videoCodec ?? '-';
        _bitrate = formattedBitrate;
        _res = '${state.width}x${state.height}';
        _speed = '${state.rate.toStringAsFixed(1)}x';
        _avsync = formattedAvsync;
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
              fontWeight: FontWeight.w640,
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
              border: Border.all(color: const Color(0x33FFFFFF), width: 1),
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
                    const Icon(
                      Icons.analytics_outlined,
                      size: 14,
                      color: Color(0xFF00E5FF),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '实时性能监控 (可拖拽)',
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
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
                  '$_estimatedFps / $_containerFps fps ($_speed)',
                  valueColor: _estimatedFps == '-'
                      ? Colors.white
                      : const Color(0xFF69F0AE),
                ),
                _buildRow(
                  '丢帧数 (Drops)',
                  totalDrops == 0
                      ? '0 帧 (流畅)'
                      : '$totalDrops 帧 (解码:$drops 渲染:$voDrops)',
                  valueColor: totalDrops == 0
                      ? const Color(0xFF69F0AE)
                      : const Color(0xFFFF5252),
                ),
                _buildRow(
                  '硬解状态 (Hwdec)',
                  isHwdec ? '$_hwdec (硬解激活)' : '$_hwdec (软解)',
                  valueColor: isHwdec
                      ? const Color(0xFF40C4FF)
                      : const Color(0xFFFFAB40),
                ),
                _buildRow('视频分辨率', _res),
                _buildRow('视频编码', _videoCodec),
                _buildRow('当前码率', _bitrate),
                _buildRow('音画同步', _avsync),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
