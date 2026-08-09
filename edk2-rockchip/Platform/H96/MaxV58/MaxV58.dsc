## @file
#
#  Copyright (c) 2014-2018, Linaro Limited. All rights reserved.
#  Copyright (c) 2023-2024, Mario Bălănică <mariobalanica02@gmail.com>
#
#  SPDX-License-Identifier: BSD-2-Clause-Patent
#
##

################################################################################
#
# Defines Section - statements that will be processed to create a Makefile.
#
################################################################################
[Defines]
  PLATFORM_NAME                  = MaxV58
  PLATFORM_VENDOR                = H96
  PLATFORM_GUID                  = 88a8247e-0eab-4fba-9d08-d52038ea70ea
  PLATFORM_VERSION               = 0.1
  DSC_SPECIFICATION              = 0x00010019
  OUTPUT_DIRECTORY               = Build/$(PLATFORM_NAME)
  VENDOR_DIRECTORY               = Platform/$(PLATFORM_VENDOR)
  PLATFORM_DIRECTORY             = $(VENDOR_DIRECTORY)/$(PLATFORM_NAME)
  SUPPORTED_ARCHITECTURES        = AARCH64
  BUILD_TARGETS                  = DEBUG|RELEASE
  SKUID_IDENTIFIER               = DEFAULT
  FLASH_DEFINITION               = Silicon/Rockchip/RK3588/RK3588.fdf
  RK_PLATFORM_FVMAIN_MODULES     = $(PLATFORM_DIRECTORY)/$(PLATFORM_NAME).Modules.fdf.inc

  #
  # HYM8563 RTC support
  # I2C location configured by PCDs below.
  #
  DEFINE RK_RTC8563_ENABLE = TRUE

  #
  # RK3588-based platform
  #
!include Silicon/Rockchip/RK3588/RK3588Platform.dsc.inc

################################################################################
#
# Library Class section - list of all Library Classes needed by this Platform.
#
################################################################################

[LibraryClasses.common]
  RockchipPlatformLib|$(PLATFORM_DIRECTORY)/Library/RockchipPlatformLib/RockchipPlatformLib.inf

################################################################################
#
# Pcd Section - list of all EDK II PCD Entries defined by this Platform.
#
################################################################################

[PcdsFixedAtBuild.common]
  # SMBIOS platform config
  gRockchipTokenSpaceGuid.PcdPlatformName|"H96 Max V58"
  gRockchipTokenSpaceGuid.PcdPlatformVendorName|"H96"
  gRockchipTokenSpaceGuid.PcdFamilyName|"Max"
  gRockchipTokenSpaceGuid.PcdBoardName|"RK3588 NVR DEMO LP4 V10"
  gRockchipTokenSpaceGuid.PcdDeviceTreeName|"rk3588-h96-max-v58"

  # I2C
  gRockchipTokenSpaceGuid.PcdI2cSlaveAddresses|{ 0x42, 0x43, 0x51 }
  gRockchipTokenSpaceGuid.PcdI2cSlaveBuses|{ 0x0, 0x0, 0x6 }
  gRockchipTokenSpaceGuid.PcdI2cSlaveBusesRuntimeSupport|{ FALSE, FALSE, TRUE }
  gRockchipTokenSpaceGuid.PcdRk860xRegulatorAddresses|{ 0x42, 0x43 }
  gRockchipTokenSpaceGuid.PcdRk860xRegulatorBuses|{ 0x0, 0x0 }
  gRockchipTokenSpaceGuid.PcdRk860xRegulatorTags|{ $(SCMI_CLK_CPUB01), $(SCMI_CLK_CPUB23) }
  gPcf8563RealTimeClockLibTokenSpaceGuid.PcdI2cSlaveAddress|0x51
  gRockchipTokenSpaceGuid.PcdRtc8563Bus|0x6

  #
  # PCIe/SATA/USB Combo PIPE PHY support flags and default values
  #
  # Per the vendor device tree: combphy1 feeds pcie2x1l0 (the soldered
  # Wi-Fi/BT module) and combphy2 feeds usbhost3_0. combphy0 has no
  # enabled consumer.
  #
  gRK3588TokenSpaceGuid.PcdComboPhy0ModeDefault|$(COMBO_PHY_MODE_UNCONNECTED)
  gRK3588TokenSpaceGuid.PcdComboPhy1ModeDefault|$(COMBO_PHY_MODE_PCIE)
  gRK3588TokenSpaceGuid.PcdComboPhy2ModeDefault|$(COMBO_PHY_MODE_USB3)

  #
  # PCI Express 3.0 support flags and default values
  #
  # No PCIe 3.0 controller is wired on this board (pcie3x4/pcie3x2 are both
  # disabled in the vendor DT). RK3588Platform.dsc.inc turns this on for
  # every full RK3588, so it has to be switched off explicitly.
  #
  gRK3588TokenSpaceGuid.PcdPcie30Supported|FALSE

  #
  # USB/DP Combo PHY support flags and default values
  #
  # No DisplayPort output exists, but both USB-DP PHYs stay enabled because
  # usbdrd3_0 (USB 3.0 type-A) and usbdrd3_1 depend on them for USB.
  #
  gRK3588TokenSpaceGuid.PcdUsbDpPhy0Supported|TRUE
  gRK3588TokenSpaceGuid.PcdUsbDpPhy1Supported|TRUE

  #
  # GMAC
  #
  # ethernet@fe1c0000 = GMAC1, rgmii-rxid, tx_delay 0x42, no rx_delay.
  #
  gRK3588TokenSpaceGuid.PcdGmac1Supported|TRUE
  gRK3588TokenSpaceGuid.PcdGmac1TxDelay|0x42

  #
  # Audio
  #
  # i2s@fe470000 (i2s0_8ch) is enabled in the vendor DT and its lrck/sclk/
  # sdi0/sdo0 pins match the ones RK3588Dxe muxes. MCLK GPIO1_PC2 is declared
  # as i2s0-mclk and no enabled node claims it (spi4 is disabled).
  #
  gRK3588TokenSpaceGuid.PcdI2S0Supported|TRUE

  #
  # Display support flags and default values
  #
  # HDMI0 only: HDMI1, eDP0 and eDP1 are all disabled in the vendor DT.
  #
  gRK3588TokenSpaceGuid.PcdDisplayConnectors|{CODE({
    VOP_OUTPUT_IF_HDMI0
  })}

################################################################################
#
# Components Section - list of all EDK II Modules needed by this Platform.
#
################################################################################
[Components.common]
  # ACPI Support
  $(PLATFORM_DIRECTORY)/AcpiTables/AcpiTables.inf

  # Device Tree Support
  $(PLATFORM_DIRECTORY)/DeviceTree/Vendor.inf
  $(PLATFORM_DIRECTORY)/DeviceTree/Mainline.inf

  # Splash screen logo
  $(VENDOR_DIRECTORY)/Drivers/LogoDxe/LogoDxe.inf

################################################################################
#
# Build Options
#
################################################################################
[BuildOptions]
  # GCC 15 defaults to C23, making 'bool' a keyword, which breaks
  # uboot-env.h's 'typedef BOOLEAN bool'. Drop once upstream supports C23.
  GCC:*_*_*_CC_FLAGS = -std=gnu17
