# git.nix
_:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Azlle";
        email = "moxmo2@pm.me";
      };
      core = {
        editor = "emacs";
        autocrlf = "input";
        filemode = "false";
        quotepath = "false";
      };
      merge.ff = false;
      pull.ff = "only";
    };

    signing.format = null;
  };
}
