From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 06 Jan 2004 15:40:31 +0000
Subject: Re: [PATCH] first stab at generic_defconfig
Message-Id: <1073403630.6667.17.camel@patsy.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040106012537.GA21877@sgi.com>
In-Reply-To: <20040106012537.GA21877@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2004-01-05 at 18:29, Jesse Barnes wrote:

> Well, here's one that disables some of the block devices I had turned
> on.  I've noticed that some of the other arches try to enable everything
> as a module even if it's not particularly relevant, but maybe we should
> do the same?

   I favor enabling too much, especially USB type things.  As long as
they can be built as modules.  probably ought to take a broad sampling
of SCSI and NICs as well.  Here's a patch that adds some essential
drivers for HP systems and a couple extras.  BTW, the removal of
CONFIG_BLK_DEV_SGIIOC4 was not intentional.  According to a new pull of
linux-ia64-2.5, it depends on IA64_SGI_SN2.  Should that be ||
IA64_GENERIC?  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

--- linux/arch/ia64/configs/generic_defconfig	2004-01-06 08:17:38.000000000 -0700
+++ linux/arch/ia64/configs/generic_defconfig	2004-01-06 08:28:33.000000000 -0700
@@ -17,7 +17,8 @@
 # CONFIG_BSD_PROCESS_ACCT is not set
 CONFIG_SYSCTL=y
 CONFIG_LOG_BUF_SHIFT 
-# CONFIG_IKCONFIG is not set
+CONFIG_IKCONFIG=y
+CONFIG_IKCONFIG_PROC=y
 # CONFIG_EMBEDDED is not set
 CONFIG_KALLSYMS=y
 CONFIG_FUTEX=y
@@ -195,7 +196,7 @@
 # CONFIG_BLK_DEV_AEC62XX is not set
 # CONFIG_BLK_DEV_ALI15X3 is not set
 # CONFIG_BLK_DEV_AMD74XX is not set
-# CONFIG_BLK_DEV_CMD64X is not set
+CONFIG_BLK_DEV_CMD64X=y
 # CONFIG_BLK_DEV_TRIFLEX is not set
 # CONFIG_BLK_DEV_CY82C693 is not set
 # CONFIG_BLK_DEV_CS5520 is not set
@@ -208,7 +209,6 @@
 # CONFIG_BLK_DEV_PDC202XX_OLD is not set
 # CONFIG_BLK_DEV_PDC202XX_NEW is not set
 # CONFIG_BLK_DEV_SVWKS is not set
-CONFIG_BLK_DEV_SGIIOC4=y
 # CONFIG_BLK_DEV_SIIMAGE is not set
 # CONFIG_BLK_DEV_SLC90E66 is not set
 # CONFIG_BLK_DEV_TRM290 is not set
@@ -296,7 +296,11 @@
 # CONFIG_SCSI_GDTH is not set
 # CONFIG_SCSI_IPS is not set
 # CONFIG_SCSI_INIA100 is not set
-# CONFIG_SCSI_SYM53C8XX_2 is not set
+CONFIG_SCSI_SYM53C8XX_2=y
+CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
+CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS
+CONFIG_SCSI_SYM53C8XX_MAX_TAGSd
+# CONFIG_SCSI_SYM53C8XX_IOMAPPED is not set
 # CONFIG_SCSI_QLOGIC_ISP is not set
 CONFIG_SCSI_QLOGIC_FC=y
 # CONFIG_SCSI_QLOGIC_FC_FIRMWARE is not set
@@ -388,7 +392,14 @@
 #
 # Tulip family network device support
 #
-# CONFIG_NET_TULIP is not set
+CONFIG_NET_TULIP=y
+# CONFIG_DE2104X is not set
+CONFIG_TULIP=m
+# CONFIG_TULIP_MWI is not set
+# CONFIG_TULIP_MMIO is not set
+# CONFIG_DE4X5 is not set
+# CONFIG_WINBOND_840 is not set
+# CONFIG_DM9102 is not set
 # CONFIG_HP100 is not set
 CONFIG_NET_PCI=y
 # CONFIG_PCNET32 is not set
@@ -414,7 +425,8 @@
 #
 # CONFIG_ACENIC is not set
 # CONFIG_DL2K is not set
-# CONFIG_E1000 is not set
+CONFIG_E1000=m
+# CONFIG_E1000_NAPI is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
@@ -540,8 +552,12 @@
 CONFIG_SERIAL_8250_CONSOLE=y
 CONFIG_SERIAL_8250_ACPI=y
 CONFIG_SERIAL_8250_HCDP=y
-CONFIG_SERIAL_8250_NR_UARTS=4
-# CONFIG_SERIAL_8250_EXTENDED is not set
+CONFIG_SERIAL_8250_NR_UARTS=6
+CONFIG_SERIAL_8250_EXTENDED=y
+CONFIG_SERIAL_8250_SHARE_IRQ=y
+# CONFIG_SERIAL_8250_DETECT_IRQ is not set
+# CONFIG_SERIAL_8250_MULTIPORT is not set
+# CONFIG_SERIAL_8250_RSA is not set
 
 #
 # Non-8250 serial port support
@@ -846,7 +862,7 @@
 # CONFIG_SND_ES1938 is not set
 # CONFIG_SND_ES1968 is not set
 # CONFIG_SND_MAESTRO3 is not set
-# CONFIG_SND_FM801 is not set
+CONFIG_SND_FM801=m
 # CONFIG_SND_ICE1712 is not set
 # CONFIG_SND_ICE1724 is not set
 # CONFIG_SND_INTEL8X0 is not set
@@ -892,7 +908,16 @@
 # CONFIG_USB_MIDI is not set
 # CONFIG_USB_ACM is not set
 # CONFIG_USB_PRINTER is not set
-# CONFIG_USB_STORAGE is not set
+CONFIG_USB_STORAGE=m
+# CONFIG_USB_STORAGE_DEBUG is not set
+# CONFIG_USB_STORAGE_DATAFAB is not set
+# CONFIG_USB_STORAGE_FREECOM is not set
+# CONFIG_USB_STORAGE_ISD200 is not set
+# CONFIG_USB_STORAGE_DPCM is not set
+# CONFIG_USB_STORAGE_HP8200e is not set
+# CONFIG_USB_STORAGE_SDDR09 is not set
+# CONFIG_USB_STORAGE_SDDR55 is not set
+# CONFIG_USB_STORAGE_JUMPSHOT is not set
 
 #
 # USB Human Interface Devices (HID)


