From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 25 Mar 2004 22:27:40 +0000
Subject: [PATCH] update sn2_defconfig
Message-Id: <200403251427.40862.jbarnes@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_cz1YA1nYBy+6K9z"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_cz1YA1nYBy+6K9z
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Just a quick update to the sn2_defconfig file.  Turns on a few more options.

Jesse


--Boundary-00=_cz1YA1nYBy+6K9z
Content-Type: text/plain;
  charset="us-ascii";
  name="sn2-defconfig-update.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sn2-defconfig-update.patch"

===== arch/ia64/configs/sn2_defconfig 1.4 vs edited =====
--- 1.4/arch/ia64/configs/sn2_defconfig	Mon Mar 15 05:55:41 2004
+++ edited/arch/ia64/configs/sn2_defconfig	Thu Mar 25 14:18:56 2004
@@ -48,31 +48,26 @@
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 CONFIG_TIME_INTERPOLATION=y
 CONFIG_EFI=y
-# CONFIG_ITANIUM is not set
-CONFIG_MCKINLEY=y
 # CONFIG_IA64_GENERIC is not set
 # CONFIG_IA64_DIG is not set
 # CONFIG_IA64_HP_ZX1 is not set
 CONFIG_IA64_SGI_SN2=y
 # CONFIG_IA64_HP_SIM is not set
+# CONFIG_ITANIUM is not set
+CONFIG_MCKINLEY=y
 # CONFIG_IA64_PAGE_SIZE_4KB is not set
 # CONFIG_IA64_PAGE_SIZE_8KB is not set
 CONFIG_IA64_PAGE_SIZE_16KB=y
 # CONFIG_IA64_PAGE_SIZE_64KB is not set
-CONFIG_ACPI=y
-CONFIG_ACPI_INTERPRETER=y
-CONFIG_ACPI_KERNEL_CONFIG=y
 CONFIG_IA64_L1_CACHE_SHIFT=7
 # CONFIG_MCKINLEY_ASTEP_SPECIFIC is not set
 CONFIG_NUMA=y
 CONFIG_VIRTUAL_MEM_MAP=y
 CONFIG_DISCONTIGMEM=y
-CONFIG_IA64_MCA=y
 # CONFIG_IA64_CYCLONE is not set
 CONFIG_IOSAPIC=y
-# CONFIG_IA64_SGI_SN_SIM is not set
+CONFIG_IA64_SGI_SN_SIM=y
 CONFIG_FORCE_MAX_ZONEORDER=18
-# CONFIG_IA64_PAL_IDLE is not set
 CONFIG_SMP=y
 CONFIG_NR_CPUS=512
 # CONFIG_PREEMPT is not set
@@ -86,9 +81,15 @@
 # CONFIG_BINFMT_MISC is not set
 
 #
+# Power management and ACPI
+#
+CONFIG_ACPI=y
+
+#
 # ACPI (Advanced Configuration and Power Interface) Support
 #
 CONFIG_ACPI_BOOT=y
+CONFIG_ACPI_INTERPRETER=y
 # CONFIG_ACPI_BUTTON is not set
 # CONFIG_ACPI_FAN is not set
 # CONFIG_ACPI_PROCESSOR is not set
@@ -98,6 +99,10 @@
 CONFIG_ACPI_POWER=y
 CONFIG_ACPI_PCI=y
 CONFIG_ACPI_SYSTEM=y
+
+#
+# Bus options (PCI, PCMCIA)
+#
 CONFIG_PCI=y
 CONFIG_PCI_DOMAINS=y
 CONFIG_PCI_LEGACY_PROC=y
@@ -106,7 +111,13 @@
 #
 # PCI Hotplug Support
 #
-# CONFIG_HOTPLUG_PCI is not set
+CONFIG_HOTPLUG_PCI=y
+# CONFIG_HOTPLUG_PCI_FAKE is not set
+# CONFIG_HOTPLUG_PCI_ACPI is not set
+# CONFIG_HOTPLUG_PCI_CPCI is not set
+# CONFIG_HOTPLUG_PCI_PCIE is not set
+# CONFIG_HOTPLUG_PCI_SHPC is not set
+CONFIG_HOTPLUG_PCI_SGI=y
 
 #
 # PCMCIA/CardBus support
@@ -120,7 +131,7 @@
 #
 # Generic Driver Options
 #
-# CONFIG_FW_LOADER is not set
+CONFIG_FW_LOADER=m
 # CONFIG_DEBUG_DRIVER is not set
 
 #
@@ -140,13 +151,12 @@
 #
 # Block devices
 #
-# CONFIG_BLK_DEV_FD is not set
 # CONFIG_BLK_CPQ_DA is not set
 # CONFIG_BLK_CPQ_CISS_DA is not set
 CONFIG_BLK_DEV_DAC960=m
 CONFIG_BLK_DEV_UMEM=m
 CONFIG_BLK_DEV_LOOP=y
-# CONFIG_BLK_DEV_CRYPTOLOOP is not set
+CONFIG_BLK_DEV_CRYPTOLOOP=m
 CONFIG_BLK_DEV_NBD=m
 # CONFIG_BLK_DEV_CARMEL is not set
 CONFIG_BLK_DEV_RAM=y
@@ -272,6 +282,7 @@
 CONFIG_SCSI_SATA_SVW=m
 CONFIG_SCSI_ATA_PIIX=m
 CONFIG_SCSI_SATA_PROMISE=m
+# CONFIG_SCSI_SATA_SIL is not set
 CONFIG_SCSI_SATA_VIA=m
 CONFIG_SCSI_SATA_VITESSE=y
 # CONFIG_SCSI_BUSLOGIC is not set
@@ -314,12 +325,12 @@
 # CONFIG_MD_RAID6 is not set
 CONFIG_MD_MULTIPATH=y
 CONFIG_BLK_DEV_DM=y
-# CONFIG_DM_CRYPT is not set
+CONFIG_DM_CRYPT=m
 
 #
 # Fusion MPT device support
 #
-CONFIG_FUSION=m
+CONFIG_FUSION=y
 CONFIG_FUSION_MAX_SGE=40
 CONFIG_FUSION_ISENSE=m
 CONFIG_FUSION_CTL=m
@@ -364,7 +375,6 @@
 CONFIG_IP_PIMSM_V1=y
 CONFIG_IP_PIMSM_V2=y
 CONFIG_ARPD=y
-# CONFIG_INET_ECN is not set
 CONFIG_SYN_COOKIES=y
 CONFIG_INET_AH=m
 CONFIG_INET_ESP=m
@@ -460,7 +470,6 @@
 #
 # SCTP Configuration (EXPERIMENTAL)
 #
-CONFIG_IPV6_SCTP__=m
 # CONFIG_IP_SCTP is not set
 # CONFIG_ATM is not set
 CONFIG_VLAN_8021Q=m
@@ -490,6 +499,7 @@
 CONFIG_NET_SCH_TBF=m
 CONFIG_NET_SCH_GRED=m
 CONFIG_NET_SCH_DSMARK=m
+# CONFIG_NET_SCH_DELAY is not set
 # CONFIG_NET_SCH_INGRESS is not set
 CONFIG_NET_QOS=y
 CONFIG_NET_ESTIMATOR=y
@@ -523,12 +533,10 @@
 # Ethernet (10 or 100Mbit)
 #
 CONFIG_NET_ETHERNET=y
-CONFIG_MII=y
+CONFIG_MII=m
 # CONFIG_HAPPYMEAL is not set
 # CONFIG_SUNGEM is not set
-CONFIG_NET_VENDOR_3COM=y
-CONFIG_VORTEX=m
-CONFIG_TYPHOON=m
+# CONFIG_NET_VENDOR_3COM is not set
 
 #
 # Tulip family network device support
@@ -550,7 +558,7 @@
 # CONFIG_B44 is not set
 # CONFIG_FORCEDETH is not set
 # CONFIG_DGRS is not set
-CONFIG_EEPRO100=y
+CONFIG_EEPRO100=m
 # CONFIG_EEPRO100_PIO is not set
 # CONFIG_E100 is not set
 # CONFIG_FEALNX is not set
@@ -582,7 +590,8 @@
 #
 # Ethernet (10000 Mbit)
 #
-# CONFIG_IXGB is not set
+CONFIG_IXGB=m
+# CONFIG_IXGB_NAPI is not set
 # CONFIG_FDDI is not set
 # CONFIG_HIPPI is not set
 CONFIG_PPP=m
@@ -606,7 +615,7 @@
 # CONFIG_TR is not set
 CONFIG_NET_FC=y
 # CONFIG_SHAPER is not set
-# CONFIG_NETCONSOLE is not set
+CONFIG_NETCONSOLE=y
 
 #
 # Wan interfaces
@@ -627,8 +636,10 @@
 # Bluetooth support
 #
 # CONFIG_BT is not set
-# CONFIG_NETPOLL is not set
-# CONFIG_NET_POLL_CONTROLLER is not set
+CONFIG_NETPOLL=y
+# CONFIG_NETPOLL_RX is not set
+# CONFIG_NETPOLL_TRAP is not set
+CONFIG_NET_POLL_CONTROLLER=y
 
 #
 # ISDN subsystem
@@ -674,9 +685,13 @@
 CONFIG_INPUT_KEYBOARD=y
 CONFIG_KEYBOARD_ATKBD=y
 # CONFIG_KEYBOARD_SUNKBD is not set
+# CONFIG_KEYBOARD_LKKBD is not set
 # CONFIG_KEYBOARD_XTKBD is not set
 # CONFIG_KEYBOARD_NEWTON is not set
-# CONFIG_INPUT_MOUSE is not set
+CONFIG_INPUT_MOUSE=y
+CONFIG_MOUSE_PS2=y
+# CONFIG_MOUSE_SERIAL is not set
+# CONFIG_MOUSE_VSXXXAA is not set
 # CONFIG_INPUT_JOYSTICK is not set
 # CONFIG_INPUT_TOUCHSCREEN is not set
 # CONFIG_INPUT_MISC is not set
@@ -714,11 +729,6 @@
 CONFIG_UNIX98_PTYS=y
 CONFIG_LEGACY_PTYS=y
 CONFIG_LEGACY_PTY_COUNT=256
-
-#
-# Mice
-#
-# CONFIG_BUSMOUSE is not set
 # CONFIG_QIC02_TAPE is not set
 
 #
@@ -742,7 +752,8 @@
 #
 # CONFIG_AGP is not set
 # CONFIG_DRM is not set
-# CONFIG_RAW_DRIVER is not set
+CONFIG_RAW_DRIVER=m
+CONFIG_MAX_RAW_DEVS=256
 
 #
 # I2C support
@@ -825,9 +836,9 @@
 # CD-ROM/DVD Filesystems
 #
 CONFIG_ISO9660_FS=y
-# CONFIG_JOLIET is not set
+CONFIG_JOLIET=y
 # CONFIG_ZISOFS is not set
-# CONFIG_UDF_FS is not set
+CONFIG_UDF_FS=m
 
 #
 # DOS/FAT/NT Filesystems
@@ -887,6 +898,7 @@
 # CONFIG_CIFS is not set
 # CONFIG_NCP_FS is not set
 # CONFIG_CODA_FS is not set
+# CONFIG_INTERMEZZO_FS is not set
 # CONFIG_AFS_FS is not set
 
 #
@@ -980,6 +992,7 @@
 # CONFIG_IA64_DEBUG_CMPXCHG is not set
 # CONFIG_IA64_DEBUG_IRQ is not set
 # CONFIG_DEBUG_INFO is not set
+CONFIG_SYSVIPC_COMPAT=y
 
 #
 # Security options
@@ -1006,4 +1019,5 @@
 # CONFIG_CRYPTO_CAST6 is not set
 # CONFIG_CRYPTO_ARC4 is not set
 CONFIG_CRYPTO_DEFLATE=m
+# CONFIG_CRYPTO_MICHAEL_MIC is not set
 # CONFIG_CRYPTO_TEST is not set

--Boundary-00=_cz1YA1nYBy+6K9z--
