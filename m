From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 17 Aug 2005 00:26:37 +0000
Subject: Updated zx1 defconfig
Message-Id: <17154.33853.725478.789499@berry.gelato.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,
	Just `make oldconfig' doesn't help for the zx1 defconfig ---
because we need the MPT Fusion drivers, which are picked up as not
selected.
Tested on HP ZX2000 and ZX2600.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>


Index: linux-2.6-ia64/arch/ia64/configs/zx1_defconfig
=================================--- linux-2.6-ia64.orig/arch/ia64/configs/zx1_defconfig	2005-08-01 15:21:46.135968631 +1000
+++ linux-2.6-ia64/arch/ia64/configs/zx1_defconfig	2005-08-17 10:25:30.820735227 +1000
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.13-rc1-20050629
-# Wed Jun 29 15:31:11 2005
+# Linux kernel version: 2.6.13-rc6
+# Wed Aug 17 10:02:43 2005
 #
 
 #
@@ -132,6 +132,7 @@
 CONFIG_ACPI_INTERPRETER=y
 CONFIG_ACPI_BUTTON=y
 CONFIG_ACPI_VIDEO=m
+CONFIG_ACPI_HOTKEY=m
 CONFIG_ACPI_FAN=y
 CONFIG_ACPI_PROCESSOR=y
 CONFIG_ACPI_THERMAL=y
@@ -169,6 +170,83 @@
 # CONFIG_PCCARD is not set
 
 #
+# Networking
+#
+CONFIG_NET=y
+
+#
+# Networking options
+#
+CONFIG_PACKET=y
+# CONFIG_PACKET_MMAP is not set
+CONFIG_UNIX=y
+# CONFIG_NET_KEY is not set
+CONFIG_INET=y
+CONFIG_IP_MULTICAST=y
+# CONFIG_IP_ADVANCED_ROUTER is not set
+CONFIG_IP_FIB_HASH=y
+# CONFIG_IP_PNP is not set
+# CONFIG_NET_IPIP is not set
+# CONFIG_NET_IPGRE is not set
+# CONFIG_IP_MROUTE is not set
+# CONFIG_ARPD is not set
+# CONFIG_SYN_COOKIES is not set
+# CONFIG_INET_AH is not set
+# CONFIG_INET_ESP is not set
+# CONFIG_INET_IPCOMP is not set
+# CONFIG_INET_TUNNEL is not set
+# CONFIG_IP_TCPDIAG is not set
+# CONFIG_IP_TCPDIAG_IPV6 is not set
+# CONFIG_TCP_CONG_ADVANCED is not set
+CONFIG_TCP_CONG_BIC=y
+
+#
+# IP: Virtual Server Configuration
+#
+# CONFIG_IP_VS is not set
+# CONFIG_IPV6 is not set
+CONFIG_NETFILTER=y
+# CONFIG_NETFILTER_DEBUG is not set
+
+#
+# IP: Netfilter Configuration
+#
+# CONFIG_IP_NF_CONNTRACK is not set
+# CONFIG_IP_NF_CONNTRACK_MARK is not set
+# CONFIG_IP_NF_QUEUE is not set
+# CONFIG_IP_NF_IPTABLES is not set
+CONFIG_IP_NF_ARPTABLES=y
+# CONFIG_IP_NF_ARPFILTER is not set
+# CONFIG_IP_NF_ARP_MANGLE is not set
+
+#
+# SCTP Configuration (EXPERIMENTAL)
+#
+# CONFIG_IP_SCTP is not set
+# CONFIG_ATM is not set
+# CONFIG_BRIDGE is not set
+# CONFIG_VLAN_8021Q is not set
+# CONFIG_DECNET is not set
+# CONFIG_LLC2 is not set
+# CONFIG_IPX is not set
+# CONFIG_ATALK is not set
+# CONFIG_X25 is not set
+# CONFIG_LAPB is not set
+# CONFIG_NET_DIVERT is not set
+# CONFIG_ECONET is not set
+# CONFIG_WAN_ROUTER is not set
+# CONFIG_NET_SCHED is not set
+# CONFIG_NET_CLS_ROUTE is not set
+
+#
+# Network testing
+#
+# CONFIG_NET_PKTGEN is not set
+# CONFIG_HAMRADIO is not set
+# CONFIG_IRDA is not set
+# CONFIG_BT is not set
+
+#
 # Device Drivers
 #
 
@@ -349,6 +427,7 @@
 # CONFIG_SCSI_QLA2300 is not set
 # CONFIG_SCSI_QLA2322 is not set
 # CONFIG_SCSI_QLA6312 is not set
+# CONFIG_SCSI_QLA24XX is not set
 # CONFIG_SCSI_LPFC is not set
 # CONFIG_SCSI_DC395x is not set
 # CONFIG_SCSI_DC390T is not set
@@ -362,9 +441,11 @@
 #
 # Fusion MPT device support
 #
-# CONFIG_FUSION is not set
-# CONFIG_FUSION_SPI is not set
-# CONFIG_FUSION_FC is not set
+CONFIG_FUSION=y
+CONFIG_FUSION_SPI=y
+CONFIG_FUSION_FC=y
+CONFIG_FUSION_MAX_SGE8
+CONFIG_FUSION_CTL=m
 
 #
 # IEEE 1394 (FireWire) support
@@ -377,87 +458,8 @@
 # CONFIG_I2O is not set
 
 #
-# Networking support
-#
-CONFIG_NET=y
-
-#
-# Networking options
-#
-CONFIG_PACKET=y
-# CONFIG_PACKET_MMAP is not set
-CONFIG_UNIX=y
-# CONFIG_NET_KEY is not set
-CONFIG_INET=y
-CONFIG_IP_MULTICAST=y
-# CONFIG_IP_ADVANCED_ROUTER is not set
-CONFIG_IP_FIB_HASH=y
-# CONFIG_IP_PNP is not set
-# CONFIG_NET_IPIP is not set
-# CONFIG_NET_IPGRE is not set
-# CONFIG_IP_MROUTE is not set
-# CONFIG_ARPD is not set
-# CONFIG_SYN_COOKIES is not set
-# CONFIG_INET_AH is not set
-# CONFIG_INET_ESP is not set
-# CONFIG_INET_IPCOMP is not set
-# CONFIG_INET_TUNNEL is not set
-# CONFIG_IP_TCPDIAG is not set
-# CONFIG_IP_TCPDIAG_IPV6 is not set
-# CONFIG_TCP_CONG_ADVANCED is not set
-CONFIG_TCP_CONG_BIC=y
-
-#
-# IP: Virtual Server Configuration
-#
-# CONFIG_IP_VS is not set
-# CONFIG_IPV6 is not set
-CONFIG_NETFILTER=y
-# CONFIG_NETFILTER_DEBUG is not set
-
-#
-# IP: Netfilter Configuration
+# Network device support
 #
-# CONFIG_IP_NF_CONNTRACK is not set
-# CONFIG_IP_NF_CONNTRACK_MARK is not set
-# CONFIG_IP_NF_QUEUE is not set
-# CONFIG_IP_NF_IPTABLES is not set
-CONFIG_IP_NF_ARPTABLES=y
-# CONFIG_IP_NF_ARPFILTER is not set
-# CONFIG_IP_NF_ARP_MANGLE is not set
-
-#
-# SCTP Configuration (EXPERIMENTAL)
-#
-# CONFIG_IP_SCTP is not set
-# CONFIG_ATM is not set
-# CONFIG_BRIDGE is not set
-# CONFIG_VLAN_8021Q is not set
-# CONFIG_DECNET is not set
-# CONFIG_LLC2 is not set
-# CONFIG_IPX is not set
-# CONFIG_ATALK is not set
-# CONFIG_X25 is not set
-# CONFIG_LAPB is not set
-# CONFIG_NET_DIVERT is not set
-# CONFIG_ECONET is not set
-# CONFIG_WAN_ROUTER is not set
-
-#
-# QoS and/or fair queueing
-#
-# CONFIG_NET_SCHED is not set
-# CONFIG_NET_CLS_ROUTE is not set
-
-#
-# Network testing
-#
-# CONFIG_NET_PKTGEN is not set
-# CONFIG_NETPOLL is not set
-# CONFIG_NET_POLL_CONTROLLER is not set
-# CONFIG_HAMRADIO is not set
-# CONFIG_IRDA is not set
-# CONFIG_BT is not set
 CONFIG_NETDEVICES=y
 CONFIG_DUMMY=y
 # CONFIG_BONDING is not set
@@ -555,6 +557,8 @@
 # CONFIG_NET_FC is not set
 # CONFIG_SHAPER is not set
 # CONFIG_NETCONSOLE is not set
+# CONFIG_NETPOLL is not set
+# CONFIG_NET_POLL_CONTROLLER is not set
 
 #
 # ISDN subsystem
@@ -659,6 +663,7 @@
 CONFIG_DRM_RADEON=y
 # CONFIG_DRM_MGA is not set
 # CONFIG_DRM_SIS is not set
+# CONFIG_DRM_VIA is not set
 # CONFIG_RAW_DRIVER is not set
 # CONFIG_HPET is not set
 # CONFIG_HANGCHECK_TIMER is not set
@@ -706,47 +711,10 @@
 # CONFIG_I2C_VIAPRO is not set
 # CONFIG_I2C_VOODOO3 is not set
 # CONFIG_I2C_PCA_ISA is not set
-
-#
-# Hardware Sensors Chip support
-#
 # CONFIG_I2C_SENSOR is not set
-# CONFIG_SENSORS_ADM1021 is not set
-# CONFIG_SENSORS_ADM1025 is not set
-# CONFIG_SENSORS_ADM1026 is not set
-# CONFIG_SENSORS_ADM1031 is not set
-# CONFIG_SENSORS_ADM9240 is not set
-# CONFIG_SENSORS_ASB100 is not set
-# CONFIG_SENSORS_ATXP1 is not set
-# CONFIG_SENSORS_DS1621 is not set
-# CONFIG_SENSORS_FSCHER is not set
-# CONFIG_SENSORS_FSCPOS is not set
-# CONFIG_SENSORS_GL518SM is not set
-# CONFIG_SENSORS_GL520SM is not set
-# CONFIG_SENSORS_IT87 is not set
-# CONFIG_SENSORS_LM63 is not set
-# CONFIG_SENSORS_LM75 is not set
-# CONFIG_SENSORS_LM77 is not set
-# CONFIG_SENSORS_LM78 is not set
-# CONFIG_SENSORS_LM80 is not set
-# CONFIG_SENSORS_LM83 is not set
-# CONFIG_SENSORS_LM85 is not set
-# CONFIG_SENSORS_LM87 is not set
-# CONFIG_SENSORS_LM90 is not set
-# CONFIG_SENSORS_LM92 is not set
-# CONFIG_SENSORS_MAX1619 is not set
-# CONFIG_SENSORS_PC87360 is not set
-# CONFIG_SENSORS_SMSC47B397 is not set
-# CONFIG_SENSORS_SIS5595 is not set
-# CONFIG_SENSORS_SMSC47M1 is not set
-# CONFIG_SENSORS_VIA686A is not set
-# CONFIG_SENSORS_W83781D is not set
-# CONFIG_SENSORS_W83L785TS is not set
-# CONFIG_SENSORS_W83627HF is not set
-# CONFIG_SENSORS_W83627EHF is not set
 
 #
-# Other I2C Chip support
+# Miscellaneous I2C Chip support
 #
 # CONFIG_SENSORS_DS1337 is not set
 # CONFIG_SENSORS_DS1374 is not set
@@ -767,6 +735,11 @@
 # CONFIG_W1 is not set
 
 #
+# Hardware Monitoring support
+#
+# CONFIG_HWMON is not set
+
+#
 # Misc devices
 #
 
@@ -782,7 +755,6 @@
 #
 # Video Adapters
 #
-# CONFIG_TUNER_MULTI_I2C is not set
 # CONFIG_VIDEO_BT848 is not set
 # CONFIG_VIDEO_CPIA is not set
 # CONFIG_VIDEO_SAA5246A is not set
@@ -1025,6 +997,7 @@
 # CONFIG_USB_EGALAX is not set
 # CONFIG_USB_XPAD is not set
 # CONFIG_USB_ATI_REMOTE is not set
+# CONFIG_USB_KEYSPAN_REMOTE is not set
 
 #
 # USB Imaging devices
@@ -1080,6 +1053,7 @@
 # CONFIG_USB_PHIDGETSERVO is not set
 # CONFIG_USB_IDMOUSE is not set
 # CONFIG_USB_SISUSBVGA is not set
+# CONFIG_USB_LD is not set
 
 #
 # USB DSL modem support
@@ -1121,6 +1095,7 @@
 CONFIG_FS_MBCACHE=y
 # CONFIG_REISERFS_FS is not set
 # CONFIG_JFS_FS is not set
+# CONFIG_FS_POSIX_ACL is not set
 
 #
 # XFS support
@@ -1128,6 +1103,7 @@
 # CONFIG_XFS_FS is not set
 # CONFIG_MINIX_FS is not set
 # CONFIG_ROMFS_FS is not set
+# CONFIG_INOTIFY is not set
 # CONFIG_QUOTA is not set
 CONFIG_DNOTIFY=y
 CONFIG_AUTOFS_FS=y
