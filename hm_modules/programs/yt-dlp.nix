# nvim.nix
{ ... }:

{
  programs.yt-dlp = {
    enable = true;
    extraConfig = ''
      --cookies-from-browser firefox
      --output "~/Videos/%(extractor_key)s/%(uploader_id)s/%(timestamp>%Y-%m-%d_%H-%M)s_%(title)s_%(id)s.%(ext)s"
    '';
  };
}
