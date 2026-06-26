{
  description = "lattice diamond fpga tooling";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs}:
  
  let 
  system = "x86_64-linux";
  pkgs = import nixpkgs {inherit system;};
  
  in {

    overlays.default = final: prev: {
      diamond = with final; final.stdenv.mkDerivation { 
        name = "diamond";


        src = requireFile {
          name = "3.14.0.75.2_Diamond_lin.zip";
          url = "https://www.latticesemi.com/FileExplorer?media={ED835C57-116A-45B7-A442-B92008CC9F10}&document_id=54455";
          sha256 = "8e793407c595455af5304b68fdc7c16d7992a5f1ed0fb963998db88699292a95"; 
        };


        nativeBuildInputs = [
          tcsh
          unzip
          makeWrapper
          autoPatchelfHook 
        ];


        buildInputs = [
            expat
            fontconfig.lib
            libxft
            libx11
            dbus
            glib
            zlib
            freetype
            libsm
            libice
            libxrender
            libxcb
            libusb-compat-0_1
            libxrandr
            libtinfo
            numactl
            alsa-lib
            libtiff
            libxinerama
            libpulseaudio
            ncurses5
            pango
            cairo
            gtk2
            gtk2-x11
            libxml2_13
            libxext
            libxt
            libuuid
            libglvnd
            krb5
            libxcomposite
            gst_all_1.gstreamer
            gst_all_1.gst-plugins-base
            sqlite
            graphite2
            libxkbcommon
            libxcb-image
            libxcb-keysyms
            libxcb-render-util
        ];


        autoPatchelfIgnoreMissingDeps = [ "*" ];

        unpackPhase = ''
        echo unpacking source
        mkdir source
        unzip $src -d source 
        '';

        installPhase = ''
        runHook preInstall
        pwd
        installername=3.14.0.75.2_Diamond_lin.run

        mkdir $out/diamond -p

        autoPatchelf source/$installername
        
        source/$installername --console --prefix $out/diamond
        runHook postInstall

        mkdir $out/bin
        
        makeWrapper $out/diamond/bin/lin64/diamond $out/bin/diamond
        runHook postInstall
        '';

        
        dontAutoPatchelf = ":)";

        postFixup = ''
        mv $out/diamond/questasim /tmp/questasim
        autoPatchelf $out/diamond
        mv /tmp/questasim $out/diamond/questasim
        '';

      };

      diamond-fhs = final.buildFHSEnv {
           name = "diamond";
           targetPkgs = pkgs: with pkgs; [ 
            libxft
            libxext
            libx11
            expat
            fontconfig.lib

            self.packages.x86_64-linux.diamond
           ]; 
           runScript = "bash";
      };
    };
    packages.${system} = 
      let 
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ self.overlays.default ];
        };
      in
    {
      diamond = pkgs.diamond;
      default = pkgs.diamond.fhs;
    };
  };
}
