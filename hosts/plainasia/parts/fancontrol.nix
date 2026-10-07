# hosts/plainasia/parts/fancontrol.nix
# Super I/Oチップ(ASRock B550M-ITX/ac搭載のNuvoton NCT6792D)用。デフォルトでは
# ロードされず、/sys/class/hwmonにfan*_input/pwm*が一切出てこない状態だった。
# 実機で modprobe nct6775 して確認した結果、force_id等は不要でそのまま認識される
# (chip: nct6792、platformデバイス名は nct6775.656 で固定、hwmon番号は再起動で
# 変わりうる)。
#
# 実機で確認したヘッダの対応:
#   - CPU_FAN1 = fan2/pwm2。BIOSのSmart Fan(enable=5)で既に正常に自動制御されて
#     おり、ここでは一切触らない。
#   - CHA_FAN1/WP = fan1/pwm1。未使用(何も挿していない)。
#   - CHA_FAN2/WP = fan3/pwm3。元々HDDベイのバックプレーンのFAN端子(Molex給電の
#     固定フル回転パススルーで、マザーボードから一切見えない)に挿してあった
#     ケースファンを、ここへ配線し直した。このファンの役割は専らHDD(tankの
#     IronWolf 2台)の冷却なので、CPU温度ではなくHDDのSMART温度で制御する。
#
# pwm3の実測特性: pwm値を下げても~810rpm以下には落ちず(3pin DC方式の下限と
# 思われる)、pwm=60あたりから明確に反応が始まり255で約1980rpmまで上がる。
# 下限は実質「完全停止」ではなく常時810rpm程度のベース風量になるので、
# start=60/stop=0として渡す(stop=0は文字通りの停止ではなく、このベース風量
# 状態を指す)。
{ pkgs, ... }:
{
  boot.kernelModules = [ "nct6775" ];

  environment.systemPackages = [ pkgs.lm_sensors ];

  services.hddfancontrol = {
    # settingsだけでは発火しない。このenableが大元のスイッチで、立てないと
    # systemd.services側の実体(script/ExecStart)が一切生成されず、下のRestart
    # 上書きだけが空のユニットとして残る (実際に一度踏んだ: "Service has no
    # ExecStart=... Refusing" で起動すらしていなかった)。
    enable = true;

    settings.tank = {
      disks = [
        "/dev/disk/by-id/wwn-0x5000c50113de71d3"
        "/dev/disk/by-id/wwn-0x5000c50113de618d"
      ];
      pwmPaths = [
        "`echo /sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]`/pwm3:60:0"
      ];

      # デフォルトの30-50℃は、配線し直す前(=常時フル回転だった頃)に記録された
      # 実温度(33-34℃、SMART属性194のMin/Max)がほぼ収まってしまい、本当に熱く
      # なるまで反応しない。カーブ移行後は平均風量が落ちて実温度も上がるはずなので、
      # 様子を見ながら調整する前提で、ひとまず早めに反応するレンジに詰める。
      extraArgs = [
        "--drive-temp-range"
        "35"
        "45"
      ];
    };
  };

  # daemonが予期せず落ちた際、ファンがその時点のduty比に固定されたまま放置される
  # (次の再起動まで誰も監視しない)のを避けるため、すぐ再起動させる。
  systemd.services.hddfancontrol-tank.serviceConfig.Restart = "on-failure";
}
