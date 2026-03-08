{
  self',
  pkgs,
  lib,
}:
let
  excludePackages = [
    (baseNameOf ./.)
    "firefox-addons"
    "firefox-themes"
    "windows-iso"
    "walogram"
  ];

  isDerivation =
    pkg: builtins.isAttrs pkg && ((pkg ? type && pkg.type == "derivation") || (pkg ? drvPath));

  getDerivations =
    packages:
    let
      collectNames =
        prefix: attrs:
        lib.concatMap (
          name:
          let
            pkg = attrs.${name};
            fullName = if prefix == "" then name else "${prefix}.${name}";
          in
          if isDerivation pkg then
            [ fullName ]
          else if builtins.isAttrs pkg && !(pkg ? outPath) then
            collectNames fullName pkg
          else
            [ ]
        ) (lib.attrNames attrs);
    in
    lib.sort lib.lessThan (collectNames "" packages);

  getPackageByPath = path: root: lib.foldl (acc: key: acc.${key}) root (lib.splitString "." path);

  isLocalPackage =
    _name: pkg:
    let
      version =
        if pkg ? version then
          pkg.version
        else if pkg ? drvVersion then
          pkg.drvVersion
        else if pkg ? src && pkg.src ? version then
          pkg.src.version
        else
          null;
    in
    version == "local";

  ourPackages = self'.legacyPackages or { };
  allDerivations = getDerivations ourPackages;

  packagesToUpdate = builtins.filter (
    name:
    let
      pkg = getPackageByPath name ourPackages;
      notExcluded =
        !(builtins.elem name excludePackages)
        && !(builtins.any (ex: lib.hasPrefix (ex + ".") name) excludePackages);
      notLocal = if pkg ? version || pkg ? drvVersion then !(isLocalPackage name pkg) else true;
    in
    notExcluded && notLocal
  ) allDerivations;

  localPackagesCount = builtins.length (
    builtins.filter (
      name:
      let
        pkg = getPackageByPath name ourPackages;
        notExcluded =
          !(builtins.elem name excludePackages)
          && !(builtins.any (ex: lib.hasPrefix (ex + ".") name) excludePackages);
        isLocal = if pkg ? version || pkg ? drvVersion then isLocalPackage name pkg else false;
      in
      notExcluded && isLocal
    ) allDerivations
  );

  quietNixUpdate = pkgs.writeShellScriptBin "quiet-nix-update" ''
    ${lib.getExe pkgs.nix-update} "$@" > /dev/null 2>&1
    exit_code=$?
    exit $exit_code
  '';
in
pkgs.writeShellScriptBin "update-packages" ''
  echo "Starting package updates..."
  echo ""
  COMMANDS=()
  PACKAGE_NAMES=()
  for name in ${toString packagesToUpdate}; do
    nix_update_cmd="${lib.getExe quietNixUpdate}"
    cmd="cd $PWD && $nix_update_cmd --flake legacyPackages.${pkgs.stdenv.system}.$name"
    
    COMMANDS+=("$cmd")
    PACKAGE_NAMES+=("$name")
  done
  total=''${#COMMANDS[@]}
  current=0
  success=0
  failed=0
  all_total=${toString (builtins.length allDerivations)}
  excluded_count=${toString (builtins.length excludePackages)}
  local_count=${toString localPackagesCount}
  no_version_count=$(($all_total - $excluded_count - $local_count - $total))
  echo "=== Package Statistics ==="
  echo "Total packages: $all_total"
  echo "Excluded by list: $excluded_count"
  echo "Local packages (skipped): $local_count"
  echo "Packages without 'version' attr: $no_version_count"
  echo "Packages to update: $total"
  echo ""
  if [[ $total -eq 0 ]]; then
    echo "No packages to update!"
    exit 0
  fi
  for i in "''${!COMMANDS[@]}"; do
    cmd="''${COMMANDS[$i]}"
    name="''${PACKAGE_NAMES[$i]}"
    current=$((current + 1))
    
    echo -n "[$current/$total] Updating $name..."
    if eval "$cmd"; then
      echo " Success"
      success=$((success + 1))
    else
      echo " Failed"
      failed=$((failed + 1))
    fi
  done
  echo ""
  echo "=== Update Summary ==="
  echo "Successful: $success"
  echo "Failed: $failed"
  echo "Skipped (local): $local_count"
  echo "Excluded: $excluded_count"
  echo "Total: $all_total"
''
