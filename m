From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 16 Jun 2004 16:08:23 +0000
Subject: [PATCH] update sn2_defconfig
Message-Id: <200406161208.23618.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_3BH0AJcEYwMgm0y"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_3BH0AJcEYwMgm0y
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Small patch to update the sn2_defconfig file.  I just did a 'make oldconfig' 
with the current sn2_defconfig and removed 8250 support.  Please include it 
in your 2.6.7-ia64 patch if there's still time.

Thanks,
Jesse

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>


--Boundary-00=_3BH0AJcEYwMgm0y
Content-Type: text/x-diff;
  charset="us-ascii";
  name="sn2-defconfig-update.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sn2-defconfig-update.patch"

===== arch/ia64/configs/sn2_defconfig 1.6 vs edited =====
--- 1.6/arch/ia64/configs/sn2_defconfig	2004-03-23 13:18:46 -05:00
+++ edited/arch/ia64/configs/sn2_defconfig	2004-06-16 12:03:12 -04:00
@@ -14,18 +14,22 @@
 #
 CONFIG_SWAP=y
 CONFIG_SYSVIPC=y
+CONFIG_POSIX_MQUEUE=y
 # CONFIG_BSD_PROCESS_ACCT is not set
 CONFIG_SYSCTL=y
+# CONFIG_AUDIT is not set
 CONFIG_LOG_BUF_SHIFT=20
 CONFIG_HOTPLUG=y
 # CONFIG_IKCONFIG is not set
 # CONFIG_EMBEDDED is not set
 CONFIG_KALLSYMS=y
+CONFIG_KALLSYMS_ALL=y
 CONFIG_FUTEX=y
 CONFIG_EPOLL=y
 CONFIG_IOSCHED_NOOP=y
 CONFIG_IOSCHED_AS=y
 CONFIG_IOSCHED_DEADLINE=y
+CONFIG_IOSCHED_CFQ=y
 # CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
 
 #
@@ -60,7 +64,6 @@
 CONFIG_IA64_PAGE_SIZE_16KB=y
 # CONFIG_IA64_PAGE_SIZE_64KB is not set
 CONFIG_IA64_L1_CACHE_SHIFT=7
-# CONFIG_MCKINLEY_ASTEP_SPECIFIC is not set
 CONFIG_NUMA=y
 CONFIG_VIRTUAL_MEM_MAP=y
 CONFIG_DISCONTIGMEM=y
@@ -70,12 +73,17 @@
 CONFIG_FORCE_MAX_ZONEORDER=18
 CONFIG_SMP=y
 CONFIG_NR_CPUS=512
+# CONFIG_HOTPLUG_CPU is not set
 # CONFIG_PREEMPT is not set
 CONFIG_HAVE_DEC_LOCK=y
 CONFIG_IA32_SUPPORT=y
 CONFIG_COMPAT=y
 CONFIG_PERFMON=y
 CONFIG_IA64_PALINFO=y
+
+#
+# Firmware Drivers
+#
 CONFIG_EFI_VARS=y
 CONFIG_BINFMT_ELF=y
 # CONFIG_BINFMT_MISC is not set
@@ -105,6 +113,7 @@
 #
 CONFIG_PCI=y
 CONFIG_PCI_DOMAINS=y
+# CONFIG_PCI_USE_VECTOR is not set
 CONFIG_PCI_LEGACY_PROC=y
 CONFIG_PCI_NAMES=y
 
@@ -174,7 +183,6 @@
 #
 CONFIG_BLK_DEV_IDEDISK=y
 # CONFIG_IDEDISK_MULTI_MODE is not set
-# CONFIG_IDEDISK_STROKE is not set
 CONFIG_BLK_DEV_IDECD=m
 CONFIG_BLK_DEV_IDETAPE=m
 CONFIG_BLK_DEV_IDEFLOPPY=y
@@ -218,6 +226,7 @@
 # CONFIG_BLK_DEV_SLC90E66 is not set
 # CONFIG_BLK_DEV_TRM290 is not set
 # CONFIG_BLK_DEV_VIA82CXXX is not set
+# CONFIG_IDE_ARM is not set
 CONFIG_BLK_DEV_IDEDMA=y
 # CONFIG_IDEDMA_IVB is not set
 CONFIG_IDEDMA_AUTO=y
@@ -243,7 +252,6 @@
 # Some SCSI devices (e.g. CD jukebox) support multiple LUNs
 #
 # CONFIG_SCSI_MULTI_LUN is not set
-CONFIG_SCSI_REPORT_LUNS=y
 CONFIG_SCSI_CONSTANTS=y
 # CONFIG_SCSI_LOGGING is not set
 
@@ -281,7 +289,9 @@
 CONFIG_SCSI_SATA_SVW=m
 CONFIG_SCSI_ATA_PIIX=m
 CONFIG_SCSI_SATA_PROMISE=m
+# CONFIG_SCSI_SATA_SX4 is not set
 # CONFIG_SCSI_SATA_SIL is not set
+# CONFIG_SCSI_SATA_SIS is not set
 CONFIG_SCSI_SATA_VIA=m
 CONFIG_SCSI_SATA_VITESSE=y
 # CONFIG_SCSI_BUSLOGIC is not set
@@ -298,6 +308,7 @@
 CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
 CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
 # CONFIG_SCSI_SYM53C8XX_IOMAPPED is not set
+# CONFIG_SCSI_IPR is not set
 # CONFIG_SCSI_QLOGIC_ISP is not set
 # CONFIG_SCSI_QLOGIC_FC is not set
 CONFIG_SCSI_QLOGIC_1280=y
@@ -343,6 +354,7 @@
 #
 # I2O device support
 #
+# CONFIG_I2O is not set
 
 #
 # Networking support
@@ -389,8 +401,6 @@
 CONFIG_INET6_ESP=m
 CONFIG_INET6_IPCOMP=m
 CONFIG_IPV6_TUNNEL=m
-# CONFIG_DECNET is not set
-CONFIG_BRIDGE=m
 CONFIG_NETFILTER=y
 # CONFIG_NETFILTER_DEBUG is not set
 CONFIG_BRIDGE_NETFILTER=y
@@ -452,6 +462,7 @@
 CONFIG_IP_NF_ARP_MANGLE=m
 # CONFIG_IP_NF_COMPAT_IPCHAINS is not set
 # CONFIG_IP_NF_COMPAT_IPFWADM is not set
+# CONFIG_IP_NF_RAW is not set
 
 #
 # IPv6: Netfilter Configuration
@@ -471,7 +482,9 @@
 #
 # CONFIG_IP_SCTP is not set
 # CONFIG_ATM is not set
+CONFIG_BRIDGE=m
 CONFIG_VLAN_8021Q=m
+# CONFIG_DECNET is not set
 # CONFIG_LLC2 is not set
 # CONFIG_IPX is not set
 # CONFIG_ATALK is not set
@@ -516,12 +529,14 @@
 # Network testing
 #
 # CONFIG_NET_PKTGEN is not set
+CONFIG_NETPOLL=y
+# CONFIG_NETPOLL_RX is not set
+# CONFIG_NETPOLL_TRAP is not set
+CONFIG_NET_POLL_CONTROLLER=y
+# CONFIG_HAMRADIO is not set
+# CONFIG_IRDA is not set
+# CONFIG_BT is not set
 CONFIG_NETDEVICES=y
-
-#
-# ARCnet devices
-#
-# CONFIG_ARCNET is not set
 CONFIG_DUMMY=m
 CONFIG_BONDING=m
 CONFIG_EQUALIZER=m
@@ -529,6 +544,11 @@
 # CONFIG_ETHERTAP is not set
 
 #
+# ARCnet devices
+#
+# CONFIG_ARCNET is not set
+
+#
 # Ethernet (10 or 100Mbit)
 #
 CONFIG_NET_ETHERNET=y
@@ -582,7 +602,6 @@
 CONFIG_HAMACHI=m
 CONFIG_YELLOWFIN=m
 CONFIG_R8169=m
-CONFIG_SIS190=m
 CONFIG_SK98LIN=m
 CONFIG_TIGON3=y
 
@@ -591,6 +610,22 @@
 #
 CONFIG_IXGB=m
 # CONFIG_IXGB_NAPI is not set
+# CONFIG_S2IO is not set
+
+#
+# Token Ring devices
+#
+# CONFIG_TR is not set
+
+#
+# Wireless LAN (non-hamradio)
+#
+# CONFIG_NET_RADIO is not set
+
+#
+# Wan interfaces
+#
+# CONFIG_WAN is not set
 # CONFIG_FDDI is not set
 # CONFIG_HIPPI is not set
 CONFIG_PPP=m
@@ -602,45 +637,11 @@
 # CONFIG_PPP_BSDCOMP is not set
 # CONFIG_PPPOE is not set
 # CONFIG_SLIP is not set
-
-#
-# Wireless LAN (non-hamradio)
-#
-# CONFIG_NET_RADIO is not set
-
-#
-# Token Ring devices
-#
-# CONFIG_TR is not set
 CONFIG_NET_FC=y
 # CONFIG_SHAPER is not set
 CONFIG_NETCONSOLE=y
 
 #
-# Wan interfaces
-#
-# CONFIG_WAN is not set
-
-#
-# Amateur Radio support
-#
-# CONFIG_HAMRADIO is not set
-
-#
-# IrDA (infrared) support
-#
-# CONFIG_IRDA is not set
-
-#
-# Bluetooth support
-#
-# CONFIG_BT is not set
-CONFIG_NETPOLL=y
-# CONFIG_NETPOLL_RX is not set
-# CONFIG_NETPOLL_TRAP is not set
-CONFIG_NET_POLL_CONTROLLER=y
-
-#
 # ISDN subsystem
 #
 # CONFIG_ISDN is not set
@@ -703,6 +704,7 @@
 CONFIG_HW_CONSOLE=y
 CONFIG_SERIAL_NONSTANDARD=y
 # CONFIG_ROCKETPORT is not set
+# CONFIG_CYCLADES is not set
 # CONFIG_SYNCLINK is not set
 # CONFIG_SYNCLINKMP is not set
 # CONFIG_N_HDLC is not set
@@ -713,18 +715,11 @@
 #
 # Serial drivers
 #
-CONFIG_SERIAL_8250=y
-CONFIG_SERIAL_8250_CONSOLE=y
-CONFIG_SERIAL_8250_HCDP=y
-CONFIG_SERIAL_8250_ACPI=y
-CONFIG_SERIAL_8250_NR_UARTS=4
-# CONFIG_SERIAL_8250_EXTENDED is not set
+# CONFIG_SERIAL_8250 is not set
 
 #
 # Non-8250 serial port support
 #
-CONFIG_SERIAL_CORE=y
-CONFIG_SERIAL_CORE_CONSOLE=y
 CONFIG_UNIX98_PTYS=y
 CONFIG_LEGACY_PTYS=y
 CONFIG_LEGACY_PTY_COUNT=256
@@ -740,7 +735,6 @@
 #
 # CONFIG_WATCHDOG is not set
 # CONFIG_HW_RANDOM is not set
-# CONFIG_GEN_RTC is not set
 CONFIG_EFI_RTC=y
 # CONFIG_DTLK is not set
 # CONFIG_R3964 is not set
@@ -852,6 +846,7 @@
 #
 CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
+CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
@@ -897,7 +892,6 @@
 # CONFIG_CIFS is not set
 # CONFIG_NCP_FS is not set
 # CONFIG_CODA_FS is not set
-# CONFIG_INTERMEZZO_FS is not set
 # CONFIG_AFS_FS is not set
 
 #
@@ -968,6 +962,7 @@
 # Library routines
 #
 CONFIG_CRC32=y
+# CONFIG_LIBCRC32C is not set
 CONFIG_ZLIB_INFLATE=m
 CONFIG_ZLIB_DEFLATE=m
 
@@ -1019,4 +1014,5 @@
 # CONFIG_CRYPTO_ARC4 is not set
 CONFIG_CRYPTO_DEFLATE=m
 # CONFIG_CRYPTO_MICHAEL_MIC is not set
+# CONFIG_CRYPTO_CRC32C is not set
 # CONFIG_CRYPTO_TEST is not set

--Boundary-00=_3BH0AJcEYwMgm0y--
