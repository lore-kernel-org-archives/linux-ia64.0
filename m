From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 10 Aug 2002 08:58:14 +0000
Subject: [Linux-ia64] test patch relative to 2.5.30
Message-Id: <marc-linux-ia64-105590701905931@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Below is a quick patch for 2.5.30.  Warning: it has been tested only
lightly.  It worked for me on a Big Sur in UP mode.  I think MP is
broken at the moment.  My focus was to try to get the AGP/DRM code
into shape so we can have it merged into 2.5.  The primary reason I
tought it would be good to make this barely tested patch available is
because 2.5.29 likes to eat filesystems on IDE disks (it ate the
rootfs on one of my machines and subtly corrupted a couple of files on
another machine...).  With 2.5.30, I haven't seen any file corruption
so far, but your mileage obviously may vary.

	--david

diff -Nru a/Documentation/mmio_barrier.txt b/Documentation/mmio_barrier.txt
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/Documentation/mmio_barrier.txt	Sat Aug 10 01:51:47 2002
@@ -0,0 +1,15 @@
+On some platforms, so-called memory-mapped I/O is weakly ordered.  For
+example, the following might occur:
+
+CPU A writes 0x1 to Device #1
+CPU B writes 0x2 to Device #1
+Device #1 sees 0x2
+Device #1 sees 0x1
+
+On such platforms, driver writers are responsible for ensuring that I/O
+writes to memory-mapped addresses on their device arrive in the order
+intended.  The mmiob() macro is provided for this purpose.  A typical use
+of this macro might be immediately prior to the exit of a critical
+section of code proteced by spinlocks.  This would ensure that subsequent
+writes to I/O space arrived only after all prior writes (much like a
+typical memory barrier op, mb(), only with respect to I/O).
diff -Nru a/Makefile b/Makefile
--- a/Makefile	Sat Aug 10 01:51:46 2002
+++ b/Makefile	Sat Aug 10 01:51:46 2002
@@ -221,7 +221,7 @@
=20
 CPPFLAGS :=3D -D__KERNEL__ -I$(HPATH)
=20
-CFLAGS :=3D $(CPPFLAGS) -Wall -Wstrict-prototypes -Wno-trigraphs -O2 \
+CFLAGS :=3D $(CPPFLAGS) -Wall -Wstrict-prototypes -Wno-trigraphs -g -O2 \
 	  -fomit-frame-pointer -fno-strict-aliasing -fno-common
 AFLAGS :=3D -D__ASSEMBLY__ $(CPPFLAGS)
=20
diff -Nru a/arch/i386/mm/fault.c b/arch/i386/mm/fault.c
--- a/arch/i386/mm/fault.c	Sat Aug 10 01:51:46 2002
+++ b/arch/i386/mm/fault.c	Sat Aug 10 01:51:46 2002
@@ -28,8 +28,6 @@
=20
 extern void die(const char *,struct pt_regs *,long);
=20
-extern int console_loglevel;
-
 /*
  * Ugly, ugly, but the goto's result in better assembly..
  */
diff -Nru a/arch/ia64/Makefile b/arch/ia64/Makefile
--- a/arch/ia64/Makefile	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/Makefile	Sat Aug 10 01:51:46 2002
@@ -13,7 +13,7 @@
=20
 export AWK
=20
-OBJCOPYFLAGS :=3D --strip-all=20
+OBJCOPYFLAGS :=3D --strip-all
 LDFLAGS_vmlinux :=3D -static -T arch/$(ARCH)/vmlinux.lds
 AFLAGS_KERNEL :=3D -mconstant-gp
 EXTRA	@@ -26,7 +26,7 @@
 GCC_VERSION=3D$(shell $(CC) -v 2>&1 | fgrep 'gcc version' | cut -f3 -d' ' =
| cut -f1 -d'.')
=20
 ifneq ($(GCC_VERSION),2)
-	CFLAGS +=3D -frename-registers --param max-inline-insns 00
+	CFLAGS +=3D -frename-registers --param max-inline-insnsP00
 endif
=20
 ifeq ($(CONFIG_ITANIUM_BSTEP_SPECIFIC),y)
diff -Nru a/arch/ia64/boot/Makefile b/arch/ia64/boot/Makefile
--- a/arch/ia64/boot/Makefile	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/boot/Makefile	Sat Aug 10 01:51:46 2002
@@ -12,8 +12,10 @@
=20
 OBJECTS	=3D bootloader.o
=20
-targets-$(CONFIG_IA64_HP_SIM) +=3D bootloader
-targets-$(CONFIG_IA64_GENERIC) +=3D bootloader
+targets-$(CONFIG_IA64_HP_SIM)	+=3D bootloader
+targets-$(CONFIG_IA64_GENERIC)	+=3D bootloader
+
+CFLAGS	:=3D $(CFLAGS) $(CFLAGS_KERNEL)
=20
 all:	$(targets-y)
=20
diff -Nru a/arch/ia64/config.in b/arch/ia64/config.in
--- a/arch/ia64/config.in	Sat Aug 10 01:51:47 2002
+++ b/arch/ia64/config.in	Sat Aug 10 01:51:47 2002
@@ -64,12 +64,13 @@
 	fi
 fi
=20
-if [ "$CONFIG_IA64_GENERIC" =3D "y" -o  "$CONFIG_IA64_DIG" =3D "y" -o "$CO=
NFIG_IA64_HP_ZX1" =3D "y" ]; then
+if [ "$CONFIG_IA64_GENERIC" =3D "y" -o "$CONFIG_IA64_DIG" =3D "y" -o "$CON=
FIG_IA64_HP_ZX1" =3D "y" ];
+then
 	bool '  Enable IA-64 Machine Check Abort' CONFIG_IA64_MCA
 	define_bool CONFIG_PM y
 fi
=20
-if [ "$CONFIG_IA64_SGI_SN1" =3D "y" -o  "$CONFIG_IA64_SGI_SN2" =3D "y" ]; =
then
+if [ "$CONFIG_IA64_SGI_SN1" =3D "y" -o "$CONFIG_IA64_SGI_SN2" =3D "y" ]; t=
hen
 	define_bool CONFIG_IA64_SGI_SN y
 	bool '  Enable extra debugging code' CONFIG_IA64_SGI_SN_DEBUG
 	bool '  Enable SGI Medusa Simulator Support' CONFIG_IA64_SGI_SN_SIM
@@ -99,21 +100,20 @@
 tristate 'Kernel support for MISC binaries' CONFIG_BINFMT_MISC
=20
 if [ "$CONFIG_IA64_HP_SIM" =3D "n" ]; then
+  source drivers/acpi/Config.in
=20
-source drivers/acpi/Config.in
+  bool 'PCI support' CONFIG_PCI
+  source drivers/pci/Config.in
=20
-bool 'PCI support' CONFIG_PCI
-source drivers/pci/Config.in
-
-bool 'Support for hot-pluggable devices' CONFIG_HOTPLUG
-if [ "$CONFIG_HOTPLUG" =3D "y" ]; then
-   source drivers/pcmcia/Config.in
-else
-   define_bool CONFIG_PCMCIA n
-fi
-
-source drivers/parport/Config.in
+  bool 'Support for hot-pluggable devices' CONFIG_HOTPLUG
+  if [ "$CONFIG_HOTPLUG" =3D "y" ]; then
+     source drivers/hotplug/Config.in
+     source drivers/pcmcia/Config.in
+  else
+     define_bool CONFIG_PCMCIA n
+  fi
=20
+  source drivers/parport/Config.in
 fi # !HP_SIM
=20
 endmenu
@@ -123,39 +123,26 @@
 fi
=20
 if [ "$CONFIG_IA64_HP_SIM" =3D "n" ]; then
+  source drivers/mtd/Config.in
+  source drivers/pnp/Config.in
+  source drivers/block/Config.in
+  source drivers/ieee1394/Config.in
+  source drivers/message/i2o/Config.in
+  source drivers/md/Config.in
+  source drivers/message/fusion/Config.in
=20
-source drivers/mtd/Config.in
-source drivers/pnp/Config.in
-source drivers/block/Config.in
-source drivers/ieee1394/Config.in
-source drivers/message/i2o/Config.in
-source drivers/md/Config.in
-source drivers/message/fusion/Config.in
-
-mainmenu_option next_comment
-comment 'ATA/ATAPI/MFM/RLL support'
+  mainmenu_option next_comment
+  comment 'ATA/ATAPI/MFM/RLL support'
=20
-tristate 'ATA/ATAPI/MFM/RLL support' CONFIG_IDE
+  tristate 'ATA/ATAPI/MFM/RLL support' CONFIG_IDE
=20
-if [ "$CONFIG_IDE" !=3D "n" ]; then
-  source drivers/ide/Config.in
-else
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
-if [ "$CONFIG_BLK_DEV_RAM" =3D "y" -o "$CONFIG_BLK_DEV_RAM" =3D "m" ]; then
-   int '  Default RAM disk size' CONFIG_BLK_DEV_RAM_SIZE 4096
+  if [ "$CONFIG_IDE" !=3D "n" ]; then
+    source drivers/ide/Config.in
+  else
+    define_bool CONFIG_BLK_DEV_HD n
+  fi
+  endmenu
 fi
-endmenu
-fi # !HP_SIM
=20
 mainmenu_option next_comment
 comment 'SCSI support'
@@ -168,80 +155,83 @@
 endmenu
=20
 if [ "$CONFIG_IA64_HP_SIM" =3D "n" ]; then
+  if [ "$CONFIG_NET" =3D "y" ]; then
+    mainmenu_option next_comment
+    comment 'Network device support'
+
+    bool 'Network device support' CONFIG_NETDEVICES
+    if [ "$CONFIG_NETDEVICES" =3D "y" ]; then
+      source drivers/net/Config.in
+    fi
+    endmenu
+  fi
+  source net/ax25/Config.in
+  source drivers/isdn/Config.in
=20
-if [ "$CONFIG_NET" =3D "y" ]; then
   mainmenu_option next_comment
-  comment 'Network device support'
+  comment 'CD-ROM drivers (not for SCSI or IDE/ATAPI drives)'
=20
-  bool 'Network device support' CONFIG_NETDEVICES
-  if [ "$CONFIG_NETDEVICES" =3D "y" ]; then
-    source drivers/net/Config.in
+  bool 'Support non-SCSI/IDE/ATAPI CDROM drives' CONFIG_CD_NO_IDESCSI
+  if [ "$CONFIG_CD_NO_IDESCSI" !=3D "n" ]; then
+    source drivers/cdrom/Config.in
   fi
   endmenu
-fi
-
-source net/ax25/Config.in
=20
-source drivers/isdn/Config.in
+  #
+  # input before char - char/joystick depends on it. As does USB.
+  #
+  source drivers/input/Config.in
+  source drivers/char/Config.in
=20
-mainmenu_option next_comment
-comment 'CD-ROM drivers (not for SCSI or IDE/ATAPI drives)'
+  #source drivers/misc/Config.in
=20
-bool 'Support non-SCSI/IDE/ATAPI CDROM drives' CONFIG_CD_NO_IDESCSI
-if [ "$CONFIG_CD_NO_IDESCSI" !=3D "n" ]; then
-  source drivers/cdrom/Config.in
-fi
-endmenu
+  source drivers/media/Config.in
+else # HP_SIM
=20
-fi # !HP_SIM
-
-#
-# input before char - char/joystick depends on it. As does USB.
-#
-source drivers/input/Config.in
-source drivers/char/Config.in
-
-#source drivers/misc/Config.in
-
-source drivers/media/Config.in
-
-source fs/Config.in
-
-if [ "$CONFIG_VT" =3D "y" ]; then
   mainmenu_option next_comment
-  comment 'Console drivers'
-  bool 'VGA text console' CONFIG_VGA_CONSOLE
-  source drivers/video/Config.in
-  if [ "$CONFIG_FB" =3D "y" ]; then
-    define_bool CONFIG_PCI_CONSOLE y
+  comment 'Block devices'
+  tristate 'Loopback device support' CONFIG_BLK_DEV_LOOP
+  dep_tristate 'Network block device support' CONFIG_BLK_DEV_NBD $CONFIG_N=
ET
+
+  tristate 'RAM disk support' CONFIG_BLK_DEV_RAM
+  if [ "$CONFIG_BLK_DEV_RAM" =3D "y" -o "$CONFIG_BLK_DEV_RAM" =3D "m" ]; t=
hen
+    int '  Default RAM disk size' CONFIG_BLK_DEV_RAM_SIZE 4096
   fi
   endmenu
-fi
+fi # HP_SIM
=20
-if [ "$CONFIG_IA64_HP_SIM" =3D "n" ]; then
-
-mainmenu_option next_comment
-comment 'Sound'
-
-tristate 'Sound card support' CONFIG_SOUND
-if [ "$CONFIG_SOUND" !=3D "n" ]; then
-  source sound/Config.in
-fi
-endmenu
+source fs/Config.in
=20
-source drivers/usb/Config.in
+if [ "$CONFIG_IA64_HP_SIM" =3D "n" ]; then
+  if [ "$CONFIG_VT" =3D "y" ]; then
+    mainmenu_option next_comment
+    comment 'Console drivers'
+    bool 'VGA text console' CONFIG_VGA_CONSOLE
+    source drivers/video/Config.in
+    if [ "$CONFIG_FB" =3D "y" ]; then
+      define_bool CONFIG_PCI_CONSOLE y
+    fi
+    endmenu
+  fi
=20
-source lib/Config.in
+  mainmenu_option next_comment
+  comment 'Sound'
=20
-source net/bluetooth/Config.in
+  tristate 'Sound card support' CONFIG_SOUND
+  if [ "$CONFIG_SOUND" !=3D "n" ]; then
+    source sound/Config.in
+  fi
+  endmenu
=20
+  source drivers/usb/Config.in
+  source lib/Config.in
+  source net/bluetooth/Config.in
 fi # !HP_SIM
=20
 if [ "$CONFIG_IA64_HP_SIM" !=3D "n" -o "$CONFIG_IA64_GENERIC" !=3D "n" ]; =
then
-  source arch/ia64/hp/Config.in
+  source arch/ia64/hp/sim/Config.in
 fi
=20
-
 mainmenu_option next_comment
 comment 'Kernel hacking'
=20
@@ -255,7 +245,14 @@
    bool '  Disable VHPT' CONFIG_DISABLE_VHPT
    bool '  Magic SysRq key' CONFIG_MAGIC_SYSRQ
=20
-   bool '  Early printk support (requires VGA!)' CONFIG_IA64_EARLY_PRINTK
+   bool '  Early printk support' CONFIG_IA64_EARLY_PRINTK
+   if [ "$CONFIG_IA64_EARLY_PRINTK" !=3D "n" ]; then
+      bool '    Early printk on MMIO serial port' CONFIG_IA64_EARLY_PRINTK=
_UART
+      if [ "$CONFIG_IA64_EARLY_PRINTK_UART" !=3D "n" ]; then
+         hex '      UART MMIO base address' CONFIG_IA64_EARLY_PRINTK_UART_=
BASE ff5e0000
+      fi
+      bool '    Early printk on VGA' CONFIG_IA64_EARLY_PRINTK_VGA
+   fi
    bool '  Debug memory allocations' CONFIG_DEBUG_SLAB
    bool '  Spinlock debugging' CONFIG_DEBUG_SPINLOCK
    bool '  Turn on compare-and-exchange bug checking (slow!)' CONFIG_IA64_=
DEBUG_CMPXCHG
diff -Nru a/arch/ia64/hp/Config.in b/arch/ia64/hp/Config.in
--- a/arch/ia64/hp/Config.in	Sat Aug 10 01:51:46 2002
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,9 +0,0 @@
-mainmenu_option next_comment
-comment 'HP Simulator drivers'
-
-bool 'Simulated Ethernet ' CONFIG_HP_SIMETH
-bool 'Simulated serial driver support' CONFIG_HP_SIMSERIAL
-if [ "$CONFIG_SCSI" !=3D "n" ]; then
-  bool 'Simulated SCSI disk' CONFIG_HP_SIMSCSI
-fi
-endmenu
diff -Nru a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu=
.c
--- a/arch/ia64/hp/common/sba_iommu.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/hp/common/sba_iommu.c	Sat Aug 10 01:51:46 2002
@@ -2,6 +2,7 @@
 **  IA64 System Bus Adapter (SBA) I/O MMU manager
 **
 **	(c) Copyright 2002 Alex Williamson
+**	(c) Copyright 2002 Grant Grundler
 **	(c) Copyright 2002 Hewlett-Packard Company
 **
 **	Portions (c) 2000 Grant Grundler (from parisc I/O MMU code)
@@ -110,7 +111,7 @@
 */
 #define DELAYED_RESOURCE_CNT	16
=20
-#define DEFAULT_DMA_HINT_REG	0
+#define DEFAULT_DMA_HINT_REG(d)	0
=20
 #define ZX1_FUNC_ID_VALUE    ((PCI_DEVICE_ID_HP_ZX1_SBA << 16) | PCI_VENDO=
R_ID_HP)
 #define ZX1_MC_ID    ((PCI_DEVICE_ID_HP_ZX1_MC << 16) | PCI_VENDOR_ID_HP)
@@ -216,9 +217,10 @@
 static int reserve_sba_gart =3D 1;
 static struct pci_dev sac_only_dev;
=20
-#define sba_sg_iova(sg) (sg->address)
+#define sba_sg_address(sg) (page_address((sg)->page) + (sg)->offset)
 #define sba_sg_len(sg) (sg->length)
-#define sba_sg_buffer(sg) (sg->orig_address)
+#define sba_sg_iova(sg) (sg->dma_address)
+#define sba_sg_iova_len(sg) (sg->dma_length)
=20
 /* REVISIT - fix me for multiple SBAs/IOCs */
 #define GET_IOC(dev) (sba_list->ioc)
@@ -232,7 +234,7 @@
 ** rather than the HW. I/O MMU allocation alogorithms can be
 ** faster with smaller size is (to some degree).
 */
-#define DMA_CHUNK_SIZE  (BITS_PER_LONG*PAGE_SIZE)
+#define DMA_CHUNK_SIZE  (BITS_PER_LONG*IOVP_SIZE)
=20
 /* Looks nice and keeps the compiler happy */
 #define SBA_DEV(d) ((struct sba_device *) (d))
@@ -255,7 +257,7 @@
  * sba_dump_tlb - debugging only - print IOMMU operating parameters
  * @hpa: base address of the IOMMU
  *
- * Print the size/location of the IO MMU PDIR.
+ * Print the size/location of the IO MMU Pdir.
  */
 static void
 sba_dump_tlb(char *hpa)
@@ -273,12 +275,12 @@
 #ifdef ASSERT_PDIR_SANITY
=20
 /**
- * sba_dump_pdir_entry - debugging only - print one IOMMU PDIR entry
+ * sba_dump_pdir_entry - debugging only - print one IOMMU Pdir entry
  * @ioc: IO MMU structure which owns the pdir we are interested in.
  * @msg: text to print ont the output line.
  * @pide: pdir index.
  *
- * Print one entry of the IO MMU PDIR in human readable form.
+ * Print one entry of the IO MMU Pdir in human readable form.
  */
 static void
 sba_dump_pdir_entry(struct ioc *ioc, char *msg, uint pide)
@@ -360,25 +362,25 @@
  * print the SG list so we can verify it's correct by hand.
  */
 static void
-sba_dump_sg( struct ioc *ioc, struct scatterlist *startsg, int nents)
+sba_dump_sg(struct ioc *ioc, struct scatterlist *startsg, int nents)
 {
 	while (nents-- > 0) {
-		printk(" %d : %08lx/%05x %p\n",
+		printk(" %d : DMA %08lx/%05x CPU %p\n",
 				nents,
 				(unsigned long) sba_sg_iova(startsg),
-				sba_sg_len(startsg),
-				sba_sg_buffer(startsg));
+				sba_sg_iova_len(startsg),
+				sba_sg_address(startsg));
 		startsg++;
 	}
 }
 static void
-sba_check_sg( struct ioc *ioc, struct scatterlist *startsg, int nents)
+sba_check_sg(struct ioc *ioc, struct scatterlist *startsg, int nents)
 {
 	struct scatterlist *the_sg =3D startsg;
 	int the_nents =3D nents;
=20
 	while (the_nents-- > 0) {
-		if (sba_sg_buffer(the_sg) =3D 0x0UL)
+		if (sba_sg_address(the_sg) =3D 0x0UL)
 			sba_dump_sg(NULL, startsg, nents);
 		the_sg++;
 	}
@@ -404,7 +406,6 @@
 #define SBA_IOVA(ioc,iovp,offset,hint_reg) ((ioc->ibase) | (iovp) | (offse=
t) | ((hint_reg)<<(ioc->hint_shift_pdir)))
 #define SBA_IOVP(ioc,iova) (((iova) & ioc->hint_mask_pdir) & ~(ioc->ibase))
=20
-/* FIXME : review these macros to verify correctness and usage */
 #define PDIR_INDEX(iovp)   ((iovp)>>IOVP_SHIFT)
=20
 #define RESMAP_MASK(n)    ~(~0UL << (n))
@@ -412,7 +413,7 @@
=20
=20
 /**
- * sba_search_bitmap - find free space in IO PDIR resource bitmap
+ * sba_search_bitmap - find free space in IO Pdir resource bitmap
  * @ioc: IO MMU structure which owns the pdir we are interested in.
  * @bits_wanted: number of entries we need.
  *
@@ -449,7 +450,7 @@
 		** We need the alignment to invalidate I/O TLB using
 		** SBA HW features in the unmap path.
 		*/
-		unsigned long o =3D 1 << get_order(bits_wanted << PAGE_SHIFT);
+		unsigned long o =3D 1UL << get_order(bits_wanted << IOVP_SHIFT);
 		uint bitshiftcnt =3D ROUNDUP(ioc->res_bitshift, o);
 		unsigned long mask;
=20
@@ -495,7 +496,7 @@
=20
=20
 /**
- * sba_alloc_range - find free bits and mark them in IO PDIR resource bitm=
ap
+ * sba_alloc_range - find free bits and mark them in IO Pdir resource bitm=
ap
  * @ioc: IO MMU structure which owns the pdir we are interested in.
  * @size: number of bytes to create a mapping for
  *
@@ -557,7 +558,7 @@
=20
=20
 /**
- * sba_free_range - unmark bits in IO PDIR resource bitmap
+ * sba_free_range - unmark bits in IO Pdir resource bitmap
  * @ioc: IO MMU structure which owns the pdir we are interested in.
  * @iova: IO virtual address which was previously allocated.
  * @size: number of bytes to create a mapping for
@@ -604,14 +605,14 @@
=20
=20
 /**
- * sba_io_pdir_entry - fill in one IO PDIR entry
- * @pdir_ptr:  pointer to IO PDIR entry
- * @vba: Virtual CPU address of buffer to map
+ * sba_io_pdir_entry - fill in one IO Pdir entry
+ * @pdir_ptr:  pointer to IO Pdir entry
+ * @phys_page: phys CPU address of page to map
  *
  * SBA Mapping Routine
  *
- * Given a virtual address (vba, arg1) sba_io_pdir_entry()
- * loads the I/O PDIR entry pointed to by pdir_ptr (arg0).
+ * Given a physical address (phys_page, arg1) sba_io_pdir_entry()
+ * loads the I/O Pdir entry pointed to by pdir_ptr (arg0).
  * Each IO Pdir entry consists of 8 bytes as shown below
  * (LSB =3D bit 0):
  *
@@ -623,20 +624,12 @@
  *  V  =3D Valid Bit
  *  U  =3D Unused
  * PPN =3D Physical Page Number
- *
- * The physical address fields are filled with the results of virt_to_phys=
()
- * on the vba.
  */
=20
-#if 1
-#define sba_io_pdir_entry(pdir_ptr, vba) *pdir_ptr =3D ((vba & ~0xE0000000=
00000FFFULL) | 0x80000000000000FFULL)
-#else
-void SBA_INLINE
-sba_io_pdir_entry(u64 *pdir_ptr, unsigned long vba)
-{
-	*pdir_ptr =3D ((vba & ~0xE000000000000FFFULL) | 0x80000000000000FFULL);
-}
-#endif
+#define SBA_VALID_MASK	0x80000000000000FFULL
+#define sba_io_pdir_entry(pdir_ptr, phys_page) *pdir_ptr =3D (phys_page | =
SBA_VALID_MASK)
+#define sba_io_page(pdir_ptr) (*pdir_ptr & ~SBA_VALID_MASK)
+
=20
 #ifdef ENABLE_MARK_CLEAN
 /**
@@ -660,12 +653,12 @@
 #endif
=20
 /**
- * sba_mark_invalid - invalidate one or more IO PDIR entries
+ * sba_mark_invalid - invalidate one or more IO Pdir entries
  * @ioc: IO MMU structure which owns the pdir we are interested in.
  * @iova:  IO Virtual Address mapped earlier
  * @byte_cnt:  number of bytes this mapping covers.
  *
- * Marking the IO PDIR entry(ies) as Invalid and invalidate
+ * Marking the IO Pdir entry(ies) as Invalid and invalidate
  * corresponding IO TLB entry. The PCOM (Purge Command Register)
  * is to purge stale entries in the IO TLB when unmapping entries.
  *
@@ -700,14 +693,14 @@
 		iovp |=3D IOVP_SHIFT;     /* set "size" field for PCOM */
=20
 		/*
-		** clear I/O PDIR entry "valid" bit
+		** clear I/O Pdir entry "valid" bit
 		** Do NOT clear the rest - save it for debugging.
 		** We should only clear bits that have previously
 		** been enabled.
 		*/
-		ioc->pdir_base[off] &=3D ~(0x80000000000000FFULL);
+		ioc->pdir_base[off] &=3D ~SBA_VALID_MASK;
 	} else {
-		u32 t =3D get_order(byte_cnt) + PAGE_SHIFT;
+		u32 t =3D get_order(byte_cnt) + IOVP_SHIFT;
=20
 		iovp |=3D t;
 		ASSERT(t <=3D 31);   /* 2GB! Max value of "size" field */
@@ -716,7 +709,7 @@
 			/* verify this pdir entry is enabled */
 			ASSERT(ioc->pdir_base[off]  >> 63);
 			/* clear I/O Pdir entry "valid" bit first */
-			ioc->pdir_base[off] &=3D ~(0x80000000000000FFULL);
+			ioc->pdir_base[off] &=3D ~SBA_VALID_MASK;
 			off++;
 			byte_cnt -=3D IOVP_SIZE;
 		} while (byte_cnt > 0);
@@ -744,7 +737,7 @@
 	u64 *pdir_start;
 	int pide;
 #ifdef ALLOW_IOV_BYPASS
-	unsigned long pci_addr =3D virt_to_phys(addr);
+	unsigned long phys_addr =3D virt_to_phys(addr);
 #endif
=20
 	ioc =3D GET_IOC(dev);
@@ -754,7 +747,7 @@
 	/*
  	** Check if the PCI device can DMA to ptr... if so, just return ptr
  	*/
-	if ((pci_addr & ~dev->dma_mask) =3D 0) {
+	if ((phys_addr & ~dev->dma_mask) =3D 0) {
 		/*
  		** Device is bit capable of DMA'ing to the buffer...
 		** just return the PCI address of ptr
@@ -765,8 +758,8 @@
 		spin_unlock_irqrestore(&ioc->res_lock, flags);
 #endif
 		DBG_BYPASS("sba_map_single() bypass mask/addr: 0x%lx/0x%lx\n",
-		           dev->dma_mask, pci_addr);
-		return pci_addr;
+		           dev->dma_mask, phys_addr);
+		return phys_addr;
 	}
 #endif
=20
@@ -799,7 +792,8 @@
=20
 	while (size > 0) {
 		ASSERT(((u8 *)pdir_start)[7] =3D 0); /* verify availability */
-		sba_io_pdir_entry(pdir_start, (unsigned long) addr);
+
+		sba_io_pdir_entry(pdir_start, virt_to_phys(addr));
=20
 		DBG_RUN("     pdir 0x%p %lx\n", pdir_start, *pdir_start);
=20
@@ -812,7 +806,7 @@
 	sba_check_pdir(ioc,"Check after sba_map_single()");
 #endif
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
-	return SBA_IOVA(ioc, iovp, offset, DEFAULT_DMA_HINT_REG);
+	return SBA_IOVA(ioc, iovp, offset, DEFAULT_DMA_HINT_REG(direction));
 }
=20
 /**
@@ -866,6 +860,29 @@
 	size +=3D offset;
 	size =3D ROUNDUP(size, IOVP_SIZE);
=20
+#ifdef ENABLE_MARK_CLEAN
+	/*
+	** Don't need to hold the spinlock while telling VM pages are "clean".
+	** The pages are "busy" in the resource map until we mark them free.
+	** But tell VM pages are clean *before* releasing the resource
+	** in order to avoid race conditions.
+	*/
+	if (direction =3D PCI_DMA_FROMDEVICE) {
+		u32 iovp =3D (u32) SBA_IOVP(ioc,iova);
+		unsigned int pide =3D PDIR_INDEX(iovp);
+		u64 *pdirp =3D &(ioc->pdir_base[pide]);
+		size_t byte_cnt =3D size;
+		void *addr;
+
+		do {
+			addr =3D phys_to_virt(sba_io_page(pdirp));
+			mark_clean(addr, min(byte_cnt, IOVP_SIZE));
+			pdirp++;
+			byte_cnt -=3D IOVP_SIZE;
+		} while (byte_cnt > 0);
+	}
+#endif
+
 	spin_lock_irqsave(&ioc->res_lock, flags);
 #ifdef CONFIG_PROC_FS
 	ioc->usingle_calls++;
@@ -891,40 +908,7 @@
 	sba_free_range(ioc, iova, size);
 	READ_REG(ioc->ioc_hpa+IOC_PCOM);	/* flush purges */
 #endif /* DELAYED_RESOURCE_CNT =3D 0 */
-#ifdef ENABLE_MARK_CLEAN
-	if (direction =3D PCI_DMA_FROMDEVICE) {
-		u32 iovp =3D (u32) SBA_IOVP(ioc,iova);
-		int off =3D PDIR_INDEX(iovp);
-		void *addr;
-
-		if (size <=3D IOVP_SIZE) {
-			addr =3D phys_to_virt(ioc->pdir_base[off] &
-					    ~0xE000000000000FFFULL);
-			mark_clean(addr, size);
-		} else {
-			size_t byte_cnt =3D size;
-
-			do {
-				addr =3D phys_to_virt(ioc->pdir_base[off] &
-				                    ~0xE000000000000FFFULL);
-				mark_clean(addr, min(byte_cnt, IOVP_SIZE));
-				off++;
-				byte_cnt -=3D IOVP_SIZE;
-
-			   } while (byte_cnt > 0);
-		}
-	}
-#endif
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
-
-	/* XXX REVISIT for 2.5 Linux - need syncdma for zero-copy support.
-	** For Astro based systems this isn't a big deal WRT performance.
-	** As long as 2.4 kernels copyin/copyout data from/to userspace,
-	** we don't need the syncdma. The issue here is I/O MMU cachelines
-	** are *not* coherent in all cases.  May be hwrev dependent.
-	** Need to investigate more.
-	asm volatile("syncdma");=09
-	*/
 }
=20
=20
@@ -980,242 +964,109 @@
 }
=20
=20
-/*
-** Since 0 is a valid pdir_base index value, can't use that
-** to determine if a value is valid or not. Use a flag to indicate
-** the SG list entry contains a valid pdir index.
-*/
-#define PIDE_FLAG 0x1UL
-
 #ifdef DEBUG_LARGE_SG_ENTRIES
 int dump_run_sg =3D 0;
 #endif
=20
-
-/**
- * sba_fill_pdir - write allocated SG entries into IO PDIR
- * @ioc: IO MMU structure which owns the pdir we are interested in.
- * @startsg:  list of IOVA/size pairs
- * @nents: number of entries in startsg list
- *
- * Take preprocessed SG list and write corresponding entries
- * in the IO PDIR.
- */
-
-static SBA_INLINE int
-sba_fill_pdir(
-	struct ioc *ioc,
-	struct scatterlist *startsg,
-	int nents)
-{
-	struct scatterlist *dma_sg =3D startsg;	/* pointer to current DMA */
-	int n_mappings =3D 0;
-	u64 *pdirp =3D 0;
-	unsigned long dma_offset =3D 0;
-
-	dma_sg--;
-	while (nents-- > 0) {
-		int     cnt =3D sba_sg_len(startsg);
-		sba_sg_len(startsg) =3D 0;
-
-#ifdef DEBUG_LARGE_SG_ENTRIES
-		if (dump_run_sg)
-			printk(" %2d : %08lx/%05x %p\n",
-				nents,
-				(unsigned long) sba_sg_iova(startsg), cnt,
-				sba_sg_buffer(startsg)
-		);
-#else
-		DBG_RUN_SG(" %d : %08lx/%05x %p\n",
-				nents,
-				(unsigned long) sba_sg_iova(startsg), cnt,
-				sba_sg_buffer(startsg)
-		);
-#endif
-		/*
-		** Look for the start of a new DMA stream
-		*/
-		if ((u64)sba_sg_iova(startsg) & PIDE_FLAG) {
-			u32 pide =3D (u64)sba_sg_iova(startsg) & ~PIDE_FLAG;
-			dma_offset =3D (unsigned long) pide & ~IOVP_MASK;
-			sba_sg_iova(startsg) =3D 0;
-			dma_sg++;
-			sba_sg_iova(dma_sg) =3D (char *)(pide | ioc->ibase);
-			pdirp =3D &(ioc->pdir_base[pide >> IOVP_SHIFT]);
-			n_mappings++;
-		}
-
-		/*
-		** Look for a VCONTIG chunk
-		*/
-		if (cnt) {
-			unsigned long vaddr =3D (unsigned long) sba_sg_buffer(startsg);
-			ASSERT(pdirp);
-
-			/* Since multiple Vcontig blocks could make up
-			** one DMA stream, *add* cnt to dma_len.
-			*/
-			sba_sg_len(dma_sg) +=3D cnt;
-			cnt +=3D dma_offset;
-			dma_offset=3D0;	/* only want offset on first chunk */
-			cnt =3D ROUNDUP(cnt, IOVP_SIZE);
-#ifdef CONFIG_PROC_FS
-			ioc->msg_pages +=3D cnt >> IOVP_SHIFT;
-#endif
-			do {
-				sba_io_pdir_entry(pdirp, vaddr);
-				vaddr +=3D IOVP_SIZE;
-				cnt -=3D IOVP_SIZE;
-				pdirp++;
-			} while (cnt > 0);
-		}
-		startsg++;
-	}
-#ifdef DEBUG_LARGE_SG_ENTRIES
-	dump_run_sg =3D 0;
-#endif
-	return(n_mappings);
-}
-
-
-/*
-** Two address ranges are DMA contiguous *iff* "end of prev" and
-** "start of next" are both on a page boundry.
-**
-** (shift left is a quick trick to mask off upper bits)
-*/
-#define DMA_CONTIG(__X, __Y) \
-	(((((unsigned long) __X) | ((unsigned long) __Y)) << (BITS_PER_LONG - PAG=
E_SHIFT)) =3D 0UL)
+#define SG_ENT_VIRT_PAGE(sg) page_address((sg)->page)
+#define SG_ENT_PHYS_PAGE(SG) virt_to_phys(SG_ENT_VIRT_PAGE(SG))
=20
=20
 /**
  * sba_coalesce_chunks - preprocess the SG list
  * @ioc: IO MMU structure which owns the pdir we are interested in.
- * @startsg:  list of IOVA/size pairs
+ * @startsg:  input=3DSG list	output=3DDMA addr/len pairs filled in
  * @nents: number of entries in startsg list
+ * @direction: R/W or both.
+ *
+ * Walk the SG list and determine where the breaks are in the DMA stream.
+ * Allocate IO Pdir resources and fill them in separate loop.
+ * Returns the number of DMA streams used for output IOVA list.
+ * Note each DMA stream can consume multiple IO Pdir entries.
  *
- * First pass is to walk the SG list and determine where the breaks are
- * in the DMA stream. Allocates PDIR entries but does not fill them.
- * Returns the number of DMA chunks.
- *
- * Doing the fill seperate from the coalescing/allocation keeps the
- * code simpler. Future enhancement could make one pass through
- * the sglist do both.
+ * Code is written assuming some coalescing is possible.
  */
 static SBA_INLINE int
-sba_coalesce_chunks( struct ioc *ioc,
-	struct scatterlist *startsg,
-	int nents)
-{
-	struct scatterlist *vcontig_sg;    /* VCONTIG chunk head */
-	unsigned long vcontig_len;         /* len of VCONTIG chunk */
-	unsigned long vcontig_end;
-	struct scatterlist *dma_sg;        /* next DMA stream head */
-	unsigned long dma_offset, dma_len; /* start/len of DMA stream */
+sba_coalesce_chunks(struct ioc *ioc, struct scatterlist *startsg,
+	int nents, int direction)
+{
+	struct scatterlist *dma_sg =3D startsg;	/* return array */
 	int n_mappings =3D 0;
=20
-	while (nents > 0) {
-		unsigned long vaddr =3D (unsigned long) (startsg->address);=20
+	ASSERT(nents > 1);
+
+	do {
+		unsigned int dma_cnt =3D 1; /* number of pages in DMA stream */
+		unsigned int pide;	/* index into IO Pdir array */
+		u64 *pdirp;		/* pointer into IO Pdir array */
+		unsigned long dma_offset, dma_len; /* cumulative DMA stream */
=20
 		/*
 		** Prepare for first/next DMA stream
 		*/
-		dma_sg =3D vcontig_sg =3D startsg;
-		dma_len =3D vcontig_len =3D vcontig_end =3D sba_sg_len(startsg);
-		vcontig_end +=3D  vaddr;
-		dma_offset =3D vaddr & ~IOVP_MASK;
-
-		/* PARANOID: clear entries */
-		sba_sg_buffer(startsg) =3D sba_sg_iova(startsg);
-		sba_sg_iova(startsg) =3D 0;
-		sba_sg_len(startsg) =3D 0;
+		dma_len =3D sba_sg_len(startsg);
+		dma_offset =3D (unsigned long) sba_sg_address(startsg);
+		startsg++;
+		nents--;
=20
 		/*
-		** This loop terminates one iteration "early" since
-		** it's always looking one "ahead".
+		** We want to know how many entries can be coalesced
+		** before trying to allocate IO Pdir space.
+		** IOVAs can then be allocated "naturally" aligned
+		** to take advantage of the block IO TLB flush.
 		*/
-		while (--nents > 0) {
-			unsigned long vaddr;	/* tmp */
+		while (nents) {
+			unsigned long end_offset =3D dma_offset + dma_len;
=20
-			startsg++;
-
-			/* catch brokenness in SCSI layer */
-			ASSERT(startsg->length <=3D DMA_CHUNK_SIZE);
+			/* prev entry must end on a page boundary */
+			if (end_offset & IOVP_MASK)
+				break;
=20
-			/*
-			** First make sure current dma stream won't
-			** exceed DMA_CHUNK_SIZE if we coalesce the
-			** next entry.
-			*/
-			if (((dma_len + dma_offset + startsg->length + ~IOVP_MASK) & IOVP_MASK)=
 > DMA_CHUNK_SIZE)
+			/* next entry start on a page boundary? */
+			if (startsg->offset)
 				break;
=20
 			/*
-			** Then look for virtually contiguous blocks.
-			**
-			** append the next transaction?
+			** make sure current dma stream won't exceed
+			** DMA_CHUNK_SIZE if coalescing entries.
 			*/
-			vaddr =3D (unsigned long) sba_sg_iova(startsg);
-			if  (vcontig_end =3D vaddr)
-			{
-				vcontig_len +=3D sba_sg_len(startsg);
-				vcontig_end +=3D sba_sg_len(startsg);
-				dma_len     +=3D sba_sg_len(startsg);
-				sba_sg_buffer(startsg) =3D (char *)vaddr;
-				sba_sg_iova(startsg) =3D 0;
-				sba_sg_len(startsg) =3D 0;
-				continue;
-			}
+			if (((end_offset + startsg->length + ~IOVP_MASK)
+								& IOVP_MASK)
+					> DMA_CHUNK_SIZE)
+				break;
=20
-#ifdef DEBUG_LARGE_SG_ENTRIES
-			dump_run_sg =3D (vcontig_len > IOVP_SIZE);
-#endif
+			dma_len +=3D sba_sg_len(startsg);
+			startsg++;
+			nents--;
+			dma_cnt++;
+		}
=20
-			/*
-			** Not virtually contigous.
-			** Terminate prev chunk.
-			** Start a new chunk.
-			**
-			** Once we start a new VCONTIG chunk, dma_offset
-			** can't change. And we need the offset from the first
-			** chunk - not the last one. Ergo Successive chunks
-			** must start on page boundaries and dove tail
-			** with it's predecessor.
-			*/
-			sba_sg_len(vcontig_sg) =3D vcontig_len;
+		ASSERT(dma_len <=3D DMA_CHUNK_SIZE);
=20
-			vcontig_sg =3D startsg;
-			vcontig_len =3D sba_sg_len(startsg);
+		/* allocate IO Pdir resource.
+		** returns index into (u64) IO Pdir array.
+		** IOVA is formed from this.
+		*/
+		pide =3D sba_alloc_range(ioc, dma_cnt << IOVP_SHIFT);
+		pdirp =3D &(ioc->pdir_base[pide]);
=20
-			/*
-			** 3) do the entries end/start on page boundaries?
-			**    Don't update vcontig_end until we've checked.
-			*/
-			if (DMA_CONTIG(vcontig_end, vaddr))
-			{
-				vcontig_end =3D vcontig_len + vaddr;
-				dma_len +=3D vcontig_len;
-				sba_sg_buffer(startsg) =3D (char *)vaddr;
-				sba_sg_iova(startsg) =3D 0;
-				continue;
-			} else {
-				break;
-			}
+		/* fill_pdir: write stream into IO Pdir */
+		while (dma_cnt--) {
+			sba_io_pdir_entry(pdirp, SG_ENT_PHYS_PAGE(startsg));
+			startsg++;
+			pdirp++;
 		}
=20
-		/*
-		** End of DMA Stream
-		** Terminate last VCONTIG block.
-		** Allocate space for DMA stream.
-		*/
-		sba_sg_len(vcontig_sg) =3D vcontig_len;
-		dma_len =3D (dma_len + dma_offset + ~IOVP_MASK) & IOVP_MASK;
-		ASSERT(dma_len <=3D DMA_CHUNK_SIZE);
-		sba_sg_iova(dma_sg) =3D (char *) (PIDE_FLAG=20
-			| (sba_alloc_range(ioc, dma_len) << IOVP_SHIFT)
-			| dma_offset);
+		/* "output" IOVA */
+		sba_sg_iova(dma_sg) =3D SBA_IOVA(ioc,
+					((dma_addr_t) pide << IOVP_SHIFT),
+					dma_offset,
+					DEFAULT_DMA_HINT_REG(direction));
+		sba_sg_iova_len(dma_sg) =3D dma_len;
+
+		dma_sg++;
 		n_mappings++;
-	}
+	} while (nents);
=20
 	return n_mappings;
 }
@@ -1223,7 +1074,7 @@
=20
 /**
  * sba_map_sg - map Scatter/Gather list
- * @dev: instance of PCI owned by the driver that's asking.
+ * @dev: instance of PCI device owned by the driver that's asking.
  * @sglist:  array of buffer/length pairs
  * @nents:  number of entries in list
  * @direction:  R/W or both.
@@ -1234,42 +1085,46 @@
 		int direction)
 {
 	struct ioc *ioc;
-	int coalesced, filled =3D 0;
+	int filled =3D 0;
 	unsigned long flags;
 #ifdef ALLOW_IOV_BYPASS
 	struct scatterlist *sg;
 #endif
=20
-	DBG_RUN_SG("%s() START %d entries\n", __FUNCTION__, nents);
+	DBG_RUN_SG("%s() START %d entries, 0x%p,0x%x\n", __FUNCTION__, nents,
+		sba_sg_address(sglist), sba_sg_len(sglist));
+
 	ioc =3D GET_IOC(dev);
 	ASSERT(ioc);
=20
 #ifdef ALLOW_IOV_BYPASS
 	if (dev->dma_mask >=3D ioc->dma_mask) {
-		for (sg =3D sglist ; filled < nents ; filled++, sg++){
-			sba_sg_buffer(sg) =3D sba_sg_iova(sg);
-			sba_sg_iova(sg) =3D (char *)virt_to_phys(sba_sg_buffer(sg));
+		for (sg =3D sglist ; filled < nents ; filled++, sg++) {
+			sba_sg_iova(sg) =3D virt_to_phys(sba_sg_address(sg));
+			sba_sg_iova_len(sg) =3D sba_sg_len(sg);
 		}
 #ifdef CONFIG_PROC_FS
 		spin_lock_irqsave(&ioc->res_lock, flags);
 		ioc->msg_bypass++;
 		spin_unlock_irqrestore(&ioc->res_lock, flags);
 #endif
+		DBG_RUN_SG("%s() DONE %d mappings bypassed\n", __FUNCTION__, filled);
 		return filled;
 	}
 #endif
 	/* Fast path single entry scatterlists. */
 	if (nents =3D 1) {
-		sba_sg_buffer(sglist) =3D sba_sg_iova(sglist);
-		sba_sg_iova(sglist) =3D (char *)sba_map_single(dev,
-						sba_sg_buffer(sglist),
-						sba_sg_len(sglist), direction);
+		sba_sg_iova(sglist) =3D sba_map_single(dev,
+						     (void *) sba_sg_iova(sglist),
+						     sba_sg_len(sglist), direction);
+		sba_sg_iova_len(sglist) =3D sba_sg_len(sglist);
 #ifdef CONFIG_PROC_FS
 		/*
 		** Should probably do some stats counting, but trying to
 		** be precise quickly starts wasting CPU time.
 		*/
 #endif
+		DBG_RUN_SG("%s() DONE 1 mapping\n", __FUNCTION__);
 		return 1;
 	}
=20
@@ -1286,26 +1141,11 @@
 #ifdef CONFIG_PROC_FS
 	ioc->msg_calls++;
 #endif
-
-	/*
-	** First coalesce the chunks and allocate I/O pdir space
-	**
-	** If this is one DMA stream, we can properly map using the
-	** correct virtual address associated with each DMA page.
-	** w/o this association, we wouldn't have coherent DMA!
-	** Access to the virtual address is what forces a two pass algorithm.
-	*/
-	coalesced =3D sba_coalesce_chunks(ioc, sglist, nents);
 =20
 	/*
-	** Program the I/O Pdir
-	**
-	** map the virtual addresses to the I/O Pdir
-	** o dma_address will contain the pdir index
-	** o dma_len will contain the number of bytes to map=20
-	** o address contains the virtual address.
+	** coalesce and program the I/O Pdir
 	*/
-	filled =3D sba_fill_pdir(ioc, sglist, nents);
+	filled =3D sba_coalesce_chunks(ioc, sglist, nents, direction);
=20
 #ifdef ASSERT_PDIR_SANITY
 	if (sba_check_pdir(ioc,"Check after sba_map_sg()"))
@@ -1317,7 +1157,6 @@
=20
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
=20
-	ASSERT(coalesced =3D filled);
 	DBG_RUN_SG("%s() DONE %d mappings\n", __FUNCTION__, filled);
=20
 	return filled;
@@ -1341,8 +1180,8 @@
 	unsigned long flags;
 #endif
=20
-	DBG_RUN_SG("%s() START %d entries,  %p,%x\n",
-		__FUNCTION__, nents, sba_sg_buffer(sglist), sglist->length);
+	DBG_RUN_SG("%s() START %d entries, 0x%p,0x%x\n",
+		__FUNCTION__, nents, sba_sg_address(sglist), sba_sg_len(sglist));
=20
 	ioc =3D GET_IOC(dev);
 	ASSERT(ioc);
@@ -1360,7 +1199,7 @@
 	while (sba_sg_len(sglist) && nents--) {
=20
 		sba_unmap_single(dev, (dma_addr_t)sba_sg_iova(sglist),
-		                 sba_sg_len(sglist), direction);
+		                 sba_sg_iova_len(sglist), direction);
 #ifdef CONFIG_PROC_FS
 		/*
 		** This leaves inconsistent data in the stats, but we can't
@@ -1368,7 +1207,7 @@
 		** were coalesced to a single entry.  The stats are fun,
 		** but speed is more important.
 		*/
-		ioc->usg_pages +=3D (((u64)sba_sg_iova(sglist) & ~IOVP_MASK) + sba_sg_le=
n(sglist) + IOVP_SIZE - 1) >> PAGE_SHIFT;
+		ioc->usg_pages +=3D (((u64)sba_sg_iova(sglist) & ~IOVP_MASK) + sba_sg_le=
n(sglist) + IOVP_SIZE - 1) >> IOVP_SHIFT;
 #endif
 		++sglist;
 	}
@@ -1429,12 +1268,12 @@
 		__FUNCTION__, ioc->ioc_hpa, iova_space_size>>20,
 		iov_order + PAGE_SHIFT, ioc->pdir_size);
=20
-	/* FIXME : DMA HINTs not used */
+	/* XXX DMA HINTs not used */
 	ioc->hint_shift_pdir =3D iov_order + PAGE_SHIFT;
 	ioc->hint_mask_pdir =3D ~(0x3 << (iov_order + PAGE_SHIFT));
=20
-	ioc->pdir_base -	pdir_base =3D (void *) __get_free_pages(GFP_KERNEL, get_=
order(pdir_size));
+	ioc->pdir_base =3D pdir_base +		(void *) __get_free_pages(GFP_KERNEL, get=
_order(pdir_size));
 	if (NULL =3D pdir_base)
 	{
 		panic(__FILE__ ":%s() could not allocate I/O Page Table\n", __FUNCTION__=
);
@@ -1452,20 +1291,8 @@
=20
 	/* build IMASK for IOC and Elroy */
 	iova_space_mask =3D  0xffffffff;
-	iova_space_mask <<=3D (iov_order + PAGE_SHIFT);
+	iova_space_mask <<=3D (iov_order + IOVP_SHIFT);
=20
-#ifdef CONFIG_IA64_HP_PROTO
-	/*
-	** REVISIT - this is a kludge, but we won't be supporting anything but
-	** zx1 2.0 or greater for real.  When fw is in shape, ibase will
-	** be preprogrammed w/ the IOVA hole base and imask will give us
-	** the size.
-	*/
-	if ((sba_dev->hw_rev & 0xFF) < 0x20) {
-		DBG_INIT("%s() Found SBA rev < 2.0, setting IOVA base to 0.  This device=
 will not be supported in the future.\n", __FUNCTION__);
-		ioc->ibase =3D 0x0;
-	} else
-#endif
 	ioc->ibase =3D READ_REG(ioc->ioc_hpa + IOC_IBASE) & 0xFFFFFFFEUL;
=20
 	ioc->imask =3D iova_space_mask;	/* save it */
@@ -1474,7 +1301,7 @@
 		__FUNCTION__, ioc->ibase, ioc->imask);
=20
 	/*
-	** FIXME: Hint registers are programmed with default hint
+	** XXX DMA HINT registers are programmed with default hint
 	** values during boot, so hints should be sane even if we
 	** can't reprogram them the way drivers want.
 	*/
@@ -1487,8 +1314,8 @@
 	*/
 	ioc->imask |=3D 0xFFFFFFFF00000000UL;
=20
-	/* Set I/O PDIR Page size to system page size */
-	switch (PAGE_SHIFT) {
+	/* Set I/O Pdir page size to system page size */
+	switch (IOVP_SHIFT) {
 		case 12: /* 4K */
 			tcnfg =3D 0;
 			break;
@@ -1628,7 +1455,7 @@
 			sba_dev->ioc[i].pdir_base[0] =3D 0x8000badbadc0ffeeULL;
=20
 			for (reserved_iov =3D 0xA0000 ; reserved_iov < 0xC0000 ; reserved_iov +=
=3D IOVP_SIZE) {
-				u64 *res_ptr =3D sba_dev->ioc[i].res_map;
+				u64 *res_ptr =3D (u64 *) sba_dev->ioc[i].res_map;
 				int index =3D PDIR_INDEX(reserved_iov);
 				int res_word;
 				u64 mask;
@@ -1636,7 +1463,7 @@
 				res_word =3D (int)(index / BITS_PER_LONG);
 				mask =3D  0x1UL << (index - (res_word * BITS_PER_LONG));
 				res_ptr[res_word] |=3D mask;
-				sba_dev->ioc[i].pdir_base[PDIR_INDEX(reserved_iov)] =3D (0x80000000000=
000FFULL | reserved_iov);
+				sba_dev->ioc[i].pdir_base[PDIR_INDEX(reserved_iov)] =3D (SBA_VALID_MAS=
K | reserved_iov);
=20
 			}
 		}
@@ -1759,8 +1586,8 @@
=20
 	for (i =3D 0; i < PCI_NUM_RESOURCES; i++) {
 		if (pci_resource_flags(device, i) =3D IORESOURCE_MEM) {
-			hpa =3D ioremap(pci_resource_start(device, i),
-				pci_resource_len(device, i));
+			hpa =3D (u64) ioremap(pci_resource_start(device, i),
+					    pci_resource_len(device, i));
 			break;
 		}
 	}
@@ -1768,7 +1595,7 @@
 	func_id =3D READ_REG(hpa + SBA_FUNC_ID);
=20
 	if (func_id =3D ZX1_FUNC_ID_VALUE) {
-		(void)strcpy(sba_rev, "zx1");
+		strcpy(sba_rev, "zx1");
 		func_offset =3D zx1_func_offsets;
 	} else {
 		return;
diff -Nru a/arch/ia64/hp/sim/Config.in b/arch/ia64/hp/sim/Config.in
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/hp/sim/Config.in	Sat Aug 10 01:51:46 2002
@@ -0,0 +1,9 @@
+mainmenu_option next_comment
+comment 'HP Simulator drivers'
+
+bool 'Simulated Ethernet ' CONFIG_HP_SIMETH
+bool 'Simulated serial driver support' CONFIG_HP_SIMSERIAL
+if [ "$CONFIG_SCSI" !=3D "n" ]; then
+  bool 'Simulated SCSI disk' CONFIG_HP_SIMSCSI
+fi
+endmenu
diff -Nru a/arch/ia64/hp/sim/hpsim_console.c b/arch/ia64/hp/sim/hpsim_conso=
le.c
--- a/arch/ia64/hp/sim/hpsim_console.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/hp/sim/hpsim_console.c	Sat Aug 10 01:51:46 2002
@@ -30,12 +30,12 @@
 static kdev_t simcons_console_device (struct console *);
=20
 struct console hpsim_cons =3D {
-	name:		"simcons",
-	write:		simcons_write,
-	device:		simcons_console_device,
-	setup:		simcons_init,
-	flags:		CON_PRINTBUFFER,
-	index:		-1,
+	.name =3D		"simcons",
+	.write =3D	simcons_write,
+	.device =3D	simcons_console_device,
+	.setup =3D	simcons_init,
+	.flags =3D	CON_PRINTBUFFER,
+	.index =3D	-1,
 };
=20
 static int
diff -Nru a/arch/ia64/hp/sim/hpsim_irq.c b/arch/ia64/hp/sim/hpsim_irq.c
--- a/arch/ia64/hp/sim/hpsim_irq.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/hp/sim/hpsim_irq.c	Sat Aug 10 01:51:46 2002
@@ -22,14 +22,14 @@
 }
=20
 static struct hw_interrupt_type irq_type_hp_sim =3D {
-	typename:	"hpsim",
-	startup:	hpsim_irq_startup,
-	shutdown:	hpsim_irq_noop,
-	enable:		hpsim_irq_noop,
-	disable:	hpsim_irq_noop,
-	ack:		hpsim_irq_noop,
-	end:		hpsim_irq_noop,
-	set_affinity:	(void (*)(unsigned int, unsigned long)) hpsim_irq_noop,
+	.typename =3D	"hpsim",
+	.startup =3D	hpsim_irq_startup,
+	.shutdown =3D	hpsim_irq_noop,
+	.enable =3D	hpsim_irq_noop,
+	.disable =3D	hpsim_irq_noop,
+	.ack =3D		hpsim_irq_noop,
+	.end =3D		hpsim_irq_noop,
+	.set_affinity =3D	(void (*)(unsigned int, unsigned long)) hpsim_irq_noop,
 };
=20
 void __init
diff -Nru a/arch/ia64/hp/sim/hpsim_setup.c b/arch/ia64/hp/sim/hpsim_setup.c
--- a/arch/ia64/hp/sim/hpsim_setup.c	Sat Aug 10 01:51:47 2002
+++ b/arch/ia64/hp/sim/hpsim_setup.c	Sat Aug 10 01:51:47 2002
@@ -1,18 +1,19 @@
 /*
  * Platform dependent support for HP simulator.
  *
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998, 1999, 2002 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1999 Vijay Chander <vijay@engr.sgi.com>
  */
+#include <linux/console.h>
 #include <linux/init.h>
+#include <linux/kdev_t.h>
 #include <linux/kernel.h>
+#include <linux/major.h>
 #include <linux/param.h>
+#include <linux/root_dev.h>
 #include <linux/string.h>
 #include <linux/types.h>
-#include <linux/kdev_t.h>
-#include <linux/console.h>
-#include <linux/root_dev.h>
=20
 #include <asm/delay.h>
 #include <asm/irq.h>
@@ -55,5 +56,5 @@
 {
 	ROOT_DEV =3D Root_SDA1;		/* default to first SCSI drive */
=20
-	register_console (&hpsim_cons);
+	register_console(&hpsim_cons);
 }
diff -Nru a/arch/ia64/hp/sim/simscsi.c b/arch/ia64/hp/sim/simscsi.c
--- a/arch/ia64/hp/sim/simscsi.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/hp/sim/simscsi.c	Sat Aug 10 01:51:46 2002
@@ -62,7 +62,9 @@
=20
 extern long ia64_ssc (long arg0, long arg1, long arg2, long arg3, int nr);
=20
-static int desc[8] =3D { -1, -1, -1, -1, -1, -1, -1, -1 };
+static int desc[16] =3D {
+	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
+};
=20
 static struct queue_entry {
 	Scsi_Cmnd *sc;
@@ -148,9 +150,9 @@
 {
 	int size =3D disk->capacity;
=20
-	ip[0] =3D 64;
-	ip[1] =3D 32;
-	ip[2] =3D size >> 11;
+	ip[0] =3D 64;		/* heads */
+	ip[1] =3D 32;		/* sectors */
+	ip[2] =3D size >> 11;	/* cylinders */
 	return 0;
 }
=20
@@ -229,6 +231,29 @@
 		simscsi_readwrite(sc, mode, offset, sc->cmnd[4]*512);
 }
=20
+static size_t
+simscsi_get_disk_size (int fd)
+{
+	struct disk_stat stat;
+	size_t bit, sectors =3D 0;
+	struct disk_req req;
+	char buf[512];
+
+	/*
+	 * This is a bit kludgey: the simulator doesn't provide a direct way of d=
etermining
+	 * the disk size, so we do a binary search, assuming a maximum disk size =
of 4GB.
+	 */
+	for (bit =3D (4UL << 30)/512; bit !=3D 0; bit >>=3D 1) {
+		req.addr =3D __pa(&buf);
+		req.len =3D sizeof(buf);
+		ia64_ssc(fd, 1, __pa(&req), ((sectors | bit) - 1)*512, SSC_READ);
+		stat.fd =3D fd;
+		ia64_ssc(__pa(&stat), 0, 0, 0, SSC_WAIT_COMPLETION);
+		if (stat.count =3D sizeof(buf))
+			sectors |=3D bit;
+	}
+	return sectors - 1;	/* return last valid sector number */
+}
=20
 static void
 simscsi_readwrite10 (Scsi_Cmnd *sc, int mode)
@@ -247,6 +272,7 @@
 simscsi_queuecommand (Scsi_Cmnd *sc, void (*done)(Scsi_Cmnd *))
 {
 	char fname[MAX_ROOT_LEN+16];
+	size_t disk_size;
 	char *buf;
 #if DEBUG_SIMSCSI
 	register long sp asm ("sp");
@@ -258,15 +284,15 @@
=20
 	sc->result =3D DID_BAD_TARGET << 16;
 	sc->scsi_done =3D done;
-	if (sc->target <=3D 7 && sc->lun =3D 0) {
+	if (sc->target <=3D 15 && sc->lun =3D 0) {
 		switch (sc->cmnd[0]) {
 		      case INQUIRY:
 			if (sc->request_bufflen < 35) {
 				break;
 			}
 			sprintf (fname, "%s%c", simscsi_root, 'a' + sc->target);
-			desc[sc->target] =3D ia64_ssc (__pa(fname), SSC_READ_ACCESS|SSC_WRITE_A=
CCESS,
-						     0, 0, SSC_OPEN);
+			desc[sc->target] =3D ia64_ssc(__pa(fname), SSC_READ_ACCESS|SSC_WRITE_AC=
CESS,
+						    0, 0, SSC_OPEN);
 			if (desc[sc->target] < 0) {
 				/* disk doesn't exist... */
 				break;
@@ -319,11 +345,13 @@
 			}
 			buf =3D sc->request_buffer;
=20
+			disk_size =3D simscsi_get_disk_size(desc[sc->target]);
+
 			/* pretend to be a 1GB disk (partition table contains real stuff): */
-			buf[0] =3D 0x00;
-			buf[1] =3D 0x1f;
-			buf[2] =3D 0xff;
-			buf[3] =3D 0xff;
+			buf[0] =3D (disk_size >> 24) & 0xff;
+			buf[1] =3D (disk_size >> 16) & 0xff;
+			buf[2] =3D (disk_size >>  8) & 0xff;
+			buf[3] =3D (disk_size >>  0) & 0xff;
 			/* set block size of 512 bytes: */
 			buf[4] =3D 0;
 			buf[5] =3D 0;
diff -Nru a/arch/ia64/hp/sim/simserial.c b/arch/ia64/hp/sim/simserial.c
--- a/arch/ia64/hp/sim/simserial.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/hp/sim/simserial.c	Sat Aug 10 01:51:46 2002
@@ -13,6 +13,7 @@
  *
  * 02/04/00 D. Mosberger	Merged in serial.c bug fixes in rs_close().
  * 02/25/00 D. Mosberger	Synced up with 2.3.99pre-5 version of serial.c.
+ * 07/30/02 D. Mosberger	Replace sti()/cli() with explicit spinlocks & loc=
al irq masking
  */
=20
 #include <linux/config.h>
@@ -31,6 +32,7 @@
 #include <linux/serialP.h>
=20
 #include <asm/irq.h>
+#include <asm/hw_irq.h>
 #include <asm/uaccess.h>
=20
 #ifdef CONFIG_KDB
@@ -61,6 +63,7 @@
=20
 static char *serial_name =3D "SimSerial driver";
 static char *serial_version =3D "0.6";
+static spinlock_t serial_lock =3D SPIN_LOCK_UNLOCKED;
=20
 /*
  * This has been extracted from asm/serial.h. We need one eventually but
@@ -232,14 +235,14 @@
=20
 	if (!tty || !info->xmit.buf) return;
=20
-	save_flags(flags); cli();
+	spin_lock_irqsave(&serial_lock, flags);
 	if (CIRC_SPACE(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE) =3D 0)=
 {
-		restore_flags(flags);
+		spin_unlock_irqrestore(&serial_lock, flags);
 		return;
 	}
 	info->xmit.buf[info->xmit.head] =3D ch;
 	info->xmit.head =3D (info->xmit.head + 1) & (SERIAL_XMIT_SIZE-1);
-	restore_flags(flags);
+	spin_unlock_irqrestore(&serial_lock, flags);
 }
=20
 static _INLINE_ void transmit_chars(struct async_struct *info, int *intr_d=
one)
@@ -247,7 +250,7 @@
 	int count;
 	unsigned long flags;
=20
-	save_flags(flags); cli();
+	spin_lock_irqsave(&serial_lock, flags);
=20
 	if (info->x_char) {
 		char c =3D info->x_char;
@@ -290,7 +293,7 @@
 		info->xmit.tail +=3D count;
 	}
 out:
-	restore_flags(flags);
+	spin_unlock_irqrestore(&serial_lock, flags);
 }
=20
 static void rs_flush_chars(struct tty_struct *tty)
@@ -314,7 +317,6 @@
=20
 	if (!tty || !info->xmit.buf || !tmp_buf) return 0;
=20
-	save_flags(flags);
 	if (from_user) {
 		down(&tmp_buf_sem);
 		while (1) {
@@ -331,21 +333,26 @@
 					ret =3D -EFAULT;
 				break;
 			}
-			cli();
-			c1 =3D CIRC_SPACE_TO_END(info->xmit.head, info->xmit.tail, SERIAL_XMIT_=
SIZE);
-			if (c1 < c)
-				c =3D c1;
-			memcpy(info->xmit.buf + info->xmit.head, tmp_buf, c);
-			info->xmit.head =3D ((info->xmit.head + c) &
-					   (SERIAL_XMIT_SIZE-1));
-			restore_flags(flags);
+
+			spin_lock_irqsave(&serial_lock, flags);
+			{
+				c1 =3D CIRC_SPACE_TO_END(info->xmit.head, info->xmit.tail,
+						       SERIAL_XMIT_SIZE);
+				if (c1 < c)
+					c =3D c1;
+				memcpy(info->xmit.buf + info->xmit.head, tmp_buf, c);
+				info->xmit.head =3D ((info->xmit.head + c) &
+						   (SERIAL_XMIT_SIZE-1));
+			}
+			spin_unlock_irqrestore(&serial_lock, flags);
+
 			buf +=3D c;
 			count -=3D c;
 			ret +=3D c;
 		}
 		up(&tmp_buf_sem);
 	} else {
-		cli();
+		spin_lock_irqsave(&serial_lock, flags);
 		while (1) {
 			c =3D CIRC_SPACE_TO_END(info->xmit.head, info->xmit.tail, SERIAL_XMIT_S=
IZE);
 			if (count < c)
@@ -360,7 +367,7 @@
 			count -=3D c;
 			ret +=3D c;
 		}
-		restore_flags(flags);
+		spin_unlock_irqrestore(&serial_lock, flags);
 	}
 	/*
 	 * Hey, we transmit directly from here in our case
@@ -391,9 +398,9 @@
 	struct async_struct *info =3D (struct async_struct *)tty->driver_data;
 	unsigned long flags;
=20
-	save_flags(flags); cli();
+	spin_lock_irqsave(&serial_lock, flags);
 	info->xmit.head =3D info->xmit.tail =3D 0;
-	restore_flags(flags);
+	spin_unlock_irqrestore(&serial_lock, flags);
=20
 	wake_up_interruptible(&tty->write_wait);
=20
@@ -566,44 +573,45 @@
 	       state->irq);
 #endif
=20
-	save_flags(flags); cli(); /* Disable interrupts */
-
-	/*
-	 * First unlink the serial port from the IRQ chain...
-	 */
-	if (info->next_port)
-		info->next_port->prev_port =3D info->prev_port;
-	if (info->prev_port)
-		info->prev_port->next_port =3D info->next_port;
-	else
-		IRQ_ports[state->irq] =3D info->next_port;
+	spin_lock_irqsave(&serial_lock, flags);
+	{
+		/*
+		 * First unlink the serial port from the IRQ chain...
+		 */
+		if (info->next_port)
+			info->next_port->prev_port =3D info->prev_port;
+		if (info->prev_port)
+			info->prev_port->next_port =3D info->next_port;
+		else
+			IRQ_ports[state->irq] =3D info->next_port;
=20
-	/*
-	 * Free the IRQ, if necessary
-	 */
-	if (state->irq && (!IRQ_ports[state->irq] ||
-			  !IRQ_ports[state->irq]->next_port)) {
-		if (IRQ_ports[state->irq]) {
-			free_irq(state->irq, NULL);
-			retval =3D request_irq(state->irq, rs_interrupt_single,
-					     IRQ_T(info), "serial", NULL);
-
-			if (retval)
-				printk("serial shutdown: request_irq: error %d"
-				       "  Couldn't reacquire IRQ.\n", retval);
-		} else
-			free_irq(state->irq, NULL);
-	}
+		/*
+		 * Free the IRQ, if necessary
+		 */
+		if (state->irq && (!IRQ_ports[state->irq] ||
+				   !IRQ_ports[state->irq]->next_port)) {
+			if (IRQ_ports[state->irq]) {
+				free_irq(state->irq, NULL);
+				retval =3D request_irq(state->irq, rs_interrupt_single,
+						     IRQ_T(info), "serial", NULL);
+
+				if (retval)
+					printk("serial shutdown: request_irq: error %d"
+					       "  Couldn't reacquire IRQ.\n", retval);
+			} else
+				free_irq(state->irq, NULL);
+		}
=20
-	if (info->xmit.buf) {
-		free_page((unsigned long) info->xmit.buf);
-		info->xmit.buf =3D 0;
-	}
+		if (info->xmit.buf) {
+			free_page((unsigned long) info->xmit.buf);
+			info->xmit.buf =3D 0;
+		}
=20
-	if (info->tty) set_bit(TTY_IO_ERROR, &info->tty->flags);
+		if (info->tty) set_bit(TTY_IO_ERROR, &info->tty->flags);
=20
-	info->flags &=3D ~ASYNC_INITIALIZED;
-	restore_flags(flags);
+		info->flags &=3D ~ASYNC_INITIALIZED;
+	}
+	spin_unlock_irqrestore(&serial_lock, flags);
 }
=20
 /*
@@ -626,14 +634,13 @@
=20
 	state =3D info->state;
=20
-	save_flags(flags); cli();
-
+	spin_lock_irqsave(&serial_lock, flags);
 	if (tty_hung_up_p(filp)) {
 #ifdef SIMSERIAL_DEBUG
 		printk("rs_close: hung_up\n");
 #endif
 		MOD_DEC_USE_COUNT;
-		restore_flags(flags);
+		spin_unlock_irqrestore(&serial_lock, flags);
 		return;
 	}
 #ifdef SIMSERIAL_DEBUG
@@ -658,11 +665,11 @@
 	}
 	if (state->count) {
 		MOD_DEC_USE_COUNT;
-		restore_flags(flags);
+		spin_unlock_irqrestore(&serial_lock, flags);
 		return;
 	}
 	info->flags |=3D ASYNC_CLOSING;
-	restore_flags(flags);
+	spin_unlock_irqrestore(&serial_lock, flags);
=20
 	/*
 	 * Now we wait for the transmit buffer to clear; and we notify
@@ -770,7 +777,7 @@
 	if (!page)
 		return -ENOMEM;
=20
-	save_flags(flags); cli();
+	spin_lock_irqsave(&serial_lock, flags);
=20
 	if (info->flags & ASYNC_INITIALIZED) {
 		free_page(page);
@@ -851,11 +858,11 @@
 	}
=20
 	info->flags |=3D ASYNC_INITIALIZED;
-	restore_flags(flags);
+	spin_unlock_irqrestore(&serial_lock, flags);
 	return 0;
=20
 errout:
-	restore_flags(flags);
+	spin_unlock_irqrestore(&serial_lock, flags);
 	return retval;
 }
=20
diff -Nru a/arch/ia64/hp/zx1/hpzx1_machvec.c b/arch/ia64/hp/zx1/hpzx1_machv=
ec.c
--- a/arch/ia64/hp/zx1/hpzx1_machvec.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/hp/zx1/hpzx1_machvec.c	Sat Aug 10 01:51:46 2002
@@ -1,4 +1,2 @@
 #define MACHVEC_PLATFORM_NAME	hpzx1
 #include <asm/machvec_init.h>
-#define MACHVEC_PLATFORM_NAME	hpzx1
-#include <asm/machvec_init.h>
diff -Nru a/arch/ia64/hp/zx1/hpzx1_misc.c b/arch/ia64/hp/zx1/hpzx1_misc.c
--- a/arch/ia64/hp/zx1/hpzx1_misc.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/hp/zx1/hpzx1_misc.c	Sat Aug 10 01:51:46 2002
@@ -12,111 +12,65 @@
 #include <linux/kernel.h>
 #include <linux/pci.h>
 #include <linux/acpi.h>
-#include <asm/iosapic.h>
+
+#include <asm/dma.h>
 #include <asm/efi.h>
+#include <asm/iosapic.h>
=20
-#include "../drivers/acpi/include/platform/acgcc.h"
-#include "../drivers/acpi/include/actypes.h"
-#include "../drivers/acpi/include/acexcep.h"
-#include "../drivers/acpi/include/acpixf.h"
-#include "../drivers/acpi/include/actbl.h"
-#include "../drivers/acpi/include/acconfig.h"
-#include "../drivers/acpi/include/acmacros.h"
-#include "../drivers/acpi/include/aclocal.h"
-#include "../drivers/acpi/include/acobject.h"
-#include "../drivers/acpi/include/acstruct.h"
-#include "../drivers/acpi/include/acnamesp.h"
-#include "../drivers/acpi/include/acutils.h"
+extern acpi_status acpi_evaluate_integer (acpi_handle, acpi_string, acpi_o=
bject_list *,
+					  unsigned long *);
=20
 #define PFX "hpzx1: "
=20
+static int hpzx1_devices;
+
 struct fake_pci_dev {
-	struct fake_pci_dev *next;
-	unsigned char bus;
-	unsigned int devfn;
-	int sizing;		// in middle of BAR sizing operation?
 	unsigned long csr_base;
-	unsigned int csr_size;
+	unsigned long csr_size;
 	unsigned long mapped_csrs;	// ioremapped
+	int sizing;			// in middle of BAR sizing operation?
 };
=20
-static struct fake_pci_dev *fake_pci_head, **fake_pci_tail =3D &fake_pci_h=
ead;
-
 static struct pci_ops *orig_pci_ops;
=20
-static inline struct fake_pci_dev *
-fake_pci_find_slot(unsigned char bus, unsigned int devfn)
-{
-	struct fake_pci_dev *dev;
-
-	for (dev =3D fake_pci_head; dev; dev =3D dev->next)
-		if (dev->bus =3D bus && dev->devfn =3D devfn)
-			return dev;
-	return NULL;
+#define HP_CFG_RD(sz, bits, name)						\
+static int hp_cfg_read##sz (struct pci_dev *dev, int where, u##bits *value=
)	\
+{										\
+	struct fake_pci_dev *fake_dev;						\
+	if (!(fake_dev =3D (struct fake_pci_dev *) dev->sysdata))			\
+		return orig_pci_ops->name(dev, where, value);			\
+										\
+	if (where =3D PCI_BASE_ADDRESS_0) {					\
+		if (fake_dev->sizing)						\
+			*value =3D ~(fake_dev->csr_size - 1);			\
+		else								\
+			*value =3D (fake_dev->csr_base &				\
+				    PCI_BASE_ADDRESS_MEM_MASK) |		\
+				PCI_BASE_ADDRESS_SPACE_MEMORY;			\
+		fake_dev->sizing =3D 0;						\
+		return PCIBIOS_SUCCESSFUL;					\
+	}									\
+	*value =3D read##sz(fake_dev->mapped_csrs + where);			\
+	if (where =3D PCI_COMMAND)						\
+		*value |=3D PCI_COMMAND_MEMORY; /* SBA omits this */		\
+	return PCIBIOS_SUCCESSFUL;						\
 }
=20
-static struct fake_pci_dev *
-alloc_fake_pci_dev(void)
-{
-        struct fake_pci_dev *dev;
-
-        dev =3D kmalloc(sizeof(*dev), GFP_KERNEL);
-	if (!dev)
-		return NULL;
-
-	memset(dev, 0, sizeof(*dev));
-
-        *fake_pci_tail =3D dev;
-        fake_pci_tail =3D &dev->next;
-
-        return dev;
-}
-
-#define HP_CFG_RD(sz, bits, name) \
-static int hp_cfg_read##sz (struct pci_dev *dev, int where, u##bits *value=
) \
-{ \
-	struct fake_pci_dev *fake_dev; \
-	if (!(fake_dev =3D fake_pci_find_slot(dev->bus->number, dev->devfn))) \
-		return orig_pci_ops->name(dev, where, value); \
-	\
-	switch (where) { \
-	case PCI_COMMAND: \
-		*value =3D read##sz(fake_dev->mapped_csrs + where); \
-		*value |=3D PCI_COMMAND_MEMORY; /* SBA omits this */ \
-		break; \
-	case PCI_BASE_ADDRESS_0: \
-		if (fake_dev->sizing) \
-			*value =3D ~(fake_dev->csr_size - 1); \
-		else \
-			*value =3D (fake_dev->csr_base & \
-				    PCI_BASE_ADDRESS_MEM_MASK) | \
-				PCI_BASE_ADDRESS_SPACE_MEMORY; \
-		fake_dev->sizing =3D 0; \
-		break; \
-	default: \
-		*value =3D read##sz(fake_dev->mapped_csrs + where); \
-		break; \
-	} \
-	return PCIBIOS_SUCCESSFUL; \
-}
-
-#define HP_CFG_WR(sz, bits, name) \
-static int hp_cfg_write##sz (struct pci_dev *dev, int where, u##bits value=
) \
-{ \
-	struct fake_pci_dev *fake_dev; \
-	if (!(fake_dev =3D fake_pci_find_slot(dev->bus->number, dev->devfn))) \
-		return orig_pci_ops->name(dev, where, value); \
-	\
-	switch (where) { \
-	case PCI_BASE_ADDRESS_0: \
-		if (value =3D ~0) \
-			fake_dev->sizing =3D 1; \
-		break; \
-	default: \
-		write##sz(value, fake_dev->mapped_csrs + where); \
-		break; \
-	} \
-	return PCIBIOS_SUCCESSFUL; \
+#define HP_CFG_WR(sz, bits, name)						\
+static int hp_cfg_write##sz (struct pci_dev *dev, int where, u##bits value=
)	\
+{										\
+	struct fake_pci_dev *fake_dev;						\
+										\
+	if (!(fake_dev =3D (struct fake_pci_dev *) dev->sysdata))			\
+		return orig_pci_ops->name(dev, where, value);			\
+										\
+	if (where =3D PCI_BASE_ADDRESS_0) {					\
+		if (value =3D (u##bits) ~0)					\
+			fake_dev->sizing =3D 1;					\
+		return PCIBIOS_SUCCESSFUL;					\
+	} else									\
+		write##sz(value, fake_dev->mapped_csrs + where);		\
+	return PCIBIOS_SUCCESSFUL;						\
 }
=20
 HP_CFG_RD(b,  8, read_byte)
@@ -135,51 +89,86 @@
 	hp_cfg_writel,
 };
=20
-/*
- * Assume we'll never have a physical slot higher than 0x10, so we can
- * use slots above that for "fake" PCI devices to represent things
- * that only show up in the ACPI namespace.
- */
-#define HP_MAX_SLOT	0x10
-
-static struct fake_pci_dev *
-hpzx1_fake_pci_dev(unsigned long addr, unsigned int bus, unsigned int size)
+static void
+hpzx1_fake_pci_dev(char *name, unsigned int busnum, unsigned long addr, un=
signed int size)
 {
-	struct fake_pci_dev *dev;
-	int slot;
+	struct fake_pci_dev *fake;
+	int slot, ret;
+	struct pci_dev *dev;
+	struct pci_bus *b, *bus =3D NULL;
+	u8 hdr;
+
+        fake =3D kmalloc(sizeof(*fake), GFP_KERNEL);
+	if (!fake) {
+		printk(KERN_ERR PFX "No memory for %s (0x%p) sysdata\n", name, (void *) =
addr);
+		return;
+	}
=20
-	// Note: lspci thinks 0x1f is invalid
-	for (slot =3D 0x1e; slot > HP_MAX_SLOT; slot--) {
-		if (!fake_pci_find_slot(bus, PCI_DEVFN(slot, 0)))
+	memset(fake, 0, sizeof(*fake));
+	fake->csr_base =3D addr;
+	fake->csr_size =3D size;
+	fake->mapped_csrs =3D (unsigned long) ioremap(addr, size);
+	fake->sizing =3D 0;
+
+	pci_for_each_bus(b)
+		if (busnum =3D b->number) {
+			bus =3D b;
 			break;
+		}
+
+	if (!bus) {
+		printk(KERN_ERR PFX "No host bus 0x%02x for %s (0x%p)\n",
+		       busnum, name, (void *) addr);
+		kfree(fake);
+		return;
 	}
-	if (slot =3D HP_MAX_SLOT) {
-		printk(KERN_ERR PFX
-			"no slot space for device (0x%p) on bus 0x%02x\n",
-			(void *) addr, bus);
-		return NULL;
+
+	for (slot =3D 0x1e; slot; slot--)
+		if (!pci_find_slot(busnum, PCI_DEVFN(slot, 0)))
+			break;
+
+	if (slot < 0) {
+		printk(KERN_ERR PFX "No space for %s (0x%p) on bus 0x%02x\n",
+		       name, (void *) addr, busnum);
+		kfree(fake);
+		return;
 	}
=20
-	dev =3D alloc_fake_pci_dev();
+        dev =3D kmalloc(sizeof(*dev), GFP_KERNEL);
 	if (!dev) {
-		printk(KERN_ERR PFX
-			"no memory for device (0x%p) on bus 0x%02x\n",
-			(void *) addr, bus);
-		return NULL;
+		printk(KERN_ERR PFX "No memory for %s (0x%p)\n", name, (void *) addr);
+		kfree(fake);
+		return;
 	}
=20
+	bus->ops =3D &hp_pci_conf;	// replace pci ops for this bus
+
+	memset(dev, 0, sizeof(*dev));
 	dev->bus =3D bus;
+	dev->sysdata =3D fake;
+	dev->dev.parent =3D bus->dev;
+	dev->dev.bus =3D &pci_bus_type;
 	dev->devfn =3D PCI_DEVFN(slot, 0);
-	dev->csr_base =3D addr;
-	dev->csr_size =3D size;
+	pci_read_config_word(dev, PCI_VENDOR_ID, &dev->vendor);
+	pci_read_config_word(dev, PCI_DEVICE_ID, &dev->device);
+	pci_read_config_byte(dev, PCI_HEADER_TYPE, &hdr);
+	dev->hdr_type =3D hdr & 0x7f;
+
+	pci_setup_device(dev);
+
+	// pci_insert_device() without running /sbin/hotplug
+	list_add_tail(&dev->bus_list, &bus->devices);
+	list_add_tail(&dev->global_list, &pci_devices);
+
+	strcpy(dev->dev.name, dev->name);
+	strcpy(dev->dev.bus_id, dev->slot_name);
+	ret =3D device_register(&dev->dev);
+	if (ret < 0)
+		printk(KERN_INFO PFX "fake device registration failed (%d)\n", ret);
=20
-	/*
-	 * Drivers should ioremap what they need, but we have to do
-	 * it here, too, so PCI config accesses work.
-	 */
-	dev->mapped_csrs =3D ioremap(dev->csr_base, dev->csr_size);
+	printk(KERN_INFO PFX "%s at 0x%lx; pci dev %s\n", name, addr, dev->slot_n=
ame);
=20
-	return dev;
+	hpzx1_devices++;
 }
=20
 typedef struct {
@@ -189,10 +178,10 @@
 	u8	csr_length[8];
 } acpi_hp_vendor_long;
=20
-#define HP_CCSR_LENGTH 0x21
-#define HP_CCSR_TYPE 0x2
-#define HP_CCSR_GUID EFI_GUID(0x69e9adf9, 0x924f, 0xab5f,			\
-			      0xf6, 0x4a, 0x24, 0xd2, 0x01, 0x37, 0x0e, 0xad)
+#define HP_CCSR_LENGTH	0x21
+#define HP_CCSR_TYPE	0x2
+#define HP_CCSR_GUID	EFI_GUID(0x69e9adf9, 0x924f, 0xab5f,				\
+				 0xf6, 0x4a, 0x24, 0xd2, 0x01, 0x37, 0x0e, 0xad)
=20
 extern acpi_status acpi_get_crs(acpi_handle, acpi_buffer *);
 extern acpi_resource *acpi_get_crs_next(acpi_buffer *, int *);
@@ -213,7 +202,7 @@
 	*csr_length =3D 0;
=20
 	status =3D acpi_get_crs(obj, &buf);
-	if (status !=3D AE_OK) {
+	if (ACPI_FAILURE(status)) {
 		printk(KERN_ERR PFX "Unable to get _CRS data on object\n");
 		return status;
 	}
@@ -254,13 +243,12 @@
 hpzx1_sba_probe(acpi_handle obj, u32 depth, void *context, void **ret)
 {
 	u64 csr_base =3D 0, csr_length =3D 0;
-	char *name =3D context;
-	struct fake_pci_dev *dev;
 	acpi_status status;
+	char *name =3D context;
+	char fullname[16];
=20
 	status =3D hp_csr_space(obj, &csr_base, &csr_length);
-
-	if (status !=3D AE_OK)
+	if (ACPI_FAILURE(status))
 		return status;
=20
 	/*
@@ -268,14 +256,10 @@
 	 * includes both SBA and IOC.  Make SBA and IOC show up
 	 * separately in PCI space.
 	 */
-	if ((dev =3D hpzx1_fake_pci_dev(csr_base, 0, 0x1000)))
-		printk(KERN_INFO PFX "%s SBA at 0x%lx; pci dev %02x:%02x.%d\n",
-			name, csr_base, dev->bus,
-			PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
-	if ((dev =3D hpzx1_fake_pci_dev(csr_base + 0x1000, 0, 0x1000)))
-		printk(KERN_INFO PFX "%s IOC at 0x%lx; pci dev %02x:%02x.%d\n",
-			name, csr_base + 0x1000, dev->bus,
-			PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
+	sprintf(fullname, "%s SBA", name);
+	hpzx1_fake_pci_dev(fullname, 0, csr_base, 0x1000);
+	sprintf(fullname, "%s IOC", name);
+	hpzx1_fake_pci_dev(fullname, 0, csr_base + 0x1000, 0x1000);
=20
 	return AE_OK;
 }
@@ -283,28 +267,24 @@
 static acpi_status
 hpzx1_lba_probe(acpi_handle obj, u32 depth, void *context, void **ret)
 {
-	acpi_status status;
 	u64 csr_base =3D 0, csr_length =3D 0;
+	acpi_status status;
+	NATIVE_UINT busnum;
 	char *name =3D context;
-	NATIVE_UINT busnum =3D 0;
-	struct fake_pci_dev *dev;
+	char fullname[32];
=20
 	status =3D hp_csr_space(obj, &csr_base, &csr_length);
-
-	if (status !=3D AE_OK)
+	if (ACPI_FAILURE(status))
 		return status;
=20
 	status =3D acpi_evaluate_integer(obj, METHOD_NAME__BBN, NULL, &busnum);
 	if (ACPI_FAILURE(status)) {
-		printk(KERN_ERR PFX "evaluate _BBN fail=3D0x%x\n", status);
+		printk(KERN_WARNING PFX "evaluate _BBN fail=3D0x%x\n", status);
 		busnum =3D 0;	// no _BBN; stick it on bus 0
 	}
=20
-	if ((dev =3D hpzx1_fake_pci_dev(csr_base, busnum, csr_length)))
-		printk(KERN_INFO PFX "%s LBA at 0x%lx, _BBN 0x%02x; "
-			"pci dev %02x:%02x.%d\n",
-			name, csr_base, busnum, dev->bus,
-			PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
+	sprintf(fullname, "%s _BBN 0x%02x", name, (unsigned int) busnum);
+	hpzx1_fake_pci_dev(fullname, busnum, csr_base, csr_length);
=20
 	return AE_OK;
 }
@@ -314,6 +294,8 @@
 {
 	extern struct pci_ops *pci_root_ops;
=20
+	orig_pci_ops =3D pci_root_ops;
+
 	/*
 	 * Make fake PCI devices for the following hardware in the
 	 * ACPI namespace.  This makes it more convenient for drivers
@@ -328,10 +310,10 @@
 	 */
 	acpi_get_devices("HWP0001", hpzx1_sba_probe, "HWP0001", NULL);
 #ifdef CONFIG_IA64_HP_PROTO
-	if (fake_pci_tail !=3D &fake_pci_head) {
+	if (hpzx1_devices) {
 #endif
-	acpi_get_devices("HWP0002", hpzx1_lba_probe, "HWP0002", NULL);
-	acpi_get_devices("HWP0003", hpzx1_lba_probe, "HWP0003", NULL);
+	acpi_get_devices("HWP0002", hpzx1_lba_probe, "HWP0002 PCI LBA", NULL);
+	acpi_get_devices("HWP0003", hpzx1_lba_probe, "HWP0003 AGP LBA", NULL);
=20
 #ifdef CONFIG_IA64_HP_PROTO
 	}
@@ -342,48 +324,25 @@
 	 * if we didn't find anything, add the things we know are
 	 * there.
 	 */
-	if (fake_pci_tail =3D &fake_pci_head) {
+	if (hpzx1_devices =3D 0) {
 		u64 hpa, csr_base;
-		struct fake_pci_dev *dev;
=20
 		csr_base =3D 0xfed00000UL;
-		hpa =3D (u64) ioremap(csr_base, 0x1000);
+		hpa =3D (u64) ioremap(csr_base, 0x2000);
 		if (__raw_readl(hpa) =3D ZX1_FUNC_ID_VALUE) {
-			if ((dev =3D hpzx1_fake_pci_dev(csr_base, 0, 0x1000)))
-				printk(KERN_INFO PFX "HWP0001 SBA at 0x%lx; "
-					"pci dev %02x:%02x.%d\n", csr_base,
-					dev->bus, PCI_SLOT(dev->devfn),
-					PCI_FUNC(dev->devfn));
-			if ((dev =3D hpzx1_fake_pci_dev(csr_base + 0x1000, 0,
-					0x1000)))
-				printk(KERN_INFO PFX "HWP0001 IOC at 0x%lx; "
-					"pci dev %02x:%02x.%d\n",
-					csr_base + 0x1000,
-					dev->bus, PCI_SLOT(dev->devfn),
-					PCI_FUNC(dev->devfn));
+			hpzx1_fake_pci_dev("HWP0001 SBA", 0, csr_base, 0x1000);
+			hpzx1_fake_pci_dev("HWP0001 IOC", 0, csr_base + 0x1000,
+					    0x1000);
=20
 			csr_base =3D 0xfed24000UL;
 			iounmap(hpa);
 			hpa =3D (u64) ioremap(csr_base, 0x1000);
-			if ((dev =3D hpzx1_fake_pci_dev(csr_base, 0x40, 0x1000)))
-				printk(KERN_INFO PFX "HWP0003 AGP LBA at "
-					"0x%lx; pci dev %02x:%02x.%d\n",
-					csr_base,
-					dev->bus, PCI_SLOT(dev->devfn),
-					PCI_FUNC(dev->devfn));
+			hpzx1_fake_pci_dev("HWP0003 AGP LBA", 0x40, csr_base,
+					    0x1000);
 		}
 		iounmap(hpa);
 	}
 #endif
-
-	if (fake_pci_tail =3D &fake_pci_head)
-		return;
-
-	/*
-	 * Replace PCI ops, but only if we made fake devices.
-	 */
-	orig_pci_ops =3D pci_root_ops;
-	pci_root_ops =3D &hp_pci_conf;
 }
=20
 extern void sba_init(void);
@@ -391,9 +350,16 @@
 void
 hpzx1_pci_fixup (int phase)
 {
-	if (phase =3D 0)
-		hpzx1_acpi_dev_init();
 	iosapic_pci_fixup(phase);
-        if (phase =3D 1)
+	switch (phase) {
+	      case 0:
+		/* zx1 has a hardware I/O TLB which lets us DMA from any device to any a=
ddress */
+		MAX_DMA_ADDRESS =3D ~0UL;
+		break;
+
+	      case 1:
+		hpzx1_acpi_dev_init();
 		sba_init();
+		break;
+	}
 }
diff -Nru a/arch/ia64/ia32/binfmt_elf32.c b/arch/ia64/ia32/binfmt_elf32.c
--- a/arch/ia64/ia32/binfmt_elf32.c	Sat Aug 10 01:51:47 2002
+++ b/arch/ia64/ia32/binfmt_elf32.c	Sat Aug 10 01:51:47 2002
@@ -67,7 +67,7 @@
 }
=20
 static struct vm_operations_struct ia32_shared_page_vm_ops =3D {
-	nopage:	ia32_install_shared_page
+	.nopage =3Dia32_install_shared_page
 };
=20
 void
diff -Nru a/arch/ia64/ia32/ia32_ioctl.c b/arch/ia64/ia32/ia32_ioctl.c
--- a/arch/ia64/ia32/ia32_ioctl.c	Sat Aug 10 01:51:47 2002
+++ b/arch/ia64/ia32/ia32_ioctl.c	Sat Aug 10 01:51:47 2002
@@ -30,6 +30,8 @@
 #include <asm/ia32.h>
=20
 #include <../drivers/char/drm/drm.h>
+#include <../drivers/char/drm/mga_drm.h>
+#include <../drivers/char/drm/i810_drm.h>
=20
=20
 #define IOCTL_NR(a)	((a) & ~(_IOC_SIZEMASK << _IOC_SIZESHIFT))
diff -Nru a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/acpi.c	Sat Aug 10 01:51:46 2002
@@ -56,16 +56,19 @@
 void (*pm_idle) (void);
 void (*pm_power_off) (void);
=20
+unsigned char acpi_kbd_controller_present =3D 1;
+
 const char *
 acpi_get_sysname (void)
 {
 #ifdef CONFIG_IA64_GENERIC
-	unsigned long rsdp_phys =3D 0;
+	unsigned long rsdp_phys;
 	struct acpi20_table_rsdp *rsdp;
 	struct acpi_table_xsdt *xsdt;
 	struct acpi_table_header *hdr;
=20
-	if ((0 !=3D acpi_find_rsdp(&rsdp_phys)) || !rsdp_phys) {
+	rsdp_phys =3D acpi_find_rsdp();
+	if (!rsdp_phys) {
 		printk("ACPI 2.0 RSDP not found, default to \"dig\"\n");
 		return "dig";
 	}
@@ -99,6 +102,8 @@
 	return "sn2";
 # elif defined (CONFIG_IA64_DIG)
 	return "dig";
+# elif defined (CONFIG_IA64_HP_ZX1)
+	return "hpzx1";
 # else
 #	error Unknown platform.  Fix acpi.c.
 # endif
@@ -130,9 +135,7 @@
 	if (!buf->pointer)
 		return -ENOMEM;
=20
-	result =3D acpi_get_current_resources(obj, buf);
-
-	return result;
+	return acpi_get_current_resources(obj, buf);
 }
=20
 acpi_resource *
@@ -175,6 +178,8 @@
 /* Array to record platform interrupt vectors for generic interrupt routin=
g. */
 int platform_irq_list[ACPI_MAX_PLATFORM_IRQS] =3D { [0 ... ACPI_MAX_PLATFO=
RM_IRQS - 1] =3D -1 };
=20
+enum acpi_irq_model_id acpi_irq_model =3D ACPI_IRQ_MODEL_IOSAPIC;
+
 /*
  * Interrupt routing API for device drivers.  Provides interrupt vector for
  * a generic platform event.  Currently only CPEI is implemented.
@@ -189,10 +194,14 @@
 		vector =3D platform_irq_list[int_type];
 	} else
 		printk("acpi_request_vector(): invalid interrupt type\n");
-
 	return vector;
 }
=20
+char *
+__acpi_map_table (unsigned long phys_addr, unsigned long size)
+{
+	return __va(phys_addr);
+}
=20
 /* -----------------------------------------------------------------------=
---
                             Boot-time Table Parsing
@@ -206,7 +215,7 @@
 static int __init
 acpi_parse_lapic_addr_ovr (acpi_table_entry_header *header)
 {
-	struct acpi_table_lapic_addr_ovr *lapic =3D NULL;
+	struct acpi_table_lapic_addr_ovr *lapic;
=20
 	lapic =3D (struct acpi_table_lapic_addr_ovr *) header;
 	if (!lapic)
@@ -218,7 +227,6 @@
 		iounmap((void *) ipi_base_addr);
 		ipi_base_addr =3D (unsigned long) ioremap(lapic->address, 0);
 	}
-
 	return 0;
 }
=20
@@ -226,7 +234,7 @@
 static int __init
 acpi_parse_lsapic (acpi_table_entry_header *header)
 {
-	struct acpi_table_lsapic *lsapic =3D NULL;
+	struct acpi_table_lsapic *lsapic;
=20
 	lsapic =3D (struct acpi_table_lsapic *) header;
 	if (!lsapic)
@@ -262,7 +270,7 @@
 static int __init
 acpi_parse_lapic_nmi (acpi_table_entry_header *header)
 {
-	struct acpi_table_lapic_nmi *lacpi_nmi =3D NULL;
+	struct acpi_table_lapic_nmi *lacpi_nmi;
=20
 	lacpi_nmi =3D (struct acpi_table_lapic_nmi*) header;
 	if (!lacpi_nmi)
@@ -271,7 +279,6 @@
 	acpi_table_print_madt_entry(header);
=20
 	/* TBD: Support lapic_nmi entries */
-
 	return 0;
 }
=20
@@ -279,11 +286,11 @@
 static int __init
 acpi_find_iosapic (int global_vector, u32 *irq_base, char **iosapic_addres=
s)
 {
-	struct acpi_table_iosapic *iosapic =3D NULL;
-	int ver =3D 0;
-	int max_pin =3D 0;
-	char *p =3D 0;
-	char *end =3D 0;
+	struct acpi_table_iosapic *iosapic;
+	int ver;
+	int max_pin;
+	char *p;
+	char *end;
=20
 	if (!irq_base || !iosapic_address)
 		return -ENODEV;
@@ -338,10 +345,10 @@
 static int __init
 acpi_parse_plat_int_src (acpi_table_entry_header *header)
 {
-	struct acpi_table_plat_int_src *plintsrc =3D NULL;
-	int vector =3D 0;
-	u32 irq_base =3D 0;
-	char *iosapic_address =3D NULL;
+	struct acpi_table_plat_int_src *plintsrc;
+	int vector;
+	u32 irq_base;
+	char *iosapic_address;
=20
 	plintsrc =3D (struct acpi_table_plat_int_src *) header;
 	if (!plintsrc)
@@ -354,7 +361,7 @@
 		return -ENODEV;
 	}
=20
-	if (0 !=3D acpi_find_iosapic(plintsrc->global_irq, &irq_base, &iosapic_ad=
dress)) {
+	if (acpi_find_iosapic(plintsrc->global_irq, &irq_base, &iosapic_address))=
 {
 		printk(KERN_WARNING PREFIX "IOSAPIC not found\n");
 		return -ENODEV;
 	}
@@ -363,15 +370,15 @@
 	 * Get vector assignment for this IRQ, set attributes, and program the
 	 * IOSAPIC routing table.
 	 */
-	vector =3D iosapic_register_platform_irq (plintsrc->type,
-						plintsrc->global_irq,
-						plintsrc->iosapic_vector,
-						plintsrc->eid,
-						plintsrc->id,
-						(plintsrc->flags.polarity =3D 1) ? 1 : 0,
-						(plintsrc->flags.trigger =3D 1) ? 1 : 0,
-						irq_base,
-						iosapic_address);
+	vector =3D iosapic_register_platform_irq(plintsrc->type,
+					       plintsrc->global_irq,
+					       plintsrc->iosapic_vector,
+					       plintsrc->eid,
+					       plintsrc->id,
+					       (plintsrc->flags.polarity =3D 1) ? 1 : 0,
+					       (plintsrc->flags.trigger =3D 1) ? 1 : 0,
+					       irq_base,
+					       iosapic_address);
=20
 	platform_irq_list[plintsrc->type] =3D vector;
 	return 0;
@@ -381,7 +388,7 @@
 static int __init
 acpi_parse_int_src_ovr (acpi_table_entry_header *header)
 {
-	struct acpi_table_int_src_ovr *p =3D NULL;
+	struct acpi_table_int_src_ovr *p;
=20
 	p =3D (struct acpi_table_int_src_ovr *) header;
 	if (!p)
@@ -394,9 +401,8 @@
 		return 0;
=20
 	iosapic_register_legacy_irq(p->bus_irq, p->global_irq,
-		(p->flags.polarity =3D 1) ? 1 : 0,
-		(p->flags.trigger =3D 1) ? 1 : 0);
-
+				    (p->flags.polarity =3D 1) ? 1 : 0,
+				    (p->flags.trigger =3D 1) ? 1 : 0);
 	return 0;
 }
=20
@@ -404,7 +410,7 @@
 static int __init
 acpi_parse_nmi_src (acpi_table_entry_header *header)
 {
-	struct acpi_table_nmi_src *nmi_src =3D NULL;
+	struct acpi_table_nmi_src *nmi_src;
=20
 	nmi_src =3D (struct acpi_table_nmi_src*) header;
 	if (!nmi_src)
@@ -413,7 +419,6 @@
 	acpi_table_print_madt_entry(header);
=20
 	/* TBD: Support nimsrc entries */
-
 	return 0;
 }
=20
@@ -425,50 +430,59 @@
 		return -EINVAL;
=20
 	acpi_madt =3D (struct acpi_table_madt *) __va(phys_addr);
-	if (!acpi_madt) {
-		printk(KERN_WARNING PREFIX "Unable to map MADT\n");
-		return -ENODEV;
-	}
=20
 	/* Get base address of IPI Message Block */
=20
 	if (acpi_madt->lapic_address)
-		ipi_base_addr =3D (unsigned long)
-			ioremap(acpi_madt->lapic_address, 0);
+		ipi_base_addr =3D (unsigned long) ioremap(acpi_madt->lapic_address, 0);
=20
 	printk(KERN_INFO PREFIX "Local APIC address 0x%lx\n", ipi_base_addr);
-
 	return 0;
 }
=20
-
-int __init
-acpi_find_rsdp (unsigned long *rsdp_phys)
+static int __init
+acpi_parse_fadt (unsigned long phys_addr, unsigned long size)
 {
-	if (!rsdp_phys)
+	struct acpi_table_header *fadt_header;
+	fadt_descriptor_rev2 *fadt;
+
+	if (!phys_addr || !size)
 		return -EINVAL;
=20
-	if (efi.acpi20) {
-		(*rsdp_phys) =3D __pa(efi.acpi20);
-		return 0;
-	}
-	else if (efi.acpi) {
-		printk(KERN_WARNING PREFIX "v1.0/r0.71 tables no longer supported\n");
-	}
+	fadt_header =3D (struct acpi_table_header *) __va(phys_addr);
+	if (fadt_header->revision !=3D 3)
+		return -ENODEV;		/* Only deal with ACPI 2.0 FADT */
=20
-	return -ENODEV;
+	fadt =3D (fadt_descriptor_rev2 *) fadt_header;
+
+	if (!(fadt->iapc_boot_arch & BAF_8042_KEYBOARD_CONTROLLER))
+		acpi_kbd_controller_present =3D 0;
+
+	return 0;
+}
+
+unsigned long __init
+acpi_find_rsdp (void)
+{
+	unsigned long rsdp_phys =3D 0;
+
+	if (efi.acpi20)
+		rsdp_phys =3D __pa(efi.acpi20);
+	else if (efi.acpi)
+		printk(KERN_WARNING PREFIX "v1.0/r0.71 tables no longer supported\n");
+	return rsdp_phys;
 }
=20
=20
-#ifdef CONFIG_SERIAL_ACPI
+#ifdef CONFIG_SERIAL_8250_ACPI
=20
 #include <linux/acpi_serial.h>
=20
 static int __init
 acpi_parse_spcr (unsigned long phys_addr, unsigned long size)
 {
-	acpi_ser_t *spcr =3D NULL;
-	unsigned long global_int =3D 0;
+	acpi_ser_t *spcr;
+	unsigned long global_int;
=20
 	if (!phys_addr || !size)
 		return -EINVAL;
@@ -486,11 +500,6 @@
 	 */
=20
 	spcr =3D (acpi_ser_t *) __va(phys_addr);
-	if (!spcr) {
-		printk(KERN_WARNING PREFIX "Unable to map SPCR\n");
-		return -ENODEV;
-	}
-
 	setup_serial_acpi(spcr);
=20
 	if (spcr->length < sizeof(acpi_ser_t))
@@ -500,38 +509,37 @@
 	if ((spcr->base_addr.space_id !=3D ACPI_SERIAL_PCICONF_SPACE) &&
 	    (spcr->int_type =3D ACPI_SERIAL_INT_SAPIC))
 	{
-		u32 irq_base =3D 0;
-		char *iosapic_address =3D NULL;
-		int vector =3D 0;
+		u32 irq_base;
+		char *iosapic_address;
+		int vector;
=20
 		/* We have a UART in memory space with an SAPIC interrupt */
=20
-		global_int =3D (  (spcr->global_int[3] << 24) |
-				(spcr->global_int[2] << 16) |
-				(spcr->global_int[1] << 8)  |
-				(spcr->global_int[0])  );
+		global_int =3D ((spcr->global_int[3] << 24) |
+			      (spcr->global_int[2] << 16) |
+			      (spcr->global_int[1] << 8)  |
+			      (spcr->global_int[0])  );
=20
 		/* Which iosapic does this IRQ belong to? */
=20
-		if (0 =3D acpi_find_iosapic(global_int, &irq_base, &iosapic_address)) {
-			vector =3D iosapic_register_irq (global_int, 1, 1,
-						       irq_base, iosapic_address);
-		}
+		if (!acpi_find_iosapic(global_int, &irq_base, &iosapic_address))
+			vector =3D iosapic_register_irq(global_int, 1, 1,
+						      irq_base, iosapic_address);
 	}
 	return 0;
 }
=20
-#endif /*CONFIG_SERIAL_ACPI*/
+#endif /* CONFIG_SERIAL_8250_ACPI */
=20
=20
 int __init
 acpi_boot_init (char *cmdline)
 {
-	int result =3D 0;
+	int result;
=20
 	/* Initialize the ACPI boot-time table parser */
 	result =3D acpi_table_init(cmdline);
-	if (0 !=3D result)
+	if (result)
 		return result;
=20
 	/*
@@ -542,59 +550,44 @@
 	 * information -- the successor to MPS tables.
 	 */
=20
-	result =3D acpi_table_parse(ACPI_APIC, acpi_parse_madt);
-	if (1 > result)
-		return result;
+	if (acpi_table_parse(ACPI_APIC, acpi_parse_madt) < 1) {
+		printk(KERN_ERR PREFIX "Can't find MADT\n");
+		goto skip_madt;
+	}
=20
 	/* Local APIC */
=20
-	result =3D acpi_table_parse_madt(ACPI_MADT_LAPIC_ADDR_OVR, acpi_parse_lap=
ic_addr_ovr);
-	if (0 > result) {
+	if (acpi_table_parse_madt(ACPI_MADT_LAPIC_ADDR_OVR, acpi_parse_lapic_addr=
_ovr) < 0)
 		printk(KERN_ERR PREFIX "Error parsing LAPIC address override entry\n");
-		return result;
-	}
=20
-	result =3D acpi_table_parse_madt(ACPI_MADT_LSAPIC, acpi_parse_lsapic);
-	if (1 > result) {
-		printk(KERN_ERR PREFIX "Error parsing MADT - no LAPIC entries!\n");
-		return -ENODEV;
-	}
+	if (acpi_table_parse_madt(ACPI_MADT_LSAPIC, acpi_parse_lsapic) < 1)
+		printk(KERN_ERR PREFIX "Error parsing MADT - no LAPIC entries\n");
=20
-	result =3D acpi_table_parse_madt(ACPI_MADT_LAPIC_NMI, acpi_parse_lapic_nm=
i);
-	if (0 > result) {
+	if (acpi_table_parse_madt(ACPI_MADT_LAPIC_NMI, acpi_parse_lapic_nmi) < 0)
 		printk(KERN_ERR PREFIX "Error parsing LAPIC NMI entry\n");
-		return result;
-	}
=20
 	/* I/O APIC */
=20
-	result =3D acpi_table_parse_madt(ACPI_MADT_IOSAPIC, acpi_parse_iosapic);
-	if (1 > result) {
-		printk(KERN_ERR PREFIX "Error parsing MADT - no IOAPIC entries!\n");
-		return ((result =3D 0) ? -ENODEV : result);
-	}
+	if (acpi_table_parse_madt(ACPI_MADT_IOSAPIC, acpi_parse_iosapic) < 1)
+		printk(KERN_ERR PREFIX "Error parsing MADT - no IOSAPIC entries\n");
=20
 	/* System-Level Interrupt Routing */
=20
-	result =3D acpi_table_parse_madt(ACPI_MADT_PLAT_INT_SRC, acpi_parse_plat_=
int_src);
-	if (0 > result) {
+	if (acpi_table_parse_madt(ACPI_MADT_PLAT_INT_SRC, acpi_parse_plat_int_src=
) < 0)
 		printk(KERN_ERR PREFIX "Error parsing platform interrupt source entry\n"=
);
-		return result;
-	}
=20
-	result =3D acpi_table_parse_madt(ACPI_MADT_INT_SRC_OVR, acpi_parse_int_sr=
c_ovr);
-	if (0 > result) {
+	if (acpi_table_parse_madt(ACPI_MADT_INT_SRC_OVR, acpi_parse_int_src_ovr) =
< 0)
 		printk(KERN_ERR PREFIX "Error parsing interrupt source overrides entry\n=
");
-		return result;
-	}
=20
-	result =3D acpi_table_parse_madt(ACPI_MADT_NMI_SRC, acpi_parse_nmi_src);
-	if (0 > result) {
+	if (acpi_table_parse_madt(ACPI_MADT_NMI_SRC, acpi_parse_nmi_src) < 0)
 		printk(KERN_ERR PREFIX "Error parsing NMI SRC entry\n");
-		return result;
-	}
+  skip_madt:
+
+	/* FADT says whether a legacy keyboard controller is present. */
+	if (acpi_table_parse(ACPI_FACP, acpi_parse_fadt) < 1)
+		printk(KERN_ERR PREFIX "Can't find FADT\n");
=20
-#ifdef CONFIG_SERIAL_ACPI
+#ifdef CONFIG_SERIAL_8250_ACPI
 	/*
 	 * TBD: Need phased approach to table parsing (only do those absolutely
 	 *      required during boot-up).  Recommend expanding concept of fix-
@@ -602,7 +595,7 @@
 	 *      serial ports, EC, SMBus, etc.
 	 */
 	acpi_table_parse(ACPI_SPCR, acpi_parse_spcr);
-#endif /*CONFIG_SERIAL_ACPI*/
+#endif
=20
 #ifdef CONFIG_SMP
 	if (available_cpus =3D 0) {
@@ -613,7 +606,6 @@
 #endif
 	/* Make boot-up look pretty */
 	printk("%d CPUs available, %d CPUs total\n", available_cpus, total_cpus);
-
 	return 0;
 }
=20
@@ -625,9 +617,9 @@
 int __init
 acpi_get_prt (struct pci_vector_struct **vectors, int *count)
 {
-	struct pci_vector_struct *vector =3D NULL;
-	struct list_head *node =3D NULL;
-	struct acpi_prt_entry *entry =3D NULL;
+	struct pci_vector_struct *vector;
+	struct list_head *node;
+	struct acpi_prt_entry *entry;
 	int i =3D 0;
=20
 	if (!vectors || !count)
@@ -636,14 +628,14 @@
 	*vectors =3D NULL;
 	*count =3D 0;
=20
-	if (acpi_prts.count <=3D 0) {
+	if (acpi_prt.count < 0) {
 		printk(KERN_ERR PREFIX "No PCI IRQ routing entries\n");
 		return -ENODEV;
 	}
=20
 	/* Allocate vectors */
=20
-	*vectors =3D kmalloc(sizeof(struct pci_vector_struct) * acpi_prts.count, =
GFP_KERNEL);
+	*vectors =3D kmalloc(sizeof(struct pci_vector_struct) * acpi_prt.count, G=
FP_KERNEL);
 	if (!(*vectors))
 		return -ENOMEM;
=20
@@ -651,15 +643,15 @@
=20
 	vector =3D *vectors;
=20
-	list_for_each(node, &acpi_prts.entries) {
+	list_for_each(node, &acpi_prt.entries) {
 		entry =3D (struct acpi_prt_entry *)node;
 		vector[i].bus    =3D entry->id.bus;
-		vector[i].pci_id =3D ((u32) entry->id.dev << 16) | 0xffff;
-		vector[i].pin    =3D entry->id.pin;
-		vector[i].irq    =3D entry->source.index;
+		vector[i].pci_id =3D ((u32) entry->id.device << 16) | 0xffff;
+		vector[i].pin    =3D entry->pin;
+		vector[i].irq    =3D entry->link.index;
 		i++;
 	}
-	*count =3D acpi_prts.count;
+	*count =3D acpi_prt.count;
 	return 0;
 }
=20
@@ -671,8 +663,7 @@
         if (!type)
                 return -EINVAL;
=20
-	*type =3D ACPI_INT_MODEL_IOSAPIC;
-
+	*type =3D ACPI_IRQ_MODEL_IOSAPIC;
         return 0;
 }
=20
diff -Nru a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/efi.c	Sat Aug 10 01:51:46 2002
@@ -125,9 +125,79 @@
 	tv->tv_usec =3D tm.nanosecond / 1000;
 }
=20
+static int
+is_available_memory (efi_memory_desc_t *md)
+{
+	if (!(md->attribute & EFI_MEMORY_WB))
+		return 0;
+
+	switch (md->type) {
+	      case EFI_LOADER_CODE:
+	      case EFI_LOADER_DATA:
+	      case EFI_BOOT_SERVICES_CODE:
+	      case EFI_BOOT_SERVICES_DATA:
+	      case EFI_CONVENTIONAL_MEMORY:
+		return 1;
+	}
+	return 0;
+}
+
 /*
- * Walks the EFI memory map and calls CALLBACK once for each EFI
- * memory descriptor that has memory that is available for OS use.
+ * Trim descriptor MD so its starts at address START_ADDR.  If the descrip=
tor covers
+ * memory that is normally available to the kernel, issue a warning that s=
ome memory
+ * is being ignored.
+ */
+static void
+trim_bottom (efi_memory_desc_t *md, u64 start_addr)
+{
+	u64 num_skipped_pages;
+
+	if (md->phys_addr >=3D start_addr || !md->num_pages)
+		return;
+
+	num_skipped_pages =3D (start_addr - md->phys_addr) >> EFI_PAGE_SHIFT;
+	if (num_skipped_pages > md->num_pages)
+		num_skipped_pages =3D md->num_pages;
+
+	if (is_available_memory(md))
+		printk(KERN_NOTICE "efi.%s: ignoring %luKB of memory at 0x%lx due to gra=
nule hole "
+		       "at 0x%lx\n", __FUNCTION__,
+		       (num_skipped_pages << EFI_PAGE_SHIFT) >> 10,
+		       md->phys_addr, start_addr - IA64_GRANULE_SIZE);
+	/*
+	 * NOTE: Don't set md->phys_addr to START_ADDR because that could cause t=
he memory
+	 * descriptor list to become unsorted.  In such a case, md->num_pages wil=
l be
+	 * zero, so the Right Thing will happen.
+	 */
+	md->phys_addr +=3D num_skipped_pages << EFI_PAGE_SHIFT;
+	md->num_pages -=3D num_skipped_pages;
+}
+
+static void
+trim_top (efi_memory_desc_t *md, u64 end_addr)
+{
+	u64 num_dropped_pages, md_end_addr;
+
+	md_end_addr =3D md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT);
+
+	if (md_end_addr <=3D end_addr || !md->num_pages)
+		return;
+
+	num_dropped_pages =3D (md_end_addr - end_addr) >> EFI_PAGE_SHIFT;
+	if (num_dropped_pages > md->num_pages)
+		num_dropped_pages =3D md->num_pages;
+
+	if (is_available_memory(md))
+		printk(KERN_NOTICE "efi.%s: ignoring %luKB of memory at 0x%lx due to gra=
nule hole "
+		       "at 0x%lx\n", __FUNCTION__,
+		       (num_dropped_pages << EFI_PAGE_SHIFT) >> 10,
+		       md->phys_addr, end_addr);
+	md->num_pages -=3D num_dropped_pages;
+}
+
+/*
+ * Walks the EFI memory map and calls CALLBACK once for each EFI memory de=
scriptor that
+ * has memory that is available for OS use.
  */
 void
 efi_memmap_walk (efi_freemem_callback_t callback, void *arg)
@@ -137,9 +207,9 @@
 		u64 start;
 		u64 end;
 	} prev, curr;
-	void *efi_map_start, *efi_map_end, *p;
-	efi_memory_desc_t *md;
-	u64 efi_desc_size, start, end;
+	void *efi_map_start, *efi_map_end, *p, *q;
+	efi_memory_desc_t *md, *check_md;
+	u64 efi_desc_size, start, end, granule_addr, first_non_wb_addr =3D 0;
=20
 	efi_map_start =3D __va(ia64_boot_param->efi_memmap);
 	efi_map_end   =3D efi_map_start + ia64_boot_param->efi_memmap_size;
@@ -147,24 +217,56 @@
=20
 	for (p =3D efi_map_start; p < efi_map_end; p +=3D efi_desc_size) {
 		md =3D p;
-		switch (md->type) {
-		      case EFI_LOADER_CODE:
-		      case EFI_LOADER_DATA:
-		      case EFI_BOOT_SERVICES_CODE:
-		      case EFI_BOOT_SERVICES_DATA:
-		      case EFI_CONVENTIONAL_MEMORY:
-			if (!(md->attribute & EFI_MEMORY_WB))
-				continue;
+
+		/* skip over non-WB memory descriptors; that's all we're interested in..=
. */
+		if (!(md->attribute & EFI_MEMORY_WB))
+			continue;
+
+		if (md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) > first_non_wb_add=
r) {
+			/*
+			 * Search for the next run of contiguous WB memory.  Start search
+			 * at first granule boundary covered by md.
+			 */
+			granule_addr =3D ((md->phys_addr + IA64_GRANULE_SIZE - 1)
+					& -IA64_GRANULE_SIZE);
+			first_non_wb_addr =3D granule_addr;
+			for (q =3D p; q < efi_map_end; q +=3D efi_desc_size) {
+				check_md =3D q;
+
+				if (check_md->attribute & EFI_MEMORY_WB)
+					trim_bottom(md, granule_addr);
+
+				if (check_md->phys_addr < granule_addr)
+					continue;
+
+				if (!(check_md->attribute & EFI_MEMORY_WB))
+					break;	/* hit a non-WB region; stop search */
+
+				if (check_md->phys_addr !=3D first_non_wb_addr)
+					break;	/* hit a memory hole; stop search */
+
+				first_non_wb_addr +=3D check_md->num_pages << EFI_PAGE_SHIFT;
+			}
+			/* round it down to the previous granule-boundary: */
+			first_non_wb_addr &=3D -IA64_GRANULE_SIZE;
+
+			if (!(first_non_wb_addr > granule_addr))
+				continue;	/* couldn't find enough contiguous memory */
+		}
+
+		/* BUG_ON((md->phys_addr >> IA64_GRANULE_SHIFT) < first_non_wb_addr); */
+
+		trim_top(md, first_non_wb_addr);
+
+		if (is_available_memory(md)) {
 			if (md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) > mem_limit) {
 				if (md->phys_addr > mem_limit)
 					continue;
 				md->num_pages =3D (mem_limit - md->phys_addr) >> EFI_PAGE_SHIFT;
 			}
-			if (md->num_pages =3D 0) {
-				printk("efi_memmap_walk: ignoring empty region at 0x%lx",
-				       md->phys_addr);
+
+			if (md->num_pages =3D 0)
 				continue;
-			}
=20
 			curr.start =3D PAGE_OFFSET + md->phys_addr;
 			curr.end   =3D curr.start + (md->num_pages << EFI_PAGE_SHIFT);
@@ -187,10 +289,6 @@
 					prev =3D curr;
 				}
 			}
-			break;
-
-		      default:
-			continue;
 		}
 	}
 	if (prev_valid) {
@@ -268,8 +366,9 @@
 		 */
 		psr =3D ia64_clear_ic();
 		ia64_itr(0x1, IA64_TR_PALCODE, vaddr & mask,
-			 pte_val(pfn_pte(md->phys_addr >> PAGE_SHIFT, PAGE_KERNEL)), IA64_GRANU=
LE_SHIFT);
-		ia64_set_psr(psr);
+			 pte_val(pfn_pte(md->phys_addr >> PAGE_SHIFT, PAGE_KERNEL)),
+			 IA64_GRANULE_SHIFT);
+		ia64_set_psr(psr);		/* restore psr */
 		ia64_srlz_i();
 	}
 }
@@ -347,6 +446,9 @@
 		} else if (efi_guidcmp(config_tables[i].guid, SAL_SYSTEM_TABLE_GUID) =3D=
 0) {
 			efi.sal_systab =3D __va(config_tables[i].table);
 			printk(" SALsystab=3D0x%lx", config_tables[i].table);
+		} else if (efi_guidcmp(config_tables[i].guid, HCDP_TABLE_GUID) =3D 0) {
+			efi.hcdp =3D __va(config_tables[i].table);
+			printk(" HCDP=3D0x%lx", config_tables[i].table);
 		}
 	}
 	printk("\n");
@@ -376,7 +478,7 @@
 			md =3D p;
 			printk("mem%02u: type=3D%u, attr=3D0x%lx, range=3D[0x%016lx-0x%016lx) (=
%luMB)\n",
 			       i, md->type, md->attribute, md->phys_addr,
-			       md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) - 1,
+			       md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT),
 			       md->num_pages >> (20 - EFI_PAGE_SHIFT));
 		}
 	}
diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/entry.S	Sat Aug 10 01:51:46 2002
@@ -175,6 +175,7 @@
 (p6)	srlz.d
 	ld8 sp=3D[r21]			// load kernel stack pointer of new task
 	mov IA64_KR(CURRENT)=3Dr20	// update "current" application register
+	mov r8=3Dr13			// return pointer to previously running task
 	mov r13=3Din0			// set "current" pointer
 	;;
 	DO_LOAD_SWITCH_STACK
diff -Nru a/arch/ia64/kernel/ia64_ksyms.c b/arch/ia64/kernel/ia64_ksyms.c
--- a/arch/ia64/kernel/ia64_ksyms.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/ia64_ksyms.c	Sat Aug 10 01:51:46 2002
@@ -88,12 +88,6 @@
 #include <asm/smplock.h>
 EXPORT_SYMBOL(kernel_flag);
=20
-/* #include <asm/system.h> */
-EXPORT_SYMBOL(__global_sti);
-EXPORT_SYMBOL(__global_cli);
-EXPORT_SYMBOL(__global_save_flags);
-EXPORT_SYMBOL(__global_restore_flags);
-
 #else /* !CONFIG_SMP */
=20
 EXPORT_SYMBOL(__flush_tlb_all);
diff -Nru a/arch/ia64/kernel/init_task.c b/arch/ia64/kernel/init_task.c
--- a/arch/ia64/kernel/init_task.c	Sat Aug 10 01:51:47 2002
+++ b/arch/ia64/kernel/init_task.c	Sat Aug 10 01:51:47 2002
@@ -34,8 +34,8 @@
 	} s;
 	unsigned long stack[KERNEL_STACK_SIZE/sizeof (unsigned long)];
 } init_thread_union __attribute__((section(".data.init_task"))) =3D {{
-	task: INIT_TASK(init_thread_union.s.task),
-	thread_info: INIT_THREAD_INFO(init_thread_union.s.thread_info)
+	.task =3D		INIT_TASK(init_thread_union.s.task),
+	.thread_info =3D	INIT_THREAD_INFO(init_thread_union.s.thread_info)
 }};
=20
 asm (".global init_task; init_task =3D init_thread_union");
diff -Nru a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
--- a/arch/ia64/kernel/iosapic.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/iosapic.c	Sat Aug 10 01:51:46 2002
@@ -88,7 +88,7 @@
=20
 static struct iosapic_irq {
 	char *addr;			/* base address of IOSAPIC */
-	unsigned char base_irq;		/* first irq assigned to this IOSAPIC */
+	unsigned int base_irq;		/* first irq assigned to this IOSAPIC */
 	char pin;			/* IOSAPIC pin (-1 =3D> not an IOSAPIC irq) */
 	unsigned char dmode	: 3;	/* delivery mode (see iosapic.h) */
 	unsigned char polarity	: 1;	/* interrupt polarity (see iosapic.h) */
@@ -97,9 +97,9 @@
=20
 static struct iosapic {
 	char *addr;			/* base address of IOSAPIC */
-	unsigned char	pcat_compat;	/* 8259 compatibility flag */
-	unsigned char 	base_irq;	/* first irq assigned to this IOSAPIC */
+	unsigned int 	base_irq;	/* first irq assigned to this IOSAPIC */
 	unsigned short 	max_pin;	/* max input pin supported in this IOSAPIC */
+	unsigned char	pcat_compat;	/* 8259 compatibility flag */
 } iosapic_lists[256] __initdata;
=20
 static int num_iosapic =3D 0;
@@ -160,6 +160,10 @@
 	int pin;
 	char redir;
=20
+#ifdef DEBUG_IRQ_ROUTING
+	printk(KERN_DEBUG "set_rte: routing vector 0x%02x to 0x%lx\n", vector, de=
st);
+#endif
+
 	pin =3D iosapic_irq[vector].pin;
 	if (pin < 0)
 		return;		/* not an IOSAPIC interrupt */
@@ -322,14 +326,14 @@
 #define iosapic_ack_level_irq		nop
=20
 struct hw_interrupt_type irq_type_iosapic_level =3D {
-	typename:	"IO-SAPIC-level",
-	startup:	iosapic_startup_level_irq,
-	shutdown:	iosapic_shutdown_level_irq,
-	enable:		iosapic_enable_level_irq,
-	disable:	iosapic_disable_level_irq,
-	ack:		iosapic_ack_level_irq,
-	end:		iosapic_end_level_irq,
-	set_affinity:	iosapic_set_affinity
+	.typename =3D	"IO-SAPIC-level",
+	.startup =3D	iosapic_startup_level_irq,
+	.shutdown =3D	iosapic_shutdown_level_irq,
+	.enable =3D	iosapic_enable_level_irq,
+	.disable =3D	iosapic_disable_level_irq,
+	.ack =3D		iosapic_ack_level_irq,
+	.end =3D		iosapic_end_level_irq,
+	.set_affinity =3D	iosapic_set_affinity
 };
=20
 /*
@@ -366,14 +370,14 @@
 #define iosapic_end_edge_irq		nop
=20
 struct hw_interrupt_type irq_type_iosapic_edge =3D {
-	typename:	"IO-SAPIC-edge",
-	startup:	iosapic_startup_edge_irq,
-	shutdown:	iosapic_disable_edge_irq,
-	enable:		iosapic_enable_edge_irq,
-	disable:	iosapic_disable_edge_irq,
-	ack:		iosapic_ack_edge_irq,
-	end:		iosapic_end_edge_irq,
-	set_affinity:	iosapic_set_affinity
+	.typename =3D	"IO-SAPIC-edge",
+	.startup =3D	iosapic_startup_edge_irq,
+	.shutdown =3D	iosapic_disable_edge_irq,
+	.enable =3D	iosapic_enable_edge_irq,
+	.disable =3D	iosapic_disable_edge_irq,
+	.ack =3D		iosapic_ack_edge_irq,
+	.end =3D		iosapic_end_edge_irq,
+	.set_affinity =3D	iosapic_set_affinity
 };
=20
 unsigned int
@@ -406,7 +410,7 @@
 	    || iosapic_irq[vector].polarity || iosapic_irq[vector].trigger)
 	{
 		new_vector =3D ia64_alloc_irq();
-		printk("Reassigning Vector 0x%x to 0x%x\n", vector, new_vector);
+		printk("Reassigning vector 0x%x to 0x%x\n", vector, new_vector);
 		memcpy (&iosapic_irq[new_vector], &iosapic_irq[vector],
 			sizeof(struct iosapic_irq));
 		memset (&iosapic_irq[vector], 0, sizeof(struct iosapic_irq));
@@ -422,6 +426,7 @@
 	irq_desc_t *idesc;
 	struct hw_interrupt_type *irq_type;
=20
+	gsi_to_vector(global_vector) =3D vector;
 	iosapic_irq[vector].pin	=3D pin;
 	iosapic_irq[vector].polarity =3D polarity ? IOSAPIC_POL_HIGH : IOSAPIC_PO=
L_LOW;
 	iosapic_irq[vector].dmode    =3D delivery;
@@ -640,7 +645,7 @@
 	unsigned int irq;
 	char *addr;
=20
-	if (0 !=3D acpi_get_prt(&pci_irq.route, &pci_irq.num_routes))
+	if (acpi_get_prt(&pci_irq.route, &pci_irq.num_routes))
 		return;
=20
 	for (i =3D 0; i < pci_irq.num_routes; i++) {
@@ -679,11 +684,10 @@
 		       pci_irq.route[i].bus, pci_irq.route[i].pci_id>>16, pci_irq.route[=
i].pin,
 		       iosapic_irq[vector].base_irq + iosapic_irq[vector].pin, vector);
 #endif
-
 		/*
-		 * Forget not to program the IOSAPIC RTE per ACPI _PRT
+		 * NOTE: The IOSAPIC RTE will be programmed in iosapic_pci_fixup().  It
+		 * needs to be done there to ensure PCI hotplug works right.
 		 */
-		set_rte(vector, (ia64_get_lid() >> 16) & 0xffff);
 	}
 }
=20
@@ -757,10 +761,11 @@
 				if (!(smp_int_redirect & SMP_IRQ_REDIRECTION)) {
 					static int cpu_index =3D 0;
=20
-					set_rte(vector, cpu_physical_id(cpu_index) & 0xffff);
+					while (!cpu_online(cpu_index))
+						if (++cpu_index >=3D NR_CPUS)
+							cpu_index =3D 0;
=20
-					for (cpu_index++; !cpu_online(cpu_index % NR_CPUS); cpu_index++);
-                                        cpu_index %=3D NR_CPUS;
+					set_rte(vector, cpu_physical_id(cpu_index) & 0xffff);
 				} else {
 					/*
 					 * Direct the interrupt vector to the current cpu,
diff -Nru a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c
--- a/arch/ia64/kernel/irq.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/irq.c	Sat Aug 10 01:51:46 2002
@@ -200,277 +200,12 @@
 	return 0;
 }
=20
-
-/*
- * Global interrupt locks for SMP. Allow interrupts to come in on any
- * CPU, yet make cli/sti act globally to protect critical regions..
- */
-
-#ifdef CONFIG_SMP
-unsigned int global_irq_holder =3D NO_PROC_ID;
-unsigned volatile long global_irq_lock; /* pedantic: long for set_bit --RR=
 */
-
-extern void show_stack(unsigned long* esp);
-
-static void show(char * str)
+#if CONFIG_SMP
+inline void synchronize_irq(unsigned int irq)
 {
-	int i;
-	int cpu =3D smp_processor_id();
-
-	printk("\n%s, CPU %d:\n", str, cpu);
-	printk("irq:  %d [",irqs_running());
-	for(i=3D0;i < NR_CPUS;i++)
-		printk(" %d",irq_count(i));
-	printk(" ]\nbh:   %d [",spin_is_locked(&global_bh_lock) ? 1 : 0);
-	for(i=3D0;i < NR_CPUS;i++)
-		printk(" %d",bh_count(i));
-
-	printk(" ]\nStack dumps:");
-#if defined(CONFIG_IA64)
-	/*
-	 * We can't unwind the stack of another CPU without access to
-	 * the registers of that CPU.  And sending an IPI when we're
-	 * in a potentially wedged state doesn't sound like a smart
-	 * idea.
-	 */
-#elif defined(CONFIG_X86)
-	for(i=3D0;i< NR_CPUS;i++) {
-		unsigned long esp;
-		if(i=3Dcpu)
-			continue;
-		printk("\nCPU %d:",i);
-		esp =3D init_tss[i].esp0;
-		if(esp=3DNULL) {
-			/* tss->esp0 is set to NULL in cpu_init(),
-			 * it's initialized when the cpu returns to user
-			 * space. -- manfreds
-			 */
-			printk(" <unknown> ");
-			continue;
-		}
-		esp &=3D ~(THREAD_SIZE-1);
-		esp +=3D sizeof(struct task_struct);
-		show_stack((void*)esp);
-	}
-#else
-	You lose...
-#endif
-	printk("\nCPU %d:",cpu);
-	show_stack(NULL);
-	printk("\n");
+	while (irq_desc(irq)->status & IRQ_INPROGRESS)
+		cpu_relax();
 }
-
-#define MAXCOUNT 100000000
-
-/*
- * I had a lockup scenario where a tight loop doing
- * spin_unlock()/spin_lock() on CPU#1 was racing with
- * spin_lock() on CPU#0. CPU#0 should have noticed spin_unlock(), but
- * apparently the spin_unlock() information did not make it
- * through to CPU#0 ... nasty, is this by design, do we have to limit
- * 'memory update oscillation frequency' artificially like here?
- *
- * Such 'high frequency update' races can be avoided by careful design, but
- * some of our major constructs like spinlocks use similar techniques,
- * it would be nice to clarify this issue. Set this define to 0 if you
- * want to check whether your system freezes.  I suspect the delay done
- * by SYNC_OTHER_CORES() is in correlation with 'snooping latency', but
- * i thought that such things are guaranteed by design, since we use
- * the 'LOCK' prefix.
- */
-#define SUSPECTED_CPU_OR_CHIPSET_BUG_WORKAROUND 0
-
-#if SUSPECTED_CPU_OR_CHIPSET_BUG_WORKAROUND
-# define SYNC_OTHER_CORES(x) udelay(x+1)
-#else
-/*
- * We have to allow irqs to arrive between local_irq_enable and local_irq_=
disable
- */
-# ifdef CONFIG_IA64
-#  define SYNC_OTHER_CORES(x) __asm__ __volatile__ ("nop 0")
-# else
-#  define SYNC_OTHER_CORES(x) __asm__ __volatile__ ("nop")
-# endif
-#endif
-
-static inline void wait_on_irq(void)
-{
-	int count =3D MAXCOUNT;
-
-	for (;;) {
-
-		/*
-		 * Wait until all interrupts are gone. Wait
-		 * for bottom half handlers unless we're
-		 * already executing in one..
-		 */
-		if (!irqs_running())
-			if (really_local_bh_count() || !spin_is_locked(&global_bh_lock))
-				break;
-
-		/* Duh, we have to loop. Release the lock to avoid deadlocks */
-		smp_mb__before_clear_bit();	/* need barrier before releasing lock... */
-		clear_bit(0,&global_irq_lock);
-
-		for (;;) {
-			if (!--count) {
-				show("wait_on_irq");
-				count =3D ~0;
-			}
-			local_irq_enable();
-			SYNC_OTHER_CORES(smp_processor_id());
-			local_irq_disable();
-			if (irqs_running())
-				continue;
-			if (global_irq_lock)
-				continue;
-			if (!really_local_bh_count() && spin_is_locked(&global_bh_lock))
-				continue;
-			if (!test_and_set_bit(0,&global_irq_lock))
-				break;
-		}
-	}
-}
-
-/*
- * This is called when we want to synchronize with
- * interrupts. We may for example tell a device to
- * stop sending interrupts: but to make sure there
- * are no interrupts that are executing on another
- * CPU we need to call this function.
- */
-void synchronize_irq(void)
-{
-	if (irqs_running()) {
-		/* Stupid approach */
-		cli();
-		sti();
-	}
-}
-
-static inline void get_irqlock(void)
-{
-	if (test_and_set_bit(0,&global_irq_lock)) {
-		/* do we already hold the lock? */
-		if (smp_processor_id() =3D global_irq_holder)
-			return;
-		/* Uhhuh.. Somebody else got it. Wait.. */
-		do {
-			do {
-#ifdef CONFIG_X86
-				rep_nop();
-#endif
-			} while (test_bit(0,&global_irq_lock));
-		} while (test_and_set_bit(0,&global_irq_lock));
-	}
-	/*
-	 * We also to make sure that nobody else is running
-	 * in an interrupt context.
-	 */
-	wait_on_irq();
-
-	/*
-	 * Ok, finally..
-	 */
-	global_irq_holder =3D smp_processor_id();
-}
-
-#define EFLAGS_IF_SHIFT 9
-
-/*
- * A global "cli()" while in an interrupt context
- * turns into just a local cli(). Interrupts
- * should use spinlocks for the (very unlikely)
- * case that they ever want to protect against
- * each other.
- *
- * If we already have local interrupts disabled,
- * this will not turn a local disable into a
- * global one (problems with spinlocks: this makes
- * save_flags+cli+sti usable inside a spinlock).
- */
-void __global_cli(void)
-{
-	unsigned int flags;
-
-#ifdef CONFIG_IA64
-	local_save_flags(flags);
-	if (flags & IA64_PSR_I) {
-		local_irq_disable();
-		if (!really_local_irq_count())
-			get_irqlock();
-	}
-#else
-	local_save_flags(flags);
-	if (flags & (1 << EFLAGS_IF_SHIFT)) {
-		local_irq_disable();
-		if (!really_local_irq_count())
-			get_irqlock();
-	}
-#endif
-}
-
-void __global_sti(void)
-{
-	if (!really_local_irq_count())
-		release_irqlock(smp_processor_id());
-	local_irq_enable();
-}
-
-/*
- * SMP flags value to restore to:
- * 0 - global cli
- * 1 - global sti
- * 2 - local cli
- * 3 - local sti
- */
-unsigned long __global_save_flags(void)
-{
-	int retval;
-	int local_enabled;
-	unsigned long flags;
-	int cpu =3D smp_processor_id();
-
-	local_save_flags(flags);
-#ifdef CONFIG_IA64
-	local_enabled =3D (flags & IA64_PSR_I) !=3D 0;
-#else
-	local_enabled =3D (flags >> EFLAGS_IF_SHIFT) & 1;
-#endif
-	/* default to local */
-	retval =3D 2 + local_enabled;
-
-	/* check for global flags if we're not in an interrupt */
-	if (!really_local_irq_count()) {
-		if (local_enabled)
-			retval =3D 1;
-		if (global_irq_holder =3D cpu)
-			retval =3D 0;
-	}
-	return retval;
-}
-
-void __global_restore_flags(unsigned long flags)
-{
-	switch (flags) {
-	case 0:
-		__global_cli();
-		break;
-	case 1:
-		__global_sti();
-		break;
-	case 2:
-		local_irq_disable();
-		break;
-	case 3:
-		local_irq_enable();
-		break;
-	default:
-		printk("global_restore_flags: %08lx (%08lx)\n",
-			flags, (&flags)[-1]);
-	}
-}
-
 #endif
=20
 /*
@@ -482,11 +217,7 @@
  */
 int handle_IRQ_event(unsigned int irq, struct pt_regs * regs, struct irqac=
tion * action)
 {
-	int status;
-
-	local_irq_enter(irq);
-
-	status =3D 1;	/* Force the "do bottom halves" bit */
+	int status =3D 1;	/* Force the "do bottom halves" bit */
=20
 	if (!(action->flags & SA_INTERRUPT))
 		local_irq_enable();
@@ -500,11 +231,16 @@
 		add_interrupt_randomness(irq);
 	local_irq_disable();
=20
-	local_irq_exit(irq);
-
 	return status;
 }
=20
+/*
+ * Generic enable/disable code: this just calls
+ * down into the PIC-specific version for the actual
+ * hardware disable after having gotten the irq
+ * controller lock.
+ */
+
 /**
  *	disable_irq_nosync - disable an irq without waiting
  *	@irq: Interrupt to disable
@@ -546,14 +282,7 @@
 void disable_irq(unsigned int irq)
 {
 	disable_irq_nosync(irq);
-
-#ifdef CONFIG_SMP
-	if (!really_local_irq_count()) {
-		do {
-			barrier();
-		} while (irq_desc(irq)->status & IRQ_INPROGRESS);
-	}
-#endif
+	synchronize_irq(irq);
 }
=20
 /**
@@ -616,6 +345,7 @@
 	struct irqaction * action;
 	unsigned int status;
=20
+	irq_enter();
 	kstat.irqs[cpu][irq]++;
=20
 	if (desc->status & IRQ_PER_CPU) {
@@ -638,7 +368,7 @@
 		 * use the action we have.
 		 */
 		action =3D NULL;
-		if (!(status & (IRQ_DISABLED | IRQ_INPROGRESS))) {
+		if (likely(!(status & (IRQ_DISABLED | IRQ_INPROGRESS)))) {
 			action =3D desc->action;
 			status &=3D ~IRQ_PENDING; /* we commit to handling */
 			status |=3D IRQ_INPROGRESS; /* we are handling it */
@@ -651,7 +381,7 @@
 		 * a different instance of this same irq, the other processor
 		 * will take care of it.
 		 */
-		if (!action)
+		if (unlikely(!action))
 			goto out;
=20
 		/*
@@ -673,8 +403,8 @@
 				break;
 			desc->status &=3D ~IRQ_PENDING;
 		}
-		desc->status &=3D ~IRQ_INPROGRESS;
 	  out:
+		desc->status &=3D ~IRQ_INPROGRESS;
 		/*
 		 * The ->end() handler has to deal with interrupts which got
 		 * disabled while the handler was running.
@@ -682,6 +412,7 @@
 		desc->handler->end(irq);
 		spin_unlock(&desc->lock);
 	}
+	irq_exit();
 	return 1;
 }
=20
@@ -811,7 +542,7 @@
 #ifdef CONFIG_SMP
 			/* Wait to make sure it's not being used on another CPU */
 			while (desc->status & IRQ_INPROGRESS)
-				barrier();
+				synchronize_irq(irq);
 #endif
 			kfree(action);
 			return;
@@ -864,7 +595,7 @@
=20
 	/* Wait for longstanding interrupts to trigger. */
 	for (delay =3D jiffies + HZ/50; time_after(delay, jiffies); )
-		/* about 20ms delay */ synchronize_irq();
+		/* about 20ms delay */ barrier();
=20
 	/*
 	 * enable any unassigned irqs
@@ -887,7 +618,7 @@
 	 * Wait for spurious interrupts to trigger
 	 */
 	for (delay =3D jiffies + HZ/10; time_after(delay, jiffies); )
-		/* about 100ms delay */ synchronize_irq();
+		/* about 100ms delay */ barrier();
=20
 	/*
 	 * Now filter out any obviously spurious interrupts
diff -Nru a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
--- a/arch/ia64/kernel/irq_ia64.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/irq_ia64.c	Sat Aug 10 01:51:46 2002
@@ -36,6 +36,10 @@
 #include <asm/pgtable.h>
 #include <asm/system.h>
=20
+#ifdef CONFIG_PERFMON
+# include <asm/perfmon.h>
+#endif
+
 #define IRQ_DEBUG	0
=20
 /* default base addr of IPI table */
@@ -50,6 +54,11 @@
 	0x28, 0x27, 0x26, 0x25, 0x24, 0x23, 0x22, 0x21
 };
=20
+/*
+ * GSI to IA-64 vector translation table.
+ */
+__u8 gsi_to_vector_map[255];
+
 int
 ia64_alloc_irq (void)
 {
@@ -144,9 +153,9 @@
 extern void handle_IPI (int irq, void *dev_id, struct pt_regs *regs);
=20
 static struct irqaction ipi_irqaction =3D {
-	handler:	handle_IPI,
-	flags:		SA_INTERRUPT,
-	name:		"IPI"
+	.handler =3D	handle_IPI,
+	.flags =3D	SA_INTERRUPT,
+	.name =3D		"IPI"
 };
 #endif
=20
@@ -172,6 +181,9 @@
 	register_percpu_irq(IA64_SPURIOUS_INT_VECTOR, NULL);
 #ifdef CONFIG_SMP
 	register_percpu_irq(IA64_IPI_VECTOR, &ipi_irqaction);
+#endif
+#ifdef CONFIG_PERFMON
+	perfmon_init_percpu();
 #endif
 	platform_irq_init();
 }
diff -Nru a/arch/ia64/kernel/irq_lsapic.c b/arch/ia64/kernel/irq_lsapic.c
--- a/arch/ia64/kernel/irq_lsapic.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/irq_lsapic.c	Sat Aug 10 01:51:46 2002
@@ -27,12 +27,12 @@
 }
=20
 struct hw_interrupt_type irq_type_ia64_lsapic =3D {
-	typename:	"LSAPIC",
-	startup:	lsapic_noop_startup,
-	shutdown:	lsapic_noop,
-	enable:		lsapic_noop,
-	disable:	lsapic_noop,
-	ack:		lsapic_noop,
-	end:		lsapic_noop,
-	set_affinity:	(void (*)(unsigned int, unsigned long)) lsapic_noop
+	.typename =3D	"LSAPIC",
+	.startup =3D	lsapic_noop_startup,
+	.shutdown =3D	lsapic_noop,
+	.enable =3D	lsapic_noop,
+	.disable =3D	lsapic_noop,
+	.ack =3D		lsapic_noop,
+	.end =3D		lsapic_noop,
+	.set_affinity =3D	(void (*)(unsigned int, unsigned long)) lsapic_noop
 };
diff -Nru a/arch/ia64/kernel/machvec.c b/arch/ia64/kernel/machvec.c
--- a/arch/ia64/kernel/machvec.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/machvec.c	Sat Aug 10 01:51:46 2002
@@ -11,13 +11,16 @@
 struct ia64_machine_vector ia64_mv;
=20
 /*
- * Most platforms use this routine for mapping page frame addresses
- * into a memory map index.
+ * Most platforms use this routine for mapping page frame addresses into a=
 memory map
+ * index.
+ *
+ * Note: we can't use __pa() because map_nr_dense(X) MUST map to something=
 >=3D max_mapnr if
+ * X is outside the identity mapped kernel space.
  */
 unsigned long
 map_nr_dense (unsigned long addr)
 {
-	return MAP_NR_DENSE(addr);
+	return (addr - PAGE_OFFSET) >> PAGE_SHIFT;
 }
=20
 static struct ia64_machine_vector *
diff -Nru a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
--- a/arch/ia64/kernel/mca.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/mca.c	Sat Aug 10 01:51:46 2002
@@ -82,27 +82,27 @@
 extern struct hw_interrupt_type	irq_type_iosapic_level;
=20
 static struct irqaction cmci_irqaction =3D {
-	handler:    ia64_mca_cmc_int_handler,
-	flags:      SA_INTERRUPT,
-	name:       "cmc_hndlr"
+	.handler =3D	ia64_mca_cmc_int_handler,
+	.flags =3D	SA_INTERRUPT,
+	.name =3D		"cmc_hndlr"
 };
=20
 static struct irqaction mca_rdzv_irqaction =3D {
-	handler:    ia64_mca_rendez_int_handler,
-	flags:      SA_INTERRUPT,
-	name:       "mca_rdzv"
+	.handler =3D	ia64_mca_rendez_int_handler,
+	.flags =3D	SA_INTERRUPT,
+	.name =3D		"mca_rdzv"
 };
=20
 static struct irqaction mca_wkup_irqaction =3D {
-	handler:    ia64_mca_wakeup_int_handler,
-	flags:      SA_INTERRUPT,
-	name:       "mca_wkup"
+	.handler =3D	ia64_mca_wakeup_int_handler,
+	.flags =3D	SA_INTERRUPT,
+	.name =3D		"mca_wkup"
 };
=20
 static struct irqaction mca_cpe_irqaction =3D {
-	handler:    ia64_mca_cpe_int_handler,
-	flags:      SA_INTERRUPT,
-	name:       "cpe_hndlr"
+	.handler =3D	ia64_mca_cpe_int_handler,
+	.flags =3D	SA_INTERRUPT,
+	.name =3D		"cpe_hndlr"
 };
=20
 /*
@@ -626,9 +626,12 @@
 void
 ia64_mca_rendez_int_handler(int rendez_irq, void *arg, struct pt_regs *ptr=
egs)
 {
-	int flags, cpu =3D 0;
+	unsigned long flags;
+	int cpu =3D 0;
+
 	/* Mask all interrupts */
-	save_and_cli(flags);
+#warning XXX fix me: this used to be: save_and_cli(flags);
+	local_irq_save(flags);
=20
 #ifdef CONFIG_SMP
 	cpu =3D cpu_logical_id(hard_smp_processor_id());
@@ -646,7 +649,7 @@
 	ia64_mca_wakeup_ipi_wait();
=20
 	/* Enable all interrupts */
-	restore_flags(flags);
+	local_irq_restore(flags);
 }
=20
=20
diff -Nru a/arch/ia64/kernel/mca_asm.S b/arch/ia64/kernel/mca_asm.S
--- a/arch/ia64/kernel/mca_asm.S	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/mca_asm.S	Sat Aug 10 01:51:46 2002
@@ -684,9 +684,9 @@
 	movl	r3=3DSAL_GET_STATE_INFO;;
 	DATA_VA_TO_PA(r7);;		// convert to physical address
 	ld8	r8=3D[r7],8;;		// get pdesc function pointer
-	DATA_VA_TO_PA(r8)		// convert to physical address
+	dep	r8=3D0,r8,61,3;;		// convert SAL VA to PA
 	ld8	r1=3D[r7];;		// set new (ia64_sal) gp
-	DATA_VA_TO_PA(r1)		// convert to physical address
+	dep	r1=3D0,r1,61,3;;		// convert SAL VA to PA
 	mov	b6=3Dr8
=20
 	alloc	r5=3Dar.pfs,8,0,8,0;;	// allocate stack frame for SAL call
diff -Nru a/arch/ia64/kernel/pci.c b/arch/ia64/kernel/pci.c
--- a/arch/ia64/kernel/pci.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/pci.c	Sat Aug 10 01:51:46 2002
@@ -165,7 +165,7 @@
  */
=20
 struct pci_bus *
-pcibios_scan_root(int seg, int bus)
+pcibios_scan_root(int bus)
 {
 	struct list_head *list =3D NULL;
 	struct pci_bus *pci_bus =3D NULL;
@@ -174,12 +174,12 @@
 		pci_bus =3D pci_bus_b(list);
 		if (pci_bus->number =3D bus) {
 			/* Already scanned */
-			printk("PCI: Bus (%02x:%02x) already probed\n", seg, bus);
+			printk("PCI: Bus (%02x) already probed\n", bus);
 			return pci_bus;
 		}
 	}
=20
-	printk("PCI: Probing PCI hardware on bus (%02x:%02x)\n", seg, bus);
+	printk("PCI: Probing PCI hardware on bus (%02x)\n", bus);
=20
 	return pci_scan_bus(bus, pci_root_ops, NULL);
 }
@@ -265,12 +265,37 @@
 int
 pcibios_enable_device (struct pci_dev *dev)
 {
+	u16 cmd, old_cmd;
+	int idx;
+	struct resource *r;
+
 	if (!dev)
 		return -EINVAL;
=20
-	/* Not needed, since we enable all devices at startup.  */
+	pci_read_config_word(dev, PCI_COMMAND, &cmd);
+	old_cmd =3D cmd;
+	for (idx=3D0; idx<6; idx++) {
+		r =3D &dev->resource[idx];
+		if (!r->start && r->end) {
+			printk(KERN_ERR
+			       "PCI: Device %s not available because of resource collisions\n",
+			       dev->slot_name);
+			return -EINVAL;
+		}
+		if (r->flags & IORESOURCE_IO)
+			cmd |=3D PCI_COMMAND_IO;
+		if (r->flags & IORESOURCE_MEM)
+			cmd |=3D PCI_COMMAND_MEMORY;
+	}
+	if (dev->resource[PCI_ROM_RESOURCE].start)
+		cmd |=3D PCI_COMMAND_MEMORY;
+	if (cmd !=3D old_cmd) {
+		printk("PCI: Enabling device %s (%04x -> %04x)\n", dev->slot_name, old_c=
md, cmd);
+		pci_write_config_word(dev, PCI_COMMAND, cmd);
+	}
=20
 	printk(KERN_INFO "PCI: Found IRQ %d for device %s\n", dev->irq, dev->slot=
_name);
+
 	return 0;
 }
=20
diff -Nru a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
--- a/arch/ia64/kernel/perfmon.c	Sat Aug 10 01:51:47 2002
+++ b/arch/ia64/kernel/perfmon.c	Sat Aug 10 01:51:47 2002
@@ -106,6 +106,12 @@
=20
 #define PFM_REG_RETFLAG_SET(flags, val)	do { flags &=3D ~PFM_REG_RETFL_MAS=
K; flags |=3D (val); } while(0)
=20
+#ifdef CONFIG_SMP
+#define cpu_is_online(i) (cpu_online_map & (1UL << i))
+#else
+#define cpu_is_online(i)        (i=3D0)
+#endif
+
 /*
  * debugging
  */
@@ -277,8 +283,8 @@
 typedef struct {
 	pfm_pmu_reg_type_t	type;
 	int			pm_pos;
-	int			(*read_check)(struct task_struct *task, unsigned int cnum, unsigned=
 long *val);
-	int			(*write_check)(struct task_struct *task, unsigned int cnum, unsigne=
d long *val);
+	int			(*read_check)(struct task_struct *task, unsigned int cnum, unsigned=
 long *val, struct pt_regs *regs);
+	int			(*write_check)(struct task_struct *task, unsigned int cnum, unsigne=
d long *val, struct pt_regs *regs);
 	unsigned long		dep_pmd[4];
 	unsigned long		dep_pmc[4];
 } pfm_reg_desc_t;
@@ -396,7 +402,7 @@
 static void pfm_vm_close(struct vm_area_struct * area);
=20
 static struct vm_operations_struct pfm_vm_ops=3D{
-	close: pfm_vm_close
+	.close =3D pfm_vm_close
 };
=20
 /*
@@ -902,8 +908,8 @@
 		/*
 		 * and it must be a valid CPU
 		 */
-		cpu =3D ffs(pfx->ctx_cpu_mask);
-		if (!cpu_online(cpu)) {
+		cpu =3D ffz(~pfx->ctx_cpu_mask);
+		if (cpu_is_online(cpu) =3D 0) {
 			DBprintk(("CPU%d is not online\n", cpu));
 			return -EINVAL;
 		}
@@ -925,11 +931,12 @@
 			DBprintk(("must have notify_pid when blocking for [%d]\n", task->pid));
 			return -EINVAL;
 		}
-
+#if 0
 		if ((ctx_flags & PFM_FL_NOTIFY_BLOCK) && pfx->ctx_notify_pid =3D task->p=
id) {
 			DBprintk(("cannot notify self when blocking for [%d]\n", task->pid));
 			return -EINVAL;
 		}
+#endif
 	}
 	/* probably more to add here */
=20
@@ -968,7 +975,7 @@
 	if (ctx_flags & PFM_FL_SYSTEM_WIDE) {
=20
 		/* at this point, we know there is at least one bit set */
-		cpu =3D ffs(tmp.ctx_cpu_mask) - 1;
+		cpu =3D ffz(~tmp.ctx_cpu_mask);
=20
 		DBprintk(("requesting CPU%d currently on CPU%d\n",cpu, smp_processor_id(=
)));
=20
@@ -1280,7 +1287,7 @@
 		/*
 		 * execute write checker, if any
 		 */
-		if (PMC_WR_FUNC(cnum)) ret =3D PMC_WR_FUNC(cnum)(task, cnum, &tmp.reg_va=
lue);
+		if (PMC_WR_FUNC(cnum)) ret =3D PMC_WR_FUNC(cnum)(task, cnum, &tmp.reg_va=
lue, regs);
 abort_mission:
 		if (ret =3D -EINVAL) reg_retval =3D PFM_REG_RETFL_EINVAL;
=20
@@ -1371,7 +1378,7 @@
 		/*
 		 * execute write checker, if any
 		 */
-		if (PMD_WR_FUNC(cnum)) ret =3D PMD_WR_FUNC(cnum)(task, cnum, &tmp.reg_va=
lue);
+		if (PMD_WR_FUNC(cnum)) ret =3D PMD_WR_FUNC(cnum)(task, cnum, &tmp.reg_va=
lue, regs);
 abort_mission:
 		if (ret =3D -EINVAL) reg_retval =3D PFM_REG_RETFL_EINVAL;
=20
@@ -1394,6 +1401,8 @@
=20
 		/* keep track of what we use */
 		CTX_USED_PMD(ctx, pmu_conf.pmd_desc[(cnum)].dep_pmd[0]);
+		/* mark this register as used as well */
+		CTX_USED_PMD(ctx, RDEP(cnum));
=20
 		/* writes to unimplemented part is ignored, so this is safe */
 		ia64_set_pmd(cnum, tmp.reg_value & pmu_conf.perf_ovfl_val);
@@ -1438,7 +1447,7 @@
 	DBprintk(("ctx_last_cpu=3D%d for [%d]\n", atomic_read(&ctx->ctx_last_cpu)=
, task->pid));
=20
 	for (i =3D 0; i < count; i++, req++) {
-		unsigned long reg_val =3D ~0UL, ctx_val =3D ~0UL;
+		unsigned long ctx_val =3D ~0UL;
=20
 		if (copy_from_user(&tmp, req, sizeof(tmp))) return -EFAULT;
=20
@@ -1462,7 +1471,7 @@
 		 */
 		if (atomic_read(&ctx->ctx_last_cpu) =3D smp_processor_id()){
 			ia64_srlz_d();
-			val =3D reg_val =3D ia64_get_pmd(cnum);
+			val =3D ia64_get_pmd(cnum);
 			DBprintk(("reading pmd[%u]=3D0x%lx from hw\n", cnum, val));
 		} else {
 #ifdef CONFIG_SMP
@@ -1484,7 +1493,7 @@
 			}
 #endif
 			/* context has been saved */
-			val =3D reg_val =3D th->pmd[cnum];
+			val =3D th->pmd[cnum];
 		}
 		if (PMD_IS_COUNTING(cnum)) {
 			/*
@@ -1493,9 +1502,7 @@
=20
 			val &=3D pmu_conf.perf_ovfl_val;
 			val +=3D ctx_val =3D ctx->ctx_soft_pmds[cnum].val;
-		} else {
-			val =3D reg_val =3D ia64_get_pmd(cnum);
-		}
+		}=20
=20
 		tmp.reg_value =3D val;
=20
@@ -1503,14 +1510,13 @@
 		 * execute read checker, if any
 		 */
 		if (PMD_RD_FUNC(cnum)) {
-			ret =3D PMD_RD_FUNC(cnum)(task, cnum, &tmp.reg_value);
+			ret =3D PMD_RD_FUNC(cnum)(task, cnum, &tmp.reg_value, regs);
 		}
=20
 		PFM_REG_RETFLAG_SET(tmp.reg_flags, ret);
=20
-		DBprintk(("read pmd[%u] ret=3D%d soft_pmd=3D0x%lx reg=3D0x%lx pmc=3D0x%l=
x\n",=20
-					cnum, ret, ctx_val, reg_val,=20
-					ia64_get_pmc(cnum)));
+		DBprintk(("read pmd[%u] ret=3D%d value=3D0x%lx pmc=3D0x%lx\n",=20
+					cnum, ret, val, ia64_get_pmc(cnum)));
=20
 		if (copy_to_user(req, &tmp, sizeof(tmp))) return -EFAULT;
 	}
@@ -1553,15 +1559,11 @@
 	 */
 	if (ctx && ctx->ctx_fl_using_dbreg =3D 1) return -1;
=20
-	/*
-	 * XXX: not pretty
-	 */
 	LOCK_PFS();
=20
 	/*
-	 * We only allow the use of debug registers when there is no system
-	 * wide monitoring=20
-	 * XXX: we could relax this by=20
+	 * We cannot allow setting breakpoints when system wide monitoring
+	 * sessions are using the debug registers.
 	 */
 	if (pfm_sessions.pfs_sys_use_dbregs> 0)
 		ret =3D -1;
@@ -1921,7 +1923,6 @@
 	dbr_mask_reg_t dbr;
 } dbreg_t;
=20
-
 static int
 pfm_write_ibr_dbr(int mode, struct task_struct *task, void *arg, int count=
, struct pt_regs *regs)
 {
@@ -1963,8 +1964,8 @@
 	if (ctx->ctx_fl_system) {
 		/* we mark ourselves as owner  of the debug registers */
 		ctx->ctx_fl_using_dbreg =3D 1;
-	} else {
-       		if (ctx->ctx_fl_using_dbreg =3D 0) {
+		DBprintk(("system-wide setting fl_using_dbreg for [%d]\n", task->pid));
+	} else if (first_time) {
 			ret=3D -EBUSY;
 			if ((thread->flags & IA64_THREAD_DBG_VALID) !=3D 0) {
 				DBprintk(("debug registers already in use for [%d]\n", task->pid));
@@ -1973,6 +1974,7 @@
 			/* we mark ourselves as owner  of the debug registers */
 			ctx->ctx_fl_using_dbreg =3D 1;
=20
+			DBprintk(("setting fl_using_dbreg for [%d]\n", task->pid));
 			/*=20
 			 * Given debug registers cannot be used for both debugging=20
 			 * and performance monitoring at the same time, we reuse
@@ -1980,20 +1982,27 @@
 			 */
 			memset(task->thread.dbr, 0, sizeof(task->thread.dbr));
 			memset(task->thread.ibr, 0, sizeof(task->thread.ibr));
+	}
=20
-			/*
-			 * clear hardware registers to make sure we don't
-			 * pick up stale state
-			 */
-			for (i=3D0; i < pmu_conf.num_ibrs; i++) {
-				ia64_set_ibr(i, 0UL);
-			}
-			ia64_srlz_i();
-			for (i=3D0; i < pmu_conf.num_dbrs; i++) {
-				ia64_set_dbr(i, 0UL);
-			}
-			ia64_srlz_d();
+	if (first_time) {
+		DBprintk(("[%d] clearing ibrs,dbrs\n", task->pid));
+		/*
+	 	 * clear hardware registers to make sure we don't
+	 	 * pick up stale state.=20
+		 *
+		 * for a system wide session, we do not use
+		 * thread.dbr, thread.ibr because this process
+		 * never leaves the current CPU and the state
+		 * is shared by all processes running on it
+	 	 */
+		for (i=3D0; i < pmu_conf.num_ibrs; i++) {
+			ia64_set_ibr(i, 0UL);
 		}
+		ia64_srlz_i();
+		for (i=3D0; i < pmu_conf.num_dbrs; i++) {
+			ia64_set_dbr(i, 0UL);
+		}
+		ia64_srlz_d();
 	}
=20
 	ret =3D -EFAULT;
@@ -2361,9 +2370,9 @@
 {
 	struct pt_regs *regs =3D (struct pt_regs *)&stack;
 	struct task_struct *task =3D current;
-	pfm_context_t *ctx =3D task->thread.pfm_context;
+	pfm_context_t *ctx;
 	size_t sz;
-	int ret =3D -ESRCH, narg;
+	int ret, narg;
=20
 	/*=20
 	 * reject any call if perfmon was disabled at initialization time
@@ -2393,6 +2402,8 @@
=20
 		if (pid !=3D current->pid) {
=20
+			ret =3D -ESRCH;
+
 			read_lock(&tasklist_lock);
=20
 			task =3D find_task_by_pid(pid);
@@ -2407,10 +2418,11 @@
 				ret =3D check_task_state(task);
 				if (ret !=3D 0) goto abort_call;
 			}
-			ctx =3D task->thread.pfm_context;
 		}
 	}=20
=20
+	ctx =3D task->thread.pfm_context;
+
 	if (PFM_CMD_USE_CTX(cmd)) {
 		ret =3D -EINVAL;
 	       if (ctx =3D NULL) {
@@ -2953,11 +2965,6 @@
 static int
 perfmon_proc_info(char *page)
 {
-#ifdef CONFIG_SMP
-#define cpu_is_online(i) (cpu_online_map & (1UL << i))
-#else
-#define cpu_is_online(i)        1
-#endif
 	char *p =3D page;
 	int i;
=20
@@ -4118,9 +4125,9 @@
 }
=20
 static struct irqaction perfmon_irqaction =3D {
-	handler:	perfmon_interrupt,
-	flags:		SA_INTERRUPT,
-	name:		"perfmon"
+	.handler =3D	perfmon_interrupt,
+	.flags =3D	SA_INTERRUPT,
+	.name =3D		"perfmon"
 };
=20
=20
@@ -4150,11 +4157,6 @@
 	pal_perf_mon_info_u_t pm_info;
 	s64 status;
=20
-	register_percpu_irq(IA64_PERFMON_VECTOR, &perfmon_irqaction);
-
-	ia64_set_pmv(IA64_PERFMON_VECTOR);
-	ia64_srlz_d();
-
 	pmu_conf.pfm_is_disabled =3D 1;
=20
 	printk("perfmon: version %u.%u (sampling format v%u.%u) IRQ %u\n",=20
@@ -4232,6 +4234,9 @@
 void
 perfmon_init_percpu (void)
 {
+	if (smp_processor_id() =3D 0)
+		register_percpu_irq(IA64_PERFMON_VECTOR, &perfmon_irqaction);
+
 	ia64_set_pmv(IA64_PERFMON_VECTOR);
 	ia64_srlz_d();
 }
diff -Nru a/arch/ia64/kernel/perfmon_itanium.h b/arch/ia64/kernel/perfmon_i=
tanium.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/kernel/perfmon_itanium.h	Sat Aug 10 01:51:47 2002
@@ -0,0 +1,99 @@
+/*
+ * This file contains the Itanium PMU register description tables
+ * and pmc checker used by perfmon.c.
+ *
+ * Copyright (C) 2002  Hewlett Packard Co
+ *               Stephane Eranian <eranian@hpl.hp.com>
+ */
+
+#define RDEP(x)	(1UL<<(x))
+
+#ifndef CONFIG_ITANIUM
+#error "This file is only valid when CONFIG_ITANIUM is defined"
+#endif
+
+static int pfm_ita_pmc_check(struct task_struct *task, unsigned int cnum, =
unsigned long *val, struct pt_regs *regs);
+static int pfm_write_ibr_dbr(int mode, struct task_struct *task, void *arg=
, int count, struct pt_regs *regs);
+
+static pfm_reg_desc_t pmc_desc[256]=3D{
+/* pmc0  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc1  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc2  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc3  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc4  */ { PFM_REG_COUNTING, 6, NULL, NULL, {RDEP(4),0UL, 0UL, 0UL}, {0=
UL,0UL, 0UL, 0UL}},
+/* pmc5  */ { PFM_REG_COUNTING, 6, NULL, NULL, {RDEP(5),0UL, 0UL, 0UL}, {0=
UL,0UL, 0UL, 0UL}},
+/* pmc6  */ { PFM_REG_COUNTING, 6, NULL, NULL, {RDEP(6),0UL, 0UL, 0UL}, {0=
UL,0UL, 0UL, 0UL}},
+/* pmc7  */ { PFM_REG_COUNTING, 6, NULL, NULL, {RDEP(7),0UL, 0UL, 0UL}, {0=
UL,0UL, 0UL, 0UL}},
+/* pmc8  */ { PFM_REG_CONFIG, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL=
, 0UL, 0UL}},
+/* pmc9  */ { PFM_REG_CONFIG, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL=
, 0UL, 0UL}},
+/* pmc10 */ { PFM_REG_MONITOR, 6, NULL, NULL, {RDEP(0)|RDEP(1),0UL, 0UL, 0=
UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc11 */ { PFM_REG_MONITOR, 6, NULL, pfm_ita_pmc_check, {RDEP(2)|RDEP(3=
)|RDEP(17),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc12 */ { PFM_REG_MONITOR, 6, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RD=
EP(11)|RDEP(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc13 */ { PFM_REG_CONFIG, 0, NULL, pfm_ita_pmc_check, {0UL,0UL, 0UL, 0=
UL}, {0UL,0UL, 0UL, 0UL}},
+	    { PFM_REG_NONE, 0, NULL, NULL, {0,}, {0,}}, /* end marker */
+};
+
+static pfm_reg_desc_t pmd_desc[256]=3D{
+/* pmd0  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(1),0UL, 0UL, 0UL}, {RDE=
P(10),0UL, 0UL, 0UL}},
+/* pmd1  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(0),0UL, 0UL, 0UL}, {RDE=
P(10),0UL, 0UL, 0UL}},
+/* pmd2  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(3)|RDEP(17),0UL, 0UL, 0=
UL}, {RDEP(11),0UL, 0UL, 0UL}},
+/* pmd3  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(2)|RDEP(17),0UL, 0UL, 0=
UL}, {RDEP(11),0UL, 0UL, 0UL}},
+/* pmd4  */ { PFM_REG_COUNTING, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(=
4),0UL, 0UL, 0UL}},
+/* pmd5  */ { PFM_REG_COUNTING, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(=
5),0UL, 0UL, 0UL}},
+/* pmd6  */ { PFM_REG_COUNTING, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(=
6),0UL, 0UL, 0UL}},
+/* pmd7  */ { PFM_REG_COUNTING, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(=
7),0UL, 0UL, 0UL}},
+/* pmd8  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(9)|RDEP(10)|RDEP(11)|RD=
EP(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0=
UL, 0UL}},
+/* pmd9  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(10)|RDEP(11)|RD=
EP(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0=
UL, 0UL}},
+/* pmd10 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(11)|RDE=
P(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd11 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd12 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(11)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd13 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(11)|RDEP(12)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd14 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(11)|RDEP(12)|RDEP(13)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd15 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(11)|RDEP(12)|RDEP(13)|RDEP(14)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd16 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(11)|RDEP(12)|RDEP(13)|RDEP(14)|RDEP(15),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd17 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(2)|RDEP(3),0UL, 0UL, 0U=
L}, {RDEP(11),0UL, 0UL, 0UL}},
+	    { PFM_REG_NONE, 0, NULL, NULL, {0,}, {0,}}, /* end marker */
+};
+
+static int
+pfm_ita_pmc_check(struct task_struct *task, unsigned int cnum, unsigned lo=
ng *val, struct pt_regs *regs)
+{
+	pfm_context_t *ctx =3D task->thread.pfm_context;
+	int ret;
+
+	/*
+	 * we must clear the (instruction) debug registers if pmc13.ta bit is cle=
ared
+	 * before they are written (fl_using_dbreg=3D0) to avoid picking up stale=
 information.=20
+	 */
+	if (cnum =3D 13 && ((*val & 0x1) =3D 0UL) && ctx->ctx_fl_using_dbreg =3D =
0) {
+
+		/* don't mix debug with perfmon */
+		if ((task->thread.flags & IA64_THREAD_DBG_VALID) !=3D 0) return -EINVAL;
+
+		/*=20
+		 * a count of 0 will mark the debug registers as in use and also
+		 * ensure that they are properly cleared.
+		 */
+		ret =3D pfm_write_ibr_dbr(1, task, NULL, 0, regs);
+		if (ret) return ret;
+	}
+
+	/*
+	 * we must clear the (data) debug registers if pmc11.pt bit is cleared
+	 * before they are written (fl_using_dbreg=3D0) to avoid picking up stale=
 information.=20
+	 */
+	if (cnum =3D 11 && ((*val >> 28)& 0x1) =3D 0 && ctx->ctx_fl_using_dbreg =
=3D 0) {
+
+		/* don't mix debug with perfmon */
+		if ((task->thread.flags & IA64_THREAD_DBG_VALID) !=3D 0) return -EINVAL;
+
+		/*=20
+		 * a count of 0 will mark the debug registers as in use and also
+		 * ensure that they are properly cleared.
+		 */
+		ret =3D pfm_write_ibr_dbr(0, task, NULL, 0, regs);
+		if (ret) return ret;
+	}
+	return 0;
+}
+
diff -Nru a/arch/ia64/kernel/perfmon_mckinley.h b/arch/ia64/kernel/perfmon_=
mckinley.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/kernel/perfmon_mckinley.h	Sat Aug 10 01:51:47 2002
@@ -0,0 +1,134 @@
+/*
+ * This file contains the McKinley PMU register description tables
+ * and pmc checker used by perfmon.c.
+ *
+ * Copyright (C) 2002  Hewlett Packard Co
+ *               Stephane Eranian <eranian@hpl.hp.com>
+ */
+
+#define RDEP(x)	(1UL<<(x))
+
+#ifndef CONFIG_MCKINLEY
+#error "This file is only valid when CONFIG_MCKINLEY is defined"
+#endif
+
+static int pfm_mck_pmc_check(struct task_struct *task, unsigned int cnum, =
unsigned long *val, struct pt_regs *regs);
+static int pfm_write_ibr_dbr(int mode, struct task_struct *task, void *arg=
, int count, struct pt_regs *regs);
+
+static pfm_reg_desc_t pmc_desc[256]=3D{
+/* pmc0  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc1  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc2  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc3  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc4  */ { PFM_REG_COUNTING, 6, NULL, pfm_mck_pmc_check, {RDEP(4),0UL, =
0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc5  */ { PFM_REG_COUNTING, 6, NULL, NULL, {RDEP(5),0UL, 0UL, 0UL}, {0=
UL,0UL, 0UL, 0UL}},
+/* pmc6  */ { PFM_REG_COUNTING, 6, NULL, NULL, {RDEP(6),0UL, 0UL, 0UL}, {0=
UL,0UL, 0UL, 0UL}},
+/* pmc7  */ { PFM_REG_COUNTING, 6, NULL, NULL, {RDEP(7),0UL, 0UL, 0UL}, {0=
UL,0UL, 0UL, 0UL}},
+/* pmc8  */ { PFM_REG_CONFIG, 0, NULL, pfm_mck_pmc_check, {0UL,0UL, 0UL, 0=
UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc9  */ { PFM_REG_CONFIG, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL=
, 0UL, 0UL}},
+/* pmc10 */ { PFM_REG_MONITOR, 4, NULL, NULL, {RDEP(0)|RDEP(1),0UL, 0UL, 0=
UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc11 */ { PFM_REG_MONITOR, 6, NULL, NULL, {RDEP(2)|RDEP(3)|RDEP(17),0U=
L, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc12 */ { PFM_REG_MONITOR, 6, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RD=
EP(11)|RDEP(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc13 */ { PFM_REG_CONFIG, 0, NULL, pfm_mck_pmc_check, {0UL,0UL, 0UL, 0=
UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc14 */ { PFM_REG_CONFIG, 0, NULL, pfm_mck_pmc_check, {0UL,0UL, 0UL, 0=
UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc15 */ { PFM_REG_CONFIG, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL=
, 0UL, 0UL}},
+	    { PFM_REG_NONE, 0, NULL, NULL, {0,}, {0,}}, /* end marker */
+};
+
+static pfm_reg_desc_t pmd_desc[256]=3D{
+/* pmd0  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(1),0UL, 0UL, 0UL}, {RDE=
P(10),0UL, 0UL, 0UL}},
+/* pmd1  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(0),0UL, 0UL, 0UL}, {RDE=
P(10),0UL, 0UL, 0UL}},
+/* pmd2  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(3)|RDEP(17),0UL, 0UL, 0=
UL}, {RDEP(11),0UL, 0UL, 0UL}},
+/* pmd3  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(2)|RDEP(17),0UL, 0UL, 0=
UL}, {RDEP(11),0UL, 0UL, 0UL}},
+/* pmd4  */ { PFM_REG_COUNTING, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(=
4),0UL, 0UL, 0UL}},
+/* pmd5  */ { PFM_REG_COUNTING, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(=
5),0UL, 0UL, 0UL}},
+/* pmd6  */ { PFM_REG_COUNTING, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(=
6),0UL, 0UL, 0UL}},
+/* pmd7  */ { PFM_REG_COUNTING, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(=
7),0UL, 0UL, 0UL}},
+/* pmd8  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(9)|RDEP(10)|RDEP(11)|RD=
EP(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0=
UL, 0UL}},
+/* pmd9  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(10)|RDEP(11)|RD=
EP(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0=
UL, 0UL}},
+/* pmd10 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(11)|RDE=
P(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd11 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd12 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(11)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd13 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(11)|RDEP(12)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd14 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(11)|RDEP(12)|RDEP(13)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd15 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(11)|RDEP(12)|RDEP(13)|RDEP(14)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd16 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(11)|RDEP(12)|RDEP(13)|RDEP(14)|RDEP(15),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd17 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(2)|RDEP(3),0UL, 0UL, 0U=
L}, {RDEP(11),0UL, 0UL, 0UL}},
+	    { PFM_REG_NONE, 0, NULL, NULL, {0,}, {0,}}, /* end marker */
+};
+
+static int
+pfm_mck_pmc_check(struct task_struct *task, unsigned int cnum, unsigned lo=
ng *val, struct pt_regs *regs)
+{
+	struct thread_struct *th =3D &task->thread;
+	pfm_context_t *ctx =3D task->thread.pfm_context;
+	int ret =3D 0, check_case1 =3D 0;
+	unsigned long val8 =3D 0, val14 =3D 0, val13 =3D 0;
+
+	/*
+	 * we must clear the debug registers if any pmc13.ena_dbrpX bit is enable=
d=20
+	 * before they are written (fl_using_dbreg=3D0) to avoid picking up stale=
 information.=20
+	 */
+	if (cnum =3D 13 && (*val & (0xfUL << 45)) && ctx->ctx_fl_using_dbreg =3D =
0) {
+
+		/* don't mix debug with perfmon */
+		if ((task->thread.flags & IA64_THREAD_DBG_VALID) !=3D 0) return -EINVAL;
+
+		/*=20
+		 * a count of 0 will mark the debug registers as in use and also
+		 * ensure that they are properly cleared.
+		 */
+		ret =3D pfm_write_ibr_dbr(1, task, NULL, 0, regs);
+		if (ret) return ret;
+	}
+	/*=20
+	 * we must clear the (instruction) debug registers if any pmc14.ibrpX bit=
 is enabled=20
+	 * before they are (fl_using_dbreg=3D0) to avoid picking up stale informa=
tion.=20
+	 */
+	if (cnum =3D 14 && ((*val & 0x2222) !=3D 0x2222) && ctx->ctx_fl_using_dbr=
eg =3D 0) {
+
+		/* don't mix debug with perfmon */
+		if ((task->thread.flags & IA64_THREAD_DBG_VALID) !=3D 0) return -EINVAL;
+
+		/*=20
+		 * a count of 0 will mark the debug registers as in use and also
+		 * ensure that they are properly cleared.
+		 */
+		ret =3D pfm_write_ibr_dbr(0, task, NULL, 0, regs);
+		if (ret) return ret;
+
+	}
+
+	switch(cnum) {
+		case  4: *val |=3D 1UL << 23; /* force power enable bit */
+			 break;
+		case  8: val8 =3D *val;
+			 val13 =3D th->pmc[13];
+			 val14 =3D th->pmc[14];
+			 check_case1 =3D 1;
+			 break;
+		case 13: val8  =3D th->pmc[8];
+			 val13 =3D *val;
+			 val14 =3D th->pmc[14];
+			 check_case1 =3D 1;
+			 break;
+		case 14: val8  =3D th->pmc[13];
+			 val13 =3D th->pmc[13];
+			 val14 =3D *val;
+			 check_case1 =3D 1;
+			 break;
+	}
+	/* check illegal configuration which can produce inconsistencies in taggi=
ng
+	 * i-side events in L1D and L2 caches
+	 */
+	if (check_case1) {
+		ret =3D   ((val13 >> 45) & 0xf) =3D 0=20
+		   && ((val8 & 0x1) =3D 0)
+		   && ((((val14>>1) & 0x3) =3D 0x2 || ((val14>>1) & 0x3) =3D 0x0)
+		       ||(((val14>>4) & 0x3) =3D 0x2 || ((val14>>4) & 0x3) =3D 0x0));
+
+		if (ret) printk("perfmon: failure check_case1\n");
+	}
+
+	return ret ? -EINVAL : 0;
+}
diff -Nru a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
--- a/arch/ia64/kernel/process.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/process.c	Sat Aug 10 01:51:46 2002
@@ -325,6 +325,11 @@
=20
 	/* copy parts of thread_struct: */
 	p->thread.ksp =3D (unsigned long) child_stack - 16;
+
+	/* stop some PSR bits from being inherited: */
+	child_ptregs->cr_ipsr =3D  ((child_ptregs->cr_ipsr | IA64_PSR_BITS_TO_SET)
+				  & ~IA64_PSR_BITS_TO_CLEAR);
+
 	/*
 	 * NOTE: The calling convention considers all floating point
 	 * registers in the high partition (fph) to be scratch.  Since
diff -Nru a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/setup.c	Sat Aug 10 01:51:46 2002
@@ -347,6 +347,14 @@
 #ifdef CONFIG_ACPI_BOOT
 	acpi_boot_init(*cmdline_p);
 #endif
+#ifdef CONFIG_SERIAL_HCDP
+	if (efi.hcdp) {
+		void setup_serial_hcdp(void *);
+
+		/* Setup the serial ports described by HCDP */
+		setup_serial_hcdp(efi.hcdp);
+	}
+#endif
 #ifdef CONFIG_VT
 # if defined(CONFIG_DUMMY_CONSOLE)
 	conswitchp =3D &dummy_con;
@@ -436,7 +444,7 @@
 c_start (struct seq_file *m, loff_t *pos)
 {
 #ifdef CONFIG_SMP
-	while (*pos < NR_CPUS && !(cpu_online_map & (1 << *pos)))
+	while (*pos < NR_CPUS && !(cpu_online_map & (1UL << *pos)))
 		++*pos;
 #endif
 	return *pos < NR_CPUS ? cpu_data(*pos) : NULL;
@@ -455,10 +463,10 @@
 }
=20
 struct seq_operations cpuinfo_op =3D {
-	start:	c_start,
-	next:	c_next,
-	stop:	c_stop,
-	show:	show_cpuinfo
+	.start =3D	c_start,
+	.next =3D		c_next,
+	.stop =3D		c_stop,
+	.show =3D		show_cpuinfo
 };
=20
 void
@@ -542,7 +550,18 @@
 	extern char __per_cpu_end[];
 	int cpu =3D smp_processor_id();
=20
-	my_cpu_data =3D alloc_bootmem_pages(__per_cpu_end - __per_cpu_start);
+	if (__per_cpu_end - __per_cpu_start > PAGE_SIZE)
+		panic("Per-cpu data area too big! (%Zu > %Zu)",
+		      __per_cpu_end - __per_cpu_start, PAGE_SIZE);
+
+	/*
+	 * On the BSP, the page allocator isn't initialized by the time we get he=
re.  On
+	 * the APs, the bootmem allocator is no longer available...
+	 */
+	if (cpu =3D 0)
+		my_cpu_data =3D alloc_bootmem_pages(__per_cpu_end - __per_cpu_start);
+	else
+		my_cpu_data =3D (void *) get_free_page(GFP_KERNEL);
 	memcpy(my_cpu_data, __phys_per_cpu_start, __per_cpu_end - __per_cpu_start=
);
 	__per_cpu_offset[cpu] =3D (char *) my_cpu_data - __per_cpu_start;
 	my_cpu_info =3D my_cpu_data + ((char *) &cpu_info - __per_cpu_start);
diff -Nru a/arch/ia64/kernel/signal.c b/arch/ia64/kernel/signal.c
--- a/arch/ia64/kernel/signal.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/signal.c	Sat Aug 10 01:51:46 2002
@@ -146,6 +146,7 @@
 	if (from->si_code < 0) {
 		if (__copy_to_user(to, from, sizeof(siginfo_t)))
 			return -EFAULT;
+		return 0;
 	} else {
 		int err;
=20
diff -Nru a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
--- a/arch/ia64/kernel/smpboot.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/smpboot.c	Sat Aug 10 01:51:46 2002
@@ -1,10 +1,14 @@
 /*
  * SMP boot-related support
  *
- * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2002 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * 01/05/16 Rohit Seth <rohit.seth@intel.com>	Moved SMP booting functions =
from smp.c to here.
  * 01/04/27 David Mosberger <davidm@hpl.hp.com>	Added ITC synching code.
+ * 02/07/31 David Mosberger <davidm@hpl.hp.com>	Switch over to hotplug-CPU=
 boot-sequence.
+ *						smp_boot_cpus()/smp_commence() is replaced by
+ *						smp_prepare_cpus()/__cpu_up()/smp_cpus_done().
  */
=20
=20
@@ -66,18 +70,16 @@
=20
 #define DEBUG_ITC_SYNC	0
=20
-extern void __init calibrate_delay(void);
-extern void start_ap(void);
+extern void __init calibrate_delay (void);
+extern void start_ap (void);
 extern unsigned long ia64_iobase;
=20
 int cpucount;
 task_t *task_for_booting_cpu;
=20
-/* Setup configured maximum number of CPUs to activate */
-static int max_cpus =3D -1;
-
 /* Bitmask of currently online CPUs */
 volatile unsigned long cpu_online_map;
+unsigned long phys_cpu_present_map;
=20
 /* which logical CPU number maps to which CPU (physical APIC ID) */
 volatile int ia64_cpu_to_sapicid[NR_CPUS];
@@ -86,44 +88,12 @@
=20
 struct smp_boot_data smp_boot_data __initdata;
=20
-/* Set when the idlers are all forked */
-volatile int smp_threads_ready;
-
 unsigned long ap_wakeup_vector =3D -1; /* External Int use to wakeup APs */
=20
 char __initdata no_int_routing;
=20
 unsigned char smp_int_redirect; /* are INT and IPI redirectable by the chi=
pset? */
=20
-/*
- * Setup routine for controlling SMP activation
- *
- * Command-line option of "nosmp" or "maxcpus=3D0" will disable SMP
- * activation entirely (the MPS table probe still happens, though).
- *
- * Command-line option of "maxcpus=3D<NUM>", where <NUM> is an integer
- * greater than 0, limits the maximum number of CPUs activated in
- * SMP mode to <NUM>.
- */
-
-static int __init
-nosmp (char *str)
-{
-	max_cpus =3D 0;
-	return 1;
-}
-
-__setup("nosmp", nosmp);
-
-static int __init
-maxcpus (char *str)
-{
-	get_option(&str, &max_cpus);
-	return 1;
-}
-
-__setup("maxcpus=3D", maxcpus);
-
 static int __init
 nointroute (char *str)
 {
@@ -299,7 +269,7 @@
=20
 static volatile atomic_t smp_commenced =3D ATOMIC_INIT(0);
=20
-void __init
+static void __init
 smp_commence (void)
 {
 	/*
@@ -308,7 +278,7 @@
 	Dprintk("Setting commenced=3D1, go go go\n");
=20
 	wmb();
-	atomic_set(&smp_commenced,1);
+	atomic_set(&smp_commenced, 1);
 }
=20
=20
@@ -405,6 +375,9 @@
 	int timeout, cpu;
=20
 	cpu =3D ++cpucount;
+
+	set_bit(cpu, &phys_cpu_present_map);
+
 	/*
 	 * We can't use kernel_thread since we must avoid to
 	 * reschedule the child.
@@ -425,7 +398,7 @@
=20
 	task_for_booting_cpu =3D idle;
=20
-	Dprintk("Sending wakeup vector %u to AP 0x%x/0x%x.\n", ap_wakeup_vector, =
cpu, sapicid);
+	Dprintk("Sending wakeup vector %lu to AP 0x%x/0x%x.\n", ap_wakeup_vector,=
 cpu, sapicid);
=20
 	platform_send_ipi(cpu, ap_wakeup_vector, IA64_IPI_DM_INT, 0);
=20
@@ -466,8 +439,8 @@
 /*
  * Cycle through the APs sending Wakeup IPIs to boot each.
  */
-void __init
-smp_boot_cpus (void)
+static void __init
+smp_boot_cpus (unsigned int max_cpus)
 {
 	int sapicid, cpu;
 	int boot_cpu_id =3D hard_smp_processor_id();
@@ -486,13 +459,13 @@
 	 */
 	set_bit(0, &cpu_online_map);
 	set_bit(0, &cpu_callin_map);
+	set_bit(0, &phys_cpu_present_map);
=20
 	local_cpu_data->loops_per_jiffy =3D loops_per_jiffy;
 	ia64_cpu_to_sapicid[0] =3D boot_cpu_id;
=20
 	printk("Boot processor id 0x%x/0x%x\n", 0, boot_cpu_id);
=20
-	global_irq_holder =3D NO_PROC_ID;
 	current_thread_info()->cpu =3D 0;
 	smp_tune_scheduling();
=20
@@ -537,11 +510,11 @@
=20
 		printk("Before bogomips.\n");
 		if (!cpucount) {
-			printk(KERN_ERR "Error: only one processor found.\n");
+			printk(KERN_WARNING "Warning: only one processor found.\n");
 		} else {
 			unsigned long bogosum =3D 0;
   			for (cpu =3D 0; cpu < NR_CPUS; cpu++)
-				if (cpu_online_map & (1<<cpu))
+				if (cpu_online_map & (1UL << cpu))
 					bogosum +=3D cpu_data(cpu)->loops_per_jiffy;
=20
 			printk(KERN_INFO"Total of %d processors activated (%lu.%02lu BogoMIPS).=
\n",
@@ -552,6 +525,29 @@
 	;
 }
=20
+void __init
+smp_prepare_cpus (unsigned int max_cpus)
+{
+ 	smp_boot_cpus(max_cpus);
+}
+
+int __devinit
+__cpu_up (unsigned int cpu)
+{
+	/*
+	 * Yeah, that's cheesy, but it will do until there is real hotplug suppor=
t and in
+	 * the meantime, this gives time for the interface changes to settle down=
...
+	 */
+	smp_commence();
+	return 0;
+}
+
+void __init
+smp_cpus_done (unsigned int max_cpus)
+{
+	/* nuthing... */
+}
+
 /*
  * Assume that CPU's have been discovered by some platform-dependant inter=
face.  For
  * SoftSDV/Lion, that would be ACPI.
@@ -571,9 +567,6 @@
 	ap_startup =3D (struct fptr *) start_ap;
 	sal_ret =3D ia64_sal_set_vectors(SAL_VECTOR_OS_BOOT_RENDEZ,
 				       __pa(ap_startup->fp), __pa(ap_startup->gp), 0, 0, 0, 0);
-	if (sal_ret < 0) {
-		printk("SMP: Can't set SAL AP Boot Rendezvous: %s\n     Forcing UP mode\=
n",
-		       ia64_sal_strerror(sal_ret));
-		max_cpus =3D 0;
-	}
+	if (sal_ret < 0)
+		printk("SMP: Can't set SAL AP Boot Rendezvous: %s\n", ia64_sal_strerror(=
sal_ret));
 }
diff -Nru a/arch/ia64/kernel/sys_ia64.c b/arch/ia64/kernel/sys_ia64.c
--- a/arch/ia64/kernel/sys_ia64.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/sys_ia64.c	Sat Aug 10 01:51:46 2002
@@ -82,7 +82,6 @@
 ia64_shmat (int shmid, void *shmaddr, int shmflg, long arg3, long arg4, lo=
ng arg5, long arg6,
 	    long arg7, long stack)
 {
-	extern int sys_shmat (int shmid, char *shmaddr, int shmflg, ulong *raddr);
 	struct pt_regs *regs =3D (struct pt_regs *) &stack;
 	unsigned long raddr;
 	int retval;
@@ -136,10 +135,6 @@
=20
 	/* Check against existing mmap mappings. */
 	if (find_vma_intersection(mm, oldbrk, newbrk+PAGE_SIZE))
-		goto out;
-
-	/* Check if we have enough memory.. */
-	if (!vm_enough_memory((newbrk-oldbrk) >> PAGE_SHIFT))
 		goto out;
=20
 	/* Ok, looks good - let it rip. */
diff -Nru a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
--- a/arch/ia64/kernel/time.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/kernel/time.c	Sat Aug 10 01:51:46 2002
@@ -41,21 +41,22 @@
 	extern unsigned long prof_cpu_mask;
 	extern char _stext;
=20
+	if (!prof_buffer)
+		return;
+
 	if (!((1UL << smp_processor_id()) & prof_cpu_mask))
 		return;
=20
-	if (prof_buffer && current->pid) {
-		ip -=3D (unsigned long) &_stext;
-		ip >>=3D prof_shift;
-		/*
-		 * Don't ignore out-of-bounds IP values silently, put them into the last
-		 * histogram slot, so if present, they will show up as a sharp peak.
-		 */
-		if (ip > prof_len - 1)
-			ip =3D prof_len - 1;
+	ip -=3D (unsigned long) &_stext;
+	ip >>=3D prof_shift;
+	/*
+	 * Don't ignore out-of-bounds IP values silently, put them into the last
+	 * histogram slot, so if present, they will show up as a sharp peak.
+	 */
+	if (ip > prof_len - 1)
+		ip =3D prof_len - 1;
=20
-		atomic_inc((atomic_t *) &prof_buffer[ip]);
-	}
+	atomic_inc((atomic_t *) &prof_buffer[ip]);
 }
=20
 /*
@@ -285,9 +286,9 @@
 }
=20
 static struct irqaction timer_irqaction =3D {
-	handler:	timer_interrupt,
-	flags:		SA_INTERRUPT,
-	name:		"timer"
+	.handler =3D	timer_interrupt,
+	.flags =3D	SA_INTERRUPT,
+	.name =3D		"timer"
 };
=20
 void __init
diff -Nru a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
--- a/arch/ia64/kernel/traps.c	Sat Aug 10 01:51:47 2002
+++ b/arch/ia64/kernel/traps.c	Sat Aug 10 01:51:47 2002
@@ -62,27 +62,26 @@
 void
 bust_spinlocks (int yes)
 {
+	int loglevel_save =3D console_loglevel;
+
 	spin_lock_init(&timerlist_lock);
 	if (yes) {
 		oops_in_progress =3D 1;
-#ifdef CONFIG_SMP
-		global_irq_lock =3D 0;	/* Many serial drivers do __global_cli() */
-#endif
-	} else {
-		int loglevel_save =3D console_loglevel;
+		return;
+	}
+
 #ifdef CONFIG_VT
-		unblank_screen();
+	unblank_screen();
 #endif
-		oops_in_progress =3D 0;
-		/*
-		 * OK, the message is on the console.  Now we call printk() without
-		 * oops_in_progress set so that printk will give klogd a poke.  Hold onto
-		 * your hats...
-		 */
-		console_loglevel =3D 15;		/* NMI oopser may have shut the console up */
-		printk(" ");
-		console_loglevel =3D loglevel_save;
-	}
+	oops_in_progress =3D 0;
+	/*
+	 * OK, the message is on the console.  Now we call printk() without
+	 * oops_in_progress set so that printk will give klogd a poke.  Hold onto
+	 * your hats...
+	 */
+	console_loglevel =3D 15;		/* NMI oopser may have shut the console up */
+	printk(" ");
+	console_loglevel =3D loglevel_save;
 }
=20
 void
@@ -93,9 +92,9 @@
 		int lock_owner;
 		int lock_owner_depth;
 	} die =3D {
-		lock:			SPIN_LOCK_UNLOCKED,
-		lock_owner:		-1,
-		lock_owner_depth:	0
+		.lock =3D			SPIN_LOCK_UNLOCKED,
+		.lock_owner =3D		-1,
+		.lock_owner_depth =3D	0
 	};
=20
 	if (die.lock_owner !=3D smp_processor_id()) {
@@ -131,6 +130,8 @@
 	siginfo_t siginfo;
 	int sig, code;
=20
+	die_if_kernel("bad break", regs, break_num);
+
 	/* SIGILL, SIGFPE, SIGSEGV, and SIGBUS want these field initialized: */
 	siginfo.si_addr =3D (void *) (regs->cr_iip + ia64_psr(regs)->ri);
 	siginfo.si_imm =3D break_num;
@@ -435,7 +436,7 @@
 	unsigned long code, error =3D isr;
 	struct siginfo siginfo;
 	char buf[128];
-	int result;
+	int result, sig;
 	static const char *reason[] =3D {
 		"IA-64 Illegal Operation fault",
 		"IA-64 Privileged Operation fault",
@@ -479,6 +480,30 @@
 		break;
=20
 	      case 26: /* NaT Consumption */
+		if (user_mode(regs)) {
+			if (((isr >> 4) & 0xf) =3D 2) {
+				/* NaT page consumption */
+				sig =3D SIGSEGV;
+				code =3D SEGV_ACCERR;
+			} else {
+				/* register NaT consumption */
+				sig =3D SIGILL;
+				code =3D ILL_ILLOPN;
+			}
+			siginfo.si_signo =3D sig;
+			siginfo.si_code =3D code;
+			siginfo.si_errno =3D 0;
+			siginfo.si_addr =3D (void *) (regs->cr_iip + ia64_psr(regs)->ri);
+			siginfo.si_imm =3D vector;
+			siginfo.si_flags =3D __ISR_VALID;
+			siginfo.si_isr =3D isr;
+			force_sig_info(sig, &siginfo, current);
+			return;
+		} else if (done_with_exception(regs))
+			return;
+		sprintf(buf, "NaT consumption");
+		break;
+
 	      case 31: /* Unsupported Data Reference */
 		if (user_mode(regs)) {
 			siginfo.si_signo =3D SIGILL;
@@ -491,7 +516,7 @@
 			force_sig_info(SIGILL, &siginfo, current);
 			return;
 		}
-		sprintf(buf, (vector =3D 26) ? "NaT consumption" : "Unsupported data ref=
erence");
+		sprintf(buf, "Unsupported data reference");
 		break;
=20
 	      case 29: /* Debug */
@@ -508,16 +533,15 @@
 			if (ia64_psr(regs)->is =3D 0)
 			  ifa =3D regs->cr_iip;
 #endif
-			siginfo.si_addr =3D (void *) ifa;
 			break;
-		      case 35: siginfo.si_code =3D TRAP_BRANCH; break;
-		      case 36: siginfo.si_code =3D TRAP_TRACE; break;
+		      case 35: siginfo.si_code =3D TRAP_BRANCH; ifa =3D 0; break;
+		      case 36: siginfo.si_code =3D TRAP_TRACE; ifa =3D 0; break;
 		}
 		siginfo.si_signo =3D SIGTRAP;
 		siginfo.si_errno =3D 0;
 		siginfo.si_flags =3D 0;
 		siginfo.si_isr =3D 0;
-		siginfo.si_addr =3D 0;
+		siginfo.si_addr =3D (void *) ifa;
 		siginfo.si_imm =3D 0;
 		force_sig_info(SIGTRAP, &siginfo, current);
 		return;
diff -Nru a/arch/ia64/kernel/unwind.c b/arch/ia64/kernel/unwind.c
--- a/arch/ia64/kernel/unwind.c	Sat Aug 10 01:51:47 2002
+++ b/arch/ia64/kernel/unwind.c	Sat Aug 10 01:51:47 2002
@@ -140,13 +140,13 @@
 	} stat;
 # endif
 } unw =3D {
-	tables: &unw.kernel_table,
-	lock: SPIN_LOCK_UNLOCKED,
-	save_order: {
+	.tables =3D &unw.kernel_table,
+	.lock =3D SPIN_LOCK_UNLOCKED,
+	.save_order =3D {
 		UNW_REG_RP, UNW_REG_PFS, UNW_REG_PSP, UNW_REG_PR,
 		UNW_REG_UNAT, UNW_REG_LC, UNW_REG_FPSR, UNW_REG_PRI_UNAT_GR
 	},
-	preg_index: {
+	.preg_index =3D {
 		struct_offset(struct unw_frame_info, pri_unat_loc)/8,	/* PRI_UNAT_GR */
 		struct_offset(struct unw_frame_info, pri_unat_loc)/8,	/* PRI_UNAT_MEM */
 		struct_offset(struct unw_frame_info, bsp_loc)/8,
@@ -189,9 +189,9 @@
 		struct_offset(struct unw_frame_info, fr_loc[30 - 16])/8,
 		struct_offset(struct unw_frame_info, fr_loc[31 - 16])/8,
 	},
-	hash : { [0 ... UNW_HASH_SIZE - 1] =3D -1 },
+	.hash =3D { [0 ... UNW_HASH_SIZE - 1] =3D -1 },
 #if UNW_DEBUG
-	preg_name: {
+	.preg_name =3D {
 		"pri_unat_gr", "pri_unat_mem", "bsp", "bspstore", "ar.pfs", "ar.rnat", "=
psp", "rp",
 		"r4", "r5", "r6", "r7",
 		"ar.unat", "pr", "ar.lc", "ar.fpsr",
@@ -634,8 +634,8 @@
 	for (reg =3D hi; reg >=3D lo; --reg) {
 		if (reg->where =3D UNW_WHERE_SPILL_HOME) {
 			reg->where =3D UNW_WHERE_PSPREL;
-			reg->val =3D 0x10 - *offp;
-			*offp +=3D regsize;
+			*offp -=3D regsize;
+			reg->val =3D *offp;
 		}
 	}
 }
@@ -814,7 +814,8 @@
 	}
 	for (i =3D 0; i < 20; ++i) {
 		if ((frmask & 1) !=3D 0) {
-			set_reg(sr->curr.reg + UNW_REG_F2 + i, UNW_WHERE_SPILL_HOME,
+			int base =3D (i < 4) ? UNW_REG_F2 : UNW_REG_F16 - 4;
+			set_reg(sr->curr.reg + base + i, UNW_WHERE_SPILL_HOME,
 				sr->region_start + sr->region_len - 1, 0);
 			sr->any_spills =3D 1;
 		}
diff -Nru a/arch/ia64/lib/Makefile b/arch/ia64/lib/Makefile
--- a/arch/ia64/lib/Makefile	Sat Aug 10 01:51:47 2002
+++ b/arch/ia64/lib/Makefile	Sat Aug 10 01:51:47 2002
@@ -6,43 +6,51 @@
=20
 export-objs :=3D swiotlb.o
=20
-obj-y :=3D __divsi3.o __udivsi3.o __modsi3.o __umodsi3.o					\
-	__divdi3.o __udivdi3.o __moddi3.o __umoddi3.o					\
-	checksum.o clear_page.o csum_partial_copy.o copy_page.o				\
-	copy_user.o clear_user.o strncpy_from_user.o strlen_user.o strnlen_user.o=
	\
-	flush.o io.o ip_fast_csum.o do_csum.o						\
-	memcpy.o memset.o strlen.o swiotlb.o
+obj-y :=3D __divsi3.o __udivsi3.o __modsi3.o __umodsi3.o			\
+	__divdi3.o __udivdi3.o __moddi3.o __umoddi3.o			\
+	checksum.o clear_page.o csum_partial_copy.o copy_page.o		\
+	clear_user.o strncpy_from_user.o strlen_user.o strnlen_user.o	\
+	flush.o io.o ip_fast_csum.o do_csum.o				\
+	memset.o strlen.o swiotlb.o
=20
-obj-$(CONFIG_ITANIUM) +=3D copy_page.o
-obj-$(CONFIG_MCKINLEY) +=3D copy_page_mck.o
+obj-$(CONFIG_ITANIUM)	+=3D copy_page.o copy_user.o memcpy.o
+obj-$(CONFIG_MCKINLEY)	+=3D copy_page_mck.o memcpy_mck.o
=20
 IGNORE_FLAGS_OBJS =3D	__divsi3.o __udivsi3.o __modsi3.o __umodsi3.o \
 			__divdi3.o __udivdi3.o __moddi3.o __umoddi3.o
=20
-$(L_TARGET): $(obj-y) $(export-objs)
+include $(TOPDIR)/Rules.make
+
+AFLAGS___divdi3.o	+AFLAGS___udivdi3.o	=3D -DUNSIGNED
+AFLAGS___moddi3.o	=3D 	     -DMODULO
+AFLAGS___umoddi3.o	=3D -DUNSIGNED -DMODULO
+
+AFLAGS___divsi3.o	+AFLAGS___udivsi3.o	=3D -DUNSIGNED
+AFLAGS___modsi3.o	=3D	     -DMODULO
+AFLAGS___umodsi3.o	=3D -DUNSIGNED -DMODULO
=20
 __divdi3.o: idiv64.S
-	$(CC) $(AFLAGS) -c -o $@ $<
+	$(cmd_as_o_S)
=20
 __udivdi3.o: idiv64.S
-	$(CC) $(AFLAGS) -c -DUNSIGNED -c -o $@ $<
+	$(cmd_as_o_S)
=20
 __moddi3.o: idiv64.S
-	$(CC) $(AFLAGS) -c -DMODULO -c -o $@ $<
+	$(cmd_as_o_S)
=20
 __umoddi3.o: idiv64.S
-	$(CC) $(AFLAGS) -c -DMODULO -DUNSIGNED -c -o $@ $<
+	$(cmd_as_o_S)
=20
 __divsi3.o: idiv32.S
-	$(CC) $(AFLAGS) -c -o $@ $<
+	$(cmd_as_o_S)
=20
 __udivsi3.o: idiv32.S
-	$(CC) $(AFLAGS) -c -DUNSIGNED -c -o $@ $<
+	$(cmd_as_o_S)
=20
 __modsi3.o: idiv32.S
-	$(CC) $(AFLAGS) -c -DMODULO -c -o $@ $<
+	$(cmd_as_o_S)
=20
 __umodsi3.o: idiv32.S
-	$(CC) $(AFLAGS) -c -DMODULO -DUNSIGNED -c -o $@ $<
-
-include $(TOPDIR)/Rules.make
+	$(cmd_as_o_S)
diff -Nru a/arch/ia64/lib/copy_user.S b/arch/ia64/lib/copy_user.S
--- a/arch/ia64/lib/copy_user.S	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/lib/copy_user.S	Sat Aug 10 01:51:46 2002
@@ -237,15 +237,17 @@
 .copy_user_bit##rshift:						\
 1:								\
 	EX(.failure_out,(EPI) st8 [dst1]=3Dtmp,8);		\
-(EPI_1) shrp tmp=3Dval1[PIPE_DEPTH-3],val1[PIPE_DEPTH-2],rshift;	\
-	EX(3f,(p16) ld8 val1[0]=3D[src1],8);			\
+(EPI_1) shrp tmp=3Dval1[PIPE_DEPTH-2],val1[PIPE_DEPTH-1],rshift;	\
+	EX(3f,(p16) ld8 val1[1]=3D[src1],8);			\
+(p16)	mov val1[0]=3Dr0;						\
 	br.ctop.dptk 1b;					\
 	;;							\
 	br.cond.sptk.many .diff_align_do_tail;			\
 2:								\
 (EPI)	st8 [dst1]=3Dtmp,8;					\
-(EPI_1)	shrp tmp=3Dval1[PIPE_DEPTH-3],val1[PIPE_DEPTH-2],rshift;	\
+(EPI_1)	shrp tmp=3Dval1[PIPE_DEPTH-2],val1[PIPE_DEPTH-1],rshift;	\
 3:								\
+(p16)	mov val1[1]=3Dr0;						\
 (p16)	mov val1[0]=3Dr0;						\
 	br.ctop.dptk 2b;					\
 	;;							\
diff -Nru a/arch/ia64/lib/io.c b/arch/ia64/lib/io.c
--- a/arch/ia64/lib/io.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/lib/io.c	Sat Aug 10 01:51:46 2002
@@ -87,6 +87,12 @@
 	__ia64_outl(val, port);
 }
=20
+void
+ia64_mmiob (void)
+{
+	__ia64_mmiob();
+}
+
 /* define aliases: */
=20
 asm (".global __ia64_inb, __ia64_inw, __ia64_inl");
@@ -98,5 +104,8 @@
 asm ("__ia64_outb =3D ia64_outb");
 asm ("__ia64_outw =3D ia64_outw");
 asm ("__ia64_outl =3D ia64_outl");
+
+asm (".global __ia64_mmiob");
+asm ("__ia64_mmiob =3D ia64_mmiob");
=20
 #endif /* CONFIG_IA64_GENERIC */
diff -Nru a/arch/ia64/lib/memcpy_mck.S b/arch/ia64/lib/memcpy_mck.S
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/lib/memcpy_mck.S	Sat Aug 10 01:51:47 2002
@@ -0,0 +1,674 @@
+/*
+ * Itanium 2-optimized version of memcpy and copy_user function
+ *
+ * Inputs:
+ * 	in0:	destination address
+ *	in1:	source address
+ *	in2:	number of bytes to copy
+ * Output:
+ * 	0 if success, or number of byte NOT copied if error occurred.
+ *
+ * Copyright (C) 2002 Intel Corp.
+ * Copyright (C) 2002 Ken Chen <kenneth.w.chen@intel.com>
+ */
+#include <linux/config.h>
+#include <asm/asmmacro.h>
+#include <asm/page.h>
+
+#if __GNUC__ >=3D 3
+# define EK(y...) EX(y)
+#else
+# define EK(y,x...)  x
+#endif
+
+GLOBAL_ENTRY(bcopy)
+	.regstk 3,0,0,0
+	mov r8=3Din0
+	mov in0=3Din1
+	;;
+	mov in1=3Dr8
+	;;
+END(bcopy)
+
+/* McKinley specific optimization */
+
+#define retval		r8
+#define saved_pfs	r31
+#define saved_lc	r10
+#define saved_pr	r11
+#define saved_in0	r14
+#define saved_in1	r15
+#define saved_in2	r16
+
+#define src0		r2
+#define src1		r3
+#define dst0		r17
+#define dst1		r18
+#define cnt		r9
+
+/* r19-r30 are temp for each code section */
+#define PREFETCH_DIST	8
+#define src_pre_mem	r19
+#define dst_pre_mem	r20
+#define src_pre_l2	r21
+#define dst_pre_l2	r22
+#define t1		r23
+#define t2		r24
+#define t3		r25
+#define t4		r26
+#define t5		t1	// alias!
+#define t6		t2	// alias!
+#define t7		t3	// alias!
+#define n8		r27
+#define t9		t5	// alias!
+#define t10		t4	// alias!
+#define t11		t7	// alias!
+#define t12		t6	// alias!
+#define t14		t10	// alias!
+#define t13		r28
+#define t15		r29
+#define tmp		r30
+
+/* defines for long_copy block */
+#define	A	0
+#define B	(PREFETCH_DIST)
+#define C	(B + PREFETCH_DIST)
+#define D	(C + 1)
+#define N	(D + 1)
+#define Nrot	((N + 7) & ~7)
+
+/* alias */
+#define in0		r32
+#define in1		r33
+#define in2		r34
+
+GLOBAL_ENTRY(memcpy)
+	and	r28=3D0x7,in0
+	and	r29=3D0x7,in1
+	mov	f6=F0
+	br.cond.sptk .common_code
+	;;
+GLOBAL_ENTRY(__copy_user)
+	.prologue
+// check dest alignment
+	and	r28=3D0x7,in0
+	and	r29=3D0x7,in1
+	mov	f6=F1
+	mov	saved_in0=3Din0	// save dest pointer
+	mov	saved_in1=3Din1	// save src pointer
+	mov	saved_in2=3Din2	// save len
+	;;
+.common_code:
+	cmp.gt	p15,p0=3D8,in2	// check for small size
+	cmp.ne	p13,p0=3D0,r28	// check dest alignment
+	cmp.ne	p14,p0=3D0,r29	// check src alignment
+	add	src0=3D0,in1
+	sub	r30=3D8,r28	// for .align_dest
+	mov	retval=3Dr0	// initialize return value
+	;;
+	add	dst0=3D0,in0
+	add	dst1=3D1,in0	// dest odd index
+	cmp.le	p6,p0 =3D 1,r30	// for .align_dest
+(p15)	br.cond.dpnt .memcpy_short
+(p13)	br.cond.dpnt .align_dest
+(p14)	br.cond.dpnt .unaligned_src
+	;;
+
+// both dest and src are aligned on 8-byte boundary
+.aligned_src:
+	.save ar.pfs, saved_pfs
+	alloc	saved_pfs=3Dar.pfs,3,Nrot-3,0,Nrot
+	.save pr, saved_pr
+	mov	saved_pr=3Dpr
+
+	shr.u	cnt=3Din2,7	// this much cache line
+	;;
+	cmp.lt	p6,p0=3D2*PREFETCH_DIST,cnt
+	cmp.lt	p7,p8=3D1,cnt
+	.save ar.lc, saved_lc
+	mov	saved_lc=3Dar.lc
+	.body
+	add	cnt=3D-1,cnt
+	add	src_pre_mem=3D0,in1	// prefetch src pointer
+	add	dst_pre_mem=3D0,in0	// prefetch dest pointer
+	;;
+(p7)	mov	ar.lc=3Dcnt	// prefetch count
+(p8)	mov	ar.lc=3Dr0
+(p6)	br.cond.dpnt .long_copy
+	;;
+
+.prefetch:
+	lfetch.fault	  [src_pre_mem], 128
+	lfetch.fault.excl [dst_pre_mem], 128
+	br.cloop.dptk.few .prefetch
+	;;
+
+.medium_copy:
+	and	tmp1,in2	// copy length after iteration
+	shr.u	r29=3Din2,5	// number of 32-byte iteration
+	add	dst1=3D8,dst0	// 2nd dest pointer
+	;;
+	add	cnt=3D-1,r29	// ctop iteration adjustment
+	cmp.eq	p10,p0=3Dr29,r0	// do we really need to loop?
+	add	src1=3D8,src0	// 2nd src pointer
+	cmp.le	p6,p0=3D8,tmp
+	;;
+	cmp.le	p7,p0=16,tmp
+	mov	ar.lc=3Dcnt	// loop setup
+	cmp.eq	p16,p17 =3D r0,r0
+	mov	ar.ec=3D2
+(p10)	br.dpnt.few .aligned_src_tail
+	;;
+	.align 32
+1:
+EX(.ex_handler, (p16)	ld8	r34=3D[src0],16)
+EK(.ex_handler, (p16)	ld8	r38=3D[src1],16)
+EX(.ex_handler, (p17)	st8	[dst0]=3Dr33,16)
+EK(.ex_handler, (p17)	st8	[dst1]=3Dr37,16)
+	;;
+EX(.ex_handler, (p16)	ld8	r32=3D[src0],16)
+EK(.ex_handler, (p16)	ld8	r36=3D[src1],16)
+EX(.ex_handler, (p16)	st8	[dst0]=3Dr34,16)
+EK(.ex_handler, (p16)	st8	[dst1]=3Dr38,16)
+	br.ctop.dptk.few 1b
+	;;
+
+.aligned_src_tail:
+EX(.ex_handler, (p6)	ld8	t1=3D[src0])
+	mov	ar.lc=3Dsaved_lc
+	mov	ar.pfs=3Dsaved_pfs
+EX(.ex_hndlr_s, (p7)	ld8	t2=3D[src1],8)
+	cmp.le	p8,p0$,tmp
+	and	r21=3D-8,tmp
+	;;
+EX(.ex_hndlr_s, (p8)	ld8	t3=3D[src1])
+EX(.ex_handler, (p6)	st8	[dst0]=3Dt1)	// store byte 1
+	and	in2=3D7,tmp	// remaining length
+EX(.ex_hndlr_d, (p7)	st8	[dst1]=3Dt2,8)	// store byte 2
+	add	src0=3Dsrc0,r21	// setting up src pointer
+	add	dst0=3Ddst0,r21	// setting up dest pointer
+	;;
+EX(.ex_handler, (p8)	st8	[dst1]=3Dt3)	// store byte 3
+	mov	pr=3Dsaved_pr,-1
+	br.dptk.many .memcpy_short
+	;;
+
+/* code taken from copy_page_mck */
+.long_copy:
+	.rotr v[2*PREFETCH_DIST]
+	.rotp p[N]
+
+	mov src_pre_mem =3D src0
+	mov pr.rot =3D 0x10000
+	mov ar.ec =3D 1				// special unrolled loop
+
+	mov dst_pre_mem =3D dst0
+
+	add src_pre_l2 =3D 8*8, src0
+	add dst_pre_l2 =3D 8*8, dst0
+	;;
+	add src0 =3D 8, src_pre_mem		// first t1 src
+	mov ar.lc =3D 2*PREFETCH_DIST - 1
+	shr.u cnt=3Din2,7				// number of lines
+	add src1 =3D 3*8, src_pre_mem		// first t3 src
+	add dst0 =3D 8, dst_pre_mem		// first t1 dst
+	add dst1 =3D 3*8, dst_pre_mem		// first t3 dst
+	;;
+	and tmp=127,in2				// remaining bytes after this block
+	add cnt =3D -(2*PREFETCH_DIST) - 1, cnt
+	// same as .line_copy loop, but with all predicated-off instructions remo=
ved:
+.prefetch_loop:
+EX(.ex_hndlr_lcpy_1, (p[A])	ld8 v[A] =3D [src_pre_mem], 128)		// M0
+EK(.ex_hndlr_lcpy_1, (p[B])	st8 [dst_pre_mem] =3D v[B], 128)		// M2
+	br.ctop.sptk .prefetch_loop
+	;;
+	cmp.eq p16, p0 =3D r0, r0			// reset p16 to 1
+	mov ar.lc =3D cnt
+	mov ar.ec =3D N				// # of stages in pipeline
+	;;
+.line_copy:
+EX(.ex_handler,	(p[D])	ld8 t2 =3D [src0], 3*8)			// M0
+EK(.ex_handler,	(p[D])	ld8 t4 =3D [src1], 3*8)			// M1
+EX(.ex_handler_lcpy,	(p[B])	st8 [dst_pre_mem] =3D v[B], 128)		// M2 prefet=
ch dst from memory
+EK(.ex_handler_lcpy,	(p[D])	st8 [dst_pre_l2] =3D n8, 128)		// M3 prefetch =
dst from L2
+	;;
+EX(.ex_handler_lcpy,	(p[A])	ld8 v[A] =3D [src_pre_mem], 128)		// M0 prefet=
ch src from memory
+EK(.ex_handler_lcpy,	(p[C])	ld8 n8 =3D [src_pre_l2], 128)		// M1 prefetch =
src from L2
+EX(.ex_handler,	(p[D])	st8 [dst0] =3D  t1, 8)			// M2
+EK(.ex_handler,	(p[D])	st8 [dst1] =3D  t3, 8)			// M3
+	;;
+EX(.ex_handler,	(p[D])	ld8  t5 =3D [src0], 8)
+EK(.ex_handler,	(p[D])	ld8  t7 =3D [src1], 3*8)
+EX(.ex_handler,	(p[D])	st8 [dst0] =3D  t2, 3*8)
+EK(.ex_handler,	(p[D])	st8 [dst1] =3D  t4, 3*8)
+	;;
+EX(.ex_handler,	(p[D])	ld8  t6 =3D [src0], 3*8)
+EK(.ex_handler,	(p[D])	ld8 t10 =3D [src1], 8)
+EX(.ex_handler,	(p[D])	st8 [dst0] =3D  t5, 8)
+EK(.ex_handler,	(p[D])	st8 [dst1] =3D  t7, 3*8)
+	;;
+EX(.ex_handler,	(p[D])	ld8  t9 =3D [src0], 3*8)
+EK(.ex_handler,	(p[D])	ld8 t11 =3D [src1], 3*8)
+EX(.ex_handler,	(p[D])	st8 [dst0] =3D  t6, 3*8)
+EK(.ex_handler,	(p[D])	st8 [dst1] =3D t10, 8)
+	;;
+EX(.ex_handler,	(p[D])	ld8 t12 =3D [src0], 8)
+EK(.ex_handler,	(p[D])	ld8 t14 =3D [src1], 8)
+EX(.ex_handler,	(p[D])	st8 [dst0] =3D  t9, 3*8)
+EK(.ex_handler,	(p[D])	st8 [dst1] =3D t11, 3*8)
+	;;
+EX(.ex_handler,	(p[D])	ld8 t13 =3D [src0], 4*8)
+EK(.ex_handler,	(p[D])	ld8 t15 =3D [src1], 4*8)
+EX(.ex_handler,	(p[D])	st8 [dst0] =3D t12, 8)
+EK(.ex_handler,	(p[D])	st8 [dst1] =3D t14, 8)
+	;;
+EX(.ex_handler,	(p[C])	ld8  t1 =3D [src0], 8)
+EK(.ex_handler,	(p[C])	ld8  t3 =3D [src1], 8)
+EX(.ex_handler,	(p[D])	st8 [dst0] =3D t13, 4*8)
+EK(.ex_handler,	(p[D])	st8 [dst1] =3D t15, 4*8)
+	br.ctop.sptk .line_copy
+	;;
+
+	add dst0=3D-8,dst0
+	add src0=3D-8,src0
+	mov in2=3Dtmp
+	.restore sp
+	br.sptk.many .medium_copy
+	;;
+
+#define BLOCK_SIZE	128*32
+#define blocksize	r23
+#define curlen		r24
+
+// dest is on 8-byte boundary, src is not. We need to do
+// ld8-ld8, shrp, then st8.  Max 8 byte copy per cycle.
+.unaligned_src:
+	.prologue
+	.save ar.pfs, saved_pfs
+	alloc	saved_pfs=3Dar.pfs,3,5,0,8
+	.save ar.lc, saved_lc
+	mov	saved_lc=3Dar.lc
+	.save pr, saved_pr
+	mov	saved_pr=3Dpr
+	.body
+.4k_block:
+	mov	saved_in0=3Ddst0	// need to save all input arguments
+	mov	saved_in2=3Din2
+	mov	blocksize=3DBLOCK_SIZE
+	;;
+	cmp.lt	p6,p7=3Dblocksize,in2
+	mov	saved_in1=3Dsrc0
+	;;
+(p6)	mov	in2=3Dblocksize
+	;;
+	shr.u	r21=3Din2,7	// this much cache line
+	shr.u	r22=3Din2,4	// number of 16-byte iteration
+	and	curlen=15,in2	// copy length after iteration
+	and	r30=3D7,src0	// source alignment
+	;;
+	cmp.lt	p7,p8=3D1,r21
+	add	cnt=3D-1,r21
+	;;
+
+	add	src_pre_mem=3D0,src0	// prefetch src pointer
+	add	dst_pre_mem=3D0,dst0	// prefetch dest pointer
+	and	src0=3D-8,src0		// 1st src pointer
+(p7)	mov	ar.lc =3D r21
+(p8)	mov	ar.lc =3D r0
+	;;
+	.align 32
+1:	lfetch.fault	  [src_pre_mem], 128
+	lfetch.fault.excl [dst_pre_mem], 128
+	br.cloop.dptk.few 1b
+	;;
+
+	shladd	dst1=3Dr22,3,dst0	// 2nd dest pointer
+	shladd	src1=3Dr22,3,src0	// 2nd src pointer
+	cmp.eq	p8,p9=3Dr22,r0	// do we really need to loop?
+	cmp.le	p6,p7=3D8,curlen;	// have at least 8 byte remaining?
+	add	cnt=3D-1,r22	// ctop iteration adjustment
+	;;
+EX(.ex_handler, (p9)	ld8	r33=3D[src0],8)	// loop primer
+EK(.ex_handler, (p9)	ld8	r37=3D[src1],8)
+(p8)	br.dpnt.few .noloop
+	;;
+
+// The jump address is calculated based on src alignment. The COPYU
+// macro below need to confine its size to power of two, so an entry
+// can be caulated using shl instead of an expensive multiply. The
+// size is then hard coded by the following #define to match the
+// actual size.  This make it somewhat tedious when COPYU macro gets
+// changed and this need to be adjusted to match.
+#define LOOP_SIZE 6
+1:
+	mov	r29=3Dip		// jmp_table thread
+	mov	ar.lc=3Dcnt
+	;;
+	add	r29=3D.jump_table - 1b - (.jmp1-.jump_table), r29
+	shl	r28=3Dr30, LOOP_SIZE	// jmp_table thread
+	mov	ar.ec=3D2		// loop setup
+	;;
+	add	r29=3Dr29,r28		// jmp_table thread
+	cmp.eq	p16,p17=3Dr0,r0
+	;;
+	mov	b6=3Dr29			// jmp_table thread
+	;;
+	br.cond.sptk.few b6
+
+// for 8-15 byte case
+// We will skip the loop, but need to replicate the side effect
+// that the loop produces.
+.noloop:
+EX(.ex_handler, (p6)	ld8	r37=3D[src1],8)
+	add	src0=3D8,src0
+(p6)	shl	r25=3Dr30,3
+	;;
+EX(.ex_handler, (p6)	ld8	r27=3D[src1])
+(p6)	shr.u	r28=3Dr37,r25
+(p6)	sub	r26d,r25
+	;;
+(p6)	shl	r27=3Dr27,r26
+	;;
+(p6)	or	r21=3Dr28,r27
+
+.unaligned_src_tail:
+/* check if we have more than blocksize to copy, if so go back */
+	cmp.gt	p8,p0=3Dsaved_in2,blocksize
+	;;
+(p8)	add	dst0=3Dsaved_in0,blocksize
+(p8)	add	src0=3Dsaved_in1,blocksize
+(p8)	sub	in2=3Dsaved_in2,blocksize
+(p8)	br.dpnt	.4k_block
+	;;
+
+/* we have up to 15 byte to copy in the tail.
+ * part of work is already done in the jump table code
+ * we are at the following state.
+ * src side:
+ *=20
+ *   xxxxxx xx                   <----- r21 has xxxxxxxx already
+ * -------- -------- --------
+ * 0        8        16
+ *          ^
+ *          |
+ *          src1
+ *=20
+ * dst
+ * -------- -------- --------
+ * ^
+ * |
+ * dst1
+ */
+EX(.ex_handler, (p6)	st8	[dst1]=3Dr21,8)	// more than 8 byte to copy
+(p6)	add	curlen=3D-8,curlen	// update length
+	mov	ar.pfs=3Dsaved_pfs
+	;;
+	mov	ar.lc=3Dsaved_lc
+	mov	pr=3Dsaved_pr,-1
+	mov	in2=3Dcurlen	// remaining length
+	mov	dst0=3Ddst1	// dest pointer
+	add	src0=3Dsrc1,r30	// forward by src alignment
+	;;
+
+// 7 byte or smaller.
+.memcpy_short:
+	cmp.le	p8,p9   =3D 1,in2
+	cmp.le	p10,p11 =3D 2,in2
+	cmp.le	p12,p13 =3D 3,in2
+	cmp.le	p14,p15 =3D 4,in2
+	add	src1=3D1,src0	// second src pointer
+	add	dst1=3D1,dst0	// second dest pointer
+	;;
+
+EX(.ex_handler_short, (p8)	ld1	t1=3D[src0],2)
+EK(.ex_handler_short, (p10)	ld1	t2=3D[src1],2)
+(p9)	br.ret.dpnt rp		// 0 byte copy
+	;;
+
+EX(.ex_handler_short, (p8)	st1	[dst0]=3Dt1,2)
+EK(.ex_handler_short, (p10)	st1	[dst1]=3Dt2,2)
+(p11)	br.ret.dpnt rp		// 1 byte copy
+
+EX(.ex_handler_short, (p12)	ld1	t3=3D[src0],2)
+EK(.ex_handler_short, (p14)	ld1	t4=3D[src1],2)
+(p13)	br.ret.dpnt rp		// 2 byte copy
+	;;
+
+	cmp.le	p6,p7   =3D 5,in2
+	cmp.le	p8,p9   =3D 6,in2
+	cmp.le	p10,p11 =3D 7,in2
+
+EX(.ex_handler_short, (p12)	st1	[dst0]=3Dt3,2)
+EK(.ex_handler_short, (p14)	st1	[dst1]=3Dt4,2)
+(p15)	br.ret.dpnt rp		// 3 byte copy
+	;;
+
+EX(.ex_handler_short, (p6)	ld1	t5=3D[src0],2)
+EK(.ex_handler_short, (p8)	ld1	t6=3D[src1],2)
+(p7)	br.ret.dpnt rp		// 4 byte copy
+	;;
+
+EX(.ex_handler_short, (p6)	st1	[dst0]=3Dt5,2)
+EK(.ex_handler_short, (p8)	st1	[dst1]=3Dt6,2)
+(p9)	br.ret.dptk rp		// 5 byte copy
+
+EX(.ex_handler_short, (p10)	ld1	t7=3D[src0],2)
+(p11)	br.ret.dptk rp		// 6 byte copy
+	;;
+
+EX(.ex_handler_short, (p10)	st1	[dst0]=3Dt7,2)
+	br.ret.dptk rp		// done all cases
+
+
+/* Align dest to nearest 8-byte boundary. We know we have at
+ * least 7 bytes to copy, enough to crawl to 8-byte boundary.
+ * Actual number of byte to crawl depend on the dest alignment.
+ * 7 byte or less is taken care at .memcpy_short
+
+ * src0 - source even index
+ * src1 - source  odd index
+ * dst0 - dest even index
+ * dst1 - dest  odd index
+ * r30  - distance to 8-byte boundary
+ */
+
+.align_dest:
+	add	src1=3D1,in1	// source odd index
+	cmp.le	p7,p0 =3D 2,r30	// for .align_dest
+	cmp.le	p8,p0 =3D 3,r30	// for .align_dest
+EX(.ex_handler_short, (p6)	ld1	t1=3D[src0],2)
+	cmp.le	p9,p0 =3D 4,r30	// for .align_dest
+	cmp.le	p10,p0 =3D 5,r30
+	;;
+EX(.ex_handler_short, (p7)	ld1	t2=3D[src1],2)
+EK(.ex_handler_short, (p8)	ld1	t3=3D[src0],2)
+	cmp.le	p11,p0 =3D 6,r30
+EX(.ex_handler_short, (p6)	st1	[dst0] =3D t1,2)
+	cmp.le	p12,p0 =3D 7,r30
+	;;
+EX(.ex_handler_short, (p9)	ld1	t4=3D[src1],2)
+EK(.ex_handler_short, (p10)	ld1	t5=3D[src0],2)
+EX(.ex_handler_short, (p7)	st1	[dst1] =3D t2,2)
+EK(.ex_handler_short, (p8)	st1	[dst0] =3D t3,2)
+	;;
+EX(.ex_handler_short, (p11)	ld1	t6=3D[src1],2)
+EK(.ex_handler_short, (p12)	ld1	t7=3D[src0],2)
+	cmp.eq	p6,p7=3Dr28,r29
+EX(.ex_handler_short, (p9)	st1	[dst1] =3D t4,2)
+EK(.ex_handler_short, (p10)	st1	[dst0] =3D t5,2)
+	sub	in2=3Din2,r30
+	;;
+EX(.ex_handler_short, (p11)	st1	[dst1] =3D t6,2)
+EK(.ex_handler_short, (p12)	st1	[dst0] =3D t7)
+	add	dst0=3Din0,r30	// setup arguments
+	add	src0=3Din1,r30
+(p6)	br.cond.dptk .aligned_src
+(p7)	br.cond.dpnt .unaligned_src
+	;;
+
+/* main loop body in jump table format */
+#define COPYU(shift)									\
+1:											\
+EX(.ex_handler,  (p16)	ld8	r32=3D[src0],8);		/* 1 */				\
+EK(.ex_handler,  (p16)	ld8	r36=3D[src1],8);						\
+		 (p17)	shrp	r35=3Dr33,r34,shift;;	/* 1 */				\
+EX(.ex_handler,  (p6)	ld8	r22=3D[src1]);	/* common, prime for tail section=
 */	\
+		 nop.m	0;								\
+		 (p16)	shrp	r38=3Dr36,r37,shift;					\
+EX(.ex_handler,  (p17)	st8	[dst0]=3Dr35,8);		/* 1 */				\
+EK(.ex_handler,  (p17)	st8	[dst1]=3Dr39,8);						\
+		 br.ctop.dptk.few 1b;;							\
+		 (p7)	add	src1=3D-8,src1;	/* back out for <8 byte case */		\
+		 shrp	r21=3Dr22,r38,shift;	/* speculative work */			\
+		 br.sptk.few .unaligned_src_tail /* branch out of jump table */		\
+		 ;;
+	.align 32
+.jump_table:
+	COPYU(8)	// unaligned cases
+.jmp1:
+	COPYU(16)
+	COPYU(24)
+	COPYU(32)
+	COPYU(40)
+	COPYU(48)
+	COPYU(56)
+
+#undef A
+#undef B
+#undef C
+#undef D
+END(memcpy)
+
+/*
+ * Due to lack of local tag support in gcc 2.x assembler, it is not clear =
which
+ * instruction failed in the bundle.  The exception algorithm is that we
+ * first figure out the faulting address, then detect if there is any
+ * progress made on the copy, if so, redo the copy from last known copied
+ * location up to the faulting address (exclusive). In the copy_from_user
+ * case, remaining byte in kernel buffer will be zeroed.
+ *
+ * Take copy_from_user as an example, in the code there are multiple loads
+ * in a bundle and those multiple loads could span over two pages, the
+ * faulting address is calculated as page_round_down(max(src0, src1)).
+ * This is based on knowledge that if we can access one byte in a page, we
+ * can access any byte in that page.
+ *
+ * predicate used in the exception handler:
+ * p6-p7: direction
+ * p10-p11: src faulting addr calculation
+ * p12-p13: dst faulting addr calculation
+ */
+
+#define A	r19
+#define B	r20
+#define C	r21
+#define D	r22
+#define F	r28
+
+#define memset_arg0	r32
+#define memset_arg2	r33
+
+#define saved_retval	loc0
+#define saved_rtlink	loc1
+#define saved_pfs_stack	loc2
+
+.ex_hndlr_s:
+	add	src0=3D8,src0
+	br.sptk .ex_handler
+	;;
+.ex_hndlr_d:
+	add	dst0=3D8,dst0
+	br.sptk .ex_handler
+	;;
+.ex_hndlr_lcpy_1:
+	mov	src1=3Dsrc_pre_mem
+	mov	dst1=3Ddst_pre_mem
+	cmp.gtu	p10,p11=3Dsrc_pre_mem,saved_in1
+	cmp.gtu	p12,p13=3Ddst_pre_mem,saved_in0
+	;;
+(p10)	add	src0=3D8,saved_in1
+(p11)	mov	src0=3Dsaved_in1
+(p12)	add	dst0=3D8,saved_in0
+(p13)	mov	dst0=3Dsaved_in0
+	br.sptk	.ex_handler
+.ex_handler_lcpy:
+	// in line_copy block, the preload addresses should always ahead
+	// of the other two src/dst pointers.  Furthermore, src1/dst1 should
+	// always ahead of src0/dst0.
+	mov	src1=3Dsrc_pre_mem
+	mov	dst1=3Ddst_pre_mem
+.ex_handler:
+	mov	pr=3Dsaved_pr,-1		// first restore pr, lc, and pfs
+	mov	ar.lc=3Dsaved_lc
+	mov	ar.pfs=3Dsaved_pfs
+	;;
+.ex_handler_short: // fault occurred in these sections didn't change pr, l=
c, pfs
+	cmp.ltu	p6,p7=3Dsaved_in0, saved_in1	// get the copy direction
+	cmp.ltu	p10,p11=3Dsrc0,src1
+	cmp.ltu	p12,p13=3Ddst0,dst1
+	fcmp.eq	p8,p0=F6,f0		// is it memcpy?
+	mov	tmp =3D dst0
+	;;
+(p11)	mov	src1 =3D src0		// pick the larger of the two
+(p13)	mov	dst0 =3D dst1		// make dst0 the smaller one
+(p13)	mov	dst1 =3D tmp		// and dst1 the larger one
+	;;
+(p6)	dep	F =3D r0,dst1,0,PAGE_SHIFT // usr dst round down to page boundary
+(p7)	dep	F =3D r0,src1,0,PAGE_SHIFT // usr src round down to page boundary
+	;;
+(p6)	cmp.le	p14,p0=3Ddst0,saved_in0	// no progress has been made on store
+(p7)	cmp.le	p14,p0=3Dsrc0,saved_in1	// no progress has been made on load
+	mov	retval=3Dsaved_in2
+(p8)	ld1	tmp=3D[src1]		// force an oops for memcpy call
+(p8)	st1	[dst1]=3Dr0		// force an oops for memcpy call
+(p14)	br.ret.sptk.many rp
+
+/*
+ * The remaining byte to copy is calculated as:
+ *
+ * A =3D	(faulting_addr - orig_src)	-> len to faulting ld address
+ *	or=20
+ * 	(faulting_addr - orig_dst)	-> len to faulting st address
+ * B =3D	(cur_dst - orig_dst)		-> len copied so far
+ * C =3D	A - B				-> len need to be copied
+ * D =3D	orig_len - A			-> len need to be zeroed
+ */
+(p6)	sub	A =3D F, saved_in0
+(p7)	sub	A =3D F, saved_in1
+	clrrrb
+	;;
+	alloc	saved_pfs_stack=3Dar.pfs,3,3,3,0
+	sub	B =3D dst0, saved_in0	// how many byte copied so far
+	;;
+	sub	C =3D A, B
+	sub	D =3D saved_in2, A
+	;;
+	cmp.gt	p8,p0=3DC,r0		// more than 1 byte?
+	add	memset_arg0=3Dsaved_in0, A
+(p6)	mov	memset_arg2=3D0		// copy_to_user should not call memset
+(p7)	mov	memset_arg2=3DD		// copy_from_user need to have kbuf zeroed
+	mov	r8=3D0
+	mov	saved_retval =3D D
+	mov	saved_rtlink =3D b0
+
+	add	out0=3Dsaved_in0, B
+	add	out1=3Dsaved_in1, B
+	mov	out2=3DC
+(p8)	br.call.sptk.few b0=3D__copy_user	// recursive call
+	;;
+
+	add	saved_retval=3Dsaved_retval,r8	// above might return non-zero value
+	cmp.gt	p8,p0=3Dmemset_arg2,r0	// more than 1 byte?
+	mov	out0=3Dmemset_arg0	// *s
+	mov	out1=3Dr0			// c
+	mov	out2=3Dmemset_arg2	// n
+(p8)	br.call.sptk.few b0=3Dmemset
+	;;
+
+	mov	retval=3Dsaved_retval
+	mov	ar.pfs=3Dsaved_pfs_stack
+	mov	b0=3Dsaved_rtlink
+	br.ret.sptk.many rp
+
+/* end of McKinley specific optimization */
+END(__copy_user)
diff -Nru a/arch/ia64/lib/swiotlb.c b/arch/ia64/lib/swiotlb.c
--- a/arch/ia64/lib/swiotlb.c	Sat Aug 10 01:51:47 2002
+++ b/arch/ia64/lib/swiotlb.c	Sat Aug 10 01:51:47 2002
@@ -415,18 +415,21 @@
 swiotlb_map_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelems,=
 int direction)
 {
 	void *addr;
+	unsigned long pci_addr;
 	int i;
=20
 	if (direction =3D PCI_DMA_NONE)
 		BUG();
=20
 	for (i =3D 0; i < nelems; i++, sg++) {
-		sg->orig_address =3D SG_ENT_VIRT_ADDRESS(sg);
-		if ((SG_ENT_PHYS_ADDRESS(sg) & ~hwdev->dma_mask) !=3D 0) {
-			addr =3D map_single(hwdev, sg->orig_address, sg->length, direction);
-			sg->page =3D virt_to_page(addr);
-			sg->offset =3D (u64) addr & ~PAGE_MASK;
-		}
+		addr =3D SG_ENT_VIRT_ADDRESS(sg);
+		pci_addr =3D virt_to_phys(addr);
+		if ((pci_addr & ~hwdev->dma_mask) !=3D 0)
+			sg->dma_address =3D (dma_addr_t)
+				map_single(hwdev, addr, sg->length, direction);
+		else
+			sg->dma_address =3D pci_addr;
+		sg->dma_length =3D sg->length;
 	}
 	return nelems;
 }
@@ -444,12 +447,10 @@
 		BUG();
=20
 	for (i =3D 0; i < nelems; i++, sg++)
-		if (sg->orig_address !=3D SG_ENT_VIRT_ADDRESS(sg)) {
-			unmap_single(hwdev, SG_ENT_VIRT_ADDRESS(sg), sg->length, direction);
-			sg->page =3D virt_to_page(sg->orig_address);
-			sg->offset =3D (u64) sg->orig_address & ~PAGE_MASK;
-		} else if (direction =3D PCI_DMA_FROMDEVICE)
-			mark_clean(SG_ENT_VIRT_ADDRESS(sg), sg->length);
+		if (sg->dma_address !=3D SG_ENT_PHYS_ADDRESS(sg))
+			unmap_single(hwdev, (void *) sg->dma_address, sg->dma_length, direction=
);
+		else if (direction =3D PCI_DMA_FROMDEVICE)
+			mark_clean(SG_ENT_VIRT_ADDRESS(sg), sg->dma_length);
 }
=20
 /*
@@ -468,14 +469,14 @@
 		BUG();
=20
 	for (i =3D 0; i < nelems; i++, sg++)
-		if (sg->orig_address !=3D SG_ENT_VIRT_ADDRESS(sg))
-			sync_single(hwdev, SG_ENT_VIRT_ADDRESS(sg), sg->length, direction);
+		if (sg->dma_address !=3D SG_ENT_PHYS_ADDRESS(sg))
+			sync_single(hwdev, (void *) sg->dma_address, sg->dma_length, direction);
 }
=20
 unsigned long
 swiotlb_dma_address (struct scatterlist *sg)
 {
-	return SG_ENT_PHYS_ADDRESS(sg);
+	return sg->dma_address;
 }
=20
 /*
diff -Nru a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/mm/init.c	Sat Aug 10 01:51:46 2002
@@ -10,6 +10,7 @@
=20
 #include <linux/bootmem.h>
 #include <linux/mm.h>
+#include <linux/personality.h>
 #include <linux/reboot.h>
 #include <linux/slab.h>
 #include <linux/swap.h>
@@ -68,10 +69,9 @@
 	struct vm_area_struct *vma;
=20
 	/*
-	 * If we're out of memory and kmem_cache_alloc() returns NULL,
-	 * we simply ignore the problem.  When the process attempts to
-	 * write to the register backing store for the first time, it
-	 * will get a SEGFAULT in this case.
+	 * If we're out of memory and kmem_cache_alloc() returns NULL, we simply =
ignore
+	 * the problem.  When the process attempts to write to the register backi=
ng store
+	 * for the first time, it will get a SEGFAULT in this case.
 	 */
 	vma =3D kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
 	if (vma) {
@@ -86,6 +86,19 @@
 		vma->vm_private_data =3D NULL;
 		insert_vm_struct(current->mm, vma);
 	}
+
+	/* map NaT-page at address zero to speed up speculative dereferencing of =
NULL: */
+	if (!(current->personality & MMAP_PAGE_ZERO)) {
+		vma =3D kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+		if (vma) {
+			memset(vma, 0, sizeof(*vma));
+			vma->vm_mm =3D current->mm;
+			vma->vm_end =3D PAGE_SIZE;
+			vma->vm_page_prot =3D __pgprot(pgprot_val(PAGE_READONLY) | _PAGE_MA_NAT=
);
+			vma->vm_flags =3D VM_READ | VM_MAYREAD | VM_IO | VM_RESERVED;
+			insert_vm_struct(current->mm, vma);
+		}
+	}
 }
=20
 void
@@ -95,7 +108,7 @@
=20
 	addr =3D (unsigned long) &__init_begin;
 	for (; addr < (unsigned long) &__init_end; addr +=3D PAGE_SIZE) {
-		clear_bit(PG_reserved, &virt_to_page(addr)->flags);
+		ClearPageReserved(virt_to_page(addr));
 		set_page_count(virt_to_page(addr), 1);
 		free_page(addr);
 		++totalram_pages;
@@ -149,9 +162,9 @@
 		if (!virt_addr_valid(start))
 			continue;
 		page =3D virt_to_page(start);
-		clear_bit(PG_reserved, &page->flags);
+		ClearPageReserved(page);
 		set_page_count(page, 1);
-		__free_page(page);
+		free_page(start);
 		++totalram_pages;
 	}
 }
diff -Nru a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
--- a/arch/ia64/mm/tlb.c	Sat Aug 10 01:51:47 2002
+++ b/arch/ia64/mm/tlb.c	Sat Aug 10 01:51:47 2002
@@ -35,12 +35,14 @@
 		1 << _PAGE_SIZE_4K )
=20
 struct ia64_ctx ia64_ctx =3D {
-	lock:	SPIN_LOCK_UNLOCKED,
-	next:	1,
-	limit:	(1 << 15) - 1,		/* start out with the safe (architected) limit */
-	max_ctx: ~0U
+	.lock =3D		SPIN_LOCK_UNLOCKED,
+	.next =3D		1,
+	.limit =3D	(1 << 15) - 1,		/* start out with the safe (architected) limit=
 */
+	.max_ctx =3D	~0U
 };
=20
+u8 ia64_need_tlb_flush __per_cpu_data;
+
 /*
  * Acquire the ia64_ctx.lock before calling this function!
  */
@@ -49,6 +51,7 @@
 {
 	unsigned long tsk_context, max_ctx =3D ia64_ctx.max_ctx;
 	struct task_struct *tsk;
+	int i;
=20
 	if (ia64_ctx.next > max_ctx)
 		ia64_ctx.next =3D 300;	/* skip daemons */
@@ -77,7 +80,11 @@
 			ia64_ctx.limit =3D tsk_context;
 	}
 	read_unlock(&tasklist_lock);
-	flush_tlb_all();
+	/* can't call flush_tlb_all() here because of race condition with O(1) sc=
heduler [EF] */
+	for (i =3D 0; i < NR_CPUS; ++i)
+		if (i !=3D smp_processor_id())
+			per_cpu(ia64_need_tlb_flush, i) =3D 1;
+	__flush_tlb_all();
 }
=20
 void
diff -Nru a/arch/ia64/sn/io/ifconfig_net.c b/arch/ia64/sn/io/ifconfig_net.c
--- a/arch/ia64/sn/io/ifconfig_net.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/sn/io/ifconfig_net.c	Sat Aug 10 01:51:46 2002
@@ -279,9 +279,9 @@
 }
=20
 struct file_operations ifconfig_net_fops =3D {
-	ioctl:ifconfig_net_ioctl,	/* ioctl */
-	open:ifconfig_net_open,		/* open */
-	release:ifconfig_net_close	/* release */
+	.ioctl =3Difconfig_net_ioctl,	/* ioctl */
+	.open =3Difconfig_net_open,		/* open */
+	.release =3Difconfig_net_close	/* release */
 };
=20
=20
diff -Nru a/arch/ia64/sn/io/pciba.c b/arch/ia64/sn/io/pciba.c
--- a/arch/ia64/sn/io/pciba.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/sn/io/pciba.c	Sat Aug 10 01:51:46 2002
@@ -210,31 +210,31 @@
=20
 /* file operations for each type of node */
 static struct file_operations rom_fops =3D {
-	owner:		THIS_MODULE,
-	mmap:		rom_mmap,
-	open:		generic_open,
-	release:	rom_release
+	.owner =3D	THIS_MODULE,
+	.mmap =3D		rom_mmap,
+	.open =3D		generic_open,
+	.release =3D	rom_release
 };
 =20
=20
 static struct file_operations base_fops =3D {
-	owner:		THIS_MODULE,
-	mmap:		base_mmap,
-	open:		generic_open
+	.owner =3D	THIS_MODULE,
+	.mmap =3D		base_mmap,
+	.open =3D		generic_open
 };
=20
=20
 static struct file_operations config_fops =3D {
-	owner:		THIS_MODULE,
-	ioctl:		config_ioctl,
-	open:		generic_open
+	.owner =3D	THIS_MODULE,
+	.ioctl =3D	config_ioctl,
+	.open =3D		generic_open
 };=09
=20
 static struct file_operations dma_fops =3D {
-	owner:		THIS_MODULE,
-	ioctl:		dma_ioctl,
-	mmap:		dma_mmap,
-	open:		generic_open
+	.owner =3D	THIS_MODULE,
+	.ioctl =3D	dma_ioctl,
+	.mmap =3D		dma_mmap,
+	.open =3D		generic_open
 };=09
=20
=20
diff -Nru a/arch/ia64/sn/io/sn1/hubcounters.c b/arch/ia64/sn/io/sn1/hubcoun=
ters.c
--- a/arch/ia64/sn/io/sn1/hubcounters.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/sn/io/sn1/hubcounters.c	Sat Aug 10 01:51:46 2002
@@ -24,7 +24,7 @@
=20
 static int hubstats_ioctl(struct inode *, struct file *, unsigned int, uns=
igned long);
 struct file_operations hub_mon_fops =3D {
-        ioctl:          hubstats_ioctl,
+        .ioctl =3D        hubstats_ioctl,
 };
=20
 #define HUB_CAPTURE_TICKS	(2 * HZ)
diff -Nru a/arch/ia64/sn/io/sn1/pcibr.c b/arch/ia64/sn/io/sn1/pcibr.c
--- a/arch/ia64/sn/io/sn1/pcibr.c	Sat Aug 10 01:51:47 2002
+++ b/arch/ia64/sn/io/sn1/pcibr.c	Sat Aug 10 01:51:47 2002
@@ -307,22 +307,22 @@
  * appropriate function name below.
  */
 struct file_operations pcibr_fops =3D {
-        owner:  THIS_MODULE,
-        llseek: NULL,
-        read: NULL,
-        write: NULL,
-        readdir: NULL,
-        poll: NULL,
-        ioctl: NULL,
-        mmap: NULL,
-        open: NULL,
-        flush: NULL,
-        release: NULL,
-        fsync: NULL,
-        fasync: NULL,
-        lock: NULL,
-        readv: NULL,
-        writev: NULL
+        .owner =3D THIS_MODULE,
+        .llseek =3D NULL,
+        .read =3D NULL,
+        .write =3D NULL,
+        .readdir =3D NULL,
+        .poll =3D NULL,
+        .ioctl =3D NULL,
+        .mmap =3D NULL,
+        .open =3D NULL,
+        .flush =3D NULL,
+        .release =3D NULL,
+        .fsync =3D NULL,
+        .fasync =3D NULL,
+        .lock =3D NULL,
+        .readv =3D NULL,
+        .writev =3D NULL
 };
=20
 extern devfs_handle_t hwgraph_root;
diff -Nru a/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c b/arch/ia64/sn/io/sn2/pci=
br/pcibr_dvr.c
--- a/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	Sat Aug 10 01:51:46 2002
@@ -64,22 +64,22 @@
  * appropriate function name below.
  */
 struct file_operations pcibr_fops =3D {
-	owner:  THIS_MODULE,
-	llseek: NULL,
-	read: NULL,
-	write: NULL,
-	readdir: NULL,
-	poll: NULL,
-	ioctl: NULL,
-	mmap: NULL,
-	open: NULL,
-	flush: NULL,
-	release: NULL,
-	fsync: NULL,
-	fasync: NULL,
-	lock: NULL,
-	readv: NULL,
-	writev: NULL
+	.owner =3DTHIS_MODULE,
+	.llseek =3D NULL,
+	.read =3D NULL,
+	.write =3D NULL,
+	.readdir =3D NULL,
+	.poll =3D NULL,
+	.ioctl =3D NULL,
+	.mmap =3D NULL,
+	.open =3D NULL,
+	.flush =3D NULL,
+	.release =3D NULL,
+	.fsync =3D NULL,
+	.fasync =3D NULL,
+	.lock =3D NULL,
+	.readv =3D NULL,
+	.writev =3D NULL
 };
=20
 #ifdef LATER
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/sn/kernel/setup.c	Sat Aug 10 01:51:46 2002
@@ -109,14 +109,14 @@
  * VGA color display.
  */
 struct screen_info sn1_screen_info =3D {
-	orig_x:			 0,
-	orig_y:			 0,
-	orig_video_mode:	 3,
-	orig_video_cols:	80,
-	orig_video_ega_bx:	 3,
-	orig_video_lines:	25,
-	orig_video_isVGA:	 1,
-	orig_video_points:	16
+	.orig_x =3D		 0,
+	.orig_y =3D		 0,
+	.orig_video_mode =3D	 3,
+	.orig_video_cols =3D	80,
+	.orig_video_ega_bx =3D	 3,
+	.orig_video_lines =3D	25,
+	.orig_video_isVGA =3D	 1,
+	.orig_video_points =3D	16
 };
=20
 /*
@@ -170,9 +170,9 @@
 #ifdef NOT_YET_CONFIG_IA64_MCA
 extern void ia64_mca_cpe_int_handler (int cpe_irq, void *arg, struct pt_re=
gs *ptregs);
 static struct irqaction mca_cpe_irqaction =3D {=20
-	handler:    ia64_mca_cpe_int_handler,
-	flags:      SA_INTERRUPT,
-	name:       "cpe_hndlr"
+	.handler =3D  ia64_mca_cpe_int_handler,
+	.flags =3D    SA_INTERRUPT,
+	.name =3D     "cpe_hndlr"
 };
 #endif
 #ifdef CONFIG_IA64_MCA
diff -Nru a/arch/ia64/tools/Makefile b/arch/ia64/tools/Makefile
--- a/arch/ia64/tools/Makefile	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/tools/Makefile	Sat Aug 10 01:51:46 2002
@@ -4,7 +4,9 @@
=20
 all:
=20
-mrproper:
+fastdep:
+
+mrproper: clean
=20
 clean:
 	rm -f print_offsets.s print_offsets offsets.h
diff -Nru a/arch/ia64/vmlinux.lds.S b/arch/ia64/vmlinux.lds.S
--- a/arch/ia64/vmlinux.lds.S	Sat Aug 10 01:51:46 2002
+++ b/arch/ia64/vmlinux.lds.S	Sat Aug 10 01:51:46 2002
@@ -41,9 +41,6 @@
=20
   /* Read-only data */
=20
-  . =3D ALIGN(16);
-  __gp =3D . + 0x200000;	/* gp must be 16-byte aligned for exc. table */
-
   /* Global data */
   _data =3D .;
=20
@@ -145,6 +142,9 @@
=20
   .data : AT(ADDR(.data) - PAGE_OFFSET)
 	{ *(.data) *(.gnu.linkonce.d*) CONSTRUCTORS }
+
+  . =3D ALIGN(16);
+  __gp =3D . + 0x200000;	/* gp must be 16-byte aligned for exc. table */
=20
   .got : AT(ADDR(.got) - PAGE_OFFSET)
 	{ *(.got.plt) *(.got) }
diff -Nru a/arch/parisc/kernel/traps.c b/arch/parisc/kernel/traps.c
--- a/arch/parisc/kernel/traps.c	Sat Aug 10 01:51:47 2002
+++ b/arch/parisc/kernel/traps.c	Sat Aug 10 01:51:47 2002
@@ -43,7 +43,6 @@
=20
 static inline void console_verbose(void)
 {
-	extern int console_loglevel;
 	console_loglevel =3D 15;
 }
=20
diff -Nru a/drivers/acpi/bus.c b/drivers/acpi/bus.c
--- a/drivers/acpi/bus.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/acpi/bus.c	Sat Aug 10 01:51:46 2002
@@ -2167,6 +2167,6 @@
 	return 1;
 }
=20
-subsys_initcall(acpi_init);
+arch_initcall(acpi_init); /* XXX fix me: should be subsys_initcall */
=20
 __setup("acpi=3D", acpi_setup);
diff -Nru a/drivers/acpi/osl.c b/drivers/acpi/osl.c
--- a/drivers/acpi/osl.c	Sat Aug 10 01:51:47 2002
+++ b/drivers/acpi/osl.c	Sat Aug 10 01:51:47 2002
@@ -80,6 +80,7 @@
 	 * it while walking the namespace (bus 0 and root bridges w/ _BBNs).
 	 */
 #ifdef CONFIG_ACPI_PCI
+	pcibios_config_init();
 	if (!pci_config_read || !pci_config_write) {
 		printk(KERN_ERR PREFIX "Access to PCI configuration space unavailable\n"=
);
 		return AE_NULL_ENTRY;
@@ -176,10 +177,10 @@
 acpi_os_map_memory(ACPI_PHYSICAL_ADDRESS phys, ACPI_SIZE size, void **virt)
 {
 #ifdef CONFIG_ACPI_EFI
-	if (!(EFI_MEMORY_WB & efi_mem_attributes(phys))) {
-		*virt =3D ioremap(phys, size);
-	} else {
+	if (EFI_MEMORY_WB & efi_mem_attributes(phys)) {
 		*virt =3D phys_to_virt(phys);
+	} else {
+		*virt =3D ioremap(phys, size);
 	}
 #else
 	if (phys > ULONG_MAX) {
@@ -351,8 +352,7 @@
=20
 	if (EFI_MEMORY_WB & efi_mem_attributes(phys_addr)) {
 		virt_addr =3D phys_to_virt(phys_addr);
-	}
-	else {
+	} else {
 		iomem =3D 1;
 		virt_addr =3D ioremap(phys_addr, width);
 	}
@@ -397,8 +397,7 @@
=20
 	if (EFI_MEMORY_WB & efi_mem_attributes(phys_addr)) {
 		virt_addr =3D phys_to_virt(phys_addr);
-	}
-	else {
+	} else {
 		iomem =3D 1;
 		virt_addr =3D ioremap(phys_addr, width);
 	}
diff -Nru a/drivers/acpi/pci_irq.c b/drivers/acpi/pci_irq.c
--- a/drivers/acpi/pci_irq.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/acpi/pci_irq.c	Sat Aug 10 01:51:46 2002
@@ -33,7 +33,9 @@
 #include <linux/pm.h>
 #include <linux/pci.h>
 #include <linux/acpi.h>
+#ifdef CONFIG_X86_IO_APIC
 #include <asm/mpspec.h>
+#endif
 #include "acpi_bus.h"
 #include "acpi_drivers.h"
=20
diff -Nru a/drivers/char/agp/agp.c b/drivers/char/agp/agp.c
--- a/drivers/char/agp/agp.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/agp/agp.c	Sat Aug 10 01:51:46 2002
@@ -25,6 +25,7 @@
  * TODO:=20
  * - Allocate more than order 0 pages to avoid too much linear map splitti=
ng.
  */
+
 #include <linux/config.h>
 #include <linux/module.h>
 #include <linux/pci.h>
@@ -33,6 +34,7 @@
 #include <linux/miscdevice.h>
 #include <linux/pm.h>
 #include <linux/agp_backend.h>
+#include <linux/vmalloc.h>
 #include "agp.h"
=20
 MODULE_AUTHOR("Jeff Hartmann <jhartmann@precisioninsight.com>");
@@ -134,6 +136,9 @@
 {
 	int i;
=20
+	pr_debug("agp_free_memory(curr=3D%p): type=3D%u, page_count=3D%Zu\n",
+		 curr, curr->type, curr->page_count);
+
 	if ((agp_bridge.type =3D NOT_SUPPORTED) || (curr =3D NULL))
 		return;
=20
@@ -146,7 +151,6 @@
 	}
 	if (curr->page_count !=3D 0) {
 		for (i =3D 0; i < curr->page_count; i++) {
-			curr->memory[i] &=3D ~(0x00000fff);
 			agp_bridge.agp_destroy_page(phys_to_virt(curr->memory[i]));
 		}
 	}
@@ -164,6 +168,8 @@
 	agp_memory *new;
 	int i;
=20
+	pr_debug("agp_allocate_memory(count=3D%Zu, type=3D%u)\n", page_count, typ=
e);
+
 	if (agp_bridge.type =3D NOT_SUPPORTED)
 		return NULL;
=20
@@ -199,12 +205,13 @@
 			agp_free_memory(new);
 			return NULL;
 		}
-		new->memory[i] =3D agp_bridge.mask_memory(virt_to_phys(addr), type);
+		new->memory[i] =3D virt_to_phys(addr);
 		new->page_count++;
 	}
=20
 	flush_agp_mappings();
=20
+	pr_debug("agp_allocate_memory: new=3D%p\n", new);
 	return new;
 }
=20
@@ -648,7 +655,7 @@
 	}
=20
 	for (i =3D 0, j =3D pg_start; i < mem->page_count; i++, j++)
-		agp_bridge.gatt_table[j] =3D mem->memory[i];
+		agp_bridge.gatt_table[j] =3D agp_bridge.mask_memory(mem->memory[i], mem-=
>type);
=20
 	agp_bridge.tlb_flush(mem);
 	return 0;
@@ -967,6 +974,17 @@
=20
 #endif /* CONFIG_AGP_INTEL */
=20
+#ifdef CONFIG_AGP_I460
+	{
+		.device_id	=3D PCI_DEVICE_ID_INTEL_460GX,
+		.vendor_id	=3D PCI_VENDOR_ID_INTEL,
+		.chipset	=3D INTEL_460GX,
+		.vendor_name	=3D "Intel",
+		.chipset_name	=3D "460GX",
+		.chipset_setup	=3D intel_i460_setup
+	},
+#endif
+
 #ifdef CONFIG_AGP_SIS
 	{
 		.device_id	=3D PCI_DEVICE_ID_SI_740,
@@ -1610,6 +1628,35 @@
 =09
 	pm_register(PM_PCI_DEV, PM_PCI_ID(agp_bridge.dev), agp_power);
 	return 0;
+}
+
+int agp_map_page (unsigned long vaddr, unsigned long paddr)
+{
+	unsigned long pfn =3D paddr >> PAGE_SHIFT;
+	pgd_t *pgd;
+	pmd_t *pmd;
+	pte_t *pte;
+	int ret;
+
+	pgd =3D pgd_offset_k(vaddr);
+	spin_lock(&init_mm.page_table_lock);
+	do {
+		pmd =3D pmd_alloc(&init_mm, pgd, vaddr);
+		ret =3D -ENOMEM;
+		if (!pmd)
+			break;
+		pte =3D pte_alloc_kernel(&init_mm, pmd, vaddr);
+		if (!pte)
+			break;
+		if (!pte_none(*pte)) {
+			printk("drm_remap_page: page already exists\n");
+			BUG();
+		}
+		set_pte(pte, pfn_pte(pfn, PAGE_KERNEL));
+		ret =3D 0;
+	} while (0);
+	spin_unlock(&init_mm.page_table_lock);
+	return ret;
 }
=20
 static struct pci_device_id agp_pci_table[] __initdata =3D {
diff -Nru a/drivers/char/agp/agp.h b/drivers/char/agp/agp.h
--- a/drivers/char/agp/agp.h	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/agp/agp.h	Sat Aug 10 01:51:46 2002
@@ -82,7 +82,7 @@
 	flush_agp_cache();
 }
 #else
-static void global_cache_flush(void)
+static void __attribute__((unused)) global_cache_flush(void)
 {
 	flush_agp_cache();
 }
diff -Nru a/drivers/char/agp/amd-agp.c b/drivers/char/agp/amd-agp.c
--- a/drivers/char/agp/amd-agp.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/agp/amd-agp.c	Sat Aug 10 01:51:46 2002
@@ -330,7 +330,7 @@
 	for (i =3D 0, j =3D pg_start; i < mem->page_count; i++, j++) {
 		addr =3D (j * PAGE_SIZE) + agp_bridge.gart_bus_addr;
 		cur_gatt =3D GET_GATT(addr);
-		cur_gatt[GET_GATT_OFF(addr)] =3D mem->memory[i];
+		cur_gatt[GET_GATT_OFF(addr)] =3D agp_bridge.mask_memory(mem->memory[i], =
mem->type);
 	}
 	agp_bridge.tlb_flush(mem);
 	return 0;
diff -Nru a/drivers/char/agp/hp-agp.c b/drivers/char/agp/hp-agp.c
--- a/drivers/char/agp/hp-agp.c	Sat Aug 10 01:51:47 2002
+++ b/drivers/char/agp/hp-agp.c	Sat Aug 10 01:51:47 2002
@@ -43,8 +43,7 @@
 #define HP_ZX1_SBA_IOMMU_COOKIE	0x0000badbadc0ffeeUL
=20
 #define HP_ZX1_PDIR_VALID_BIT	0x8000000000000000UL
-#define HP_ZX1_IOVA_TO_PDIR(va)	((va - hp_private.iova_base) >> \
-					hp_private.io_tlb_shift)
+#define HP_ZX1_IOVA_TO_PDIR(va)	((va - hp_private.iova_base) >> hp_private=
.io_tlb_shift)
=20
 static struct aper_size_info_fixed hp_zx1_sizes[]  {
@@ -357,12 +356,7 @@
 	return HP_ZX1_PDIR_VALID_BIT | addr;
 }
=20
-static unsigned long hp_zx1_unmask_memory(unsigned long addr)
-{
-	return addr & ~(HP_ZX1_PDIR_VALID_BIT);
-}
-
-int __init hp_zx1_setup (struct pci_dev *pdev)
+int __init hp_zx1_setup (struct pci_dev *pdev __attribute__((unused)))
 {
 	agp_bridge.masks =3D hp_zx1_masks;
 	agp_bridge.num_of_masks =3D 1;
@@ -374,7 +368,6 @@
 	agp_bridge.cleanup =3D hp_zx1_cleanup;
 	agp_bridge.tlb_flush =3D hp_zx1_tlbflush;
 	agp_bridge.mask_memory =3D hp_zx1_mask_memory;
-	agp_bridge.unmask_memory =3D hp_zx1_unmask_memory;
 	agp_bridge.agp_enable =3D agp_generic_agp_enable;
 	agp_bridge.cache_flush =3D global_cache_flush;
 	agp_bridge.create_gatt_table =3D hp_zx1_create_gatt_table;
@@ -388,7 +381,4 @@
 	agp_bridge.cant_use_aperture =3D 1;
=20
 	return hp_zx1_ioc_init();
-
-	(void) pdev; /* unused */
 }
-
diff -Nru a/drivers/char/agp/i460-agp.c b/drivers/char/agp/i460-agp.c
--- a/drivers/char/agp/i460-agp.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/agp/i460-agp.c	Sat Aug 10 01:51:46 2002
@@ -4,6 +4,9 @@
  * Copyright (C) 1999 Precision Insight, Inc.
  * Copyright (C) 1999 Xi Graphics, Inc.
  *
+ * 460GX support by Chris Ahna <christopher.j.ahna@intel.com>
+ * Clean up & simplification by David Mosberger-Tang <davidm@hpl.hp.com>
+ *
  * Permission is hereby granted, free of charge, to any person obtaining a
  * copy of this software and associated documentation files (the "Software=
"),
  * to deal in the Software without restriction, including without limitati=
on
@@ -17,55 +20,105 @@
  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
  * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABIL=
ITY,
  * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
- * JEFF HARTMANN, OR ANY OTHER CONTRIBUTORS BE LIABLE FOR ANY CLAIM,=20
- * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR=20
- * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE=20
+ * JEFF HARTMANN, OR ANY OTHER CONTRIBUTORS BE LIABLE FOR ANY CLAIM,
+ * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
+ * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  *
- * TODO:=20
+ * TODO:
  * - Allocate more than order 0 pages to avoid too much linear map splitti=
ng.
  */
+/*
+ * For documentation on the i460 AGP interface, see Chapter 7 (AGP Subsyst=
em) of
+ * the "Intel 460GTX Chipset Software Developer's Manual":
+ * http://developer.intel.com/design/itanium/downloads/24870401s.htm
+ */
=20
+#include <linux/kernel.h>
+#include <linux/bitops.h>
 #include <linux/module.h>
 #include <linux/pci.h>
 #include <linux/init.h>
 #include <linux/agp_backend.h>
-#include "agp.h"
=20
-/* BIOS configures the chipset so that one of two apbase registers are use=
d */
-static u8 intel_i460_dynamic_apbase =3D 0x10;
+#include "agp.h"
=20
-/* 460 supports multiple GART page sizes, so GART pageshift is dynamic */
-static u8 intel_i460_pageshift =3D 12;
-static u32 intel_i460_pagesize;
-
-/* Keep track of which is larger, chipset or kernel page size. */
-static u32 intel_i460_cpk =3D 1;
-
-/* Structure for tracking partial use of 4MB GART pages */
-static u32 **i460_pg_detail =3D NULL;
-static u32 *i460_pg_count =3D NULL;
+/*
+ * The i460 can operate with large (4MB) pages, but there is no sane way t=
o support this
+ * within the current kernel/DRM environment, so we disable the relevant c=
ode for now.
+ * See also comments in ia64_alloc_page()...
+ */
+#define I460_LARGE_IO_PAGES		0
=20
-#define I460_CPAGES_PER_KPAGE (PAGE_SIZE >> intel_i460_pageshift)
-#define I460_KPAGES_PER_CPAGE ((1 << intel_i460_pageshift) >> PAGE_SHIFT)
+#if I460_LARGE_IO_PAGES
+# define I460_IO_PAGE_SHIFT		i460.io_page_shift
+#else
+# define I460_IO_PAGE_SHIFT		12
+#endif
=20
+#define I460_IOPAGES_PER_KPAGE		(PAGE_SIZE >> I460_IO_PAGE_SHIFT)
+#define I460_KPAGES_PER_IOPAGE		(1 << (I460_IO_PAGE_SHIFT - PAGE_SHIFT))
 #define I460_SRAM_IO_DISABLE		(1 << 4)
 #define I460_BAPBASE_ENABLE		(1 << 3)
 #define I460_AGPSIZ_MASK		0x7
 #define I460_4M_PS			(1 << 1)
=20
-#define log2(x)				ffz(~(x))
+/* Control bits for Out-Of-GART coherency and Burst Write Combining */
+#define I460_GXBCTL_OOG		(1UL << 0)
+#define I460_GXBCTL_BWC		(1UL << 2)
+
+/*
+ * gatt_table entries are 32-bits wide on the i460; the generic code ought=
 to declare the
+ * gatt_table and gatt_table_real pointers a "void *"...
+ */
+#define RD_GATT(index)		readl((u32 *) i460.gatt + (index))
+#define WR_GATT(index, val)	writel((val), (u32 *) i460.gatt + (index))
+/*
+ * The 460 spec says we have to read the last location written to make sur=
e that all
+ * writes have taken effect
+ */
+#define WR_FLUSH_GATT(index)	RD_GATT(index)
+
+#define log2(x)			ffz(~(x))
+
+static struct {
+	void *gatt;				/* ioremap'd GATT area */
+
+	/* i460 supports multiple GART page sizes, so GART pageshift is dynamic: =
*/
+	u8 io_page_shift;
+
+	/* BIOS configures chipset to one of 2 possible apbase values: */
+	u8 dynamic_apbase;
=20
-static inline void intel_i460_read_back (volatile u32 *entry)
+	/* structure for tracking partial use of 4MB GART pages: */
+	struct lp_desc {
+		unsigned long *alloced_map;	/* bitmap of kernel-pages in use */
+		int refcount;			/* number of kernel pages using the large page */
+		u64 paddr;			/* physical address of large page */
+	} *lp_desc;
+} i460;
+
+static const struct aper_size_info_8 i460_sizes[3]  {
 	/*
-	 * The 460 spec says we have to read the last location written to
-	 * make sure that all writes have taken effect
+	 * The 32GB aperture is only available with a 4M GART page size.  Due to =
the
+	 * dynamic GART page size, we can't figure out page_order or num_entries =
until
+	 * runtime.
 	 */
-	*entry;
-}
+	{32768, 0, 0, 4},
+	{1024, 0, 0, 2},
+	{256, 0, 0, 1}
+};
=20
-static int intel_i460_fetch_size(void)
+static struct gatt_mask i460_masks[] +{
+	{
+	  .mask =3D INTEL_I460_GATT_VALID | INTEL_I460_GATT_COHERENT,
+	  .type =3D 0
+	}
+};
+
+static int i460_fetch_size (void)
 {
 	int i;
 	u8 temp;
@@ -73,8 +126,15 @@
=20
 	/* Determine the GART page size */
 	pci_read_config_byte(agp_bridge.dev, INTEL_I460_GXBCTL, &temp);
-	intel_i460_pageshift =3D (temp & I460_4M_PS) ? 22 : 12;
-	intel_i460_pagesize =3D 1UL << intel_i460_pageshift;
+	i460.io_page_shift =3D (temp & I460_4M_PS) ? 22 : 12;
+	pr_debug("i460_fetch_size: io_page_shift=3D%d\n", i460.io_page_shift);
+
+	if (i460.io_page_shift !=3D I460_IO_PAGE_SHIFT) {
+		printk(KERN_ERR PFX
+		       "I/O (GART) page-size %ZuKB doesn't match expected size %ZuKB\n",
+		       1UL << (i460.io_page_shift - 10), 1UL << (I460_IO_PAGE_SHIFT));
+		return 0;
+	}
=20
 	values =3D A_SIZE_8(agp_bridge.aperture_sizes);
=20
@@ -88,16 +148,16 @@
 	}
=20
 	/* Make sure we don't try to create an 2 ^ 23 entry GATT */
-	if ((intel_i460_pageshift =3D 0) && ((temp & I460_AGPSIZ_MASK) =3D 4)) {
+	if ((i460.io_page_shift =3D 0) && ((temp & I460_AGPSIZ_MASK) =3D 4)) {
 		printk(KERN_ERR PFX "We can't have a 32GB aperture with 4KB GART pages\n=
");
 		return 0;
 	}
=20
 	/* Determine the proper APBASE register */
 	if (temp & I460_BAPBASE_ENABLE)
-		intel_i460_dynamic_apbase =3D INTEL_I460_BAPBASE;
+		i460.dynamic_apbase =3D INTEL_I460_BAPBASE;
 	else
-		intel_i460_dynamic_apbase =3D INTEL_I460_APBASE;
+		i460.dynamic_apbase =3D INTEL_I460_APBASE;
=20
 	for (i =3D 0; i < agp_bridge.num_aperture_sizes; i++) {
 		/*
@@ -105,7 +165,7 @@
 		 * the define aperture sizes. Take care not to shift off the end of
 		 * values[i].size.
 		 */
-		values[i].num_entries =3D (values[i].size << 8) >> (intel_i460_pageshift=
 - 12);
+		values[i].num_entries =3D (values[i].size << 8) >> (I460_IO_PAGE_SHIFT -=
 12);
 		values[i].page_order =3D log2((sizeof(u32)*values[i].num_entries) >> PAG=
E_SHIFT);
 	}
=20
@@ -122,7 +182,7 @@
 }
=20
 /* There isn't anything to do here since 460 has no GART TLB. */
-static void intel_i460_tlb_flush(agp_memory * mem)
+static void i460_tlb_flush (agp_memory * mem)
 {
 	return;
 }
@@ -131,7 +191,7 @@
  * This utility function is needed to prevent corruption of the control bi=
ts
  * which are stored along with the aperture size in 460's AGPSIZ register
  */
-static void intel_i460_write_agpsiz(u8 size_value)
+static void i460_write_agpsiz (u8 size_value)
 {
 	u8 temp;
=20
@@ -140,47 +200,39 @@
 			      ((temp & ~I460_AGPSIZ_MASK) | size_value));
 }
=20
-static void intel_i460_cleanup(void)
+static void i460_cleanup (void)
 {
 	struct aper_size_info_8 *previous_size;
=20
 	previous_size =3D A_SIZE_8(agp_bridge.previous_size);
-	intel_i460_write_agpsiz(previous_size->size_value);
+	i460_write_agpsiz(previous_size->size_value);
=20
-	if (intel_i460_cpk =3D 0) {
-		vfree(i460_pg_detail);
-		vfree(i460_pg_count);
-	}
+	if (I460_IO_PAGE_SHIFT > PAGE_SHIFT)
+		kfree(i460.lp_desc);
 }
=20
-
-/* Control bits for Out-Of-GART coherency and Burst Write Combining */
-#define I460_GXBCTL_OOG		(1UL << 0)
-#define I460_GXBCTL_BWC		(1UL << 2)
-
-static int intel_i460_configure(void)
+static int i460_configure (void)
 {
 	union {
 		u32 small[2];
 		u64 large;
 	} temp;
+	size_t size;
 	u8 scratch;
-	int i;
-
 	struct aper_size_info_8 *current_size;
=20
 	temp.large =3D 0;
=20
 	current_size =3D A_SIZE_8(agp_bridge.current_size);
-	intel_i460_write_agpsiz(current_size->size_value);
+	i460_write_agpsiz(current_size->size_value);
=20
 	/*
 	 * Do the necessary rigmarole to read all eight bytes of APBASE.
 	 * This has to be done since the AGP aperture can be above 4GB on
 	 * 460 based systems.
 	 */
-	pci_read_config_dword(agp_bridge.dev, intel_i460_dynamic_apbase, &(temp.s=
mall[0]));
-	pci_read_config_dword(agp_bridge.dev, intel_i460_dynamic_apbase + 4, &(te=
mp.small[1]));
+	pci_read_config_dword(agp_bridge.dev, i460.dynamic_apbase, &(temp.small[0=
]));
+	pci_read_config_dword(agp_bridge.dev, i460.dynamic_apbase + 4, &(temp.sma=
ll[1]));
=20
 	/* Clear BAR control bits */
 	agp_bridge.gart_bus_addr =3D temp.large & ~((1UL << 3) - 1);
@@ -190,406 +242,349 @@
 			      (scratch & 0x02) | I460_GXBCTL_OOG | I460_GXBCTL_BWC);
=20
 	/*
-	 * Initialize partial allocation trackers if a GART page is bigger than
-	 * a kernel page.
+	 * Initialize partial allocation trackers if a GART page is bigger than a=
 kernel
+	 * page.
 	 */
-	if (I460_CPAGES_PER_KPAGE >=3D 1) {
-		intel_i460_cpk =3D 1;
-	} else {
-		intel_i460_cpk =3D 0;
-
-		i460_pg_detail =3D vmalloc(sizeof(*i460_pg_detail) * current_size->num_e=
ntries);
-		i460_pg_count =3D vmalloc(sizeof(*i460_pg_count) * current_size->num_ent=
ries);
-
-		for (i =3D 0; i < current_size->num_entries; i++) {
-			i460_pg_count[i] =3D 0;
-			i460_pg_detail[i] =3D NULL;
-		}
+	if (I460_IO_PAGE_SHIFT > PAGE_SHIFT) {
+		size =3D current_size->num_entries * sizeof(i460.lp_desc[0]);
+		i460.lp_desc =3D kmalloc(size, GFP_KERNEL);
+		if (!i460.lp_desc)
+			return -ENOMEM;
+		memset(i460.lp_desc, 0, size);
 	}
 	return 0;
 }
=20
-static int intel_i460_create_gatt_table(void)
+static int i460_create_gatt_table (void)
 {
-	char *table;
-	int i;
-	int page_order;
-	int num_entries;
+	int page_order, num_entries, i;
 	void *temp;
=20
 	/*
-	 * Load up the fixed address of the GART SRAMS which hold our
-	 * GATT table.
+	 * Load up the fixed address of the GART SRAMS which hold our GATT table.
 	 */
-	table =3D (char *) __va(INTEL_I460_ATTBASE);
-
 	temp =3D agp_bridge.current_size;
 	page_order =3D A_SIZE_8(temp)->page_order;
 	num_entries =3D A_SIZE_8(temp)->num_entries;
=20
-	agp_bridge.gatt_table_real =3D (u32 *) table;
-	agp_bridge.gatt_table =3D ioremap_nocache(virt_to_phys(table),
-						(PAGE_SIZE * (1 << page_order)));
-	agp_bridge.gatt_bus_addr =3D virt_to_phys(agp_bridge.gatt_table_real);
-
-	for (i =3D 0; i < num_entries; i++) {
-		agp_bridge.gatt_table[i] =3D 0;
-	}
+	i460.gatt =3D ioremap(INTEL_I460_ATTBASE, PAGE_SIZE << page_order);
=20
-	intel_i460_read_back(agp_bridge.gatt_table + i - 1);
+	/* These are no good, the should be removed from the agp_bridge strucure.=
.. */
+	agp_bridge.gatt_table_real =3D NULL;
+	agp_bridge.gatt_table =3D NULL;
+	agp_bridge.gatt_bus_addr =3D 0;
+
+	for (i =3D 0; i < num_entries; ++i)
+		WR_GATT(i, 0);
+	WR_FLUSH_GATT(i - 1);
 	return 0;
 }
=20
-static int intel_i460_free_gatt_table(void)
+static int i460_free_gatt_table (void)
 {
-	int num_entries;
-	int i;
+	int num_entries, i;
 	void *temp;
=20
 	temp =3D agp_bridge.current_size;
=20
 	num_entries =3D A_SIZE_8(temp)->num_entries;
=20
-	for (i =3D 0; i < num_entries; i++) {
-		agp_bridge.gatt_table[i] =3D 0;
-	}
-
-	intel_i460_read_back(agp_bridge.gatt_table + i - 1);
+	for (i =3D 0; i < num_entries; ++i)
+		WR_GATT(i, 0);
+	WR_FLUSH_GATT(num_entries - 1);
=20
-	iounmap(agp_bridge.gatt_table);
+	iounmap(i460.gatt);
 	return 0;
 }
=20
-/* These functions are called when PAGE_SIZE exceeds the GART page size */
+/*
+ * The following functions are called when the I/O (GART) page size is sma=
ller than
+ * PAGE_SIZE.
+ */
=20
-static int intel_i460_insert_memory_cpk(agp_memory * mem, off_t pg_start, =
int type)
+static int i460_insert_memory_small_io_page (agp_memory *mem, off_t pg_sta=
rt, int type)
 {
+	unsigned long paddr, io_pg_start, io_page_size;
 	int i, j, k, num_entries;
 	void *temp;
-	unsigned long paddr;
=20
-	/*
-	 * The rest of the kernel will compute page offsets in terms of
-	 * PAGE_SIZE.
-	 */
-	pg_start =3D I460_CPAGES_PER_KPAGE * pg_start;
+	pr_debug("i460_insert_memory_small_io_page(mem=3D%p, pg_start=3D%ld, type=
=3D%d, paddr0=3D0x%lx)\n",
+		 mem, pg_start, type, mem->memory[0]);
+
+	io_pg_start =3D I460_IOPAGES_PER_KPAGE * pg_start;
=20
 	temp =3D agp_bridge.current_size;
 	num_entries =3D A_SIZE_8(temp)->num_entries;
=20
-	if ((pg_start + I460_CPAGES_PER_KPAGE * mem->page_count) > num_entries) {
+	if ((io_pg_start + I460_IOPAGES_PER_KPAGE * mem->page_count) > num_entrie=
s) {
 		printk(KERN_ERR PFX "Looks like we're out of AGP memory\n");
 		return -EINVAL;
 	}
=20
-	j =3D pg_start;
-	while (j < (pg_start + I460_CPAGES_PER_KPAGE * mem->page_count)) {
-		if (!PGE_EMPTY(agp_bridge.gatt_table[j])) {
+	j =3D io_pg_start;
+	while (j < (io_pg_start + I460_IOPAGES_PER_KPAGE * mem->page_count)) {
+		if (!PGE_EMPTY(RD_GATT(j))) {
+			pr_debug("i460_insert_memory_small_io_page: GATT[%d]=3D0x%x is busy\n",
+				 j, RD_GATT(j));
 			return -EBUSY;
 		}
 		j++;
 	}
=20
-#if 0
-	/* not necessary since 460 GART is operated in coherent mode... */
-	if (mem->is_flushed =3D FALSE) {
-		CACHE_FLUSH();
-		mem->is_flushed =3D TRUE;
-	}
-#endif
-
-	for (i =3D 0, j =3D pg_start; i < mem->page_count; i++) {
+	io_page_size =3D 1UL << I460_IO_PAGE_SHIFT;
+	for (i =3D 0, j =3D io_pg_start; i < mem->page_count; i++) {
 		paddr =3D mem->memory[i];
-		for (k =3D 0; k < I460_CPAGES_PER_KPAGE; k++, j++, paddr +=3D intel_i460=
_pagesize)
-			agp_bridge.gatt_table[j] =3D (u32) agp_bridge.mask_memory(paddr, mem->t=
ype);
+		for (k =3D 0; k < I460_IOPAGES_PER_KPAGE; k++, j++, paddr +=3D io_page_s=
ize)
+			WR_GATT(j, agp_bridge.mask_memory(paddr, mem->type));
 	}
-
-	intel_i460_read_back(agp_bridge.gatt_table + j - 1);
+	WR_FLUSH_GATT(j - 1);
 	return 0;
 }
=20
-static int intel_i460_remove_memory_cpk(agp_memory * mem, off_t pg_start, =
int type)
+static int i460_remove_memory_small_io_page(agp_memory * mem, off_t pg_sta=
rt, int type)
 {
 	int i;
=20
-	pg_start =3D I460_CPAGES_PER_KPAGE * pg_start;
+	pr_debug("i460_remove_memory_small_io_page(mem=3D%p, pg_start=3D%ld, type=
=3D%d)\n",
+		 mem, pg_start, type);
=20
-	for (i =3D pg_start; i < (pg_start + I460_CPAGES_PER_KPAGE * mem->page_co=
unt); i++)
-		agp_bridge.gatt_table[i] =3D 0;
+	pg_start =3D I460_IOPAGES_PER_KPAGE * pg_start;
=20
-	intel_i460_read_back(agp_bridge.gatt_table + i - 1);
+	for (i =3D pg_start; i < (pg_start + I460_IOPAGES_PER_KPAGE * mem->page_c=
ount); i++)
+		WR_GATT(i, 0);
+	WR_FLUSH_GATT(i - 1);
 	return 0;
 }
=20
+#if I460_LARGE_IO_PAGES
+
 /*
- * These functions are called when the GART page size exceeds PAGE_SIZE.
+ * These functions are called when the I/O (GART) page size exceeds PAGE_S=
IZE.
  *
- * This situation is interesting since AGP memory allocations that are
- * smaller than a single GART page are possible.  The structures i460_pg_c=
ount
- * and i460_pg_detail track partial allocation of the large GART pages to
- * work around this issue.
+ * This situation is interesting since AGP memory allocations that are sma=
ller than a
+ * single GART page are possible.  The i460.lp_desc array tracks partial a=
llocation of the
+ * large GART pages to work around this issue.
  *
- * i460_pg_count[pg_num] tracks the number of kernel pages in use within
- * GART page pg_num.  i460_pg_detail[pg_num] is an array containing a
- * psuedo-GART entry for each of the aforementioned kernel pages.  The who=
le
- * of i460_pg_detail is equivalent to a giant GATT with page size equal to
- * that of the kernel.
+ * i460.lp_desc[pg_num].refcount tracks the number of kernel pages in use =
within GART page
+ * pg_num.  i460.lp_desc[pg_num].paddr is the physical address of the larg=
e page and
+ * i460.lp_desc[pg_num].alloced_map is a bitmap of kernel pages that are i=
n use (allocated).
  */
=20
-static void *intel_i460_alloc_large_page(int pg_num)
+static int i460_alloc_large_page (struct lp_desc *lp)
 {
-	int i;
-	void *bp, *bp_end;
-	struct page *page;
-
-	i460_pg_detail[pg_num] =3D (void *) vmalloc(sizeof(u32) * I460_KPAGES_PER=
_CPAGE);
-	if (i460_pg_detail[pg_num] =3D NULL) {
-		printk(KERN_ERR PFX "Out of memory, we're in trouble...\n");
-		return NULL;
-	}
-
-	for (i =3D 0; i < I460_KPAGES_PER_CPAGE; i++)
-		i460_pg_detail[pg_num][i] =3D 0;
+	unsigned long order =3D I460_IO_PAGE_SHIFT - PAGE_SHIFT;
+	size_t map_size;
+	void *lpage;
=20
-	bp =3D (void *) __get_free_pages(GFP_KERNEL, intel_i460_pageshift - PAGE_=
SHIFT);
-	if (bp =3D NULL) {
+	lpage =3D (void *) __get_free_pages(GFP_KERNEL, order);
+	if (!lpage) {
 		printk(KERN_ERR PFX "Couldn't alloc 4M GART page...\n");
-		return NULL;
+		return -ENOMEM;
 	}
=20
-	bp_end =3D bp + ((PAGE_SIZE * (1 << (intel_i460_pageshift - PAGE_SHIFT)))=
 - 1);
-
-	for (page =3D virt_to_page(bp); page <=3D virt_to_page(bp_end); page++) {
-		atomic_inc(&agp_bridge.current_memory_agp);
+	map_size =3D ((I460_KPAGES_PER_IOPAGE + BITS_PER_LONG - 1) & -BITS_PER_LO=
NG)/8;
+	lp->alloced_map =3D kmalloc(map_size, GFP_KERNEL);
+	if (!lp->alloced_map) {
+		free_pages((unsigned long) lpage, order);
+		printk(KERN_ERR PFX "Out of memory, we're in trouble...\n");
+		return -ENOMEM;
 	}
-	return bp;
+	memset(lp->alloced_map, 0, map_size);
+
+	lp->paddr =3D virt_to_phys(lpage);
+	lp->refcount =3D 0;
+	atomic_add(I460_KPAGES_PER_IOPAGE, &agp_bridge.current_memory_agp);
+	return 0;
 }
=20
-static void intel_i460_free_large_page(int pg_num, unsigned long addr)
+static void i460_free_large_page (struct lp_desc *lp)
 {
-	struct page *page;
-	void *bp, *bp_end;
-
-	bp =3D (void *) __va(addr);
-	bp_end =3D bp + (PAGE_SIZE * (1 << (intel_i460_pageshift - PAGE_SHIFT)));
+	kfree(lp->alloced_map);
+	lp->alloced_map =3D NULL;
=20
-	vfree(i460_pg_detail[pg_num]);
-	i460_pg_detail[pg_num] =3D NULL;
-
-	for (page =3D virt_to_page(bp); page < virt_to_page(bp_end); page++) {
-		atomic_dec(&agp_bridge.current_memory_agp);
-	}
-
-	free_pages((unsigned long) bp, intel_i460_pageshift - PAGE_SHIFT);
+	free_pages((unsigned long) phys_to_virt(lp->paddr), I460_IO_PAGE_SHIFT - =
PAGE_SHIFT);
+	atomic_sub(I460_KPAGES_PER_IOPAGE, &agp_bridge.current_memory_agp);
 }
=20
-static int intel_i460_insert_memory_kpc(agp_memory * mem, off_t pg_start, =
int type)
+static int i460_insert_memory_large_io_page (agp_memory * mem, off_t pg_st=
art, int type)
 {
-	int i, pg, start_pg, end_pg, start_offset, end_offset, idx;
-	int num_entries;
+	int i, start_offset, end_offset, idx, pg, num_entries;
+	struct lp_desc *start, *end, *lp;
 	void *temp;
-	unsigned long paddr;
=20
 	temp =3D agp_bridge.current_size;
 	num_entries =3D A_SIZE_8(temp)->num_entries;
=20
 	/* Figure out what pg_start means in terms of our large GART pages */
-	start_pg 	=3D pg_start / I460_KPAGES_PER_CPAGE;
-	start_offset 	=3D pg_start % I460_KPAGES_PER_CPAGE;
-	end_pg 		=3D (pg_start + mem->page_count - 1) / I460_KPAGES_PER_CPAGE;
-	end_offset 	=3D (pg_start + mem->page_count - 1) % I460_KPAGES_PER_CPAGE;
+	start	 	=3D &i460.lp_desc[pg_start / I460_KPAGES_PER_IOPAGE];
+	end 		=3D &i460.lp_desc[(pg_start + mem->page_count - 1) / I460_KPAGES_PE=
R_IOPAGE];
+	start_offset 	=3D pg_start % I460_KPAGES_PER_IOPAGE;
+	end_offset 	=3D (pg_start + mem->page_count - 1) % I460_KPAGES_PER_IOPAGE;
=20
-	if (end_pg > num_entries) {
+	if (end > i460.lp_desc + num_entries) {
 		printk(KERN_ERR PFX "Looks like we're out of AGP memory\n");
 		return -EINVAL;
 	}
=20
 	/* Check if the requested region of the aperture is free */
-	for (pg =3D start_pg; pg <=3D end_pg; pg++) {
-		/* Allocate new GART pages if necessary */
-		if (i460_pg_detail[pg] =3D NULL) {
-			temp =3D intel_i460_alloc_large_page(pg);
-			if (temp =3D NULL)
-				return -ENOMEM;
-			agp_bridge.gatt_table[pg] =3D agp_bridge.mask_memory((unsigned long) te=
mp,
-									   0);
-			intel_i460_read_back(agp_bridge.gatt_table + pg);
-		}
+	for (lp =3D start; lp <=3D end; ++lp) {
+		if (!lp->alloced_map)
+			continue;	/* OK, the entire large page is available... */
=20
-		for (idx =3D ((pg =3D start_pg) ? start_offset : 0);
-		     idx < ((pg =3D end_pg) ? (end_offset + 1) : I460_KPAGES_PER_CPAGE);
+		for (idx =3D ((lp =3D start) ? start_offset : 0);
+		     idx < ((lp =3D end) ? (end_offset + 1) : I460_KPAGES_PER_IOPAGE);
 		     idx++)
 		{
-			if (i460_pg_detail[pg][idx] !=3D 0)
+			if (test_bit(idx, lp->alloced_map))
 				return -EBUSY;
 		}
 	}
=20
-#if 0
-	/* not necessary since 460 GART is operated in coherent mode... */
-	if (mem->is_flushed =3D FALSE) {
-		CACHE_FLUSH();
-		mem->is_flushed =3D TRUE;
-	}
-#endif
+	for (lp =3D start, i =3D 0; lp <=3D end; ++lp) {
+		if (!lp->alloced_map) {
+			/* Allocate new GART pages... */
+			if (i460_alloc_large_page(lp) < 0)
+				return -ENOMEM;
+			pg =3D lp - i460.lp_desc;
+			WR_GATT(pg, agp_bridge.mask_memory(lp->paddr, 0));
+			WR_FLUSH_GATT(pg);
+		}
=20
-	for (pg =3D start_pg, i =3D 0; pg <=3D end_pg; pg++) {
-		paddr =3D agp_bridge.unmask_memory(agp_bridge.gatt_table[pg]);
-		for (idx =3D ((pg =3D start_pg) ? start_offset : 0);
-		     idx < ((pg =3D end_pg) ? (end_offset + 1) : I460_KPAGES_PER_CPAGE);
+		for (idx =3D ((lp =3D start) ? start_offset : 0);
+		     idx < ((lp =3D end) ? (end_offset + 1) : I460_KPAGES_PER_IOPAGE);
 		     idx++, i++)
 		{
-			mem->memory[i] =3D paddr + (idx * PAGE_SIZE);
-			i460_pg_detail[pg][idx] =3D agp_bridge.mask_memory(mem->memory[i],
-									 mem->type);
-			i460_pg_count[pg]++;
+			mem->memory[i] =3D lp->paddr + idx*PAGE_SIZE;
+			__set_bit(idx, lp->alloced_map);
+			++lp->refcount;
 		}
 	}
-
 	return 0;
 }
=20
-static int intel_i460_remove_memory_kpc(agp_memory * mem, off_t pg_start, =
int type)
+static int i460_remove_memory_large_io_page (agp_memory * mem, off_t pg_st=
art, int type)
 {
-	int i, pg, start_pg, end_pg, start_offset, end_offset, idx;
-	int num_entries;
+	int i, pg, start_offset, end_offset, idx, num_entries;
+	struct lp_desc *start, *end, *lp;
 	void *temp;
-	unsigned long paddr;
=20
 	temp =3D agp_bridge.current_size;
 	num_entries =3D A_SIZE_8(temp)->num_entries;
=20
 	/* Figure out what pg_start means in terms of our large GART pages */
-	start_pg 	=3D pg_start / I460_KPAGES_PER_CPAGE;
-	start_offset 	=3D pg_start % I460_KPAGES_PER_CPAGE;
-	end_pg 		=3D (pg_start + mem->page_count - 1) / I460_KPAGES_PER_CPAGE;
-	end_offset 	=3D (pg_start + mem->page_count - 1) % I460_KPAGES_PER_CPAGE;
-
-	for (i =3D 0, pg =3D start_pg; pg <=3D end_pg; pg++) {
-		for (idx =3D ((pg =3D start_pg) ? start_offset : 0);
-		    idx < ((pg =3D end_pg) ? (end_offset + 1) : I460_KPAGES_PER_CPAGE);
-		    idx++, i++)
+	start	 	=3D &i460.lp_desc[pg_start / I460_KPAGES_PER_IOPAGE];
+	end 		=3D &i460.lp_desc[(pg_start + mem->page_count - 1) / I460_KPAGES_PE=
R_IOPAGE];
+	start_offset 	=3D pg_start % I460_KPAGES_PER_IOPAGE;
+	end_offset 	=3D (pg_start + mem->page_count - 1) % I460_KPAGES_PER_IOPAGE;
+
+	for (i =3D 0, lp =3D start; lp <=3D end; ++lp) {
+		for (idx =3D ((lp =3D start) ? start_offset : 0);
+		     idx < ((lp =3D end) ? (end_offset + 1) : I460_KPAGES_PER_IOPAGE);
+		     idx++, i++)
 		{
 			mem->memory[i] =3D 0;
-			i460_pg_detail[pg][idx] =3D 0;
-			i460_pg_count[pg]--;
+			__clear_bit(idx, lp->alloced_map);
+			--lp->refcount;
 		}
=20
 		/* Free GART pages if they are unused */
-		if (i460_pg_count[pg] =3D 0) {
-			paddr =3D agp_bridge.unmask_memory(agp_bridge.gatt_table[pg]);
-			agp_bridge.gatt_table[pg] =3D agp_bridge.scratch_page;
-			intel_i460_read_back(agp_bridge.gatt_table + pg);
-			intel_i460_free_large_page(pg, paddr);
+		if (lp->refcount =3D 0) {
+			pg =3D lp - i460.lp_desc;
+			WR_GATT(pg, 0);
+			WR_FLUSH_GATT(pg);
+			i460_free_large_page(lp);
 		}
 	}
 	return 0;
 }
=20
-/* Dummy routines to call the approriate {cpk,kpc} function */
+/* Wrapper routines to call the approriate {small_io_page,large_io_page} f=
unction */
=20
-static int intel_i460_insert_memory(agp_memory * mem, off_t pg_start, int =
type)
+static int i460_insert_memory (agp_memory * mem, off_t pg_start, int type)
 {
-	if (intel_i460_cpk)
-		return intel_i460_insert_memory_cpk(mem, pg_start, type);
+	if (I460_IO_PAGE_SHIFT <=3D PAGE_SHIFT)
+		return i460_insert_memory_small_io_page(mem, pg_start, type);
 	else
-		return intel_i460_insert_memory_kpc(mem, pg_start, type);
+		return i460_insert_memory_large_io_page(mem, pg_start, type);
 }
=20
-static int intel_i460_remove_memory(agp_memory * mem, off_t pg_start, int =
type)
+static int i460_remove_memory (agp_memory * mem, off_t pg_start, int type)
 {
-	if (intel_i460_cpk)
-		return intel_i460_remove_memory_cpk(mem, pg_start, type);
+	if (I460_IO_PAGE_SHIFT <=3D PAGE_SHIFT)
+		return i460_remove_memory_small_io_page(mem, pg_start, type);
 	else
-		return intel_i460_remove_memory_kpc(mem, pg_start, type);
+		return i460_remove_memory_large_io_page(mem, pg_start, type);
 }
=20
 /*
- * If the kernel page size is smaller that the chipset page size, we don't
- * want to allocate memory until we know where it is to be bound in the
- * aperture (a multi-kernel-page alloc might fit inside of an already
- * allocated GART page).  Consequently, don't allocate or free anything
- * if i460_cpk (meaning chipset pages per kernel page) isn't set.
+ * If the I/O (GART) page size is bigger than the kernel page size, we don=
't want to
+ * allocate memory until we know where it is to be bound in the aperture (a
+ * multi-kernel-page alloc might fit inside of an already allocated GART p=
age).
  *
- * Let's just hope nobody counts on the allocated AGP memory being there
- * before bind time (I don't think current drivers do)...
+ * Let's just hope nobody counts on the allocated AGP memory being there b=
efore bind time
+ * (I don't think current drivers do)...
  */
-static void * intel_i460_alloc_page(void)
+static void *i460_alloc_page (void)
 {
-	if (intel_i460_cpk)
-		return agp_generic_alloc_page();
+	void *page;
=20
-	/* Returning NULL would cause problems */
-	/* AK: really dubious code. */
-	return (void *)~0UL;
+	if (I460_IO_PAGE_SHIFT <=3D PAGE_SHIFT)
+		page =3D agp_generic_alloc_page();
+	else
+		/* Returning NULL would cause problems */
+		/* AK: really dubious code. */
+		page =3D (void *)~0UL;
+	return page;
 }
=20
-static void intel_i460_destroy_page(void *page)
+static void i460_destroy_page (void *page)
 {
-	if (intel_i460_cpk)
+	if (I460_IO_PAGE_SHIFT <=3D PAGE_SHIFT)
 		agp_generic_destroy_page(page);
 }
=20
-static struct gatt_mask intel_i460_masks[] -{
-	{
-	  .mask =3D INTEL_I460_GATT_VALID | INTEL_I460_GATT_COHERENT,
-	  .type =3D 0
-	}
-};
+#endif /* I460_LARGE_IO_PAGES */
=20
-static unsigned long intel_i460_mask_memory(unsigned long addr, int type)
+static unsigned long i460_mask_memory (unsigned long addr, int type)
 {
 	/* Make sure the returned address is a valid GATT entry */
 	return (agp_bridge.masks[0].mask
-		| (((addr & ~((1 << intel_i460_pageshift) - 1)) & 0xffffff000) >> 12));
+		| (((addr & ~((1 << I460_IO_PAGE_SHIFT) - 1)) & 0xffffff000) >> 12));
 }
=20
-static unsigned long intel_i460_unmask_memory(unsigned long addr)
-{
-	/* Turn a GATT entry into a physical address */
-	return ((addr & 0xffffff) << 12);
-}
-
-static struct aper_size_info_8 intel_i460_sizes[3] -{
-	/*
-	 * The 32GB aperture is only available with a 4M GART page size.
-	 * Due to the dynamic GART page size, we can't figure out page_order
-	 * or num_entries until runtime.
-	 */
-	{32768, 0, 0, 4},
-	{1024, 0, 0, 2},
-	{256, 0, 0, 1}
-};
-
 int __init intel_i460_setup (struct pci_dev *pdev __attribute__((unused)))
 {
-	agp_bridge.masks =3D intel_i460_masks;
-	agp_bridge.aperture_sizes =3D (void *) intel_i460_sizes;
+	agp_bridge.num_of_masks =3D 1;
+	agp_bridge.masks =3D i460_masks;
+	agp_bridge.aperture_sizes =3D (void *) i460_sizes;
 	agp_bridge.size_type =3D U8_APER_SIZE;
 	agp_bridge.num_aperture_sizes =3D 3;
 	agp_bridge.dev_private_data =3D NULL;
 	agp_bridge.needs_scratch_page =3D FALSE;
-	agp_bridge.configure =3D intel_i460_configure;
-	agp_bridge.fetch_size =3D intel_i460_fetch_size;
-	agp_bridge.cleanup =3D intel_i460_cleanup;
-	agp_bridge.tlb_flush =3D intel_i460_tlb_flush;
-	agp_bridge.mask_memory =3D intel_i460_mask_memory;
-	agp_bridge.unmask_memory =3D intel_i460_unmask_memory;
+	agp_bridge.configure =3D i460_configure;
+	agp_bridge.fetch_size =3D i460_fetch_size;
+	agp_bridge.cleanup =3D i460_cleanup;
+	agp_bridge.tlb_flush =3D i460_tlb_flush;
+	agp_bridge.mask_memory =3D i460_mask_memory;
 	agp_bridge.agp_enable =3D agp_generic_agp_enable;
 	agp_bridge.cache_flush =3D global_cache_flush;
-	agp_bridge.create_gatt_table =3D intel_i460_create_gatt_table;
-	agp_bridge.free_gatt_table =3D intel_i460_free_gatt_table;
-	agp_bridge.insert_memory =3D intel_i460_insert_memory;
-	agp_bridge.remove_memory =3D intel_i460_remove_memory;
+	agp_bridge.create_gatt_table =3D i460_create_gatt_table;
+	agp_bridge.free_gatt_table =3D i460_free_gatt_table;
+#if I460_LARGE_IO_PAGES
+	agp_bridge.insert_memory =3D i460_insert_memory;
+	agp_bridge.remove_memory =3D i460_remove_memory;
+	agp_bridge.agp_alloc_page =3D i460_alloc_page;
+	agp_bridge.agp_destroy_page =3D i460_destroy_page;
+#else
+	agp_bridge.insert_memory =3D i460_insert_memory_small_io_page;
+	agp_bridge.remove_memory =3D i460_remove_memory_small_io_page;
+	agp_bridge.agp_alloc_page =3D agp_generic_alloc_page;
+	agp_bridge.agp_destroy_page =3D agp_generic_destroy_page;
+#endif
 	agp_bridge.alloc_by_type =3D agp_generic_alloc_by_type;
 	agp_bridge.free_by_type =3D agp_generic_free_by_type;
-	agp_bridge.agp_alloc_page =3D intel_i460_alloc_page;
-	agp_bridge.agp_destroy_page =3D intel_i460_destroy_page;
 	agp_bridge.suspend =3D agp_generic_suspend;
 	agp_bridge.resume =3D agp_generic_resume;
 	agp_bridge.cant_use_aperture =3D 1;
 	return 0;
 }
-
diff -Nru a/drivers/char/agp/i810-agp.c b/drivers/char/agp/i810-agp.c
--- a/drivers/char/agp/i810-agp.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/agp/i810-agp.c	Sat Aug 10 01:51:46 2002
@@ -179,7 +179,8 @@
    	CACHE_FLUSH();
 	for (i =3D 0, j =3D pg_start; i < mem->page_count; i++, j++) {
 		OUTREG32(intel_i810_private.registers,
-			 I810_PTE_BASE + (j * 4), mem->memory[i]);
+			 I810_PTE_BASE + (j * 4), agp_bridge.mask_memory(mem->memory[i],
+									 mem->type));
 	}
 	CACHE_FLUSH();
=20
@@ -246,11 +247,11 @@
 			agp_free_memory(new);
 			return NULL;
 		}
-		new->memory[0] =3D agp_bridge.mask_memory(virt_to_phys(addr), type);
+		new->memory[0] =3D virt_to_phys(addr);
 		new->page_count =3D 1;
 	   	new->num_scratch_pages =3D 1;
 	   	new->type =3D AGP_PHYS_MEMORY;
-	        new->physical =3D virt_to_phys((void *) new->memory[0]);
+	        new->physical =3D virt_to_phys(addr);
 	   	return new;
 	}
   =20
@@ -483,7 +484,8 @@
 	CACHE_FLUSH();
=20
 	for (i =3D 0, j =3D pg_start; i < mem->page_count; i++, j++)
-		OUTREG32(intel_i830_private.registers,I810_PTE_BASE + (j * 4),mem->memor=
y[i]);
+		OUTREG32(intel_i830_private.registers,I810_PTE_BASE + (j * 4),
+			 agp_bridge.mask_memory(mem->memory[i], mem->type));
=20
 	CACHE_FLUSH();
=20
@@ -543,7 +545,7 @@
 			return(NULL);
 		}
=20
-		nw->memory[0] =3D agp_bridge.mask_memory(virt_to_phys(addr),type);
+		nw->memory[0] =3D virt_to_phys(addr);
 		nw->page_count =3D 1;
 		nw->num_scratch_pages =3D 1;
 		nw->type =3D AGP_PHYS_MEMORY;
diff -Nru a/drivers/char/agp/sworks-agp.c b/drivers/char/agp/sworks-agp.c
--- a/drivers/char/agp/sworks-agp.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/agp/sworks-agp.c	Sat Aug 10 01:51:46 2002
@@ -405,7 +405,7 @@
 	for (i =3D 0, j =3D pg_start; i < mem->page_count; i++, j++) {
 		addr =3D (j * PAGE_SIZE) + agp_bridge.gart_bus_addr;
 		cur_gatt =3D SVRWRKS_GET_GATT(addr);
-		cur_gatt[GET_GATT_OFF(addr)] =3D mem->memory[i];
+		cur_gatt[GET_GATT_OFF(addr)] =3D agp_bridge.mask_memory(mem->memory[i], =
mem->type);
 	}
 	agp_bridge.tlb_flush(mem);
 	return 0;
diff -Nru a/drivers/char/drm/ati_pcigart.h b/drivers/char/drm/ati_pcigart.h
--- a/drivers/char/drm/ati_pcigart.h	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/drm/ati_pcigart.h	Sat Aug 10 01:51:46 2002
@@ -30,14 +30,20 @@
 #define __NO_VERSION__
 #include "drmP.h"
=20
-#if PAGE_SIZE =3D 8192
+#if PAGE_SIZE =3D 65536
+# define ATI_PCIGART_TABLE_ORDER 	0
+# define ATI_PCIGART_TABLE_PAGES 	(1 << 0)
+#elif PAGE_SIZE =3D 16384
+# define ATI_PCIGART_TABLE_ORDER 	1
+# define ATI_PCIGART_TABLE_PAGES 	(1 << 1)
+#elif PAGE_SIZE =3D 8192
 # define ATI_PCIGART_TABLE_ORDER 	2
 # define ATI_PCIGART_TABLE_PAGES 	(1 << 2)
 #elif PAGE_SIZE =3D 4096
 # define ATI_PCIGART_TABLE_ORDER 	3
 # define ATI_PCIGART_TABLE_PAGES 	(1 << 3)
 #else
-# error - PAGE_SIZE not 8K or 4K
+# error - PAGE_SIZE not 64K, 16K, 8K or 4K
 #endif
=20
 # define ATI_MAX_PCIGART_PAGES		8192	/* 32 MB aperture, 4K pages */
diff -Nru a/drivers/char/drm/drmP.h b/drivers/char/drm/drmP.h
--- a/drivers/char/drm/drmP.h	Sat Aug 10 01:51:47 2002
+++ b/drivers/char/drm/drmP.h	Sat Aug 10 01:51:47 2002
@@ -199,19 +199,17 @@
=20
 				/* Macros to make printk easier */
 #define DRM_ERROR(fmt, arg...) \
-	printk(KERN_ERR "[" DRM_NAME ":" __FUNCTION__ "] *ERROR* " fmt , ##arg)
+	printk(KERN_ERR "[" DRM_NAME ":%s] *ERROR* " fmt , __FUNCTION__ , ##arg)
 #define DRM_MEM_ERROR(area, fmt, arg...) \
-	printk(KERN_ERR "[" DRM_NAME ":" __FUNCTION__ ":%s] *ERROR* " fmt , \
+	printk(KERN_ERR "[" DRM_NAME ":%s:%s] *ERROR* " fmt , __FUNCTION__ , \
 	       DRM(mem_stats)[area].name , ##arg)
 #define DRM_INFO(fmt, arg...)  printk(KERN_INFO "[" DRM_NAME "] " fmt , ##=
arg)
=20
 #if DRM_DEBUG_CODE
-#define DRM_DEBUG(fmt, arg...)						\
-	do {								\
-		if ( DRM(flags) & DRM_FLAG_DEBUG )			\
-			printk(KERN_DEBUG				\
-			       "[" DRM_NAME ":" __FUNCTION__ "] " fmt ,	\
-			       ##arg);					\
+#define DRM_DEBUG(fmt, arg...)									\
+	do {											\
+		if ( DRM(flags) & DRM_FLAG_DEBUG )						\
+			printk(KERN_DEBUG "[" DRM_NAME ":%s] " fmt, __FUNCTION__, ##arg);	\
 	} while (0)
 #else
 #define DRM_DEBUG(fmt, arg...)		 do { } while (0)
@@ -228,16 +226,16 @@
    if (len > DRM_PROC_LIMIT) { ret; *eof =3D 1; return len - offset; }
=20
 				/* Mapping helper macros */
-#define DRM_IOREMAP(map)						\
-	(map)->handle =3D DRM(ioremap)( (map)->offset, (map)->size )
+#define DRM_IOREMAP(map, dev)							\
+	(map)->handle =3D DRM(ioremap)( (map)->offset, (map)->size, (dev) )
=20
-#define DRM_IOREMAP_NOCACHE(map)					\
-	(map)->handle =3D DRM(ioremap_nocache)((map)->offset, (map)->size)
+#define DRM_IOREMAP_NOCACHE(map, dev)						\
+	(map)->handle =3D DRM(ioremap_nocache)((map)->offset, (map)->size, (dev))
=20
-#define DRM_IOREMAPFREE(map)						\
-	do {								\
-		if ( (map)->handle && (map)->size )			\
-			DRM(ioremapfree)( (map)->handle, (map)->size );	\
+#define DRM_IOREMAPFREE(map, dev)							\
+	do {									\
+		if ( (map)->handle && (map)->size )				\
+			DRM(ioremapfree)( (map)->handle, (map)->size, (dev) );	\
 	} while (0)
=20
 #define DRM_FIND_MAP(_map, _o)						\
@@ -675,9 +673,10 @@
 extern unsigned long DRM(alloc_pages)(int order, int area);
 extern void	     DRM(free_pages)(unsigned long address, int order,
 				     int area);
-extern void	     *DRM(ioremap)(unsigned long offset, unsigned long size);
-extern void	     *DRM(ioremap_nocache)(unsigned long offset, unsigned long=
 size);
-extern void	     DRM(ioremapfree)(void *pt, unsigned long size);
+extern void	     *DRM(ioremap)(unsigned long offset, unsigned long size, d=
rm_device_t *dev);
+extern void	     *DRM(ioremap_nocache)(unsigned long offset, unsigned long=
 size,
+					   drm_device_t *dev);
+extern void	     DRM(ioremapfree)(void *pt, unsigned long size, drm_device=
_t *dev);
=20
 #if __REALLY_HAVE_AGP
 extern agp_memory    *DRM(alloc_agp)(int pages, u32 type);
diff -Nru a/drivers/char/drm/drm_bufs.h b/drivers/char/drm/drm_bufs.h
--- a/drivers/char/drm/drm_bufs.h	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/drm/drm_bufs.h	Sat Aug 10 01:51:46 2002
@@ -107,7 +107,7 @@
 	switch ( map->type ) {
 	case _DRM_REGISTERS:
 	case _DRM_FRAME_BUFFER:
-#if !defined(__sparc__) && !defined(__alpha__)
+#if !defined(__sparc__) && !defined(__alpha__) && !defined(__ia64__)
 		if ( map->offset + map->size < map->offset ||
 		     map->offset < virt_to_phys(high_memory) ) {
 			DRM(free)( map, sizeof(*map), DRM_MEM_MAPS );
@@ -124,7 +124,7 @@
 					      MTRR_TYPE_WRCOMB, 1 );
 		}
 #endif
-		map->handle =3D DRM(ioremap)( map->offset, map->size );
+		map->handle =3D DRM(ioremap)( map->offset, map->size, dev );
 		break;
=20
 	case _DRM_SHM:
@@ -245,7 +245,7 @@
 				DRM_DEBUG("mtrr_del =3D %d\n", retcode);
 			}
 #endif
-			DRM(ioremapfree)(map->handle, map->size);
+			DRM(ioremapfree)(map->handle, map->size, dev);
 			break;
 		case _DRM_SHM:
 			vfree(map->handle);
diff -Nru a/drivers/char/drm/drm_drv.h b/drivers/char/drm/drm_drv.h
--- a/drivers/char/drm/drm_drv.h	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/drm/drm_drv.h	Sat Aug 10 01:51:46 2002
@@ -423,7 +423,7 @@
 					DRM_DEBUG( "mtrr_del=3D%d\n", retcode );
 				}
 #endif
-				DRM(ioremapfree)( map->handle, map->size );
+				DRM(ioremapfree)( map->handle, map->size, dev );
 				break;
 			case _DRM_SHM:
 				vfree(map->handle);
diff -Nru a/drivers/char/drm/drm_memory.h b/drivers/char/drm/drm_memory.h
--- a/drivers/char/drm/drm_memory.h	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/drm/drm_memory.h	Sat Aug 10 01:51:46 2002
@@ -33,6 +33,9 @@
 #include <linux/config.h>
 #include "drmP.h"
 #include <linux/wrapper.h>
+#include <linux/vmalloc.h>
+
+#include <asm/tlbflush.h>
=20
 typedef struct drm_mem_stats {
 	const char	  *name;
@@ -291,17 +294,100 @@
 	}
 }
=20
-void *DRM(ioremap)(unsigned long offset, unsigned long size)
+#if __REALLY_HAVE_AGP
+
+/*
+ * Find the drm_map that covers the range [offset, offset+size).
+ */
+static inline drm_map_t *
+DRM(lookup_map)(unsigned long offset, unsigned long size, drm_device_t *de=
v)
+{
+	struct list_head *list;
+	drm_map_list_t *r_list;
+	drm_map_t *map;
+
+	list_for_each(list, &dev->maplist->head) {
+		r_list =3D (drm_map_list_t *) list;
+		map =3D r_list->map;
+		if (!map)
+			continue;
+		if (map->offset <=3D offset && (offset + size) <=3D (map->offset + map->=
size))
+			return map;
+	}
+	return NULL;
+}
+
+static inline void *
+DRM(agp_remap) (unsigned long offset, unsigned long size, drm_device_t *de=
v)
+{
+	struct drm_agp_mem *agpmem;
+	struct vm_struct *area;
+	unsigned long *paddrp, paddr;
+	void *vaddr, *end_vaddr;
+	struct page *page;
+
+	size =3D PAGE_ALIGN(size);
+
+	for (agpmem =3D dev->agp->memory; agpmem; agpmem =3D agpmem->next)
+		if (agpmem->bound <=3D offset
+		    && (agpmem->bound + (agpmem->pages << PAGE_SHIFT)) >=3D (offset + si=
ze))
+			break;
+	if (!agpmem)
+		return NULL;
+
+	/*
+	 * OK, we're mapping AGP space on a chipset/platform on which memory acce=
sses by
+	 * the CPU do not get remapped by the GART.  We fix this by using the ker=
nel's
+	 * page-table instead.
+	 */
+	area =3D get_vm_area(size, VM_AGP_REMAP);
+	if (!area)
+		return NULL;
+
+	flush_cache_all();
+
+	end_vaddr =3D area->addr + area->size;
+	paddrp =3D agpmem->memory->memory + (offset - agpmem->bound) / PAGE_SIZE;
+	for (vaddr =3D area->addr; vaddr < end_vaddr; vaddr +=3D PAGE_SIZE) {
+		paddr =3D *paddrp++;
+		page =3D pfn_to_page(paddr >> PAGE_SHIFT);
+		get_page(page);
+		if (agp_map_page((unsigned long) vaddr, paddr) < 0) {
+			put_page(page);
+			vfree(area->addr);
+			return NULL;
+		}
+	}
+
+	flush_tlb_kernel_range(area->addr, area->addr + size);
+	return area->addr;
+}
+
+#endif /* __REALLY_HAVE_AGP */
+
+void *DRM(ioremap)(unsigned long offset, unsigned long size, drm_device_t =
*dev)
 {
+	int remap_aperture =3D 0;
 	void *pt;
=20
 	if (!size) {
-		DRM_MEM_ERROR(DRM_MEM_MAPPINGS,
-			      "Mapping 0 bytes at 0x%08lx\n", offset);
+		DRM_MEM_ERROR(DRM_MEM_MAPPINGS, "Mapping 0 bytes at 0x%08lx\n", offset);
 		return NULL;
 	}
=20
-	if (!(pt =3D ioremap(offset, size))) {
+#if __REALLY_HAVE_AGP
+	if (dev->agp->cant_use_aperture) {
+		drm_map_t *map =3D DRM(lookup_map)(offset, size, dev);
+
+		if (map && map->type =3D _DRM_AGP)
+			remap_aperture =3D 1;
+	}
+#endif
+	if (remap_aperture)
+		pt =3D DRM(agp_remap)(offset, size, dev);
+ 	else
+		pt =3D ioremap(offset, size);
+	if (!pt) {
 		spin_lock(&DRM(mem_lock));
 		++DRM(mem_stats)[DRM_MEM_MAPPINGS].fail_count;
 		spin_unlock(&DRM(mem_lock));
@@ -314,8 +400,9 @@
 	return pt;
 }
=20
-void *DRM(ioremap_nocache)(unsigned long offset, unsigned long size)
+void *DRM(ioremap_nocache)(unsigned long offset, unsigned long size, drm_d=
evice_t *dev)
 {
+	int remap_aperture =3D 0;
 	void *pt;
=20
 	if (!size) {
@@ -324,7 +411,19 @@
 		return NULL;
 	}
=20
-	if (!(pt =3D ioremap_nocache(offset, size))) {
+#if __REALLY_HAVE_AGP
+	if (dev->agp->cant_use_aperture) {
+		drm_map_t *map =3D DRM(lookup_map)(offset, size, dev);
+
+		if (map && map->type =3D _DRM_AGP)
+			remap_aperture =3D 1;
+	}
+#endif
+	if (remap_aperture)
+		pt =3D DRM(agp_remap)(offset, size, dev);
+	else
+		pt =3D ioremap_nocache(offset, size);
+	if (!pt) {
 		spin_lock(&DRM(mem_lock));
 		++DRM(mem_stats)[DRM_MEM_MAPPINGS].fail_count;
 		spin_unlock(&DRM(mem_lock));
@@ -337,7 +436,7 @@
 	return pt;
 }
=20
-void DRM(ioremapfree)(void *pt, unsigned long size)
+void DRM(ioremapfree)(void *pt, unsigned long size, drm_device_t *dev)
 {
 	int alloc_count;
 	int free_count;
@@ -345,8 +444,14 @@
 	if (!pt)
 		DRM_MEM_ERROR(DRM_MEM_MAPPINGS,
 			      "Attempt to free NULL pointer\n");
-	else
-		iounmap(pt);
+	else {
+#if __REALLY_HAVE_AGP
+		if (dev->agp->cant_use_aperture && (vgetflags(pt) & VM_AGP_REMAP))
+			vfree(pt);
+		else
+#endif
+			iounmap(pt);
+	}
=20
 	spin_lock(&DRM(mem_lock));
 	DRM(mem_stats)[DRM_MEM_MAPPINGS].bytes_freed +=3D size;
diff -Nru a/drivers/char/drm/drm_vm.h b/drivers/char/drm/drm_vm.h
--- a/drivers/char/drm/drm_vm.h	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/drm/drm_vm.h	Sat Aug 10 01:51:46 2002
@@ -108,12 +108,12 @@
                  * Get the page, inc the use count, and return it
                  */
 		offset =3D (baddr - agpmem->bound) >> PAGE_SHIFT;
-		agpmem->memory->memory[offset] &=3D dev->agp->page_mask;
 		page =3D virt_to_page(__va(agpmem->memory->memory[offset]));
 		get_page(page);
=20
-		DRM_DEBUG("baddr =3D 0x%lx page =3D 0x%p, offset =3D 0x%lx\n",
-			  baddr, __va(agpmem->memory->memory[offset]), offset);
+		DRM_DEBUG("baddr =3D 0x%lx page =3D 0x%p, offset =3D 0x%lx, count=3D%d\n=
",
+			  baddr, __va(agpmem->memory->memory[offset]), offset,
+			  atomic_read(&page->count));
=20
 		return page;
         }
@@ -207,7 +207,7 @@
 					DRM_DEBUG("mtrr_del =3D %d\n", retcode);
 				}
 #endif
-				DRM(ioremapfree)(map->handle, map->size);
+				DRM(ioremapfree)(map->handle, map->size, dev);
 				break;
 			case _DRM_SHM:
 				vfree(map->handle);
@@ -421,15 +421,16 @@
=20
 	switch (map->type) {
         case _DRM_AGP:
-#if defined(__alpha__)
+#if __REALLY_HAVE_AGP
+	  if (dev->agp->cant_use_aperture) {
                 /*
-                 * On Alpha we can't talk to bus dma address from the
-                 * CPU, so for memory of type DRM_AGP, we'll deal with
-                 * sorting out the real physical pages and mappings
-                 * in nopage()
+                 * On some platforms we can't talk to bus dma address from=
 the CPU, so for
+                 * memory of type DRM_AGP, we'll deal with sorting out the=
 real physical
+                 * pages and mappings in nopage()
                  */
                 vma->vm_ops =3D &DRM(vm_ops);
                 break;
+	  }
 #endif
                 /* fall through to _DRM_FRAME_BUFFER... */       =20
 	case _DRM_FRAME_BUFFER:
@@ -440,15 +441,15 @@
 				pgprot_val(vma->vm_page_prot) |=3D _PAGE_PCD;
 				pgprot_val(vma->vm_page_prot) &=3D ~_PAGE_PWT;
 			}
-#elif defined(__ia64__)
-			if (map->type !=3D _DRM_AGP)
-				vma->vm_page_prot -					pgprot_writecombine(vma->vm_page_prot);
 #elif defined(__powerpc__)
 			pgprot_val(vma->vm_page_prot) |=3D _PAGE_NO_CACHE | _PAGE_GUARDED;
 #endif
 			vma->vm_flags |=3D VM_IO;	/* not in core dump */
 		}
+#if defined(__ia64__)
+		if (map->type !=3D _DRM_AGP)
+			vma->vm_page_prot =3D pgprot_writecombine(vma->vm_page_prot);
+#endif
 		offset =3D DRIVER_GET_REG_OFS();
 #ifdef __sparc__
 		if (io_remap_page_range(DRM_RPR_ARG(vma) vma->vm_start,
diff -Nru a/drivers/char/drm/gamma_dma.c b/drivers/char/drm/gamma_dma.c
--- a/drivers/char/drm/gamma_dma.c	Sat Aug 10 01:51:47 2002
+++ b/drivers/char/drm/gamma_dma.c	Sat Aug 10 01:51:47 2002
@@ -638,7 +638,7 @@
 	} else {
 		DRM_FIND_MAP( dev_priv->buffers, init->buffers_offset );
=20
-		DRM_IOREMAP( dev_priv->buffers );
+		DRM_IOREMAP( dev_priv->buffers, dev );
=20
 		buf =3D dma->buflist[GLINT_DRI_BUF_COUNT];
 		pgt =3D buf->address;
@@ -668,7 +668,7 @@
 	if ( dev->dev_private ) {
 		drm_gamma_private_t *dev_priv =3D dev->dev_private;
=20
-		DRM_IOREMAPFREE( dev_priv->buffers );
+		DRM_IOREMAPFREE( dev_priv->buffers, dev );
=20
 		DRM(free)( dev->dev_private, sizeof(drm_gamma_private_t),
 			   DRM_MEM_DRIVER );
diff -Nru a/drivers/char/drm/i810_dma.c b/drivers/char/drm/i810_dma.c
--- a/drivers/char/drm/i810_dma.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/drm/i810_dma.c	Sat Aug 10 01:51:46 2002
@@ -309,7 +309,7 @@
=20
 	   	if(dev_priv->ring.virtual_start) {
 		   	DRM(ioremapfree)((void *) dev_priv->ring.virtual_start,
-					 dev_priv->ring.Size);
+					 dev_priv->ring.Size, dev);
 		}
 	   	if(dev_priv->hw_status_page !=3D 0UL) {
 		   	i810_free_page(dev, dev_priv->hw_status_page);
@@ -323,7 +323,7 @@
 		for (i =3D 0; i < dma->buf_count; i++) {
 			drm_buf_t *buf =3D dma->buflist[ i ];
 			drm_i810_buf_priv_t *buf_priv =3D buf->dev_private;
-			DRM(ioremapfree)(buf_priv->kernel_virtual, buf->total);
+			DRM(ioremapfree)(buf_priv->kernel_virtual, buf->total, dev);
 		}
 	}
    	return 0;
@@ -395,7 +395,7 @@
 	   	*buf_priv->in_use =3D I810_BUF_FREE;
=20
 		buf_priv->kernel_virtual =3D DRM(ioremap)(buf->bus_address,
-							buf->total);
+							buf->total, dev);
 	}
 	return 0;
 }
@@ -448,7 +448,7 @@
=20
    	dev_priv->ring.virtual_start =3D DRM(ioremap)(dev->agp->base +
 						    init->ring_start,
-						    init->ring_size);
+						    init->ring_size, dev);
=20
    	if (dev_priv->ring.virtual_start =3D NULL) {
 		dev->dev_private =3D (void *) dev_priv;
diff -Nru a/drivers/char/drm/i830_dma.c b/drivers/char/drm/i830_dma.c
--- a/drivers/char/drm/i830_dma.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/drm/i830_dma.c	Sat Aug 10 01:51:46 2002
@@ -340,7 +340,7 @@
 	  =20
 	   	if(dev_priv->ring.virtual_start) {
 		   	DRM(ioremapfree)((void *) dev_priv->ring.virtual_start,
-					 dev_priv->ring.Size);
+					 dev_priv->ring.Size, dev);
 		}
 	   	if(dev_priv->hw_status_page !=3D 0UL) {
 		   	i830_free_page(dev, dev_priv->hw_status_page);
@@ -354,7 +354,7 @@
 		for (i =3D 0; i < dma->buf_count; i++) {
 			drm_buf_t *buf =3D dma->buflist[ i ];
 			drm_i830_buf_priv_t *buf_priv =3D buf->dev_private;
-			DRM(ioremapfree)(buf_priv->kernel_virtual, buf->total);
+			DRM(ioremapfree)(buf_priv->kernel_virtual, buf->total, dev);
 		}
 	}
    	return 0;
@@ -426,7 +426,7 @@
 	   	*buf_priv->in_use =3D I830_BUF_FREE;
=20
 		buf_priv->kernel_virtual =3D DRM(ioremap)(buf->bus_address,=20
-							buf->total);
+							buf->total, dev);
 	}
 	return 0;
 }
@@ -483,7 +483,7 @@
=20
    	dev_priv->ring.virtual_start =3D DRM(ioremap)(dev->agp->base +=20
 						    init->ring_start,=20
-						    init->ring_size);
+						    init->ring_size, dev);
=20
    	if (dev_priv->ring.virtual_start =3D NULL) {
 		dev->dev_private =3D (void *) dev_priv;
diff -Nru a/drivers/char/drm/mga_dma.c b/drivers/char/drm/mga_dma.c
--- a/drivers/char/drm/mga_dma.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/drm/mga_dma.c	Sat Aug 10 01:51:46 2002
@@ -559,9 +559,9 @@
 		(drm_mga_sarea_t *)((u8 *)dev_priv->sarea->handle +
 				    init->sarea_priv_offset);
=20
-	DRM_IOREMAP( dev_priv->warp );
-	DRM_IOREMAP( dev_priv->primary );
-	DRM_IOREMAP( dev_priv->buffers );
+	DRM_IOREMAP( dev_priv->warp, dev );
+	DRM_IOREMAP( dev_priv->primary, dev );
+	DRM_IOREMAP( dev_priv->buffers, dev );
=20
 	if(!dev_priv->warp->handle ||
 	   !dev_priv->primary->handle ||
@@ -649,9 +649,9 @@
 	if ( dev->dev_private ) {
 		drm_mga_private_t *dev_priv =3D dev->dev_private;
=20
-		DRM_IOREMAPFREE( dev_priv->warp );
-		DRM_IOREMAPFREE( dev_priv->primary );
-		DRM_IOREMAPFREE( dev_priv->buffers );
+		DRM_IOREMAPFREE( dev_priv->warp, dev );
+		DRM_IOREMAPFREE( dev_priv->primary, dev );
+		DRM_IOREMAPFREE( dev_priv->buffers, dev );
=20
 		if ( dev_priv->head !=3D NULL ) {
 			mga_freelist_cleanup( dev );
diff -Nru a/drivers/char/drm/mga_drv.h b/drivers/char/drm/mga_drv.h
--- a/drivers/char/drm/mga_drv.h	Sat Aug 10 01:51:47 2002
+++ b/drivers/char/drm/mga_drv.h	Sat Aug 10 01:51:47 2002
@@ -213,7 +213,7 @@
 		} else if ( dev_priv->prim.space <			\
 			    dev_priv->prim.high_mark ) {		\
 			if ( MGA_DMA_DEBUG )				\
-				DRM_INFO( __FUNCTION__": wrap...\n" );	\
+				DRM_INFO( "%s: wrap...\n", __FUNCTION__ );\
 			return -EBUSY;					\
 		}							\
 	}								\
@@ -224,7 +224,7 @@
 	if ( test_bit( 0, &dev_priv->prim.wrapped ) ) {			\
 		if ( mga_do_wait_for_idle( dev_priv ) < 0 ) {		\
 			if ( MGA_DMA_DEBUG )				\
-				DRM_INFO( __FUNCTION__": wrap...\n" );	\
+				DRM_INFO( "%s: wrap...\n", __FUNCTION__ );\
 			return -EBUSY;					\
 		}							\
 		mga_do_dma_wrap_end( dev_priv );			\
@@ -247,7 +247,7 @@
 	if ( MGA_VERBOSE ) {						\
 		DRM_INFO( "BEGIN_DMA( %d ) in %s\n",			\
 			  (n), __FUNCTION__ );				\
-		DRM_INFO( "   space=3D0x%x req=3D0x%x\n",			\
+		DRM_INFO( "   space=3D0x%x req=3D0x%Zx\n",			\
 			  dev_priv->prim.space, (n) * DMA_BLOCK_SIZE );	\
 	}								\
 	prim =3D dev_priv->prim.start;					\
@@ -276,7 +276,7 @@
 #define FLUSH_DMA()							\
 do {									\
 	if ( 0 ) {							\
-		DRM_INFO( __FUNCTION__ ":\n" );				\
+		DRM_INFO( "%s:\n", __FUNCTION__ );			\
 		DRM_INFO( "   tail=3D0x%06x head=3D0x%06lx\n",		\
 			  dev_priv->prim.tail,				\
 			  MGA_READ( MGA_PRIMADDRESS ) -			\
@@ -297,7 +297,7 @@
 #define DMA_WRITE( offset, val )					\
 do {									\
 	if ( MGA_VERBOSE ) {						\
-		DRM_INFO( "   DMA_WRITE( 0x%08x ) at 0x%04x\n",		\
+		DRM_INFO( "   DMA_WRITE( 0x%08x ) at 0x%04Zx\n",	\
 			  (u32)(val), write + (offset) * sizeof(u32) );	\
 	}								\
 	*(volatile u32 *)(prim + write + (offset) * sizeof(u32)) =3D val;	\
diff -Nru a/drivers/char/drm/mga_state.c b/drivers/char/drm/mga_state.c
--- a/drivers/char/drm/mga_state.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/drm/mga_state.c	Sat Aug 10 01:51:46 2002
@@ -523,7 +523,7 @@
 	int nbox =3D sarea_priv->nbox;
 	int i;
 	DMA_LOCALS;
-	DRM_DEBUG( __FUNCTION__ ":\n" );
+	DRM_DEBUG( "%s:\n", __FUNCTION__ );
=20
 	BEGIN_DMA( 1 );
=20
@@ -617,7 +617,7 @@
 	int nbox =3D sarea_priv->nbox;
 	int i;
 	DMA_LOCALS;
-	DRM_DEBUG( __FUNCTION__ ":\n" );
+	DRM_DEBUG( "%s:\n", __FUNCTION__ );
=20
 	sarea_priv->last_frame.head =3D dev_priv->prim.tail;
 	sarea_priv->last_frame.wrap =3D dev_priv->prim.last_wrap;
@@ -826,7 +826,7 @@
 	int nbox =3D sarea_priv->nbox;
 	u32 scandir =3D 0, i;
 	DMA_LOCALS;
-	DRM_DEBUG( __FUNCTION__ ":\n" );
+	DRM_DEBUG( "%s:\n", __FUNCTION__ );
=20
 	BEGIN_DMA( 4 + nbox );
=20
@@ -1029,7 +1029,7 @@
 	drm_buf_t *buf;
 	drm_mga_buf_priv_t *buf_priv;
 	drm_mga_iload_t iload;
-	DRM_DEBUG( __FUNCTION__ ":\n" );
+	DRM_DEBUG( "%s:\n", __FUNCTION__ );
=20
 	LOCK_TEST_WITH_RETURN( dev );
=20
diff -Nru a/drivers/char/drm/r128_cce.c b/drivers/char/drm/r128_cce.c
--- a/drivers/char/drm/r128_cce.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/drm/r128_cce.c	Sat Aug 10 01:51:46 2002
@@ -354,8 +354,8 @@
=20
 		R128_WRITE( R128_PM4_BUFFER_DL_RPTR_ADDR,
      			    entry->busaddr[page_ofs]);
-		DRM_DEBUG( "ring rptr: offset=3D0x%08x handle=3D0x%08lx\n",
-			   entry->busaddr[page_ofs],
+		DRM_DEBUG( "ring rptr: offset=3D0x%08lx handle=3D0x%08lx\n",
+			   (unsigned long) entry->busaddr[page_ofs],
      			   entry->handle + tmp_ofs );
 	}
=20
@@ -552,9 +552,9 @@
 				     init->sarea_priv_offset);
=20
 	if ( !dev_priv->is_pci ) {
-		DRM_IOREMAP( dev_priv->cce_ring );
-		DRM_IOREMAP( dev_priv->ring_rptr );
-		DRM_IOREMAP( dev_priv->buffers );
+		DRM_IOREMAP( dev_priv->cce_ring, dev );
+		DRM_IOREMAP( dev_priv->ring_rptr, dev );
+		DRM_IOREMAP( dev_priv->buffers, dev );
 		if(!dev_priv->cce_ring->handle ||
 		   !dev_priv->ring_rptr->handle ||
 		   !dev_priv->buffers->handle) {
@@ -626,9 +626,9 @@
 		drm_r128_private_t *dev_priv =3D dev->dev_private;
=20
 		if ( !dev_priv->is_pci ) {
-			DRM_IOREMAPFREE( dev_priv->cce_ring );
-			DRM_IOREMAPFREE( dev_priv->ring_rptr );
-			DRM_IOREMAPFREE( dev_priv->buffers );
+			DRM_IOREMAPFREE( dev_priv->cce_ring, dev );
+			DRM_IOREMAPFREE( dev_priv->ring_rptr, dev );
+			DRM_IOREMAPFREE( dev_priv->buffers, dev );
 		} else {
 			if (!DRM(ati_pcigart_cleanup)( dev,
 						dev_priv->phys_pci_gart,
diff -Nru a/drivers/char/drm/r128_drv.h b/drivers/char/drm/r128_drv.h
--- a/drivers/char/drm/r128_drv.h	Sat Aug 10 01:51:47 2002
+++ b/drivers/char/drm/r128_drv.h	Sat Aug 10 01:51:47 2002
@@ -436,7 +436,7 @@
 		DRM_ERROR( "ring space check failed!\n" );		\
 		return -EBUSY;						\
 	}								\
- __ring_space_done:							\
+ __ring_space_done:;							\
 } while (0)
=20
 #define VB_AGE_TEST_WITH_RETURN( dev_priv )				\
diff -Nru a/drivers/char/drm/radeon_cp.c b/drivers/char/drm/radeon_cp.c
--- a/drivers/char/drm/radeon_cp.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/drm/radeon_cp.c	Sat Aug 10 01:51:46 2002
@@ -627,8 +627,8 @@
=20
 		RADEON_WRITE( RADEON_CP_RB_RPTR_ADDR,
 			     entry->busaddr[page_ofs]);
-		DRM_DEBUG( "ring rptr: offset=3D0x%08x handle=3D0x%08lx\n",
-			   entry->busaddr[page_ofs],
+		DRM_DEBUG( "ring rptr: offset=3D0x%08lx handle=3D0x%08lx\n",
+			   (unsigned long) entry->busaddr[page_ofs],
 			   entry->handle + tmp_ofs );
 	}
=20
@@ -844,9 +844,9 @@
 				       init->sarea_priv_offset);
=20
 	if ( !dev_priv->is_pci ) {
-		DRM_IOREMAP( dev_priv->cp_ring );
-		DRM_IOREMAP( dev_priv->ring_rptr );
-		DRM_IOREMAP( dev_priv->buffers );
+		DRM_IOREMAP( dev_priv->cp_ring, dev );
+		DRM_IOREMAP( dev_priv->ring_rptr, dev );
+		DRM_IOREMAP( dev_priv->buffers, dev );
 		if(!dev_priv->cp_ring->handle ||
 		   !dev_priv->ring_rptr->handle ||
 		   !dev_priv->buffers->handle) {
@@ -989,9 +989,9 @@
 		drm_radeon_private_t *dev_priv =3D dev->dev_private;
=20
 		if ( !dev_priv->is_pci ) {
-			DRM_IOREMAPFREE( dev_priv->cp_ring );
-			DRM_IOREMAPFREE( dev_priv->ring_rptr );
-			DRM_IOREMAPFREE( dev_priv->buffers );
+			DRM_IOREMAPFREE( dev_priv->cp_ring, dev );
+			DRM_IOREMAPFREE( dev_priv->ring_rptr, dev );
+			DRM_IOREMAPFREE( dev_priv->buffers, dev );
 		} else {
 			if (!DRM(ati_pcigart_cleanup)( dev,
 						dev_priv->phys_pci_gart,
diff -Nru a/drivers/char/drm/radeon_drv.h b/drivers/char/drm/radeon_drv.h
--- a/drivers/char/drm/radeon_drv.h	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/drm/radeon_drv.h	Sat Aug 10 01:51:46 2002
@@ -657,7 +657,7 @@
 		DRM_ERROR( "ring space check failed!\n" );		\
 		return -EBUSY;						\
 	}								\
- __ring_space_done:							\
+ __ring_space_done:;							\
 } while (0)
=20
 #define VB_AGE_TEST_WITH_RETURN( dev_priv )				\
diff -Nru a/drivers/char/drm/radeon_state.c b/drivers/char/drm/radeon_state=
.c
--- a/drivers/char/drm/radeon_state.c	Sat Aug 10 01:51:47 2002
+++ b/drivers/char/drm/radeon_state.c	Sat Aug 10 01:51:47 2002
@@ -327,7 +327,7 @@
 	u32 rb3d_cntl =3D 0, rb3d_stencilrefmask=3D 0;
 	int i;
 	RING_LOCALS;
-	DRM_DEBUG( __FUNCTION__": flags =3D 0x%x\n", flags );
+	DRM_DEBUG( "%s: flags =3D 0x%x\n", __FUNCTION__, flags );
=20
 	if ( dev_priv->page_flipping && dev_priv->current_page =3D 1 ) {
 		unsigned int tmp =3D flags;
@@ -1507,8 +1507,8 @@
 			     sizeof(vertex) ) )
 		return -EFAULT;
=20
-	DRM_DEBUG( __FUNCTION__": pid=3D%d index=3D%d discard=3D%d\n",
-		   current->pid, vertex.idx, vertex.discard );
+	DRM_DEBUG( "%s: pid=3D%d index=3D%d discard=3D%d\n",
+		   __FUNCTION__, current->pid, vertex.idx, vertex.discard );
=20
 	if ( vertex.idx < 0 || vertex.idx >=3D dma->buf_count ) {
 		DRM_ERROR( "buffer index %d (of %d max)\n",
@@ -1759,7 +1759,7 @@
 		return -EFAULT;
 	}
=20
-	DRM_DEBUG( __FUNCTION__": pid=3D%d\n", current->pid );
+	DRM_DEBUG( "%s: pid=3D%d\n", __FUNCTION__, current->pid );
 	RING_SPACE_TEST_WITH_RETURN( dev_priv );
 	VB_AGE_TEST_WITH_RETURN( dev_priv );
=20
@@ -1870,7 +1870,7 @@
 		return -EFAULT;
 	}
=20
-	DRM_DEBUG( __FUNCTION__": pid=3D%d\n", current->pid );
+	DRM_DEBUG( "%s: pid=3D%d\n", __FUNCTION__, current->pid );
=20
 	switch( param.param ) {
 	case RADEON_PARAM_AGP_BUFFER_OFFSET:
diff -Nru a/drivers/char/mem.c b/drivers/char/mem.c
--- a/drivers/char/mem.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/char/mem.c	Sat Aug 10 01:51:46 2002
@@ -510,10 +510,12 @@
 		case 0:
 			file->f_pos =3D offset;
 			ret =3D file->f_pos;
+			force_successful_syscall_return();
 			break;
 		case 1:
 			file->f_pos +=3D offset;
 			ret =3D file->f_pos;
+			force_successful_syscall_return();
 			break;
 		default:
 			ret =3D -EINVAL;
diff -Nru a/drivers/media/radio/Makefile b/drivers/media/radio/Makefile
--- a/drivers/media/radio/Makefile	Sat Aug 10 01:51:46 2002
+++ b/drivers/media/radio/Makefile	Sat Aug 10 01:51:46 2002
@@ -5,6 +5,8 @@
 # All of the (potential) objects that export symbols.
 # This list comes from 'grep -l EXPORT_SYMBOL *.[hc]'.
=20
+obj-y		:=3D dummy.o
+
 export-objs     :=3D miropcm20-rds-core.o
=20
 miropcm20-objs	:=3D miropcm20-rds-core.o miropcm20-radio.o
diff -Nru a/drivers/media/radio/dummy.c b/drivers/media/radio/dummy.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/drivers/media/radio/dummy.c	Sat Aug 10 01:51:47 2002
@@ -0,0 +1 @@
+/* just so the linker knows what kind of object files it's deadling with..=
. */
diff -Nru a/drivers/media/video/Makefile b/drivers/media/video/Makefile
--- a/drivers/media/video/Makefile	Sat Aug 10 01:51:46 2002
+++ b/drivers/media/video/Makefile	Sat Aug 10 01:51:46 2002
@@ -5,7 +5,8 @@
 # All of the (potential) objects that export symbols.
 # This list comes from 'grep -l EXPORT_SYMBOL *.[hc]'.
=20
-export-objs     :=3D	videodev.o bttv-if.o cpia.o video-buf.o
+obj-y		:=3D dummy.o
+
=20
 bttv-objs	:=3D	bttv-driver.o bttv-cards.o bttv-if.o \
 			bttv-risc.o bttv-vbi.o
diff -Nru a/drivers/media/video/dummy.c b/drivers/media/video/dummy.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/drivers/media/video/dummy.c	Sat Aug 10 01:51:47 2002
@@ -0,0 +1 @@
+/* just so the linker knows what kind of object files it's deadling with..=
. */
diff -Nru a/drivers/message/fusion/mptscsih.c b/drivers/message/fusion/mpts=
csih.c
--- a/drivers/message/fusion/mptscsih.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/message/fusion/mptscsih.c	Sat Aug 10 01:51:46 2002
@@ -99,6 +99,8 @@
 MODULE_PARM(mptscsih, "s");
 #endif
=20
+static spinlock_t detect_lock =3D SPIN_LOCK_UNLOCKED;
+
 /*=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D*/
=20
 typedef struct _BIG_SENSE_BUF {
@@ -1156,8 +1158,7 @@
 #endif
 			sh =3D scsi_register(tpnt, sizeof(MPT_SCSI_HOST));
 			if (sh !=3D NULL) {
-				save_flags(flags);
-				cli();
+				spin_lock_irqsave(&detect_lock, flags);
 				sh->io_port =3D 0;
 				sh->n_io_port =3D 0;
 				sh->irq =3D 0;
@@ -1221,7 +1222,7 @@
 				 */
 				scsi_set_pci_device(sh, this->pcidev);
=20
-				restore_flags(flags);
+				spin_unlock_irqrestore(&detect_lock, flags);
=20
 				hd =3D (MPT_SCSI_HOST *) sh->hostdata;
 				hd->ioc =3D this;
diff -Nru a/drivers/net/eepro100.c b/drivers/net/eepro100.c
--- a/drivers/net/eepro100.c	Sat Aug 10 01:51:47 2002
+++ b/drivers/net/eepro100.c	Sat Aug 10 01:51:47 2002
@@ -25,6 +25,8 @@
 		Disabled FC and ER, to avoid lockups when when we get FCP interrupts.
 	2000 Jul 17 Goutham Rao <goutham.rao@intel.com>
 		PCI DMA API fixes, adding pci_dma_sync_single calls where neccesary
+    2000 Aug 31 David Mosberger <davidm@hpl.hp.com>
+	    RX_ALIGN support: enables rx DMA without causing unaligned accesses.
 */
=20
 static const char *version @@ -41,14 +43,18 @@
 static int txdmacount =3D 128;
 static int rxdmacount /* =3D 0 */;
=20
+#if defined(__ia64__) || defined(__alpha__) || defined(__sparc__) || defin=
ed(__mips__) || \
+	defined(__arm__)
+  /* align rx buffers to 2 bytes so that IP header is aligned */
+# define RX_ALIGN
+# define RxFD_ALIGNMENT		__attribute__ ((aligned (2), packed))
+#else
+# define RxFD_ALIGNMENT
+#endif
+
 /* Set the copy breakpoint for the copy-only-tiny-buffer Rx method.
    Lower values use more memory, but are faster. */
-#if defined(__alpha__) || defined(__sparc__) || defined(__mips__) || \
-    defined(__arm__)
-static int rx_copybreak =3D 1518;
-#else
 static int rx_copybreak =3D 200;
-#endif
=20
 /* Maximum events (Rx packets, etc.) to handle at each interrupt. */
 static int max_interrupt_work =3D 20;
@@ -377,18 +383,18 @@
=20
 /* The Speedo3 Rx and Tx frame/buffer descriptors. */
 struct descriptor {			    /* A generic descriptor. */
-	s32 cmd_status;				/* All command and status fields. */
+	volatile s32 cmd_status;	/* All command and status fields. */
 	u32 link;				    /* struct descriptor *  */
 	unsigned char params[0];
 };
=20
 /* The Speedo3 Rx and Tx buffer descriptors. */
 struct RxFD {					/* Receive frame descriptor. */
-	s32 status;
+	volatile s32 status;
 	u32 link;					/* struct RxFD * */
 	u32 rx_buf_addr;			/* void * */
 	u32 count;
-};
+} RxFD_ALIGNMENT;
=20
 /* Selected elements of the Tx/RxFD.status word. */
 enum RxFD_bits {
@@ -523,7 +529,12 @@
=20
 static int eepro100_init_one(struct pci_dev *pdev,
 		const struct pci_device_id *ent);
+
 static void eepro100_remove_one (struct pci_dev *pdev);
+#ifdef CONFIG_PM
+static int eepro100_suspend (struct pci_dev *pdev, u32 state);
+static int eepro100_resume (struct pci_dev *pdev);
+#endif
=20
 static int do_eeprom_cmd(long ioaddr, int cmd, int cmd_len);
 static int mdio_read(long ioaddr, int phy_id, int location);
@@ -1229,6 +1240,9 @@
 	for (i =3D 0; i < RX_RING_SIZE; i++) {
 		struct sk_buff *skb;
 		skb =3D dev_alloc_skb(PKT_BUF_SZ + sizeof(struct RxFD));
+#ifdef RX_ALIGN
+		skb_reserve(skb, 2);	/* Align IP on 16 byte boundary */
+#endif
 		sp->rx_skbuff[i] =3D skb;
 		if (skb =3D NULL)
 			break;			/* OK.  Just initially short of Rx bufs. */
@@ -1620,6 +1634,9 @@
 	struct sk_buff *skb;
 	/* Get a fresh skbuff to replace the consumed one. */
 	skb =3D dev_alloc_skb(PKT_BUF_SZ + sizeof(struct RxFD));
+#ifdef RX_ALIGN
+	skb_reserve(skb, 2);	/* Align IP on 16 byte boundary */
+#endif
 	sp->rx_skbuff[entry] =3D skb;
 	if (skb =3D NULL) {
 		sp->rx_ringp[entry] =3D NULL;
@@ -2303,7 +2320,9 @@
 	name:		"eepro100",
 	id_table:	eepro100_pci_tbl,
 	probe:		eepro100_init_one,
+# if defined(MODULE) || defined(CONFIG_HOTPLUG)
 	remove:		__devexit_p(eepro100_remove_one),
+# endif
 #ifdef CONFIG_PM
 	suspend:	eepro100_suspend,
 	resume:		eepro100_resume,
diff -Nru a/drivers/net/tulip/media.c b/drivers/net/tulip/media.c
--- a/drivers/net/tulip/media.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/net/tulip/media.c	Sat Aug 10 01:51:46 2002
@@ -278,6 +278,10 @@
 				for (i =3D 0; i < init_length; i++)
 					outl(init_sequence[i], ioaddr + CSR12);
 			}
+
+			(void) inl(ioaddr + CSR6); /* flush CSR12 writes */
+			udelay(500);		/* Give MII time to recover */
+
 			tmp_info =3D get_u16(&misc_info[1]);
 			if (tmp_info)
 				tp->advertising[phy_num] =3D tmp_info | 1;
diff -Nru a/drivers/scsi/megaraid.c b/drivers/scsi/megaraid.c
--- a/drivers/scsi/megaraid.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/scsi/megaraid.c	Sat Aug 10 01:51:46 2002
@@ -2047,7 +2047,7 @@
 		return;
=20
 	mbox =3D (mega_mailbox *) pScb->mboxData;
-	printk ("%u cmd:%x id:%x #scts:%x lba:%x addr:%x logdrv:%x #sg:%x\n",
+	printk ("%lu cmd:%x id:%x #scts:%x lba:%x addr:%x logdrv:%x #sg:%x\n",
 		pScb->SCpnt->pid,
 		mbox->cmd, mbox->cmdid, mbox->numsectors,
 		mbox->lba, mbox->xferaddr, mbox->logdrv, mbox->numsgelements);
@@ -3356,9 +3356,13 @@
 	mbox[0] =3D IS_BIOS_ENABLED;
 	mbox[2] =3D GET_BIOS;
=20
-	mboxpnt->xferaddr =3D virt_to_bus ((void *) megacfg->mega_buffer);
+	mboxpnt->xferaddr =3D pci_map_single(megacfg->dev,
+				(void *) megacfg->mega_buffer, (2 * 1024L),
+				PCI_DMA_FROMDEVICE);
=20
 	ret =3D megaIssueCmd (megacfg, mbox, NULL, 0);
+
+	pci_unmap_single(megacfg->dev, mboxpnt->xferaddr, 2 * 1024L, PCI_DMA_FROM=
DEVICE);
=20
 	return (*(char *) megacfg->mega_buffer);
 }
diff -Nru a/drivers/scsi/scsi_ioctl.c b/drivers/scsi/scsi_ioctl.c
--- a/drivers/scsi/scsi_ioctl.c	Sat Aug 10 01:51:47 2002
+++ b/drivers/scsi/scsi_ioctl.c	Sat Aug 10 01:51:47 2002
@@ -196,6 +196,9 @@
 	unsigned int needed, buf_needed;
 	int timeout, retries, result;
 	int data_direction, gfp_mask =3D GFP_KERNEL;
+#if __GNUC__ < 3
+	int foo;
+#endif
=20
 	if (!sic)
 		return -EINVAL;
@@ -209,11 +212,21 @@
 	if (verify_area(VERIFY_READ, sic, sizeof(Scsi_Ioctl_Command)))
 		return -EFAULT;
=20
+#if __GNUC__ < 3
+	foo =3D __get_user(inlen, &sic->inlen);
+	if (foo)
+		return -EFAULT;
+
+	foo =3D __get_user(outlen, &sic->outlen);
+	if (foo)
+		return -EFAULT;
+#else
 	if(__get_user(inlen, &sic->inlen))
 		return -EFAULT;
 	=09
 	if(__get_user(outlen, &sic->outlen))
 		return -EFAULT;
+#endif
=20
 	/*
 	 * We do not transfer more than MAX_BUF with this interface.
diff -Nru a/drivers/scsi/sym53c8xx_2/sym_glue.c b/drivers/scsi/sym53c8xx_2/=
sym_glue.c
--- a/drivers/scsi/sym53c8xx_2/sym_glue.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/scsi/sym53c8xx_2/sym_glue.c	Sat Aug 10 01:51:46 2002
@@ -295,11 +295,7 @@
 #ifndef SYM_LINUX_DYNAMIC_DMA_MAPPING
 typedef u_long		bus_addr_t;
 #else
-#if	SYM_CONF_DMA_ADDRESSING_MODE > 0
-typedef dma64_addr_t	bus_addr_t;
-#else
 typedef dma_addr_t	bus_addr_t;
-#endif
 #endif
=20
 /*
diff -Nru a/drivers/scsi/sym53c8xx_2/sym_malloc.c b/drivers/scsi/sym53c8xx_=
2/sym_malloc.c
--- a/drivers/scsi/sym53c8xx_2/sym_malloc.c	Sat Aug 10 01:51:47 2002
+++ b/drivers/scsi/sym53c8xx_2/sym_malloc.c	Sat Aug 10 01:51:47 2002
@@ -143,12 +143,14 @@
 	a =3D (m_addr_t) ptr;
=20
 	while (1) {
-#ifdef SYM_MEM_FREE_UNUSED
 		if (s =3D SYM_MEM_CLUSTER_SIZE) {
+#ifdef SYM_MEM_FREE_UNUSED
 			M_FREE_MEM_CLUSTER(a);
-			break;
-		}
+#else
+			((m_link_p) a)->next =3D h[i].next;
+			h[i].next =3D (m_link_p) a;
 #endif
+		}
 		b =3D a ^ s;
 		q =3D &h[i];
 		while (q->next && q->next !=3D (m_link_p) b) {
diff -Nru a/drivers/serial/8250.c b/drivers/serial/8250.c
--- a/drivers/serial/8250.c	Sat Aug 10 01:51:46 2002
+++ b/drivers/serial/8250.c	Sat Aug 10 01:51:46 2002
@@ -1909,6 +1909,17 @@
 	return 0;
 }
=20
+int __init early_register_port (struct uart_port *port)
+{
+	if (port->line >=3D ARRAY_SIZE(serial8250_ports))
+		return -ENODEV;
+
+	serial8250_isa_init_ports();	/* force ISA defaults */
+	serial8250_ports[port->line].port =3D *port;
+	serial8250_ports[port->line].port.ops =3D &serial8250_pops;
+	return 0;
+}
+
 /**
  *	unregister_serial - remove a 16x50 serial port at runtime
  *	@line: serial line number
diff -Nru a/drivers/serial/Config.in b/drivers/serial/Config.in
--- a/drivers/serial/Config.in	Sat Aug 10 01:51:46 2002
+++ b/drivers/serial/Config.in	Sat Aug 10 01:51:46 2002
@@ -11,6 +11,10 @@
 dep_tristate '8250/16550 and compatible serial support (EXPERIMENTAL)' CON=
FIG_SERIAL_8250 $CONFIG_EXPERIMENTAL
 dep_bool '  Console on 8250/16550 and compatible serial port (EXPERIMENTAL=
)' CONFIG_SERIAL_8250_CONSOLE $CONFIG_SERIAL_8250 $CONFIG_EXPERIMENTAL
 dep_tristate '  8250/16550 PCMCIA device support' CONFIG_SERIAL_8250_CS $C=
ONFIG_PCMCIA $CONFIG_SERIAL_8250
+if [ "$CONFIG_IA64" =3D "y" ]; then
+  dep_tristate '  8250/16550 device discovery support via ACPI SPCR/DBGP t=
ables' CONFIG_SERIAL_8250_ACPI
+  dep_tristate '  8250/16550 device discovery support via EFI HCDP table' =
CONFIG_SERIAL_8250_HCDP
+fi
=20
 dep_mbool 'Extended 8250/16550 serial driver options' CONFIG_SERIAL_8250_E=
XTENDED $CONFIG_SERIAL_8250
 dep_bool '  Support more than 4 serial ports' CONFIG_SERIAL_8250_MANY_PORT=
S $CONFIG_SERIAL_8250_EXTENDED
diff -Nru a/drivers/serial/Makefile b/drivers/serial/Makefile
--- a/drivers/serial/Makefile	Sat Aug 10 01:51:46 2002
+++ b/drivers/serial/Makefile	Sat Aug 10 01:51:46 2002
@@ -9,6 +9,8 @@
 serial-8250-y : serial-8250-$(CONFIG_PCI) +=3D 8250_pci.o
 serial-8250-$(CONFIG_ISAPNP) +=3D 8250_pnp.o
+obj-$(CONFIG_SERIAL_8250_ACPI) +=3D 8250_acpi.o
+obj-$(CONFIG_SERIAL_8250_HCDP) +=3D 8250_hcdp.o
 obj-$(CONFIG_SERIAL_CORE) +=3D core.o
 obj-$(CONFIG_SERIAL_21285) +=3D 21285.o
 obj-$(CONFIG_SERIAL_8250) +=3D 8250.o $(serial-8250-y)
diff -Nru a/drivers/video/radeonfb.c b/drivers/video/radeonfb.c
--- a/drivers/video/radeonfb.c	Sat Aug 10 01:51:47 2002
+++ b/drivers/video/radeonfb.c	Sat Aug 10 01:51:47 2002
@@ -233,8 +233,8 @@
 	u32 mmio_base_phys;
 	u32 fb_base_phys;
=20
-	u32 mmio_base;
-	u32 fb_base;
+	void *mmio_base;
+	void *fb_base;
=20
 	struct pci_dev *pdev;
=20
@@ -727,8 +727,7 @@
 	}
=20
 	/* map the regions */
-	rinfo->mmio_base =3D (u32) ioremap (rinfo->mmio_base_phys,
-				    		    RADEON_REGSIZE);
+	rinfo->mmio_base =3D ioremap (rinfo->mmio_base_phys, RADEON_REGSIZE);
 	if (!rinfo->mmio_base) {
 		printk ("radeonfb: cannot map MMIO\n");
 		release_mem_region (rinfo->mmio_base_phys,
@@ -858,8 +857,7 @@
 		}
 	}
=20
-	rinfo->fb_base =3D (u32) ioremap (rinfo->fb_base_phys,
-				  		  rinfo->video_ram);
+	rinfo->fb_base =3D ioremap (rinfo->fb_base_phys, rinfo->video_ram);
 	if (!rinfo->fb_base) {
 		printk ("radeonfb: cannot map FB\n");
 		iounmap ((void*)rinfo->mmio_base);
diff -Nru a/fs/fcntl.c b/fs/fcntl.c
--- a/fs/fcntl.c	Sat Aug 10 01:51:46 2002
+++ b/fs/fcntl.c	Sat Aug 10 01:51:46 2002
@@ -303,6 +303,7 @@
 			 * to fix this will be in libc.
 			 */
 			err =3D filp->f_owner.pid;
+			force_successful_syscall_return();
 			break;
 		case F_SETOWN:
 			lock_kernel();
diff -Nru a/fs/proc/base.c b/fs/proc/base.c
--- a/fs/proc/base.c	Sat Aug 10 01:51:46 2002
+++ b/fs/proc/base.c	Sat Aug 10 01:51:46 2002
@@ -508,7 +508,24 @@
 }
 #endif
=20
+static loff_t mem_lseek(struct file * file, loff_t offset, int orig)
+{
+	switch (orig) {
+	      case 0:
+		file->f_pos =3D offset;
+		break;
+	      case 1:
+		file->f_pos +=3D offset;
+		break;
+	      default:
+		return -EINVAL;
+	}
+	force_successful_syscall_return();
+	return file->f_pos;
+}
+
 static struct file_operations proc_mem_operations =3D {
+	llseek:		mem_lseek,
 	read:		mem_read,
 	write:		mem_write,
 	open:		mem_open,
diff -Nru a/include/asm-i386/hw_irq.h b/include/asm-i386/hw_irq.h
--- a/include/asm-i386/hw_irq.h	Sat Aug 10 01:51:47 2002
+++ b/include/asm-i386/hw_irq.h	Sat Aug 10 01:51:47 2002
@@ -107,4 +107,6 @@
 static inline void hw_resend_irq(struct hw_interrupt_type *h, unsigned int=
 i) {}
 #endif
=20
+extern irq_desc_t irq_desc [NR_IRQS];
+
 #endif /* _ASM_HW_IRQ_H */
diff -Nru a/include/asm-i386/ptrace.h b/include/asm-i386/ptrace.h
--- a/include/asm-i386/ptrace.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-i386/ptrace.h	Sat Aug 10 01:51:46 2002
@@ -58,6 +58,7 @@
 #define user_mode(regs) ((VM_MASK & (regs)->eflags) || (3 & (regs)->xcs))
 #define instruction_pointer(regs) ((regs)->eip)
 extern void show_regs(struct pt_regs *);
+#define force_successful_syscall_return()	do { } while (0)
 #endif
=20
 #endif
diff -Nru a/include/asm-ia64/acpi.h b/include/asm-ia64/acpi.h
--- a/include/asm-ia64/acpi.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/acpi.h	Sat Aug 10 01:51:46 2002
@@ -30,11 +30,74 @@
=20
 #ifdef __KERNEL__
=20
-#define __acpi_map_table(phys_addr, size) __va(phys_addr)
+#define COMPILER_DEPENDENT_INT64	long
+#define COMPILER_DEPENDENT_UINT64	unsigned long
+
+/*
+ * Calling conventions:
+ *
+ * ACPI_SYSTEM_XFACE        - Interfaces to host OS (handlers, threads)
+ * ACPI_EXTERNAL_XFACE      - External ACPI interfaces
+ * ACPI_INTERNAL_XFACE      - Internal ACPI interfaces
+ * ACPI_INTERNAL_VAR_XFACE  - Internal variable-parameter list interfaces
+ */
+#define ACPI_SYSTEM_XFACE
+#define ACPI_EXTERNAL_XFACE
+#define ACPI_INTERNAL_XFACE
+#define ACPI_INTERNAL_VAR_XFACE
+
+/* Asm macros */
+
+#define ACPI_ASM_MACROS
+#define BREAKPOINT3
+#define ACPI_DISABLE_IRQS() local_irq_disable()
+#define ACPI_ENABLE_IRQS()  local_irq_enable()
+#define ACPI_FLUSH_CPU_CACHE()
+
+#define ACPI_ACQUIRE_GLOBAL_LOCK(GLptr, Acq) \
+	do { \
+	__asm__ volatile ("1:  ld4      r29=3D%1\n"  \
+		";;\n"                  \
+		"mov    ar.ccv=3Dr29\n"   \
+		"mov    r2=3Dr29\n"       \
+		"shr.u  r30=3Dr29,1\n"    \
+		"and    r29=3D-4,r29\n"   \
+		";;\n"                  \
+		"add    r29=3D2,r29\n"    \
+		"and    r30=3D1,r30\n"    \
+		";;\n"                  \
+		"add    r29=3Dr29,r30\n"  \
+		";;\n"                  \
+		"cmpxchg4.acq   r30=3D%1,r29,ar.ccv\n" \
+		";;\n"                  \
+		"cmp.eq p6,p7=3Dr2,r30\n" \
+		"(p7) br.dpnt.few 1b\n" \
+		"cmp.gt p8,p9=3D3,r29\n"  \
+		";;\n"                  \
+		"(p8) mov %0=3D-1\n"      \
+		"(p9) mov %0=3Dr0\n"      \
+		:"=3Dr"(Acq):"m"(GLptr):"r2","r29","r30","memory"); \
+	} while (0)
+
+#define ACPI_RELEASE_GLOBAL_LOCK(GLptr, Acq) \
+	do { \
+	__asm__ volatile ("1:  ld4      r29=3D%1\n" \
+		";;\n"                  \
+		"mov    ar.ccv=3Dr29\n"   \
+		"mov    r2=3Dr29\n"       \
+		"and    r29=3D-4,r29\n"   \
+		";;\n"                  \
+		"cmpxchg4.acq   r30=3D%1,r29,ar.ccv\n" \
+		";;\n"                  \
+		"cmp.eq p6,p7=3Dr2,r30\n" \
+		"(p7) br.dpnt.few 1b\n" \
+		"and    %0=3D1,r2\n"      \
+		";;\n"                  \
+		:"=3Dr"(Acq):"m"(GLptr):"r2","r29","r30","memory"); \
+	} while (0)
=20
 const char *acpi_get_sysname (void);
 int acpi_boot_init (char *cdline);
-int acpi_find_rsdp (unsigned long *phys_addr);
 int acpi_request_vector (u32 int_type);
 int acpi_get_prt (struct pci_vector_struct **vectors, int *count);
 int acpi_get_interrupt_model(int *type);
diff -Nru a/include/asm-ia64/agp.h b/include/asm-ia64/agp.h
--- a/include/asm-ia64/agp.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/agp.h	Sat Aug 10 01:51:46 2002
@@ -1,11 +1,21 @@
-#ifndef AGP_H
-#define AGP_H 1
+#ifndef _ASM_IA64_AGP_H
+#define _ASM_IA64_AGP_H
=20
-/* dummy for now */
+/*
+ * IA-64 specific AGP definitions.
+ *
+ * Copyright (C) 2002 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+ */
=20
-#define map_page_into_agp(page)=20
-#define unmap_page_from_agp(page)=20
-#define flush_agp_mappings()=20
-#define flush_agp_cache() mb()
+/*
+ * To avoid memory-attribute aliasing issues, we require that the AGPGART =
engine operate
+ * in coherent mode, which lets us map the AGP memory as normal (write-bac=
k) memory
+ * (unlike x86, where it gets mapped "write-coalescing").
+ */
+#define map_page_into_agp(page)		/* nothing */
+#define unmap_page_from_agp(page)	/* nothing */
+#define flush_agp_mappings()		/* nothing */
+#define flush_agp_cache()		mb()
=20
-#endif
+#endif /* _ASM_IA64_AGP_H */
diff -Nru a/include/asm-ia64/bitops.h b/include/asm-ia64/bitops.h
--- a/include/asm-ia64/bitops.h	Sat Aug 10 01:51:47 2002
+++ b/include/asm-ia64/bitops.h	Sat Aug 10 01:51:47 2002
@@ -326,7 +326,7 @@
 	return exp - 0xffff;
 }
=20
-static int
+static inline int
 fls (int x)
 {
 	return ia64_fls((unsigned int) x);
diff -Nru a/include/asm-ia64/cacheflush.h b/include/asm-ia64/cacheflush.h
--- a/include/asm-ia64/cacheflush.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/cacheflush.h	Sat Aug 10 01:51:46 2002
@@ -6,6 +6,8 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
+#include <linux/page-flags.h>
+
 #include <asm/bitops.h>
 #include <asm/page.h>
=20
@@ -23,7 +25,7 @@
=20
 #define flush_dcache_page(page)			\
 do {						\
-	clear_bit(PG_arch_1, &page->flags);	\
+	clear_bit(PG_arch_1, &(page)->flags);	\
 } while (0)
=20
 extern void flush_icache_range (unsigned long start, unsigned long end);
diff -Nru a/include/asm-ia64/delay.h b/include/asm-ia64/delay.h
--- a/include/asm-ia64/delay.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/delay.h	Sat Aug 10 01:51:46 2002
@@ -53,7 +53,7 @@
=20
 	__asm__ __volatile__("mov %0=3Dar.itc" : "=3Dr"(result) :: "memory");
 #ifdef CONFIG_ITANIUM
-	while (unlikely ((__s32) result =3D -1)
+	while (unlikely((__s32) result =3D -1))
 		__asm__ __volatile__("mov %0=3Dar.itc" : "=3Dr"(result) :: "memory");
 #endif
 	return result;
diff -Nru a/include/asm-ia64/efi.h b/include/asm-ia64/efi.h
--- a/include/asm-ia64/efi.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/efi.h	Sat Aug 10 01:51:46 2002
@@ -190,6 +190,9 @@
 #define SAL_SYSTEM_TABLE_GUID    \
     EFI_GUID(  0xeb9d2d32, 0x2d88, 0x11d3, 0x9a, 0x16, 0x0, 0x90, 0x27, 0x=
3f, 0xc1, 0x4d )
=20
+#define HCDP_TABLE_GUID	\
+    EFI_GUID(  0xf951938d, 0x620b, 0x42ef, 0x82, 0x79, 0xa8, 0x4b, 0x79, 0=
x61, 0x78, 0x98 )
+
 typedef struct {
 	efi_guid_t guid;
 	u64 table;
@@ -225,6 +228,7 @@
 	void *smbios;			/* SM BIOS table */
 	void *sal_systab;		/* SAL system table */
 	void *boot_info;		/* boot info table */
+	void *hcdp;			/* HCDP table */
 	efi_get_time_t *get_time;
 	efi_set_time_t *set_time;
 	efi_get_wakeup_time_t *get_wakeup_time;
diff -Nru a/include/asm-ia64/elf.h b/include/asm-ia64/elf.h
--- a/include/asm-ia64/elf.h	Sat Aug 10 01:51:47 2002
+++ b/include/asm-ia64/elf.h	Sat Aug 10 01:51:47 2002
@@ -2,7 +2,7 @@
 #define _ASM_IA64_ELF_H
=20
 /*
- * ELF archtecture specific definitions.
+ * ELF-specific definitions.
  *
  * Copyright (C) 1998, 1999, 2002 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
diff -Nru a/include/asm-ia64/hardirq.h b/include/asm-ia64/hardirq.h
--- a/include/asm-ia64/hardirq.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/hardirq.h	Sat Aug 10 01:51:46 2002
@@ -17,89 +17,93 @@
  * No irq_cpustat_t for IA-64.  The data is held in the per-CPU data struc=
ture.
  */
 #define softirq_pending(cpu)		(cpu_data(cpu)->softirq_pending)
-#define ksoftirqd_task(cpu)		(cpu_data(cpu)->ksoftirqd)
-#define irq_count(cpu)			(cpu_data(cpu)->irq_stat.f.irq_count)
-#define bh_count(cpu)			(cpu_data(cpu)->irq_stat.f.bh_count)
 #define syscall_count(cpu)		/* unused on IA-64 */
+#define ksoftirqd_task(cpu)		(cpu_data(cpu)->ksoftirqd)
 #define nmi_count(cpu)			0
=20
 #define local_softirq_pending()		(local_cpu_data->softirq_pending)
-#define local_ksoftirqd_task()		(local_cpu_data->ksoftirqd)
-#define really_local_irq_count()	(local_cpu_data->irq_stat.f.irq_count)	/*=
 XXX fix me */
-#define really_local_bh_count()		(local_cpu_data->irq_stat.f.bh_count)	/* =
XXX fix me */
 #define local_syscall_count()		/* unused on IA-64 */
+#define local_ksoftirqd_task()		(local_cpu_data->ksoftirqd)
 #define local_nmi_count()		0
=20
 /*
- * Are we in an interrupt context? Either doing bottom half or hardware in=
terrupt
- * processing?
+ * We put the hardirq and softirq counter into the preemption counter. The=
 bitmask has the
+ * following meaning:
+ *
+ * - bits 0-7 are the preemption count (max preemption depth: 256)
+ * - bits 8-15 are the softirq count (max # of softirqs: 256)
+ * - bits 16-31 are the hardirq count (max # of hardirqs: 65536)
+ *
+ * - (bit 63 is the PREEMPT_ACTIVE flag---not currently implemented.)
+ *
+ * PREEMPT_MASK: 0x000000ff
+ * SOFTIRQ_MASK: 0x0000ff00
+ * HARDIRQ_MASK: 0xffff0000
  */
-#define in_interrupt()			(local_cpu_data->irq_stat.irq_and_bh_counts !=3D =
0)
-#define in_irq()			(local_cpu_data->irq_stat.f.irq_count !=3D 0)
=20
-#ifndef CONFIG_SMP
-# define local_hardirq_trylock()	(really_local_irq_count() =3D 0)
-# define local_hardirq_endlock()	do { } while (0)
+#define PREEMPT_BITS	8
+#define SOFTIRQ_BITS	8
+#define HARDIRQ_BITS	16
+
+#define PREEMPT_SHIFT	0
+#define SOFTIRQ_SHIFT	(PREEMPT_SHIFT + PREEMPT_BITS)
+#define HARDIRQ_SHIFT	(SOFTIRQ_SHIFT + SOFTIRQ_BITS)
+
+#define __MASK(x)	((1UL << (x))-1)
+
+#define PREEMPT_MASK	(__MASK(PREEMPT_BITS) << PREEMPT_SHIFT)
+#define HARDIRQ_MASK	(__MASK(HARDIRQ_BITS) << HARDIRQ_SHIFT)
+#define SOFTIRQ_MASK	(__MASK(SOFTIRQ_BITS) << SOFTIRQ_SHIFT)
+
+#define hardirq_count()	(preempt_count() & HARDIRQ_MASK)
+#define softirq_count()	(preempt_count() & SOFTIRQ_MASK)
+#define irq_count()	(preempt_count() & (HARDIRQ_MASK | SOFTIRQ_MASK))
+
+#define PREEMPT_OFFSET	(1UL << PREEMPT_SHIFT)
+#define SOFTIRQ_OFFSET	(1UL << SOFTIRQ_SHIFT)
+#define HARDIRQ_OFFSET	(1UL << HARDIRQ_SHIFT)
=20
-# define local_irq_enter(irq)		(really_local_irq_count()++)
-# define local_irq_exit(irq)		(really_local_irq_count()--)
+/*
+ * The hardirq mask has to be large enough to have space for potentially a=
ll IRQ sources
+ * in the system nesting on a single CPU:
+ */
+#if (1 << HARDIRQ_BITS) < NR_IRQS
+# error HARDIRQ_BITS is too low!
+#endif
=20
-# define synchronize_irq()		barrier()
+/*
+ * Are we doing bottom half or hardware interrupt processing?
+ * Are we in a softirq context?
+ * Interrupt context?
+ */
+#define in_irq()		(hardirq_count())
+#define in_softirq()		(softirq_count())
+#define in_interrupt()		(irq_count())
+
+#define hardirq_trylock()	(!in_interrupt())
+#define hardirq_endlock()	do { } while (0)
+
+#define irq_enter()		(preempt_count() +=3D HARDIRQ_OFFSET)
+
+#if CONFIG_PREEMPT
+# error CONFIG_PREEMT currently not supported.
+# define IRQ_EXIT_OFFSET (HARDIRQ_OFFSET-1)
 #else
+# define IRQ_EXIT_OFFSET HARDIRQ_OFFSET
+#endif
=20
-#include <asm/atomic.h>
-#include <asm/smp.h>
-
-extern unsigned int global_irq_holder;
-extern volatile unsigned long global_irq_lock;
-
-static inline int
-irqs_running (void)
-{
-	int i;
-
-	for (i =3D 0; i < NR_CPUS; i++)
-		if (irq_count(i))
-			return 1;
-	return 0;
-}
-
-static inline void
-release_irqlock (int cpu)
-{
-	/* if we didn't own the irq lock, just ignore.. */
-	if (global_irq_holder =3D cpu) {
-		global_irq_holder =3D NO_PROC_ID;
-		smp_mb__before_clear_bit();	/* need barrier before releasing lock... */
-		clear_bit(0,&global_irq_lock);
-        }
-}
-
-static inline void
-local_irq_enter (int irq)
-{
-	really_local_irq_count()++;
-
-	while (test_bit(0,&global_irq_lock)) {
-		/* nothing */;
-	}
-}
-
-static inline void
-local_irq_exit (int irq)
-{
-	really_local_irq_count()--;
-}
-
-static inline int
-local_hardirq_trylock (void)
-{
-	return !really_local_irq_count() && !test_bit(0,&global_irq_lock);
-}
-
-#define local_hardirq_endlock()		do { } while (0)
-
-extern void synchronize_irq (void);
+#define irq_exit()								\
+do {										\
+		preempt_count() -=3D IRQ_EXIT_OFFSET;				\
+		if (!in_interrupt() && softirq_pending(smp_processor_id()))	\
+			do_softirq();						\
+		preempt_enable_no_resched();					\
+} while (0)
=20
+#ifdef CONFIG_SMP
+  extern void synchronize_irq (unsigned int irq);
+#else
+# define synchronize_irq(irq)	barrier()
 #endif /* CONFIG_SMP */
+
 #endif /* _ASM_IA64_HARDIRQ_H */
diff -Nru a/include/asm-ia64/hw_irq.h b/include/asm-ia64/hw_irq.h
--- a/include/asm-ia64/hw_irq.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/hw_irq.h	Sat Aug 10 01:51:46 2002
@@ -2,10 +2,11 @@
 #define _ASM_IA64_HW_IRQ_H
=20
 /*
- * Copyright (C) 2001 Hewlett-Packard Co
- * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 2001-2002 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
+#include <linux/interrupt.h>
 #include <linux/sched.h>
 #include <linux/types.h>
=20
@@ -67,6 +68,8 @@
=20
 extern __u8 isa_irq_to_vector_map[16];
 #define isa_irq_to_vector(x)	isa_irq_to_vector_map[(x)]
+extern __u8 gsi_to_vector_map[255];
+#define gsi_to_vector(x)	gsi_to_vector_map[(x)]
=20
 extern unsigned long ipi_base_addr;
=20
diff -Nru a/include/asm-ia64/keyboard.h b/include/asm-ia64/keyboard.h
--- a/include/asm-ia64/keyboard.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/keyboard.h	Sat Aug 10 01:51:46 2002
@@ -16,6 +16,7 @@
 #define KEYBOARD_IRQ			isa_irq_to_vector(1)
 #define DISABLE_KBD_DURING_INTERRUPTS	0
=20
+extern unsigned char acpi_kbd_controller_present;
 extern int pckbd_setkeycode(unsigned int scancode, unsigned int keycode);
 extern int pckbd_getkeycode(unsigned int scancode);
 extern int pckbd_pretranslate(unsigned char scancode, char raw_mode);
@@ -26,6 +27,7 @@
 extern void pckbd_init_hw(void);
 extern unsigned char pckbd_sysrq_xlate[128];
=20
+#define kbd_controller_present() acpi_kbd_controller_present
 #define kbd_setkeycode		pckbd_setkeycode
 #define kbd_getkeycode		pckbd_getkeycode
 #define kbd_pretranslate	pckbd_pretranslate
diff -Nru a/include/asm-ia64/kregs.h b/include/asm-ia64/kregs.h
--- a/include/asm-ia64/kregs.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/kregs.h	Sat Aug 10 01:51:46 2002
@@ -64,6 +64,15 @@
 #define IA64_PSR_RI_BIT		41
 #define IA64_PSR_ED_BIT		43
 #define IA64_PSR_BN_BIT		44
+#define IA64_PSR_IA_BIT		45
+
+/* A mask of PSR bits that we generally don't want to inherit across a clo=
ne2() or an
+   execve().  Only list flags here that need to be cleared/set for BOTH cl=
one2() and
+   execve().  */
+#define IA64_PSR_BITS_TO_CLEAR	(IA64_PSR_MFL | IA64_PSR_MFH | IA64_PSR_DB =
| IA64_PSR_LP | \
+				 IA64_PSR_TB  | IA64_PSR_ID  | IA64_PSR_DA | IA64_PSR_DD | \
+				 IA64_PSR_SS  | IA64_PSR_ED  | IA64_PSR_IA)
+#define IA64_PSR_BITS_TO_SET	(IA64_PSR_DFH)
=20
 #define IA64_PSR_BE	(__IA64_UL(1) << IA64_PSR_BE_BIT)
 #define IA64_PSR_UP	(__IA64_UL(1) << IA64_PSR_UP_BIT)
@@ -85,6 +94,7 @@
 #define IA64_PSR_TB	(__IA64_UL(1) << IA64_PSR_TB_BIT)
 #define IA64_PSR_RT	(__IA64_UL(1) << IA64_PSR_RT_BIT)
 /* The following are not affected by save_flags()/restore_flags(): */
+#define IA64_PSR_CPL	(__IA64_UL(3) << IA64_PSR_CPL0_BIT)
 #define IA64_PSR_IS	(__IA64_UL(1) << IA64_PSR_IS_BIT)
 #define IA64_PSR_MC	(__IA64_UL(1) << IA64_PSR_MC_BIT)
 #define IA64_PSR_IT	(__IA64_UL(1) << IA64_PSR_IT_BIT)
@@ -95,6 +105,7 @@
 #define IA64_PSR_RI	(__IA64_UL(3) << IA64_PSR_RI_BIT)
 #define IA64_PSR_ED	(__IA64_UL(1) << IA64_PSR_ED_BIT)
 #define IA64_PSR_BN	(__IA64_UL(1) << IA64_PSR_BN_BIT)
+#define IA64_PSR_IA	(__IA64_UL(1) << IA64_PSR_IA_BIT)
=20
 /* User mask bits: */
 #define IA64_PSR_UM	(IA64_PSR_BE | IA64_PSR_UP | IA64_PSR_AC | IA64_PSR_MF=
L | IA64_PSR_MFH)
diff -Nru a/include/asm-ia64/machvec.h b/include/asm-ia64/machvec.h
--- a/include/asm-ia64/machvec.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/machvec.h	Sat Aug 10 01:51:46 2002
@@ -210,6 +210,7 @@
 extern ia64_mv_pci_dma_sync_single swiotlb_sync_single;
 extern ia64_mv_pci_dma_sync_sg swiotlb_sync_sg;
 extern ia64_mv_pci_dma_address swiotlb_dma_address;
+extern ia64_mv_pci_dma_supported swiotlb_pci_dma_supported;
=20
 /*
  * Define default versions so we can extend machvec for new platforms with=
out having
diff -Nru a/include/asm-ia64/machvec_init.h b/include/asm-ia64/machvec_init=
.h
--- a/include/asm-ia64/machvec_init.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/machvec_init.h	Sat Aug 10 01:51:46 2002
@@ -16,6 +16,7 @@
 extern ia64_mv_outb_t __ia64_outb;
 extern ia64_mv_outw_t __ia64_outw;
 extern ia64_mv_outl_t __ia64_outl;
+extern ia64_mv_mmiob_t __ia64_mmiob;
=20
 #define MACHVEC_HELPER(name)									\
  struct ia64_machine_vector machvec_##name __attribute__ ((unused, __secti=
on__ (".machvec")))	\
diff -Nru a/include/asm-ia64/mmu_context.h b/include/asm-ia64/mmu_context.h
--- a/include/asm-ia64/mmu_context.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/mmu_context.h	Sat Aug 10 01:51:46 2002
@@ -2,8 +2,8 @@
 #define _ASM_IA64_MMU_CONTEXT_H
=20
 /*
- * Copyright (C) 1998-2001 Hewlett-Packard Co
- * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2002 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 /*
@@ -13,8 +13,6 @@
  * consider the region number when performing a TLB lookup, we need to ass=
ign a unique
  * region id to each region in a process.  We use the least significant th=
ree bits in a
  * region id for this purpose.
- *
- * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #define IA64_REGION_ID_KERNEL	0 /* the kernel's region id (tlb.c depends o=
n this being 0) */
@@ -23,6 +21,8 @@
=20
 # ifndef __ASSEMBLY__
=20
+#include <linux/compiler.h>
+#include <linux/percpu.h>
 #include <linux/sched.h>
 #include <linux/spinlock.h>
=20
@@ -36,6 +36,7 @@
 };
=20
 extern struct ia64_ctx ia64_ctx;
+extern u8 ia64_need_tlb_flush __per_cpu_data;
=20
 extern void wrap_mmu_context (struct mm_struct *mm);
=20
@@ -44,6 +45,23 @@
 {
 }
=20
+/*
+ * When the context counter wraps around all TLBs need to be flushed becau=
se an old
+ * context number might have been reused. This is signalled by the ia64_ne=
ed_tlb_flush
+ * per-CPU variable, which is checked in the routine below. Called by acti=
vate_mm().
+ * <efocht@ess.nec.de>
+ */
+static inline void
+delayed_tlb_flush (void)
+{
+	extern void __flush_tlb_all (void);
+
+	if (unlikely(ia64_need_tlb_flush)) {
+		__flush_tlb_all();
+		ia64_need_tlb_flush =3D 0;
+	}
+}
+
 static inline void
 get_new_mmu_context (struct mm_struct *mm)
 {
@@ -54,7 +72,6 @@
 		mm->context =3D ia64_ctx.next++;
 	}
 	spin_unlock(&ia64_ctx.lock);
-
 }
=20
 static inline void
@@ -109,6 +126,8 @@
 static inline void
 activate_mm (struct mm_struct *prev, struct mm_struct *next)
 {
+	delayed_tlb_flush();
+
 	/*
 	 * We may get interrupts here, but that's OK because interrupt
 	 * handlers cannot touch user-space.
diff -Nru a/include/asm-ia64/module.h b/include/asm-ia64/module.h
--- a/include/asm-ia64/module.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/module.h	Sat Aug 10 01:51:46 2002
@@ -75,7 +75,7 @@
 		return 1;
 	}
 	if (!mod_bound(archdata->segment_base, 0, mod)) {
-		printk(KERN_ERR "module_arch_init: archdata->unw_table out of bounds.\n"=
);
+		printk(KERN_ERR "module_arch_init: archdata->segment_base out of bounds.=
\n");
 		return 1;
 	}
=20
diff -Nru a/include/asm-ia64/offsets.h b/include/asm-ia64/offsets.h
--- a/include/asm-ia64/offsets.h	Sat Aug 10 01:51:46 2002
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,130 +0,0 @@
-#ifndef _ASM_IA64_OFFSETS_H
-#define _ASM_IA64_OFFSETS_H
-/*
- * DO NOT MODIFY
- *
- * This file was generated by arch/ia64/tools/print_offsets.awk.
- *
- */
-#define IA64_TASK_SIZE			3952	/* 0xf70 */
-#define IA64_THREAD_INFO_SIZE		32	/* 0x20 */
-#define IA64_PT_REGS_SIZE		400	/* 0x190 */
-#define IA64_SWITCH_STACK_SIZE		560	/* 0x230 */
-#define IA64_SIGINFO_SIZE		128	/* 0x80 */
-#define IA64_CPU_SIZE			224	/* 0xe0 */
-#define SIGFRAME_SIZE			2816	/* 0xb00 */
-#define UNW_FRAME_INFO_SIZE		448	/* 0x1c0 */
-
-#define IA64_TASK_THREAD_KSP_OFFSET	1496	/* 0x5d8 */
-#define IA64_PT_REGS_CR_IPSR_OFFSET	0	/* 0x0 */
-#define IA64_PT_REGS_CR_IIP_OFFSET	8	/* 0x8 */
-#define IA64_PT_REGS_CR_IFS_OFFSET	16	/* 0x10 */
-#define IA64_PT_REGS_AR_UNAT_OFFSET	24	/* 0x18 */
-#define IA64_PT_REGS_AR_PFS_OFFSET	32	/* 0x20 */
-#define IA64_PT_REGS_AR_RSC_OFFSET	40	/* 0x28 */
-#define IA64_PT_REGS_AR_RNAT_OFFSET	48	/* 0x30 */
-#define IA64_PT_REGS_AR_BSPSTORE_OFFSET	56	/* 0x38 */
-#define IA64_PT_REGS_PR_OFFSET		64	/* 0x40 */
-#define IA64_PT_REGS_B6_OFFSET		72	/* 0x48 */
-#define IA64_PT_REGS_LOADRS_OFFSET	80	/* 0x50 */
-#define IA64_PT_REGS_R1_OFFSET		88	/* 0x58 */
-#define IA64_PT_REGS_R2_OFFSET		96	/* 0x60 */
-#define IA64_PT_REGS_R3_OFFSET		104	/* 0x68 */
-#define IA64_PT_REGS_R12_OFFSET		112	/* 0x70 */
-#define IA64_PT_REGS_R13_OFFSET		120	/* 0x78 */
-#define IA64_PT_REGS_R14_OFFSET		128	/* 0x80 */
-#define IA64_PT_REGS_R15_OFFSET		136	/* 0x88 */
-#define IA64_PT_REGS_R8_OFFSET		144	/* 0x90 */
-#define IA64_PT_REGS_R9_OFFSET		152	/* 0x98 */
-#define IA64_PT_REGS_R10_OFFSET		160	/* 0xa0 */
-#define IA64_PT_REGS_R11_OFFSET		168	/* 0xa8 */
-#define IA64_PT_REGS_R16_OFFSET		176	/* 0xb0 */
-#define IA64_PT_REGS_R17_OFFSET		184	/* 0xb8 */
-#define IA64_PT_REGS_R18_OFFSET		192	/* 0xc0 */
-#define IA64_PT_REGS_R19_OFFSET		200	/* 0xc8 */
-#define IA64_PT_REGS_R20_OFFSET		208	/* 0xd0 */
-#define IA64_PT_REGS_R21_OFFSET		216	/* 0xd8 */
-#define IA64_PT_REGS_R22_OFFSET		224	/* 0xe0 */
-#define IA64_PT_REGS_R23_OFFSET		232	/* 0xe8 */
-#define IA64_PT_REGS_R24_OFFSET		240	/* 0xf0 */
-#define IA64_PT_REGS_R25_OFFSET		248	/* 0xf8 */
-#define IA64_PT_REGS_R26_OFFSET		256	/* 0x100 */
-#define IA64_PT_REGS_R27_OFFSET		264	/* 0x108 */
-#define IA64_PT_REGS_R28_OFFSET		272	/* 0x110 */
-#define IA64_PT_REGS_R29_OFFSET		280	/* 0x118 */
-#define IA64_PT_REGS_R30_OFFSET		288	/* 0x120 */
-#define IA64_PT_REGS_R31_OFFSET		296	/* 0x128 */
-#define IA64_PT_REGS_AR_CCV_OFFSET	304	/* 0x130 */
-#define IA64_PT_REGS_AR_FPSR_OFFSET	312	/* 0x138 */
-#define IA64_PT_REGS_B0_OFFSET		320	/* 0x140 */
-#define IA64_PT_REGS_B7_OFFSET		328	/* 0x148 */
-#define IA64_PT_REGS_F6_OFFSET		336	/* 0x150 */
-#define IA64_PT_REGS_F7_OFFSET		352	/* 0x160 */
-#define IA64_PT_REGS_F8_OFFSET		368	/* 0x170 */
-#define IA64_PT_REGS_F9_OFFSET		384	/* 0x180 */
-#define IA64_SWITCH_STACK_CALLER_UNAT_OFFSET 0	/* 0x0 */
-#define IA64_SWITCH_STACK_AR_FPSR_OFFSET 8	/* 0x8 */
-#define IA64_SWITCH_STACK_F2_OFFSET	16	/* 0x10 */
-#define IA64_SWITCH_STACK_F3_OFFSET	32	/* 0x20 */
-#define IA64_SWITCH_STACK_F4_OFFSET	48	/* 0x30 */
-#define IA64_SWITCH_STACK_F5_OFFSET	64	/* 0x40 */
-#define IA64_SWITCH_STACK_F10_OFFSET	80	/* 0x50 */
-#define IA64_SWITCH_STACK_F11_OFFSET	96	/* 0x60 */
-#define IA64_SWITCH_STACK_F12_OFFSET	112	/* 0x70 */
-#define IA64_SWITCH_STACK_F13_OFFSET	128	/* 0x80 */
-#define IA64_SWITCH_STACK_F14_OFFSET	144	/* 0x90 */
-#define IA64_SWITCH_STACK_F15_OFFSET	160	/* 0xa0 */
-#define IA64_SWITCH_STACK_F16_OFFSET	176	/* 0xb0 */
-#define IA64_SWITCH_STACK_F17_OFFSET	192	/* 0xc0 */
-#define IA64_SWITCH_STACK_F18_OFFSET	208	/* 0xd0 */
-#define IA64_SWITCH_STACK_F19_OFFSET	224	/* 0xe0 */
-#define IA64_SWITCH_STACK_F20_OFFSET	240	/* 0xf0 */
-#define IA64_SWITCH_STACK_F21_OFFSET	256	/* 0x100 */
-#define IA64_SWITCH_STACK_F22_OFFSET	272	/* 0x110 */
-#define IA64_SWITCH_STACK_F23_OFFSET	288	/* 0x120 */
-#define IA64_SWITCH_STACK_F24_OFFSET	304	/* 0x130 */
-#define IA64_SWITCH_STACK_F25_OFFSET	320	/* 0x140 */
-#define IA64_SWITCH_STACK_F26_OFFSET	336	/* 0x150 */
-#define IA64_SWITCH_STACK_F27_OFFSET	352	/* 0x160 */
-#define IA64_SWITCH_STACK_F28_OFFSET	368	/* 0x170 */
-#define IA64_SWITCH_STACK_F29_OFFSET	384	/* 0x180 */
-#define IA64_SWITCH_STACK_F30_OFFSET	400	/* 0x190 */
-#define IA64_SWITCH_STACK_F31_OFFSET	416	/* 0x1a0 */
-#define IA64_SWITCH_STACK_R4_OFFSET	432	/* 0x1b0 */
-#define IA64_SWITCH_STACK_R5_OFFSET	440	/* 0x1b8 */
-#define IA64_SWITCH_STACK_R6_OFFSET	448	/* 0x1c0 */
-#define IA64_SWITCH_STACK_R7_OFFSET	456	/* 0x1c8 */
-#define IA64_SWITCH_STACK_B0_OFFSET	464	/* 0x1d0 */
-#define IA64_SWITCH_STACK_B1_OFFSET	472	/* 0x1d8 */
-#define IA64_SWITCH_STACK_B2_OFFSET	480	/* 0x1e0 */
-#define IA64_SWITCH_STACK_B3_OFFSET	488	/* 0x1e8 */
-#define IA64_SWITCH_STACK_B4_OFFSET	496	/* 0x1f0 */
-#define IA64_SWITCH_STACK_B5_OFFSET	504	/* 0x1f8 */
-#define IA64_SWITCH_STACK_AR_PFS_OFFSET	512	/* 0x200 */
-#define IA64_SWITCH_STACK_AR_LC_OFFSET	520	/* 0x208 */
-#define IA64_SWITCH_STACK_AR_UNAT_OFFSET 528	/* 0x210 */
-#define IA64_SWITCH_STACK_AR_RNAT_OFFSET 536	/* 0x218 */
-#define IA64_SWITCH_STACK_AR_BSPSTORE_OFFSET 544	/* 0x220 */
-#define IA64_SWITCH_STACK_PR_OFFSET	552	/* 0x228 */
-#define IA64_SIGCONTEXT_IP_OFFSET	40	/* 0x28 */
-#define IA64_SIGCONTEXT_AR_BSP_OFFSET	72	/* 0x48 */
-#define IA64_SIGCONTEXT_AR_FPSR_OFFSET	104	/* 0x68 */
-#define IA64_SIGCONTEXT_AR_RNAT_OFFSET	80	/* 0x50 */
-#define IA64_SIGCONTEXT_AR_UNAT_OFFSET	96	/* 0x60 */
-#define IA64_SIGCONTEXT_B0_OFFSET	136	/* 0x88 */
-#define IA64_SIGCONTEXT_CFM_OFFSET	48	/* 0x30 */
-#define IA64_SIGCONTEXT_FLAGS_OFFSET	0	/* 0x0 */
-#define IA64_SIGCONTEXT_FR6_OFFSET	560	/* 0x230 */
-#define IA64_SIGCONTEXT_PR_OFFSET	128	/* 0x80 */
-#define IA64_SIGCONTEXT_R12_OFFSET	296	/* 0x128 */
-#define IA64_SIGCONTEXT_RBS_BASE_OFFSET	2512	/* 0x9d0 */
-#define IA64_SIGCONTEXT_LOADRS_OFFSET	2520	/* 0x9d8 */
-#define IA64_SIGFRAME_ARG0_OFFSET	0	/* 0x0 */
-#define IA64_SIGFRAME_ARG1_OFFSET	8	/* 0x8 */
-#define IA64_SIGFRAME_ARG2_OFFSET	16	/* 0x10 */
-#define IA64_SIGFRAME_HANDLER_OFFSET	24	/* 0x18 */
-#define IA64_SIGFRAME_SIGCONTEXT_OFFSET	160	/* 0xa0 */
-#define IA64_CLONE_VFORK		16384	/* 0x4000 */
-#define IA64_CLONE_VM			256	/* 0x100 */
-
-#endif /* _ASM_IA64_OFFSETS_H */
diff -Nru a/include/asm-ia64/page.h b/include/asm-ia64/page.h
--- a/include/asm-ia64/page.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/page.h	Sat Aug 10 01:51:46 2002
@@ -87,7 +87,12 @@
 #define REGION_SIZE		REGION_NUMBER(1)
 #define REGION_KERNEL		7
=20
-#define BUG() do { printk("kernel BUG at %s:%d!\n", __FILE__, __LINE__); *=
(int *)0=3D0; } while (0)
+#if (__GNUC__ > 3) || (__GNUC__ =3D 3 && __GNUC_MINOR__ >=3D 1)
+# define ia64_abort()	__builtin_trap()
+#else
+# define ia64_abort()	(*(volatile int *) 0 =3D 0)
+#endif
+#define BUG() do { printk("kernel BUG at %s:%d!\n", __FILE__, __LINE__); i=
a64_abort(); } while (0)
 #define PAGE_BUG(page) do { BUG(); } while (0)
=20
 static __inline__ int
diff -Nru a/include/asm-ia64/param.h b/include/asm-ia64/param.h
--- a/include/asm-ia64/param.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/param.h	Sat Aug 10 01:51:46 2002
@@ -4,8 +4,8 @@
 /*
  * Fundamental kernel parameters.
  *
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998, 1999, 2002 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #include <linux/config.h>
@@ -33,6 +33,7 @@
 #define MAXHOSTNAMELEN	64	/* max length of hostname */
=20
 #ifdef __KERNEL__
+# define USER_HZ	HZ
 # define CLOCKS_PER_SEC	HZ	/* frequency at which times() counts */
 #endif
=20
diff -Nru a/include/asm-ia64/pci.h b/include/asm-ia64/pci.h
--- a/include/asm-ia64/pci.h	Sat Aug 10 01:51:47 2002
+++ b/include/asm-ia64/pci.h	Sat Aug 10 01:51:47 2002
@@ -21,7 +21,7 @@
 #define PCIBIOS_MIN_MEM		0x10000000
=20
 void pcibios_config_init(void);
-struct pci_bus * pcibios_scan_root(int seg, int bus);
+struct pci_bus * pcibios_scan_root(int bus);
 extern int (*pci_config_read)(int seg, int bus, int dev, int fn, int reg, =
int len, u32 *value);
 extern int (*pci_config_write)(int seg, int bus, int dev, int fn, int reg,=
 int len, u32 value);
=20
@@ -90,7 +90,7 @@
 /* Return the index of the PCI controller for device PDEV. */
 #define pci_controller_num(PDEV)	(0)
=20
-#define sg_dma_len(sg)		((sg)->length)
+#define sg_dma_len(sg)		((sg)->dma_length)
=20
 #define HAVE_PCI_MMAP
 extern int pci_mmap_page_range (struct pci_dev *dev, struct vm_area_struct=
 *vma,
diff -Nru a/include/asm-ia64/perfmon.h b/include/asm-ia64/perfmon.h
--- a/include/asm-ia64/perfmon.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/perfmon.h	Sat Aug 10 01:51:46 2002
@@ -172,9 +172,8 @@
 extern int  pfm_release_debug_registers(struct task_struct *);
 extern int  pfm_cleanup_smpl_buf(struct task_struct *);
 extern void pfm_syst_wide_update_task(struct task_struct *, int);
-extern void pfm_ovfl_block_reset (void);
-
-extern int pfm_syst_wide;
+extern void pfm_ovfl_block_reset(void);
+extern void perfmon_init_percpu(void);
=20
 #endif /* __KERNEL__ */
=20
diff -Nru a/include/asm-ia64/pgalloc.h b/include/asm-ia64/pgalloc.h
--- a/include/asm-ia64/pgalloc.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/pgalloc.h	Sat Aug 10 01:51:46 2002
@@ -15,9 +15,10 @@
=20
 #include <linux/config.h>
=20
+#include <linux/compiler.h>
 #include <linux/mm.h>
+#include <linux/page-flags.h>
 #include <linux/threads.h>
-#include <linux/compiler.h>
=20
 #include <asm/mmu_context.h>
 #include <asm/processor.h>
diff -Nru a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
--- a/include/asm-ia64/processor.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/processor.h	Sat Aug 10 01:51:46 2002
@@ -270,12 +270,8 @@
=20
 #define start_thread(regs,new_ip,new_sp) do {							\
 	set_fs(USER_DS);									\
-	ia64_psr(regs)->dfh =3D 1;	/* disable fph */					\
-	ia64_psr(regs)->mfh =3D 0;	/* clear mfh */						\
-	ia64_psr(regs)->cpl =3D 3;	/* set user mode */					\
-	ia64_psr(regs)->ri =3D 0;		/* clear return slot number */				\
-	ia64_psr(regs)->is =3D 0;		/* IA-64 instruction set */				\
-	ia64_psr(regs)->sp =3D 1;		/* enforce secure perfmon */				\
+	regs->cr_ipsr =3D ((regs->cr_ipsr | (IA64_PSR_BITS_TO_SET | IA64_PSR_CPL =
| IA64_PSR_SP))	\
+			 & ~(IA64_PSR_BITS_TO_CLEAR | IA64_PSR_RI | IA64_PSR_IS));		\
 	regs->cr_iip =3D new_ip;									\
 	regs->ar_rsc =3D 0xf;		/* eager mode, privilege level 3 */			\
 	regs->ar_rnat =3D 0;									\
@@ -284,7 +280,7 @@
 	regs->loadrs =3D 0;									\
 	regs->r8 =3D current->mm->dumpable;	/* set "don't zap registers" flag */	=
	\
 	regs->r12 =3D new_sp - 16;	/* allocate 16 byte scratch area */			\
-	if (!likely (current->mm->dumpable)) {					\
+	if (unlikely(!current->mm->dumpable)) {					\
 		/*										\
 		 * Zap scratch regs to avoid leaking bits between processes with differe=
nt	\
 		 * uid/privileges.								\
diff -Nru a/include/asm-ia64/rmap.h b/include/asm-ia64/rmap.h
--- a/include/asm-ia64/rmap.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/rmap.h	Sat Aug 10 01:51:46 2002
@@ -1,7 +1,7 @@
-#ifndef _IA64_RMAP_H
-#define _IA64_RMAP_H
+#ifndef _ASM_IA64_RMAP_H
+#define _ASM_IA64_RMAP_H
=20
 /* nothing to see, move along */
 #include <asm-generic/rmap.h>
=20
-#endif
+#endif /* _ASM_IA64_RMAP_H */
diff -Nru a/include/asm-ia64/scatterlist.h b/include/asm-ia64/scatterlist.h
--- a/include/asm-ia64/scatterlist.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/scatterlist.h	Sat Aug 10 01:51:46 2002
@@ -7,12 +7,12 @@
  */
=20
 struct scatterlist {
-	char *orig_address;	/* for use by swiotlb */
-
-	/* These two are only valid if ADDRESS member of this struct is NULL.  */
 	struct page *page;
 	unsigned int offset;
 	unsigned int length;	/* buffer length */
+
+	dma_addr_t dma_address;
+	unsigned int dma_length;
 };
=20
 #define ISA_DMA_THRESHOLD	(~0UL)
diff -Nru a/include/asm-ia64/serial.h b/include/asm-ia64/serial.h
--- a/include/asm-ia64/serial.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/serial.h	Sat Aug 10 01:51:46 2002
@@ -1,6 +1,6 @@
 /*
  * include/asm-ia64/serial.h
- *=20
+ *
  * Derived from the i386 version.
  */
=20
@@ -35,7 +35,7 @@
 #else
 #define RS_TABLE_SIZE
 #endif
-=09
+
 /*
  * The following define the access methods for the HUB6 card. All
  * access is through two ports for all 24 possible chips. The card is
@@ -115,21 +115,8 @@
 #define HUB6_SERIAL_PORT_DFNS
 #endif
=20
-#ifdef CONFIG_MCA
-#define MCA_SERIAL_PORT_DFNS			\
-	{ 0, BASE_BAUD, 0x3220, 3, STD_COM_FLAGS },	\
-	{ 0, BASE_BAUD, 0x3228, 3, STD_COM_FLAGS },	\
-	{ 0, BASE_BAUD, 0x4220, 3, STD_COM_FLAGS },	\
-	{ 0, BASE_BAUD, 0x4228, 3, STD_COM_FLAGS },	\
-	{ 0, BASE_BAUD, 0x5220, 3, STD_COM_FLAGS },	\
-	{ 0, BASE_BAUD, 0x5228, 3, STD_COM_FLAGS },
-#else
-#define MCA_SERIAL_PORT_DFNS
-#endif
-
 #define SERIAL_PORT_DFNS		\
 	STD_SERIAL_PORT_DEFNS		\
 	EXTRA_SERIAL_PORT_DEFNS		\
-	HUB6_SERIAL_PORT_DFNS		\
-	MCA_SERIAL_PORT_DFNS
+	HUB6_SERIAL_PORT_DFNS
=20
diff -Nru a/include/asm-ia64/smp.h b/include/asm-ia64/smp.h
--- a/include/asm-ia64/smp.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/smp.h	Sat Aug 10 01:51:46 2002
@@ -17,6 +17,7 @@
 #include <linux/threads.h>
 #include <linux/kernel.h>
=20
+#include <asm/bitops.h>
 #include <asm/io.h>
 #include <asm/param.h>
 #include <asm/processor.h>
@@ -36,6 +37,7 @@
=20
 extern char no_int_routing __initdata;
=20
+extern unsigned long phys_cpu_present_map;
 extern volatile unsigned long cpu_online_map;
 extern unsigned long ipi_base_addr;
 extern unsigned char smp_int_redirect;
@@ -45,23 +47,26 @@
=20
 extern unsigned long ap_wakeup_vector;
=20
-#define cpu_online(cpu) (cpu_online_map & (1<<(cpu)))
-extern inline unsigned int num_online_cpus(void)
+#define cpu_possible(cpu)	(phys_cpu_present_map & (1UL << (cpu)))
+#define cpu_online(cpu)		(cpu_online_map & (1UL << (cpu)))
+
+static inline unsigned int
+num_online_cpus (void)
 {
 	return hweight64(cpu_online_map);
 }
=20
-extern inline int any_online_cpu(unsigned int mask)
+static inline int
+any_online_cpu (unsigned int mask)
 {
 	if (mask & cpu_online_map)
 		return __ffs(mask & cpu_online_map);
-
 	return -1;
 }
=20
 /*
- * Function to map hard smp processor id to logical id.  Slow, so
- * don't use this in performance-critical code.
+ * Function to map hard smp processor id to logical id.  Slow, so don't us=
e this in
+ * performance-critical code.
  */
 static inline int
 cpu_logical_id (int cpuid)
@@ -120,11 +125,9 @@
 }
=20
 /* Upping and downing of CPUs */
-extern int __cpu_disable(void);
-extern void __cpu_die(unsigned int cpu);
-extern int __cpu_up(unsigned int cpu);
-
-#define NO_PROC_ID		0xffffffff	/* no processor magic marker */
+extern int __cpu_disable (void);
+extern void __cpu_die (unsigned int cpu);
+extern int __cpu_up (unsigned int cpu);
=20
 extern void __init init_smp_config (void);
 extern void smp_do_timer (struct pt_regs *regs);
diff -Nru a/include/asm-ia64/smplock.h b/include/asm-ia64/smplock.h
--- a/include/asm-ia64/smplock.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/smplock.h	Sat Aug 10 01:51:46 2002
@@ -14,11 +14,6 @@
=20
 #ifdef CONFIG_SMP
 # define kernel_locked()	spin_is_locked(&kernel_flag)
-# define check_irq_holder(cpu)			\
-do {						\
-	if (global_irq_holder =3D (cpu))		\
-		BUG();				\
-} while (0)
 #else
 # define kernel_locked()	(1)
 #endif
@@ -26,12 +21,10 @@
 /*
  * Release global kernel lock and global interrupt lock
  */
-#define release_kernel_lock(task, cpu)		\
+#define release_kernel_lock(task)		\
 do {						\
-	if (unlikely(task->lock_depth >=3D 0)) {	\
+	if (unlikely(task->lock_depth >=3D 0))	\
 		spin_unlock(&kernel_flag);	\
-		check_irq_holder(cpu);		\
-	}					\
 } while (0)
=20
 /*
diff -Nru a/include/asm-ia64/softirq.h b/include/asm-ia64/softirq.h
--- a/include/asm-ia64/softirq.h	Sat Aug 10 01:51:47 2002
+++ b/include/asm-ia64/softirq.h	Sat Aug 10 01:51:47 2002
@@ -4,22 +4,23 @@
 #include <linux/compiler.h>
=20
 /*
- * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2002 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
+#include <linux/compiler.h>
+#include <linux/preempt.h>
+
 #include <asm/hardirq.h>
=20
-#define __local_bh_enable()	do { barrier(); really_local_bh_count()--; } w=
hile (0)
+#define __local_bh_enable()	do { barrier(); preempt_count() -=3D SOFTIRQ_O=
FFSET; } while (0)
=20
-#define local_bh_disable()	do { really_local_bh_count()++; barrier(); } wh=
ile (0)
-#define local_bh_enable()								\
-do {											\
-	__local_bh_enable();								\
-	if (unlikely(local_softirq_pending()) && really_local_bh_count() =3D 0)	\
-		do_softirq();								\
+#define local_bh_disable()	do { preempt_count() +=3D SOFTIRQ_OFFSET; barri=
er(); } while (0)
+#define local_bh_enable()						\
+do {									\
+	__local_bh_enable();						\
+	if (unlikely(!in_interrupt() && local_softirq_pending()))	\
+		do_softirq();						\
+	preempt_check_resched();					\
 } while (0)
-
-
-#define in_softirq()		(really_local_bh_count() !=3D 0)
=20
 #endif /* _ASM_IA64_SOFTIRQ_H */
diff -Nru a/include/asm-ia64/system.h b/include/asm-ia64/system.h
--- a/include/asm-ia64/system.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/system.h	Sat Aug 10 01:51:46 2002
@@ -13,9 +13,11 @@
  * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
  */
 #include <linux/config.h>
+#include <linux/percpu.h>
=20
 #include <asm/kregs.h>
 #include <asm/page.h>
+#include <asm/pal.h>
=20
 #define KERNEL_START		(PAGE_OFFSET + 68*1024*1024)
=20
@@ -102,6 +104,8 @@
 #define set_mb(var, value)	do { (var) =3D (value); mb(); } while (0)
 #define set_wmb(var, value)	do { (var) =3D (value); mb(); } while (0)
=20
+#define safe_halt()         ia64_pal_halt(1)                /* PAL_HALT */
+
 /*
  * The group barrier in front of the rsm & ssm are necessary to ensure
  * that none of the previous instructions in the same group are
@@ -168,27 +172,7 @@
 #endif /* !CONFIG_IA64_DEBUG_IRQ */
=20
 #define local_irq_enable()	__asm__ __volatile__ (";; ssm psr.i;; srlz.d" :=
:: "memory")
-
-#define local_irq_disable()			local_irq_disable ()
 #define local_save_flags(flags)	__asm__ __volatile__ ("mov %0=3Dpsr" : "=
=3Dr" (flags) :: "memory")
-#define local_irq_save(flags)	local_irq_save(flags)
-#define save_and_cli(flags)	local_irq_save(flags)
-
-#ifdef CONFIG_SMP
-  extern void __global_cli (void);
-  extern void __global_sti (void);
-  extern unsigned long __global_save_flags (void);
-  extern void __global_restore_flags (unsigned long);
-# define cli()			__global_cli()
-# define sti()			__global_sti()
-# define save_flags(flags)	((flags) =3D __global_save_flags())
-# define restore_flags(flags)	__global_restore_flags(flags)
-#else /* !CONFIG_SMP */
-# define cli()			local_irq_disable()
-# define sti()			local_irq_enable()
-# define save_flags(flags)	local_save_flags(flags)
-# define restore_flags(flags)	local_irq_restore(flags)
-#endif /* !CONFIG_SMP */
=20
 /*
  * Force an unresolved reference if someone tries to use
@@ -376,7 +360,7 @@
  * newly created thread returns directly to
  * ia64_ret_from_syscall_clear_r8.
  */
-extern void ia64_switch_to (void *next_task);
+extern struct task_struct *ia64_switch_to (void *next_task);
=20
 struct task_struct;
=20
@@ -384,19 +368,20 @@
 extern void ia64_load_extra (struct task_struct *task);
=20
 #if defined(CONFIG_SMP) && defined(CONFIG_PERFMON)
-# define PERFMON_IS_SYSWIDE() (local_cpu_data->pfm_syst_wide !=3D 0)
+  extern int __per_cpu_data pfm_syst_wide;
+# define PERFMON_IS_SYSWIDE() (this_cpu(pfm_syst_wide) !=3D 0)
 #else
 # define PERFMON_IS_SYSWIDE() (0)
 #endif
=20
-#define __switch_to(prev,next) do {							\
+#define __switch_to(prev,next,last) do {							\
 	if (((prev)->thread.flags & (IA64_THREAD_DBG_VALID|IA64_THREAD_PM_VALID))=
	\
 	    || IS_IA32_PROCESS(ia64_task_regs(prev)) || PERFMON_IS_SYSWIDE())		\
 		ia64_save_extra(prev);							\
 	if (((next)->thread.flags & (IA64_THREAD_DBG_VALID|IA64_THREAD_PM_VALID))=
	\
 	    || IS_IA32_PROCESS(ia64_task_regs(next)) || PERFMON_IS_SYSWIDE())		\
 		ia64_load_extra(next);							\
-	ia64_switch_to((next));								\
+	(last) =3D ia64_switch_to((next));						\
 } while (0)
=20
 #ifdef CONFIG_SMP
@@ -411,19 +396,19 @@
  * task->thread.fph, avoiding the complication of having to fetch
  * the latest fph state from another CPU.
  */
-# define switch_to(prev,next) do {						\
+# define switch_to(prev,next,last) do {						\
 	if (ia64_psr(ia64_task_regs(prev))->mfh) {				\
 		ia64_psr(ia64_task_regs(prev))->mfh =3D 0;			\
 		(prev)->thread.flags |=3D IA64_THREAD_FPH_VALID;			\
 		__ia64_save_fpu((prev)->thread.fph);				\
 	}									\
 	ia64_psr(ia64_task_regs(prev))->dfh =3D 1;				\
-	__switch_to(prev,next);							\
+	__switch_to(prev,next,last);						\
   } while (0)
 #else
-# define switch_to(prev,next) do {						\
+# define switch_to(prev,next,last) do {						\
 	ia64_psr(ia64_task_regs(next))->dfh =3D (ia64_get_fpu_owner() !=3D (next)=
);	\
-	__switch_to(prev,next);							\
+	__switch_to(prev,next,last);						\
 } while (0)
 #endif
=20
diff -Nru a/include/asm-ia64/tlb.h b/include/asm-ia64/tlb.h
--- a/include/asm-ia64/tlb.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/tlb.h	Sat Aug 10 01:51:46 2002
@@ -1,7 +1,202 @@
-/* XXX fix me! */
+#ifndef _ASM_IA64_TLB_H
+#define _ASM_IA64_TLB_H
+/*
+ * Copyright (C) 2002 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+ *
+ * This file was derived from asm-generic/tlb.h.
+ */
+/*
+ * Removing a translation from a page table (including TLB-shootdown) is a=
 four-step
+ * procedure:
+ *
+ *	(1) Flush (virtual) caches --- ensures virtual memory is coherent with =
kernel memory
+ *	    (this is a no-op on ia64).
+ *	(2) Clear the relevant portions of the page-table
+ *	(3) Flush the TLBs --- ensures that stale content is gone from CPU TLBs
+ *	(4) Release the pages that were freed up in step (2).
+ *
+ * Note that the ordering of these steps is crucial to avoid races on MP m=
achines.
+ *
+ * The Linux kernel defines several platform-specific hooks for TLB-shootd=
own.  When
+ * unmapping a portion of the virtual address space, these hooks are calle=
d according to
+ * the following template:
+ *
+ *	tlb <- tlb_gather_mmu(mm, full_mm_flush);	// start unmap for address sp=
ace MM
+ *	{
+ *	  for each vma that needs a shootdown do {
+ *	    tlb_start_vma(tlb, vma);
+ *	      for each page-table-entry PTE that needs to be removed do {
+ *		tlb_remove_tlb_entry(tlb, pte, address);
+ *		if (pte refers to a normal page) {
+ *		  tlb_remove_page(tlb, page);
+ *		}
+ *	      }
+ *	    tlb_end_vma(tlb, vma);
+ *	  }
+ *	}
+ *	tlb_finish_mmu(tlb, start, end);	// finish unmap for address space MM
+ */
+#include <linux/config.h>
+#include <linux/mm.h>
+
+#include <asm/processor.h>
+#include <asm/tlbflush.h>
+
+#ifdef CONFIG_SMP
+# define FREE_PTE_NR		2048
+# define tlb_fast_mode(tlb)	((tlb)->nr =3D ~0U)
+#else
+# define FREE_PTE_NR		0
+# define tlb_fast_mode(tlb)	(1)
+#endif
+
+typedef struct {
+	struct mm_struct	*mm;
+	unsigned int		nr;	/* =3D ~0U =3D> fast mode */
+	unsigned int		fullmm;	/* non-zero means full mm flush */
+	unsigned long		freed;	/* number of pages freed */
+	unsigned long		start_addr;
+	unsigned long		end_addr;
+	struct page 		*pages[FREE_PTE_NR];
+} mmu_gather_t;
+
+/* Users of the generic TLB shootdown code must declare this storage space=
. */
+extern mmu_gather_t	mmu_gathers[NR_CPUS];
+
+/*
+ * Flush the TLB for address range START to END and, if not in fast mode, =
release the
+ * freed pages that where gathered up to this point.
+ */
+static inline void
+ia64_tlb_flush_mmu (mmu_gather_t *tlb, unsigned long start, unsigned long =
end)
+{
+	unsigned int nr;
+
+	if (tlb->fullmm) {
+		/*
+		 * Tearing down the entire address space.  This happens both as a result
+		 * of exit() and execve().  The latter case necessitates the call to
+		 * flush_tlb_mm() here.
+		 */
+		flush_tlb_mm(tlb->mm);
+	} else if (unlikely (end - start >=3D 1024*1024*1024*1024UL
+		      || REGION_NUMBER(start) !=3D REGION_NUMBER(end - 1)))
+	{
+		/*
+		 * If we flush more than a tera-byte or across regions, we're probably
+		 * better off just flushing the entire TLB(s).  This should be very rare
+		 * and is not worth optimizing for.
+		 */
+		flush_tlb_all();
+	} else {
+		/*
+		 * XXX fix me: flush_tlb_range() should take an mm pointer instead of a
+		 * vma pointer.
+		 */
+		struct vm_area_struct vma;
+
+		vma.vm_mm =3D tlb->mm;
+		/* flush the address range from the tlb: */
+		flush_tlb_range(&vma, start, end);
+		/* now flush the virt. page-table area mapping the address range: */
+		flush_tlb_range(&vma, ia64_thash(start), ia64_thash(end));
+	}
+
+	/* lastly, release the freed pages */
+	nr =3D tlb->nr;
+	if (!tlb_fast_mode(tlb)) {
+		unsigned long i;
+		tlb->nr =3D 0;
+		tlb->start_addr =3D ~0UL;
+		for (i =3D 0; i < nr; ++i)
+			free_page_and_swap_cache(tlb->pages[i]);
+	}
+}
+
+/*
+ * Return a pointer to an initialized mmu_gather_t.
+ */
+static inline mmu_gather_t *
+tlb_gather_mmu (struct mm_struct *mm, unsigned int full_mm_flush)
+{
+	mmu_gather_t *tlb =3D &mmu_gathers[smp_processor_id()];
+
+	tlb->mm =3D mm;
+	/*
+	 * Use fast mode if only 1 CPU is online.
+	 *
+	 * It would be tempting to turn on fast-mode for full_mm_flush as well.  =
But this
+	 * doesn't work because of speculative accesses and software prefetching:=
 the page
+	 * table of "mm" may (and usually is) the currently active page table and=
 even
+	 * though the kernel won't do any user-space accesses during the TLB shoo=
t down, a
+	 * compiler might use speculation or lfetch.fault on what happens to be a=
 valid
+	 * user-space address.  This in turn could trigger a TLB miss fault (or a=
 VHPT
+	 * walk) and re-insert a TLB entry we just removed.  Slow mode avoids such
+	 * problems.  (We could make fast-mode work by switching the current task=
 to a
+	 * different "mm" during the shootdown.) --davidm 08/02/2002
+	 */
+	tlb->nr =3D (num_online_cpus() =3D 1) ? ~0U : 0;
+	tlb->fullmm =3D full_mm_flush;
+	tlb->freed =3D 0;
+	tlb->start_addr =3D ~0UL;
+	return tlb;
+}
+
+/*
+ * Called at the end of the shootdown operation to free up any resources t=
hat were
+ * collected.  The page table lock is still held at this point.
+ */
+static inline void
+tlb_finish_mmu (mmu_gather_t *tlb, unsigned long start, unsigned long end)
+{
+	unsigned long freed =3D tlb->freed;
+	struct mm_struct *mm =3D tlb->mm;
+	unsigned long rss =3D mm->rss;
+
+	if (rss < freed)
+		freed =3D rss;
+	mm->rss =3D rss - freed;
+	/*
+	 * Note: tlb->nr may be 0 at this point, so we can't rely on tlb->start_a=
ddr and
+	 * tlb->end_addr.
+	 */
+	ia64_tlb_flush_mmu(tlb, start, end);
+
+	/* keep the page table cache within bounds */
+	check_pgt_cache();
+}
+
+/*
+ * Remove TLB entry for PTE mapped at virtual address ADDRESS.  This is ca=
lled for any
+ * PTE, not just those pointing to (normal) physical memory.
+ */
+static inline void
+tlb_remove_tlb_entry (mmu_gather_t *tlb, pte_t *ptep, unsigned long addres=
s)
+{
+	if (tlb->start_addr =3D ~0UL)
+		tlb->start_addr =3D address;
+	tlb->end_addr =3D address + PAGE_SIZE;
+}
+
+/*
+ * Logically, this routine frees PAGE.  On MP machines, the actual freeing=
 of the page
+ * must be delayed until after the TLB has been flushed (see comments at t=
he beginning of
+ * this file).
+ */
+static inline void
+tlb_remove_page (mmu_gather_t *tlb, struct page *page)
+{
+	if (tlb_fast_mode(tlb)) {
+		free_page_and_swap_cache(page);
+		return;
+	}
+	tlb->pages[tlb->nr++] =3D page;
+	if (tlb->nr >=3D FREE_PTE_NR)
+		ia64_tlb_flush_mmu(tlb, tlb->start_addr, tlb->end_addr);
+}
+
 #define tlb_start_vma(tlb, vma)			do { } while (0)
 #define tlb_end_vma(tlb, vma)			do { } while (0)
-#define tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
-#define tlb_flush(tlb)				flush_tlb_mm((tlb)->mm)
=20
-#include <asm-generic/tlb.h>
+#endif /* _ASM_IA64_TLB_H */
diff -Nru a/include/asm-ia64/tlbflush.h b/include/asm-ia64/tlbflush.h
--- a/include/asm-ia64/tlbflush.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/tlbflush.h	Sat Aug 10 01:51:46 2002
@@ -60,6 +60,8 @@
 #else
 	if (vma->vm_mm =3D current->active_mm)
 		asm volatile ("ptc.l %0,%1" :: "r"(addr), "r"(PAGE_SHIFT << 2) : "memory=
");
+	else
+		vma->vm_mm->context =3D 0;
 #endif
 }
=20
@@ -70,12 +72,10 @@
 static inline void
 flush_tlb_pgtables (struct mm_struct *mm, unsigned long start, unsigned lo=
ng end)
 {
-	struct vm_area_struct vma;
-
-	if (REGION_NUMBER(start) !=3D REGION_NUMBER(end))
-		printk("flush_tlb_pgtables: can't flush across regions!!\n");
-	vma.vm_mm =3D mm;
-	flush_tlb_range(&vma, ia64_thash(start), ia64_thash(end));
+	/*
+	 * Deprecated.  The virtual page table is now flushed via the normal gath=
er/flush
+	 * interface (see tlb.h).
+	 */
 }
=20
 #define flush_tlb_kernel_range(start, end)	flush_tlb_all()	/* XXX fix me */
diff -Nru a/include/asm-ia64/unistd.h b/include/asm-ia64/unistd.h
--- a/include/asm-ia64/unistd.h	Sat Aug 10 01:51:46 2002
+++ b/include/asm-ia64/unistd.h	Sat Aug 10 01:51:46 2002
@@ -223,6 +223,10 @@
 #define __NR_sched_setaffinity		1231
 #define __NR_sched_getaffinity		1232
 #define __NR_security			1233
+#define __NR_get_large_pages		1234
+#define __NR_free_large_pages		1235
+#define __NR_share_large_pages		1236
+#define __NR_unshare_large_pages	1237
=20
 #if !defined(__ASSEMBLY__) && !defined(ASSEMBLER)
=20
diff -Nru a/include/linux/acpi_serial.h b/include/linux/acpi_serial.h
--- a/include/linux/acpi_serial.h	Sat Aug 10 01:51:46 2002
+++ b/include/linux/acpi_serial.h	Sat Aug 10 01:51:46 2002
@@ -9,6 +9,8 @@
  *
  */
=20
+#include <linux/serial.h>
+
 extern void setup_serial_acpi(void *);
=20
 #define ACPI_SIG_LEN		4
diff -Nru a/include/linux/agp_backend.h b/include/linux/agp_backend.h
--- a/include/linux/agp_backend.h	Sat Aug 10 01:51:46 2002
+++ b/include/linux/agp_backend.h	Sat Aug 10 01:51:46 2002
@@ -249,6 +249,16 @@
  *=20
  */
=20
+extern int agp_map_page(unsigned long vaddr, unsigned long paddr);
+
+/*
+ * agp_map_page :
+ *
+ * Update the kernel's page table such that virtual address VADDR maps
+ * to physical address PADDR.  VADDR must be an address in the VMALLOC
+ * arena.
+ */
+
 typedef struct {
 	void       (*free_memory)(agp_memory *);
 	agp_memory *(*allocate_memory)(size_t, u32);
diff -Nru a/include/linux/fs.h b/include/linux/fs.h
--- a/include/linux/fs.h	Sat Aug 10 01:51:46 2002
+++ b/include/linux/fs.h	Sat Aug 10 01:51:46 2002
@@ -513,12 +513,17 @@
=20
 extern int init_private_file(struct file *, struct dentry *, int);
=20
+/* Max fileoffset that can safely be dealt with by filesystems that have n=
ot (yet) been
+   audited for 64-bit issues. */
 #define	MAX_NON_LFS	((1UL<<31) - 1)
=20
-/* Page cache limit. The filesystems should put that into their s_maxbytes=
=20
-   limits, otherwise bad things can happen in VM. */=20
+/* Max fileoffset that can be stored in a variable of type offset_t.  */
+#define MAX_OFF_T	((loff_t)((1UL << ((sizeof(off_t)*8) - 1)) - 1))
+
+/* Page cache limit. The filesystems should put that into their s_maxbytes
+   limits, otherwise bad things can happen in VM. */
 #if BITS_PER_LONG=3D32
-#define MAX_LFS_FILESIZE	(((u64)PAGE_CACHE_SIZE << (BITS_PER_LONG-1))-1)=20
+#define MAX_LFS_FILESIZE	(((u64)PAGE_CACHE_SIZE << (BITS_PER_LONG-1))-1)
 #elif BITS_PER_LONG=3D64
 #define MAX_LFS_FILESIZE 	0x7fffffffffffffff
 #endif
diff -Nru a/include/linux/highmem.h b/include/linux/highmem.h
--- a/include/linux/highmem.h	Sat Aug 10 01:51:46 2002
+++ b/include/linux/highmem.h	Sat Aug 10 01:51:46 2002
@@ -3,6 +3,8 @@
=20
 #include <linux/config.h>
 #include <linux/fs.h>
+#include <linux/mm.h>
+
 #include <asm/cacheflush.h>
=20
 #ifdef CONFIG_HIGHMEM
diff -Nru a/include/linux/irq.h b/include/linux/irq.h
--- a/include/linux/irq.h	Sat Aug 10 01:51:46 2002
+++ b/include/linux/irq.h	Sat Aug 10 01:51:46 2002
@@ -56,15 +56,13 @@
  *
  * Pad this out to 32 bytes for cache and indexing reasons.
  */
-typedef struct {
+typedef struct irq_desc {
 	unsigned int status;		/* IRQ status */
 	hw_irq_controller *handler;
 	struct irqaction *action;	/* IRQ action list */
 	unsigned int depth;		/* nested irq disables */
 	spinlock_t lock;
 } ____cacheline_aligned irq_desc_t;
-
-extern irq_desc_t irq_desc [NR_IRQS];
=20
 #include <asm/hw_irq.h> /* the arch dependent stuff */
=20
diff -Nru a/include/linux/irq_cpustat.h b/include/linux/irq_cpustat.h
--- a/include/linux/irq_cpustat.h	Sat Aug 10 01:51:46 2002
+++ b/include/linux/irq_cpustat.h	Sat Aug 10 01:51:46 2002
@@ -24,7 +24,7 @@
 #define __IRQ_STAT(cpu, member)	(irq_stat[cpu].member)
 #else
 #define __IRQ_STAT(cpu, member)	((void)(cpu), irq_stat[0].member)
-#endif=09
+#endif
 #endif
=20
   /* arch independent irq_stat fields */
@@ -33,5 +33,10 @@
 #define ksoftirqd_task(cpu)	__IRQ_STAT((cpu), __ksoftirqd_task)
   /* arch dependent irq_stat fields */
 #define nmi_count(cpu)		__IRQ_STAT((cpu), __nmi_count)		/* i386, ia64 */
+
+#define local_softirq_pending()	softirq_pending(smp_processor_id())
+#define local_syscall_count()	syscall_count(smp_processor_id())
+#define local_ksoftirqd_task()	ksoftirqd_task(smp_processor_id())
+#define local_nmi_count()	nmi_count(smp_processor_id())
=20
 #endif	/* __irq_cpustat_h */
diff -Nru a/include/linux/kernel.h b/include/linux/kernel.h
--- a/include/linux/kernel.h	Sat Aug 10 01:51:46 2002
+++ b/include/linux/kernel.h	Sat Aug 10 01:51:46 2002
@@ -37,6 +37,13 @@
 #define	KERN_INFO	"<6>"	/* informational			*/
 #define	KERN_DEBUG	"<7>"	/* debug-level messages			*/
=20
+extern int console_printk[];
+
+#define console_loglevel (console_printk[0])
+#define default_message_loglevel (console_printk[1])
+#define minimum_console_loglevel (console_printk[2])
+#define default_console_loglevel (console_printk[3])
+
 struct completion;
=20
 extern struct notifier_block *panic_notifier_list;
@@ -72,8 +79,6 @@
=20
 asmlinkage int printk(const char * fmt, ...)
 	__attribute__ ((format (printf, 1, 2)));
-
-extern int console_loglevel;
=20
 static inline void console_silent(void)
 {
diff -Nru a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h	Sat Aug 10 01:51:46 2002
+++ b/include/linux/mm.h	Sat Aug 10 01:51:46 2002
@@ -182,6 +182,36 @@
 };
=20
 /*
+ * inlines for acquisition and release of PG_chainlock
+ */
+static inline void pte_chain_lock(struct page *page)
+{
+	/*
+	 * Assuming the lock is uncontended, this never enters
+	 * the body of the outer loop. If it is contended, then
+	 * within the inner loop a non-atomic test is used to
+	 * busywait with less bus contention for a good time to
+	 * attempt to acquire the lock bit.
+	 */
+	preempt_disable();
+#ifdef CONFIG_SMP
+	while (test_and_set_bit(PG_chainlock, &page->flags)) {
+		while (test_bit(PG_chainlock, &page->flags))
+			cpu_relax();
+	}
+#endif
+}
+
+static inline void pte_chain_unlock(struct page *page)
+{
+#ifdef CONFIG_SMP
+	smp_mb__before_clear_bit();
+	clear_bit(PG_chainlock, &page->flags);
+#endif
+	preempt_enable();
+}
+
+/*
  * Methods to modify the page usage count.
  *
  * What counts for a page usage:
diff -Nru a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h	Sat Aug 10 01:51:46 2002
+++ b/include/linux/mmzone.h	Sat Aug 10 01:51:46 2002
@@ -88,7 +88,8 @@
 	 * rarely used fields:
 	 */
 	char			*name;
-	unsigned long		size;
+	unsigned long		totalsize;	/* total size, including holes */
+	unsigned long		memsize;	/* amount of memory (excluding holes) */
 } zone_t;
=20
 #define ZONE_DMA		0
diff -Nru a/include/linux/page-flags.h b/include/linux/page-flags.h
--- a/include/linux/page-flags.h	Sat Aug 10 01:51:46 2002
+++ b/include/linux/page-flags.h	Sat Aug 10 01:51:46 2002
@@ -42,6 +42,10 @@
  * address space...
  */
=20
+#include <linux/preempt.h>
+
+struct page;
+
 /*
  * Don't use the *_dontuse flags.  Use the macros.  Otherwise you'll break
  * locked- and dirty-page accounting.  The top eight bits of page->flags a=
re
@@ -226,36 +230,6 @@
 #define TestSetPageDirect(page)	test_and_set_bit(PG_direct, &(page)->flags)
 #define ClearPageDirect(page)		clear_bit(PG_direct, &(page)->flags)
 #define TestClearPageDirect(page)	test_and_clear_bit(PG_direct, &(page)->f=
lags)
-
-/*
- * inlines for acquisition and release of PG_chainlock
- */
-static inline void pte_chain_lock(struct page *page)
-{
-	/*
-	 * Assuming the lock is uncontended, this never enters
-	 * the body of the outer loop. If it is contended, then
-	 * within the inner loop a non-atomic test is used to
-	 * busywait with less bus contention for a good time to
-	 * attempt to acquire the lock bit.
-	 */
-	preempt_disable();
-#ifdef CONFIG_SMP
-	while (test_and_set_bit(PG_chainlock, &page->flags)) {
-		while (test_bit(PG_chainlock, &page->flags))
-			cpu_relax();
-	}
-#endif
-}
-
-static inline void pte_chain_unlock(struct page *page)
-{
-#ifdef CONFIG_SMP
-	smp_mb__before_clear_bit();
-	clear_bit(PG_chainlock, &page->flags);
-#endif
-	preempt_enable();
-}
=20
 /*
  * The PageSwapCache predicate doesn't use a PG_flag at this time,
diff -Nru a/include/linux/percpu.h b/include/linux/percpu.h
--- a/include/linux/percpu.h	Sat Aug 10 01:51:46 2002
+++ b/include/linux/percpu.h	Sat Aug 10 01:51:46 2002
@@ -2,11 +2,11 @@
 #define __LINUX_PERCPU_H
 #include <linux/config.h>
=20
-#ifdef CONFIG_SMP
 #define __per_cpu_data	__attribute__((section(".data.percpu")))
+
+#ifdef CONFIG_SMP
 #include <asm/percpu.h>
 #else
-#define __per_cpu_data
 #define per_cpu(var, cpu)			var
 #define this_cpu(var)				var
 #endif
diff -Nru a/include/linux/sched.h b/include/linux/sched.h
--- a/include/linux/sched.h	Sat Aug 10 01:51:46 2002
+++ b/include/linux/sched.h	Sat Aug 10 01:51:46 2002
@@ -429,14 +429,14 @@
=20
 #ifndef INIT_THREAD_SIZE
 # define INIT_THREAD_SIZE	2048*sizeof(long)
-#endif
-
 union thread_union {
 	struct thread_info thread_info;
 	unsigned long stack[INIT_THREAD_SIZE/sizeof(long)];
 };
=20
 extern union thread_union init_thread_union;
+#endif
+
 extern struct task_struct init_task;
=20
 extern struct   mm_struct init_mm;
diff -Nru a/include/linux/serial.h b/include/linux/serial.h
--- a/include/linux/serial.h	Sat Aug 10 01:51:46 2002
+++ b/include/linux/serial.h	Sat Aug 10 01:51:46 2002
@@ -188,5 +188,8 @@
 #define ACPI_SERIAL_DEBUG_PORT          5
 #endif
=20
+/* tty port reserved for the HCDP serial console port */
+#define HCDP_SERIAL_CONSOLE_PORT	4
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SERIAL_H */
diff -Nru a/include/linux/smp.h b/include/linux/smp.h
--- a/include/linux/smp.h	Sat Aug 10 01:51:46 2002
+++ b/include/linux/smp.h	Sat Aug 10 01:51:46 2002
@@ -57,10 +57,6 @@
  */
 extern int smp_threads_ready;
=20
-extern volatile unsigned long smp_msg_data;
-extern volatile int smp_src_cpu;
-extern volatile int smp_msg_id;
-
 #define MSG_ALL_BUT_SELF	0x8000	/* Assume <32768 CPU's */
 #define MSG_ALL			0x8001
=20
@@ -96,18 +92,6 @@
 #define cpu_online_map				1
 #define cpu_online(cpu)				({ cpu; 1; })
 #define num_online_cpus()			1
-#define __per_cpu_data
-#define per_cpu(var, cpu)			var
-#define this_cpu(var)				var
-
-/* Need to know about CPUs going up/down? */
-static inline int register_cpu_notifier(struct notifier_block *nb)
-{
-	return 0;
-}
-static inline void unregister_cpu_notifier(struct notifier_block *nb)
-{
-}
 #endif /* !SMP */
=20
 #define get_cpu()		({ preempt_disable(); smp_processor_id(); })
diff -Nru a/include/linux/vmalloc.h b/include/linux/vmalloc.h
--- a/include/linux/vmalloc.h	Sat Aug 10 01:51:47 2002
+++ b/include/linux/vmalloc.h	Sat Aug 10 01:51:47 2002
@@ -8,6 +8,7 @@
 /* bits in vm_struct->flags */
 #define VM_IOREMAP	0x00000001	/* ioremap() and friends */
 #define VM_ALLOC	0x00000002	/* vmalloc() */
+#define VM_AGP_REMAP	0x00000004	/* for page-table-based AGP GART emulation=
 */
=20
 struct vm_struct {
 	unsigned long flags;
@@ -25,6 +26,9 @@
 extern int vmalloc_area_pages(unsigned long address, unsigned long size,
                               int gfp_mask, pgprot_t prot);
 extern struct vm_struct *remove_kernel_area(void *addr);
+
+/* Get the flags associated with the area starting at ADDR.  */
+extern unsigned long vgetflags (void *addr);
=20
 /*
  * Various ways to allocate pages.
diff -Nru a/kernel/exec_domain.c b/kernel/exec_domain.c
--- a/kernel/exec_domain.c	Sat Aug 10 01:51:46 2002
+++ b/kernel/exec_domain.c	Sat Aug 10 01:51:46 2002
@@ -196,8 +196,10 @@
=20
 	put_exec_domain(oep);
=20
+#if 0
 	printk(KERN_DEBUG "[%s:%d]: set personality to %lx\n",
 			current->comm, current->pid, personality);
+#endif
 	return 0;
 }
=20
diff -Nru a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c	Sat Aug 10 01:51:46 2002
+++ b/kernel/fork.c	Sat Aug 10 01:51:46 2002
@@ -100,7 +100,11 @@
 	init_task.rlim[RLIMIT_NPROC].rlim_max =3D max_threads/2;
 }
=20
-static struct task_struct *dup_task_struct(struct task_struct *orig)
+#if 1
+extern struct task_struct *dup_task_struct (struct task_struct *orig);
+#else
+
+struct task_struct *dup_task_struct(struct task_struct *orig)
 {
 	struct task_struct *tsk;
 	struct thread_info *ti;
@@ -128,6 +132,8 @@
 	free_thread_info(tsk->thread_info);
 	kmem_cache_free(task_struct_cachep,tsk);
 }
+
+#endif
=20
 /* Protects next_safe and last_pid. */
 spinlock_t lastpid_lock =3D SPIN_LOCK_UNLOCKED;
diff -Nru a/kernel/ksyms.c b/kernel/ksyms.c
--- a/kernel/ksyms.c	Sat Aug 10 01:51:46 2002
+++ b/kernel/ksyms.c	Sat Aug 10 01:51:46 2002
@@ -109,6 +109,7 @@
 EXPORT_SYMBOL(kmalloc);
 EXPORT_SYMBOL(kfree);
 EXPORT_SYMBOL(vfree);
+EXPORT_SYMBOL(vgetflags);
 EXPORT_SYMBOL(__vmalloc);
 EXPORT_SYMBOL(vmalloc);
 EXPORT_SYMBOL(vmalloc_32);
@@ -387,7 +388,9 @@
 EXPORT_SYMBOL(del_timer);
 EXPORT_SYMBOL(request_irq);
 EXPORT_SYMBOL(free_irq);
+#if !defined(CONFIG_IA64)
 EXPORT_SYMBOL(irq_stat);
+#endif
=20
 /* waitqueue handling */
 EXPORT_SYMBOL(add_wait_queue);
@@ -596,7 +599,9 @@
 /* init task, for moving kthread roots - ought to export a function ?? */
=20
 EXPORT_SYMBOL(init_task);
+#ifndef CONFIG_IA64
 EXPORT_SYMBOL(init_thread_union);
+#endif
=20
 EXPORT_SYMBOL(tasklist_lock);
 EXPORT_SYMBOL(pidhash);
diff -Nru a/kernel/printk.c b/kernel/printk.c
--- a/kernel/printk.c	Sat Aug 10 01:51:46 2002
+++ b/kernel/printk.c	Sat Aug 10 01:51:46 2002
@@ -16,6 +16,7 @@
  *	01Mar01 Andrew Morton <andrewm@uow.edu.au>
  */
=20
+#include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/tty.h>
 #include <linux/tty_driver.h>
@@ -54,11 +55,12 @@
=20
 DECLARE_WAIT_QUEUE_HEAD(log_wait);
=20
-/* Keep together for sysctl support */
-int console_loglevel =3D DEFAULT_CONSOLE_LOGLEVEL;
-int default_message_loglevel =3D DEFAULT_MESSAGE_LOGLEVEL;
-int minimum_console_loglevel =3D MINIMUM_CONSOLE_LOGLEVEL;
-int default_console_loglevel =3D DEFAULT_CONSOLE_LOGLEVEL;
+int console_printk[4] =3D {
+	DEFAULT_CONSOLE_LOGLEVEL,	/* console_loglevel */
+	DEFAULT_MESSAGE_LOGLEVEL,	/* default_message_loglevel */
+	MINIMUM_CONSOLE_LOGLEVEL,	/* minimum_console_loglevel */
+	DEFAULT_CONSOLE_LOGLEVEL,	/* default_console_loglevel */
+};
=20
 int oops_in_progress;
=20
@@ -325,6 +327,12 @@
 			__call_console_drivers(start, end);
 		}
 	}
+#ifdef CONFIG_IA64_EARLY_PRINTK
+	if (!console_drivers) {
+		static void early_printk (const char *str, size_t len);
+		early_printk(&LOG_BUF(start), end - start);
+	}
+#endif
 }
=20
 /*
@@ -691,3 +699,108 @@
 		tty->driver.write(tty, 0, msg, strlen(msg));
 	return;
 }
+
+#ifdef CONFIG_IA64_EARLY_PRINTK
+
+# ifdef CONFIG_IA64_EARLY_PRINTK_VGA
+
+#include <asm/io.h>
+
+#define VGABASE		((char *)0xc0000000000b8000)
+#define VGALINES	24
+#define VGACOLS		80
+
+static int current_ypos =3D VGALINES, current_xpos =3D 0;
+
+static void
+early_printk_vga (const char *str, size_t len)
+{
+	char c;
+	int  i, k, j;
+
+	while (len-- > 0) {
+		c =3D *str++;
+		if (current_ypos >=3D VGALINES) {
+			/* scroll 1 line up */
+			for (k =3D 1, j =3D 0; k < VGALINES; k++, j++) {
+				for (i =3D 0; i < VGACOLS; i++) {
+					writew(readw(VGABASE + 2*(VGACOLS*k + i)),
+					       VGABASE + 2*(VGACOLS*j + i));
+				}
+			}
+			for (i =3D 0; i < VGACOLS; i++) {
+				writew(0x720, VGABASE + 2*(VGACOLS*j + i));
+			}
+			current_ypos =3D VGALINES-1;
+		}
+		if (c =3D '\n') {
+			current_xpos =3D 0;
+			current_ypos++;
+		} else if (c !=3D '\r')  {
+			writew(((0x7 << 8) | (unsigned short) c),
+			       VGABASE + 2*(VGACOLS*current_ypos + current_xpos++));
+			if (current_xpos >=3D VGACOLS) {
+				current_xpos =3D 0;
+				current_ypos++;
+			}
+		}
+	}
+}
+
+# endif /* CONFIG_IA64_EARLY_PRINTK_VGA */
+
+# ifdef CONFIG_IA64_EARLY_PRINTK_UART
+
+#include <linux/serial_reg.h>
+#include <asm/system.h>
+
+static void early_printk_uart(const char *str, size_t len)
+{
+	static char *uart =3D NULL;
+	unsigned long uart_base;
+	char c;
+
+	if (!uart) {
+		uart_base =3D 0;
+#  ifdef CONFIG_SERIAL_8250_HCDP
+		{
+			extern unsigned long hcdp_early_uart(void);
+			uart_base =3D hcdp_early_uart();
+		}
+#  endif
+#  if CONFIG_IA64_EARLY_PRINTK_UART_BASE
+		if (!uart_base)
+			uart_base =3D CONFIG_IA64_EARLY_PRINTK_UART_BASE;
+#  endif
+		if (uart_base) {
+			uart =3D ioremap(uart_base, 64);
+			if (!uart)
+				return;
+		}
+	}
+
+	while (len-- > 0) {
+		c =3D *str++;
+		while ((readb(uart + UART_LSR) & UART_LSR_TEMT) =3D 0)
+			cpu_relax(); /* spin */
+
+		writeb(c, uart + UART_TX);
+
+		if (c =3D '\n')
+			writeb('\r', uart + UART_TX);
+	}
+}
+
+# endif /* CONFIG_IA64_EARLY_PRINTK_UART */
+
+void early_printk(const char *str, size_t len)
+{
+#ifdef CONFIG_IA64_EARLY_PRINTK_UART
+	early_printk_uart(str, len);
+#endif
+#ifdef CONFIG_IA64_EARLY_PRINTK_VGA
+	early_printk_vga(str, len);
+#endif
+}
+
+#endif /* CONFIG_IA64_EARLY_PRINTK */
diff -Nru a/kernel/softirq.c b/kernel/softirq.c
--- a/kernel/softirq.c	Sat Aug 10 01:51:46 2002
+++ b/kernel/softirq.c	Sat Aug 10 01:51:46 2002
@@ -38,7 +38,10 @@
    - Bottom halves: globally serialized, grr...
  */
=20
+/* No separate irq_stat for ia64, it is part of PSA */
+#if !defined(CONFIG_IA64)
 irq_cpustat_t irq_stat[NR_CPUS];
+#endif /* CONFIG_IA64 */
=20
 static struct softirq_action softirq_vec[32] __cacheline_aligned_in_smp;
=20
@@ -69,7 +72,7 @@
 	local_irq_save(flags);
 	cpu =3D smp_processor_id();
=20
-	pending =3D softirq_pending(cpu);
+	pending =3D local_softirq_pending();
=20
 	if (pending) {
 		struct softirq_action *h;
@@ -78,7 +81,7 @@
 		local_bh_disable();
 restart:
 		/* Reset the pending bitmask before enabling irqs */
-		softirq_pending(cpu) =3D 0;
+		local_softirq_pending() =3D 0;
=20
 		local_irq_enable();
=20
@@ -93,7 +96,7 @@
=20
 		local_irq_disable();
=20
-		pending =3D softirq_pending(cpu);
+		pending =3D local_softirq_pending();
 		if (pending & mask) {
 			mask &=3D ~pending;
 			goto restart;
@@ -101,7 +104,7 @@
 		__local_bh_enable();
=20
 		if (pending)
-			wakeup_softirqd(cpu);
+			wakeup_softirqd(smp_processor_id());
 	}
=20
 	local_irq_restore(flags);
@@ -371,15 +374,15 @@
 	__set_current_state(TASK_INTERRUPTIBLE);
 	mb();
=20
-	ksoftirqd_task(cpu) =3D current;
+	local_ksoftirqd_task() =3D current;
=20
 	for (;;) {
-		if (!softirq_pending(cpu))
+		if (!local_softirq_pending())
 			schedule();
=20
 		__set_current_state(TASK_RUNNING);
=20
-		while (softirq_pending(cpu)) {
+		while (local_softirq_pending()) {
 			do_softirq();
 			cond_resched();
 		}
@@ -413,6 +416,8 @@
 __init int spawn_ksoftirqd(void)
 {
 	cpu_callback(&cpu_nfb, CPU_ONLINE, (void *)smp_processor_id());
+#if CONFIG_SMP
 	register_cpu_notifier(&cpu_nfb);
+#endif
 	return 0;
 }
diff -Nru a/kernel/timer.c b/kernel/timer.c
--- a/kernel/timer.c	Sat Aug 10 01:51:46 2002
+++ b/kernel/timer.c	Sat Aug 10 01:51:46 2002
@@ -886,7 +886,7 @@
 	if (t.tv_nsec >=3D 1000000000L || t.tv_nsec < 0 || t.tv_sec < 0)
 		return -EINVAL;
=20
-
+#if !defined(__ia64__)
 	if (t.tv_sec =3D 0 && t.tv_nsec <=3D 2000000L &&
 	    current->policy !=3D SCHED_NORMAL)
 	{
@@ -899,6 +899,7 @@
 		udelay((t.tv_nsec + 999) / 1000);
 		return 0;
 	}
+#endif
=20
 	expire =3D timespec_to_jiffies(&t) + (t.tv_sec || t.tv_nsec);
=20
diff -Nru a/mm/bootmem.c b/mm/bootmem.c
--- a/mm/bootmem.c	Sat Aug 10 01:51:46 2002
+++ b/mm/bootmem.c	Sat Aug 10 01:51:46 2002
@@ -143,6 +143,7 @@
 static void * __init __alloc_bootmem_core (bootmem_data_t *bdata,=20
 	unsigned long size, unsigned long align, unsigned long goal)
 {
+	static unsigned long last_success;
 	unsigned long i, start =3D 0;
 	void *ret;
 	unsigned long offset, remaining_size;
@@ -168,6 +169,9 @@
 	if (goal && (goal >=3D bdata->node_boot_start) &&=20
 			((goal >> PAGE_SHIFT) < bdata->node_low_pfn)) {
 		preferred =3D goal - bdata->node_boot_start;
+
+		if (last_success >=3D preferred)
+			preferred =3D last_success;
 	} else
 		preferred =3D 0;
=20
@@ -179,6 +183,8 @@
 restart_scan:
 	for (i =3D preferred; i < eidx; i +=3D incr) {
 		unsigned long j;
+		i =3D find_next_zero_bit((char *)bdata->node_bootmem_map, eidx, i);
+		i =3D (i + incr - 1) & -incr;
 		if (test_bit(i, bdata->node_bootmem_map))
 			continue;
 		for (j =3D i + 1; j < i + areasize; ++j) {
@@ -197,6 +203,7 @@
 	}
 	return NULL;
 found:
+	last_success =3D start << PAGE_SHIFT;
 	if (start >=3D eidx)
 		BUG();
=20
@@ -256,21 +263,21 @@
 	map =3D bdata->node_bootmem_map;
 	for (i =3D 0; i < idx; ) {
 		unsigned long v =3D ~map[i / BITS_PER_LONG];
-		if (v) {=20
+		if (v) {
 			unsigned long m;
-			for (m =3D 1; m && i < idx; m<<=3D1, page++, i++) {=20
+			for (m =3D 1; m && i < idx; m<<=3D1, page++, i++) {
 				if (v & m) {
-			count++;
-			ClearPageReserved(page);
-			set_page_count(page, 1);
-			__free_page(page);
-		}
-	}
+					count++;
+					ClearPageReserved(page);
+					set_page_count(page, 1);
+					__free_page(page);
+				}
+			}
 		} else {
 			i+=3DBITS_PER_LONG;
-			page+=3DBITS_PER_LONG;=20
-		} =09
-	}=09
+			page+=3DBITS_PER_LONG;
+		}
+	}
 	total +=3D count;
=20
 	/*
diff -Nru a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c	Sat Aug 10 01:51:46 2002
+++ b/mm/memory.c	Sat Aug 10 01:51:46 2002
@@ -110,7 +110,7 @@
 	pmd =3D pmd_offset(dir, 0);
 	pgd_clear(dir);
 	for (j =3D 0; j < PTRS_PER_PMD ; j++) {
-		prefetchw(pmd+j+(PREFETCH_STRIDE/16));
+		prefetchw(pmd + j + PREFETCH_STRIDE/sizeof(*pmd));
 		free_one_pmd(tlb, pmd+j);
 	}
 	pmd_free_tlb(tlb, pmd);
diff -Nru a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c	Sat Aug 10 01:51:46 2002
+++ b/mm/page_alloc.c	Sat Aug 10 01:51:46 2002
@@ -47,7 +47,7 @@
  */
 static inline int bad_range(zone_t *zone, struct page *page)
 {
-	if (page - mem_map >=3D zone->zone_start_mapnr + zone->size)
+	if (page - mem_map >=3D zone->zone_start_mapnr + zone->totalsize)
 		return 1;
 	if (page - mem_map < zone->zone_start_mapnr)
 		return 1;
@@ -497,7 +497,7 @@
 		zone_t *zone;
=20
 		for (zone =3D *zonep++; zone; zone =3D *zonep++) {
-			unsigned long size =3D zone->size;
+			unsigned long size =3D zone->memsize;
 			unsigned long high =3D zone->pages_high;
 			if (size > high)
 				sum +=3D size - high;
@@ -637,7 +637,7 @@
 			zone_t *zone =3D &pgdat->node_zones[type];
  			unsigned long nr, flags, order, total =3D 0;
=20
-			if (!zone->size)
+			if (!zone->memsize)
 				continue;
=20
 			spin_lock_irqsave(&zone->lock, flags);
@@ -684,7 +684,7 @@
 			 */
 			case ZONE_HIGHMEM:
 				zone =3D pgdat->node_zones + ZONE_HIGHMEM;
-				if (zone->size) {
+				if (zone->memsize) {
 #ifndef CONFIG_HIGHMEM
 					BUG();
 #endif
@@ -692,11 +692,11 @@
 				}
 			case ZONE_NORMAL:
 				zone =3D pgdat->node_zones + ZONE_NORMAL;
-				if (zone->size)
+				if (zone->memsize)
 					zonelist->zones[j++] =3D zone;
 			case ZONE_DMA:
 				zone =3D pgdat->node_zones + ZONE_DMA;
-				if (zone->size)
+				if (zone->memsize)
 					zonelist->zones[j++] =3D zone;
 		}
 		zonelist->zones[j++] =3D NULL;
@@ -807,7 +807,8 @@
 			realsize -=3D zholes_size[j];
=20
 		printk("zone(%lu): %lu pages.\n", j, size);
-		zone->size =3D size;
+		zone->totalsize =3D size;
+		zone->memsize =3D realsize;
 		zone->name =3D zone_names[j];
 		zone->lock =3D SPIN_LOCK_UNLOCKED;
 		zone->zone_pgdat =3D pgdat;
diff -Nru a/mm/vmalloc.c b/mm/vmalloc.c
--- a/mm/vmalloc.c	Sat Aug 10 01:51:46 2002
+++ b/mm/vmalloc.c	Sat Aug 10 01:51:46 2002
@@ -367,3 +367,20 @@
 	read_unlock(&vmlist_lock);
 	return buf - buf_start;
 }
+
+unsigned long vgetflags (void * addr)
+{
+	struct vm_struct *tmp;
+	unsigned long flags;
+
+	write_lock(&vmlist_lock);
+	for (tmp =3D vmlist ; tmp ; tmp =3D tmp->next) {
+		if (tmp->addr =3D addr) {
+			flags =3D tmp->flags;
+			break;
+		}
+
+	}
+	write_unlock(&vmlist_lock);
+	return flags;
+}
diff -Nru a/sound/oss/cs4281/cs4281m.c b/sound/oss/cs4281/cs4281m.c
--- a/sound/oss/cs4281/cs4281m.c	Sat Aug 10 01:51:47 2002
+++ b/sound/oss/cs4281/cs4281m.c	Sat Aug 10 01:51:47 2002
@@ -1942,8 +1942,8 @@
 		len -=3D x;
 	}
 	CS_DBGOUT(CS_WAVE_WRITE, 4, printk(KERN_INFO
-		"cs4281: clear_advance(): memset %d at 0x%.8x for %d size \n",
-			(unsigned)c, (unsigned)((char *) buf) + bptr, len));
+		"cs4281: clear_advance(): memset %d at %p for %d size \n",
+			(unsigned)c, ((char *) buf) + bptr, len));
 	memset(((char *) buf) + bptr, c, len);
 }
=20
@@ -1978,9 +1978,8 @@
 				wake_up(&s->dma_adc.wait);
 		}
 		CS_DBGOUT(CS_PARMS, 8, printk(KERN_INFO
-			"cs4281: cs4281_update_ptr(): s=3D0x%.8x hwptr=3D%d total_bytes=3D%d co=
unt=3D%d \n",
-				(unsigned)s, s->dma_adc.hwptr,=20
-				s->dma_adc.total_bytes, s->dma_adc.count));
+			"cs4281: cs4281_update_ptr(): s=3D%p hwptr=3D%d total_bytes=3D%d count=
=3D%d \n",
+				s, s->dma_adc.hwptr, s->dma_adc.total_bytes, s->dma_adc.count));
 	}
 	// update DAC pointer=20
 	//
@@ -2012,11 +2011,10 @@
 				// Continue to play silence until the _release.
 				//
 				CS_DBGOUT(CS_WAVE_WRITE, 6, printk(KERN_INFO
-					"cs4281: cs4281_update_ptr(): memset %d at 0x%.8x for %d size \n",
+					"cs4281: cs4281_update_ptr(): memset %d at %p for %d size \n",
 						(unsigned)(s->prop_dac.fmt &=20
 						(AFMT_U8 | AFMT_U16_LE)) ? 0x80 : 0,=20
-						(unsigned)s->dma_dac.rawbuf,=20
-						s->dma_dac.dmasize));
+						s->dma_dac.rawbuf, s->dma_dac.dmasize));
 				memset(s->dma_dac.rawbuf,
 				       (s->prop_dac.
 					fmt & (AFMT_U8 | AFMT_U16_LE)) ?
@@ -2047,9 +2045,8 @@
 			}
 		}
 		CS_DBGOUT(CS_PARMS, 8, printk(KERN_INFO
-			"cs4281: cs4281_update_ptr(): s=3D0x%.8x hwptr=3D%d total_bytes=3D%d co=
unt=3D%d \n",
-				(unsigned) s, s->dma_dac.hwptr,=20
-				s->dma_dac.total_bytes, s->dma_dac.count));
+			"cs4281: cs4281_update_ptr(): s=3D%p hwptr=3D%d total_bytes=3D%d count=
=3D%d \n",
+				s, s->dma_dac.hwptr, s->dma_dac.total_bytes, s->dma_dac.count));
 	}
 }
=20
@@ -2180,8 +2177,7 @@
=20
 	VALIDATE_STATE(s);
 	CS_DBGOUT(CS_FUNCTION, 4, printk(KERN_INFO
-		 "cs4281: mixer_ioctl(): s=3D0x%.8x cmd=3D0x%.8x\n",
-			 (unsigned) s, cmd));
+		 "cs4281: mixer_ioctl(): s=3D%p cmd=3D0x%.8x\n", s, cmd));
 #if CSDEBUG
 	cs_printioctl(cmd);
 #endif
@@ -2746,9 +2742,8 @@
 	CS_DBGOUT(CS_FUNCTION, 2,
 		  printk(KERN_INFO "cs4281: CopySamples()+ "));
 	CS_DBGOUT(CS_WAVE_READ, 8, printk(KERN_INFO
-		 " dst=3D0x%x src=3D0x%x count=3D%d iChannels=3D%d fmt=3D0x%x\n",
-			 (unsigned) dst, (unsigned) src, (unsigned) count,
-			 (unsigned) iChannels, (unsigned) fmt));
+		 " dst=3D%p src=3D%p count=3D%d iChannels=3D%d fmt=3D0x%x\n",
+			 dst, src, (unsigned) count, (unsigned) iChannels, (unsigned) fmt));
=20
 	// Gershwin does format conversion in hardware so normally
 	// we don't do any host based coversion. The data formatter
@@ -2828,9 +2823,9 @@
 	void *src =3D hwsrc;	//default to the standard destination buffer addr
=20
 	CS_DBGOUT(CS_FUNCTION, 6, printk(KERN_INFO
-		"cs_copy_to_user()+ fmt=3D0x%x fmt_o=3D0x%x cnt=3D%d dest=3D0x%.8x\n",
+		"cs_copy_to_user()+ fmt=3D0x%x fmt_o=3D0x%x cnt=3D%d dest=3D%p\n",
 			s->prop_adc.fmt, s->prop_adc.fmt_original,
-			(unsigned) cnt, (unsigned) dest));
+			(unsigned) cnt, dest));
=20
 	if (cnt > s->dma_adc.dmasize) {
 		cnt =3D s->dma_adc.dmasize;
@@ -2875,7 +2870,7 @@
 	unsigned copied =3D 0;
=20
 	CS_DBGOUT(CS_FUNCTION | CS_WAVE_READ, 2,
-		  printk(KERN_INFO "cs4281: cs4281_read()+ %d \n", count));
+		  printk(KERN_INFO "cs4281: cs4281_read()+ %Zu \n", count));
=20
 	VALIDATE_STATE(s);
 	if (ppos !=3D &file->f_pos)
@@ -2898,7 +2893,7 @@
 //
 	while (count > 0) {
 		CS_DBGOUT(CS_WAVE_READ, 8, printk(KERN_INFO
-			"_read() count>0 count=3D%d .count=3D%d .swptr=3D%d .hwptr=3D%d \n",
+			"_read() count>0 count=3D%Zu .count=3D%d .swptr=3D%d .hwptr=3D%d \n",
 				count, s->dma_adc.count,
 				s->dma_adc.swptr, s->dma_adc.hwptr));
 		spin_lock_irqsave(&s->lock, flags);
@@ -2955,11 +2950,10 @@
 		// the "cnt" is the number of bytes to read.
=20
 		CS_DBGOUT(CS_WAVE_READ, 2, printk(KERN_INFO
-			"_read() copy_to cnt=3D%d count=3D%d ", cnt, count));
+			"_read() copy_to cnt=3D%d count=3D%Zu ", cnt, count));
 		CS_DBGOUT(CS_WAVE_READ, 8, printk(KERN_INFO
-			 " .dmasize=3D%d .count=3D%d buffer=3D0x%.8x ret=3D%d\n",
-				 s->dma_adc.dmasize, s->dma_adc.count,
-				 (unsigned) buffer, ret));
+			 " .dmasize=3D%d .count=3D%d buffer=3D%p ret=3D%Zd\n",
+				 s->dma_adc.dmasize, s->dma_adc.count, buffer, ret));
=20
 		if (cs_copy_to_user
 		    (s, buffer, s->dma_adc.rawbuf + swptr, cnt, &copied))
@@ -2975,7 +2969,7 @@
 		start_adc(s);
 	}
 	CS_DBGOUT(CS_FUNCTION | CS_WAVE_READ, 2,
-		  printk(KERN_INFO "cs4281: cs4281_read()- %d\n", ret));
+		  printk(KERN_INFO "cs4281: cs4281_read()- %Zd\n", ret));
 	return ret;
 }
=20
@@ -2991,7 +2985,7 @@
 	int cnt;
=20
 	CS_DBGOUT(CS_FUNCTION | CS_WAVE_WRITE, 2,
-		  printk(KERN_INFO "cs4281: cs4281_write()+ count=3D%d\n",
+		  printk(KERN_INFO "cs4281: cs4281_write()+ count=3D%Zu\n",
 			 count));
 	VALIDATE_STATE(s);
=20
@@ -3047,7 +3041,7 @@
 		start_dac(s);
 	}
 	CS_DBGOUT(CS_FUNCTION | CS_WAVE_WRITE, 2,
-		  printk(KERN_INFO "cs4281: cs4281_write()- %d\n", ret));
+		  printk(KERN_INFO "cs4281: cs4281_write()- %Zd\n", ret));
 	return ret;
 }
=20
@@ -3168,8 +3162,7 @@
 	int val, mapped, ret;
=20
 	CS_DBGOUT(CS_FUNCTION, 4, printk(KERN_INFO
-		 "cs4281: cs4281_ioctl(): file=3D0x%.8x cmd=3D0x%.8x\n",
-			 (unsigned) file, cmd));
+		 "cs4281: cs4281_ioctl(): file=3D%p cmd=3D0x%.8x\n", file, cmd));
 #if CSDEBUG
 	cs_printioctl(cmd);
 #endif
@@ -3205,7 +3198,7 @@
 			 "cs4281: cs4281_ioctl(): DSP_RESET\n"));
 		if (file->f_mode & FMODE_WRITE) {
 			stop_dac(s);
-			synchronize_irq();
+			synchronize_irq(s->irq);
 			s->dma_dac.swptr =3D s->dma_dac.hwptr  			    s->dma_dac.count =3D s->d=
ma_dac.total_bytes  			    s->dma_dac.blocks =3D s->dma_dac.wakeup =3D 0;
@@ -3213,7 +3206,7 @@
 		}
 		if (file->f_mode & FMODE_READ) {
 			stop_adc(s);
-			synchronize_irq();
+			synchronize_irq(s->irq);
 			s->dma_adc.swptr =3D s->dma_adc.hwptr  			    s->dma_adc.count =3D s->d=
ma_adc.total_bytes  			    s->dma_adc.blocks =3D s->dma_dac.wakeup =3D 0;
@@ -3599,8 +3592,8 @@
 	    (struct cs4281_state *) file->private_data;
=20
 	CS_DBGOUT(CS_FUNCTION | CS_RELEASE, 2, printk(KERN_INFO
-		 "cs4281: cs4281_release(): inode=3D0x%.8x file=3D0x%.8x f_mode=3D%d\n",
-			 (unsigned) inode, (unsigned) file, file->f_mode));
+		 "cs4281: cs4281_release(): inode=3D%p file=3D%p f_mode=3D%d\n",
+			 inode, file, file->f_mode));
=20
 	VALIDATE_STATE(s);
=20
@@ -3634,8 +3627,8 @@
 	struct list_head *entry;
=20
 	CS_DBGOUT(CS_FUNCTION | CS_OPEN, 2, printk(KERN_INFO
-		"cs4281: cs4281_open(): inode=3D0x%.8x file=3D0x%.8x f_mode=3D0x%x\n",
-			(unsigned) inode, (unsigned) file, file->f_mode));
+		"cs4281: cs4281_open(): inode=3D%p file=3D%p f_mode=3D0x%x\n",
+			inode, file, file->f_mode));
=20
 	list_for_each(entry, &cs4281_devs)
 	{
@@ -4344,10 +4337,8 @@
=20
 	CS_DBGOUT(CS_INIT, 2,
 		  printk(KERN_INFO
-			 "cs4281: probe() BA0=3D0x%.8x BA1=3D0x%.8x pBA0=3D0x%.8x pBA1=3D0x%.8x=
 \n",
-			 (unsigned) temp1, (unsigned) temp2,
-			 (unsigned) s->pBA0, (unsigned) s->pBA1));
-
+			 "cs4281: probe() BA0=3D0x%.8x BA1=3D0x%.8x pBA0=3D%p pBA1=3D%p \n",
+			 (unsigned) temp1, (unsigned) temp2, s->pBA0, s->pBA1));
 	CS_DBGOUT(CS_INIT, 2,
 		  printk(KERN_INFO
 			 "cs4281: probe() pBA0phys=3D0x%.8x pBA1phys=3D0x%.8x\n",
@@ -4394,15 +4385,13 @@
 	if (pmdev)
 	{
 		CS_DBGOUT(CS_INIT | CS_PM, 4, printk(KERN_INFO
-			 "cs4281: probe() pm_register() succeeded (0x%x).\n",
-				(unsigned)pmdev));
+			 "cs4281: probe() pm_register() succeeded (%p).\n", pmdev));
 		pmdev->data =3D s;
 	}
 	else
 	{
 		CS_DBGOUT(CS_INIT | CS_PM | CS_ERROR, 0, printk(KERN_INFO
-			 "cs4281: probe() pm_register() failed (0x%x).\n",
-				(unsigned)pmdev));
+			 "cs4281: probe() pm_register() failed (%p).\n", pmdev));
 		s->pm.flags |=3D CS4281_PM_NOT_REGISTERED;
 	}
 #endif
@@ -4452,7 +4441,7 @@
 {
 	struct cs4281_state *s =3D pci_get_drvdata(pci_dev);
 	// stop DMA controller=20
-	synchronize_irq();
+	synchronize_irq(s->irq);
 	free_irq(s->irq, s);
 	unregister_sound_dsp(s->dev_audio);
 	unregister_sound_mixer(s->dev_mixer);
diff -Nru a/sound/oss/cs4281/cs4281pm-24.c b/sound/oss/cs4281/cs4281pm-24.c
--- a/sound/oss/cs4281/cs4281pm-24.c	Sat Aug 10 01:51:47 2002
+++ b/sound/oss/cs4281/cs4281pm-24.c	Sat Aug 10 01:51:47 2002
@@ -38,16 +38,16 @@
 #define CS4281_SUSPEND_TBL cs4281_suspend_tbl
 #define CS4281_RESUME_TBL cs4281_resume_tbl
 */
-#define CS4281_SUSPEND_TBL cs4281_null
-#define CS4281_RESUME_TBL cs4281_null
+#define CS4281_SUSPEND_TBL	(int (*) (struct pci_dev *, u32)) cs4281_null
+#define CS4281_RESUME_TBL	(int (*) (struct pci_dev *)) cs4281_null
=20
 int cs4281_pm_callback(struct pm_dev *dev, pm_request_t rqst, void *data)
 {
 	struct cs4281_state *state;
=20
 	CS_DBGOUT(CS_PM, 2, printk(KERN_INFO=20
-		"cs4281: cs4281_pm_callback dev=3D0x%x rqst=3D0x%x state=3D%d\n",
-			(unsigned)dev,(unsigned)rqst,(unsigned)data));
+		"cs4281: cs4281_pm_callback dev=3D%p rqst=3D0x%x state=3D%p\n",
+			dev,(unsigned)rqst,data));
 	state =3D (struct cs4281_state *) dev->data;
 	if (state) {
 		switch(rqst) {
@@ -78,7 +78,7 @@
 }
=20
 #else /* CS4281_PM */
-#define CS4281_SUSPEND_TBL cs4281_null
-#define CS4281_RESUME_TBL cs4281_null
+#define CS4281_SUSPEND_TBL	(int (*) (struct pci_dev *, u32)) cs4281_null
+#define CS4281_RESUME_TBL 	(int (*) (struct pci_dev *)) cs4281_null
 #endif /* CS4281_PM */
=20

