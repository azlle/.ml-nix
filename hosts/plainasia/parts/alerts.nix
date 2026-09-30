# hosts/plainasia/parts/alerts.nix
# smartd (S.M.A.R.T.セルフテスト) と zed (ZFSイベント: scrubエラー、プール
# デグレードなど) の通知をDiscordのWebhookへ送る。両方とも「メール送信
# プログラム」を差し込める仕組みを持つので、実際のメール送信は行わず、
# stdinのメッセージをそのままDiscordへcurlで投げるだけの1本のスクリプトを
# 両方に指定する。
#
# smartd (-i <recipient>、ヘッダ付き全文をstdin) と zed (-s <件名>
# <recipient>、本文のみをstdin) で呼び出し方が違うため、両対応させている。
{ config, pkgs, ... }:
let
  discordNotify = pkgs.writeShellScript "discord-notify" ''
    set -eu

    webhook_url=$(${pkgs.coreutils}/bin/cat "$DISCORD_WEBHOOK_FILE")

    subject=""
    while [ $# -gt 0 ]; do
      case "$1" in
        -s)
          subject="$2"
          shift 2
          ;;
        *)
          shift
          ;;
      esac
    done

    raw=$(${pkgs.coreutils}/bin/cat)

    if [ -z "$subject" ]; then
      # smartd style: ヘッダ付き全文。Subject: 行を取り出し、空行より後を本文にする。
      subject=$(printf '%s\n' "$raw" | ${pkgs.gnused}/bin/sed -n 's/^Subject: //p' | ${pkgs.coreutils}/bin/head -n1)
      body=$(printf '%s\n' "$raw" | ${pkgs.gnused}/bin/sed '1,/^$/d')
      if [ -z "$subject" ]; then
        # smartdはSMARTD_SUBJECTを常に空文字にする仕様 (smartd.cppのMailWarning()が
        # 標準添付のsmartd_warning.shによる件名組み立てを前提にしており、そちらを
        # 経由しないNixOSのsmartdNotifyスクリプト経由だと常に空になる)。
        # smartdが同じくexec先に渡す SMARTD_FAILTYPE/SMARTD_DEVICESTRING から
        # 代わりの件名を組み立てる。
        subject="SMART alert (''${SMARTD_FAILTYPE:-unknown}) on ''${SMARTD_DEVICESTRING:-unknown device}"
      fi
    else
      # zed style: 件名は引数で渡済み、stdinは本文のみ。
      body="$raw"
    fi

    # Discordのメッセージ本文上限(2000文字)に収まるよう安全側で切る。
    body=$(printf '%s' "$body" | ${pkgs.coreutils}/bin/head -c 1800)

    ${pkgs.jq}/bin/jq -n --arg title "$subject" --arg body "$body" \
      '{content: ("**" + $title + "**\n```\n" + $body + "\n```")}' \
      | ${pkgs.curl}/bin/curl -sS -X POST -H "Content-Type: application/json" -d @- "$webhook_url"
  '';

  webhookFile = config.sops.secrets."discord/smart-alerts-webhook".path;
in
{
  sops.secrets."discord/smart-alerts-webhook" = { };

  services.smartd.notifications.mail = {
    enable = true;
    mailer = discordNotify;
    # 実際のメールアドレスではなく、smartd生成スクリプトの引数として
    # 渡されるだけのプレースホルダー(discordNotifyは中身を見ない)。
    recipient = "discord";
  };
  systemd.services.smartd.environment.DISCORD_WEBHOOK_FILE = webhookFile;

  services.zfs.zed.settings = {
    ZED_EMAIL_ADDR = [ "discord" ]; # 同上、プレースホルダー
    ZED_EMAIL_PROG = "${discordNotify}";
    ZED_EMAIL_OPTS = "-s '@SUBJECT@' @ADDRESS@";
    # true にすると scrub 完了などの「問題なし」通知まで飛んでノイズになる。
    # エラー・デグレードなど実際に問題がある時だけ通知したいので false。
    ZED_NOTIFY_VERBOSE = false;
  };
  systemd.services.zfs-zed.environment.DISCORD_WEBHOOK_FILE = webhookFile;
}
