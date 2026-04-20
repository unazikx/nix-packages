{
  nixos-rebuild-ng,
}:

nixos-rebuild-ng.overrideAttrs (_old: {
  postPatch = _old.postPatch + ''
    cp -f \
      ${./repl.nix} \
      nixos_rebuild/repl.nix.template
  '';
})
