From: Matthew Wilcox <willy@debian.org>
Date: Thu, 11 Mar 2004 21:16:29 +0000
Subject: [PATCH] drivers/Kconfig
Message-Id: <20040311211629.GN2148@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Convert ia64 to use the generic drivers/Kconfig mechanism.

Index: arch/ia64/Kconfig
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/Kconfig,v
retrieving revision 1.10
diff -u -p -r1.10 Kconfig
--- a/arch/ia64/Kconfig	10 Mar 2004 02:27:21 -0000	1.10
+++ b/arch/ia64/Kconfig	11 Mar 2004 20:58:54 -0000
@@ -416,92 +416,13 @@ source "drivers/pci/hotplug/Kconfig"
 
 source "drivers/pcmcia/Kconfig"
 
-source "drivers/parport/Kconfig"
-
 endif
 
 endmenu
 
-source "drivers/base/Kconfig"
-
-if !IA64_HP_SIM
-
-source "drivers/mtd/Kconfig"
-
-source "drivers/pnp/Kconfig"
-
-source "drivers/block/Kconfig"
-
-source "drivers/ide/Kconfig"
-
-source "drivers/ieee1394/Kconfig"
-
-source "drivers/message/i2o/Kconfig"
-
-source "drivers/md/Kconfig"
-
-source "drivers/message/fusion/Kconfig"
-
-endif
-
-
-source "drivers/scsi/Kconfig"
-
-source "net/Kconfig"
-
-
-if !IA64_HP_SIM
-
-source "drivers/isdn/Kconfig"
-
-source "drivers/cdrom/Kconfig"
-
-#
-# input before char - char/joystick depends on it. As does USB.
-#
-source "drivers/input/Kconfig"
-
-source "drivers/char/Kconfig"
-
-source "drivers/i2c/Kconfig"
-
-#source drivers/misc/Config.in
-source "drivers/media/Kconfig"
-
-endif
-
-
-menu "Block devices"
-	depends on IA64_HP_SIM
-
-config BLK_DEV_LOOP
-	tristate "Loopback device support"
-
-config BLK_DEV_NBD
-	tristate "Network block device support"
-	depends on NET
-
-config BLK_DEV_RAM
-	tristate "RAM disk support"
-
-config BLK_DEV_RAM_SIZE
-	int "Default RAM disk size"
-	depends on BLK_DEV_RAM
-	default "4096"
-
-endmenu
+source "drivers/Kconfig"
 
 source "fs/Kconfig"
-
-if !IA64_HP_SIM
-
-source "drivers/video/Kconfig"
-
-source "sound/Kconfig"
-
-source "drivers/usb/Kconfig"
-
-endif
 
 source "lib/Kconfig"
 

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
