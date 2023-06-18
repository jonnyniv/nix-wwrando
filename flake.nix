{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    wwrando = {
      url = "github:LagoLunatic/wwrando?ref=1.10.0";
      flake = false;
    };
  };


  outputs = { self, nixpkgs, wwrando }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (system: 
      let
        syspkgs = pkgs.${system};
        pythonpkgs = syspkgs.python310Packages;
      in
      {
        default = pythonpkgs.buildPythonApplication {
          pname = "wwrando";
          version = "1.10.0";
          src = wwrando;
          format = "pyproject";
          propagatedBuildInputs = with pythonpkgs; [
            pyyaml
            pyside6
            pillow
            appdirs
            certifi
            setuptools
          ];
          preBuild = ''
            cat > pyproject.toml << EOF
            ''
            + builtins.readFile ./pyproject.toml
            + "\nEOF\n"
            + ''
            cat > wwrando_run.py << EOF
            def main():
              import wwrando
            EOF
            substituteInPlace wwrando_paths.py --replace "from sys import _MEIPASS" ""
            substituteInPlace wwrando_paths.py --replace "_MEIPASS" "os.path.dirname(os.path.realpath(__file__))"
            ''
            ;
        };
      });
    };
}
