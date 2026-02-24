# AUR Packaging

AnimeShelf 的 AUR 包名是 `animeshelf`，类型为源码编译包。

## 目录结构

- `animeshelf/PKGBUILD`
- `animeshelf/animeshelf.desktop`
- `animeshelf/animeshelf.png`

## 发布到 AUR 的基本流程

1. 确保 GitHub 已存在对应版本 tag（例如 `v0.1.0`）。
2. 按新版本更新 `animeshelf/PKGBUILD` 里的 `pkgver`（必要时更新 `pkgrel`）。
3. 在 `animeshelf` 目录执行 `makepkg --printsrcinfo > .SRCINFO`。
4. 注册并登录 AUR（https://aur.archlinux.org/），配置 SSH key。
5. 推送 AUR 仓库：

```bash
git clone ssh://aur@aur.archlinux.org/animeshelf.git animeshelf-aur
cp PKGBUILD animeshelf.desktop animeshelf.png .SRCINFO animeshelf-aur/
cd animeshelf-aur
git add PKGBUILD animeshelf.desktop animeshelf.png .SRCINFO
git commit -m "update to v0.1.0"
git push
```

## 本地验证

```bash
cd linux/packaging/aur/animeshelf
makepkg -si
```
