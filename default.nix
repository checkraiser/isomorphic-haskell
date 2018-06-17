{ pkgs ? import ((import <nixpkgs> {}).fetchFromGitHub {
	owner = "NixOS";
	repo = "nixpkgs";
	rev = "a0aeb23";
	sha256 = "04dgg0f2839c1kvlhc45hcksmjzr8a22q1bgfnrx71935ilxl33d";
  }){}
}:
let
  inherit (pkgs) runCommand closurecompiler;
  inherit (pkgs.haskell.packages) ghcjs ghc802;
  result = import (pkgs.fetchFromGitHub {
    owner = "dmjio";
    repo = "miso";
    sha256 = "1l1gwzzqlvvcmg70jjrwc5ijv1vb6y5ljqkh7rxxq7hkyxpjyx9q";
    rev = "95f6bc9b1ae6230b110358a82b6a573806f272c2";
  }) {};
  server = ghc802.callPackage ./server.nix { miso = result.miso-ghc; };
  client = ghcjs.callPackage ./client.nix { miso = result.miso-ghcjs; };
in 
  runCommand "isomorphic1" { inherit client server; } ''
    mkdir -p $out/{bin,static}
    ${closurecompiler}/bin/closure-compiler ${client}/bin/client.jsexe/all.js > $out/static/all.js
    cp ${server}/bin/* $out/bin
  ''