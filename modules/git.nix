# modules/git.nix
{ delib, ... }:
delib.module {
  name = "git";

  home.always = {
    imports = [
      (
        {
          username,
          config,
          lib,
          pkgs,
          ...
        }:
        {
          home.packages = [ pkgs.git-vrc ];

          programs.git = {
            enable = true;

            settings = {
              user = {
                name = "Azlle";
                email = "moxmo2@pm.me";
              };
              core = {
                editor = "emacs -nw";
                autocrlf = "input";
                filemode = "false";
                quotepath = "false";
              };
              merge.ff = false;
              pull.ff = "only";

              # requires running `git vrc install --attributes` inside each repo to set up .gitattributes.
              filter.vrc = {
                clean = "git vrc clean --file %f";
                smudge = "git vrc smudge --file %f";
                required = true;
              };
            };

            signing.format = null;

            # CF-Access-Client-Id/Secret headers, to bypass Cloudflare Access's Auth0 login for git.melocy.cc.
            includes = lib.mkIf (username == "eeshta") [
              { path = config.sops.secrets."forgejo/cf-access-service-token".path; }
            ];
          };
        }
      )
    ];
  };
}
