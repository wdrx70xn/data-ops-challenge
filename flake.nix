{
  description = "data-ops-challenge";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self, nixpkgs, flake-utils
  }: flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs { inherit system; };
  in {

    packages.default = pkgs.stdenvNoCC.mkDerivation {
      name = "data-ops-challenge";

      nativeBuildInputs = (with pkgs; [
        xsv
        jq
        curl
        python3
      ]);

      src = ./.;

      buildPhase = ''
        mkdir -p $out

        cd $src
        BUILD_DIR=$out ./transform.bash
      '';

      doCheck = true;
      checkPhase = ''
        diff -q $src/tests/output.csv $out/user-policies.csv
      '';
    };
  });
}
