# pkgs/niri-libdisplay-info-overlay.nix
# nixpkgs から libdisplay-info_0_2 が削除された (0.3 以降のみ提供) 一方で、
# niri-flake の派生は今も libdisplay-info_0_2 を引数に取るため eval が失敗する。
#
# niri-unstable が使う Rust crate libdisplay-info-sys 0.3.0 は C ライブラリの
# バージョンを pkg-config で自動検出し 0.3 を正式サポートしている
# (nixpkgs 本家の niri も libdisplay-info_0_3 でビルドしている) ので 0.3 を渡す。
#
# niri-flake 側は関数本体に `assert libdisplay-info_0_2.version == "0.2.0"` を持ち、
# この assert は .override より先に評価されてしまうため、パッケージセットに
# libdisplay-info_0_2 を生やす形で差し替える。中身は本物の 0.3.0 の派生のままで、
# assert を通すために version 属性だけ上書きする (再ビルドは発生しない)。
#
# niri-flake が libdisplay-info_0_3 に対応したらこのオーバーレイごと削除する。
final: _prev: {
  libdisplay-info_0_2 = final.libdisplay-info_0_3 // {
    version = "0.2.0";
  };
}
