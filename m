From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 23 Jul 2002 03:09:24 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.18)
Message-Id: <marc-linux-ia64-105590701905811@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 22 Jul 2002 11:05:50 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>It goes back to the more drastic solution of turning off "xconfig"
>alltogether (it tells you to use "menuconfig" instead).  I don't care
>about "xconfig" myself, but of course will welcome patches that fix
>the problems for real.

Memo to self: xconfig is a can of worms, try to avoid working on it.

The current configuration mini-language (CML1) has lots of hidden
restrictions.  One of them is that you cannot reliably select a
variable in two different menus.  arch/ia64/config.in is breaking this
rule in several places, some of which work, others do not.  This patch -

* Indents arch/ia64/config.in so I can see what is dependent on HP_SIM.
  The bulk of the patch is indent changes, if this is a problem I can
  do another patch without the indent changes, but the result is much
  less readable.

* Moves force setting of DEVFS for SN[12] to fs/Config.in.

* Removes dependency on CONFIG_DRM_AGP.  That variable does not exist
  and breaks xconfig for ia64.  This is a generic 2.4.18/2.4.19-rc bug
  and has been sent to Marcelo.

* Removes the attempt to set BLOCK variables from arch/ia64/config.in
  and adds the dependency on HP_SIM to drivers/block/Config.in.  This
  is the only method that stands any chance of working for xconfig.
  ACPI is already done this way for the same reason, the arch
  dependencies are inside the ACPI menu, not in the arch menu.

* Moves force settings of ACPI variables based on HP_SIM to _after_
  HP_SIM is actually defined.  General config bug, not xconfig specific.


Index: 18.102/fs/Config.in
--- 18.102/fs/Config.in Wed, 23 Jan 2002 08:52:06 +1100 kaos (linux-2.4/m/b/39_Config.in 1.2.1.2.1.8 644)
+++ 18.102(w)/fs/Config.in Tue, 23 Jul 2002 12:39:57 +1000 kaos (linux-2.4/m/b/39_Config.in 1.2.1.2.1.8 644)
@@ -61,7 +61,11 @@ tristate 'OS/2 HPFS file system support'
 
 bool '/proc file system support' CONFIG_PROC_FS
 
-dep_bool '/dev file system support (EXPERIMENTAL)' CONFIG_DEVFS_FS $CONFIG_EXPERIMENTAL
+if [ "$CONFIG_IA64_SGI_SN1" = "y" -o "$CONFIG_IA64_SGI_SN2" = "y" ]; then
+   dep_bool '/dev file system support (EXPERIMENTAL)' CONFIG_DEVFS_FS $CONFIG_EXPERIMENTAL
+else
+   define_bool CONFIG_DEVFS_FS y
+fi
 dep_bool '  Automatically mount at boot' CONFIG_DEVFS_MOUNT $CONFIG_DEVFS_FS
 dep_bool '  Debug devfs' CONFIG_DEVFS_DEBUG $CONFIG_DEVFS_FS
 
Index: 18.102/drivers/char/Config.in
--- 18.102/drivers/char/Config.in Mon, 22 Jul 2002 11:29:07 +1000 kaos (linux-2.4/b/c/3_Config.in 1.2.1.1.4.12.1.2 644)
+++ 18.102(w)/drivers/char/Config.in Tue, 23 Jul 2002 12:31:28 +1000 kaos (linux-2.4/b/c/3_Config.in 1.2.1.1.4.12.1.2 644)
@@ -211,7 +211,7 @@ if [ "$CONFIG_FTAPE" != "n" ]; then
 fi
 endmenu
 
-dep_tristate '/dev/agpgart (AGP Support)' CONFIG_AGP $CONFIG_DRM_AGP
+tristate '/dev/agpgart (AGP Support)' CONFIG_AGP
 if [ "$CONFIG_AGP" != "n" ]; then
    bool '  Intel 440LX/BX/GX and I815/I830M/I840/I850 support' CONFIG_AGP_INTEL
    if [ "$CONFIG_IA64" != "n" ]; then
Index: 18.102/drivers/block/Config.in
--- 18.102/drivers/block/Config.in Mon, 17 Sep 2001 11:13:57 +1000 kaos (linux-2.4/c/c/37_Config.in 1.2.2.1 644)
+++ 18.102(w)/drivers/block/Config.in Tue, 23 Jul 2002 13:05:00 +1000 kaos (linux-2.4/c/c/37_Config.in 1.2.2.1 644)
@@ -4,6 +4,8 @@
 mainmenu_option next_comment
 comment 'Block devices'
 
+if [ "$CONFIG_IA64_HP_SIM" != "y" ]; then
+
 tristate 'Normal PC floppy disk support' CONFIG_BLK_DEV_FD
 if [ "$CONFIG_AMIGA" = "y" ]; then
    tristate 'Amiga floppy support' CONFIG_AMIGA_FLOPPY
@@ -36,6 +38,7 @@ fi
 dep_tristate 'Compaq SMART2 support' CONFIG_BLK_CPQ_DA $CONFIG_PCI
 dep_tristate 'Compaq Smart Array 5xxx support' CONFIG_BLK_CPQ_CISS_DA $CONFIG_PCI 
 dep_tristate 'Mylex DAC960/DAC1100 PCI RAID Controller support' CONFIG_BLK_DEV_DAC960 $CONFIG_PCI
+fi # HP_SIM
 
 tristate 'Loopback device support' CONFIG_BLK_DEV_LOOP
 dep_tristate 'Network block device support' CONFIG_BLK_DEV_NBD $CONFIG_NET
Index: 18.102/arch/ia64/config.in
--- 18.102/arch/ia64/config.in Mon, 22 Jul 2002 11:29:07 +1000 kaos (linux-2.4/s/c/38_config.in 1.1.2.1.2.2.3.1.1.6.1.1 644)
+++ 18.102(w)/arch/ia64/config.in Tue, 23 Jul 2002 13:01:43 +1000 kaos (linux-2.4/s/c/38_config.in 1.1.2.1.2.2.3.1.1.6.1.1 644)
@@ -26,13 +26,6 @@ define_bool CONFIG_SBUS n
 define_bool CONFIG_RWSEM_GENERIC_SPINLOCK y
 define_bool CONFIG_RWSEM_XCHGADD_ALGORITHM n
 
-if [ "$CONFIG_IA64_HP_SIM" = "n" ]; then
-  define_bool CONFIG_ACPI y
-  define_bool CONFIG_ACPI_EFI y
-  define_bool CONFIG_ACPI_INTERPRETER y
-  define_bool CONFIG_ACPI_KERNEL_CONFIG y
-fi
-
 choice 'IA-64 processor type' \
 	"Itanium		CONFIG_ITANIUM \
 	 Itanium-2		CONFIG_MCKINLEY" Itanium
@@ -89,10 +82,6 @@ if [ "$CONFIG_IA64_SGI_SN1" = "y" -o "$C
 	bool '  Enable SGI Medusa Simulator Support' CONFIG_IA64_SGI_SN_SIM
 	bool '  Enable autotest (llsc). Option to run cache test instead of booting' \
 			CONFIG_IA64_SGI_AUTOTEST n
-	define_bool CONFIG_DEVFS_FS y
-	if [ "$CONFIG_DEVFS_FS" = "y" ]; then
-	  bool '    Enable DEVFS Debug Code' CONFIG_DEVFS_DEBUG n
-	fi
 	bool '  Enable protocol mode for the L1 console' CONFIG_SERIAL_SGI_L1_PROTOCOL y
 	define_bool CONFIG_DISCONTIGMEM y
 	define_bool CONFIG_IA64_MCA y
@@ -117,22 +106,26 @@ tristate 'Kernel support for ELF binarie
 tristate 'Kernel support for MISC binaries' CONFIG_BINFMT_MISC
 
 if [ "$CONFIG_IA64_HP_SIM" = "n" ]; then
+   source drivers/acpi/Config.in
 
-source drivers/acpi/Config.in
-
-bool 'PCI support' CONFIG_PCI
-source drivers/pci/Config.in
-
-bool 'Support for hot-pluggable devices' CONFIG_HOTPLUG
-if [ "$CONFIG_HOTPLUG" = "y" ]; then
-   source drivers/hotplug/Config.in
-   source drivers/pcmcia/Config.in
-else
-   define_bool CONFIG_PCMCIA n
-fi
-
-source drivers/parport/Config.in
+   bool 'PCI support' CONFIG_PCI
+   source drivers/pci/Config.in
 
+   bool 'Support for hot-pluggable devices' CONFIG_HOTPLUG
+   if [ "$CONFIG_HOTPLUG" = "y" ]; then
+      source drivers/hotplug/Config.in
+      source drivers/pcmcia/Config.in
+   else
+      define_bool CONFIG_PCMCIA n
+   fi
+
+   source drivers/parport/Config.in
+
+else # !HP_SIM
+   define_bool CONFIG_ACPI y
+   define_bool CONFIG_ACPI_EFI y
+   define_bool CONFIG_ACPI_INTERPRETER y
+   define_bool CONFIG_ACPI_KERNEL_CONFIG y
 fi # !HP_SIM
 
 endmenu
@@ -142,43 +135,30 @@ if [ "$CONFIG_NET" = "y" ]; then
 fi
 
 if [ "$CONFIG_IA64_HP_SIM" = "n" ]; then
+   source drivers/mtd/Config.in
+   source drivers/pnp/Config.in
+fi # !HP_SIM
 
-define_tristate CONFIG_BLK_DEV_LOOP n
-define_tristate CONFIG_BLK_DEV_NBD n
-define_tristate CONFIG_BLK_DEV_RAM n
-
-source drivers/mtd/Config.in
-source drivers/pnp/Config.in
 source drivers/block/Config.in
-source drivers/ieee1394/Config.in
-source drivers/message/i2o/Config.in
-source drivers/md/Config.in
-source drivers/message/fusion/Config.in
 
-mainmenu_option next_comment
-comment 'ATA/IDE/MFM/RLL support'
-
-tristate 'ATA/IDE/MFM/RLL support' CONFIG_IDE
-
-if [ "$CONFIG_IDE" != "n" ]; then
-  source drivers/ide/Config.in
-else
-  define_bool CONFIG_BLK_DEV_IDE_MODES n
-  define_bool CONFIG_BLK_DEV_HD n
-fi
-endmenu
-
-else # ! HP_SIM
-mainmenu_option next_comment
-comment 'Block devices'
-tristate 'Loopback device support' CONFIG_BLK_DEV_LOOP
-dep_tristate 'Network block device support' CONFIG_BLK_DEV_NBD $CONFIG_NET
-
-tristate 'RAM disk support' CONFIG_BLK_DEV_RAM
-if [ "$CONFIG_BLK_DEV_RAM" = "y" -o "$CONFIG_BLK_DEV_RAM" = "m" ]; then
-   int '  Default RAM disk size' CONFIG_BLK_DEV_RAM_SIZE 4096
-fi
-endmenu
+if [ "$CONFIG_IA64_HP_SIM" = "n" ]; then
+   source drivers/ieee1394/Config.in
+   source drivers/message/i2o/Config.in
+   source drivers/md/Config.in
+   source drivers/message/fusion/Config.in
+
+   mainmenu_option next_comment
+   comment 'ATA/IDE/MFM/RLL support'
+
+   tristate 'ATA/IDE/MFM/RLL support' CONFIG_IDE
+
+   if [ "$CONFIG_IDE" != "n" ]; then
+     source drivers/ide/Config.in
+   else
+     define_bool CONFIG_BLK_DEV_IDE_MODES n
+     define_bool CONFIG_BLK_DEV_HD n
+   fi
+   endmenu
 fi # !HP_SIM
 
 mainmenu_option next_comment
@@ -193,36 +173,36 @@ endmenu
 
 if [ "$CONFIG_IA64_HP_SIM" = "n" ]; then
 
-if [ "$CONFIG_NET" = "y" ]; then
-  mainmenu_option next_comment
-  comment 'Network device support'
-
-  bool 'Network device support' CONFIG_NETDEVICES
-  if [ "$CONFIG_NETDEVICES" = "y" ]; then
-    source drivers/net/Config.in
-  fi
-  endmenu
-fi
-
-source net/ax25/Config.in
-
-mainmenu_option next_comment
-comment 'ISDN subsystem'
-
-tristate 'ISDN support' CONFIG_ISDN
-if [ "$CONFIG_ISDN" != "n" ]; then
-  source drivers/isdn/Config.in
-fi
-endmenu
-
-mainmenu_option next_comment
-comment 'CD-ROM drivers (not for SCSI or IDE/ATAPI drives)'
-
-bool 'Support non-SCSI/IDE/ATAPI drives' CONFIG_CD_NO_IDESCSI
-if [ "$CONFIG_CD_NO_IDESCSI" != "n" ]; then
-  source drivers/cdrom/Config.in
-fi
-endmenu
+   if [ "$CONFIG_NET" = "y" ]; then
+     mainmenu_option next_comment
+     comment 'Network device support'
+
+     bool 'Network device support' CONFIG_NETDEVICES
+     if [ "$CONFIG_NETDEVICES" = "y" ]; then
+       source drivers/net/Config.in
+     fi
+     endmenu
+   fi
+
+   source net/ax25/Config.in
+
+   mainmenu_option next_comment
+   comment 'ISDN subsystem'
+
+   tristate 'ISDN support' CONFIG_ISDN
+   if [ "$CONFIG_ISDN" != "n" ]; then
+     source drivers/isdn/Config.in
+   fi
+   endmenu
+
+   mainmenu_option next_comment
+   comment 'CD-ROM drivers (not for SCSI or IDE/ATAPI drives)'
+
+   bool 'Support non-SCSI/IDE/ATAPI drives' CONFIG_CD_NO_IDESCSI
+   if [ "$CONFIG_CD_NO_IDESCSI" != "n" ]; then
+     source drivers/cdrom/Config.in
+   fi
+   endmenu
 
 fi # !HP_SIM
 
@@ -251,20 +231,20 @@ fi
 
 if [ "$CONFIG_IA64_HP_SIM" = "n" ]; then
 
-mainmenu_option next_comment
-comment 'Sound'
+   mainmenu_option next_comment
+   comment 'Sound'
 
-tristate 'Sound card support' CONFIG_SOUND
-if [ "$CONFIG_SOUND" != "n" ]; then
-  source drivers/sound/Config.in
-fi
-endmenu
-
-source drivers/usb/Config.in
-
-if [ "$CONFIG_EXPERIMENTAL" = "y" ]; then
-   source net/bluetooth/Config.in
-fi
+   tristate 'Sound card support' CONFIG_SOUND
+   if [ "$CONFIG_SOUND" != "n" ]; then
+     source drivers/sound/Config.in
+   fi
+   endmenu
+
+   source drivers/usb/Config.in
+
+   if [ "$CONFIG_EXPERIMENTAL" = "y" ]; then
+      source net/bluetooth/Config.in
+   fi
 
 fi # !HP_SIM
 


