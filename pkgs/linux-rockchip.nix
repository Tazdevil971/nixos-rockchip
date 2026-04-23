{
  pkgs,
  pkgs-stable,
  lib,
  fetchFromGitHub,
}:

let
  kernelConfig = with lib.kernel; {
    ARCH_ROCKCHIP = yes;
    CHARGER_RK817 = yes;
    COMMON_CLK_RK808 = yes;
    COMMON_CLK_ROCKCHIP = yes;
    DRM_ROCKCHIP = yes;
    GPIO_ROCKCHIP = yes;
    MMC_DW = yes;
    MMC_DW_ROCKCHIP = yes;
    MMC_SDHCI_OF_DWCMSHC = yes;
    MOTORCOMM_PHY = yes;
    PCIE_ROCKCHIP_DW_HOST = yes;
    PHY_ROCKCHIP_INNO_CSIDPHY = yes;
    PHY_ROCKCHIP_INNO_DSIDPHY = yes;
    PHY_ROCKCHIP_INNO_USB2 = yes;
    PHY_ROCKCHIP_NANENG_COMBO_PHY = yes;
    PINCTRL_ROCKCHIP = yes;
    PWM_ROCKCHIP = yes;
    REGULATOR_RK808 = yes;
    ROCKCHIP_DW_HDMI = yes;
    ROCKCHIP_IODOMAIN = yes;
    ROCKCHIP_IOMMU = yes;
    ROCKCHIP_MBOX = yes;
    ROCKCHIP_PHY = yes;
    ROCKCHIP_PM_DOMAINS = yes;
    ROCKCHIP_SARADC = yes;
    ROCKCHIP_THERMAL = yes;
    ROCKCHIP_VOP2 = yes;
    RTC_DRV_RK808 = yes;
    SND_SOC_RK817 = module;
    SND_SOC_ROCKCHIP_I2S_TDM = module;
    SPI_ROCKCHIP = yes;
    STMMAC_ETH = yes;
    VIDEO_HANTRO_ROCKCHIP = yes;
  };
  pinetabKernelConfig = with lib.kernel; {
    BES2600 = module;
    BES2600_5GHZ_SUPPORT = yes;
    BES2600_DEBUGFS = yes;

    DRM_PANEL_BOE_TH101MB31UIG002_28A = yes;
  };
  radxaRk2312BuildArgs = {
    version = "6.1.43-26-rk2312";
    modDirVersion = "6.1.43";
    src = pkgs.fetchFromGitHub {
      owner = "radxa";
      repo = "kernel";
      rev = "ba75427f384faf9e1246fd2aeaacffae115ba88d";
      hash = "sha256-PujHYvCuPwCMk9Yvou4Z2z51eJ6eyEeqpEs6ZYvQ3o0=";
    };
    extraMakeFlags = [
      "KCFLAGS+=-Wno-error=enum-int-mismatch" 
      "KCFLAGS+=-Wno-error=calloc-transposed-args"
      "KCFLAGS+=-Wno-error=incompatible-pointer-types"
    ];
    defconfig = "rockchip_linux_defconfig";
    ignoreConfigErrors = true;
    structuredExtraConfig = with lib.kernel; {
      ATA_BMDMA = yes;
      ATA_SFF = yes;
      ROCKCHIP_MINIDUMP = no;
      # TODO: Properly fix
      # ROCKCHIP_IOMUX = no;
      # ROCKCHIP_RGA = no;
      # ROCKCHIP_HW_DECOMPRESS_USER = no;
      RK_NAND = no;
      RK_NANDC_NAND = no;
      RK_SFC_NAND = no;
      RK_SFC_NOR = no;
      RK_CMA_PROCFS = no;
      DMABUF_HEAPS_SRAM = no;
      MALI_KUTF = no;
      MFD_SERDES_DISPLAY = no;
      DRM_AMDGPU = no;
      VIDEO_DES_MAXIM2C = no;
      VIDEO_DES_MAXIM4C = no;
      VIDEO_MAXIM_DES_MAXIM2C = no;
      VIDEO_TECHPOINT = no;
      VIDEO_AR0822 = no;
      VIDEO_AR2020 = no;
      VIDEO_MAX96712 = no;
      VIDEO_MAX96714 = no;
      VIDEO_MAX96722 = no;
      VIDEO_MAX96756 = no;
      VIDEO_MIS2031 = no;
      VIDEO_MIS4001 = no;
      VIDEO_OG01A10 = no;
      VIDEO_OG02B10 = no;
      VIDEO_OS02K10 = no;
      VIDEO_OS04D10 = no;
      VIDEO_OV16885 = no;
      VIDEO_SC1346 = no;
      VIDEO_SC223A = no;
      VIDEO_SC2355 = no;
      VIDEO_SC4336P = no;
      VIDEO_SC450AI = no;
      VIDEO_SC5336 = no;
      VIDEO_ROCKCHIP_PREISP = no;
      # TODO: Properly fix
      # VIDEO_ROCKCHIP_ISP = no;
      STMMAC_UIO = no;
      NVMEM_RK628_EFUSE = no;
      NVMEM_ROCKCHIP_SEC_OTP = no;
      TOUCHSCREEN_CYPRESS_CYTTSP5 = no;
      RTC_DRV_RK630 = no;
      COMPASS_AK8975 = no;
      LS_CM3232 = no;
      GS_DMT10 = no;
      GS_KXTJ9 = no;
      GS_MC3230 = no;
      GS_MMA7660 = no;
      GS_MMA8452 = no;
    };
  };
in
{
  linux_latest_rockchip_stable = pkgs-stable.linuxKernel.packagesFor (
    pkgs-stable.linuxKernel.kernels.linux_latest.override { structuredExtraConfig = kernelConfig; }
  );
  linux_latest_rockchip_unstable = pkgs.linuxKernel.packagesFor (
    pkgs.linuxKernel.kernels.linux_latest.override { structuredExtraConfig = kernelConfig; }
  );

  linux_6_1_radxa_rk2312_stable = pkgs-stable.linuxKernel.packagesFor (
    pkgs-stable.buildLinux radxaRk2312BuildArgs
  );
  linux_6_1_radxa_rk2312_unstable = pkgs.linuxKernel.packagesFor (
    pkgs.buildLinux radxaRk2312BuildArgs
  );
      
  linux_6_18_pinetab_stable =
    let
      version = "6.18.10-danctnix1";
    in
    pkgs-stable.linuxKernel.packagesFor (
      pkgs-stable.linuxKernel.kernels.linux_6_18.override {
        argsOverride = {
          src = pkgs.fetchFromGitea {
            domain = "codeberg.org";
            owner = "DanctNIX";
            repo = "linux-pinetab2";
            rev = "v${version}";
            hash = "sha256-AOifTyqX8x0ea6jg1GQaoiehS0H1oat3C9HK9fgMKwg=";
          };
          inherit version;
          modDirVersion = version;
        };
        kernelPatches = [
          {
            name = "Enable backlight in defconfig";
            patch = ./backlight.patch;
          }
        ];
        structuredExtraConfig = kernelConfig // pinetabKernelConfig;
      }
    );

  linux_7_0_pinetab_unstable =
    let
      version = "7.0.6-danctnix1";
    in
    pkgs.linuxKernel.packagesFor (
      pkgs.linuxKernel.kernels.linux_7_0.override {
        argsOverride = {
          src = pkgs.fetchFromGitea {
            domain = "codeberg.org";
            owner = "DanctNIX";
            repo = "linux-pinetab2";
            rev = "v${version}";
            hash = "sha256-YYcJF5qmCJGsZhB1xLST/ecaPeOR5QGYEuHMqOHxjZ0=";
          };
          inherit version;
          modDirVersion = version;
        };
        kernelPatches = [
          {
            name = "Enable backlight in defconfig";
            patch = ./backlight-7.0.patch;
          }
        ];
        structuredExtraConfig = kernelConfig // pinetabKernelConfig;
      }
    );

  linux_6_18_orangepi5b_stable = pkgs-stable.linuxKernel.packagesFor (
    pkgs-stable.linuxKernel.kernels.linux_6_18.override {
      structuredExtraConfig = kernelConfig;
      kernelPatches = [
        {
          name = "Set the clock of the bcrm driver to 32khz as required by bcm43752.";
          patch = ./patches/linux/6.17/rk3588-0802-wireless-add-clk-property.patch;
        }
      ];
    }
  );

  linux_6_18_orangepi5b_unstable = pkgs.linuxKernel.packagesFor (
    pkgs.linuxKernel.kernels.linux_6_18.override {
      structuredExtraConfig = kernelConfig;
      kernelPatches = [
        {
          name = "Set the clock of the bcrm driver to 32khz as required by bcm43752.";
          patch = ./patches/linux/6.17/rk3588-0802-wireless-add-clk-property.patch;
        }
      ];
    }
  );
}
