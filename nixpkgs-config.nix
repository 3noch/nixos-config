{
  allowUnfree = true;
  allowBroken = true;

  packageOverrides = pkgs: {
    obelisk = (import dep/obelisk {}).command;

    haskellPackages-mine = pkgs.haskellPackages.override {
      overrides = self: super: {

        #haskell-src-exts-HEAD = self.callCabal2nix "haskell-src-exts" (pkgs.fetchFromGitHub {
        #  owner  = "haskell-suite";
        #  repo   = "haskell-src-exts";
        #  rev    = "935f6f0915e89c314b686bdbdc6980c72335ba3c";
        #  sha256 = "1v3c1bd5q07qncqfbikvs8h3r4dr500blm5xv3b4jqqv69f0iam9";
        #}) {};
        #haskell-src-exts = self.haskell-src-exts-HEAD;

        #hlint = super.hlint.overrideAttrs (_: { haskell-src-exts = self.haskell-src-exts-HEAD; });
        #stylish-haskell = super.stylish-haskell.overrideAttrs (_: { haskell-src-exts = self.haskell-src-exts-HEAD; });

        twitch-cli = self.callCabal2nix "twitch-cli" (pkgs.fetchFromGitHub {
          owner  = "grafted-in";
          repo   = "twitch-cli";
          rev    = "85047186c3790ab8f015bdc4658abfe63c6129b7";
          sha256 = "1yr53r3h0p12dj2cyc3j6r71nyf0g93x1xbra9205f6qp3ymc205";
        }) {};

        #intero = pkgs.haskell.lib.dontCheck super.intero;
        stylish-haskell = pkgs.haskell.lib.doJailbreak super.stylish-haskell;
      };
    };
  };
}
