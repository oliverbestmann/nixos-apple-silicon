final: prev: {
  linux-asahi = final.callPackage ./linux-asahi { };
  uboot-asahi = final.callPackage ./uboot-asahi { };
  asahi-fwextract = final.callPackage ./asahi-fwextract { };
  alsa-ucm-conf-asahi = final.callPackage ./alsa-ucm-conf-asahi { inherit (prev) alsa-ucm-conf; };
  asahi-audio = final.callPackage ./asahi-audio { };
}
