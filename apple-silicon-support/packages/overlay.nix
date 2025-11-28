final: prev: {
  linux-asahi = final.callPackage ./linux-asahi { };
  uboot-asahi = final.callPackage ./uboot-asahi { };
  linux-asahi-mini = final.callPackage ./linux-asahi-mini { };
}
