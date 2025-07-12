{ lib
, fetchFromGitLab
, mesa
,
}:

(mesa.override {
  galliumDrivers = [
    "softpipe"
    "llvmpipe"
    "asahi"
  ];
  vulkanDrivers = [
    "swrast"
    "asahi"
  ];
}).overrideAttrs
  (oldAttrs: {
    version = "25.1.5";
    src = fetchFromGitLab {
      # tracking: https://pagure.io/fedora-asahi/mesa/commits/asahi
      domain = "gitlab.freedesktop.org";
      owner = "mesa";
      repo = "mesa";
      tag = "mesa-25.1.5";
      hash = "sha256-AZAd1/wiz8d0lXpim9obp6/K7ySP12rGFe8jZrc9Gl0=";
    };

    mesonFlags =
      let
        badFlags = [
          "-Dinstall-mesa-clc"
          "-Dgallium-nine"
          "-Dtools"
        ];
        isBadFlagList = f: builtins.map (b: lib.hasPrefix b f) badFlags;
        isGoodFlag = f: !(builtins.foldl' (x: y: x || y) false (isBadFlagList f));
      in
      (builtins.filter isGoodFlag oldAttrs.mesonFlags)
      ++ [
        # we do not build any graphics drivers these features can be enabled for
        "-Dgallium-va=disabled"
        "-Dgallium-vdpau=disabled"
        "-Dgallium-xa=disabled"
        "-Dtools=asahi"
      ];

    # replace patches with ones tweaked slightly to apply to this version
    patches = [
      ./opencl.patch
    ];

    postInstall =
      (oldAttrs.postInstall or "")
      + ''
        # we don't build anything to go in this output but it needs to exist
        touch $spirv2dxil
        touch $cross_tools
      '';
  })
