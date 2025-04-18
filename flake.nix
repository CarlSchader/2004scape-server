{
  description = "2004 runescape";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
  let
    # system invariant outputs
    all-systems = flake-utils.lib.eachDefaultSystem (system: 
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in 
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          openssl
          sqlite
          mysql-shell
          prisma
          prisma-engines
          nodejs_22
          jdk17
        ];

        shellHook = ''
          export PRISMA_SCHEMA_ENGINE_BINARY="${pkgs.prisma-engines}/bin/schema-engine"
          export PRISMA_QUERY_ENGINE_BINARY="${pkgs.prisma-engines}/bin/query-engine"
          export PRISMA_QUERY_ENGINE_LIBRARY="${pkgs.prisma-engines}/lib/libquery_engine.node"
          export PRISMA_FMT_BINARY="${pkgs.prisma-engines}/bin/prisma-fmt"
          export PATH="$PWD/node_modules/.bin/:$PATH"
        '';
      };
    });
  in 
  {
    nixosModules.db = { config, pkgs, ...}: {
      # options = {};
      config = {
        services.mysql = {
          enable = true;
          settings.mysqld.port = 3306;
          package = pkgs.mariadb;
          user = "lostcity";
          dataDir = "/var/lib/mysql-lostcity";
          initialDatabases = [
            { name = "lostcity"; }
          ];
          ensureDatabases = [ "lostcity" ];
        };
      };
    };
  } // all-systems;
}
