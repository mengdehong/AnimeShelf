#!/usr/bin/env bash
# 国内 Flutter / Dart Pub 镜像环境变量配置
# 使用方式: source scripts/use_cn_mirror.sh
#
# Flutter CN 社区镜像 (flutter-io.cn)
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"

# 可选: 腾讯云镜像 (备用)
# export PUB_HOSTED_URL="https://mirrors.tencent.com/dart-pub"
# export FLUTTER_STORAGE_BASE_URL="https://mirrors.tencent.com/flutter"

echo "Flutter 国内镜像已启用:"
echo "  PUB_HOSTED_URL          = $PUB_HOSTED_URL"
echo "  FLUTTER_STORAGE_BASE_URL = $FLUTTER_STORAGE_BASE_URL"
