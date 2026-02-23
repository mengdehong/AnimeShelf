import 'package:anime_shelf/core/utils/export_service.dart';

String buildPlainTextImportReportText(PlainTextImportReport report) {
  final imported = report.lineResults
      .where((result) => result.status == PlainTextImportLineStatus.imported)
      .toList(growable: false);
  final lowConfidence = report.lineResults
      .where(
        (result) =>
            result.status == PlainTextImportLineStatus.lowConfidenceSkipped,
      )
      .toList(growable: false);
  final noResultOrSearchError = report.lineResults
      .where(
        (result) => result.status == PlainTextImportLineStatus.noResultSkipped,
      )
      .toList(growable: false);
  final searchFailed = noResultOrSearchError
      .where(_isSearchFailedLine)
      .toList(growable: false);
  final noResult = noResultOrSearchError
      .where((result) => !_isSearchFailedLine(result))
      .toList(growable: false);
  final duplicate = report.lineResults
      .where(
        (result) => result.status == PlainTextImportLineStatus.duplicateSkipped,
      )
      .toList(growable: false);
  final cancelled = report.lineResults
      .where((result) => result.status == PlainTextImportLineStatus.cancelled)
      .toList(growable: false);

  final failedCount =
      lowConfidence.length +
      searchFailed.length +
      noResult.length +
      duplicate.length;

  final lines = <String>[
    '【导入概览】',
    '- 状态：${report.cancelled ? '已取消' : '已完成'}',
    '- 总行数：${report.totalLines}',
    '- 识别条目：${report.totalEntries}',
    '- 已处理：${report.processedEntries}',
    '- 成功导入：${imported.length}',
    '- 导入失败：$failedCount '
        '(匹配不确定 ${lowConfidence.length} / '
        '请求失败 ${searchFailed.length} / '
        '未找到 ${noResult.length} / 已存在 ${duplicate.length})',
    '- 空行：${report.emptyLinesSkipped}',
    '- 识别分组标题：${report.tierHeadersDetected}',
  ];

  if (cancelled.isNotEmpty) {
    lines.add('- 取消后未处理：${cancelled.length}');
  }

  if (failedCount > 0 || cancelled.isNotEmpty) {
    lines
      ..add('')
      ..add('【导入失败（请自行复制导入）】');

    if (lowConfidence.isNotEmpty) {
      lines
        ..add('匹配不确定（${lowConfidence.length}）：')
        ..addAll(lowConfidence.map(_formatLowConfidenceLine));
    }

    if (searchFailed.isNotEmpty) {
      lines
        ..add('请求失败（${searchFailed.length}）：')
        ..addAll(searchFailed.map(_formatSearchFailedLine));
    }

    if (noResult.isNotEmpty) {
      lines
        ..add('未找到结果（${noResult.length}）：')
        ..addAll(
          noResult.map((result) => '- L${result.lineNumber}: ${result.input}'),
        );
    }

    if (duplicate.isNotEmpty) {
      lines
        ..add('已在书架（${duplicate.length}，无需重复导入）：')
        ..addAll(
          duplicate.map((result) {
            final matchedTitle = result.matchedTitle;
            if (matchedTitle != null && matchedTitle.isNotEmpty) {
              return '- L${result.lineNumber}: ${result.input} -> $matchedTitle';
            }
            return '- L${result.lineNumber}: ${result.input}';
          }),
        );
    }

    if (cancelled.isNotEmpty) {
      lines
        ..add('取消后未处理（${cancelled.length}）：')
        ..addAll(
          cancelled.map((result) => '- L${result.lineNumber}: ${result.input}'),
        );
    }

    final retryInputs = <String>[
      ...lowConfidence.map((result) => result.input),
      ...searchFailed.map((result) => result.input),
      ...noResult.map((result) => result.input),
      ...cancelled.map((result) => result.input),
    ];
    if (retryInputs.isNotEmpty) {
      lines
        ..add('')
        ..add('可复制重试列表（逐行粘贴即可）：')
        ..addAll(retryInputs);
    }
  }

  if (imported.isNotEmpty) {
    lines
      ..add('')
      ..add('【导入成功（${imported.length}）】')
      ..addAll(
        imported.map((result) {
          final matchedTitle = result.matchedTitle;
          if (matchedTitle != null && matchedTitle.isNotEmpty) {
            return '- L${result.lineNumber}: ${result.input} -> $matchedTitle';
          }
          return '- L${result.lineNumber}: ${result.input}';
        }),
      );
  }

  if (report.unknownTierHeaders.isNotEmpty ||
      report.inboxFallbackEntries.isNotEmpty) {
    lines
      ..add('')
      ..add('【分组提示】');

    if (report.unknownTierHeaders.isNotEmpty) {
      lines
        ..add('未识别分组标题（已自动归入 Inbox）：')
        ..addAll(report.unknownTierHeaders.map((header) => '- $header'));
    }

    if (report.inboxFallbackEntries.isNotEmpty) {
      lines
        ..add('因分组未识别而归入 Inbox 的条目：')
        ..addAll(report.inboxFallbackEntries.map(_formatInboxFallbackEntry));
    }
  }

  return lines.join('\n');
}

String _formatLowConfidenceLine(PlainTextImportLineResult result) {
  final matchedTitle = result.matchedTitle;
  final reason = _toFriendlyLowConfidenceReason(result.reason);
  if (matchedTitle != null && matchedTitle.isNotEmpty) {
    return '- L${result.lineNumber}: ${result.input} -> '
        '$matchedTitle（$reason）';
  }
  return '- L${result.lineNumber}: ${result.input}（$reason）';
}

String _toFriendlyLowConfidenceReason(String reason) {
  if (RegExp(r'[\u4e00-\u9fff]').hasMatch(reason)) {
    return reason;
  }

  if (reason.contains('season indicator mismatch')) {
    final wantedSeason = RegExp(r'wanted season\s+([0-9]+)').firstMatch(reason);
    final seasonNumber = wantedSeason?.group(1);
    if (seasonNumber != null) {
      return '季数信息不一致（输入季数：$seasonNumber）';
    }
    return '季数信息不一致';
  }

  if (reason.contains('low confidence')) {
    final scoreMatch = RegExp(r'score:\s*([0-9.]+)').firstMatch(reason);
    final score = scoreMatch?.group(1);
    if (score != null) {
      return '匹配度偏低（$score）';
    }
    return '匹配度偏低';
  }

  if (reason.contains('no suitable match')) {
    return '候选结果不够可靠';
  }

  if (reason.contains('ambiguous')) {
    return '候选项过于接近';
  }

  if (reason.contains('query too short')) {
    return '输入过短，无法稳定匹配';
  }

  if (reason.contains('empty query')) {
    return '输入为空';
  }

  return '匹配不够确定';
}

bool _isSearchFailedLine(PlainTextImportLineResult result) {
  return _isSearchFailedReason(result.reason);
}

bool _isSearchFailedReason(String reason) {
  return reason.startsWith('search request failed');
}

String _formatSearchFailedLine(PlainTextImportLineResult result) {
  final friendly = _toFriendlySearchFailureReason(result.reason);
  return '- L${result.lineNumber}: ${result.input}（$friendly）';
}

String _toFriendlySearchFailureReason(String reason) {
  if (!reason.startsWith('search request failed')) {
    return '请求失败';
  }

  if (reason.contains('timeout')) {
    return '请求超时';
  }
  if (reason.contains('no internet connection')) {
    return '网络不可用';
  }

  final statusMatch = RegExp(r'api status\s+([0-9]+)').firstMatch(reason);
  final statusCode = statusMatch?.group(1);
  if (statusCode != null) {
    return '接口异常（HTTP $statusCode）';
  }

  if (reason.contains('api error')) {
    return '接口异常';
  }

  return '请求失败';
}

String _formatInboxFallbackEntry(String entry) {
  final match = RegExp(
    r'^L([0-9]+):\s*(.*?)\s*->\s*Inbox\s*\(unknown tier\s*"(.*)"\)$',
  ).firstMatch(entry);
  if (match == null) {
    return '- $entry';
  }

  final lineNumber = match.group(1);
  final input = match.group(2);
  final header = match.group(3);
  return '- L$lineNumber: $input -> Inbox（未识别分组 "$header"）';
}
