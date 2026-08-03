# git-forgejo-access.nix
{ osConfig, ... }:

{
  # CF-Access-Client-Id/Secret headers for git.melocy.cc, so `git+https://`
  # flake inputs and clones can bypass the interactive Auth0 login that
  # Cloudflare Access would otherwise require. Kept out of hm_modules/git.nix
  # since osConfig is only available when home-manager is integrated into a
  # NixOS system (not on sumizomenosakura's standalone home-manager setup).
  programs.git.includes = [
    { path = osConfig.sops.secrets."forgejo/cf-access-service-token".path; }
  ];
}
