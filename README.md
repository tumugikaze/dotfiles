# Dotfiles

自分専用Dotfiles

## 構成

| 環境 | 引数 | アーキテクチャ |
| --- | --- | --- |
| Linux | `linux` | x86_64-linux |
| Linux (Hyprland) | `hyprland` | x86_64-linux |
| macOS | `darwin` | aarch64-darwin |
| WSL2 | `wsl` | x86_64-linux |

ユーザー名は`flake.nix`にあるので、環境でユーザー名が違う場合変更して色々実行する

## セットアップ

```bash
./setup.sh darwin
```

引数には構成のところ参照

## 依存関係の更新

```bash
./update.sh
```

`flake.lock` を更新する。

## 適用

```bash
./apply.sh
```

.configなど変更した後に反映するために実行

引数を省略すると前回適用した環境を使う（初回はOSから自動判定）。別の環境にしたい場合は `./apply.sh hyprland` のように指定する

## Nodeパッケージ

```bash
./packages/install.sh Node.txt
```

## Archパッケージ

```bash
./packages/install.sh Pacman.txt Aur.txt
```

Hyprland関連はこれでインストール

## macOSパッケージ

```bash
brew install --cask 1password
```

## ローカルシェル設定

`~/.zshrc.local` は存在すれば読み込まれる

## Git設定


```bash
touch ~/.gitconfig
git config --global user.name "..."
git config --global user.email "..."
```

物理キー
```bash
git config --global user.signingkey ~/.ssh/id_ed25519_sk.pub
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```
```bash
cd ~/.ssh && nix shell nixpkgs#openssh -c ssh-keygen -K
```

## Neovim

LSPサーバーはHome Managerでインストールする（masonは使わない）。rust-analyzerだけはrustupのものを使うので、Rustを使う環境では一度だけ実行する

```bash
rustup default stable
rustup component add rust-analyzer
```
