{
  lib,
  fishPlugins,
  fetchFromGitHub,
}:

fishPlugins.buildFishPlugin {
  pname = "fish-helix";
  version = "git";

  src = fetchFromGitHub {
    owner = "Tijs-B";
    repo = "fish-helix";
    rev = "dd27504666b065bfaad87f64d2610a085476fd4f";
    hash = "sha256-mlZ7A8MSmKrECJKbwv+Cm2DpLI5TmfYe0bCeWPjYfgA=";
  };

  meta = {
    description = "Helix key bindings for fish";
    homepage = "https://github.com/sshilovsky/fish-helix";
    license = lib.licenses.mit;
  };
}
