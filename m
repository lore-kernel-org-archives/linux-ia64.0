From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 25 Sep 2001 07:13:28 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.10)
Message-Id: <marc-linux-ia64-105590698805619@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Here is a long-awaited kernel update which brings us in sync with
2.4.10.  As usual, it's available at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/ in file:

	linux-2.4.10-ia64-010924.diff*

The major changes this time include:

 - Major ia32 subsystem update by yours truly:
	- enable use of emulator prefix: for a non-directory file with
	  path PATH, the ia32 subsystem now uses /emul/ia32-linux/PATH
	  if the file exists
	- fix a nasty bug which caused ia32 binaries to subtly corrupt
	  page table page (this was the reason "realplay" often crashed
	  on start up, but the bug could affect any process, not just
	  ia32 processes)
	- make the address space layout of ia32 tasks match that of
	  a real linux/x86 task; in particular, the stack now starts
	  at 0xc0000000 (and grows towards lower addresses)
	- fix emulated mmap() and mprotect() to work when page size is 4K
	  and work better when the page size is larger
	- fix emulated ptrace() sys x86 strace() works
	- fill in missing system calls (pread, pwrite, sendfile, SuS-compliant
	  getrlimit, mmap2, {,f}truncate64, {,l,f}stat64, 32-bit uid/gid
	  versions of lchown, getuid etc., pivot_root, mincore, madvise,
	  getdents64, fcntl64) and drop some unsupported ones
	  (module related syscalls, vm86, bdflush)
	- support signal delivery with SA_RESTORER sigreturn
	- don't align shared mmap()s to 1MB---this filled up a 32-bit address
	  space too quickly
    with these fixes in place, I'm able to successfully run the ia32
    versions of realplay, OpenOffice, mozilla, netscape, acrobat, strace,
    Intel compilers, etc.  But as usual, your mileage may vary.
 - update perform to v0.3 (Stephane Eranian)
 - SN updates from SGI (just a starter, more to follow...)
 - be more consistent about using i-cache prefetches (use .few for branches
   within a routine, .many otherwise)
 - fix alternate stack signal delivery (used to break if the old stack
   didn't have enough memory to hold the dirty stacked registers); ironical=
ly,
   this fix probably also speeds up this case (it's no longer necessary
   to do a flushrs...)
 - McKinley related I/O SAPIC updates from Alex Williamson
 - fix irq bug which caused console keyboard to report timeout when
   pressing the caps lock key (Richard Hirst)
 - fix ptrace race condition (thanks to Shoichi Sakon for providing
   a test case that reproduced this problem)
 - turn on dcr.lc by default
 - many sync-ups for 2.4.10 (thanks to KOCHI Takayoshi for sending a timely
   ACPI update)

I should warn that this kernel has received only moderate testing so
far.  The remote access server I'm normally using to access a test
ia64 machine crashed just shortly before making the patch, so I wasn't
able to do my usual round of testing.  Having said that, the kernel
seems to work fine on a dual Itanium Big Sur, so there is hope.  As
you know, Linus and co decided to basically rewrite the VM system.  As
far as I can tell, this hasn't had any negative impact on ia64, but
I'd recommend doing a lot of testing before declaring this kernel as
ready for prime time.

Oh, and as usual, the patch below is fyi, only.  The the full patch
for definite answers.

Enjoy,

	--david

diff -urN linux-davidm/Documentation/Configure.help linux-2.4.10-lia/Docume=
ntation/Configure.help
--- linux-davidm/Documentation/Configure.help	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/Documentation/Configure.help	Mon Sep 24 21:34:01 2001
@@ -18686,10 +18686,21 @@
   so the "DIG-compliant" option is usually the right choice.
=20
   HP-simulator   For the HP simulator (http://software.hp.com/ia64linux/).
-  SN1-simulator  For the SGI SN1 simulator.
+  SGI-SN1	 For SGI SN1 Platforms.
+  SGI-SN2	 For SGI SN2 Platforms.
   DIG-compliant  For DIG ("Developer's Interface Guide") compliant system.
=20
   If you don't know what to do, choose "generic".
+
+CONFIG_IA64_SGI_SN_SIM
+  Build a kernel that runs on both the SGI simulator AND on hardware.
+  There is a very slight performance penalty on hardware for including this
+  option.
+
+CONFIG_IA64_SGI_SN_DEBUG
+  This enables addition debug code that helps isolate
+  platform/kernel bugs. There is a small but measurable performance
+  degradation when this option is enabled.
=20
 Kernel page size
 CONFIG_IA64_PAGE_SIZE_4KB
diff -urN linux-davidm/arch/ia64/Makefile linux-2.4.10-lia/arch/ia64/Makefi=
le
--- linux-davidm/arch/ia64/Makefile	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/Makefile	Mon Sep 24 22:20:41 2001
@@ -17,7 +17,9 @@
 AFLAGS_KERNEL :=3D -mconstant-gp
 EXTRA	=20
-CFLAGS :=3D $(CFLAGS) -pipe $(EXTRA) -ffixed-r13 -mfixed-range=F10-f15,f32=
-f127 -falign-functions2
+CFLAGS :=3D $(CFLAGS) -pipe $(EXTRA) -ffixed-r13 -mfixed-range=F10-f15,f32=
-f127 \
+	  -falign-functions2 --param max-inline-insns@0
+# -ffunction-sections
 CFLAGS_KERNEL :=3D -mconstant-gp
=20
 GCC_VERSION=3D$(shell $(CROSS_COMPILE)$(HOSTCC) -v 2>&1 | fgrep 'gcc versi=
on' | cut -f3 -d' ' | cut -f1 -d'.')
@@ -32,7 +34,7 @@
=20
 ifdef CONFIG_IA64_GENERIC
 	CORE_FILES      :=3D      arch/$(ARCH)/hp/hp.a	\
-				arch/$(ARCH)/sn/sn.a	\
+				arch/$(ARCH)/sn/sn.o	\
 				arch/$(ARCH)/dig/dig.a	\
 				arch/$(ARCH)/sn/io/sgiio.o \
 				$(CORE_FILES)
@@ -52,15 +54,14 @@
                                 $(CORE_FILES)
 endif
=20
-ifdef CONFIG_IA64_SGI_SN1
+ifdef CONFIG_IA64_SGI_SN
 	CFLAGS		+=3D -DBRINGUP
-        SUBDIRS         :=3D      arch/$(ARCH)/sn/sn1	\
-				arch/$(ARCH)/sn		\
+        SUBDIRS         :=3D      arch/$(ARCH)/sn/kernel	\
 				arch/$(ARCH)/sn/io	\
 				arch/$(ARCH)/sn/fprom	\
 				$(SUBDIRS)
-        CORE_FILES      :=3D      arch/$(ARCH)/sn/sn.a	\
-				arch/$(ARCH)/sn/io/sgiio.o\
+        CORE_FILES      :=3D      arch/$(ARCH)/sn/kernel/sn.o	\
+				arch/$(ARCH)/sn/io/sgiio.o	\
 				$(CORE_FILES)
 endif
=20
diff -urN linux-davidm/arch/ia64/config.in linux-2.4.10-lia/arch/ia64/confi=
g.in
--- linux-davidm/arch/ia64/config.in	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/config.in	Mon Sep 24 21:43:20 2001
@@ -28,6 +28,7 @@
=20
 if [ "$CONFIG_IA64_HP_SIM" =3D "n" ]; then
   define_bool CONFIG_ACPI y
+  define_bool CONFIG_ACPI_EFI y
   define_bool CONFIG_ACPI_INTERPRETER y
   define_bool CONFIG_ACPI_KERNEL_CONFIG y
 fi
@@ -40,7 +41,8 @@
 	"generic		CONFIG_IA64_GENERIC		\
 	 DIG-compliant		CONFIG_IA64_DIG			\
 	 HP-simulator		CONFIG_IA64_HP_SIM		\
-	 SGI-SN1		CONFIG_IA64_SGI_SN1" generic
+	 SGI-SN1		CONFIG_IA64_SGI_SN1		\
+	 SGI-SN2		CONFIG_IA64_SGI_SN2" generic
=20
 choice 'Kernel page size'						\
 	"4KB			CONFIG_IA64_PAGE_SIZE_4KB		\
@@ -71,18 +73,22 @@
 	define_bool CONFIG_PM y
 fi
=20
-if [ "$CONFIG_IA64_SGI_SN1" =3D "y" ]; then
-	bool '  Enable SGI Medusa Simulator Support' CONFIG_IA64_SGI_SN1_SIM
-	define_bool CONFIG_DEVFS_DEBUG y
+if [ "$CONFIG_IA64_SGI_SN1" =3D "y" ] || [ "$CONFIG_IA64_SGI_SN2" =3D "y" =
]; then
+	define_bool CONFIG_IA64_SGI_SN y
+	bool '  Enable extra debugging code' CONFIG_IA64_SGI_SN_DEBUG n
+	bool '  Enable SGI Medusa Simulator Support' CONFIG_IA64_SGI_SN_SIM
+	bool '  Enable autotest (llsc). Option to run cache test instead of booti=
ng' \
+			CONFIG_IA64_SGI_AUTOTEST n
 	define_bool CONFIG_DEVFS_FS y
-	define_bool CONFIG_IA64_BRL_EMU y
+	if [ "$CONFIG_DEVFS_FS" =3D "y" ]; then
+	  bool '    Enable DEVFS Debug Code' CONFIG_DEVFS_DEBUG n
+	fi
+	bool '  Enable protocol mode for the L1 console' CONFIG_SERIAL_SGI_L1_PRO=
TOCOL y
+	define_bool CONFIG_DISCONTIGMEM y
 	define_bool CONFIG_IA64_MCA y
-	define_bool CONFIG_ITANIUM y
-	define_bool CONFIG_SGI_IOC3_ETH y
+	define_bool CONFIG_NUMA y
 	define_bool CONFIG_PERCPU_IRQ y
-	define_int  CONFIG_CACHE_LINE_SHIFT 7
-	bool '  Enable DISCONTIGMEM support' CONFIG_DISCONTIGMEM
-	bool '	Enable NUMA support' CONFIG_NUMA
+	tristate '  PCIBA support' CONFIG_PCIBA
 fi
=20
 define_bool CONFIG_KCORE_ELF y	# On IA-64, we always want an ELF /proc/kco=
re.
@@ -250,13 +256,19 @@
 mainmenu_option next_comment
 comment 'Kernel hacking'
=20
-#bool 'Debug kmalloc/kfree' CONFIG_DEBUG_MALLOC
-
-bool 'Magic SysRq key' CONFIG_MAGIC_SYSRQ
-bool 'Early printk support (requires VGA!)' CONFIG_IA64_EARLY_PRINTK
-bool 'Turn on compare-and-exchange bug checking (slow!)' CONFIG_IA64_DEBUG=
_CMPXCHG
-bool 'Turn on irq debug checks (slow!)' CONFIG_IA64_DEBUG_IRQ
-bool 'Print possible IA64 hazards to console' CONFIG_IA64_PRINT_HAZARDS
-bool 'Disable VHPT' CONFIG_DISABLE_VHPT
+bool 'Kernel debugging' CONFIG_DEBUG_KERNEL
+if [ "$CONFIG_DEBUG_KERNEL" !=3D "n" ]; then
+   bool '  Print possible IA64 hazards to console' CONFIG_IA64_PRINT_HAZAR=
DS
+   bool '  Disable VHPT' CONFIG_DISABLE_VHPT
+   bool '  Magic SysRq key' CONFIG_MAGIC_SYSRQ
+
+# early printk is currently broken for SMP: the secondary processors get s=
tuck...
+#   bool '  Early printk support (requires VGA!)' CONFIG_IA64_EARLY_PRINTK
+
+   bool '  Debug memory allocations' CONFIG_DEBUG_SLAB
+   bool '  Spinlock debugging' CONFIG_DEBUG_SPINLOCK
+   bool '  Turn on compare-and-exchange bug checking (slow!)' CONFIG_IA64_=
DEBUG_CMPXCHG
+   bool '  Turn on irq debug checks (slow!)' CONFIG_IA64_DEBUG_IRQ
+fi
=20
 endmenu
diff -urN linux-davidm/arch/ia64/defconfig linux-2.4.10-lia/arch/ia64/defco=
nfig
--- linux-davidm/arch/ia64/defconfig	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/defconfig	Mon Sep 24 22:23:50 2001
@@ -25,6 +25,7 @@
 CONFIG_RWSEM_GENERIC_SPINLOCK=3Dy
 # CONFIG_RWSEM_XCHGADD_ALGORITHM is not set
 CONFIG_ACPI=3Dy
+CONFIG_ACPI_EFI=3Dy
 CONFIG_ACPI_INTERPRETER=3Dy
 CONFIG_ACPI_KERNEL_CONFIG=3Dy
 CONFIG_ITANIUM=3Dy
@@ -33,6 +34,7 @@
 CONFIG_IA64_DIG=3Dy
 # CONFIG_IA64_HP_SIM is not set
 # CONFIG_IA64_SGI_SN1 is not set
+# CONFIG_IA64_SGI_SN2 is not set
 # CONFIG_IA64_PAGE_SIZE_4KB is not set
 # CONFIG_IA64_PAGE_SIZE_8KB is not set
 CONFIG_IA64_PAGE_SIZE_16KB=3Dy
@@ -44,6 +46,7 @@
 CONFIG_PM=3Dy
 CONFIG_KCORE_ELF=3Dy
 CONFIG_SMP=3Dy
+CONFIG_IA32_SUPPORT=3Dy
 CONFIG_PERFMON=3Dy
 CONFIG_IA64_PALINFO=3Dy
 CONFIG_EFI_VARS=3Dy
@@ -159,6 +162,7 @@
 # CONFIG_MD_RAID0 is not set
 # CONFIG_MD_RAID1 is not set
 # CONFIG_MD_RAID5 is not set
+# CONFIG_MD_MULTIPATH is not set
 # CONFIG_BLK_DEV_LVM is not set
=20
 #
@@ -203,6 +207,7 @@
 CONFIG_BLK_DEV_IDEPCI=3Dy
 CONFIG_IDEPCI_SHARE_IRQ=3Dy
 CONFIG_BLK_DEV_IDEDMA_PCI=3Dy
+CONFIG_BLK_DEV_ADMA=3Dy
 # CONFIG_BLK_DEV_OFFBOARD is not set
 # CONFIG_IDEDMA_PCI_AUTO is not set
 CONFIG_BLK_DEV_IDEDMA=3Dy
@@ -212,8 +217,8 @@
 # CONFIG_AEC62XX_TUNING is not set
 # CONFIG_BLK_DEV_ALI15X3 is not set
 # CONFIG_WDC_ALI15X3 is not set
-# CONFIG_BLK_DEV_AMD7409 is not set
-# CONFIG_AMD7409_OVERRIDE is not set
+# CONFIG_BLK_DEV_AMD74XX is not set
+# CONFIG_AMD74XX_OVERRIDE is not set
 # CONFIG_BLK_DEV_CMD64X is not set
 # CONFIG_BLK_DEV_CY82C693 is not set
 # CONFIG_BLK_DEV_CS5530 is not set
@@ -226,7 +231,8 @@
 # CONFIG_BLK_DEV_OPTI621 is not set
 # CONFIG_BLK_DEV_PDC202XX is not set
 # CONFIG_PDC202XX_BURST is not set
-# CONFIG_BLK_DEV_OSB4 is not set
+# CONFIG_PDC202XX_FORCE is not set
+# CONFIG_BLK_DEV_SVWKS is not set
 # CONFIG_BLK_DEV_SIS5513 is not set
 # CONFIG_BLK_DEV_SLC90E66 is not set
 # CONFIG_BLK_DEV_TRM290 is not set
@@ -236,6 +242,9 @@
 # CONFIG_IDEDMA_IVB is not set
 # CONFIG_DMA_NONPCI is not set
 CONFIG_BLK_DEV_IDE_MODES=3Dy
+# CONFIG_BLK_DEV_ATARAID is not set
+# CONFIG_BLK_DEV_ATARAID_PDC is not set
+# CONFIG_BLK_DEV_ATARAID_HPT is not set
=20
 #
 # SCSI support
@@ -271,6 +280,7 @@
 # CONFIG_SCSI_AHA1740 is not set
 # CONFIG_SCSI_AIC7XXX is not set
 # CONFIG_SCSI_AIC7XXX_OLD is not set
+# CONFIG_SCSI_DPT_I2O is not set
 # CONFIG_SCSI_ADVANSYS is not set
 # CONFIG_SCSI_IN2000 is not set
 # CONFIG_SCSI_AM53C974 is not set
@@ -288,6 +298,7 @@
 # CONFIG_SCSI_INITIO is not set
 # CONFIG_SCSI_INIA100 is not set
 # CONFIG_SCSI_NCR53C406A is not set
+# CONFIG_SCSI_NCR_D700 is not set
 # CONFIG_SCSI_NCR53C7xx is not set
 # CONFIG_SCSI_NCR53C8XX is not set
 # CONFIG_SCSI_SYM53C8XX is not set
@@ -325,7 +336,6 @@
 # Ethernet (10 or 100Mbit)
 #
 CONFIG_NET_ETHERNET=3Dy
-# CONFIG_ARM_AM79C961A is not set
 # CONFIG_SUNLANCE is not set
 # CONFIG_HAPPYMEAL is not set
 # CONFIG_SUNBMAC is not set
@@ -344,8 +354,6 @@
 # CONFIG_APRICOT is not set
 # CONFIG_CS89x0 is not set
 # CONFIG_TULIP is not set
-# CONFIG_TULIP_MWI is not set
-# CONFIG_TULIP_MMIO is not set
 # CONFIG_DE4X5 is not set
 # CONFIG_DGRS is not set
 # CONFIG_DM9102 is not set
@@ -366,15 +374,16 @@
 # CONFIG_TLAN is not set
 # CONFIG_VIA_RHINE is not set
 # CONFIG_WINBOND_840 is not set
+# CONFIG_LAN_SAA9730 is not set
 # CONFIG_NET_POCKET is not set
=20
 #
 # Ethernet (1000 Mbit)
 #
 # CONFIG_ACENIC is not set
-# CONFIG_ACENIC_OMIT_TIGON_I is not set
 # CONFIG_DL2K is not set
 # CONFIG_MYRI_SBUS is not set
+# CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
 # CONFIG_SK98LIN is not set
@@ -457,11 +466,37 @@
 #
 # Joysticks
 #
-# CONFIG_JOYSTICK is not set
+# CONFIG_INPUT_GAMEPORT is not set
+# CONFIG_INPUT_NS558 is not set
+# CONFIG_INPUT_LIGHTNING is not set
+# CONFIG_INPUT_PCIGAME is not set
+# CONFIG_INPUT_CS461X is not set
+# CONFIG_INPUT_EMU10K1 is not set
+CONFIG_INPUT_SERIO=3Dy
+CONFIG_INPUT_SERPORT=3Dy
=20
 #
-# Input core support is needed for joysticks
+# Joysticks
 #
+# CONFIG_INPUT_ANALOG is not set
+# CONFIG_INPUT_A3D is not set
+# CONFIG_INPUT_ADI is not set
+# CONFIG_INPUT_COBRA is not set
+# CONFIG_INPUT_GF2K is not set
+# CONFIG_INPUT_GRIP is not set
+# CONFIG_INPUT_INTERACT is not set
+# CONFIG_INPUT_TMDC is not set
+# CONFIG_INPUT_SIDEWINDER is not set
+# CONFIG_INPUT_IFORCE_USB is not set
+# CONFIG_INPUT_IFORCE_232 is not set
+# CONFIG_INPUT_WARRIOR is not set
+# CONFIG_INPUT_MAGELLAN is not set
+# CONFIG_INPUT_SPACEORB is not set
+# CONFIG_INPUT_SPACEBALL is not set
+# CONFIG_INPUT_STINGER is not set
+# CONFIG_INPUT_DB9 is not set
+# CONFIG_INPUT_GAMECON is not set
+# CONFIG_INPUT_TURBOGRAFX is not set
 # CONFIG_QIC02_TAPE is not set
=20
 #
@@ -484,21 +519,21 @@
 CONFIG_AGP=3Dy
 # CONFIG_AGP_INTEL is not set
 CONFIG_AGP_I460=3Dy
-# CONFIG_AGP_I460_FULLRQ is not set
 # CONFIG_AGP_I810 is not set
 # CONFIG_AGP_VIA is not set
 # CONFIG_AGP_AMD is not set
 # CONFIG_AGP_SIS is not set
 # CONFIG_AGP_ALI is not set
 # CONFIG_AGP_SWORKS is not set
-CONFIG_AGP_PTE_FIXUPS=3Dy
 CONFIG_DRM=3Dy
-CONFIG_DRM_TDFX=3Dy
-# CONFIG_DRM_GAMMA is not set
-# CONFIG_DRM_R128 is not set
-# CONFIG_DRM_RADEON is not set
-# CONFIG_DRM_I810 is not set
-# CONFIG_DRM_MGA is not set
+# CONFIG_DRM_NEW is not set
+CONFIG_DRM_OLD=3Dy
+CONFIG_DRM40_TDFX=3Dy
+# CONFIG_DRM40_GAMMA is not set
+# CONFIG_DRM40_R128 is not set
+# CONFIG_DRM40_RADEON is not set
+# CONFIG_DRM40_I810 is not set
+# CONFIG_DRM40_MGA is not set
=20
 #
 # Multimedia devices
@@ -612,8 +647,23 @@
 #
 # Partition Types
 #
-# CONFIG_PARTITION_ADVANCED is not set
+CONFIG_PARTITION_ADVANCED=3Dy
+# CONFIG_ACORN_PARTITION is not set
+# CONFIG_OSF_PARTITION is not set
+# CONFIG_AMIGA_PARTITION is not set
+# CONFIG_ATARI_PARTITION is not set
+# CONFIG_MAC_PARTITION is not set
 CONFIG_MSDOS_PARTITION=3Dy
+# CONFIG_BSD_DISKLABEL is not set
+# CONFIG_MINIX_SUBPARTITION is not set
+# CONFIG_SOLARIS_X86_PARTITION is not set
+# CONFIG_UNIXWARE_DISKLABEL is not set
+CONFIG_EFI_PARTITION=3Dy
+# CONFIG_DEVFS_GUID is not set
+# CONFIG_LDM_PARTITION is not set
+# CONFIG_SGI_PARTITION is not set
+# CONFIG_ULTRIX_PARTITION is not set
+# CONFIG_SUN_PARTITION is not set
 # CONFIG_SMB_NLS is not set
 CONFIG_NLS=3Dy
=20
@@ -672,8 +722,10 @@
 # Sound
 #
 CONFIG_SOUND=3Dy
+# CONFIG_SOUND_BT878 is not set
 # CONFIG_SOUND_CMPCI is not set
 # CONFIG_SOUND_EMU10K1 is not set
+# CONFIG_MIDI_EMU10K1 is not set
 # CONFIG_SOUND_FUSION is not set
 CONFIG_SOUND_CS4281=3Dy
 # CONFIG_SOUND_ES1370 is not set
@@ -682,6 +734,7 @@
 # CONFIG_SOUND_MAESTRO is not set
 # CONFIG_SOUND_MAESTRO3 is not set
 # CONFIG_SOUND_ICH is not set
+# CONFIG_SOUND_RME96XX is not set
 # CONFIG_SOUND_SONICVIBES is not set
 # CONFIG_SOUND_TRIDENT is not set
 # CONFIG_SOUND_MSNDCLAS is not set
@@ -747,10 +800,11 @@
 #
 # USB Network adaptors
 #
-# CONFIG_USB_PLUSB is not set
 # CONFIG_USB_PEGASUS is not set
 # CONFIG_USB_CATC is not set
-# CONFIG_USB_NET1080 is not set
+# CONFIG_USB_CDCETHER is not set
+# CONFIG_USB_KAWETH is not set
+# CONFIG_USB_USBNET is not set
=20
 #
 # USB port drivers
@@ -775,11 +829,11 @@
 #
 # Kernel hacking
 #
-CONFIG_IA32_SUPPORT=3Dy
-CONFIG_MATHEMU=3Dy
+CONFIG_DEBUG_KERNEL=3Dy
+CONFIG_IA64_PRINT_HAZARDS=3Dy
+# CONFIG_DISABLE_VHPT is not set
 CONFIG_MAGIC_SYSRQ=3Dy
-CONFIG_IA64_EARLY_PRINTK=3Dy
+# CONFIG_DEBUG_SLAB is not set
+# CONFIG_DEBUG_SPINLOCK is not set
 # CONFIG_IA64_DEBUG_CMPXCHG is not set
 # CONFIG_IA64_DEBUG_IRQ is not set
-CONFIG_IA64_PRINT_HAZARDS=3Dy
-# CONFIG_DISABLE_VHPT is not set
diff -urN linux-davidm/arch/ia64/ia32/binfmt_elf32.c linux-2.4.10-lia/arch/=
ia64/ia32/binfmt_elf32.c
--- linux-davidm/arch/ia64/ia32/binfmt_elf32.c	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/ia32/binfmt_elf32.c	Mon Sep 24 21:43:45 2001
@@ -3,10 +3,11 @@
  *
  * Copyright (C) 1999 Arun Sharma <arun.sharma@intel.com>
  * Copyright (C) 2001 Hewlett-Packard Co
- * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * 06/16/00	A. Mallick	initialize csd/ssd/tssd/cflg for ia32_load_state
  * 04/13/01	D. Mosberger	dropped saving tssd in ar.k1---it's not needed
+ * 09/14/01	D. Mosberger	fixed memory management for gdt/tss page
  */
 #include <linux/config.h>
=20
@@ -41,51 +42,32 @@
 extern void ia64_elf32_init (struct pt_regs *regs);
 extern void put_dirty_page (struct task_struct * tsk, struct page *page, u=
nsigned long address);
=20
+static void elf32_set_personality (void);
+
 #define ELF_PLAT_INIT(_r)		ia64_elf32_init(_r)
 #define setup_arg_pages(bprm)		ia32_setup_arg_pages(bprm)
-#define elf_map				elf_map32
+#define elf_map				elf32_map
+#define SET_PERSONALITY(ex, ibcs2)	elf32_set_personality()
=20
 /* Ugly but avoids duplication */
 #include "../../../fs/binfmt_elf.c"
=20
-/* Global descriptor table */
-unsigned long *ia32_gdt_table, *ia32_tss;
+extern struct page *ia32_shared_page[];
+extern unsigned long *ia32_gdt;
=20
 struct page *
-put_shared_page (struct task_struct * tsk, struct page *page, unsigned lon=
g address)
+ia32_install_shared_page (struct vm_area_struct *vma, unsigned long addres=
s, int no_share)
 {
-	pgd_t * pgd;
-	pmd_t * pmd;
-	pte_t * pte;
-
-	if (page_count(page) !=3D 1)
-		printk("mem_map disagrees with %p at %08lx\n", (void *) page, address);
+	struct page *pg =3D ia32_shared_page[(address - vma->vm_start)/PAGE_SIZE];
=20
-	pgd =3D pgd_offset(tsk->mm, address);
-
-	spin_lock(&tsk->mm->page_table_lock);
-	{
-		pmd =3D pmd_alloc(tsk->mm, pgd, address);
-		if (!pmd)
-			goto out;
-		pte =3D pte_alloc(tsk->mm, pmd, address);
-		if (!pte)
-			goto out;
-		if (!pte_none(*pte))
-			goto out;
-		flush_page_to_ram(page);
-		set_pte(pte, pte_mkwrite(mk_pte(page, PAGE_SHARED)));
-	}
-	spin_unlock(&tsk->mm->page_table_lock);
-	/* no need for flush_tlb */
-	return page;
-
-  out:
-	spin_unlock(&tsk->mm->page_table_lock);
-	__free_page(page);
-	return 0;
+	get_page(pg);
+	return pg;
 }
=20
+static struct vm_operations_struct ia32_shared_page_vm_ops =3D {
+	nopage:	ia32_install_shared_page
+};
+
 void
 ia64_elf32_init (struct pt_regs *regs)
 {
@@ -97,9 +79,23 @@
 	 * it with privilege level 3 because the IVE uses non-privileged accesses=
 to these
 	 * tables.  IA-32 segmentation is used to protect against IA-32 accesses =
to them.
 	 */
-	put_shared_page(current, virt_to_page(ia32_gdt_table), IA32_GDT_OFFSET);
-	if (PAGE_SHIFT <=3D IA32_PAGE_SHIFT)
-		put_shared_page(current, virt_to_page(ia32_tss), IA32_TSS_OFFSET);
+	vma =3D kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	if (vma) {
+		vma->vm_mm =3D current->mm;
+		vma->vm_start =3D IA32_GDT_OFFSET;
+		vma->vm_end =3D vma->vm_start + max(PAGE_SIZE, 2*IA32_PAGE_SIZE);
+		vma->vm_page_prot =3D PAGE_SHARED;
+		vma->vm_flags =3D VM_READ|VM_MAYREAD;
+		vma->vm_ops =3D &ia32_shared_page_vm_ops;
+		vma->vm_pgoff =3D 0;
+		vma->vm_file =3D NULL;
+		vma->vm_private_data =3D NULL;
+		down_write(&current->mm->mmap_sem);
+		{
+			insert_vm_struct(current->mm, vma);
+		}
+		up_write(&current->mm->mmap_sem);
+	}
=20
 	/*
 	 * Install LDT as anonymous memory.  This gives us all-zero segment descr=
iptors
@@ -116,25 +112,25 @@
 		vma->vm_pgoff =3D 0;
 		vma->vm_file =3D NULL;
 		vma->vm_private_data =3D NULL;
-		insert_vm_struct(current->mm, vma);
+		down_write(&current->mm->mmap_sem);
+		{
+			insert_vm_struct(current->mm, vma);
+		}
+		up_write(&current->mm->mmap_sem);
 	}
=20
 	nr =3D smp_processor_id();
=20
-	current->thread.map_base  =3D IA32_PAGE_OFFSET/3;
-	current->thread.task_size =3D IA32_PAGE_OFFSET;	/* use what Linux/x86 use=
s... */
-	set_fs(USER_DS);				/* set addr limit for new TASK_SIZE */
-
 	/* Setup the segment selectors */
 	regs->r16 =3D (__USER_DS << 16) | __USER_DS; /* ES =3D DS, GS, FS are zer=
o */
 	regs->r17 =3D (__USER_DS << 16) | __USER_CS; /* SS, CS; ia32_load_state()=
 sets TSS and LDT */
=20
 	/* Setup the segment descriptors */
-	regs->r24 =3D IA32_SEG_UNSCRAMBLE(ia32_gdt_table[__USER_DS >> 3]);	/* ESD=
 */
-	regs->r27 =3D IA32_SEG_UNSCRAMBLE(ia32_gdt_table[__USER_DS >> 3]);	/* DSD=
 */
+	regs->r24 =3D IA32_SEG_UNSCRAMBLE(ia32_gdt[__USER_DS >> 3]);		/* ESD */
+	regs->r27 =3D IA32_SEG_UNSCRAMBLE(ia32_gdt[__USER_DS >> 3]);		/* DSD */
 	regs->r28 =3D 0;								/* FSD (null) */
 	regs->r29 =3D 0;								/* GSD (null) */
-	regs->r30 =3D IA32_SEG_UNSCRAMBLE(ia32_gdt_table[_LDT(nr)]);		/* LDTD */
+	regs->r30 =3D IA32_SEG_UNSCRAMBLE(ia32_gdt[_LDT(nr)]);			/* LDTD */
=20
 	/*
 	 * Setup GDTD.  Note: GDTD is the descrambled version of the pseudo-descr=
iptor
@@ -164,9 +160,9 @@
 	current->thread.fcr =3D IA32_FCR_DEFAULT;
 	current->thread.fir =3D 0;
 	current->thread.fdr =3D 0;
-	current->thread.csd =3D IA32_SEG_UNSCRAMBLE(ia32_gdt_table[__USER_CS >> 3=
]);
-	current->thread.ssd =3D IA32_SEG_UNSCRAMBLE(ia32_gdt_table[__USER_DS >> 3=
]);
-	current->thread.tssd =3D IA32_SEG_UNSCRAMBLE(ia32_gdt_table[_TSS(nr)]);
+	current->thread.csd =3D IA32_SEG_UNSCRAMBLE(ia32_gdt[__USER_CS >> 3]);
+	current->thread.ssd =3D IA32_SEG_UNSCRAMBLE(ia32_gdt[__USER_DS >> 3]);
+	current->thread.tssd =3D IA32_SEG_UNSCRAMBLE(ia32_gdt[_TSS(nr)]);
=20
 	ia32_load_state(current);
 }
@@ -189,6 +185,7 @@
 	if (!mpnt)
 		return -ENOMEM;
=20
+	down_write(&current->mm->mmap_sem);
 	{
 		mpnt->vm_mm =3D current->mm;
 		mpnt->vm_start =3D PAGE_MASK & (unsigned long) bprm->p;
@@ -204,54 +201,32 @@
 	}
=20
 	for (i =3D 0 ; i < MAX_ARG_PAGES ; i++) {
-		if (bprm->page[i]) {
-			put_dirty_page(current,bprm->page[i],stack_base);
+		struct page *page =3D bprm->page[i];
+		if (page) {
+			bprm->page[i] =3D NULL;
+			put_dirty_page(current, page, stack_base);
 		}
 		stack_base +=3D PAGE_SIZE;
 	}
+	up_write(&current->mm->mmap_sem);
=20
 	return 0;
 }
=20
-static unsigned long
-ia32_mm_addr (unsigned long addr)
+static void
+elf32_set_personality (void)
 {
-	struct vm_area_struct *vma;
-
-	if ((vma =3D find_vma(current->mm, addr)) =3D NULL)
-		return ELF_PAGESTART(addr);
-	if (vma->vm_start > addr)
-		return ELF_PAGESTART(addr);
-	return ELF_PAGEALIGN(addr);
+	set_personality(PER_LINUX32);
+	current->thread.map_base  =3D IA32_PAGE_OFFSET/3;
+	current->thread.task_size =3D IA32_PAGE_OFFSET;	/* use what Linux/x86 use=
s... */
+	set_fs(USER_DS);				/* set addr limit for new TASK_SIZE */
 }
=20
-/*
- *  Normally we would do an `mmap' to map in the process's text section.
- *  This doesn't work with IA32 processes as the ELF file might specify
- *  a non page size aligned address.  Instead we will just allocate
- *  memory and read the data in from the file.  Slightly less efficient
- *  but it works.
- */
-extern long ia32_do_mmap (struct file *filep, unsigned int len, unsigned i=
nt prot,
-			  unsigned int flags, unsigned int fd, unsigned int offset);
-
 static unsigned long
-elf_map32 (struct file *filep, unsigned long addr, struct elf_phdr *eppnt,=
 int prot, int type)
+elf32_map (struct file *filep, unsigned long addr, struct elf_phdr *eppnt,=
 int prot, int type)
 {
-	unsigned long retval;
-
-	if (eppnt->p_memsz >=3D (1UL<<32) || addr > (1UL<<32) - eppnt->p_memsz)
-		return -EINVAL;
+	unsigned long pgoff =3D (eppnt->p_vaddr) & ~IA32_PAGE_MASK;
=20
-	/*
-	 *  Make sure the elf interpreter doesn't get loaded at location 0
-	 *    so that NULL pointers correctly cause segfaults.
-	 */
-	if (addr =3D 0)
-		addr +=3D PAGE_SIZE;
-	set_brk(ia32_mm_addr(addr), addr + eppnt->p_memsz);
-	memset((char *) addr + eppnt->p_filesz, 0, eppnt->p_memsz - eppnt->p_file=
sz);
-	kernel_read(filep, eppnt->p_offset, (char *) addr, eppnt->p_filesz);
-	retval =3D (unsigned long) addr;
-	return retval;
+	return ia32_do_mmap(filep, (addr & IA32_PAGE_MASK), eppnt->p_filesz + pgo=
ff, prot, type,
+			    eppnt->p_offset - pgoff);
 }
diff -urN linux-davidm/arch/ia64/ia32/ia32_entry.S linux-2.4.10-lia/arch/ia=
64/ia32/ia32_entry.S
--- linux-davidm/arch/ia64/ia32/ia32_entry.S	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/ia32/ia32_entry.S	Mon Sep 24 21:44:23 2001
@@ -2,7 +2,7 @@
 #include <asm/offsets.h>
 #include <asm/signal.h>
=20
-#include "../kernel/entry.h"
+#include "../kernel/minstate.h"
=20
 	/*
 	 * execve() is special because in case of success, we need to
@@ -14,13 +14,13 @@
 	alloc loc1=3Dar.pfs,3,2,4,0
 	mov loc0=3Drp
 	.body
-	mov out0=3Din0			// filename
+	zxt4 out0=3Din0			// filename
 	;;				// stop bit between alloc and call
-	mov out1=3Din1			// argv
-	mov out2=3Din2			// envp
+	zxt4 out1=3Din1			// argv
+	zxt4 out2=3Din2			// envp
 	add out3=16,sp			// regs
 	br.call.sptk.few rp=3Dsys32_execve
-1:	cmp4.ge p6,p0=3Dr8,r0
+1:	cmp.ge p6,p0=3Dr8,r0
 	mov ar.pfs=3Dloc1			// restore ar.pfs
 	;;
 (p6)	mov ar.pfs=3Dr0			// clear ar.pfs in case of success
@@ -29,6 +29,25 @@
 	br.ret.sptk.few rp
 END(ia32_execve)
=20
+ENTRY(ia32_clone)
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2)
+	alloc r16=3Dar.pfs,2,2,4,0
+	DO_SAVE_SWITCH_STACK
+	mov loc0=3Drp
+	mov loc1=3Dr16				// save ar.pfs across do_fork
+	.body
+	zxt4 out1=3Din1				// newsp
+	mov out3=3D0				// stacksize
+	adds out2=3DIA64_SWITCH_STACK_SIZE+16,sp	// out2 =3D &regs
+	zxt4 out0=3Din0				// out0 =3D clone_flags
+	br.call.sptk.many rp=3Ddo_fork
+.ret0:	.restore sp
+	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// pop the switch stack
+	mov ar.pfs=3Dloc1
+	mov rp=3Dloc0
+	br.ret.sptk.many rp
+END(ia32_clone)
+
 	//
 	// Get possibly unaligned sigmask argument into an aligned
 	//   kernel buffer
@@ -38,7 +57,8 @@
 	// r32 is still the first argument which is the signal mask.
 	// We copy this 4-byte aligned value to an 8-byte aligned buffer
 	// in the task structure and then jump to the IA64 code.
-
+	zxt4 r32=3Dr32
+	;;
 	EX(.Lfail, ld4 r2=3D[r32],4)		// load low part of sigmask
 	;;
 	EX(.Lfail, ld4 r3=3D[r32])		// load high part of sigmask
@@ -54,6 +74,24 @@
 .Lfail:	br.ret.sptk.many rp	// failed to read sigmask
 END(ia32_rt_sigsuspend)
=20
+GLOBAL_ENTRY(ia32_ret_from_clone)
+	PT_REGS_UNWIND_INFO(0)
+	/*
+	 * We need to call schedule_tail() to complete the scheduling process.
+	 * Called by ia64_switch_to after do_fork()->copy_thread().  r8 contains =
the
+	 * address of the previously executing task.
+	 */
+	br.call.sptk.many rp=3Dia64_invoke_schedule_tail
+.ret1:	adds r2=3DIA64_TASK_PTRACE_OFFSET,r13
+	;;
+	ld8 r2=3D[r2]
+	;;
+	mov r8=3D0
+	tbit.nz p6,p0=3Dr2,PT_TRACESYS_BIT
+(p6)	br.cond.spnt .ia32_strace_check_retval
+	;;					// prevent RAW on r8
+END(ia32_ret_from_clone)
+	// fall thrugh
 GLOBAL_ENTRY(ia32_ret_from_syscall)
 	PT_REGS_UNWIND_INFO(0)
=20
@@ -77,15 +115,20 @@
 	//
 GLOBAL_ENTRY(ia32_trace_syscall)
 	PT_REGS_UNWIND_INFO(0)
+	mov r3=3D-38
+	adds r2=3DIA64_PT_REGS_R8_OFFSET+16,sp
+	;;
+	st8 [r2]=3Dr3				// initialize return code to -ENOSYS
 	br.call.sptk.few rp=3Dinvoke_syscall_trace // give parent a chance to cat=
ch syscall args
-.ret0:	br.call.sptk.few rp=B6			// do the syscall
-.ret1:	cmp.lt p6,p0=3Dr8,r0			// syscall failed?
+.ret2:	br.call.sptk.few rp=B6			// do the syscall
+.ia32_strace_check_retval:
+	cmp.lt p6,p0=3Dr8,r0			// syscall failed?
 	adds r2=3DIA64_PT_REGS_R8_OFFSET+16,sp	// r2 =3D &pt_regs.r8
 	;;
 	st8.spill [r2]=3Dr8			// store return value in slot for r8
 	br.call.sptk.few rp=3Dinvoke_syscall_trace // give parent a chance to cat=
ch return value
-.ret2:	alloc r2=3Dar.pfs,0,0,0,0			// drop the syscall argument frame
-	br.cond.sptk.many ia64_leave_kernel	// rp MUST be !=3D ia64_leave_kernel!
+.ret4:	alloc r2=3Dar.pfs,0,0,0,0			// drop the syscall argument frame
+	br.cond.sptk.many ia64_leave_kernel
 END(ia32_trace_syscall)
=20
 GLOBAL_ENTRY(sys32_vfork)
@@ -110,7 +153,7 @@
 	mov out3=3D0
 	adds out2=3DIA64_SWITCH_STACK_SIZE+16,sp	// out2 =3D &regs
 	br.call.sptk.few rp=3Ddo_fork
-.ret3:	mov ar.pfs=3Dloc1
+.ret5:	mov ar.pfs=3Dloc1
 	.restore sp
 	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// pop the switch stack
 	mov rp=3Dloc0
@@ -137,21 +180,21 @@
 	data8 sys32_time
 	data8 sys_mknod
 	data8 sys_chmod		  /* 15 */
-	data8 sys_lchown
+	data8 sys_lchown	/* 16-bit version */
 	data8 sys32_ni_syscall	  /* old break syscall holder */
 	data8 sys32_ni_syscall
 	data8 sys32_lseek
 	data8 sys_getpid	  /* 20 */
 	data8 sys_mount
 	data8 sys_oldumount
-	data8 sys_setuid
-	data8 sys_getuid
+	data8 sys_setuid	/* 16-bit version */
+	data8 sys_getuid	/* 16-bit version */
 	data8 sys32_ni_syscall /* sys_stime is not supported on IA64 */  /* 25 */
 	data8 sys32_ptrace
 	data8 sys32_alarm
 	data8 sys32_ni_syscall
-	data8 sys_pause
-	data8 ia32_utime	  /* 30 */
+	data8 sys32_pause
+	data8 sys32_utime	  /* 30 */
 	data8 sys32_ni_syscall	  /* old stty syscall holder */
 	data8 sys32_ni_syscall	  /* old gtty syscall holder */
 	data8 sys_access
@@ -167,15 +210,15 @@
 	data8 sys32_times
 	data8 sys32_ni_syscall	  /* old prof syscall holder */
 	data8 sys_brk		  /* 45 */
-	data8 sys_setgid
-	data8 sys_getgid
+	data8 sys_setgid	/* 16-bit version */
+	data8 sys_getgid	/* 16-bit version */
 	data8 sys32_signal
-	data8 sys_geteuid
-	data8 sys_getegid	  /* 50 */
+	data8 sys_geteuid	/* 16-bit version */
+	data8 sys_getegid	/* 16-bit version */	  /* 50 */
 	data8 sys_acct
 	data8 sys_umount	  /* recycled never used phys( */
 	data8 sys32_ni_syscall	  /* old lock syscall holder */
-	data8 ia32_ioctl
+	data8 sys32_ioctl
 	data8 sys32_fcntl	  /* 55 */
 	data8 sys32_ni_syscall	  /* old mpx syscall holder */
 	data8 sys_setpgid
@@ -191,19 +234,19 @@
 	data8 sys32_sigaction
 	data8 sys32_ni_syscall
 	data8 sys32_ni_syscall
-	data8 sys_setreuid	  /* 70 */
-	data8 sys_setregid
+	data8 sys_setreuid	/* 16-bit version */	  /* 70 */
+	data8 sys_setregid	/* 16-bit version */
 	data8 sys32_ni_syscall
-	data8 sys_sigpending
+	data8 sys32_sigpending
 	data8 sys_sethostname
 	data8 sys32_setrlimit	  /* 75 */
-	data8 sys32_getrlimit
+	data8 sys32_old_getrlimit
 	data8 sys32_getrusage
 	data8 sys32_gettimeofday
 	data8 sys32_settimeofday
-	data8 sys_getgroups	  /* 80 */
-	data8 sys_setgroups
-	data8 old_select
+	data8 sys32_getgroups16	  /* 80 */
+	data8 sys32_setgroups16
+	data8 sys32_old_select
 	data8 sys_symlink
 	data8 sys32_ni_syscall
 	data8 sys_readlink	  /* 85 */
@@ -212,17 +255,17 @@
 	data8 sys_reboot
 	data8 sys32_readdir
 	data8 sys32_mmap	  /* 90 */
-	data8 sys_munmap
+	data8 sys32_munmap
 	data8 sys_truncate
 	data8 sys_ftruncate
 	data8 sys_fchmod
-	data8 sys_fchown	  /* 95 */
+	data8 sys_fchown	/* 16-bit version */	  /* 95 */
 	data8 sys_getpriority
 	data8 sys_setpriority
 	data8 sys32_ni_syscall	  /* old profil syscall holder */
 	data8 sys32_statfs
 	data8 sys32_fstatfs	  /* 100 */
-	data8 sys_ioperm
+	data8 sys32_ioperm
 	data8 sys32_socketcall
 	data8 sys_syslog
 	data8 sys32_setitimer
@@ -231,36 +274,36 @@
 	data8 sys32_newlstat
 	data8 sys32_newfstat
 	data8 sys32_ni_syscall
-	data8 sys_iopl		  /* 110 */
+	data8 sys32_iopl		  /* 110 */
 	data8 sys_vhangup
 	data8 sys32_ni_syscall		/* used to be sys_idle */
 	data8 sys32_ni_syscall
 	data8 sys32_wait4
 	data8 sys_swapoff	  /* 115 */
-	data8 sys_sysinfo
+	data8 sys32_sysinfo
 	data8 sys32_ipc
 	data8 sys_fsync
 	data8 sys32_sigreturn
-	data8 sys_clone		  /* 120 */
+	data8 ia32_clone	  /* 120 */
 	data8 sys_setdomainname
 	data8 sys32_newuname
 	data8 sys32_modify_ldt
-	data8 sys_adjtimex
+	data8 sys32_ni_syscall	/* adjtimex */
 	data8 sys32_mprotect	  /* 125 */
-	data8 sys_sigprocmask
-	data8 sys_create_module
-	data8 sys_init_module
-	data8 sys_delete_module
-	data8 sys_get_kernel_syms  /* 130 */
-	data8 sys_quotactl
+	data8 sys32_sigprocmask
+	data8 sys32_ni_syscall	/* create_module */
+	data8 sys32_ni_syscall	/* init_module */
+	data8 sys32_ni_syscall	/* delete_module */
+	data8 sys32_ni_syscall	/* get_kernel_syms */  /* 130 */
+	data8 sys32_quotactl
 	data8 sys_getpgid
 	data8 sys_fchdir
-	data8 sys_bdflush
-	data8 sys_sysfs		  /* 135 */
-	data8 sys_personality
+	data8 sys32_ni_syscall	/* sys_bdflush */
+	data8 sys_sysfs		/* 135 */
+	data8 sys32_personality
 	data8 sys32_ni_syscall	  /* for afs_syscall */
-	data8 sys_setfsuid
-	data8 sys_setfsgid
+	data8 sys_setfsuid	/* 16-bit version */
+	data8 sys_setfsgid	/* 16-bit version */
 	data8 sys_llseek	  /* 140 */
 	data8 sys32_getdents
 	data8 sys32_select
@@ -282,68 +325,68 @@
 	data8 sys_sched_yield
 	data8 sys_sched_get_priority_max
 	data8 sys_sched_get_priority_min	 /* 160 */
-	data8 sys_sched_rr_get_interval
+	data8 sys32_sched_rr_get_interval
 	data8 sys32_nanosleep
 	data8 sys_mremap
-	data8 sys_setresuid
-	data8 sys32_getresuid	  /* 165 */
-	data8 sys_vm86
-	data8 sys_query_module
+	data8 sys_setresuid	/* 16-bit version */
+	data8 sys32_getresuid16	/* 16-bit version */	  /* 165 */
+	data8 sys32_ni_syscall	/* vm86 */
+	data8 sys32_ni_syscall	/* sys_query_module */
 	data8 sys_poll
-	data8 sys_nfsservctl
+	data8 sys32_ni_syscall	/* nfsservctl */
 	data8 sys_setresgid	  /* 170 */
-	data8 sys32_getresgid
+	data8 sys32_getresgid16
 	data8 sys_prctl
 	data8 sys32_rt_sigreturn
 	data8 sys32_rt_sigaction
 	data8 sys32_rt_sigprocmask /* 175 */
 	data8 sys_rt_sigpending
-	data8 sys_rt_sigtimedwait
-	data8 sys_rt_sigqueueinfo
+	data8 sys32_rt_sigtimedwait
+	data8 sys32_rt_sigqueueinfo
 	data8 ia32_rt_sigsuspend
-	data8 sys_pread		  /* 180 */
-	data8 sys_pwrite
-	data8 sys_chown
+	data8 sys32_pread	  /* 180 */
+	data8 sys32_pwrite
+	data8 sys_chown	/* 16-bit version */
 	data8 sys_getcwd
 	data8 sys_capget
 	data8 sys_capset	  /* 185 */
 	data8 sys32_sigaltstack
-	data8 sys_sendfile
+	data8 sys32_sendfile
 	data8 sys32_ni_syscall		  /* streams1 */
 	data8 sys32_ni_syscall		  /* streams2 */
 	data8 sys32_vfork	  /* 190 */
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall	  /* 195 */
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall	  /* 200 */
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall	  /* 205 */
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall	  /* 210 */
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall	  /* 215 */
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall	  /* 220 */
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
+	data8 sys32_getrlimit
+	data8 sys32_mmap2
+	data8 sys32_truncate64
+	data8 sys32_ftruncate64
+	data8 sys32_stat64	  /* 195 */
+	data8 sys32_lstat64
+	data8 sys32_fstat64
+	data8 sys_lchown
+	data8 sys_getuid
+	data8 sys_getgid	  /* 200 */
+	data8 sys_geteuid
+	data8 sys_getegid
+	data8 sys_setreuid
+	data8 sys_setregid
+	data8 sys_getgroups	  /* 205 */
+	data8 sys_setgroups
+	data8 sys_fchown
+	data8 sys_setresuid
+	data8 sys_getresuid
+	data8 sys_setresgid	  /* 210 */
+	data8 sys_getresgid
+	data8 sys_chown
+	data8 sys_setuid
+	data8 sys_setgid
+	data8 sys_setfsuid	  /* 215 */
+	data8 sys_setfsgid
+	data8 sys_pivot_root
+	data8 sys_mincore
+	data8 sys_madvise
+	data8 sys_getdents64	  /* 220 */
+	data8 sys32_fcntl64
+	data8 sys_ni_syscall	  /* reserved for TUX */
 	/*
 	 *  CAUTION: If any system calls are added beyond this point
 	 *	then the check in `arch/ia64/kernel/ivt.S' will have
diff -urN linux-davidm/arch/ia64/ia32/ia32_ioctl.c linux-2.4.10-lia/arch/ia=
64/ia32/ia32_ioctl.c
--- linux-davidm/arch/ia64/ia32/ia32_ioctl.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/ia32/ia32_ioctl.c	Mon Sep 24 21:44:39 2001
@@ -36,12 +36,13 @@
 	_ret;						\
 })
=20
-#define P(i)	((void *)(long)(i))
+#define P(i)	((void *)(unsigned long)(i))
=20
=20
 asmlinkage long sys_ioctl(unsigned int fd, unsigned int cmd, unsigned long=
 arg);
=20
-asmlinkage long ia32_ioctl(unsigned int fd, unsigned int cmd, unsigned int=
 arg)
+asmlinkage long
+sys32_ioctl (unsigned int fd, unsigned int cmd, unsigned int arg)
 {
 	long ret;
=20
@@ -81,7 +82,7 @@
 				if (copy_to_user(P(arg), &ver32, sizeof(ver32)))
 					return -EFAULT;
 			}
-			return(ret);
+			return ret;
 		}
=20
 	case IOCTL_NR(DRM_IOCTL_GET_UNIQUE):
@@ -202,9 +203,9 @@
 	case IOCTL_NR(I2OHTML):
 		break;
 	default:
-		return(sys_ioctl(fd, cmd, (unsigned long)arg));
+		return sys_ioctl(fd, cmd, (unsigned long)arg);
=20
 	}
 	printk("%x:unimplemented IA32 ioctl system call\n", cmd);
-	return(-EINVAL);
+	return -EINVAL;
 }
diff -urN linux-davidm/arch/ia64/ia32/ia32_ldt.c linux-2.4.10-lia/arch/ia64=
/ia32/ia32_ldt.c
--- linux-davidm/arch/ia64/ia32/ia32_ldt.c	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/ia32/ia32_ldt.c	Mon Sep 24 21:44:52 2001
@@ -16,6 +16,8 @@
 #include <asm/uaccess.h>
 #include <asm/ia32.h>
=20
+#define P(p)	((void *) (unsigned long) (p))
+
 /*
  * read_ldt() is not really atomic - this is not a problem since synchroni=
zation of reads
  * and writes done to the LDT has to be assured by user-space anyway. Writ=
es are atomic,
@@ -101,19 +103,19 @@
 }
=20
 asmlinkage int
-sys32_modify_ldt (int func, void *ptr, unsigned int bytecount)
+sys32_modify_ldt (int func, unsigned int ptr, unsigned int bytecount)
 {
 	int ret =3D -ENOSYS;
=20
 	switch (func) {
 	      case 0:
-		ret =3D read_ldt(ptr, bytecount);
+		ret =3D read_ldt(P(ptr), bytecount);
 		break;
 	      case 1:
-		ret =3D write_ldt(ptr, bytecount, 1);
+		ret =3D write_ldt(P(ptr), bytecount, 1);
 		break;
 	      case 0x11:
-		ret =3D write_ldt(ptr, bytecount, 0);
+		ret =3D write_ldt(P(ptr), bytecount, 0);
 		break;
 	}
 	return ret;
diff -urN linux-davidm/arch/ia64/ia32/ia32_signal.c linux-2.4.10-lia/arch/i=
a64/ia32/ia32_signal.c
--- linux-davidm/arch/ia64/ia32/ia32_signal.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/ia32/ia32_signal.c	Mon Sep 24 21:45:00 2001
@@ -1,8 +1,8 @@
 /*
  * IA32 Architecture-specific signal handling support.
  *
- * Copyright (C) 1999 Hewlett-Packard Co
- * Copyright (C) 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999, 2001 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1999 Arun Sharma <arun.sharma@intel.com>
  * Copyright (C) 2000 VA Linux Co
  * Copyright (C) 2000 Don Dugger <n0ano@valinux.com>
@@ -13,6 +13,7 @@
 #include <linux/errno.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
+#include <linux/personality.h>
 #include <linux/ptrace.h>
 #include <linux/sched.h>
 #include <linux/signal.h>
@@ -31,6 +32,8 @@
 #define DEBUG_SIG	0
 #define _BLOCKABLE	(~(sigmask(SIGKILL) | sigmask(SIGSTOP)))
=20
+#define __IA32_NR_sigreturn            119
+#define __IA32_NR_rt_sigreturn         173
=20
 struct sigframe_ia32
 {
@@ -54,12 +57,51 @@
        char retcode[8];
 };
=20
-static int
+int
+copy_siginfo_from_user32 (siginfo_t *to, siginfo_t32 *from)
+{
+	unsigned long tmp;
+	int err;
+
+	if (!access_ok(VERIFY_READ, from, sizeof(siginfo_t32)))
+		return -EFAULT;
+
+	err =3D __get_user(to->si_signo, &from->si_signo);
+	err |=3D __get_user(to->si_errno, &from->si_errno);
+	err |=3D __get_user(to->si_code, &from->si_code);
+
+	if (from->si_code < 0)
+		err |=3D __copy_from_user(&to->_sifields._pad, &from->_sifields._pad, SI=
_PAD_SIZE);
+	else {
+		switch (from->si_code >> 16) {
+		      case __SI_CHLD >> 16:
+			err |=3D __get_user(to->si_utime, &from->si_utime);
+			err |=3D __get_user(to->si_stime, &from->si_stime);
+			err |=3D __get_user(to->si_status, &from->si_status);
+		      default:
+			err |=3D __get_user(to->si_pid, &from->si_pid);
+			err |=3D __get_user(to->si_uid, &from->si_uid);
+			break;
+		      case __SI_FAULT >> 16:
+			err |=3D __get_user(tmp, &from->si_addr);
+			to->si_addr =3D (void *) tmp;
+			break;
+		      case __SI_POLL >> 16:
+			err |=3D __get_user(to->si_band, &from->si_band);
+			err |=3D __get_user(to->si_fd, &from->si_fd);
+			break;
+			/* case __SI_RT: This is not generated by the kernel as of now.  */
+		}
+	}
+	return err;
+}
+
+int
 copy_siginfo_to_user32 (siginfo_t32 *to, siginfo_t *from)
 {
 	int err;
=20
-	if (!access_ok (VERIFY_WRITE, to, sizeof(siginfo_t32)))
+	if (!access_ok(VERIFY_WRITE, to, sizeof(siginfo_t32)))
 		return -EFAULT;
=20
 	/* If you change siginfo_t structure, please be sure
@@ -100,80 +142,81 @@
=20
=20
 static int
-setup_sigcontext_ia32(struct sigcontext_ia32 *sc, struct _fpstate_ia32 *fp=
state,
-                struct pt_regs *regs, unsigned long mask)
+setup_sigcontext_ia32 (struct sigcontext_ia32 *sc, struct _fpstate_ia32 *f=
pstate,
+		       struct pt_regs *regs, unsigned long mask)
 {
-       int  err =3D 0;
-       unsigned long flag;
+	int  err =3D 0;
+	unsigned long flag;
=20
-       err |=3D __put_user((regs->r16 >> 32) & 0xffff , (unsigned int *)&s=
c->fs);
-       err |=3D __put_user((regs->r16 >> 48) & 0xffff , (unsigned int *)&s=
c->gs);
+	err |=3D __put_user((regs->r16 >> 32) & 0xffff , (unsigned int *)&sc->fs);
+	err |=3D __put_user((regs->r16 >> 48) & 0xffff , (unsigned int *)&sc->gs);
=20
-       err |=3D __put_user((regs->r16 >> 56) & 0xffff, (unsigned int *)&sc=
->es);
-       err |=3D __put_user(regs->r16 & 0xffff, (unsigned int *)&sc->ds);
-       err |=3D __put_user(regs->r15, &sc->edi);
-       err |=3D __put_user(regs->r14, &sc->esi);
-       err |=3D __put_user(regs->r13, &sc->ebp);
-       err |=3D __put_user(regs->r12, &sc->esp);
-       err |=3D __put_user(regs->r11, &sc->ebx);
-       err |=3D __put_user(regs->r10, &sc->edx);
-       err |=3D __put_user(regs->r9, &sc->ecx);
-       err |=3D __put_user(regs->r8, &sc->eax);
+	err |=3D __put_user((regs->r16 >> 56) & 0xffff, (unsigned int *)&sc->es);
+	err |=3D __put_user(regs->r16 & 0xffff, (unsigned int *)&sc->ds);
+	err |=3D __put_user(regs->r15, &sc->edi);
+	err |=3D __put_user(regs->r14, &sc->esi);
+	err |=3D __put_user(regs->r13, &sc->ebp);
+	err |=3D __put_user(regs->r12, &sc->esp);
+	err |=3D __put_user(regs->r11, &sc->ebx);
+	err |=3D __put_user(regs->r10, &sc->edx);
+	err |=3D __put_user(regs->r9, &sc->ecx);
+	err |=3D __put_user(regs->r8, &sc->eax);
 #if 0
-       err |=3D __put_user(current->tss.trap_no, &sc->trapno);
-       err |=3D __put_user(current->tss.error_code, &sc->err);
+	err |=3D __put_user(current->tss.trap_no, &sc->trapno);
+	err |=3D __put_user(current->tss.error_code, &sc->err);
 #endif
-       err |=3D __put_user(regs->cr_iip, &sc->eip);
-       err |=3D __put_user(regs->r17 & 0xffff, (unsigned int *)&sc->cs);
-       /*
-	*  `eflags' is in an ar register for this context
-	*/
-       asm volatile ("mov %0=3Dar.eflag ;;" : "=3Dr"(flag));
-       err |=3D __put_user((unsigned int)flag, &sc->eflags);
-      =20
-       err |=3D __put_user(regs->r12, &sc->esp_at_signal);
-       err |=3D __put_user((regs->r17 >> 16) & 0xffff, (unsigned int *)&sc=
->ss);
+	err |=3D __put_user(regs->cr_iip, &sc->eip);
+	err |=3D __put_user(regs->r17 & 0xffff, (unsigned int *)&sc->cs);
+	/*
+	 *  `eflags' is in an ar register for this context
+	 */
+	asm volatile ("mov %0=3Dar.eflag ;;" : "=3Dr"(flag));
+	err |=3D __put_user((unsigned int)flag, &sc->eflags);
+	err |=3D __put_user(regs->r12, &sc->esp_at_signal);
+	err |=3D __put_user((regs->r17 >> 16) & 0xffff, (unsigned int *)&sc->ss);
=20
 #if 0
-       tmp =3D save_i387(fpstate);
-       if (tmp < 0)
-         err =3D 1;
-       else
-         err |=3D __put_user(tmp ? fpstate : NULL, &sc->fpstate);
+	tmp =3D save_i387(fpstate);
+	if (tmp < 0)
+		err =3D 1;
+	else
+		err |=3D __put_user(tmp ? fpstate : NULL, &sc->fpstate);
=20
-       /* non-iBCS2 extensions.. */
+	/* non-iBCS2 extensions.. */
 #endif
-       err |=3D __put_user(mask, &sc->oldmask);
+	err |=3D __put_user(mask, &sc->oldmask);
 #if 0
-       err |=3D __put_user(current->tss.cr2, &sc->cr2);
+	err |=3D __put_user(current->tss.cr2, &sc->cr2);
 #endif
-      =20
-       return err;
+	return err;
 }
=20
 static int
-restore_sigcontext_ia32(struct pt_regs *regs, struct sigcontext_ia32 *sc, =
int *peax)
+restore_sigcontext_ia32 (struct pt_regs *regs, struct sigcontext_ia32 *sc,=
 int *peax)
 {
        unsigned int err =3D 0;
=20
-#define COPY(ia64x, ia32x)             err |=3D __get_user(regs->ia64x, &s=
c->ia32x)
+#define COPY(ia64x, ia32x)	err |=3D __get_user(regs->ia64x, &sc->ia32x)
=20
-#define copyseg_gs(tmp)        (regs->r16 |=3D (unsigned long) tmp << 48)
-#define copyseg_fs(tmp)        (regs->r16 |=3D (unsigned long) tmp << 32)
-#define copyseg_cs(tmp)        (regs->r17 |=3D tmp)
-#define copyseg_ss(tmp)        (regs->r17 |=3D (unsigned long) tmp << 16)
-#define copyseg_es(tmp)        (regs->r16 |=3D (unsigned long) tmp << 16)
-#define copyseg_ds(tmp)        (regs->r16 |=3D tmp)
-
-#define COPY_SEG(seg)                                          \
-       { unsigned short tmp;                                   \
-         err |=3D __get_user(tmp, &sc->seg);                             \
-         copyseg_##seg(tmp); }
-
-#define COPY_SEG_STRICT(seg)                                   \
-       { unsigned short tmp;                                   \
-         err |=3D __get_user(tmp, &sc->seg);                             \
-         copyseg_##seg(tmp|3); }
+#define copyseg_gs(tmp)		(regs->r16 |=3D (unsigned long) tmp << 48)
+#define copyseg_fs(tmp)		(regs->r16 |=3D (unsigned long) tmp << 32)
+#define copyseg_cs(tmp)		(regs->r17 |=3D tmp)
+#define copyseg_ss(tmp)		(regs->r17 |=3D (unsigned long) tmp << 16)
+#define copyseg_es(tmp)		(regs->r16 |=3D (unsigned long) tmp << 16)
+#define copyseg_ds(tmp)		(regs->r16 |=3D tmp)
+
+#define COPY_SEG(seg)					\
+       {						\
+	       unsigned short tmp;			\
+	       err |=3D __get_user(tmp, &sc->seg);	\
+	       copyseg_##seg(tmp);			\
+       }
+#define COPY_SEG_STRICT(seg)				\
+       {						\
+	       unsigned short tmp;			\
+	       err |=3D __get_user(tmp, &sc->seg);	\
+	       copyseg_##seg(tmp|3);			\
+       }
=20
        /* To make COPY_SEGs easier, we zero r16, r17 */
        regs->r16 =3D 0;
@@ -198,9 +241,8 @@
 		unsigned long flag;
=20
 		/*
-		 *  IA32 `eflags' is not part of `pt_regs', it's
-		 *  in an ar register which is part of the thread
-		 *  context.  Fortunately, we are executing in the
+		 *  IA32 `eflags' is not part of `pt_regs', it's in an ar register which
+		 *  is part of the thread context.  Fortunately, we are executing in the
 		 *  IA32 process's context.
 		 */
 		err |=3D __get_user(tmpflags, &sc->eflags);
@@ -227,7 +269,7 @@
        err |=3D __get_user(*peax, &sc->eax);
        return err;
=20
-#if 0      =20
+#if 0
 badframe:
        return 1;
 #endif
@@ -238,158 +280,164 @@
  * Determine which stack to use..
  */
 static inline void *
-get_sigframe(struct k_sigaction *ka, struct pt_regs * regs, size_t frame_s=
ize)
+get_sigframe (struct k_sigaction *ka, struct pt_regs * regs, size_t frame_=
size)
 {
-       unsigned long esp;
-       unsigned int xss;
+	unsigned long esp;
=20
-       /* Default to using normal stack */
-       esp =3D regs->r12;
-       xss =3D regs->r16 >> 16;
-
-       /* This is the X/Open sanctioned signal stack switching.  */
-       if (ka->sa.sa_flags & SA_ONSTACK) {
-               if (! on_sig_stack(esp))
-                       esp =3D current->sas_ss_sp + current->sas_ss_size;
-       }
-       /* Legacy stack switching not supported */
-      =20
-       return (void *)((esp - frame_size) & -8ul);
+	/* Default to using normal stack (truncate off sign-extension of bit 31: =
*/
+	esp =3D (unsigned int) regs->r12;
+
+	/* This is the X/Open sanctioned signal stack switching.  */
+	if (ka->sa.sa_flags & SA_ONSTACK) {
+		if (!on_sig_stack(esp))
+			esp =3D current->sas_ss_sp + current->sas_ss_size;
+	}
+	/* Legacy stack switching not supported */
+
+	return (void *)((esp - frame_size) & -8ul);
 }
=20
 static int
-setup_frame_ia32(int sig, struct k_sigaction *ka, sigset_t *set,
-           struct pt_regs * regs)=20
-{     =20
-       struct sigframe_ia32 *frame;
-       int err =3D 0;
-
-       frame =3D get_sigframe(ka, regs, sizeof(*frame));
-
-       if (!access_ok(VERIFY_WRITE, frame, sizeof(*frame)))
-               goto give_sigsegv;
-
-       err |=3D __put_user((current->exec_domain
-                          && current->exec_domain->signal_invmap
-                          && sig < 32
-                          ? (int)(current->exec_domain->signal_invmap[sig])
-                          : sig),
-                         &frame->sig);
-
-       err |=3D setup_sigcontext_ia32(&frame->sc, &frame->fpstate, regs, s=
et->sig[0]);
-
-       if (_IA32_NSIG_WORDS > 1) {
-               err |=3D __copy_to_user(frame->extramask, (char *) &set->si=
g[1] + 4,
-                                     sizeof(frame->extramask));
-       }
+setup_frame_ia32 (int sig, struct k_sigaction *ka, sigset_t *set, struct p=
t_regs * regs)
+{
+	struct sigframe_ia32 *frame;
+	int err =3D 0;
=20
-       /* Set up to return from userspace.  If provided, use a stub
-          already in userspace.  */
-       err |=3D __put_user((long)frame->retcode, &frame->pretcode);
-       /* This is popl %eax ; movl $,%eax ; int $0x80 */
-       err |=3D __put_user(0xb858, (short *)(frame->retcode+0));
-#define __IA32_NR_sigreturn            119
-       err |=3D __put_user(__IA32_NR_sigreturn & 0xffff, (short *)(frame->=
retcode+2));
-       err |=3D __put_user(__IA32_NR_sigreturn >> 16, (short *)(frame->ret=
code+4));
-       err |=3D __put_user(0x80cd, (short *)(frame->retcode+6));
-
-       if (err)
-               goto give_sigsegv;
-
-       /* Set up registers for signal handler */
-       regs->r12 =3D (unsigned long) frame;
-       regs->cr_iip =3D (unsigned long) ka->sa.sa_handler;
-
-       set_fs(USER_DS);
-       regs->r16 =3D (__USER_DS << 16) |  (__USER_DS); /* ES =3D DS, GS, F=
S are zero */
-       regs->r17 =3D (__USER_DS << 16) | __USER_CS;
+	frame =3D get_sigframe(ka, regs, sizeof(*frame));
+
+	if (!access_ok(VERIFY_WRITE, frame, sizeof(*frame)))
+		goto give_sigsegv;
+
+	err |=3D __put_user((current->exec_domain
+			   && current->exec_domain->signal_invmap
+			   && sig < 32
+			   ? (int)(current->exec_domain->signal_invmap[sig])
+			   : sig),
+			  &frame->sig);
+
+	err |=3D setup_sigcontext_ia32(&frame->sc, &frame->fpstate, regs, set->si=
g[0]);
+
+	if (_IA32_NSIG_WORDS > 1)
+		err |=3D __copy_to_user(frame->extramask, (char *) &set->sig + 4,
+				      sizeof(frame->extramask));
+
+	/* Set up to return from userspace.  If provided, use a stub
+	   already in userspace.  */
+	if (ka->sa.sa_flags & SA_RESTORER) {
+		unsigned int restorer =3D IA32_SA_RESTORER(ka);
+		err |=3D __put_user(restorer, &frame->pretcode);
+	} else {
+		err |=3D __put_user((long)frame->retcode, &frame->pretcode);
+		/* This is popl %eax ; movl $,%eax ; int $0x80 */
+		err |=3D __put_user(0xb858, (short *)(frame->retcode+0));
+		err |=3D __put_user(__IA32_NR_sigreturn & 0xffff, (short *)(frame->retco=
de+2));
+		err |=3D __put_user(__IA32_NR_sigreturn >> 16, (short *)(frame->retcode+=
4));
+		err |=3D __put_user(0x80cd, (short *)(frame->retcode+6));
+	}
+
+	if (err)
+		goto give_sigsegv;
+
+	/* Set up registers for signal handler */
+	regs->r12 =3D (unsigned long) frame;
+	regs->cr_iip =3D IA32_SA_HANDLER(ka);
+
+	set_fs(USER_DS);
+	regs->r16 =3D (__USER_DS << 16) |  (__USER_DS); /* ES =3D DS, GS, FS are =
zero */
+	regs->r17 =3D (__USER_DS << 16) | __USER_CS;
=20
 #if 0
-       regs->eflags &=3D ~TF_MASK;
+	regs->eflags &=3D ~TF_MASK;
 #endif
=20
 #if 0
-       printk("SIG deliver (%s:%d): sig=3D%d sp=3D%p pc=3D%lx ra=3D%x\n",
+	printk("SIG deliver (%s:%d): sig=3D%d sp=3D%p pc=3D%lx ra=3D%x\n",
                current->comm, current->pid, sig, (void *) frame, regs->cr_=
iip, frame->pretcode);
 #endif
=20
-       return 1;
+	return 1;
=20
-give_sigsegv:
-       if (sig =3D SIGSEGV)
-               ka->sa.sa_handler =3D SIG_DFL;
-       force_sig(SIGSEGV, current);
-       return 0;
+  give_sigsegv:
+	if (sig =3D SIGSEGV)
+		ka->sa.sa_handler =3D SIG_DFL;
+	force_sig(SIGSEGV, current);
+	return 0;
 }
=20
 static int
-setup_rt_frame_ia32(int sig, struct k_sigaction *ka, siginfo_t *info,
-              sigset_t *set, struct pt_regs * regs)
+setup_rt_frame_ia32 (int sig, struct k_sigaction *ka, siginfo_t *info,
+		     sigset_t *set, struct pt_regs * regs)
 {
-       struct rt_sigframe_ia32 *frame;
-       int err =3D 0;
+	struct rt_sigframe_ia32 *frame;
+	int err =3D 0;
=20
-       frame =3D get_sigframe(ka, regs, sizeof(*frame));
+	frame =3D get_sigframe(ka, regs, sizeof(*frame));
=20
-       if (!access_ok(VERIFY_WRITE, frame, sizeof(*frame)))
-               goto give_sigsegv;
-
-       err |=3D __put_user((current->exec_domain
-                          && current->exec_domain->signal_invmap
-                          && sig < 32
-                          ? current->exec_domain->signal_invmap[sig]
-                          : sig),
-                         &frame->sig);
-       err |=3D __put_user((long)&frame->info, &frame->pinfo);
-       err |=3D __put_user((long)&frame->uc, &frame->puc);
-       err |=3D copy_siginfo_to_user32(&frame->info, info);
-
-       /* Create the ucontext.  */
-       err |=3D __put_user(0, &frame->uc.uc_flags);
-       err |=3D __put_user(0, &frame->uc.uc_link);
-       err |=3D __put_user(current->sas_ss_sp, &frame->uc.uc_stack.ss_sp);
-       err |=3D __put_user(sas_ss_flags(regs->r12),
-                         &frame->uc.uc_stack.ss_flags);
-       err |=3D __put_user(current->sas_ss_size, &frame->uc.uc_stack.ss_si=
ze);
-       err |=3D setup_sigcontext_ia32(&frame->uc.uc_mcontext, &frame->fpst=
ate,
-                               regs, set->sig[0]);
-       err |=3D __copy_to_user(&frame->uc.uc_sigmask, set, sizeof(*set));
-      =20
-       err |=3D __put_user((long)frame->retcode, &frame->pretcode);
-       /* This is movl $,%eax ; int $0x80 */
-       err |=3D __put_user(0xb8, (char *)(frame->retcode+0));
-#define __IA32_NR_rt_sigreturn         173
-       err |=3D __put_user(__IA32_NR_rt_sigreturn, (int *)(frame->retcode+=
1));
-       err |=3D __put_user(0x80cd, (short *)(frame->retcode+5));
+	if (!access_ok(VERIFY_WRITE, frame, sizeof(*frame)))
+		goto give_sigsegv;
+
+	err |=3D __put_user((current->exec_domain
+			   && current->exec_domain->signal_invmap
+			   && sig < 32
+			   ? current->exec_domain->signal_invmap[sig]
+			   : sig),
+			  &frame->sig);
+	err |=3D __put_user((long)&frame->info, &frame->pinfo);
+	err |=3D __put_user((long)&frame->uc, &frame->puc);
+	err |=3D copy_siginfo_to_user32(&frame->info, info);
+
+	/* Create the ucontext.  */
+	err |=3D __put_user(0, &frame->uc.uc_flags);
+	err |=3D __put_user(0, &frame->uc.uc_link);
+	err |=3D __put_user(current->sas_ss_sp, &frame->uc.uc_stack.ss_sp);
+	err |=3D __put_user(sas_ss_flags(regs->r12), &frame->uc.uc_stack.ss_flags=
);
+	err |=3D __put_user(current->sas_ss_size, &frame->uc.uc_stack.ss_size);
+	err |=3D setup_sigcontext_ia32(&frame->uc.uc_mcontext, &frame->fpstate, r=
egs, set->sig[0]);
+	err |=3D __copy_to_user(&frame->uc.uc_sigmask, set, sizeof(*set));
+	if (err)
+		goto give_sigsegv;
+
+	/* Set up to return from userspace.  If provided, use a stub
+	   already in userspace.  */
+	if (ka->sa.sa_flags & SA_RESTORER) {
+		unsigned int restorer =3D IA32_SA_RESTORER(ka);
+		err |=3D __put_user(restorer, &frame->pretcode);
+	} else {
+		err |=3D __put_user((long)frame->retcode, &frame->pretcode);
+		/* This is movl $,%eax ; int $0x80 */
+		err |=3D __put_user(0xb8, (char *)(frame->retcode+0));
+		err |=3D __put_user(__IA32_NR_rt_sigreturn, (int *)(frame->retcode+1));
+		err |=3D __put_user(0x80cd, (short *)(frame->retcode+5));
+	}
=20
-       if (err)
-               goto give_sigsegv;
+	if (err)
+		goto give_sigsegv;
=20
-       /* Set up registers for signal handler */
-       regs->r12 =3D (unsigned long) frame;
-       regs->cr_iip =3D (unsigned long) ka->sa.sa_handler;
+	/* Set up registers for signal handler */
+	regs->r12 =3D (unsigned long) frame;
+	regs->cr_iip =3D IA32_SA_HANDLER(ka);
=20
-       set_fs(USER_DS);
+	set_fs(USER_DS);
=20
-       regs->r16 =3D (__USER_DS << 16) |  (__USER_DS); /* ES =3D DS, GS, F=
S are zero */
-       regs->r17 =3D (__USER_DS << 16) | __USER_CS;
+	regs->r16 =3D (__USER_DS << 16) |  (__USER_DS); /* ES =3D DS, GS, FS are =
zero */
+	regs->r17 =3D (__USER_DS << 16) | __USER_CS;
=20
 #if 0
-       regs->eflags &=3D ~TF_MASK;
+	regs->eflags &=3D ~TF_MASK;
 #endif
=20
 #if 0
-       printk("SIG deliver (%s:%d): sp=3D%p pc=3D%lx ra=3D%x\n",
+	printk("SIG deliver (%s:%d): sp=3D%p pc=3D%lx ra=3D%x\n",
                current->comm, current->pid, (void *) frame, regs->cr_iip, =
frame->pretcode);
 #endif
=20
-       return 1;
+	return 1;
=20
 give_sigsegv:
-       if (sig =3D SIGSEGV)
-               ka->sa.sa_handler =3D SIG_DFL;
-       force_sig(SIGSEGV, current);
-       return 0;
+	if (sig =3D SIGSEGV)
+		ka->sa.sa_handler =3D SIG_DFL;
+	force_sig(SIGSEGV, current);
+	return 0;
 }
=20
 int
@@ -398,93 +446,79 @@
 {
        /* Set up the stack frame */
        if (ka->sa.sa_flags & SA_SIGINFO)
-               return(setup_rt_frame_ia32(sig, ka, info, set, regs));
+               return setup_rt_frame_ia32(sig, ka, info, set, regs);
        else
-               return(setup_frame_ia32(sig, ka, set, regs));
+               return setup_frame_ia32(sig, ka, set, regs);
 }
=20
-asmlinkage int
-sys32_sigreturn(
-int arg0,
-int arg1,
-int arg2,
-int arg3,
-int arg4,
-int arg5,
-int arg6,
-int arg7,
-unsigned long stack)
-{
-       struct pt_regs *regs =3D (struct pt_regs *) &stack;
-       struct sigframe_ia32 *frame =3D (struct sigframe_ia32 *)(regs->r12-=
 8);
-       sigset_t set;
-       int eax;
-
-       if (verify_area(VERIFY_READ, frame, sizeof(*frame)))
-               goto badframe;
-
-       if (__get_user(set.sig[0], &frame->sc.oldmask)
-           || (_IA32_NSIG_WORDS > 1 && __copy_from_user((char *) &set.sig =
+ 4, &frame->extramask,
-							sizeof(frame->extramask))))
-               goto badframe;
-
-       sigdelsetmask(&set, ~_BLOCKABLE);
-       spin_lock_irq(&current->sigmask_lock);
-       current->blocked =3D (sigset_t) set;
-       recalc_sigpending(current);
-       spin_unlock_irq(&current->sigmask_lock);
-      =20
-       if (restore_sigcontext_ia32(regs, &frame->sc, &eax))
-               goto badframe;
-       return eax;
-
-badframe:
-       force_sig(SIGSEGV, current);
-       return 0;
-}     =20
-
-asmlinkage int
-sys32_rt_sigreturn(
-int arg0,
-int arg1,
-int arg2,
-int arg3,
-int arg4,
-int arg5,
-int arg6,
-int arg7,
-unsigned long stack)
-{
-       struct pt_regs *regs =3D (struct pt_regs *) &stack;
-       struct rt_sigframe_ia32 *frame =3D (struct rt_sigframe_ia32 *)(regs=
->r12 - 4);
-       sigset_t set;
-       stack_t st;
-       int eax;
-
-       if (verify_area(VERIFY_READ, frame, sizeof(*frame)))
-               goto badframe;
-       if (__copy_from_user(&set, &frame->uc.uc_sigmask, sizeof(set)))
-               goto badframe;
-
-       sigdelsetmask(&set, ~_BLOCKABLE);
-       spin_lock_irq(&current->sigmask_lock);
-       current->blocked =3D  set;
-       recalc_sigpending(current);
-       spin_unlock_irq(&current->sigmask_lock);
-      =20
-       if (restore_sigcontext_ia32(regs, &frame->uc.uc_mcontext, &eax))
-               goto badframe;
-
-       if (__copy_from_user(&st, &frame->uc.uc_stack, sizeof(st)))
-               goto badframe;
-       /* It is more difficult to avoid calling this function than to
-          call it and ignore errors.  */
-       do_sigaltstack(&st, NULL, regs->r12);
-
-       return eax;
+asmlinkage long
+sys32_sigreturn (int arg0, int arg1, int arg2, int arg3, int arg4, int arg=
5, int arg6, int arg7,
+		 unsigned long stack)
+{
+	struct pt_regs *regs =3D (struct pt_regs *) &stack;
+	unsigned long esp =3D (unsigned int) regs->r12;
+	struct sigframe_ia32 *frame =3D (struct sigframe_ia32 *)(esp - 8);
+	sigset_t set;
+	int eax;
+
+	if (verify_area(VERIFY_READ, frame, sizeof(*frame)))
+		goto badframe;
+
+	if (__get_user(set.sig[0], &frame->sc.oldmask)
+	    || (_IA32_NSIG_WORDS > 1 && __copy_from_user((char *) &set.sig + 4, &=
frame->extramask,
+							 sizeof(frame->extramask))))
+		goto badframe;
+
+	sigdelsetmask(&set, ~_BLOCKABLE);
+	spin_lock_irq(&current->sigmask_lock);
+	current->blocked =3D (sigset_t) set;
+	recalc_sigpending(current);
+	spin_unlock_irq(&current->sigmask_lock);
+
+	if (restore_sigcontext_ia32(regs, &frame->sc, &eax))
+		goto badframe;
+	return eax;
+
+  badframe:
+	force_sig(SIGSEGV, current);
+	return 0;
+}
=20
-badframe:
-       force_sig(SIGSEGV, current);
-       return 0;
-}     =20
+asmlinkage long
+sys32_rt_sigreturn (int arg0, int arg1, int arg2, int arg3, int arg4, int =
arg5, int arg6, int arg7,
+		    unsigned long stack)
+{
+	struct pt_regs *regs =3D (struct pt_regs *) &stack;
+	unsigned long esp =3D (unsigned int) regs->r12;
+	struct rt_sigframe_ia32 *frame =3D (struct rt_sigframe_ia32 *)(esp - 4);
+	sigset_t set;
+	stack_t st;
+	int eax;
+
+	if (verify_area(VERIFY_READ, frame, sizeof(*frame)))
+		goto badframe;
+	if (__copy_from_user(&set, &frame->uc.uc_sigmask, sizeof(set)))
+		goto badframe;
+
+	sigdelsetmask(&set, ~_BLOCKABLE);
+	spin_lock_irq(&current->sigmask_lock);
+	current->blocked =3D  set;
+	recalc_sigpending(current);
+	spin_unlock_irq(&current->sigmask_lock);
+
+	if (restore_sigcontext_ia32(regs, &frame->uc.uc_mcontext, &eax))
+		goto badframe;
+
+	if (__copy_from_user(&st, &frame->uc.uc_stack, sizeof(st)))
+		goto badframe;
+	/* It is more difficult to avoid calling this function than to
+	   call it and ignore errors.  */
+	do_sigaltstack(&st, NULL, esp);
+
+	return eax;
+
+  badframe:
+	force_sig(SIGSEGV, current);
+	return 0;
+}
=20
diff -urN linux-davidm/arch/ia64/ia32/ia32_support.c linux-2.4.10-lia/arch/=
ia64/ia32/ia32_support.c
--- linux-davidm/arch/ia64/ia32/ia32_support.c	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/ia32/ia32_support.c	Mon Sep 24 21:45:11 2001
@@ -4,15 +4,17 @@
  * Copyright (C) 1999 Arun Sharma <arun.sharma@intel.com>
  * Copyright (C) 2000 Asit K. Mallick <asit.k.mallick@intel.com>
  * Copyright (C) 2001 Hewlett-Packard Co
- * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * 06/16/00	A. Mallick	added csd/ssd/tssd for ia32 thread context
  * 02/19/01	D. Mosberger	dropped tssd; it's not needed
+ * 09/14/01	D. Mosberger	fixed memory management for gdt/tss page
  */
=20
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/mm.h>
+#include <linux/personality.h>
 #include <linux/sched.h>
=20
 #include <asm/page.h>
@@ -21,10 +23,12 @@
 #include <asm/processor.h>
 #include <asm/ia32.h>
=20
-extern unsigned long *ia32_gdt_table, *ia32_tss;
-
 extern void die_if_kernel (char *str, struct pt_regs *regs, long err);
=20
+struct exec_domain ia32_exec_domain;
+struct page *ia32_shared_page[(2*IA32_PAGE_SIZE + PAGE_SIZE - 1)/PAGE_SIZE=
];
+unsigned long *ia32_gdt;
+
 void
 ia32_save_state (struct task_struct *t)
 {
@@ -85,36 +89,34 @@
 void
 ia32_gdt_init (void)
 {
-	unsigned long gdt_and_tss_page, ldt_size;
+	unsigned long *tss;
+	unsigned long ldt_size;
 	int nr;
=20
-	/* allocate two IA-32 pages of memory: */
-	gdt_and_tss_page =3D __get_free_pages(GFP_KERNEL,
-					    (IA32_PAGE_SHIFT < PAGE_SHIFT)
-					    ? 0 : (IA32_PAGE_SHIFT + 1) - PAGE_SHIFT);
-	ia32_gdt_table =3D (unsigned long *) gdt_and_tss_page;
-	ia32_tss =3D (unsigned long *) (gdt_and_tss_page + IA32_PAGE_SIZE);
-
-	/* Zero the gdt and tss */
-	memset((void *) gdt_and_tss_page, 0, 2*IA32_PAGE_SIZE);
+	ia32_shared_page[0] =3D alloc_page(GFP_KERNEL);
+	ia32_gdt =3D page_address(ia32_shared_page[0]);
+	tss =3D ia32_gdt + IA32_PAGE_SIZE/sizeof(ia32_gdt[0]);
+
+	if (IA32_PAGE_SIZE =3D PAGE_SIZE) {
+		ia32_shared_page[1] =3D alloc_page(GFP_KERNEL);
+		tss =3D page_address(ia32_shared_page[1]);
+	}
=20
 	/* CS descriptor in IA-32 (scrambled) format */
-	ia32_gdt_table[__USER_CS >> 3] -		IA32_SEG_DESCRIPTOR(0, (IA32_PAGE_OFFSE=
T - 1) >> IA32_PAGE_SHIFT,
-				    0xb, 1, 3, 1, 1, 1, 1);
+	ia32_gdt[__USER_CS >> 3] =3D IA32_SEG_DESCRIPTOR(0, (IA32_PAGE_OFFSET-1) =
>> IA32_PAGE_SHIFT,
+						       0xb, 1, 3, 1, 1, 1, 1);
=20
 	/* DS descriptor in IA-32 (scrambled) format */
-	ia32_gdt_table[__USER_DS >> 3] -		IA32_SEG_DESCRIPTOR(0, (IA32_PAGE_OFFSE=
T - 1) >> IA32_PAGE_SHIFT,
-				    0x3, 1, 3, 1, 1, 1, 1);
+	ia32_gdt[__USER_DS >> 3] =3D IA32_SEG_DESCRIPTOR(0, (IA32_PAGE_OFFSET-1) =
>> IA32_PAGE_SHIFT,
+						       0x3, 1, 3, 1, 1, 1, 1);
=20
 	/* We never change the TSS and LDT descriptors, so we can share them acro=
ss all CPUs.  */
 	ldt_size =3D PAGE_ALIGN(IA32_LDT_ENTRIES*IA32_LDT_ENTRY_SIZE);
 	for (nr =3D 0; nr < NR_CPUS; ++nr) {
-		ia32_gdt_table[_TSS(nr)] =3D IA32_SEG_DESCRIPTOR(IA32_TSS_OFFSET, 235,
-							       0xb, 0, 3, 1, 1, 1, 0);
-		ia32_gdt_table[_LDT(nr)] =3D IA32_SEG_DESCRIPTOR(IA32_LDT_OFFSET, ldt_si=
ze - 1,
-							       0x2, 0, 3, 1, 1, 1, 0);
+		ia32_gdt[_TSS(nr)] =3D IA32_SEG_DESCRIPTOR(IA32_TSS_OFFSET, 235,
+							 0xb, 0, 3, 1, 1, 1, 0);
+		ia32_gdt[_LDT(nr)] =3D IA32_SEG_DESCRIPTOR(IA32_LDT_OFFSET, ldt_size - 1,
+							 0x2, 0, 3, 1, 1, 1, 0);
 	}
 }
=20
@@ -133,3 +135,18 @@
 	siginfo.si_code =3D TRAP_BRKPT;
 	force_sig_info(SIGTRAP, &siginfo, current);
 }
+
+static int __init
+ia32_init (void)
+{
+	ia32_exec_domain.name =3D "Linux/x86";
+	ia32_exec_domain.handler =3D NULL;
+	ia32_exec_domain.pers_low =3D PER_LINUX32;
+	ia32_exec_domain.pers_high =3D PER_LINUX32;
+	ia32_exec_domain.signal_map =3D default_exec_domain.signal_map;
+	ia32_exec_domain.signal_invmap =3D default_exec_domain.signal_invmap;
+	register_exec_domain(&ia32_exec_domain);
+	return 0;
+}
+
+__initcall(ia32_init);
diff -urN linux-davidm/arch/ia64/ia32/sys_ia32.c linux-2.4.10-lia/arch/ia64=
/ia32/sys_ia32.c
--- linux-davidm/arch/ia64/ia32/sys_ia32.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/ia32/sys_ia32.c	Mon Sep 24 21:45:20 2001
@@ -1,14 +1,13 @@
 /*
- * sys_ia32.c: Conversion between 32bit and 64bit native syscalls. Based on
- *             sys_sparc32
+ * sys_ia32.c: Conversion between 32bit and 64bit native syscalls. Derived=
 from sys_sparc32.c.
  *
  * Copyright (C) 2000		VA Linux Co
  * Copyright (C) 2000		Don Dugger <n0ano@valinux.com>
  * Copyright (C) 1999		Arun Sharma <arun.sharma@intel.com>
  * Copyright (C) 1997,1998	Jakub Jelinek (jj@sunsite.mff.cuni.cz)
  * Copyright (C) 1997		David S. Miller (davem@caip.rutgers.edu)
- * Copyright (C) 2000		Hewlett-Packard Co.
- * Copyright (C) 2000		David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 2000-2001 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * These routines maintain argument size conversion between 32bit and 64bit
  * environment.
@@ -53,7 +52,6 @@
 #include <asm/types.h>
 #include <asm/uaccess.h>
 #include <asm/semaphore.h>
-#include <asm/ipc.h>
=20
 #include <net/scm.h>
 #include <net/sock.h>
@@ -66,18 +64,23 @@
=20
 extern asmlinkage long sys_execve (char *, char **, char **, struct pt_reg=
s *);
 extern asmlinkage long sys_mprotect (unsigned long, size_t, unsigned long);
+extern asmlinkage long sys_munmap (unsigned long, size_t);
+
+/* forward declaration: */
+asmlinkage long sys32_mprotect (unsigned int, unsigned int, int);
=20
 static int
 nargs (unsigned int arg, char **ap)
 {
-	int n, err, addr;
+	unsigned int addr;
+	int n, err;
=20
 	if (!arg)
 		return 0;
=20
 	n =3D 0;
 	do {
-		err =3D get_user(addr, (int *)A(arg));
+		err =3D get_user(addr, (unsigned int *)A(arg));
 		if (err)
 			return err;
 		if (ap)
@@ -144,30 +147,33 @@
 }
=20
 static inline int
-putstat(struct stat32 *ubuf, struct stat *kbuf)
+putstat (struct stat32 *ubuf, struct stat *kbuf)
 {
 	int err;
=20
-	err =3D put_user (kbuf->st_dev, &ubuf->st_dev);
-	err |=3D __put_user (kbuf->st_ino, &ubuf->st_ino);
-	err |=3D __put_user (kbuf->st_mode, &ubuf->st_mode);
-	err |=3D __put_user (kbuf->st_nlink, &ubuf->st_nlink);
-	err |=3D __put_user (kbuf->st_uid, &ubuf->st_uid);
-	err |=3D __put_user (kbuf->st_gid, &ubuf->st_gid);
-	err |=3D __put_user (kbuf->st_rdev, &ubuf->st_rdev);
-	err |=3D __put_user (kbuf->st_size, &ubuf->st_size);
-	err |=3D __put_user (kbuf->st_atime, &ubuf->st_atime);
-	err |=3D __put_user (kbuf->st_mtime, &ubuf->st_mtime);
-	err |=3D __put_user (kbuf->st_ctime, &ubuf->st_ctime);
-	err |=3D __put_user (kbuf->st_blksize, &ubuf->st_blksize);
-	err |=3D __put_user (kbuf->st_blocks, &ubuf->st_blocks);
+	if (clear_user(ubuf, sizeof(*ubuf)))
+		return 1;
+
+	err  =3D __put_user(kbuf->st_dev, &ubuf->st_dev);
+	err |=3D __put_user(kbuf->st_ino, &ubuf->st_ino);
+	err |=3D __put_user(kbuf->st_mode, &ubuf->st_mode);
+	err |=3D __put_user(kbuf->st_nlink, &ubuf->st_nlink);
+	err |=3D __put_user(kbuf->st_uid, &ubuf->st_uid);
+	err |=3D __put_user(kbuf->st_gid, &ubuf->st_gid);
+	err |=3D __put_user(kbuf->st_rdev, &ubuf->st_rdev);
+	err |=3D __put_user(kbuf->st_size, &ubuf->st_size);
+	err |=3D __put_user(kbuf->st_atime, &ubuf->st_atime);
+	err |=3D __put_user(kbuf->st_mtime, &ubuf->st_mtime);
+	err |=3D __put_user(kbuf->st_ctime, &ubuf->st_ctime);
+	err |=3D __put_user(kbuf->st_blksize, &ubuf->st_blksize);
+	err |=3D __put_user(kbuf->st_blocks, &ubuf->st_blocks);
 	return err;
 }
=20
-extern asmlinkage long sys_newstat(char * filename, struct stat * statbuf);
+extern asmlinkage long sys_newstat (char * filename, struct stat * statbuf=
);
=20
 asmlinkage long
-sys32_newstat(char * filename, struct stat32 *statbuf)
+sys32_newstat (char *filename, struct stat32 *statbuf)
 {
 	int ret;
 	struct stat s;
@@ -175,8 +181,8 @@
=20
 	set_fs(KERNEL_DS);
 	ret =3D sys_newstat(filename, &s);
-	set_fs (old_fs);
-	if (putstat (statbuf, &s))
+	set_fs(old_fs);
+	if (putstat(statbuf, &s))
 		return -EFAULT;
 	return ret;
 }
@@ -184,16 +190,16 @@
 extern asmlinkage long sys_newlstat(char * filename, struct stat * statbuf=
);
=20
 asmlinkage long
-sys32_newlstat(char * filename, struct stat32 *statbuf)
+sys32_newlstat (char *filename, struct stat32 *statbuf)
 {
-	int ret;
-	struct stat s;
 	mm_segment_t old_fs =3D get_fs();
+	struct stat s;
+	int ret;
=20
-	set_fs (KERNEL_DS);
+	set_fs(KERNEL_DS);
 	ret =3D sys_newlstat(filename, &s);
-	set_fs (old_fs);
-	if (putstat (statbuf, &s))
+	set_fs(old_fs);
+	if (putstat(statbuf, &s))
 		return -EFAULT;
 	return ret;
 }
@@ -201,112 +207,171 @@
 extern asmlinkage long sys_newfstat(unsigned int fd, struct stat * statbuf=
);
=20
 asmlinkage long
-sys32_newfstat(unsigned int fd, struct stat32 *statbuf)
+sys32_newfstat (unsigned int fd, struct stat32 *statbuf)
 {
-	int ret;
-	struct stat s;
 	mm_segment_t old_fs =3D get_fs();
+	struct stat s;
+	int ret;
=20
-	set_fs (KERNEL_DS);
+	set_fs(KERNEL_DS);
 	ret =3D sys_newfstat(fd, &s);
-	set_fs (old_fs);
-	if (putstat (statbuf, &s))
+	set_fs(old_fs);
+	if (putstat(statbuf, &s))
 		return -EFAULT;
 	return ret;
 }
=20
 #define OFFSET4K(a)	((a) & 0xfff)
=20
-unsigned long
-do_mmap_fake(struct file *file, unsigned long addr, unsigned long len,
-	unsigned long prot, unsigned long flags, loff_t off)
+#if PAGE_SHIFT > IA32_PAGE_SHIFT
+
+/*
+ * Determine whether address ADDR is readable.  This must be done *without=
* actually
+ * touching memory because otherwise the stack auto-expansion may *make* t=
he address
+ * readable, which is not at all what we want. --davidm 01/09/20
+ */
+static inline long
+is_readable (unsigned long addr)
+{
+	struct vm_area_struct *vma =3D find_vma(current->mm, addr);
+	return vma && (vma->vm_start <=3D addr) && (vma->vm_flags & VM_READ);
+}
+
+static unsigned long
+do_mmap_fake (struct file *file, unsigned long addr, unsigned long len, in=
t prot, int flags,
+	      loff_t off)
 {
+	unsigned long faddr =3D (addr & PAGE_MASK), end, front_len, back_len, ret=
val;
+	void *front =3D 0, *back =3D 0;
 	struct inode *inode;
-	void *front, *back;
-	unsigned long baddr;
-	int r;
-	char c;
=20
-	if (OFFSET4K(addr) || OFFSET4K(off))
-		return -EINVAL;
+	/*
+	 * Allow any kind of access: this lets us avoid having to figure out what=
 the
+	 * protection of the partial front and back pages is...
+	 */
 	prot |=3D PROT_WRITE;
-	front =3D NULL;
-	back =3D NULL;
-	if ((baddr =3D (addr & PAGE_MASK)) !=3D addr && get_user(c, (char *)baddr=
) =3D 0) {
-		front =3D kmalloc(addr - baddr, GFP_KERNEL);
-		if (!front)
-			return -ENOMEM;
-		__copy_user(front, (void *)baddr, addr - baddr);
+
+	if (OFFSET4K(addr))
+		return -EINVAL;
+
+	end =3D addr + len;
+	front_len =3D addr - faddr;
+	back_len =3D (end & ~PAGE_MASK);
+
+	if (front_len && is_readable(faddr)) {
+		front =3D kmalloc(front_len, GFP_KERNEL);
+		if (!front) {
+			addr =3D -ENOMEM;
+			goto fail;
+		}
+		copy_from_user(front, (void *)faddr, front_len);
 	}
-	if (addr && ((addr + len) & ~PAGE_MASK) && get_user(c, (char *)(addr + le=
n)) =3D 0) {
-		back =3D kmalloc(PAGE_SIZE - ((addr + len) & ~PAGE_MASK), GFP_KERNEL);
+
+	if (addr && back_len && is_readable(end)) {
+		back =3D kmalloc(PAGE_SIZE - back_len, GFP_KERNEL);
 		if (!back) {
-			if (front)
-				kfree(front);
-			return -ENOMEM;
+			addr =3D -ENOMEM;
+			goto fail;
 		}
-		__copy_user(back, (char *)addr + len, PAGE_SIZE - ((addr + len) & ~PAGE_=
MASK));
+		copy_from_user(back, (char *)end, PAGE_SIZE - back_len);
 	}
+
 	down_write(&current->mm->mmap_sem);
-	r =3D do_mmap(0, baddr, len + (addr - baddr), prot, flags | MAP_ANONYMOUS=
, 0);
+	{
+		retval =3D do_mmap(0, faddr, len + front_len, prot, flags | MAP_ANONYMOU=
S, 0);
+	}
 	up_write(&current->mm->mmap_sem);
-	if (r < 0)
-		return(r);
-	if (addr =3D 0)
-		addr =3D r;
+
+	if (IS_ERR((void *) retval)) {
+		addr =3D retval;
+		goto fail;
+	}
+
+	if (!addr)
+		addr =3D retval;
+
+	end =3D addr + len;
+
 	if (back) {
-		__copy_user((char *)addr + len, back, PAGE_SIZE - ((addr + len) & ~PAGE_=
MASK));
+		if (copy_to_user((char *) end, back, PAGE_SIZE - back_len)) {
+			addr =3D -EINVAL;
+			goto fail;
+		}
 		kfree(back);
 	}
 	if (front) {
-		__copy_user((void *)baddr, front, addr - baddr);
+		if (copy_to_user((void *) faddr, front, front_len)) {
+			addr =3D -EINVAL;
+			goto fail;
+		}
 		kfree(front);
 	}
-	if (flags & MAP_ANONYMOUS) {
-		clear_user((char *)addr, len);
-		return(addr);
+
+	if (!(flags & MAP_ANONYMOUS)) {
+		inode =3D file->f_dentry->d_inode;
+		if (!inode->i_fop
+		    || !file->f_op->read
+		    || (*file->f_op->read)(file, (char *)addr, len, &off) < 0)
+		{
+			sys_munmap(addr, len + front_len);
+			return -EINVAL;
+		}
 	}
-	if (!file)
-		return -EINVAL;
-	inode =3D file->f_dentry->d_inode;
-	if (!inode->i_fop)
-		return -EINVAL;
-	if (!file->f_op->read)
-		return -EINVAL;
-	r =3D file->f_op->read(file, (char *)addr, len, &off);
-	return (r < 0) ? -EINVAL : addr;
+	return addr;
+
+  fail:	if (front)
+		kfree(front);
+	if (back)
+		kfree(back);
+	return addr;
 }
=20
-long
-ia32_do_mmap (struct file *file, unsigned int addr, unsigned int len, unsi=
gned int prot,
-	      unsigned int flags, unsigned int fd, unsigned int offset)
+#endif /* PAGE_SHIFT > IA32_PAGE_SHIFT */
+
+unsigned long
+ia32_do_mmap (struct file *file, unsigned long addr, unsigned long len, in=
t prot, int flags,
+	      loff_t offset)
 {
-	long error =3D -EFAULT;
-	unsigned int poff;
+	if (file && (!file->f_op || !file->f_op->mmap))
+		return -ENODEV;
=20
-	flags &=3D ~(MAP_EXECUTABLE | MAP_DENYWRITE);
-	prot |=3D PROT_EXEC;
+	len =3D IA32_PAGE_ALIGN(len);
+	if (len =3D 0)
+		return addr;
+
+	if (len > IA32_PAGE_OFFSET || addr > IA32_PAGE_OFFSET - len)
+		return -EINVAL;
+
+	if (OFFSET4K(offset))
+		return -EINVAL;
+
+	if (prot & (PROT_READ | PROT_WRITE))
+		prot |=3D PROT_EXEC;	/* x86 has no "execute" permission bit... */
=20
+#if PAGE_SHIFT > IA32_PAGE_SHIFT
 	if ((flags & MAP_FIXED) && ((addr & ~PAGE_MASK) || (offset & ~PAGE_MASK)))
-		error =3D do_mmap_fake(file, addr, len, prot, flags, (loff_t)offset);
-	else {
-		poff =3D offset & PAGE_MASK;
-		len +=3D offset - poff;
+		addr =3D do_mmap_fake(file, addr, len, prot, flags, offset);
+	else
+#endif
+	{
+		loff_t pgoff =3D offset & PAGE_MASK;
+		len +=3D offset - pgoff;
=20
 		down_write(&current->mm->mmap_sem);
-		error =3D do_mmap_pgoff(file, addr, len, prot, flags, poff >> PAGE_SHIFT=
);
+		{
+			addr =3D do_mmap(file, addr, len, prot, flags, pgoff);
+		}
 		up_write(&current->mm->mmap_sem);
=20
-		if (!IS_ERR((void *) error))
-			error +=3D offset - poff;
+		if (!IS_ERR((void *) addr))
+			addr +=3D offset - pgoff;
 	}
-	return error;
+	return addr;
 }
=20
 /*
- * Linux/i386 didn't use to be able to handle more than
- * 4 system call parameters, so these system calls used a memory
- * block for parameter passing..
+ * Linux/i386 didn't use to be able to handle more than 4 system call para=
meters, so these
+ * system calls used a memory block for parameter passing..
  */
=20
 struct mmap_arg_struct {
@@ -319,56 +384,147 @@
 };
=20
 asmlinkage long
-sys32_mmap(struct mmap_arg_struct *arg)
+sys32_mmap (struct mmap_arg_struct *arg)
 {
 	struct mmap_arg_struct a;
 	struct file *file =3D NULL;
-	long retval;
+	unsigned long addr;
+	int flags;
=20
 	if (copy_from_user(&a, arg, sizeof(a)))
 		return -EFAULT;
=20
-	if (PAGE_ALIGN(a.len) =3D 0)
-		return a.addr;
+	if (OFFSET4K(a.offset))
+		return -EINVAL;
+
+	flags =3D a.flags;
=20
-	if (!(a.flags & MAP_ANONYMOUS)) {
+	flags &=3D ~(MAP_EXECUTABLE | MAP_DENYWRITE);
+	if (!(flags & MAP_ANONYMOUS)) {
 		file =3D fget(a.fd);
 		if (!file)
 			return -EBADF;
 	}
-#ifdef	CONFIG_IA64_PAGE_SIZE_4KB
-	if ((a.offset & ~PAGE_MASK) !=3D 0)
-		return -EINVAL;
=20
-	down_write(&current->mm->mmap_sem);
-	retval =3D do_mmap_pgoff(file, a.addr, a.len, a.prot, a.flags, a.offset >=
> PAGE_SHIFT);
-	up_write(&current->mm->mmap_sem);
-#else
-	retval =3D ia32_do_mmap(file, a.addr, a.len, a.prot, a.flags, a.fd, a.off=
set);
-#endif
+	addr =3D ia32_do_mmap(file, a.addr, a.len, a.prot, flags, a.offset);
+
+	if (file)
+		fput(file);
+	return addr;
+}
+
+asmlinkage long
+sys32_mmap2 (unsigned int addr, unsigned int len, unsigned int prot, unsig=
ned int flags,
+	     unsigned int fd, unsigned int pgoff)
+{
+	struct file *file =3D NULL;
+	unsigned long retval;
+
+	flags &=3D ~(MAP_EXECUTABLE | MAP_DENYWRITE);
+	if (!(flags & MAP_ANONYMOUS)) {
+		file =3D fget(fd);
+		if (!file)
+			return -EBADF;
+	}
+
+	retval =3D ia32_do_mmap(file, addr, len, prot, flags,
+			      (unsigned long) pgoff << IA32_PAGE_SHIFT);
+
 	if (file)
 		fput(file);
 	return retval;
 }
=20
 asmlinkage long
-sys32_mprotect(unsigned long start, size_t len, unsigned long prot)
+sys32_munmap (unsigned int start, unsigned int len)
+{
+	unsigned int end =3D start + len;
+
+#if PAGE_SHIFT > IA32_PAGE_SHIFT
+	if (start > end)
+		return -EINVAL;
+
+	start =3D PAGE_ALIGN(start);
+	end =3D end & PAGE_MASK;
+
+	if (start >=3D end)
+		return 0;
+#endif
+	return sys_munmap(start, end - start);
+}
+
+#if PAGE_SHIFT > IA32_PAGE_SHIFT
+
+/*
+ * When mprotect()ing a partial page, we set the permission to the union o=
f the old
+ * settings and the new settings.  In other words, it's only possible to m=
ake access to a
+ * partial page less restrictive.
+ */
+static long
+mprotect_partial_page (unsigned long address, int new_prot)
+{
+	int old_prot;
+
+	if (new_prot =3D PROT_NONE)
+		return 0;		/* optimize case where nothing changes... */
+
+	/*
+	 * We cannot easily determine the existing protection on this page becaus=
e we have
+	 * to relinquish the mmap-semaphore before calling sys_mprotect(), which =
would
+	 * create a window during which another task could change the protection =
settings
+	 * underneath us.  To avoid this, we conservatively assume that the page =
is
+	 * RWXable.
+	 */
+	old_prot =3D PROT_READ | PROT_WRITE | PROT_EXEC;
+	return sys_mprotect(address, PAGE_SIZE, new_prot | old_prot);
+}
+
+#endif /* PAGE_SHIFT > IA32_PAGE_SHIFT */
+
+asmlinkage long
+sys32_mprotect (unsigned int start, unsigned int len, int prot)
 {
+	unsigned long end =3D start + len;
+#if PAGE_SHIFT > IA32_PAGE_SHIFT
+	long retval;
+#endif
=20
-#ifdef	CONFIG_IA64_PAGE_SIZE_4KB
-	return(sys_mprotect(start, len, prot));
-#else	// CONFIG_IA64_PAGE_SIZE_4KB
-	if (prot =3D 0)
-		return(0);
-	len +=3D start & ~PAGE_MASK;
-	if ((start & ~PAGE_MASK) && (prot & PROT_WRITE))
+	if (prot & (PROT_READ | PROT_WRITE))
+		/* on x86, PROT_WRITE implies PROT_READ and PROT_READ implies PROT_EXEC.=
.. */
 		prot |=3D PROT_EXEC;
-	return(sys_mprotect(start & PAGE_MASK, len & PAGE_MASK, prot));
-#endif	// CONFIG_IA64_PAGE_SIZE_4KB
+
+#if PAGE_SHIFT > IA32_PAGE_SHIFT
+	if (OFFSET4K(start))
+		return -EINVAL;
+
+	end =3D IA32_PAGE_ALIGN(end);
+	if (end < start)
+		return -EINVAL;
+
+	if (start & ~PAGE_MASK) {
+		/* start address is 4KB aligned but not page aligned. */
+		retval =3D mprotect_partial_page(start & PAGE_MASK, prot);
+		if (retval < 0)
+			return retval;
+
+		start =3D PAGE_ALIGN(start);
+		if (start >=3D end)
+			return 0;
+	}
+
+	if (end & ~PAGE_MASK) {
+		/* end address is 4KB aligned but not page aligned. */
+		retval =3D mprotect_partial_page(end & PAGE_MASK, prot);
+		if (retval < 0)
+			return retval;
+		end &=3D PAGE_MASK;
+	}
+#endif
+	return sys_mprotect(start, end - start, prot);
 }
=20
 asmlinkage long
-sys32_pipe(int *fd)
+sys32_pipe (int *fd)
 {
 	int retval;
 	int fds[2];
@@ -382,119 +538,154 @@
 	return retval;
 }
=20
+static inline void
+sigact_set_handler (struct k_sigaction *sa, unsigned int handler, unsigned=
 int restorer)
+{
+	if (handler + 1 <=3D 2)
+		/* SIG_DFL, SIG_IGN, or SIG_ERR: must sign-extend to 64-bits */
+		sa->sa.sa_handler =3D (__sighandler_t) A((int) handler);
+	else
+		sa->sa.sa_handler =3D (__sighandler_t) (((unsigned long) restorer << 32)=
 | handler);
+}
+
 asmlinkage long
 sys32_signal (int sig, unsigned int handler)
 {
 	struct k_sigaction new_sa, old_sa;
 	int ret;
=20
-	new_sa.sa.sa_handler =3D (__sighandler_t) A(handler);
+	sigact_set_handler(&new_sa, handler, 0);
 	new_sa.sa.sa_flags =3D SA_ONESHOT | SA_NOMASK;
=20
 	ret =3D do_sigaction(sig, &new_sa, &old_sa);
=20
-	return ret ? ret : (unsigned long)old_sa.sa.sa_handler;
+	return ret ? ret : IA32_SA_HANDLER(&old_sa);
 }
=20
 asmlinkage long
-sys32_rt_sigaction(int sig, struct sigaction32 *act,
-		   struct sigaction32 *oact,  unsigned int sigsetsize)
+sys32_rt_sigaction (int sig, struct sigaction32 *act,
+		    struct sigaction32 *oact, unsigned int sigsetsize)
 {
 	struct k_sigaction new_ka, old_ka;
+	unsigned int handler, restorer;
 	int ret;
-	sigset32_t set32;
=20
 	/* XXX: Don't preclude handling different sized sigset_t's.  */
 	if (sigsetsize !=3D sizeof(sigset32_t))
 		return -EINVAL;
=20
 	if (act) {
-		ret =3D get_user((long)new_ka.sa.sa_handler, &act->sa_handler);
-		ret |=3D __copy_from_user(&set32, &act->sa_mask,
-					sizeof(sigset32_t));
-		switch (_NSIG_WORDS) {
-		case 4: new_ka.sa.sa_mask.sig[3] =3D set32.sig[6]
-				| (((long)set32.sig[7]) << 32);
-		case 3: new_ka.sa.sa_mask.sig[2] =3D set32.sig[4]
-				| (((long)set32.sig[5]) << 32);
-		case 2: new_ka.sa.sa_mask.sig[1] =3D set32.sig[2]
-				| (((long)set32.sig[3]) << 32);
-		case 1: new_ka.sa.sa_mask.sig[0] =3D set32.sig[0]
-				| (((long)set32.sig[1]) << 32);
-		}
-		ret |=3D __get_user(new_ka.sa.sa_flags, &act->sa_flags);
-
+		ret =3D get_user(handler, &act->sa_handler);
+		ret |=3D get_user(new_ka.sa.sa_flags, &act->sa_flags);
+		ret |=3D get_user(restorer, &act->sa_restorer);
+		ret |=3D copy_from_user(&new_ka.sa.sa_mask, &act->sa_mask, sizeof(sigset=
32_t));
 		if (ret)
 			return -EFAULT;
+
+		sigact_set_handler(&new_ka, handler, restorer);
 	}
=20
 	ret =3D do_sigaction(sig, act ? &new_ka : NULL, oact ? &old_ka : NULL);
=20
 	if (!ret && oact) {
-		switch (_NSIG_WORDS) {
-		case 4:
-			set32.sig[7] =3D (old_ka.sa.sa_mask.sig[3] >> 32);
-			set32.sig[6] =3D old_ka.sa.sa_mask.sig[3];
-		case 3:
-			set32.sig[5] =3D (old_ka.sa.sa_mask.sig[2] >> 32);
-			set32.sig[4] =3D old_ka.sa.sa_mask.sig[2];
-		case 2:
-			set32.sig[3] =3D (old_ka.sa.sa_mask.sig[1] >> 32);
-			set32.sig[2] =3D old_ka.sa.sa_mask.sig[1];
-		case 1:
-			set32.sig[1] =3D (old_ka.sa.sa_mask.sig[0] >> 32);
-			set32.sig[0] =3D old_ka.sa.sa_mask.sig[0];
-		}
-		ret =3D put_user((long)old_ka.sa.sa_handler, &oact->sa_handler);
-		ret |=3D __copy_to_user(&oact->sa_mask, &set32,
-				      sizeof(sigset32_t));
-		ret |=3D __put_user(old_ka.sa.sa_flags, &oact->sa_flags);
+		ret =3D put_user(IA32_SA_HANDLER(&old_ka), &oact->sa_handler);
+		ret |=3D put_user(old_ka.sa.sa_flags, &oact->sa_flags);
+		ret |=3D put_user(IA32_SA_RESTORER(&old_ka), &oact->sa_restorer);
+		ret |=3D copy_to_user(&oact->sa_mask, &old_ka.sa.sa_mask, sizeof(sigset3=
2_t));
 	}
-
 	return ret;
 }
=20
=20
-extern asmlinkage long sys_rt_sigprocmask(int how, sigset_t *set, sigset_t=
 *oset,
-					  size_t sigsetsize);
+extern asmlinkage long sys_rt_sigprocmask (int how, sigset_t *set, sigset_=
t *oset,
+					   size_t sigsetsize);
=20
 asmlinkage long
-sys32_rt_sigprocmask(int how, sigset32_t *set, sigset32_t *oset,
-		     unsigned int sigsetsize)
+sys32_rt_sigprocmask (int how, sigset32_t *set, sigset32_t *oset, unsigned=
 int sigsetsize)
 {
-	sigset_t s;
-	sigset32_t s32;
-	int ret;
 	mm_segment_t old_fs =3D get_fs();
+	sigset_t s;
+	long ret;
+
+	if (sigsetsize > sizeof(s))
+		return -EINVAL;
=20
 	if (set) {
-		if (copy_from_user (&s32, set, sizeof(sigset32_t)))
+		memset(&s, 0, sizeof(s));
+		if (copy_from_user(&s.sig, set, sigsetsize))
 			return -EFAULT;
-		switch (_NSIG_WORDS) {
-		case 4: s.sig[3] =3D s32.sig[6] | (((long)s32.sig[7]) << 32);
-		case 3: s.sig[2] =3D s32.sig[4] | (((long)s32.sig[5]) << 32);
-		case 2: s.sig[1] =3D s32.sig[2] | (((long)s32.sig[3]) << 32);
-		case 1: s.sig[0] =3D s32.sig[0] | (((long)s32.sig[1]) << 32);
-		}
 	}
-	set_fs (KERNEL_DS);
-	ret =3D sys_rt_sigprocmask(how, set ? &s : NULL, oset ? &s : NULL,
-				 sigsetsize);
-	set_fs (old_fs);
-	if (ret) return ret;
+	set_fs(KERNEL_DS);
+	ret =3D sys_rt_sigprocmask(how, set ? &s : NULL, oset ? &s : NULL, sizeof=
(s));
+	set_fs(old_fs);
+	if (ret)
+		return ret;
 	if (oset) {
-		switch (_NSIG_WORDS) {
-		case 4: s32.sig[7] =3D (s.sig[3] >> 32); s32.sig[6] =3D s.sig[3];
-		case 3: s32.sig[5] =3D (s.sig[2] >> 32); s32.sig[4] =3D s.sig[2];
-		case 2: s32.sig[3] =3D (s.sig[1] >> 32); s32.sig[2] =3D s.sig[1];
-		case 1: s32.sig[1] =3D (s.sig[0] >> 32); s32.sig[0] =3D s.sig[0];
-		}
-		if (copy_to_user (oset, &s32, sizeof(sigset32_t)))
+		if (copy_to_user(oset, &s.sig, sigsetsize))
 			return -EFAULT;
 	}
 	return 0;
 }
=20
+asmlinkage long
+sys32_sigprocmask (int how, unsigned int *set, unsigned int *oset)
+{
+	return sys32_rt_sigprocmask(how, (sigset32_t *) set, (sigset32_t *) oset,=
 sizeof(*set));
+}
+
+struct timespec32 {
+	int	tv_sec;
+	int	tv_nsec;
+};
+
+asmlinkage long
+sys32_rt_sigtimedwait (sigset32_t *uthese, siginfo_t32 *uinfo, struct time=
spec32 *uts,
+		       unsigned int sigsetsize)
+{
+	extern asmlinkage long sys_rt_sigtimedwait (const sigset_t *, siginfo_t *,
+						    const struct timespec *, size_t);
+	extern int copy_siginfo_to_user32 (siginfo_t32 *, siginfo_t *);
+	mm_segment_t old_fs =3D get_fs();
+	struct timespec t;
+	siginfo_t info;
+	sigset_t s;
+	int ret;
+
+	if (copy_from_user(&s.sig, uthese, sizeof(sigset32_t)))
+		return -EFAULT;
+	if (uts) {
+		ret =3D get_user(t.tv_sec, &uts->tv_sec);
+		ret |=3D get_user(t.tv_nsec, &uts->tv_nsec);
+		if (ret)
+			return -EFAULT;
+	}
+	set_fs(KERNEL_DS);
+	ret =3D sys_rt_sigtimedwait(&s, &info, &t, sigsetsize);
+	set_fs(old_fs);
+	if (ret >=3D 0 && uinfo) {
+		if (copy_siginfo_to_user32(uinfo, &info))
+			return -EFAULT;
+	}
+	return ret;
+}
+
+asmlinkage long
+sys32_rt_sigqueueinfo (int pid, int sig, siginfo_t32 *uinfo)
+{
+	extern asmlinkage long sys_rt_sigqueueinfo (int, int, siginfo_t *);
+	extern int copy_siginfo_from_user32 (siginfo_t *to, siginfo_t32 *from);
+	mm_segment_t old_fs =3D get_fs();
+	siginfo_t info;
+	int ret;
+
+	if (copy_siginfo_from_user32(&info, uinfo))
+		return -EFAULT;
+	set_fs(KERNEL_DS);
+	ret =3D sys_rt_sigqueueinfo(pid, sig, &info);
+	set_fs(old_fs);
+	return ret;
+}
+
 static inline int
 put_statfs (struct statfs32 *ubuf, struct statfs *kbuf)
 {
@@ -516,15 +707,15 @@
 extern asmlinkage long sys_statfs(const char * path, struct statfs * buf);
=20
 asmlinkage long
-sys32_statfs(const char * path, struct statfs32 *buf)
+sys32_statfs (const char *path, struct statfs32 *buf)
 {
 	int ret;
 	struct statfs s;
 	mm_segment_t old_fs =3D get_fs();
=20
-	set_fs (KERNEL_DS);
-	ret =3D sys_statfs((const char *)path, &s);
-	set_fs (old_fs);
+	set_fs(KERNEL_DS);
+	ret =3D sys_statfs(path, &s);
+	set_fs(old_fs);
 	if (put_statfs(buf, &s))
 		return -EFAULT;
 	return ret;
@@ -533,15 +724,15 @@
 extern asmlinkage long sys_fstatfs(unsigned int fd, struct statfs * buf);
=20
 asmlinkage long
-sys32_fstatfs(unsigned int fd, struct statfs32 *buf)
+sys32_fstatfs (unsigned int fd, struct statfs32 *buf)
 {
 	int ret;
 	struct statfs s;
 	mm_segment_t old_fs =3D get_fs();
=20
-	set_fs (KERNEL_DS);
+	set_fs(KERNEL_DS);
 	ret =3D sys_fstatfs(fd, &s);
-	set_fs (old_fs);
+	set_fs(old_fs);
 	if (put_statfs(buf, &s))
 		return -EFAULT;
 	return ret;
@@ -559,7 +750,7 @@
 };
=20
 static inline long
-get_tv32(struct timeval *o, struct timeval32 *i)
+get_tv32 (struct timeval *o, struct timeval32 *i)
 {
 	return (!access_ok(VERIFY_READ, i, sizeof(*i)) ||
 		(__get_user(o->tv_sec, &i->tv_sec) |
@@ -567,7 +758,7 @@
 }
=20
 static inline long
-put_tv32(struct timeval32 *o, struct timeval *i)
+put_tv32 (struct timeval32 *o, struct timeval *i)
 {
 	return (!access_ok(VERIFY_WRITE, o, sizeof(*o)) ||
 		(__put_user(i->tv_sec, &o->tv_sec) |
@@ -575,7 +766,7 @@
 }
=20
 static inline long
-get_it32(struct itimerval *o, struct itimerval32 *i)
+get_it32 (struct itimerval *o, struct itimerval32 *i)
 {
 	return (!access_ok(VERIFY_READ, i, sizeof(*i)) ||
 		(__get_user(o->it_interval.tv_sec, &i->it_interval.tv_sec) |
@@ -585,7 +776,7 @@
 }
=20
 static inline long
-put_it32(struct itimerval32 *o, struct itimerval *i)
+put_it32 (struct itimerval32 *o, struct itimerval *i)
 {
 	return (!access_ok(VERIFY_WRITE, o, sizeof(*o)) ||
 		(__put_user(i->it_interval.tv_sec, &o->it_interval.tv_sec) |
@@ -594,10 +785,10 @@
 		 __put_user(i->it_value.tv_usec, &o->it_value.tv_usec)));
 }
=20
-extern int do_getitimer(int which, struct itimerval *value);
+extern int do_getitimer (int which, struct itimerval *value);
=20
 asmlinkage long
-sys32_getitimer(int which, struct itimerval32 *it)
+sys32_getitimer (int which, struct itimerval32 *it)
 {
 	struct itimerval kit;
 	int error;
@@ -609,10 +800,10 @@
 	return error;
 }
=20
-extern int do_setitimer(int which, struct itimerval *, struct itimerval *);
+extern int do_setitimer (int which, struct itimerval *, struct itimerval *=
);
=20
 asmlinkage long
-sys32_setitimer(int which, struct itimerval32 *in, struct itimerval32 *out)
+sys32_setitimer (int which, struct itimerval32 *in, struct itimerval32 *ou=
t)
 {
 	struct itimerval kin, kout;
 	int error;
@@ -632,8 +823,9 @@
 	return 0;
=20
 }
+
 asmlinkage unsigned long
-sys32_alarm(unsigned int seconds)
+sys32_alarm (unsigned int seconds)
 {
 	struct itimerval it_new, it_old;
 	unsigned int oldalarm;
@@ -662,7 +854,7 @@
 extern asmlinkage long sys_gettimeofday (struct timeval *tv, struct timezo=
ne *tz);
=20
 asmlinkage long
-ia32_utime(char * filename, struct utimbuf_32 *times32)
+sys32_utime (char *filename, struct utimbuf_32 *times32)
 {
 	mm_segment_t old_fs =3D get_fs();
 	struct timeval tv[2], *tvp;
@@ -675,20 +867,20 @@
 		if (get_user(tv[1].tv_sec, &times32->mtime))
 			return -EFAULT;
 		tv[1].tv_usec =3D 0;
-		set_fs (KERNEL_DS);
+		set_fs(KERNEL_DS);
 		tvp =3D tv;
 	} else
 		tvp =3D NULL;
 	ret =3D sys_utimes(filename, tvp);
-	set_fs (old_fs);
+	set_fs(old_fs);
 	return ret;
 }
=20
 extern struct timezone sys_tz;
-extern int do_sys_settimeofday(struct timeval *tv, struct timezone *tz);
+extern int do_sys_settimeofday (struct timeval *tv, struct timezone *tz);
=20
 asmlinkage long
-sys32_gettimeofday(struct timeval32 *tv, struct timezone *tz)
+sys32_gettimeofday (struct timeval32 *tv, struct timezone *tz)
 {
 	if (tv) {
 		struct timeval ktv;
@@ -704,7 +896,7 @@
 }
=20
 asmlinkage long
-sys32_settimeofday(struct timeval32 *tv, struct timezone *tz)
+sys32_settimeofday (struct timeval32 *tv, struct timezone *tz)
 {
 	struct timeval ktv;
 	struct timezone ktz;
@@ -777,7 +969,7 @@
 }
=20
 asmlinkage long
-sys32_getdents (unsigned int fd, void * dirent, unsigned int count)
+sys32_getdents (unsigned int fd, struct linux32_dirent *dirent, unsigned i=
nt count)
 {
 	struct file * file;
 	struct linux32_dirent * lastdirent;
@@ -789,7 +981,7 @@
 	if (!file)
 		goto out;
=20
-	buf.current_dir =3D (struct linux32_dirent *) dirent;
+	buf.current_dir =3D dirent;
 	buf.previous =3D NULL;
 	buf.count =3D count;
 	buf.error =3D 0;
@@ -833,7 +1025,7 @@
 }
=20
 asmlinkage long
-sys32_readdir (unsigned int fd, void * dirent, unsigned int count)
+sys32_readdir (unsigned int fd, void *dirent, unsigned int count)
 {
 	int error;
 	struct file * file;
@@ -868,7 +1060,7 @@
 #define ROUND_UP_TIME(x,y) (((x)+(y)-1)/(y))
=20
 asmlinkage long
-sys32_select(int n, fd_set *inp, fd_set *outp, fd_set *exp, struct timeval=
32 *tvp32)
+sys32_select (int n, fd_set *inp, fd_set *outp, fd_set *exp, struct timeva=
l32 *tvp32)
 {
 	fd_set_bits fds;
 	char *bits;
@@ -880,8 +1072,7 @@
 		time_t sec, usec;
=20
 		ret =3D -EFAULT;
-		if (get_user(sec, &tvp32->tv_sec)
-		    || get_user(usec, &tvp32->tv_usec))
+		if (get_user(sec, &tvp32->tv_sec) || get_user(usec, &tvp32->tv_usec))
 			goto out_nofds;
=20
 		ret =3D -EINVAL;
@@ -935,9 +1126,7 @@
 			usec =3D timeout % HZ;
 			usec *=3D (1000000/HZ);
 		}
-		if (put_user(sec, (int *)&tvp32->tv_sec)
-		    || put_user(usec, (int *)&tvp32->tv_usec))
-		{
+		if (put_user(sec, &tvp32->tv_sec) || put_user(usec, &tvp32->tv_usec)) {
 			ret =3D -EFAULT;
 			goto out;
 		}
@@ -971,50 +1160,43 @@
 };
=20
 asmlinkage long
-old_select(struct sel_arg_struct *arg)
+sys32_old_select (struct sel_arg_struct *arg)
 {
 	struct sel_arg_struct a;
=20
 	if (copy_from_user(&a, arg, sizeof(a)))
 		return -EFAULT;
-	return sys32_select(a.n, (fd_set *)A(a.inp), (fd_set *)A(a.outp), (fd_set=
 *)A(a.exp),
-			    (struct timeval32 *)A(a.tvp));
+	return sys32_select(a.n, (fd_set *) A(a.inp), (fd_set *) A(a.outp), (fd_s=
et *) A(a.exp),
+			    (struct timeval32 *) A(a.tvp));
 }
=20
-struct timespec32 {
-	int	tv_sec;
-	int	tv_nsec;
-};
-
-extern asmlinkage long sys_nanosleep(struct timespec *rqtp, struct timespe=
c *rmtp);
+extern asmlinkage long sys_nanosleep (struct timespec *rqtp, struct timesp=
ec *rmtp);
=20
 asmlinkage long
-sys32_nanosleep(struct timespec32 *rqtp, struct timespec32 *rmtp)
+sys32_nanosleep (struct timespec32 *rqtp, struct timespec32 *rmtp)
 {
 	struct timespec t;
 	int ret;
 	mm_segment_t old_fs =3D get_fs ();
=20
-	if (get_user (t.tv_sec, &rqtp->tv_sec) ||
-	    __get_user (t.tv_nsec, &rqtp->tv_nsec))
+	if (get_user (t.tv_sec, &rqtp->tv_sec) || get_user (t.tv_nsec, &rqtp->tv_=
nsec))
 		return -EFAULT;
-	set_fs (KERNEL_DS);
+	set_fs(KERNEL_DS);
 	ret =3D sys_nanosleep(&t, rmtp ? &t : NULL);
-	set_fs (old_fs);
+	set_fs(old_fs);
 	if (rmtp && ret =3D -EINTR) {
-		if (__put_user (t.tv_sec, &rmtp->tv_sec) ||
-		    __put_user (t.tv_nsec, &rmtp->tv_nsec))
+		if (put_user(t.tv_sec, &rmtp->tv_sec) || put_user(t.tv_nsec, &rmtp->tv_n=
sec))
 			return -EFAULT;
 	}
 	return ret;
 }
=20
 struct iovec32 { unsigned int iov_base; int iov_len; };
-asmlinkage ssize_t sys_readv(unsigned long,const struct iovec *,unsigned l=
ong);
-asmlinkage ssize_t sys_writev(unsigned long,const struct iovec *,unsigned =
long);
+asmlinkage ssize_t sys_readv (unsigned long,const struct iovec *,unsigned =
long);
+asmlinkage ssize_t sys_writev (unsigned long,const struct iovec *,unsigned=
 long);
=20
 static struct iovec *
-get_iovec32(struct iovec32 *iov32, struct iovec *iov_buf, u32 count, int t=
ype)
+get_iovec32 (struct iovec32 *iov32, struct iovec *iov_buf, u32 count, int =
type)
 {
 	int i;
 	u32 buf, len;
@@ -1024,24 +1206,23 @@
=20
 	if (!count)
 		return 0;
-	if(verify_area(VERIFY_READ, iov32, sizeof(struct iovec32)*count))
-		return(struct iovec *)0;
+	if (verify_area(VERIFY_READ, iov32, sizeof(struct iovec32)*count))
+		return NULL;
 	if (count > UIO_MAXIOV)
-		return(struct iovec *)0;
+		return NULL;
 	if (count > UIO_FASTIOV) {
 		iov =3D kmalloc(count*sizeof(struct iovec), GFP_KERNEL);
 		if (!iov)
-			return((struct iovec *)0);
+			return NULL;
 	} else
 		iov =3D iov_buf;
=20
 	ivp =3D iov;
 	for (i =3D 0; i < count; i++) {
-		if (__get_user(len, &iov32->iov_len) ||
-		    __get_user(buf, &iov32->iov_base)) {
+		if (__get_user(len, &iov32->iov_len) || __get_user(buf, &iov32->iov_base=
)) {
 			if (iov !=3D iov_buf)
 				kfree(iov);
-			return((struct iovec *)0);
+			return NULL;
 		}
 		if (verify_area(type, (void *)A(buf), len)) {
 			if (iov !=3D iov_buf)
@@ -1049,22 +1230,23 @@
 			return((struct iovec *)0);
 		}
 		ivp->iov_base =3D (void *)A(buf);
-		ivp->iov_len =3D (__kernel_size_t)len;
+		ivp->iov_len =3D (__kernel_size_t) len;
 		iov32++;
 		ivp++;
 	}
-	return(iov);
+	return iov;
 }
=20
 asmlinkage long
-sys32_readv(int fd, struct iovec32 *vector, u32 count)
+sys32_readv (int fd, struct iovec32 *vector, u32 count)
 {
 	struct iovec iovstack[UIO_FASTIOV];
 	struct iovec *iov;
-	int ret;
+	long ret;
 	mm_segment_t old_fs =3D get_fs();
=20
-	if ((iov =3D get_iovec32(vector, iovstack, count, VERIFY_WRITE)) =3D (str=
uct iovec *)0)
+	iov =3D get_iovec32(vector, iovstack, count, VERIFY_WRITE);
+	if (!iov)
 		return -EFAULT;
 	set_fs(KERNEL_DS);
 	ret =3D sys_readv(fd, iov, count);
@@ -1075,14 +1257,15 @@
 }
=20
 asmlinkage long
-sys32_writev(int fd, struct iovec32 *vector, u32 count)
+sys32_writev (int fd, struct iovec32 *vector, u32 count)
 {
 	struct iovec iovstack[UIO_FASTIOV];
 	struct iovec *iov;
-	int ret;
+	long ret;
 	mm_segment_t old_fs =3D get_fs();
=20
-	if ((iov =3D get_iovec32(vector, iovstack, count, VERIFY_READ)) =3D (stru=
ct iovec *)0)
+	iov =3D get_iovec32(vector, iovstack, count, VERIFY_READ);
+	if (!iov)
 		return -EFAULT;
 	set_fs(KERNEL_DS);
 	ret =3D sys_writev(fd, iov, count);
@@ -1100,45 +1283,66 @@
 	int	rlim_max;
 };
=20
-extern asmlinkage long sys_getrlimit(unsigned int resource, struct rlimit =
*rlim);
+extern asmlinkage long sys_getrlimit (unsigned int resource, struct rlimit=
 *rlim);
=20
 asmlinkage long
-sys32_getrlimit(unsigned int resource, struct rlimit32 *rlim)
+sys32_old_getrlimit (unsigned int resource, struct rlimit32 *rlim)
 {
+	mm_segment_t old_fs =3D get_fs();
 	struct rlimit r;
 	int ret;
-	mm_segment_t old_fs =3D get_fs ();
=20
-	set_fs (KERNEL_DS);
+	set_fs(KERNEL_DS);
+	ret =3D sys_getrlimit(resource, &r);
+	set_fs(old_fs);
+	if (!ret) {
+		ret =3D put_user(RESOURCE32(r.rlim_cur), &rlim->rlim_cur);
+		ret |=3D put_user(RESOURCE32(r.rlim_max), &rlim->rlim_max);
+	}
+	return ret;
+}
+
+asmlinkage long
+sys32_getrlimit (unsigned int resource, struct rlimit32 *rlim)
+{
+	mm_segment_t old_fs =3D get_fs();
+	struct rlimit r;
+	int ret;
+
+	set_fs(KERNEL_DS);
 	ret =3D sys_getrlimit(resource, &r);
-	set_fs (old_fs);
+	set_fs(old_fs);
 	if (!ret) {
-		ret =3D put_user (RESOURCE32(r.rlim_cur), &rlim->rlim_cur);
-		ret |=3D __put_user (RESOURCE32(r.rlim_max), &rlim->rlim_max);
+		if (r.rlim_cur >=3D 0xffffffff)
+			r.rlim_cur =3D 0xffffffff;
+		if (r.rlim_max >=3D 0xffffffff)
+			r.rlim_max =3D 0xffffffff;
+		ret =3D put_user(r.rlim_cur, &rlim->rlim_cur);
+		ret |=3D put_user(r.rlim_max, &rlim->rlim_max);
 	}
 	return ret;
 }
=20
-extern asmlinkage long sys_setrlimit(unsigned int resource, struct rlimit =
*rlim);
+extern asmlinkage long sys_setrlimit (unsigned int resource, struct rlimit=
 *rlim);
=20
 asmlinkage long
-sys32_setrlimit(unsigned int resource, struct rlimit32 *rlim)
+sys32_setrlimit (unsigned int resource, struct rlimit32 *rlim)
 {
 	struct rlimit r;
 	int ret;
-	mm_segment_t old_fs =3D get_fs ();
+	mm_segment_t old_fs =3D get_fs();
=20
-	if (resource >=3D RLIM_NLIMITS) return -EINVAL;
-	if (get_user (r.rlim_cur, &rlim->rlim_cur) ||
-	    __get_user (r.rlim_max, &rlim->rlim_max))
+	if (resource >=3D RLIM_NLIMITS)
+		return -EINVAL;
+	if (get_user(r.rlim_cur, &rlim->rlim_cur) || get_user(r.rlim_max, &rlim->=
rlim_max))
 		return -EFAULT;
 	if (r.rlim_cur =3D RLIM_INFINITY32)
 		r.rlim_cur =3D RLIM_INFINITY;
 	if (r.rlim_max =3D RLIM_INFINITY32)
 		r.rlim_max =3D RLIM_INFINITY;
-	set_fs (KERNEL_DS);
+	set_fs(KERNEL_DS);
 	ret =3D sys_setrlimit(resource, &r);
-	set_fs (old_fs);
+	set_fs(old_fs);
 	return ret;
 }
=20
@@ -1157,7 +1361,7 @@
 };
=20
 static inline int
-shape_msg(struct msghdr *mp, struct msghdr32 *mp32)
+shape_msg (struct msghdr *mp, struct msghdr32 *mp32)
 {
 	int ret;
 	unsigned int i;
@@ -1189,7 +1393,7 @@
  */
=20
 static inline int
-verify_iovec32(struct msghdr *m, struct iovec *iov, char *address, int mod=
e)
+verify_iovec32 (struct msghdr *m, struct iovec *iov, char *address, int mo=
de)
 {
 	int size, err, ct;
 	struct iovec32 *iov32;
@@ -1224,8 +1428,8 @@
 	return err;
 }
=20
-extern __inline__ void
-sockfd_put(struct socket *sock)
+static inline void
+sockfd_put (struct socket *sock)
 {
 	fput(sock->file);
 }
@@ -1236,13 +1440,14 @@
 					   24 for IPv6,
 					   about 80 for AX.25 */
=20
-extern struct socket *sockfd_lookup(int fd, int *err);
+extern struct socket *sockfd_lookup (int fd, int *err);
=20
 /*
  *	BSD sendmsg interface
  */
=20
-int sys32_sendmsg(int fd, struct msghdr32 *msg, unsigned flags)
+int
+sys32_sendmsg (int fd, struct msghdr32 *msg, unsigned flags)
 {
 	struct socket *sock;
 	char address[MAX_SOCK_ADDR];
@@ -1406,9 +1611,9 @@
=20
 /* Argument list sizes for sys_socketcall */
 #define AL(x) ((x) * sizeof(u32))
-static unsigned char nas[18]=3D{AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
-				AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
-				AL(6),AL(2),AL(5),AL(5),AL(3),AL(3)};
+static const unsigned char nas[18]=3D{AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
+				    AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
+				    AL(6),AL(2),AL(5),AL(5),AL(3),AL(3)};
 #undef AL
=20
 extern asmlinkage long sys_bind(int fd, struct sockaddr *umyaddr, int addr=
len);
@@ -1437,7 +1642,8 @@
 extern asmlinkage long sys_shutdown(int fd, int how);
 extern asmlinkage long sys_listen(int fd, int backlog);
=20
-asmlinkage long sys32_socketcall(int call, u32 *args)
+asmlinkage long
+sys32_socketcall (int call, u32 *args)
 {
 	int ret;
 	u32 a[6];
@@ -1465,16 +1671,13 @@
 			ret =3D sys_listen(a0, a1);
 			break;
 		case SYS_ACCEPT:
-			ret =3D sys_accept(a0, (struct sockaddr *)A(a1),
-					  (int *)A(a[2]));
+			ret =3D sys_accept(a0, (struct sockaddr *)A(a1), (int *)A(a[2]));
 			break;
 		case SYS_GETSOCKNAME:
-			ret =3D sys_getsockname(a0, (struct sockaddr *)A(a1),
-					       (int *)A(a[2]));
+			ret =3D sys_getsockname(a0, (struct sockaddr *)A(a1), (int *)A(a[2]));
 			break;
 		case SYS_GETPEERNAME:
-			ret =3D sys_getpeername(a0, (struct sockaddr *)A(a1),
-					       (int *)A(a[2]));
+			ret =3D sys_getpeername(a0, (struct sockaddr *)A(a1), (int *)A(a[2]));
 			break;
 		case SYS_SOCKETPAIR:
 			ret =3D sys_socketpair(a0, a1, a[2], (int *)A(a[3]));
@@ -1502,12 +1705,10 @@
 			ret =3D sys_getsockopt(a0, a1, a[2], a[3], a[4]);
 			break;
 		case SYS_SENDMSG:
-			ret =3D sys32_sendmsg(a0, (struct msghdr32 *)A(a1),
-					     a[2]);
+			ret =3D sys32_sendmsg(a0, (struct msghdr32 *) A(a1), a[2]);
 			break;
 		case SYS_RECVMSG:
-			ret =3D sys32_recvmsg(a0, (struct msghdr32 *)A(a1),
-					     a[2]);
+			ret =3D sys32_recvmsg(a0, (struct msghdr32 *) A(a1), a[2]);
 			break;
 		default:
 			ret =3D EINVAL;
@@ -1574,10 +1775,27 @@
 	unsigned short          shm_nattch;
 };
=20
+struct ipc_kludge {
+	struct msgbuf *msgp;
+	long msgtyp;
+};
+
+#define SEMOP		 1
+#define SEMGET		 2
+#define SEMCTL		 3
+#define MSGSND		11
+#define MSGRCV		12
+#define MSGGET		13
+#define MSGCTL		14
+#define SHMAT		21
+#define SHMDT		22
+#define SHMGET		23
+#define SHMCTL		24
+
 #define IPCOP_MASK(__x)	(1UL << (__x))
=20
 static int
-do_sys32_semctl(int first, int second, int third, void *uptr)
+do_sys32_semctl (int first, int second, int third, void *uptr)
 {
 	union semun fourth;
 	u32 pad;
@@ -1590,7 +1808,7 @@
 		return -EINVAL;
 	if (get_user(pad, (u32 *)uptr))
 		return -EFAULT;
-	if(third =3D SETVAL)
+	if (third =3D SETVAL)
 		fourth.val =3D (int)pad;
 	else
 		fourth.__pad =3D (void *)A(pad);
@@ -1607,44 +1825,38 @@
 	case GETALL:
 	case SETVAL:
 	case SETALL:
-		err =3D sys_semctl (first, second, third, fourth);
+		err =3D sys_semctl(first, second, third, fourth);
 		break;
=20
 	case IPC_STAT:
 	case SEM_STAT:
 		usp =3D (struct semid_ds32 *)A(pad);
 		fourth.__pad =3D &s;
-		old_fs =3D get_fs ();
-		set_fs (KERNEL_DS);
-		err =3D sys_semctl (first, second, third, fourth);
-		set_fs (old_fs);
+		old_fs =3D get_fs();
+		set_fs(KERNEL_DS);
+		err =3D sys_semctl(first, second, third, fourth);
+		set_fs(old_fs);
 		err2 =3D put_user(s.sem_perm.key, &usp->sem_perm.key);
-		err2 |=3D __put_user(s.sem_perm.uid, &usp->sem_perm.uid);
-		err2 |=3D __put_user(s.sem_perm.gid, &usp->sem_perm.gid);
-		err2 |=3D __put_user(s.sem_perm.cuid,
-				   &usp->sem_perm.cuid);
-		err2 |=3D __put_user (s.sem_perm.cgid,
-				    &usp->sem_perm.cgid);
-		err2 |=3D __put_user (s.sem_perm.mode,
-				    &usp->sem_perm.mode);
-		err2 |=3D __put_user (s.sem_perm.seq, &usp->sem_perm.seq);
-		err2 |=3D __put_user (s.sem_otime, &usp->sem_otime);
-		err2 |=3D __put_user (s.sem_ctime, &usp->sem_ctime);
-		err2 |=3D __put_user (s.sem_nsems, &usp->sem_nsems);
+		err2 |=3D put_user(s.sem_perm.uid, &usp->sem_perm.uid);
+		err2 |=3D put_user(s.sem_perm.gid, &usp->sem_perm.gid);
+		err2 |=3D put_user(s.sem_perm.cuid, &usp->sem_perm.cuid);
+		err2 |=3D put_user(s.sem_perm.cgid, &usp->sem_perm.cgid);
+		err2 |=3D put_user(s.sem_perm.mode, &usp->sem_perm.mode);
+		err2 |=3D put_user(s.sem_perm.seq, &usp->sem_perm.seq);
+		err2 |=3D put_user(s.sem_otime, &usp->sem_otime);
+		err2 |=3D put_user(s.sem_ctime, &usp->sem_ctime);
+		err2 |=3D put_user(s.sem_nsems, &usp->sem_nsems);
 		if (err2)
 			err =3D -EFAULT;
 		break;
-
 	}
-
 	return err;
 }
=20
 static int
 do_sys32_msgsnd (int first, int second, int third, void *uptr)
 {
-	struct msgbuf *p =3D kmalloc (second + sizeof (struct msgbuf)
-				    + 4, GFP_USER);
+	struct msgbuf *p =3D kmalloc (second + sizeof(struct msgbuf) + 4, GFP_USE=
R);
 	struct msgbuf32 *up =3D (struct msgbuf32 *)uptr;
 	mm_segment_t old_fs;
 	int err;
@@ -1656,17 +1868,16 @@
 	if (err)
 		goto out;
 	old_fs =3D get_fs ();
-	set_fs (KERNEL_DS);
+	set_fs(KERNEL_DS);
 	err =3D sys_msgsnd (first, p, second, third);
-	set_fs (old_fs);
+	set_fs(old_fs);
 out:
 	kfree (p);
 	return err;
 }
=20
 static int
-do_sys32_msgrcv (int first, int second, int msgtyp, int third,
-		 int version, void *uptr)
+do_sys32_msgrcv (int first, int second, int msgtyp, int third, int version=
, void *uptr)
 {
 	struct msgbuf32 *up;
 	struct msgbuf *p;
@@ -1691,9 +1902,9 @@
 	if (!p)
 		goto out;
 	old_fs =3D get_fs ();
-	set_fs (KERNEL_DS);
+	set_fs(KERNEL_DS);
 	err =3D sys_msgrcv (first, p, second + 4, msgtyp, third);
-	set_fs (old_fs);
+	set_fs(old_fs);
 	if (err < 0)
 		goto free_then_out;
 	up =3D (struct msgbuf32 *)uptr;
@@ -1720,49 +1931,47 @@
 	case IPC_INFO:
 	case IPC_RMID:
 	case MSG_INFO:
-		err =3D sys_msgctl (first, second, (struct msqid_ds *)uptr);
+		err =3D sys_msgctl(first, second, (struct msqid_ds *)uptr);
 		break;
=20
 	case IPC_SET:
-		err =3D get_user (m.msg_perm.uid, &up->msg_perm.uid);
-		err |=3D __get_user (m.msg_perm.gid, &up->msg_perm.gid);
-		err |=3D __get_user (m.msg_perm.mode, &up->msg_perm.mode);
-		err |=3D __get_user (m.msg_qbytes, &up->msg_qbytes);
+		err =3D get_user(m.msg_perm.uid, &up->msg_perm.uid);
+		err |=3D get_user(m.msg_perm.gid, &up->msg_perm.gid);
+		err |=3D get_user(m.msg_perm.mode, &up->msg_perm.mode);
+		err |=3D get_user(m.msg_qbytes, &up->msg_qbytes);
 		if (err)
 			break;
-		old_fs =3D get_fs ();
-		set_fs (KERNEL_DS);
-		err =3D sys_msgctl (first, second, &m);
-		set_fs (old_fs);
+		old_fs =3D get_fs();
+		set_fs(KERNEL_DS);
+		err =3D sys_msgctl(first, second, &m);
+		set_fs(old_fs);
 		break;
=20
 	case IPC_STAT:
 	case MSG_STAT:
-		old_fs =3D get_fs ();
-		set_fs (KERNEL_DS);
-		err =3D sys_msgctl (first, second, (void *) &m64);
-		set_fs (old_fs);
-		err2 =3D put_user (m64.msg_perm.key, &up->msg_perm.key);
-		err2 |=3D __put_user(m64.msg_perm.uid, &up->msg_perm.uid);
-		err2 |=3D __put_user(m64.msg_perm.gid, &up->msg_perm.gid);
-		err2 |=3D __put_user(m64.msg_perm.cuid, &up->msg_perm.cuid);
-		err2 |=3D __put_user(m64.msg_perm.cgid, &up->msg_perm.cgid);
-		err2 |=3D __put_user(m64.msg_perm.mode, &up->msg_perm.mode);
-		err2 |=3D __put_user(m64.msg_perm.seq, &up->msg_perm.seq);
-		err2 |=3D __put_user(m64.msg_stime, &up->msg_stime);
-		err2 |=3D __put_user(m64.msg_rtime, &up->msg_rtime);
-		err2 |=3D __put_user(m64.msg_ctime, &up->msg_ctime);
-		err2 |=3D __put_user(m64.msg_cbytes, &up->msg_cbytes);
-		err2 |=3D __put_user(m64.msg_qnum, &up->msg_qnum);
-		err2 |=3D __put_user(m64.msg_qbytes, &up->msg_qbytes);
-		err2 |=3D __put_user(m64.msg_lspid, &up->msg_lspid);
-		err2 |=3D __put_user(m64.msg_lrpid, &up->msg_lrpid);
+		old_fs =3D get_fs();
+		set_fs(KERNEL_DS);
+		err =3D sys_msgctl(first, second, (void *) &m64);
+		set_fs(old_fs);
+		err2 =3D put_user(m64.msg_perm.key, &up->msg_perm.key);
+		err2 |=3D put_user(m64.msg_perm.uid, &up->msg_perm.uid);
+		err2 |=3D put_user(m64.msg_perm.gid, &up->msg_perm.gid);
+		err2 |=3D put_user(m64.msg_perm.cuid, &up->msg_perm.cuid);
+		err2 |=3D put_user(m64.msg_perm.cgid, &up->msg_perm.cgid);
+		err2 |=3D put_user(m64.msg_perm.mode, &up->msg_perm.mode);
+		err2 |=3D put_user(m64.msg_perm.seq, &up->msg_perm.seq);
+		err2 |=3D put_user(m64.msg_stime, &up->msg_stime);
+		err2 |=3D put_user(m64.msg_rtime, &up->msg_rtime);
+		err2 |=3D put_user(m64.msg_ctime, &up->msg_ctime);
+		err2 |=3D put_user(m64.msg_cbytes, &up->msg_cbytes);
+		err2 |=3D put_user(m64.msg_qnum, &up->msg_qnum);
+		err2 |=3D put_user(m64.msg_qbytes, &up->msg_qbytes);
+		err2 |=3D put_user(m64.msg_lspid, &up->msg_lspid);
+		err2 |=3D put_user(m64.msg_lrpid, &up->msg_lrpid);
 		if (err2)
 			err =3D -EFAULT;
 		break;
-
 	}
-
 	return err;
 }
=20
@@ -1774,8 +1983,8 @@
 	int err;
=20
 	if (version =3D 1)
-		return -EINVAL;
-	err =3D sys_shmat (first, uptr, second, &raddr);
+		return -EINVAL;	/* iBCS2 emulator entry point: unsupported */
+	err =3D sys_shmat(first, uptr, second, &raddr);
 	if (err)
 		return err;
 	return put_user(raddr, uaddr);
@@ -1806,60 +2015,55 @@
 		break;
 	case IPC_SET:
 		err =3D get_user (s.shm_perm.uid, &up->shm_perm.uid);
-		err |=3D __get_user (s.shm_perm.gid, &up->shm_perm.gid);
-		err |=3D __get_user (s.shm_perm.mode, &up->shm_perm.mode);
+		err |=3D get_user(s.shm_perm.gid, &up->shm_perm.gid);
+		err |=3D get_user(s.shm_perm.mode, &up->shm_perm.mode);
 		if (err)
 			break;
-		old_fs =3D get_fs ();
-		set_fs (KERNEL_DS);
-		err =3D sys_shmctl (first, second, &s);
-		set_fs (old_fs);
+		old_fs =3D get_fs();
+		set_fs(KERNEL_DS);
+		err =3D sys_shmctl(first, second, &s);
+		set_fs(old_fs);
 		break;
=20
 	case IPC_STAT:
 	case SHM_STAT:
-		old_fs =3D get_fs ();
-		set_fs (KERNEL_DS);
+		old_fs =3D get_fs();
+		set_fs(KERNEL_DS);
 		err =3D sys_shmctl (first, second, (void *) &s64);
-		set_fs (old_fs);
+		set_fs(old_fs);
 		if (err < 0)
 			break;
-		err2 =3D put_user (s64.shm_perm.key, &up->shm_perm.key);
-		err2 |=3D __put_user (s64.shm_perm.uid, &up->shm_perm.uid);
-		err2 |=3D __put_user (s64.shm_perm.gid, &up->shm_perm.gid);
-		err2 |=3D __put_user (s64.shm_perm.cuid,
-				    &up->shm_perm.cuid);
-		err2 |=3D __put_user (s64.shm_perm.cgid,
-				    &up->shm_perm.cgid);
-		err2 |=3D __put_user (s64.shm_perm.mode,
-				    &up->shm_perm.mode);
-		err2 |=3D __put_user (s64.shm_perm.seq, &up->shm_perm.seq);
-		err2 |=3D __put_user (s64.shm_atime, &up->shm_atime);
-		err2 |=3D __put_user (s64.shm_dtime, &up->shm_dtime);
-		err2 |=3D __put_user (s64.shm_ctime, &up->shm_ctime);
-		err2 |=3D __put_user (s64.shm_segsz, &up->shm_segsz);
-		err2 |=3D __put_user (s64.shm_nattch, &up->shm_nattch);
-		err2 |=3D __put_user (s64.shm_cpid, &up->shm_cpid);
-		err2 |=3D __put_user (s64.shm_lpid, &up->shm_lpid);
+		err2 =3D put_user(s64.shm_perm.key, &up->shm_perm.key);
+		err2 |=3D put_user(s64.shm_perm.uid, &up->shm_perm.uid);
+		err2 |=3D put_user(s64.shm_perm.gid, &up->shm_perm.gid);
+		err2 |=3D put_user(s64.shm_perm.cuid, &up->shm_perm.cuid);
+		err2 |=3D put_user(s64.shm_perm.cgid, &up->shm_perm.cgid);
+		err2 |=3D put_user(s64.shm_perm.mode, &up->shm_perm.mode);
+		err2 |=3D put_user(s64.shm_perm.seq, &up->shm_perm.seq);
+		err2 |=3D put_user(s64.shm_atime, &up->shm_atime);
+		err2 |=3D put_user(s64.shm_dtime, &up->shm_dtime);
+		err2 |=3D put_user(s64.shm_ctime, &up->shm_ctime);
+		err2 |=3D put_user(s64.shm_segsz, &up->shm_segsz);
+		err2 |=3D put_user(s64.shm_nattch, &up->shm_nattch);
+		err2 |=3D put_user(s64.shm_cpid, &up->shm_cpid);
+		err2 |=3D put_user(s64.shm_lpid, &up->shm_lpid);
 		if (err2)
 			err =3D -EFAULT;
 		break;
=20
 	case SHM_INFO:
-		old_fs =3D get_fs ();
-		set_fs (KERNEL_DS);
-		err =3D sys_shmctl (first, second, (void *)&si);
-		set_fs (old_fs);
+		old_fs =3D get_fs();
+		set_fs(KERNEL_DS);
+		err =3D sys_shmctl(first, second, (void *)&si);
+		set_fs(old_fs);
 		if (err < 0)
 			break;
-		err2 =3D put_user (si.used_ids, &uip->used_ids);
-		err2 |=3D __put_user (si.shm_tot, &uip->shm_tot);
-		err2 |=3D __put_user (si.shm_rss, &uip->shm_rss);
-		err2 |=3D __put_user (si.shm_swp, &uip->shm_swp);
-		err2 |=3D __put_user (si.swap_attempts,
-				    &uip->swap_attempts);
-		err2 |=3D __put_user (si.swap_successes,
-				    &uip->swap_successes);
+		err2 =3D put_user(si.used_ids, &uip->used_ids);
+		err2 |=3D put_user(si.shm_tot, &uip->shm_tot);
+		err2 |=3D put_user(si.shm_rss, &uip->shm_rss);
+		err2 |=3D put_user(si.shm_swp, &uip->shm_swp);
+		err2 |=3D put_user(si.swap_attempts, &uip->swap_attempts);
+		err2 |=3D put_user(si.swap_successes, &uip->swap_successes);
 		if (err2)
 			err =3D -EFAULT;
 		break;
@@ -1877,53 +2081,48 @@
 	call &=3D 0xffff;
=20
 	switch (call) {
-
-	case SEMOP:
+	      case SEMOP:
 		/* struct sembuf is the same on 32 and 64bit :)) */
-		err =3D sys_semop (first, (struct sembuf *)AA(ptr),
-				 second);
-		break;
-	case SEMGET:
-		err =3D sys_semget (first, second, third);
-		break;
-	case SEMCTL:
-		err =3D do_sys32_semctl (first, second, third,
-				       (void *)AA(ptr));
-		break;
+		return sys_semop(first, (struct sembuf *)AA(ptr), second);
+	      case SEMGET:
+		return sys_semget(first, second, third);
+	      case SEMCTL:
+		if (third & IPC_64) {
+			printk("sys32_ipc(SEMCTL): no IPC_64 version; please fix me.");
+			return -ENOSYS;
+		}
+		return do_sys32_semctl(first, second, third, (void *)AA(ptr));
=20
-	case MSGSND:
-		err =3D do_sys32_msgsnd (first, second, third,
-				       (void *)AA(ptr));
-		break;
-	case MSGRCV:
-		err =3D do_sys32_msgrcv (first, second, fifth, third,
-				       version, (void *)AA(ptr));
-		break;
-	case MSGGET:
-		err =3D sys_msgget ((key_t) first, second);
-		break;
-	case MSGCTL:
-		err =3D do_sys32_msgctl (first, second, (void *)AA(ptr));
-		break;
+	      case MSGSND:
+		return do_sys32_msgsnd(first, second, third, (void *)AA(ptr));
+	      case MSGRCV:
+		return do_sys32_msgrcv(first, second, fifth, third, version, (void *)AA(=
ptr));
+	      case MSGGET:
+		return sys_msgget((key_t) first, second);
+	      case MSGCTL:
+		if (second & IPC_64) {
+			printk("sys32_ipc(MSGCTL): no IPC_64 version; please fix me.");
+			return -ENOSYS;
+		}
+		return do_sys32_msgctl(first, second, (void *)AA(ptr));
=20
-	case SHMAT:
-		err =3D do_sys32_shmat (first, second, third, version, (void *)AA(ptr));
+	      case SHMAT:
+		err =3D do_sys32_shmat(first, second, third, version, (void *)AA(ptr));
 		break;
-	case SHMDT:
-		err =3D sys_shmdt ((char *)AA(ptr));
-		break;
-	case SHMGET:
-		err =3D sys_shmget (first, second, third);
-		break;
-	case SHMCTL:
-		err =3D do_sys32_shmctl (first, second, (void *)AA(ptr));
-		break;
-	default:
-		err =3D -EINVAL;
-		break;
-	}
+	      case SHMDT:
+		return sys_shmdt((char *)AA(ptr));
+	      case SHMGET:
+		return sys_shmget(first, second, third);
+	      case SHMCTL:
+		if (second & IPC_64) {
+			printk("sys32_ipc(SHMCTL): no IPC_64 version; please fix me.");
+			return -ENOSYS;
+		}
+		return do_sys32_shmctl(first, second, (void *)AA(ptr));
=20
-	return err;
+	      default:
+		return -EINVAL;
+	}
 }
=20
 /*
@@ -1931,7 +2130,8 @@
  * sys_gettimeofday().  IA64 did this but i386 Linux did not
  * so we have to implement this system call here.
  */
-asmlinkage long sys32_time(int * tloc)
+asmlinkage long
+sys32_time (int *tloc)
 {
 	int i;
=20
@@ -1939,7 +2139,7 @@
 	   stuff it to user space. No side effects */
 	i =3D CURRENT_TIME;
 	if (tloc) {
-		if (put_user(i,tloc))
+		if (put_user(i, tloc))
 			i =3D -EFAULT;
 	}
 	return i;
@@ -1991,8 +2191,7 @@
 }
=20
 asmlinkage long
-sys32_wait4(__kernel_pid_t32 pid, unsigned int *stat_addr, int options,
-	    struct rusage32 *ru)
+sys32_wait4 (int pid, unsigned int *stat_addr, int options, struct rusage3=
2 *ru)
 {
 	if (!ru)
 		return sys_wait4(pid, stat_addr, options, NULL);
@@ -2002,37 +2201,38 @@
 		unsigned int status;
 		mm_segment_t old_fs =3D get_fs();
=20
-		set_fs (KERNEL_DS);
+		set_fs(KERNEL_DS);
 		ret =3D sys_wait4(pid, stat_addr ? &status : NULL, options, &r);
-		set_fs (old_fs);
-		if (put_rusage (ru, &r)) return -EFAULT;
-		if (stat_addr && put_user (status, stat_addr))
+		set_fs(old_fs);
+		if (put_rusage(ru, &r))
+			return -EFAULT;
+		if (stat_addr && put_user(status, stat_addr))
 			return -EFAULT;
 		return ret;
 	}
 }
=20
 asmlinkage long
-sys32_waitpid(__kernel_pid_t32 pid, unsigned int *stat_addr, int options)
+sys32_waitpid (int pid, unsigned int *stat_addr, int options)
 {
 	return sys32_wait4(pid, stat_addr, options, NULL);
 }
=20
=20
-extern asmlinkage long
-sys_getrusage(int who, struct rusage *ru);
+extern asmlinkage long sys_getrusage (int who, struct rusage *ru);
=20
 asmlinkage long
-sys32_getrusage(int who, struct rusage32 *ru)
+sys32_getrusage (int who, struct rusage32 *ru)
 {
 	struct rusage r;
 	int ret;
 	mm_segment_t old_fs =3D get_fs();
=20
-	set_fs (KERNEL_DS);
+	set_fs(KERNEL_DS);
 	ret =3D sys_getrusage(who, &r);
-	set_fs (old_fs);
-	if (put_rusage (ru, &r)) return -EFAULT;
+	set_fs(old_fs);
+	if (put_rusage (ru, &r))
+		return -EFAULT;
 	return ret;
 }
=20
@@ -2043,41 +2243,41 @@
 	__kernel_clock_t32 tms_cstime;
 };
=20
-extern asmlinkage long sys_times(struct tms * tbuf);
+extern asmlinkage long sys_times (struct tms * tbuf);
=20
 asmlinkage long
-sys32_times(struct tms32 *tbuf)
+sys32_times (struct tms32 *tbuf)
 {
+	mm_segment_t old_fs =3D get_fs();
 	struct tms t;
 	long ret;
-	mm_segment_t old_fs =3D get_fs ();
 	int err;
=20
-	set_fs (KERNEL_DS);
+	set_fs(KERNEL_DS);
 	ret =3D sys_times(tbuf ? &t : NULL);
-	set_fs (old_fs);
+	set_fs(old_fs);
 	if (tbuf) {
 		err =3D put_user (IA32_TICK(t.tms_utime), &tbuf->tms_utime);
-		err |=3D __put_user (IA32_TICK(t.tms_stime), &tbuf->tms_stime);
-		err |=3D __put_user (IA32_TICK(t.tms_cutime), &tbuf->tms_cutime);
-		err |=3D __put_user (IA32_TICK(t.tms_cstime), &tbuf->tms_cstime);
+		err |=3D put_user (IA32_TICK(t.tms_stime), &tbuf->tms_stime);
+		err |=3D put_user (IA32_TICK(t.tms_cutime), &tbuf->tms_cutime);
+		err |=3D put_user (IA32_TICK(t.tms_cstime), &tbuf->tms_cstime);
 		if (err)
 			ret =3D -EFAULT;
 	}
 	return IA32_TICK(ret);
 }
=20
-unsigned int
+static unsigned int
 ia32_peek (struct pt_regs *regs, struct task_struct *child, unsigned long =
addr, unsigned int *val)
 {
 	size_t copied;
 	unsigned int ret;
=20
 	copied =3D access_process_vm(child, addr, val, sizeof(*val), 0);
-	return(copied !=3D sizeof(ret) ? -EIO : 0);
+	return (copied !=3D sizeof(ret)) ? -EIO : 0;
 }
=20
-unsigned int
+static unsigned int
 ia32_poke (struct pt_regs *regs, struct task_struct *child, unsigned long =
addr, unsigned int val)
 {
=20
@@ -2107,113 +2307,70 @@
 #define PT_UESP	15
 #define PT_SS	16
=20
-unsigned int
-getreg(struct task_struct *child, int regno)
+static unsigned int
+getreg (struct task_struct *child, int regno)
 {
 	struct pt_regs *child_regs;
=20
 	child_regs =3D ia64_task_regs(child);
 	switch (regno / sizeof(int)) {
-
-	case PT_EBX:
-		return(child_regs->r11);
-	case PT_ECX:
-		return(child_regs->r9);
-	case PT_EDX:
-		return(child_regs->r10);
-	case PT_ESI:
-		return(child_regs->r14);
-	case PT_EDI:
-		return(child_regs->r15);
-	case PT_EBP:
-		return(child_regs->r13);
-	case PT_EAX:
-	case PT_ORIG_EAX:
-		return(child_regs->r8);
-	case PT_EIP:
-		return(child_regs->cr_iip);
-	case PT_UESP:
-		return(child_regs->r12);
-	case PT_EFL:
-		return(child->thread.eflag);
-	case PT_DS:
-	case PT_ES:
-	case PT_FS:
-	case PT_GS:
-	case PT_SS:
-		return((unsigned int)__USER_DS);
-	case PT_CS:
-		return((unsigned int)__USER_CS);
-	default:
-		printk(KERN_ERR "getregs:unknown register %d\n", regno);
+	      case PT_EBX: return child_regs->r11;
+	      case PT_ECX: return child_regs->r9;
+	      case PT_EDX: return child_regs->r10;
+	      case PT_ESI: return child_regs->r14;
+	      case PT_EDI: return child_regs->r15;
+	      case PT_EBP: return child_regs->r13;
+	      case PT_EAX: return child_regs->r8;
+	      case PT_ORIG_EAX: return child_regs->r1; /* see dispatch_to_ia32_ha=
ndler() */
+	      case PT_EIP: return child_regs->cr_iip;
+	      case PT_UESP: return child_regs->r12;
+	      case PT_EFL: return child->thread.eflag;
+	      case PT_DS: case PT_ES: case PT_FS: case PT_GS: case PT_SS:
+		return __USER_DS;
+	      case PT_CS: return __USER_CS;
+	      default:
+		printk(KERN_ERR "getreg:unknown register %d\n", regno);
 		break;
-
 	}
-	return(0);
+	return 0;
 }
=20
-void
-putreg(struct task_struct *child, int regno, unsigned int value)
+static void
+putreg (struct task_struct *child, int regno, unsigned int value)
 {
 	struct pt_regs *child_regs;
=20
 	child_regs =3D ia64_task_regs(child);
 	switch (regno / sizeof(int)) {
-
-	case PT_EBX:
-		child_regs->r11 =3D value;
-		break;
-	case PT_ECX:
-		child_regs->r9 =3D value;
-		break;
-	case PT_EDX:
-		child_regs->r10 =3D value;
-		break;
-	case PT_ESI:
-		child_regs->r14 =3D value;
-		break;
-	case PT_EDI:
-		child_regs->r15 =3D value;
-		break;
-	case PT_EBP:
-		child_regs->r13 =3D value;
-		break;
-	case PT_EAX:
-	case PT_ORIG_EAX:
-		child_regs->r8 =3D value;
-		break;
-	case PT_EIP:
-		child_regs->cr_iip =3D value;
-		break;
-	case PT_UESP:
-		child_regs->r12 =3D value;
-		break;
-	case PT_EFL:
-		child->thread.eflag =3D value;
-		break;
-	case PT_DS:
-	case PT_ES:
-	case PT_FS:
-	case PT_GS:
-	case PT_SS:
+	      case PT_EBX: child_regs->r11 =3D value; break;
+	      case PT_ECX: child_regs->r9 =3D value; break;
+	      case PT_EDX: child_regs->r10 =3D value; break;
+	      case PT_ESI: child_regs->r14 =3D value; break;
+	      case PT_EDI: child_regs->r15 =3D value; break;
+	      case PT_EBP: child_regs->r13 =3D value; break;
+	      case PT_EAX: child_regs->r8 =3D value; break;
+	      case PT_ORIG_EAX: child_regs->r1 =3D value; break;
+	      case PT_EIP: child_regs->cr_iip =3D value; break;
+	      case PT_UESP: child_regs->r12 =3D value; break;
+	      case PT_EFL: child->thread.eflag =3D value; break;
+	      case PT_DS: case PT_ES: case PT_FS: case PT_GS: case PT_SS:
 		if (value !=3D __USER_DS)
 			printk(KERN_ERR "setregs:try to set invalid segment register %d =3D %x\=
n",
 			       regno, value);
 		break;
-	case PT_CS:
+	      case PT_CS:
 		if (value !=3D __USER_CS)
 			printk(KERN_ERR "setregs:try to set invalid segment register %d =3D %x\=
n",
 			       regno, value);
 		break;
-	default:
-		printk(KERN_ERR "getregs:unknown register %d\n", regno);
+	      default:
+		printk(KERN_ERR "putreg:unknown register %d\n", regno);
 		break;
-
 	}
 }
=20
 static inline void
-ia32f2ia64f(void *dst, void *src)
+ia32f2ia64f (void *dst, void *src)
 {
=20
 	__asm__ ("ldfe f6=3D[%1] ;;\n\t"
@@ -2224,7 +2381,7 @@
 }
=20
 static inline void
-ia64f2ia32f(void *dst, void *src)
+ia64f2ia32f (void *dst, void *src)
 {
=20
 	__asm__ ("ldf.fill f6=3D[%1] ;;\n\t"
@@ -2234,8 +2391,9 @@
 	return;
 }
=20
-void
-put_fpreg(int regno, struct _fpreg_ia32 *reg, struct pt_regs *ptp, struct =
switch_stack *swp, int tos)
+static void
+put_fpreg (int regno, struct _fpreg_ia32 *reg, struct pt_regs *ptp, struct=
 switch_stack *swp,
+	   int tos)
 {
 	struct _fpreg_ia32 *f;
 	char buf[32];
@@ -2264,8 +2422,9 @@
 	__copy_to_user(reg, f, sizeof(*reg));
 }
=20
-void
-get_fpreg(int regno, struct _fpreg_ia32 *reg, struct pt_regs *ptp, struct =
switch_stack *swp, int tos)
+static void
+get_fpreg (int regno, struct _fpreg_ia32 *reg, struct pt_regs *ptp, struct=
 switch_stack *swp,
+	   int tos)
 {
=20
 	if ((regno +=3D tos) >=3D 8)
@@ -2291,8 +2450,8 @@
 	return;
 }
=20
-int
-save_ia32_fpstate(struct task_struct *tsk, struct _fpstate_ia32 *save)
+static int
+save_ia32_fpstate (struct task_struct *tsk, struct _fpstate_ia32 *save)
 {
 	struct switch_stack *swp;
 	struct pt_regs *ptp;
@@ -2315,11 +2474,11 @@
 	tos =3D (tsk->thread.fsr >> 11) & 3;
 	for (i =3D 0; i < 8; i++)
 		put_fpreg(i, &save->_st[i], ptp, swp, tos);
-	return(0);
+	return 0;
 }
=20
-int
-restore_ia32_fpstate(struct task_struct *tsk, struct _fpstate_ia32 *save)
+static int
+restore_ia32_fpstate (struct task_struct *tsk, struct _fpstate_ia32 *save)
 {
 	struct switch_stack *swp;
 	struct pt_regs *ptp;
@@ -2342,10 +2501,11 @@
 	tos =3D (tsk->thread.fsr >> 11) & 3;
 	for (i =3D 0; i < 8; i++)
 		get_fpreg(i, &save->_st[i], ptp, swp, tos);
-	return(ret ? -EFAULT : 0);
+	return ret ? -EFAULT : 0;
 }
=20
-asmlinkage long sys_ptrace(long, pid_t, unsigned long, unsigned long, long=
, long, long, long, long);
+extern asmlinkage long sys_ptrace (long, pid_t, unsigned long, unsigned lo=
ng, long, long, long,
+				   long, long);
=20
 /*
  *  Note that the IA32 version of `ptrace' calls the IA64 routine for
@@ -2360,13 +2520,12 @@
 {
 	struct pt_regs *regs =3D (struct pt_regs *) &stack;
 	struct task_struct *child;
+	unsigned int value, tmp;
 	long i, ret;
-	unsigned int value;
=20
 	lock_kernel();
 	if (request =3D PTRACE_TRACEME) {
-		ret =3D sys_ptrace(request, pid, addr, data,
-				arg4, arg5, arg6, arg7, stack);
+		ret =3D sys_ptrace(request, pid, addr, data, arg4, arg5, arg6, arg7, sta=
ck);
 		goto out;
 	}
=20
@@ -2381,8 +2540,7 @@
 		goto out;
=20
 	if (request =3D PTRACE_ATTACH) {
-		ret =3D sys_ptrace(request, pid, addr, data,
-				arg4, arg5, arg6, arg7, stack);
+		ret =3D sys_ptrace(request, pid, addr, data, arg4, arg5, arg6, arg7, sta=
ck);
 		goto out;
 	}
 	ret =3D -ESRCH;
@@ -2400,21 +2558,32 @@
 	      case PTRACE_PEEKDATA:	/* read word at location addr */
 		ret =3D ia32_peek(regs, child, addr, &value);
 		if (ret =3D 0)
-			ret =3D put_user(value, (unsigned int *)A(data));
+			ret =3D put_user(value, (unsigned int *) A(data));
 		else
 			ret =3D -EIO;
 		goto out;
=20
 	      case PTRACE_POKETEXT:
 	      case PTRACE_POKEDATA:	/* write the word at location addr */
-		ret =3D ia32_poke(regs, child, addr, (unsigned int)data);
+		ret =3D ia32_poke(regs, child, addr, data);
 		goto out;
=20
 	      case PTRACE_PEEKUSR:	/* read word at addr in USER area */
-		ret =3D 0;
+		ret =3D -EIO;
+		if ((addr & 3) || addr > 17*sizeof(int))
+			break;
+
+		tmp =3D getreg(child, addr);
+		if (!put_user(tmp, (unsigned int *) A(data)))
+			ret =3D 0;
 		break;
=20
 	      case PTRACE_POKEUSR:	/* write word at addr in USER area */
+		ret =3D -EIO;
+		if ((addr & 3) || addr > 17*sizeof(int))
+			break;
+
+		putreg(child, addr, data);
 		ret =3D 0;
 		break;
=20
@@ -2423,28 +2592,25 @@
 			ret =3D -EIO;
 			break;
 		}
-		for ( i =3D 0; i < 17*sizeof(int); i +=3D sizeof(int) ) {
-			__put_user(getreg(child, i), (unsigned int *) A(data));
+		for (i =3D 0; i < 17*sizeof(int); i +=3D sizeof(int) ) {
+			put_user(getreg(child, i), (unsigned int *) A(data));
 			data +=3D sizeof(int);
 		}
 		ret =3D 0;
 		break;
=20
 	      case IA32_PTRACE_SETREGS:
-	      {
-		unsigned int tmp;
 		if (!access_ok(VERIFY_READ, (int *) A(data), 17*sizeof(int))) {
 			ret =3D -EIO;
 			break;
 		}
-		for ( i =3D 0; i < 17*sizeof(int); i +=3D sizeof(int) ) {
-			__get_user(tmp, (unsigned int *) A(data));
+		for (i =3D 0; i < 17*sizeof(int); i +=3D sizeof(int) ) {
+			get_user(tmp, (unsigned int *) A(data));
 			putreg(child, i, tmp);
 			data +=3D sizeof(int);
 		}
 		ret =3D 0;
 		break;
-	      }
=20
 	      case IA32_PTRACE_GETFPREGS:
 		ret =3D save_ia32_fpstate(child, (struct _fpstate_ia32 *) A(data));
@@ -2459,10 +2625,8 @@
 	      case PTRACE_KILL:
 	      case PTRACE_SINGLESTEP:	/* execute chile for one instruction */
 	      case PTRACE_DETACH:	/* detach a process */
-		unlock_kernel();
-		ret =3D sys_ptrace(request, pid, addr, data,
-				arg4, arg5, arg6, arg7, stack);
-		return(ret);
+		ret =3D sys_ptrace(request, pid, addr, data, arg4, arg5, arg6, arg7, sta=
ck);
+		break;
=20
 	      default:
 		ret =3D -EIO;
@@ -2500,35 +2664,35 @@
 	return err;
 }
=20
-extern asmlinkage long sys_fcntl(unsigned int fd, unsigned int cmd,
-				 unsigned long arg);
+extern asmlinkage long sys_fcntl (unsigned int fd, unsigned int cmd, unsig=
ned long arg);
=20
 asmlinkage long
-sys32_fcntl(unsigned int fd, unsigned int cmd, int arg)
+sys32_fcntl (unsigned int fd, unsigned int cmd, unsigned int arg)
 {
-	struct flock f;
 	mm_segment_t old_fs;
+	struct flock f;
 	long ret;
=20
 	switch (cmd) {
-	case F_GETLK:
-	case F_SETLK:
-	case F_SETLKW:
-		if(get_flock32(&f, (struct flock32 *)((long)arg)))
+	      case F_GETLK:
+	      case F_SETLK:
+	      case F_SETLKW:
+		if (get_flock32(&f, (struct flock32 *) A(arg)))
 			return -EFAULT;
 		old_fs =3D get_fs();
 		set_fs(KERNEL_DS);
-		ret =3D sys_fcntl(fd, cmd, (unsigned long)&f);
+		ret =3D sys_fcntl(fd, cmd, (unsigned long) &f);
 		set_fs(old_fs);
-		if(cmd =3D F_GETLK && put_flock32(&f, (struct flock32 *)((long)arg)))
+		if (cmd =3D F_GETLK && put_flock32(&f, (struct flock32 *) A(arg)))
 			return -EFAULT;
 		return ret;
-	default:
+
+	      default:
 		/*
 		 *  `sys_fcntl' lies about arg, for the F_SETOWN
 		 *  sub-function arg can have a negative value.
 		 */
-		return sys_fcntl(fd, cmd, (unsigned long)((long)arg));
+		return sys_fcntl(fd, cmd, arg);
 	}
 }
=20
@@ -2536,25 +2700,30 @@
 sys32_sigaction (int sig, struct old_sigaction32 *act, struct old_sigactio=
n32 *oact)
 {
 	struct k_sigaction new_ka, old_ka;
+	unsigned int handler, restorer;
 	int ret;
=20
 	if (act) {
 		old_sigset32_t mask;
=20
-		ret =3D get_user((long)new_ka.sa.sa_handler, &act->sa_handler);
-		ret |=3D __get_user(new_ka.sa.sa_flags, &act->sa_flags);
-		ret |=3D __get_user(mask, &act->sa_mask);
+		ret =3D get_user(handler, &act->sa_handler);
+		ret |=3D get_user(new_ka.sa.sa_flags, &act->sa_flags);
+		ret |=3D get_user(restorer, &act->sa_restorer);
+		ret |=3D get_user(mask, &act->sa_mask);
 		if (ret)
 			return ret;
+
+		sigact_set_handler(&new_ka, handler, restorer);
 		siginitset(&new_ka.sa.sa_mask, mask);
 	}
=20
 	ret =3D do_sigaction(sig, act ? &new_ka : NULL, oact ? &old_ka : NULL);
=20
 	if (!ret && oact) {
-		ret =3D put_user((long)old_ka.sa.sa_handler, &oact->sa_handler);
-		ret |=3D __put_user(old_ka.sa.sa_flags, &oact->sa_flags);
-		ret |=3D __put_user(old_ka.sa.sa_mask.sig[0], &oact->sa_mask);
+		ret =3D put_user(IA32_SA_HANDLER(&old_ka), &oact->sa_handler);
+		ret |=3D put_user(old_ka.sa.sa_flags, &oact->sa_flags);
+		ret |=3D put_user(IA32_SA_RESTORER(&old_ka), &oact->sa_restorer);
+		ret |=3D put_user(old_ka.sa.sa_mask.sig[0], &oact->sa_mask);
 	}
=20
 	return ret;
@@ -2563,8 +2732,8 @@
 asmlinkage long sys_ni_syscall(void);
=20
 asmlinkage long
-sys32_ni_syscall(int dummy0, int dummy1, int dummy2, int dummy3,
-	int dummy4, int dummy5, int dummy6, int dummy7, int stack)
+sys32_ni_syscall (int dummy0, int dummy1, int dummy2, int dummy3, int dumm=
y4, int dummy5,
+		  int dummy6, int dummy7, int stack)
 {
 	struct pt_regs *regs =3D (struct pt_regs *)&stack;
=20
@@ -2579,7 +2748,7 @@
 #define IOLEN	((65536 / 4) * 4096)
=20
 asmlinkage long
-sys_iopl (int level)
+sys32_iopl (int level)
 {
 	extern unsigned long ia64_iobase;
 	int fd;
@@ -2624,7 +2793,7 @@
 }
=20
 asmlinkage long
-sys_ioperm (unsigned int from, unsigned int num, int on)
+sys32_ioperm (unsigned int from, unsigned int num, int on)
 {
=20
 	/*
@@ -2637,7 +2806,7 @@
 	 * XXX proper ioperm() support should be emulated by
 	 *	manipulating the page protections...
 	 */
-	return sys_iopl(3);
+	return sys32_iopl(3);
 }
=20
 typedef struct {
@@ -2647,10 +2816,8 @@
 } ia32_stack_t;
=20
 asmlinkage long
-sys32_sigaltstack (const ia32_stack_t *uss32, ia32_stack_t *uoss32,
-long arg2, long arg3, long arg4,
-long arg5, long arg6, long arg7,
-long stack)
+sys32_sigaltstack (ia32_stack_t *uss32, ia32_stack_t *uoss32,
+		   long arg2, long arg3, long arg4, long arg5, long arg6, long arg7, lon=
g stack)
 {
 	struct pt_regs *pt =3D (struct pt_regs *) &stack;
 	stack_t uss, uoss;
@@ -2659,8 +2826,8 @@
 	mm_segment_t old_fs =3D get_fs();
=20
 	if (uss32)
-		if (copy_from_user(&buf32, (void *)A(uss32), sizeof(ia32_stack_t)))
-			return(-EFAULT);
+		if (copy_from_user(&buf32, uss32, sizeof(ia32_stack_t)))
+			return -EFAULT;
 	uss.ss_sp =3D (void *) (long) buf32.ss_sp;
 	uss.ss_flags =3D buf32.ss_flags;
 	uss.ss_size =3D buf32.ss_size;
@@ -2673,34 +2840,34 @@
 		buf32.ss_sp =3D (long) uoss.ss_sp;
 		buf32.ss_flags =3D uoss.ss_flags;
 		buf32.ss_size =3D uoss.ss_size;
-		if (copy_to_user((void*)A(uoss32), &buf32, sizeof(ia32_stack_t)))
-			return(-EFAULT);
+		if (copy_to_user(uoss32, &buf32, sizeof(ia32_stack_t)))
+			return -EFAULT;
 	}
-	return(ret);
+	return ret;
 }
=20
 asmlinkage int
-sys_pause (void)
+sys32_pause (void)
 {
 	current->state =3D TASK_INTERRUPTIBLE;
 	schedule();
 	return -ERESTARTNOHAND;
 }
=20
-asmlinkage long sys_msync(unsigned long start, size_t len, int flags);
+asmlinkage long sys_msync (unsigned long start, size_t len, int flags);
=20
 asmlinkage int
-sys32_msync(unsigned int start, unsigned int len, int flags)
+sys32_msync (unsigned int start, unsigned int len, int flags)
 {
 	unsigned int addr;
=20
 	if (OFFSET4K(start))
 		return -EINVAL;
 	addr =3D start & PAGE_MASK;
-	return(sys_msync(addr, len + (start - addr), flags));
+	return sys_msync(addr, len + (start - addr), flags);
 }
=20
-struct sysctl_ia32 {
+struct sysctl32 {
 	unsigned int	name;
 	int		nlen;
 	unsigned int	oldval;
@@ -2713,16 +2880,16 @@
 extern asmlinkage long sys_sysctl(struct __sysctl_args *args);
=20
 asmlinkage long
-sys32_sysctl(struct sysctl_ia32 *args32)
+sys32_sysctl (struct sysctl32 *args)
 {
-	struct sysctl_ia32 a32;
+	struct sysctl32 a32;
 	mm_segment_t old_fs =3D get_fs ();
 	void *oldvalp, *newvalp;
 	size_t oldlen;
 	int *namep;
 	long ret;
=20
-	if (copy_from_user(&a32, args32, sizeof (a32)))
+	if (copy_from_user(&a32, args, sizeof(a32)))
 		return -EFAULT;
=20
 	/*
@@ -2755,7 +2922,7 @@
 }
=20
 asmlinkage long
-sys32_newuname(struct new_utsname * name)
+sys32_newuname (struct new_utsname *name)
 {
 	extern asmlinkage long sys_newuname(struct new_utsname * name);
 	int ret =3D sys_newuname(name);
@@ -2766,10 +2933,10 @@
 	return ret;
 }
=20
-extern asmlinkage long sys_getresuid(uid_t *ruid, uid_t *euid, uid_t *suid=
);
+extern asmlinkage long sys_getresuid (uid_t *ruid, uid_t *euid, uid_t *sui=
d);
=20
 asmlinkage long
-sys32_getresuid (u16 *ruid, u16 *euid, u16 *suid)
+sys32_getresuid16 (u16 *ruid, u16 *euid, u16 *suid)
 {
 	uid_t a, b, c;
 	int ret;
@@ -2787,7 +2954,7 @@
 extern asmlinkage long sys_getresgid (gid_t *rgid, gid_t *egid, gid_t *sgi=
d);
=20
 asmlinkage long
-sys32_getresgid(u16 *rgid, u16 *egid, u16 *sgid)
+sys32_getresgid16 (u16 *rgid, u16 *egid, u16 *sgid)
 {
 	gid_t a, b, c;
 	int ret;
@@ -2797,15 +2964,13 @@
 	ret =3D sys_getresgid(&a, &b, &c);
 	set_fs(old_fs);
=20
-	if (!ret) {
-		ret  =3D put_user(a, rgid);
-		ret |=3D put_user(b, egid);
-		ret |=3D put_user(c, sgid);
-	}
-	return ret;
+	if (ret)
+		return ret;
+
+	return put_user(a, rgid) | put_user(b, egid) | put_user(c, sgid);
 }
=20
-int
+asmlinkage long
 sys32_lseek (unsigned int fd, int offset, unsigned int whence)
 {
 	extern off_t sys_lseek (unsigned int fd, off_t offset, unsigned int origi=
n);
@@ -2814,190 +2979,448 @@
 	return sys_lseek(fd, offset, whence);
 }
=20
-#ifdef	NOTYET  /* UNTESTED FOR IA64 FROM HERE DOWN */
+extern asmlinkage long sys_getgroups (int gidsetsize, gid_t *grouplist);
=20
-/* In order to reduce some races, while at the same time doing additional
- * checking and hopefully speeding things up, we copy filenames to the
- * kernel data space before using them..
- *
- * POSIX.1 2.4: an empty pathname is invalid (ENOENT).
- */
-static inline int
-do_getname32(const char *filename, char *page)
+asmlinkage long
+sys32_getgroups16 (int gidsetsize, short *grouplist)
 {
-	int retval;
+	mm_segment_t old_fs =3D get_fs();
+	gid_t gl[NGROUPS];
+	int ret, i;
=20
-	/* 32bit pointer will be always far below TASK_SIZE :)) */
-	retval =3D strncpy_from_user((char *)page, (char *)filename, PAGE_SIZE);
-	if (retval > 0) {
-		if (retval < PAGE_SIZE)
-			return 0;
-		return -ENAMETOOLONG;
-	} else if (!retval)
-		retval =3D -ENOENT;
-	return retval;
+	set_fs(KERNEL_DS);
+	ret =3D sys_getgroups(gidsetsize, gl);
+	set_fs(old_fs);
+
+	if (gidsetsize && ret > 0 && ret <=3D NGROUPS)
+		for (i =3D 0; i < ret; i++, grouplist++)
+			if (put_user(gl[i], grouplist))
+				return -EFAULT;
+	return ret;
 }
=20
-char *
-getname32(const char *filename)
-{
-	char *tmp, *result;
+extern asmlinkage long sys_setgroups (int gidsetsize, gid_t *grouplist);
=20
-	result =3D ERR_PTR(-ENOMEM);
-	tmp =3D (char *)__get_free_page(GFP_KERNEL);
-	if (tmp)  {
-		int retval =3D do_getname32(filename, tmp);
+asmlinkage long
+sys32_setgroups16 (int gidsetsize, short *grouplist)
+{
+	mm_segment_t old_fs =3D get_fs();
+	gid_t gl[NGROUPS];
+	int ret, i;
=20
-		result =3D tmp;
-		if (retval < 0) {
-			putname(tmp);
-			result =3D ERR_PTR(retval);
-		}
-	}
-	return result;
+	if ((unsigned) gidsetsize > NGROUPS)
+		return -EINVAL;
+	for (i =3D 0; i < gidsetsize; i++, grouplist++)
+		if (get_user(gl[i], grouplist))
+			return -EFAULT;
+	set_fs(KERNEL_DS);
+	ret =3D sys_setgroups(gidsetsize, gl);
+	set_fs(old_fs);
+	return ret;
 }
=20
-/* 32-bit timeval and related flotsam.  */
-
-extern asmlinkage long sys_ioperm(unsigned long from, unsigned long num, i=
nt on);
+/*
+ * Unfortunately, the x86 compiler aligns variables of type "long long" to=
 a 4 byte boundary
+ * only, which means that the x86 version of "struct flock64" doesn't matc=
h the ia64 version
+ * of struct flock.
+ */
=20
-asmlinkage long
-sys32_ioperm(u32 from, u32 num, int on)
+static inline long
+ia32_put_flock (struct flock *l, unsigned long addr)
 {
-	return sys_ioperm((unsigned long)from, (unsigned long)num, on);
+	return (put_user(l->l_type, (short *) addr)
+		| put_user(l->l_whence, (short *) (addr + 2))
+		| put_user(l->l_start, (long *) (addr + 4))
+		| put_user(l->l_len, (long *) (addr + 12))
+		| put_user(l->l_pid, (int *) (addr + 20)));
 }
=20
-struct dqblk32 {
-    __u32 dqb_bhardlimit;
-    __u32 dqb_bsoftlimit;
-    __u32 dqb_curblocks;
-    __u32 dqb_ihardlimit;
-    __u32 dqb_isoftlimit;
-    __u32 dqb_curinodes;
-    __kernel_time_t32 dqb_btime;
-    __kernel_time_t32 dqb_itime;
-};
-
-extern asmlinkage long sys_quotactl(int cmd, const char *special, int id,
-				   caddr_t addr);
+static inline long
+ia32_get_flock (struct flock *l, unsigned long addr)
+{
+	unsigned int start_lo, start_hi, len_lo, len_hi;
+	int err =3D (get_user(l->l_type, (short *) addr)
+		   | get_user(l->l_whence, (short *) (addr + 2))
+		   | get_user(start_lo, (int *) (addr + 4))
+		   | get_user(start_hi, (int *) (addr + 8))
+		   | get_user(len_lo, (int *) (addr + 12))
+		   | get_user(len_hi, (int *) (addr + 16))
+		   | get_user(l->l_pid, (int *) (addr + 20)));
+	l->l_start =3D ((unsigned long) start_hi << 32) | start_lo;
+	l->l_len =3D ((unsigned long) len_hi << 32) | len_lo;
+	return err;
+}
=20
 asmlinkage long
-sys32_quotactl(int cmd, const char *special, int id, unsigned long addr)
+sys32_fcntl64 (unsigned int fd, unsigned int cmd, unsigned int arg)
 {
-	int cmds =3D cmd >> SUBCMDSHIFT;
-	int err;
-	struct dqblk d;
 	mm_segment_t old_fs;
-	char *spec;
+	struct flock f;
+	long ret;
=20
-	switch (cmds) {
-	case Q_GETQUOTA:
-		break;
-	case Q_SETQUOTA:
-	case Q_SETUSE:
-	case Q_SETQLIM:
-		if (copy_from_user (&d, (struct dqblk32 *)addr,
-				    sizeof (struct dqblk32)))
+	switch (cmd) {
+	      case F_GETLK64:
+	      case F_SETLK64:
+	      case F_SETLKW64:
+		if (ia32_get_flock(&f, arg))
 			return -EFAULT;
-		d.dqb_itime =3D ((struct dqblk32 *)&d)->dqb_itime;
-		d.dqb_btime =3D ((struct dqblk32 *)&d)->dqb_btime;
-		break;
-	default:
-		return sys_quotactl(cmd, special,
-				    id, (caddr_t)addr);
-	}
-	spec =3D getname32 (special);
-	err =3D PTR_ERR(spec);
-	if (IS_ERR(spec)) return err;
-	old_fs =3D get_fs ();
-	set_fs (KERNEL_DS);
-	err =3D sys_quotactl(cmd, (const char *)spec, id, (caddr_t)&d);
-	set_fs (old_fs);
-	putname (spec);
-	if (cmds =3D Q_GETQUOTA) {
-		__kernel_time_t b =3D d.dqb_btime, i =3D d.dqb_itime;
-		((struct dqblk32 *)&d)->dqb_itime =3D i;
-		((struct dqblk32 *)&d)->dqb_btime =3D b;
-		if (copy_to_user ((struct dqblk32 *)addr, &d,
-				  sizeof (struct dqblk32)))
+		old_fs =3D get_fs();
+		set_fs(KERNEL_DS);
+		ret =3D sys_fcntl(fd, cmd, (unsigned long) &f);
+		set_fs(old_fs);
+		if (cmd =3D F_GETLK && ia32_put_flock(&f, arg))
 			return -EFAULT;
+		break;
+
+	      default:
+		ret =3D sys32_fcntl(fd, cmd, arg);
+		break;
 	}
-	return err;
+	return ret;
 }
=20
-extern asmlinkage long sys_utime(char * filename, struct utimbuf * times);
+asmlinkage long
+sys32_truncate64 (unsigned int path, unsigned int len_lo, unsigned int len=
_hi)
+{
+	extern asmlinkage long sys_truncate (const char *path, unsigned long leng=
th);
=20
-struct utimbuf32 {
-	__kernel_time_t32 actime, modtime;
-};
+	return sys_truncate((const char *) A(path), ((unsigned long) len_hi << 32=
) | len_lo);
+}
=20
 asmlinkage long
-sys32_utime(char * filename, struct utimbuf32 *times)
+sys32_ftruncate64 (int fd, unsigned int len_lo, unsigned int len_hi)
 {
-	struct utimbuf t;
-	mm_segment_t old_fs;
-	int ret;
-	char *filenam;
+	extern asmlinkage long sys_ftruncate (int fd, unsigned long length);
=20
-	if (!times)
-		return sys_utime(filename, NULL);
-	if (get_user (t.actime, &times->actime) ||
-	    __get_user (t.modtime, &times->modtime))
-		return -EFAULT;
-	filenam =3D getname32 (filename);
-	ret =3D PTR_ERR(filenam);
-	if (!IS_ERR(filenam)) {
-		old_fs =3D get_fs();
-		set_fs (KERNEL_DS);
-		ret =3D sys_utime(filenam, &t);
-		set_fs (old_fs);
-		putname (filenam);
-	}
-	return ret;
+	return sys_ftruncate(fd, ((unsigned long) len_hi << 32) | len_lo);
 }
=20
-/*
- * Ooo, nasty.  We need here to frob 32-bit unsigned longs to
- * 64-bit unsigned longs.
- */
-
-static inline int
-get_fd_set32(unsigned long n, unsigned long *fdset, u32 *ufdset)
+static int
+putstat64 (struct stat64 *ubuf, struct stat *kbuf)
 {
-	if (ufdset) {
-		unsigned long odd;
+	int err;
=20
-		if (verify_area(VERIFY_WRITE, ufdset, n*sizeof(u32)))
-			return -EFAULT;
+	if (clear_user(ubuf, sizeof(*ubuf)))
+		return 1;
=20
-		odd =3D n & 1UL;
-		n &=3D ~1UL;
-		while (n) {
-			unsigned long h, l;
-			__get_user(l, ufdset);
-			__get_user(h, ufdset+1);
-			ufdset +=3D 2;
-			*fdset++ =3D h << 32 | l;
-			n -=3D 2;
-		}
-		if (odd)
-			__get_user(*fdset, ufdset);
-	} else {
-		/* Tricky, must clear full unsigned long in the
-		 * kernel fdset at the end, this makes sure that
-		 * actually happens.
-		 */
-		memset(fdset, 0, ((n + 1) & ~1)*sizeof(u32));
-	}
-	return 0;
+	err  =3D __put_user(kbuf->st_dev, &ubuf->st_dev);
+	err |=3D __put_user(kbuf->st_ino, &ubuf->__st_ino);
+	err |=3D __put_user(kbuf->st_ino, &ubuf->st_ino_lo);
+	err |=3D __put_user(kbuf->st_ino >> 32, &ubuf->st_ino_hi);
+	err |=3D __put_user(kbuf->st_mode, &ubuf->st_mode);
+	err |=3D __put_user(kbuf->st_nlink, &ubuf->st_nlink);
+	err |=3D __put_user(kbuf->st_uid, &ubuf->st_uid);
+	err |=3D __put_user(kbuf->st_gid, &ubuf->st_gid);
+	err |=3D __put_user(kbuf->st_rdev, &ubuf->st_rdev);
+	err |=3D __put_user(kbuf->st_size, &ubuf->st_size_lo);
+	err |=3D __put_user((kbuf->st_size >> 32), &ubuf->st_size_hi);
+	err |=3D __put_user(kbuf->st_atime, &ubuf->st_atime);
+	err |=3D __put_user(kbuf->st_mtime, &ubuf->st_mtime);
+	err |=3D __put_user(kbuf->st_ctime, &ubuf->st_ctime);
+	err |=3D __put_user(kbuf->st_blksize, &ubuf->st_blksize);
+	err |=3D __put_user(kbuf->st_blocks, &ubuf->st_blocks);
+	return err;
 }
=20
-static inline void
-set_fd_set32(unsigned long n, u32 *ufdset, unsigned long *fdset)
+asmlinkage long
+sys32_stat64 (char *filename, struct stat64 *statbuf)
 {
-	unsigned long odd;
-
-	if (!ufdset)
+	mm_segment_t old_fs =3D get_fs();
+	struct stat s;
+	long ret;
+
+	set_fs(KERNEL_DS);
+	ret =3D sys_newstat(filename, &s);
+	set_fs(old_fs);
+	if (putstat64(statbuf, &s))
+		return -EFAULT;
+	return ret;
+}
+
+asmlinkage long
+sys32_lstat64 (char *filename, struct stat64 *statbuf)
+{
+	mm_segment_t old_fs =3D get_fs();
+	struct stat s;
+	long ret;
+
+	set_fs(KERNEL_DS);
+	ret =3D sys_newlstat(filename, &s);
+	set_fs(old_fs);
+	if (putstat64(statbuf, &s))
+		return -EFAULT;
+	return ret;
+}
+
+asmlinkage long
+sys32_fstat64 (unsigned int fd, struct stat64 *statbuf)
+{
+	mm_segment_t old_fs =3D get_fs();
+	struct stat s;
+	long ret;
+
+	set_fs(KERNEL_DS);
+	ret =3D sys_newfstat(fd, &s);
+	set_fs(old_fs);
+	if (putstat64(statbuf, &s))
+		return -EFAULT;
+	return ret;
+}
+
+asmlinkage long
+sys32_sigpending (unsigned int *set)
+{
+	return do_sigpending(set, sizeof(*set));
+}
+
+struct sysinfo32 {
+	s32 uptime;
+	u32 loads[3];
+	u32 totalram;
+	u32 freeram;
+	u32 sharedram;
+	u32 bufferram;
+	u32 totalswap;
+	u32 freeswap;
+	unsigned short procs;
+	char _f[22];
+};
+
+asmlinkage long
+sys32_sysinfo (struct sysinfo32 *info)
+{
+	extern asmlinkage long sys_sysinfo (struct sysinfo *);
+	mm_segment_t old_fs =3D get_fs();
+	struct sysinfo s;
+	long ret, err;
+
+	set_fs(KERNEL_DS);
+	ret =3D sys_sysinfo(&s);
+	set_fs(old_fs);
+
+	if (!access_ok(VERIFY_WRITE, info, sizeof(*info)))
+		return -EFAULT;
+
+	err  =3D __put_user(s.uptime, &info->uptime);
+	err |=3D __put_user(s.loads[0], &info->loads[0]);
+	err |=3D __put_user(s.loads[1], &info->loads[1]);
+	err |=3D __put_user(s.loads[2], &info->loads[2]);
+	err |=3D __put_user(s.totalram, &info->totalram);
+	err |=3D __put_user(s.freeram, &info->freeram);
+	err |=3D __put_user(s.sharedram, &info->sharedram);
+	err |=3D __put_user(s.bufferram, &info->bufferram);
+	err |=3D __put_user(s.totalswap, &info->totalswap);
+	err |=3D __put_user(s.freeswap, &info->freeswap);
+	err |=3D __put_user(s.procs, &info->procs);
+	if (err)
+		return -EFAULT;
+	return ret;
+}
+
+/* In order to reduce some races, while at the same time doing additional
+ * checking and hopefully speeding things up, we copy filenames to the
+ * kernel data space before using them..
+ *
+ * POSIX.1 2.4: an empty pathname is invalid (ENOENT).
+ */
+static inline int
+do_getname32 (const char *filename, char *page)
+{
+	int retval;
+
+	/* 32bit pointer will be always far below TASK_SIZE :)) */
+	retval =3D strncpy_from_user((char *)page, (char *)filename, PAGE_SIZE);
+	if (retval > 0) {
+		if (retval < PAGE_SIZE)
+			return 0;
+		return -ENAMETOOLONG;
+	} else if (!retval)
+		retval =3D -ENOENT;
+	return retval;
+}
+
+static char *
+getname32 (const char *filename)
+{
+	char *tmp, *result;
+
+	result =3D ERR_PTR(-ENOMEM);
+	tmp =3D (char *)__get_free_page(GFP_KERNEL);
+	if (tmp)  {
+		int retval =3D do_getname32(filename, tmp);
+
+		result =3D tmp;
+		if (retval < 0) {
+			putname(tmp);
+			result =3D ERR_PTR(retval);
+		}
+	}
+	return result;
+}
+
+struct dqblk32 {
+	__u32 dqb_bhardlimit;
+	__u32 dqb_bsoftlimit;
+	__u32 dqb_curblocks;
+	__u32 dqb_ihardlimit;
+	__u32 dqb_isoftlimit;
+	__u32 dqb_curinodes;
+	__kernel_time_t32 dqb_btime;
+	__kernel_time_t32 dqb_itime;
+};
+
+asmlinkage long
+sys32_quotactl (int cmd, unsigned int special, int id, struct dqblk32 *add=
r)
+{
+	extern asmlinkage long sys_quotactl (int, const char *, int, caddr_t);
+	int cmds =3D cmd >> SUBCMDSHIFT;
+	mm_segment_t old_fs;
+	struct dqblk d;
+	char *spec;
+	long err;
+
+	switch (cmds) {
+	      case Q_GETQUOTA:
+		break;
+	      case Q_SETQUOTA:
+	      case Q_SETUSE:
+	      case Q_SETQLIM:
+		if (copy_from_user (&d, addr, sizeof(struct dqblk32)))
+			return -EFAULT;
+		d.dqb_itime =3D ((struct dqblk32 *)&d)->dqb_itime;
+		d.dqb_btime =3D ((struct dqblk32 *)&d)->dqb_btime;
+		break;
+	      default:
+		return sys_quotactl(cmd, (void *) A(special), id, (caddr_t) addr);
+	}
+	spec =3D getname32((void *) A(special));
+	err =3D PTR_ERR(spec);
+	if (IS_ERR(spec))
+		return err;
+	old_fs =3D get_fs ();
+	set_fs(KERNEL_DS);
+	err =3D sys_quotactl(cmd, (const char *)spec, id, (caddr_t)&d);
+	set_fs(old_fs);
+	putname(spec);
+	if (cmds =3D Q_GETQUOTA) {
+		__kernel_time_t b =3D d.dqb_btime, i =3D d.dqb_itime;
+		((struct dqblk32 *)&d)->dqb_itime =3D i;
+		((struct dqblk32 *)&d)->dqb_btime =3D b;
+		if (copy_to_user(addr, &d, sizeof(struct dqblk32)))
+			return -EFAULT;
+	}
+	return err;
+}
+
+asmlinkage long
+sys32_sched_rr_get_interval (pid_t pid, struct timespec32 *interval)
+{
+	extern asmlinkage long sys_sched_rr_get_interval (pid_t, struct timespec =
*);
+	mm_segment_t old_fs =3D get_fs();
+	struct timespec t;
+	long ret;
+
+	set_fs(KERNEL_DS);
+	ret =3D sys_sched_rr_get_interval(pid, &t);
+	set_fs(old_fs);
+	if (put_user (t.tv_sec, &interval->tv_sec) || put_user (t.tv_nsec, &inter=
val->tv_nsec))
+		return -EFAULT;
+	return ret;
+}
+
+asmlinkage long
+sys32_pread (unsigned int fd, void *buf, unsigned int count, u32 pos_lo, u=
32 pos_hi)
+{
+	extern asmlinkage long sys_pread (unsigned int, char *, size_t, loff_t);
+	return sys_pread(fd, buf, count, ((unsigned long) pos_hi << 32) | pos_lo);
+}
+
+asmlinkage long
+sys32_pwrite (unsigned int fd, void *buf, unsigned int count, u32 pos_lo, =
u32 pos_hi)
+{
+	extern asmlinkage long sys_pwrite (unsigned int, const char *, size_t, lo=
ff_t);
+	return sys_pwrite(fd, buf, count, ((unsigned long) pos_hi << 32) | pos_lo=
);
+}
+
+asmlinkage long
+sys32_sendfile (int out_fd, int in_fd, int *offset, unsigned int count)
+{
+	extern asmlinkage long sys_sendfile (int, int, off_t *, size_t);
+	mm_segment_t old_fs =3D get_fs();
+	long ret;
+	off_t of;
+
+	if (offset && get_user(of, offset))
+		return -EFAULT;
+
+	set_fs(KERNEL_DS);
+	ret =3D sys_sendfile(out_fd, in_fd, offset ? &of : NULL, count);
+	set_fs(old_fs);
+
+	if (!ret && offset && put_user(of, offset))
+		return -EFAULT;
+
+	return ret;
+}
+
+asmlinkage long
+sys32_personality (unsigned int personality)
+{
+	extern asmlinkage long sys_personality (unsigned long);
+	long ret;
+
+	if (current->personality =3D PER_LINUX32 && personality =3D PER_LINUX)
+		personality =3D PER_LINUX32;
+	ret =3D sys_personality(personality);
+	if (ret =3D PER_LINUX32)
+		ret =3D PER_LINUX;
+	return ret;
+}
+
+#ifdef	NOTYET  /* UNTESTED FOR IA64 FROM HERE DOWN */
+
+/*
+ * Ooo, nasty.  We need here to frob 32-bit unsigned longs to
+ * 64-bit unsigned longs.
+ */
+
+static inline int
+get_fd_set32(unsigned long n, unsigned long *fdset, u32 *ufdset)
+{
+	if (ufdset) {
+		unsigned long odd;
+
+		if (verify_area(VERIFY_WRITE, ufdset, n*sizeof(u32)))
+			return -EFAULT;
+
+		odd =3D n & 1UL;
+		n &=3D ~1UL;
+		while (n) {
+			unsigned long h, l;
+			__get_user(l, ufdset);
+			__get_user(h, ufdset+1);
+			ufdset +=3D 2;
+			*fdset++ =3D h << 32 | l;
+			n -=3D 2;
+		}
+		if (odd)
+			__get_user(*fdset, ufdset);
+	} else {
+		/* Tricky, must clear full unsigned long in the
+		 * kernel fdset at the end, this makes sure that
+		 * actually happens.
+		 */
+		memset(fdset, 0, ((n + 1) & ~1)*sizeof(u32));
+	}
+	return 0;
+}
+
+static inline void
+set_fd_set32(unsigned long n, u32 *ufdset, unsigned long *fdset)
+{
+	unsigned long odd;
+
+	if (!ufdset)
 		return;
=20
 	odd =3D n & 1UL;
@@ -3015,20 +3438,11 @@
 		__put_user(*fdset, ufdset);
 }
=20
-extern asmlinkage long sys_sysfs(int option, unsigned long arg1,
-				unsigned long arg2);
-
-asmlinkage long
-sys32_sysfs(int option, u32 arg1, u32 arg2)
-{
-	return sys_sysfs(option, arg1, arg2);
-}
-
 struct ncp_mount_data32 {
 	int version;
 	unsigned int ncp_fd;
 	__kernel_uid_t32 mounted_uid;
-	__kernel_pid_t32 wdog_pid;
+	int wdog_pid;
 	unsigned char mounted_vol[NCP_VOLNAME_LEN + 1];
 	unsigned int time_out;
 	unsigned int retry_count;
@@ -3175,269 +3589,7 @@
 	}
 }
=20
-struct sysinfo32 {
-	s32 uptime;
-	u32 loads[3];
-	u32 totalram;
-	u32 freeram;
-	u32 sharedram;
-	u32 bufferram;
-	u32 totalswap;
-	u32 freeswap;
-	unsigned short procs;
-	char _f[22];
-};
-
-extern asmlinkage long sys_sysinfo(struct sysinfo *info);
-
-asmlinkage long
-sys32_sysinfo(struct sysinfo32 *info)
-{
-	struct sysinfo s;
-	int ret, err;
-	mm_segment_t old_fs =3D get_fs ();
-
-	set_fs (KERNEL_DS);
-	ret =3D sys_sysinfo(&s);
-	set_fs (old_fs);
-	err =3D put_user (s.uptime, &info->uptime);
-	err |=3D __put_user (s.loads[0], &info->loads[0]);
-	err |=3D __put_user (s.loads[1], &info->loads[1]);
-	err |=3D __put_user (s.loads[2], &info->loads[2]);
-	err |=3D __put_user (s.totalram, &info->totalram);
-	err |=3D __put_user (s.freeram, &info->freeram);
-	err |=3D __put_user (s.sharedram, &info->sharedram);
-	err |=3D __put_user (s.bufferram, &info->bufferram);
-	err |=3D __put_user (s.totalswap, &info->totalswap);
-	err |=3D __put_user (s.freeswap, &info->freeswap);
-	err |=3D __put_user (s.procs, &info->procs);
-	if (err)
-		return -EFAULT;
-	return ret;
-}
-
-extern asmlinkage long sys_sched_rr_get_interval(pid_t pid,
-						struct timespec *interval);
-
-asmlinkage long
-sys32_sched_rr_get_interval(__kernel_pid_t32 pid, struct timespec32 *inter=
val)
-{
-	struct timespec t;
-	int ret;
-	mm_segment_t old_fs =3D get_fs ();
-
-	set_fs (KERNEL_DS);
-	ret =3D sys_sched_rr_get_interval(pid, &t);
-	set_fs (old_fs);
-	if (put_user (t.tv_sec, &interval->tv_sec) ||
-	    __put_user (t.tv_nsec, &interval->tv_nsec))
-		return -EFAULT;
-	return ret;
-}
-
-extern asmlinkage long sys_sigprocmask(int how, old_sigset_t *set,
-				      old_sigset_t *oset);
-
-asmlinkage long
-sys32_sigprocmask(int how, old_sigset_t32 *set, old_sigset_t32 *oset)
-{
-	old_sigset_t s;
-	int ret;
-	mm_segment_t old_fs =3D get_fs();
-
-	if (set && get_user (s, set)) return -EFAULT;
-	set_fs (KERNEL_DS);
-	ret =3D sys_sigprocmask(how, set ? &s : NULL, oset ? &s : NULL);
-	set_fs (old_fs);
-	if (ret) return ret;
-	if (oset && put_user (s, oset)) return -EFAULT;
-	return 0;
-}
-
-extern asmlinkage long sys_sigpending(old_sigset_t *set);
-
-asmlinkage long
-sys32_sigpending(old_sigset_t32 *set)
-{
-	old_sigset_t s;
-	int ret;
-	mm_segment_t old_fs =3D get_fs();
-
-	set_fs (KERNEL_DS);
-	ret =3D sys_sigpending(&s);
-	set_fs (old_fs);
-	if (put_user (s, set)) return -EFAULT;
-	return ret;
-}
-
-extern asmlinkage long sys_rt_sigpending(sigset_t *set, size_t sigsetsize);
-
-asmlinkage long
-sys32_rt_sigpending(sigset_t32 *set, __kernel_size_t32 sigsetsize)
-{
-	sigset_t s;
-	sigset_t32 s32;
-	int ret;
-	mm_segment_t old_fs =3D get_fs();
-
-	set_fs (KERNEL_DS);
-	ret =3D sys_rt_sigpending(&s, sigsetsize);
-	set_fs (old_fs);
-	if (!ret) {
-		switch (_NSIG_WORDS) {
-		case 4: s32.sig[7] =3D (s.sig[3] >> 32); s32.sig[6] =3D s.sig[3];
-		case 3: s32.sig[5] =3D (s.sig[2] >> 32); s32.sig[4] =3D s.sig[2];
-		case 2: s32.sig[3] =3D (s.sig[1] >> 32); s32.sig[2] =3D s.sig[1];
-		case 1: s32.sig[1] =3D (s.sig[0] >> 32); s32.sig[0] =3D s.sig[0];
-		}
-		if (copy_to_user (set, &s32, sizeof(sigset_t32)))
-			return -EFAULT;
-	}
-	return ret;
-}
-
-siginfo_t32 *
-siginfo64to32(siginfo_t32 *d, siginfo_t *s)
-{
-	memset(d, 0, sizeof(siginfo_t32));
-	d->si_signo =3D s->si_signo;
-	d->si_errno =3D s->si_errno;
-	d->si_code =3D s->si_code;
-	if (s->si_signo >=3D SIGRTMIN) {
-		d->si_pid =3D s->si_pid;
-		d->si_uid =3D s->si_uid;
-		/* XXX: Ouch, how to find this out??? */
-		d->si_int =3D s->si_int;
-	} else switch (s->si_signo) {
-	/* XXX: What about POSIX1.b timers */
-	case SIGCHLD:
-		d->si_pid =3D s->si_pid;
-		d->si_status =3D s->si_status;
-		d->si_utime =3D s->si_utime;
-		d->si_stime =3D s->si_stime;
-		break;
-	case SIGSEGV:
-	case SIGBUS:
-	case SIGFPE:
-	case SIGILL:
-		d->si_addr =3D (long)(s->si_addr);
-		/* XXX: Do we need to translate this from ia64 to ia32 traps? */
-		d->si_trapno =3D s->si_trapno;
-		break;
-	case SIGPOLL:
-		d->si_band =3D s->si_band;
-		d->si_fd =3D s->si_fd;
-		break;
-	default:
-		d->si_pid =3D s->si_pid;
-		d->si_uid =3D s->si_uid;
-		break;
-	}
-	return d;
-}
-
-siginfo_t *
-siginfo32to64(siginfo_t *d, siginfo_t32 *s)
-{
-	d->si_signo =3D s->si_signo;
-	d->si_errno =3D s->si_errno;
-	d->si_code =3D s->si_code;
-	if (s->si_signo >=3D SIGRTMIN) {
-		d->si_pid =3D s->si_pid;
-		d->si_uid =3D s->si_uid;
-		/* XXX: Ouch, how to find this out??? */
-		d->si_int =3D s->si_int;
-	} else switch (s->si_signo) {
-	/* XXX: What about POSIX1.b timers */
-	case SIGCHLD:
-		d->si_pid =3D s->si_pid;
-		d->si_status =3D s->si_status;
-		d->si_utime =3D s->si_utime;
-		d->si_stime =3D s->si_stime;
-		break;
-	case SIGSEGV:
-	case SIGBUS:
-	case SIGFPE:
-	case SIGILL:
-		d->si_addr =3D (void *)A(s->si_addr);
-		/* XXX: Do we need to translate this from ia32 to ia64 traps? */
-		d->si_trapno =3D s->si_trapno;
-		break;
-	case SIGPOLL:
-		d->si_band =3D s->si_band;
-		d->si_fd =3D s->si_fd;
-		break;
-	default:
-		d->si_pid =3D s->si_pid;
-		d->si_uid =3D s->si_uid;
-		break;
-	}
-	return d;
-}
-
-extern asmlinkage long
-sys_rt_sigtimedwait(const sigset_t *uthese, siginfo_t *uinfo,
-		    const struct timespec *uts, size_t sigsetsize);
-
-asmlinkage long
-sys32_rt_sigtimedwait(sigset_t32 *uthese, siginfo_t32 *uinfo,
-		      struct timespec32 *uts, __kernel_size_t32 sigsetsize)
-{
-	sigset_t s;
-	sigset_t32 s32;
-	struct timespec t;
-	int ret;
-	mm_segment_t old_fs =3D get_fs();
-	siginfo_t info;
-	siginfo_t32 info32;
-
-	if (copy_from_user (&s32, uthese, sizeof(sigset_t32)))
-		return -EFAULT;
-	switch (_NSIG_WORDS) {
-	case 4: s.sig[3] =3D s32.sig[6] | (((long)s32.sig[7]) << 32);
-	case 3: s.sig[2] =3D s32.sig[4] | (((long)s32.sig[5]) << 32);
-	case 2: s.sig[1] =3D s32.sig[2] | (((long)s32.sig[3]) << 32);
-	case 1: s.sig[0] =3D s32.sig[0] | (((long)s32.sig[1]) << 32);
-	}
-	if (uts) {
-		ret =3D get_user (t.tv_sec, &uts->tv_sec);
-		ret |=3D __get_user (t.tv_nsec, &uts->tv_nsec);
-		if (ret)
-			return -EFAULT;
-	}
-	set_fs (KERNEL_DS);
-	ret =3D sys_rt_sigtimedwait(&s, &info, &t, sigsetsize);
-	set_fs (old_fs);
-	if (ret >=3D 0 && uinfo) {
-		if (copy_to_user (uinfo, siginfo64to32(&info32, &info),
-				  sizeof(siginfo_t32)))
-			return -EFAULT;
-	}
-	return ret;
-}
-
-extern asmlinkage long
-sys_rt_sigqueueinfo(int pid, int sig, siginfo_t *uinfo);
-
-asmlinkage long
-sys32_rt_sigqueueinfo(int pid, int sig, siginfo_t32 *uinfo)
-{
-	siginfo_t info;
-	siginfo_t32 info32;
-	int ret;
-	mm_segment_t old_fs =3D get_fs();
-
-	if (copy_from_user (&info32, uinfo, sizeof(siginfo_t32)))
-		return -EFAULT;
-	/* XXX: Is this correct? */
-	siginfo32to64(&info, &info32);
-	set_fs (KERNEL_DS);
-	ret =3D sys_rt_sigqueueinfo(pid, sig, &info);
-	set_fs (old_fs);
-	return ret;
-}
-
-extern asmlinkage long sys_setreuid(uid_t ruid, uid_t euid);
+extern asmlinkage long sys_setreuid(uid_t ruid, uid_t euid);
=20
 asmlinkage long sys32_setreuid(__kernel_uid_t32 ruid, __kernel_uid_t32 eui=
d)
 {
@@ -3462,24 +3614,6 @@
 	return sys_setresuid(sruid, seuid, ssuid);
 }
=20
-extern asmlinkage long sys_getresuid(uid_t *ruid, uid_t *euid, uid_t *suid=
);
-
-asmlinkage long
-sys32_getresuid(__kernel_uid_t32 *ruid, __kernel_uid_t32 *euid,
-		__kernel_uid_t32 *suid)
-{
-	uid_t a, b, c;
-	int ret;
-	mm_segment_t old_fs =3D get_fs();
-
-	set_fs (KERNEL_DS);
-	ret =3D sys_getresuid(&a, &b, &c);
-	set_fs (old_fs);
-	if (put_user (a, ruid) || put_user (b, euid) || put_user (c, suid))
-		return -EFAULT;
-	return ret;
-}
-
 extern asmlinkage long sys_setregid(gid_t rgid, gid_t egid);
=20
 asmlinkage long
@@ -3506,46 +3640,6 @@
 	return sys_setresgid(srgid, segid, ssgid);
 }
=20
-extern asmlinkage long sys_getgroups(int gidsetsize, gid_t *grouplist);
-
-asmlinkage long
-sys32_getgroups(int gidsetsize, __kernel_gid_t32 *grouplist)
-{
-	gid_t gl[NGROUPS];
-	int ret, i;
-	mm_segment_t old_fs =3D get_fs ();
-
-	set_fs (KERNEL_DS);
-	ret =3D sys_getgroups(gidsetsize, gl);
-	set_fs (old_fs);
-	if (gidsetsize && ret > 0 && ret <=3D NGROUPS)
-		for (i =3D 0; i < ret; i++, grouplist++)
-			if (__put_user (gl[i], grouplist))
-				return -EFAULT;
-	return ret;
-}
-
-extern asmlinkage long sys_setgroups(int gidsetsize, gid_t *grouplist);
-
-asmlinkage long
-sys32_setgroups(int gidsetsize, __kernel_gid_t32 *grouplist)
-{
-	gid_t gl[NGROUPS];
-	int ret, i;
-	mm_segment_t old_fs =3D get_fs ();
-
-	if ((unsigned) gidsetsize > NGROUPS)
-		return -EINVAL;
-	for (i =3D 0; i < gidsetsize; i++, grouplist++)
-		if (__get_user (gl[i], grouplist))
-			return -EFAULT;
-	set_fs (KERNEL_DS);
-	ret =3D sys_setgroups(gidsetsize, gl);
-	set_fs (old_fs);
-	return ret;
-}
-
-
 /* XXX These as well... */
 extern __inline__ struct socket *
 socki_lookup(struct inode *inode)
@@ -3947,601 +4041,165 @@
 		kcmsg32->cmsg_len =3D clen32;
=20
 		ucmsg =3D (struct cmsghdr *) (((char *)ucmsg) +
-					    CMSG_ALIGN(clen64));
-		wp =3D (((char *)kcmsg32) + CMSG32_ALIGN(clen32));
-	}
-
-	/* Copy back fixed up data, and adjust pointers. */
-	bufsz =3D (wp - workbuf);
-	copy_to_user((void *)orig_cmsg_uptr, workbuf, bufsz);
-
-	kmsg->msg_control =3D (struct cmsghdr *)
-		(((char *)orig_cmsg_uptr) + bufsz);
-	kmsg->msg_controllen =3D space_avail - bufsz;
-
-	kfree(workbuf);
-	return;
-
-fail:
-	/* If we leave the 64-bit format CMSG chunks in there,
-	 * the application could get confused and crash.  So to
-	 * ensure greater recovery, we report no CMSGs.
-	 */
-	kmsg->msg_controllen +=3D bufsz;
-	kmsg->msg_control =3D (void *) orig_cmsg_uptr;
-}
-
-asmlinkage long
-sys32_sendmsg(int fd, struct msghdr32 *user_msg, unsigned user_flags)
-{
-	struct socket *sock;
-	char address[MAX_SOCK_ADDR];
-	struct iovec iov[UIO_FASTIOV];
-	unsigned char ctl[sizeof(struct cmsghdr) + 20];
-	unsigned char *ctl_buf =3D ctl;
-	struct msghdr kern_msg;
-	int err, total_len;
-
-	if(msghdr_from_user32_to_kern(&kern_msg, user_msg))
-		return -EFAULT;
-	if(kern_msg.msg_iovlen > UIO_MAXIOV)
-		return -EINVAL;
-	err =3D verify_iovec32(&kern_msg, iov, address, VERIFY_READ);
-	if (err < 0)
-		goto out;
-	total_len =3D err;
-
-	if(kern_msg.msg_controllen) {
-		err =3D cmsghdr_from_user32_to_kern(&kern_msg, ctl, sizeof(ctl));
-		if(err)
-			goto out_freeiov;
-		ctl_buf =3D kern_msg.msg_control;
-	}
-	kern_msg.msg_flags =3D user_flags;
-
-	sock =3D sockfd_lookup(fd, &err);
-	if (sock !=3D NULL) {
-		if (sock->file->f_flags & O_NONBLOCK)
-			kern_msg.msg_flags |=3D MSG_DONTWAIT;
-		err =3D sock_sendmsg(sock, &kern_msg, total_len);
-		sockfd_put(sock);
-	}
-
-	/* N.B. Use kfree here, as kern_msg.msg_controllen might change? */
-	if(ctl_buf !=3D ctl)
-		kfree(ctl_buf);
-out_freeiov:
-	if(kern_msg.msg_iov !=3D iov)
-		kfree(kern_msg.msg_iov);
-out:
-	return err;
-}
-
-asmlinkage long
-sys32_recvmsg(int fd, struct msghdr32 *user_msg, unsigned int user_flags)
-{
-	struct iovec iovstack[UIO_FASTIOV];
-	struct msghdr kern_msg;
-	char addr[MAX_SOCK_ADDR];
-	struct socket *sock;
-	struct iovec *iov =3D iovstack;
-	struct sockaddr *uaddr;
-	int *uaddr_len;
-	unsigned long cmsg_ptr;
-	int err, total_len, len =3D 0;
-
-	if(msghdr_from_user32_to_kern(&kern_msg, user_msg))
-		return -EFAULT;
-	if(kern_msg.msg_iovlen > UIO_MAXIOV)
-		return -EINVAL;
-
-	uaddr =3D kern_msg.msg_name;
-	uaddr_len =3D &user_msg->msg_namelen;
-	err =3D verify_iovec32(&kern_msg, iov, addr, VERIFY_WRITE);
-	if (err < 0)
-		goto out;
-	total_len =3D err;
-
-	cmsg_ptr =3D (unsigned long) kern_msg.msg_control;
-	kern_msg.msg_flags =3D 0;
-
-	sock =3D sockfd_lookup(fd, &err);
-	if (sock !=3D NULL) {
-		struct scm_cookie scm;
-
-		if (sock->file->f_flags & O_NONBLOCK)
-			user_flags |=3D MSG_DONTWAIT;
-		memset(&scm, 0, sizeof(scm));
-		lock_kernel();
-		err =3D sock->ops->recvmsg(sock, &kern_msg, total_len,
-					 user_flags, &scm);
-		if(err >=3D 0) {
-			len =3D err;
-			if(!kern_msg.msg_control) {
-				if(sock->passcred || scm.fp)
-					kern_msg.msg_flags |=3D MSG_CTRUNC;
-				if(scm.fp)
-					__scm_destroy(&scm);
-			} else {
-				/* If recvmsg processing itself placed some
-				 * control messages into user space, it's is
-				 * using 64-bit CMSG processing, so we need
-				 * to fix it up before we tack on more stuff.
-				 */
-				if((unsigned long) kern_msg.msg_control
-				   !=3D cmsg_ptr)
-					cmsg32_recvmsg_fixup(&kern_msg,
-							     cmsg_ptr);
-
-				/* Wheee... */
-				if(sock->passcred)
-					put_cmsg32(&kern_msg,
-						   SOL_SOCKET, SCM_CREDENTIALS,
-						   sizeof(scm.creds),
-						   &scm.creds);
-				if(scm.fp !=3D NULL)
-					scm_detach_fds32(&kern_msg, &scm);
-			}
-		}
-		unlock_kernel();
-		sockfd_put(sock);
-	}
-
-	if(uaddr !=3D NULL && err >=3D 0)
-		err =3D move_addr_to_user(addr, kern_msg.msg_namelen, uaddr,
-					uaddr_len);
-	if(cmsg_ptr !=3D 0 && err >=3D 0) {
-		unsigned long ucmsg_ptr =3D ((unsigned long)kern_msg.msg_control);
-		__kernel_size_t32 uclen =3D (__kernel_size_t32) (ucmsg_ptr
-							       - cmsg_ptr);
-		err |=3D __put_user(uclen, &user_msg->msg_controllen);
-	}
-	if(err >=3D 0)
-		err =3D __put_user(kern_msg.msg_flags, &user_msg->msg_flags);
-	if(kern_msg.msg_iov !=3D iov)
-		kfree(kern_msg.msg_iov);
-out:
-	if(err < 0)
-		return err;
-	return len;
-}
-
-extern void check_pending(int signum);
-
-#ifdef CONFIG_MODULES
-
-extern asmlinkage unsigned long sys_create_module(const char *name_user,
-						  size_t size);
-
-asmlinkage unsigned long
-sys32_create_module(const char *name_user, __kernel_size_t32 size)
-{
-	return sys_create_module(name_user, (size_t)size);
-}
-
-extern asmlinkage long sys_init_module(const char *name_user,
-				      struct module *mod_user);
-
-/* Hey, when you're trying to init module, take time and prepare us a nice=
 64bit
- * module structure, even if from 32bit modutils... Why to pollute kernel.=
.. :))
- */
-asmlinkage long
-sys32_init_module(const char *name_user, struct module *mod_user)
-{
-	return sys_init_module(name_user, mod_user);
-}
-
-extern asmlinkage long sys_delete_module(const char *name_user);
-
-asmlinkage long
-sys32_delete_module(const char *name_user)
-{
-	return sys_delete_module(name_user);
-}
-
-struct module_info32 {
-	u32 addr;
-	u32 size;
-	u32 flags;
-	s32 usecount;
-};
-
-/* Query various bits about modules.  */
-
-static inline long
-get_mod_name(const char *user_name, char **buf)
-{
-	unsigned long page;
-	long retval;
-
-	if ((unsigned long)user_name >=3D TASK_SIZE
-	    && !segment_eq(get_fs (), KERNEL_DS))
-		return -EFAULT;
-
-	page =3D __get_free_page(GFP_KERNEL);
-	if (!page)
-		return -ENOMEM;
-
-	retval =3D strncpy_from_user((char *)page, user_name, PAGE_SIZE);
-	if (retval > 0) {
-		if (retval < PAGE_SIZE) {
-			*buf =3D (char *)page;
-			return retval;
-		}
-		retval =3D -ENAMETOOLONG;
-	} else if (!retval)
-		retval =3D -EINVAL;
-
-	free_page(page);
-	return retval;
-}
-
-static inline void
-put_mod_name(char *buf)
-{
-	free_page((unsigned long)buf);
-}
-
-static __inline__ struct module *
-find_module(const char *name)
-{
-	struct module *mod;
-
-	for (mod =3D module_list; mod ; mod =3D mod->next) {
-		if (mod->flags & MOD_DELETED)
-			continue;
-		if (!strcmp(mod->name, name))
-			break;
-	}
-
-	return mod;
-}
-
-static int
-qm_modules(char *buf, size_t bufsize, __kernel_size_t32 *ret)
-{
-	struct module *mod;
-	size_t nmod, space, len;
-
-	nmod =3D space =3D 0;
-
-	for (mod =3D module_list; mod->next !=3D NULL; mod =3D mod->next, ++nmod)=
 {
-		len =3D strlen(mod->name)+1;
-		if (len > bufsize)
-			goto calc_space_needed;
-		if (copy_to_user(buf, mod->name, len))
-			return -EFAULT;
-		buf +=3D len;
-		bufsize -=3D len;
-		space +=3D len;
-	}
-
-	if (put_user(nmod, ret))
-		return -EFAULT;
-	else
-		return 0;
-
-calc_space_needed:
-	space +=3D len;
-	while ((mod =3D mod->next)->next !=3D NULL)
-		space +=3D strlen(mod->name)+1;
-
-	if (put_user(space, ret))
-		return -EFAULT;
-	else
-		return -ENOSPC;
-}
-
-static int
-qm_deps(struct module *mod, char *buf, size_t bufsize, __kernel_size_t32 *=
ret)
-{
-	size_t i, space, len;
-
-	if (mod->next =3D NULL)
-		return -EINVAL;
-	if ((mod->flags & (MOD_RUNNING | MOD_DELETED)) !=3D MOD_RUNNING)
-		if (put_user(0, ret))
-			return -EFAULT;
-		else
-			return 0;
-
-	space =3D 0;
-	for (i =3D 0; i < mod->ndeps; ++i) {
-		const char *dep_name =3D mod->deps[i].dep->name;
-
-		len =3D strlen(dep_name)+1;
-		if (len > bufsize)
-			goto calc_space_needed;
-		if (copy_to_user(buf, dep_name, len))
-			return -EFAULT;
-		buf +=3D len;
-		bufsize -=3D len;
-		space +=3D len;
-	}
-
-	if (put_user(i, ret))
-		return -EFAULT;
-	else
-		return 0;
-
-calc_space_needed:
-	space +=3D len;
-	while (++i < mod->ndeps)
-		space +=3D strlen(mod->deps[i].dep->name)+1;
-
-	if (put_user(space, ret))
-		return -EFAULT;
-	else
-		return -ENOSPC;
-}
-
-static int
-qm_refs(struct module *mod, char *buf, size_t bufsize, __kernel_size_t32 *=
ret)
-{
-	size_t nrefs, space, len;
-	struct module_ref *ref;
-
-	if (mod->next =3D NULL)
-		return -EINVAL;
-	if ((mod->flags & (MOD_RUNNING | MOD_DELETED)) !=3D MOD_RUNNING)
-		if (put_user(0, ret))
-			return -EFAULT;
-		else
-			return 0;
-
-	space =3D 0;
-	for (nrefs =3D 0, ref =3D mod->refs; ref ; ++nrefs, ref =3D ref->next_ref=
) {
-		const char *ref_name =3D ref->ref->name;
-
-		len =3D strlen(ref_name)+1;
-		if (len > bufsize)
-			goto calc_space_needed;
-		if (copy_to_user(buf, ref_name, len))
-			return -EFAULT;
-		buf +=3D len;
-		bufsize -=3D len;
-		space +=3D len;
-	}
-
-	if (put_user(nrefs, ret))
-		return -EFAULT;
-	else
-		return 0;
-
-calc_space_needed:
-	space +=3D len;
-	while ((ref =3D ref->next_ref) !=3D NULL)
-		space +=3D strlen(ref->ref->name)+1;
-
-	if (put_user(space, ret))
-		return -EFAULT;
-	else
-		return -ENOSPC;
-}
-
-static inline int
-qm_symbols(struct module *mod, char *buf, size_t bufsize,
-	   __kernel_size_t32 *ret)
-{
-	size_t i, space, len;
-	struct module_symbol *s;
-	char *strings;
-	unsigned *vals;
-
-	if ((mod->flags & (MOD_RUNNING | MOD_DELETED)) !=3D MOD_RUNNING)
-		if (put_user(0, ret))
-			return -EFAULT;
-		else
-			return 0;
-
-	space =3D mod->nsyms * 2*sizeof(u32);
-
-	i =3D len =3D 0;
-	s =3D mod->syms;
-
-	if (space > bufsize)
-		goto calc_space_needed;
-
-	if (!access_ok(VERIFY_WRITE, buf, space))
-		return -EFAULT;
-
-	bufsize -=3D space;
-	vals =3D (unsigned *)buf;
-	strings =3D buf+space;
-
-	for (; i < mod->nsyms ; ++i, ++s, vals +=3D 2) {
-		len =3D strlen(s->name)+1;
-		if (len > bufsize)
-			goto calc_space_needed;
-
-		if (copy_to_user(strings, s->name, len)
-		    || __put_user(s->value, vals+0)
-		    || __put_user(space, vals+1))
-			return -EFAULT;
-
-		strings +=3D len;
-		bufsize -=3D len;
-		space +=3D len;
-	}
-
-	if (put_user(i, ret))
-		return -EFAULT;
-	else
-		return 0;
-
-calc_space_needed:
-	for (; i < mod->nsyms; ++i, ++s)
-		space +=3D strlen(s->name)+1;
-
-	if (put_user(space, ret))
-		return -EFAULT;
-	else
-		return -ENOSPC;
-}
-
-static inline int
-qm_info(struct module *mod, char *buf, size_t bufsize, __kernel_size_t32 *=
ret)
-{
-	int error =3D 0;
-
-	if (mod->next =3D NULL)
-		return -EINVAL;
+					    CMSG_ALIGN(clen64));
+		wp =3D (((char *)kcmsg32) + CMSG32_ALIGN(clen32));
+	}
=20
-	if (sizeof(struct module_info32) <=3D bufsize) {
-		struct module_info32 info;
-		info.addr =3D (unsigned long)mod;
-		info.size =3D mod->size;
-		info.flags =3D mod->flags;
-		info.usecount -			((mod_member_present(mod, can_unload)
-			  && mod->can_unload)
-			 ? -1 : atomic_read(&mod->uc.usecount));
+	/* Copy back fixed up data, and adjust pointers. */
+	bufsz =3D (wp - workbuf);
+	copy_to_user((void *)orig_cmsg_uptr, workbuf, bufsz);
=20
-		if (copy_to_user(buf, &info, sizeof(struct module_info32)))
-			return -EFAULT;
-	} else
-		error =3D -ENOSPC;
+	kmsg->msg_control =3D (struct cmsghdr *)
+		(((char *)orig_cmsg_uptr) + bufsz);
+	kmsg->msg_controllen =3D space_avail - bufsz;
=20
-	if (put_user(sizeof(struct module_info32), ret))
-		return -EFAULT;
+	kfree(workbuf);
+	return;
=20
-	return error;
+fail:
+	/* If we leave the 64-bit format CMSG chunks in there,
+	 * the application could get confused and crash.  So to
+	 * ensure greater recovery, we report no CMSGs.
+	 */
+	kmsg->msg_controllen +=3D bufsz;
+	kmsg->msg_control =3D (void *) orig_cmsg_uptr;
 }
=20
 asmlinkage long
-sys32_query_module(char *name_user, int which, char *buf,
-		   __kernel_size_t32 bufsize, u32 ret)
+sys32_sendmsg(int fd, struct msghdr32 *user_msg, unsigned user_flags)
 {
-	struct module *mod;
-	int err;
+	struct socket *sock;
+	char address[MAX_SOCK_ADDR];
+	struct iovec iov[UIO_FASTIOV];
+	unsigned char ctl[sizeof(struct cmsghdr) + 20];
+	unsigned char *ctl_buf =3D ctl;
+	struct msghdr kern_msg;
+	int err, total_len;
=20
-	lock_kernel();
-	if (name_user =3D 0) {
-		/* This finds "kernel_module" which is not exported. */
-		for(mod =3D module_list; mod->next !=3D NULL; mod =3D mod->next)
-			;
-	} else {
-		long namelen;
-		char *name;
+	if(msghdr_from_user32_to_kern(&kern_msg, user_msg))
+		return -EFAULT;
+	if(kern_msg.msg_iovlen > UIO_MAXIOV)
+		return -EINVAL;
+	err =3D verify_iovec32(&kern_msg, iov, address, VERIFY_READ);
+	if (err < 0)
+		goto out;
+	total_len =3D err;
=20
-		if ((namelen =3D get_mod_name(name_user, &name)) < 0) {
-			err =3D namelen;
-			goto out;
-		}
-		err =3D -ENOENT;
-		if (namelen =3D 0) {
-			/* This finds "kernel_module" which is not exported. */
-			for(mod =3D module_list;
-			    mod->next !=3D NULL;
-			    mod =3D mod->next) ;
-		} else if ((mod =3D find_module(name)) =3D NULL) {
-			put_mod_name(name);
-			goto out;
-		}
-		put_mod_name(name);
+	if(kern_msg.msg_controllen) {
+		err =3D cmsghdr_from_user32_to_kern(&kern_msg, ctl, sizeof(ctl));
+		if(err)
+			goto out_freeiov;
+		ctl_buf =3D kern_msg.msg_control;
 	}
+	kern_msg.msg_flags =3D user_flags;
=20
-	switch (which)
-	{
-	case 0:
-		err =3D 0;
-		break;
-	case QM_MODULES:
-		err =3D qm_modules(buf, bufsize, (__kernel_size_t32 *)AA(ret));
-		break;
-	case QM_DEPS:
-		err =3D qm_deps(mod, buf, bufsize, (__kernel_size_t32 *)AA(ret));
-		break;
-	case QM_REFS:
-		err =3D qm_refs(mod, buf, bufsize, (__kernel_size_t32 *)AA(ret));
-		break;
-	case QM_SYMBOLS:
-		err =3D qm_symbols(mod, buf, bufsize,
-				 (__kernel_size_t32 *)AA(ret));
-		break;
-	case QM_INFO:
-		err =3D qm_info(mod, buf, bufsize, (__kernel_size_t32 *)AA(ret));
-		break;
-	default:
-		err =3D -EINVAL;
-		break;
+	sock =3D sockfd_lookup(fd, &err);
+	if (sock !=3D NULL) {
+		if (sock->file->f_flags & O_NONBLOCK)
+			kern_msg.msg_flags |=3D MSG_DONTWAIT;
+		err =3D sock_sendmsg(sock, &kern_msg, total_len);
+		sockfd_put(sock);
 	}
+
+	/* N.B. Use kfree here, as kern_msg.msg_controllen might change? */
+	if(ctl_buf !=3D ctl)
+		kfree(ctl_buf);
+out_freeiov:
+	if(kern_msg.msg_iov !=3D iov)
+		kfree(kern_msg.msg_iov);
 out:
-	unlock_kernel();
 	return err;
 }
=20
-struct kernel_sym32 {
-	u32 value;
-	char name[60];
-};
-
-extern asmlinkage long sys_get_kernel_syms(struct kernel_sym *table);
-
 asmlinkage long
-sys32_get_kernel_syms(struct kernel_sym32 *table)
+sys32_recvmsg(int fd, struct msghdr32 *user_msg, unsigned int user_flags)
 {
-	int len, i;
-	struct kernel_sym *tbl;
-	mm_segment_t old_fs;
-
-	len =3D sys_get_kernel_syms(NULL);
-	if (!table) return len;
-	tbl =3D kmalloc (len * sizeof (struct kernel_sym), GFP_KERNEL);
-	if (!tbl) return -ENOMEM;
-	old_fs =3D get_fs();
-	set_fs (KERNEL_DS);
-	sys_get_kernel_syms(tbl);
-	set_fs (old_fs);
-	for (i =3D 0; i < len; i++, table +=3D sizeof (struct kernel_sym32)) {
-		if (put_user (tbl[i].value, &table->value) ||
-		    copy_to_user (table->name, tbl[i].name, 60))
-			break;
-	}
-	kfree (tbl);
-	return i;
-}
+	struct iovec iovstack[UIO_FASTIOV];
+	struct msghdr kern_msg;
+	char addr[MAX_SOCK_ADDR];
+	struct socket *sock;
+	struct iovec *iov =3D iovstack;
+	struct sockaddr *uaddr;
+	int *uaddr_len;
+	unsigned long cmsg_ptr;
+	int err, total_len, len =3D 0;
=20
-#else /* CONFIG_MODULES */
+	if(msghdr_from_user32_to_kern(&kern_msg, user_msg))
+		return -EFAULT;
+	if(kern_msg.msg_iovlen > UIO_MAXIOV)
+		return -EINVAL;
=20
-asmlinkage unsigned long
-sys32_create_module(const char *name_user, size_t size)
-{
-	return -ENOSYS;
-}
+	uaddr =3D kern_msg.msg_name;
+	uaddr_len =3D &user_msg->msg_namelen;
+	err =3D verify_iovec32(&kern_msg, iov, addr, VERIFY_WRITE);
+	if (err < 0)
+		goto out;
+	total_len =3D err;
=20
-asmlinkage long
-sys32_init_module(const char *name_user, struct module *mod_user)
-{
-	return -ENOSYS;
-}
+	cmsg_ptr =3D (unsigned long) kern_msg.msg_control;
+	kern_msg.msg_flags =3D 0;
=20
-asmlinkage long
-sys32_delete_module(const char *name_user)
-{
-	return -ENOSYS;
-}
+	sock =3D sockfd_lookup(fd, &err);
+	if (sock !=3D NULL) {
+		struct scm_cookie scm;
=20
-asmlinkage long
-sys32_query_module(const char *name_user, int which, char *buf, size_t buf=
size,
-		 size_t *ret)
-{
-	/* Let the program know about the new interface.  Not that
-	   it'll do them much good.  */
-	if (which =3D 0)
-		return 0;
+		if (sock->file->f_flags & O_NONBLOCK)
+			user_flags |=3D MSG_DONTWAIT;
+		memset(&scm, 0, sizeof(scm));
+		lock_kernel();
+		err =3D sock->ops->recvmsg(sock, &kern_msg, total_len,
+					 user_flags, &scm);
+		if(err >=3D 0) {
+			len =3D err;
+			if(!kern_msg.msg_control) {
+				if(sock->passcred || scm.fp)
+					kern_msg.msg_flags |=3D MSG_CTRUNC;
+				if(scm.fp)
+					__scm_destroy(&scm);
+			} else {
+				/* If recvmsg processing itself placed some
+				 * control messages into user space, it's is
+				 * using 64-bit CMSG processing, so we need
+				 * to fix it up before we tack on more stuff.
+				 */
+				if((unsigned long) kern_msg.msg_control
+				   !=3D cmsg_ptr)
+					cmsg32_recvmsg_fixup(&kern_msg,
+							     cmsg_ptr);
=20
-	return -ENOSYS;
-}
+				/* Wheee... */
+				if(sock->passcred)
+					put_cmsg32(&kern_msg,
+						   SOL_SOCKET, SCM_CREDENTIALS,
+						   sizeof(scm.creds),
+						   &scm.creds);
+				if(scm.fp !=3D NULL)
+					scm_detach_fds32(&kern_msg, &scm);
+			}
+		}
+		unlock_kernel();
+		sockfd_put(sock);
+	}
=20
-asmlinkage long
-sys32_get_kernel_syms(struct kernel_sym *table)
-{
-	return -ENOSYS;
+	if(uaddr !=3D NULL && err >=3D 0)
+		err =3D move_addr_to_user(addr, kern_msg.msg_namelen, uaddr,
+					uaddr_len);
+	if(cmsg_ptr !=3D 0 && err >=3D 0) {
+		unsigned long ucmsg_ptr =3D ((unsigned long)kern_msg.msg_control);
+		__kernel_size_t32 uclen =3D (__kernel_size_t32) (ucmsg_ptr
+							       - cmsg_ptr);
+		err |=3D __put_user(uclen, &user_msg->msg_controllen);
+	}
+	if(err >=3D 0)
+		err =3D __put_user(kern_msg.msg_flags, &user_msg->msg_flags);
+	if(kern_msg.msg_iov !=3D iov)
+		kfree(kern_msg.msg_iov);
+out:
+	if(err < 0)
+		return err;
+	return len;
 }
=20
-#endif  /* CONFIG_MODULES */
-
 /* Stuff for NFS server syscalls... */
 struct nfsctl_svc32 {
 	u16			svc32_port;
@@ -4821,152 +4479,12 @@
 	return err;
 }
=20
-asmlinkage long sys_utimes(char *, struct timeval *);
-
-asmlinkage long
-sys32_utimes(char *filename, struct timeval32 *tvs)
-{
-	char *kfilename;
-	struct timeval ktvs[2];
-	mm_segment_t old_fs;
-	int ret;
-
-	kfilename =3D getname32(filename);
-	ret =3D PTR_ERR(kfilename);
-	if (!IS_ERR(kfilename)) {
-		if (tvs) {
-			if (get_tv32(&ktvs[0], tvs) ||
-			    get_tv32(&ktvs[1], 1+tvs))
-				return -EFAULT;
-		}
-
-		old_fs =3D get_fs();
-		set_fs(KERNEL_DS);
-		ret =3D sys_utimes(kfilename, &ktvs[0]);
-		set_fs(old_fs);
-
-		putname(kfilename);
-	}
-	return ret;
-}
-
-/* These are here just in case some old ia32 binary calls it. */
-asmlinkage long
-sys32_pause(void)
-{
-	current->state =3D TASK_INTERRUPTIBLE;
-	schedule();
-	return -ERESTARTNOHAND;
-}
-
-/* PCI config space poking. */
-extern asmlinkage long sys_pciconfig_read(unsigned long bus,
-					 unsigned long dfn,
-					 unsigned long off,
-					 unsigned long len,
-					 unsigned char *buf);
-
-extern asmlinkage long sys_pciconfig_write(unsigned long bus,
-					  unsigned long dfn,
-					  unsigned long off,
-					  unsigned long len,
-					  unsigned char *buf);
-
-asmlinkage long
-sys32_pciconfig_read(u32 bus, u32 dfn, u32 off, u32 len, u32 ubuf)
-{
-	return sys_pciconfig_read((unsigned long) bus,
-				  (unsigned long) dfn,
-				  (unsigned long) off,
-				  (unsigned long) len,
-				  (unsigned char *)AA(ubuf));
-}
-
-asmlinkage long
-sys32_pciconfig_write(u32 bus, u32 dfn, u32 off, u32 len, u32 ubuf)
-{
-	return sys_pciconfig_write((unsigned long) bus,
-				   (unsigned long) dfn,
-				   (unsigned long) off,
-				   (unsigned long) len,
-				   (unsigned char *)AA(ubuf));
-}
-
-extern asmlinkage long sys_prctl(int option, unsigned long arg2,
-				unsigned long arg3, unsigned long arg4,
-				unsigned long arg5);
-
-asmlinkage long
-sys32_prctl(int option, u32 arg2, u32 arg3, u32 arg4, u32 arg5)
-{
-	return sys_prctl(option,
-			 (unsigned long) arg2,
-			 (unsigned long) arg3,
-			 (unsigned long) arg4,
-			 (unsigned long) arg5);
-}
-
-
-extern asmlinkage ssize_t sys_pread(unsigned int fd, char * buf,
-				    size_t count, loff_t pos);
-
-extern asmlinkage ssize_t sys_pwrite(unsigned int fd, const char * buf,
-				     size_t count, loff_t pos);
-
-typedef __kernel_ssize_t32 ssize_t32;
-
-asmlinkage ssize_t32
-sys32_pread(unsigned int fd, char *ubuf, __kernel_size_t32 count,
-	    u32 poshi, u32 poslo)
-{
-	return sys_pread(fd, ubuf, count,
-			 ((loff_t)AA(poshi) << 32) | AA(poslo));
-}
-
-asmlinkage ssize_t32
-sys32_pwrite(unsigned int fd, char *ubuf, __kernel_size_t32 count,
-	     u32 poshi, u32 poslo)
-{
-	return sys_pwrite(fd, ubuf, count,
-			  ((loff_t)AA(poshi) << 32) | AA(poslo));
-}
-
-
-extern asmlinkage long sys_personality(unsigned long);
-
-asmlinkage long
-sys32_personality(unsigned long personality)
-{
-	int ret;
-	if (current->personality =3D PER_LINUX32 && personality =3D PER_LINUX)
-		personality =3D PER_LINUX32;
-	ret =3D sys_personality(personality);
-	if (ret =3D PER_LINUX32)
-		ret =3D PER_LINUX;
-	return ret;
-}
-
 extern asmlinkage ssize_t sys_sendfile(int out_fd, int in_fd, off_t *offse=
t,
 				       size_t count);
=20
 asmlinkage long
 sys32_sendfile(int out_fd, int in_fd, __kernel_off_t32 *offset, s32 count)
 {
-	mm_segment_t old_fs =3D get_fs();
-	int ret;
-	off_t of;
-
-	if (offset && get_user(of, offset))
-		return -EFAULT;
-
-	set_fs(KERNEL_DS);
-	ret =3D sys_sendfile(out_fd, in_fd, offset ? &of : NULL, count);
-	set_fs(old_fs);
-
-	if (!ret && offset && put_user(of, offset))
-		return -EFAULT;
-
-	return ret;
 }
=20
 /* Handle adjtimex compatability. */
diff -urN linux-davidm/arch/ia64/kernel/acpi.c linux-2.4.10-lia/arch/ia64/k=
ernel/acpi.c
--- linux-davidm/arch/ia64/kernel/acpi.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/acpi.c	Mon Sep 24 21:45:43 2001
@@ -60,6 +60,8 @@
 	return "hpsim";
 # elif defined (CONFIG_IA64_SGI_SN1)
 	return "sn1";
+# elif defined (CONFIG_IA64_SGI_SN2)
+	return "sn2";
 # elif defined (CONFIG_IA64_DIG)
 	return "dig";
 # else
diff -urN linux-davidm/arch/ia64/kernel/efi_stub.S linux-2.4.10-lia/arch/ia=
64/kernel/efi_stub.S
--- linux-davidm/arch/ia64/kernel/efi_stub.S	Thu Apr  5 12:51:47 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/efi_stub.S	Mon Sep 24 21:45:52 2001
@@ -1,8 +1,8 @@
 /*
  * EFI call stub.
  *
- * Copyright (C) 1999-2000 Hewlett-Packard Co
- * Copyright (C) 1999-2000 David Mosberger <davidm@hpl.hp.com>
+ * Copyright (C) 1999-2001 Hewlett-Packard Co
+ *	David Mosberger <davidm@hpl.hp.com>
  *
  * This stub allows us to make EFI calls in physical mode with interrupts
  * turned off.  We need this because we can't call SetVirtualMap() until
@@ -68,17 +68,17 @@
 	;;
 	andcm r16=3Dloc3,r16		// get psr with IT, DT, and RT bits cleared
 	mov out3=3Din4
-	br.call.sptk.few rp=3Dia64_switch_mode
+	br.call.sptk.many rp=3Dia64_switch_mode
 .ret0:	mov out4=3Din5
 	mov out5=3Din6
 	mov out6=3Din7
-	br.call.sptk.few rp=B6		// call the EFI function
+	br.call.sptk.many rp=B6		// call the EFI function
 .ret1:	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
 	mov r16=3Dloc3
-	br.call.sptk.few rp=3Dia64_switch_mode // return to virtual mode
+	br.call.sptk.many rp=3Dia64_switch_mode // return to virtual mode
 .ret2:	mov ar.rsc=3Dloc4			// restore RSE configuration
 	mov ar.pfs=3Dloc1
 	mov rp=3Dloc0
 	mov gp=3Dloc2
-	br.ret.sptk.few rp
+	br.ret.sptk.many rp
 END(efi_call_phys)
diff -urN linux-davidm/arch/ia64/kernel/efivars.c linux-2.4.10-lia/arch/ia6=
4/kernel/efivars.c
--- linux-davidm/arch/ia64/kernel/efivars.c	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/efivars.c	Mon Sep 24 21:46:04 2001
@@ -276,21 +276,20 @@
 	if (!capable(CAP_SYS_ADMIN))
 		return -EACCES;
=20
-	spin_lock(&efivars_lock);
 	MOD_INC_USE_COUNT;
=20
 	var_data =3D kmalloc(size, GFP_KERNEL);
 	if (!var_data) {
 		MOD_DEC_USE_COUNT;
-		spin_unlock(&efivars_lock);
 		return -ENOMEM;
 	}
 	if (copy_from_user(var_data, buffer, size)) {
 		MOD_DEC_USE_COUNT;
-		spin_unlock(&efivars_lock);
+                kfree(var_data);
 		return -EFAULT;
 	}
=20
+	spin_lock(&efivars_lock);
=20
 	/* Since the data ptr we've currently got is probably for
 	   a different variable find the right variable.
diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.4.10-lia/arch/ia64/=
kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/entry.S	Mon Sep 24 21:46:12 2001
@@ -55,7 +55,7 @@
 	mov out1=3Din1			// argv
 	mov out2=3Din2			// envp
 	add out3=16,sp			// regs
-	br.call.sptk.few rp=3Dsys_execve
+	br.call.sptk.many rp=3Dsys_execve
 .ret0:	cmp4.ge p6,p7=3Dr8,r0
 	mov ar.pfs=3Dloc1			// restore ar.pfs
 	sxt4 r8=3Dr8			// return 64-bit result
@@ -64,7 +64,7 @@
 (p6)	cmp.ne pKern,pUser=3Dr0,r0	// a successful execve() lands us in user-=
mode...
 	mov rp=3Dloc0
 (p6)	mov ar.pfs=3Dr0			// clear ar.pfs on success
-(p7)	br.ret.sptk.few rp
+(p7)	br.ret.sptk.many rp
=20
 	/*
 	 * In theory, we'd have to zap this state only to prevent leaking of
@@ -85,7 +85,7 @@
 	ldf.fill f26=3D[sp];	ldf.fill f27=3D[sp];	mov f28=F0
 	ldf.fill f29=3D[sp];	ldf.fill f30=3D[sp];	mov f31=F0
 	mov ar.lc=3D0
-	br.ret.sptk.few rp
+	br.ret.sptk.many rp
 END(ia64_execve)
=20
 GLOBAL_ENTRY(sys_clone2)
@@ -99,7 +99,7 @@
 	mov out3=3Din2
 	adds out2=3DIA64_SWITCH_STACK_SIZE+16,sp	// out2 =3D &regs
 	mov out0=3Din0				// out0 =3D clone_flags
-	br.call.sptk.few rp=3Ddo_fork
+	br.call.sptk.many rp=3Ddo_fork
 .ret1:	.restore sp
 	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// pop the switch stack
 	mov ar.pfs=3Dloc1
@@ -118,7 +118,7 @@
 	mov out3=3D0
 	adds out2=3DIA64_SWITCH_STACK_SIZE+16,sp	// out2 =3D &regs
 	mov out0=3Din0				// out0 =3D clone_flags
-	br.call.sptk.few rp=3Ddo_fork
+	br.call.sptk.many rp=3Ddo_fork
 .ret2:	.restore sp
 	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// pop the switch stack
 	mov ar.pfs=3Dloc1
@@ -151,12 +151,13 @@
 	 * again.
 	 */
 (p6)	cmp.eq p7,p6=3Dr26,r27
-(p6)	br.cond.dpnt.few .map
+(p6)	br.cond.dpnt .map
 	;;
-.done:	ld8 sp=3D[r21]			// load kernel stack pointer of new task
+.done:
 (p6)	ssm psr.ic			// if we we had to map, renable the psr.ic bit FIRST!!!
 	;;
 (p6)	srlz.d
+	ld8 sp=3D[r21]			// load kernel stack pointer of new task
 	mov IA64_KR(CURRENT)=3Dr20	// update "current" application register
 	mov r8=3Dr13			// return pointer to previously running task
 	mov r13=3Din0			// set "current" pointer
@@ -167,7 +168,7 @@
 #ifdef CONFIG_SMP
 	sync.i				// ensure "fc"s done by this CPU are visible on other CPUs
 #endif
-	br.ret.sptk.few rp		// boogie on out in new context
+	br.ret.sptk.many rp		// boogie on out in new context
=20
 .map:
 	rsm psr.i | psr.ic
@@ -184,7 +185,7 @@
 	mov IA64_KR(CURRENT_STACK)=3Dr26	// remember last page we mapped...
 	;;
 	itr.d dtr[r25]=3Dr23		// wire in new mapping...
-	br.cond.sptk.many .done
+	br.cond.sptk .done
 END(ia64_switch_to)
=20
 /*
@@ -303,7 +304,7 @@
 	st8 [r2]=3Dr20		// save ar.bspstore
 	st8 [r3]=3Dr21		// save predicate registers
 	mov ar.rsc=3D3		// put RSE back into eager mode, pl 0
-	br.cond.sptk.few b7
+	br.cond.sptk.many b7
 END(save_switch_stack)
=20
 /*
@@ -418,7 +419,7 @@
 	;;
 (p6)	st4 [r2]=3Dr8
 (p6)	mov r8=3D-1
-	br.ret.sptk.few rp
+	br.ret.sptk.many rp
 END(__ia64_syscall)
=20
 	/*
@@ -433,11 +434,11 @@
 	.body
 	mov loc2=B6
 	;;
-	br.call.sptk.few rp=3Dsyscall_trace
+	br.call.sptk.many rp=3Dsyscall_trace
 .ret3:	mov rp=3Dloc0
 	mov ar.pfs=3Dloc1
 	mov b6=3Dloc2
-	br.ret.sptk.few rp
+	br.ret.sptk.many rp
 END(invoke_syscall_trace)
=20
 	/*
@@ -454,21 +455,21 @@
=20
 GLOBAL_ENTRY(ia64_trace_syscall)
 	PT_REGS_UNWIND_INFO(0)
-	br.call.sptk.few rp=3Dinvoke_syscall_trace // give parent a chance to cat=
ch syscall args
-.ret6:	br.call.sptk.few rp=B6			// do the syscall
+	br.call.sptk.many rp=3Dinvoke_syscall_trace // give parent a chance to ca=
tch syscall args
+.ret6:	br.call.sptk.many rp=B6			// do the syscall
 strace_check_retval:
 	cmp.lt p6,p0=3Dr8,r0			// syscall failed?
 	adds r2=3DPT(R8)+16,sp			// r2 =3D &pt_regs.r8
 	adds r3=3DPT(R10)+16,sp			// r3 =3D &pt_regs.r10
 	mov r10=3D0
-(p6)	br.cond.sptk.few strace_error		// syscall failed ->
+(p6)	br.cond.sptk strace_error		// syscall failed ->
 	;;					// avoid RAW on r10
 strace_save_retval:
 .mem.offset 0,0;	st8.spill [r2]=3Dr8	// store return value in slot for r8
 .mem.offset 8,0;	st8.spill [r3]=3Dr10	// clear error indication in slot fo=
r r10
 ia64_strace_leave_kernel:
-	br.call.sptk.few rp=3Dinvoke_syscall_trace // give parent a chance to cat=
ch return value
-.rety:	br.cond.sptk.many ia64_leave_kernel
+	br.call.sptk.many rp=3Dinvoke_syscall_trace // give parent a chance to ca=
tch return value
+.rety:	br.cond.sptk ia64_leave_kernel
=20
 strace_error:
 	ld8 r3=3D[r2]				// load pt_regs.r8
@@ -479,7 +480,7 @@
 	;;
 (p6)	mov r10=3D-1
 (p6)	mov r8=3Dr9
-	br.cond.sptk.few strace_save_retval
+	br.cond.sptk strace_save_retval
 END(ia64_trace_syscall)
=20
 GLOBAL_ENTRY(ia64_ret_from_clone)
@@ -489,7 +490,7 @@
 	 * Called by ia64_switch_to after do_fork()->copy_thread().  r8 contains =
the
 	 * address of the previously executing task.
 	 */
-	br.call.sptk.few rp=3Dinvoke_schedule_tail
+	br.call.sptk.many rp=3Dia64_invoke_schedule_tail
 .ret8:
 	adds r2=3DIA64_TASK_PTRACE_OFFSET,r13
 	;;
@@ -497,7 +498,7 @@
 	;;
 	mov r8=3D0
 	tbit.nz p6,p0=3Dr2,PT_TRACESYS_BIT
-(p6)	br strace_check_retval
+(p6)	br.cond.spnt strace_check_retval
 	;;					// added stop bits to prevent r8 dependency
 END(ia64_ret_from_clone)
 	// fall through
@@ -511,7 +512,7 @@
 (p6)	st8.spill [r2]=3Dr8	// store return value in slot for r8 and set unat=
 bit
 	.mem.offset 8,0
 (p6)	st8.spill [r3]=3Dr0	// clear error indication in slot for r10 and set=
 unat bit
-(p7)	br.cond.spnt.few handle_syscall_error	// handle potential syscall fai=
lure
+(p7)	br.cond.spnt handle_syscall_error	// handle potential syscall failure
 END(ia64_ret_from_syscall)
 	// fall through
 GLOBAL_ENTRY(ia64_leave_kernel)
@@ -524,17 +525,17 @@
 	adds r17=3DIA64_TASK_NEED_RESCHED_OFFSET,r13
 	adds r18=3DIA64_TASK_SIGPENDING_OFFSET,r13
 #ifdef CONFIG_PERFMON
-	adds r19=3DIA64_TASK_PFM_NOTIFY_OFFSET,r13
+	adds r19=3DIA64_TASK_PFM_MUST_BLOCK_OFFSET,r13
 #endif
 	;;
 #ifdef CONFIG_PERFMON
-(pUser)	ld8 r19=3D[r19]				// load current->task.pfm_notify
+(pUser)	ld8 r19=3D[r19]				// load current->thread.pfm_must_block
 #endif
 (pUser)	ld8 r17=3D[r17]				// load current->need_resched
 (pUser)	ld4 r18=3D[r18]				// load current->sigpending
 	;;
 #ifdef CONFIG_PERFMON
-(pUser)	cmp.ne.unc p9,p0=3Dr19,r0			// current->task.pfm_notify !=3D 0?
+(pUser)	cmp.ne.unc p9,p0=3Dr19,r0			// current->thread.pfm_must_block !=3D=
 0?
 #endif
 (pUser)	cmp.ne.unc p7,p0=3Dr17,r0			// current->need_resched !=3D 0?
 (pUser)	cmp.ne.unc p8,p0=3Dr18,r0			// current->sigpending !=3D 0?
@@ -542,7 +543,7 @@
 	adds r2=3DPT(R8)+16,r12
 	adds r3=3DPT(R9)+16,r12
 #ifdef CONFIG_PERFMON
-(p9)	br.call.spnt.many b7=3Dpfm_overflow_notify
+(p9)	br.call.spnt.many b7=3Dpfm_block_on_overflow
 #endif
 #if __GNUC__ < 3
 (p7)	br.call.spnt.many b7=3Dinvoke_schedule
@@ -642,13 +643,13 @@
 	movl r17=3DPERCPU_ADDR+IA64_CPU_PHYS_STACKED_SIZE_P8_OFFSET
 	;;
 	ld4 r17=3D[r17]		// r17 =3D cpu_data->phys_stacked_size_p8
-(pKern)	br.cond.dpnt.few skip_rbs_switch
+(pKern)	br.cond.dpnt skip_rbs_switch
 	/*
 	 * Restore user backing store.
 	 *
 	 * NOTE: alloc, loadrs, and cover can't be predicated.
 	 */
-(pNonSys) br.cond.dpnt.few dont_preserve_current_frame
+(pNonSys) br.cond.dpnt dont_preserve_current_frame
 	cover				// add current frame into dirty partition
 	;;
 	mov r19=3Dar.bsp			// get new backing store pointer
@@ -698,7 +699,7 @@
 }{ .mib
 	mov loc3=3D0
 	mov loc4=3D0
-(pRecurse) br.call.sptk.few b6=3Drse_clear_invalid
+(pRecurse) br.call.sptk.many b6=3Drse_clear_invalid
=20
 }{ .mfi	// cycle 2
 	mov loc5=3D0
@@ -707,7 +708,7 @@
 }{ .mib
 	mov loc6=3D0
 	mov loc7=3D0
-(pReturn) br.ret.sptk.few b6
+(pReturn) br.ret.sptk.many b6
 }
 #	undef pRecurse
 #	undef pReturn
@@ -753,24 +754,24 @@
 	;;
 .mem.offset 0,0; st8.spill [r2]=3Dr9	// store errno in pt_regs.r8 and set =
unat bit
 .mem.offset 8,0; st8.spill [r3]=3Dr10	// store error indication in pt_regs=
.r10 and set unat bit
-	br.cond.sptk.many ia64_leave_kernel
+	br.cond.sptk ia64_leave_kernel
 END(handle_syscall_error)
=20
 	/*
 	 * Invoke schedule_tail(task) while preserving in0-in7, which may be need=
ed
 	 * in case a system call gets restarted.
 	 */
-ENTRY(invoke_schedule_tail)
+GLOBAL_ENTRY(ia64_invoke_schedule_tail)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
 	alloc loc1=3Dar.pfs,8,2,1,0
 	mov loc0=3Drp
 	mov out0=3Dr8				// Address of previous task
 	;;
-	br.call.sptk.few rp=3Dschedule_tail
+	br.call.sptk.many rp=3Dschedule_tail
 .ret11:	mov ar.pfs=3Dloc1
 	mov rp=3Dloc0
 	br.ret.sptk.many rp
-END(invoke_schedule_tail)
+END(ia64_invoke_schedule_tail)
=20
 #if __GNUC__ < 3
=20
@@ -789,7 +790,7 @@
 	mov loc0=3Drp
 	;;
 	.body
-	br.call.sptk.few rp=3Dschedule
+	br.call.sptk.many rp=3Dschedule
 .ret14:	mov ar.pfs=3Dloc1
 	mov rp=3Dloc0
 	br.ret.sptk.many rp
@@ -816,7 +817,7 @@
 	.spillpsp ar.unat, 16			// (note that offset is relative to psp+0x10!)
 	st8 [sp]=3Dr9,-16				// allocate space for ar.unat and save it
 	.body
-	br.call.sptk.few rp=3Dia64_do_signal
+	br.call.sptk.many rp=3Dia64_do_signal
 .ret15:	.restore sp
 	adds sp=16,sp				// pop scratch stack space
 	;;
@@ -841,7 +842,7 @@
 	.spillpsp ar.unat, 16			// (note that offset is relative to psp+0x10!)
 	st8 [sp]=3Dr9,-16				// allocate space for ar.unat and save it
 	.body
-	br.call.sptk.few rp=3Dia64_rt_sigsuspend
+	br.call.sptk.many rp=3Dia64_rt_sigsuspend
 .ret17:	.restore sp
 	adds sp=16,sp				// pop scratch stack space
 	;;
@@ -863,7 +864,7 @@
 	cmp.eq pNonSys,pSys=3Dr0,r0		// sigreturn isn't a normal syscall...
 	;;
 	adds out0=16,sp				// out0 =3D &sigscratch
-	br.call.sptk.few rp=3Dia64_rt_sigreturn
+	br.call.sptk.many rp=3Dia64_rt_sigreturn
 .ret19:	.restore sp 0
 	adds sp=16,sp
 	;;
@@ -871,7 +872,7 @@
 	mov.sptk b7=3Dr8,ia64_leave_kernel
 	;;
 	mov ar.unat=3Dr9
-	br b7
+	br.many b7
 END(sys_rt_sigreturn)
=20
 GLOBAL_ENTRY(ia64_prepare_handle_unaligned)
@@ -882,7 +883,7 @@
 	mov r16=3Dr0
 	.prologue
 	DO_SAVE_SWITCH_STACK
-	br.call.sptk.few rp=3Dia64_handle_unaligned // stack frame setup in ivt
+	br.call.sptk.many rp=3Dia64_handle_unaligned // stack frame setup in ivt
 .ret21:	.body
 	DO_LOAD_SWITCH_STACK
 	br.cond.sptk.many rp			  // goes to ia64_leave_kernel
@@ -912,14 +913,14 @@
 	adds out0=16,sp				// &info
 	mov out1=3Dr13				// current
 	adds out2=16+EXTRA_FRAME_SIZE,sp	// &switch_stack
-	br.call.sptk.few rp=3Dunw_init_frame_info
+	br.call.sptk.many rp=3Dunw_init_frame_info
 1:	adds out0=16,sp				// &info
 	mov b6=3Dloc2
 	mov loc2=3Dgp				// save gp across indirect function call
 	;;
 	ld8 gp=3D[in0]
 	mov out1=3Din1				// arg
-	br.call.sptk.few rp=B6			// invoke the callback function
+	br.call.sptk.many rp=B6			// invoke the callback function
 1:	mov gp=3Dloc2				// restore gp
=20
 	// For now, we don't allow changing registers from within
diff -urN linux-davidm/arch/ia64/kernel/fw-emu.c linux-2.4.10-lia/arch/ia64=
/kernel/fw-emu.c
--- linux-davidm/arch/ia64/kernel/fw-emu.c	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/fw-emu.c	Mon Sep 24 21:46:40 2001
@@ -416,11 +416,6 @@
 	strcpy(sal_systab->product_id, "SDV");
 #endif
=20
-#ifdef CONFIG_IA64_SGI_SN1_SIM
-	strcpy(sal_systab->oem_id, "SGI");
-	strcpy(sal_systab->product_id, "SN1");
-#endif
-
 	/* fill in an entry point: */
 	sal_ed->type =3D SAL_DESC_ENTRY_POINT;
 	sal_ed->pal_proc =3D __pa(pal_desc[0]);
diff -urN linux-davidm/arch/ia64/kernel/gate.S linux-2.4.10-lia/arch/ia64/k=
ernel/gate.S
--- linux-davidm/arch/ia64/kernel/gate.S	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/gate.S	Mon Sep 24 21:46:49 2001
@@ -3,7 +3,7 @@
  * region.  For now, it contains the signal trampoline code only.
  *
  * Copyright (C) 1999-2001 Hewlett-Packard Co
- * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ * 	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #include <asm/asmmacro.h>
@@ -18,7 +18,6 @@
 #	define ARG0_OFF		(16 + IA64_SIGFRAME_ARG0_OFFSET)
 #	define ARG1_OFF		(16 + IA64_SIGFRAME_ARG1_OFFSET)
 #	define ARG2_OFF		(16 + IA64_SIGFRAME_ARG2_OFFSET)
-#	define RBS_BASE_OFF	(16 + IA64_SIGFRAME_RBS_BASE_OFFSET)
 #	define SIGHANDLER_OFF	(16 + IA64_SIGFRAME_HANDLER_OFFSET)
 #	define SIGCONTEXT_OFF	(16 + IA64_SIGFRAME_SIGCONTEXT_OFFSET)
=20
@@ -32,6 +31,8 @@
 #	define PR_OFF		IA64_SIGCONTEXT_PR_OFFSET
 #	define RP_OFF		IA64_SIGCONTEXT_B0_OFFSET
 #	define SP_OFF		IA64_SIGCONTEXT_R12_OFFSET
+#	define RBS_BASE_OFF	IA64_SIGCONTEXT_RBS_BASE_OFFSET
+#	define LOADRS_OFF	IA64_SIGCONTEXT_LOADRS_OFFSET
 #	define base0		r2
 #	define base1		r3
 	/*
@@ -73,34 +74,37 @@
 	.vframesp SP_OFF+SIGCONTEXT_OFF
 	.body
=20
-	.prologue
+	.label_state 1
+
 	adds base0=3DSIGHANDLER_OFF,sp
-	adds base1=3DRBS_BASE_OFF,sp
+	adds base1=3DRBS_BASE_OFF+SIGCONTEXT_OFF,sp
 	br.call.sptk.many rp=1F
 1:
 	ld8 r17=3D[base0],(ARG0_OFF-SIGHANDLER_OFF)	// get pointer to signal hand=
ler's plabel
-	ld8 r15=3D[base1],(ARG1_OFF-RBS_BASE_OFF)		// get address of new RBS base=
 (or NULL)
+	ld8 r15=3D[base1]					// get address of new RBS base (or NULL)
 	cover				// push args in interrupted frame onto backing store
 	;;
+	cmp.ne p8,p0=3Dr15,r0		// do we need to switch the rbs?
+	mov.m r9=3Dar.bsp			// fetch ar.bsp
+	.spillsp.p p8, ar.rnat, RNAT_OFF+SIGCONTEXT_OFF
+(p8)	br.cond.spnt setup_rbs		// yup -> (clobbers r14, r15, and r16)
+back_from_setup_rbs:
+
 	.save ar.pfs, r8
 	alloc r8=3Dar.pfs,0,0,3,0		// get CFM0, EC0, and CPL0 into r8
 	ld8 out0=3D[base0],16		// load arg0 (signum)
+	adds base1=3D(ARG1_OFF-(RBS_BASE_OFF+SIGCONTEXT_OFF)),base1
 	;;
 	ld8 out1=3D[base1]		// load arg1 (siginfop)
 	ld8 r10=3D[r17],8			// get signal handler entry point
 	;;
 	ld8 out2=3D[base0]		// load arg2 (sigcontextp)
 	ld8 gp=3D[r17]			// get signal handler's global pointer
-	cmp.ne p8,p0=3Dr15,r0		// do we need to switch the rbs?
=20
-	mov.m r17=3Dar.bsp		// fetch ar.bsp
-	.spillsp.p p8, ar.rnat, RNAT_OFF+SIGCONTEXT_OFF
-(p8)	br.cond.spnt.few setup_rbs	// yup -> (clobbers r14 and r16)
-back_from_setup_rbs:
 	adds base0=3D(BSP_OFF+SIGCONTEXT_OFF),sp
 	;;
 	.spillsp ar.bsp, BSP_OFF+SIGCONTEXT_OFF
-	st8 [base0]=3Dr17,(CFM_OFF-BSP_OFF)	// save sc_ar_bsp
+	st8 [base0]=3Dr9,(CFM_OFF-BSP_OFF)	// save sc_ar_bsp
 	dep r8=3D0,r8,38,26			// clear EC0, CPL0 and reserved bits
 	adds base1=3D(FR6_OFF+16+SIGCONTEXT_OFF),sp
 	;;
@@ -123,7 +127,7 @@
 	;;
 	stf.spill [base0]=F14,32
 	stf.spill [base1]=F15,32
-	br.call.sptk.few rp=B6			// call the signal handler
+	br.call.sptk.many rp=B6			// call the signal handler
 .ret0:	adds base0=3D(BSP_OFF+SIGCONTEXT_OFF),sp
 	;;
 	ld8 r15=3D[base0],(CFM_OFF-BSP_OFF)	// fetch sc_ar_bsp and advance to CFM=
_OFF
@@ -131,7 +135,7 @@
 	;;
 	ld8 r8=3D[base0]				// restore (perhaps modified) CFM0, EC0, and CPL0
 	cmp.ne p8,p0=3Dr14,r15			// do we need to restore the rbs?
-(p8)	br.cond.spnt.few restore_rbs		// yup -> (clobbers r14 and r16)
+(p8)	br.cond.spnt restore_rbs		// yup -> (clobbers r14 and r16)
 	;;
 back_from_restore_rbs:
 	adds base0=3D(FR6_OFF+SIGCONTEXT_OFF),sp
@@ -154,30 +158,52 @@
 	mov r15=3D__NR_rt_sigreturn
 	break __BREAK_SYSCALL
=20
+	.body
+	.copy_state 1
 setup_rbs:
-	flushrs					// must be first in insn
 	mov ar.rsc=3D0				// put RSE into enforced lazy mode
-	adds r16=3D(RNAT_OFF+SIGCONTEXT_OFF),sp
 	;;
-	mov r14=3Dar.rnat				// get rnat as updated by flushrs
-	mov ar.bspstore=3Dr15			// set new register backing store area
+	.save ar.rnat, r16
+	mov r16=3Dar.rnat				// save RNaT before switching backing store area
+	adds r14=3D(RNAT_OFF+SIGCONTEXT_OFF),sp
+
+	mov ar.bspstore=3Dr15			// switch over to new register backing store area
 	;;
 	.spillsp ar.rnat, RNAT_OFF+SIGCONTEXT_OFF
-	st8 [r16]=3Dr14				// save sc_ar_rnat
+	st8 [r14]=3Dr16				// save sc_ar_rnat
+	adds r14=3D(LOADRS_OFF+SIGCONTEXT_OFF),sp
+
+	mov.m r16=3Dar.bsp			// sc_loadrs <- (new bsp - new bspstore) << 16
+	;;
+	invala
+	sub r15=3Dr16,r15
+	;;
+	shl r15=3Dr15,16
+	;;
+	st8 [r14]=3Dr15				// save sc_loadrs
 	mov ar.rsc=3D0xf				// set RSE into eager mode, pl 3
-	invala					// invalidate ALAT
-	br.cond.sptk.many back_from_setup_rbs
+	br.cond.sptk back_from_setup_rbs
=20
+	.prologue
+	.copy_state 1
+	.spillsp ar.rnat, RNAT_OFF+SIGCONTEXT_OFF
+	.body
 restore_rbs:
-	flushrs
-	mov ar.rsc=3D0				// put RSE into enforced lazy mode
+	alloc r2=3Dar.pfs,0,0,0,0			// alloc null frame
+	adds r16=3D(LOADRS_OFF+SIGCONTEXT_OFF),sp
+	;;
+	ld8 r14=3D[r16]
 	adds r16=3D(RNAT_OFF+SIGCONTEXT_OFF),sp
 	;;
+	mov ar.rsc=3Dr14				// put RSE into enforced lazy mode
 	ld8 r14=3D[r16]				// get new rnat
-	mov ar.bspstore=3Dr15			// set old register backing store area
 	;;
-	mov ar.rnat=3Dr14				// establish new rnat
+	loadrs					// restore dirty partition
+	;;
+	mov ar.bspstore=3Dr15			// switch back to old register backing store area
+	;;
+	mov ar.rnat=3Dr14				// restore RNaT
 	mov ar.rsc=3D0xf				// (will be restored later on from sc_ar_rsc)
 	// invala not necessary as that will happen when returning to user-mode
-	br.cond.sptk.many back_from_restore_rbs
+	br.cond.sptk back_from_restore_rbs
 END(ia64_sigtramp)
diff -urN linux-davidm/arch/ia64/kernel/head.S linux-2.4.10-lia/arch/ia64/k=
ernel/head.S
--- linux-davidm/arch/ia64/kernel/head.S	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/head.S	Mon Sep 24 21:47:23 2001
@@ -6,8 +6,8 @@
  * entry point.
  *
  * Copyright (C) 1998-2001 Hewlett-Packard Co
- * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 2001 Stephane Eranian <eranian@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+ *	Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
  * Copyright (C) 1999 Intel Corp.
@@ -86,7 +86,8 @@
 	/*
 	 * Switch into virtual mode:
 	 */
-	movl r16=3D(IA64_PSR_IT|IA64_PSR_IC|IA64_PSR_DT|IA64_PSR_RT|IA64_PSR_DFH|=
IA64_PSR_BN)
+	movl r16=3D(IA64_PSR_IT|IA64_PSR_IC|IA64_PSR_DT|IA64_PSR_RT|IA64_PSR_DFH|=
IA64_PSR_BN \
+		  |IA64_PSR_DI)
 	;;
 	mov cr.ipsr=3Dr16
 	movl r17=1F
@@ -183,31 +184,31 @@
 	alloc r2=3Dar.pfs,0,0,2,0
 	movl out0=3Dalive_msg
 	;;
-	br.call.sptk.few rp=EArly_printk
+	br.call.sptk.many rp=EArly_printk
 1:	// force new bundle
 #endif /* CONFIG_IA64_EARLY_PRINTK */
=20
 #ifdef CONFIG_SMP
-(isAP)	br.call.sptk.few rp=3Dstart_secondary
+(isAP)	br.call.sptk.many rp=3Dstart_secondary
 .ret0:
-(isAP)	br.cond.sptk.few self
+(isAP)	br.cond.sptk self
 #endif
=20
 	// This is executed by the bootstrap processor (bsp) only:
=20
 #ifdef CONFIG_IA64_FW_EMU
 	// initialize PAL & SAL emulator:
-	br.call.sptk.few rp=3Dsys_fw_init
+	br.call.sptk.many rp=3Dsys_fw_init
 .ret1:
 #endif
-	br.call.sptk.few rp=3Dstart_kernel
+	br.call.sptk.many rp=3Dstart_kernel
 .ret2:	addl r3=3D@ltoff(halt_msg),gp
 	;;
 	alloc r2=3Dar.pfs,8,0,2,0
 	;;
 	ld8 out0=3D[r3]
-	br.call.sptk.few b0=3Dconsole_print
-self:	br.sptk.few self		// endless loop
+	br.call.sptk.many b0=3Dconsole_print
+self:	br.sptk.many self		// endless loop
 END(_start)
=20
 GLOBAL_ENTRY(ia64_save_debug_regs)
@@ -227,10 +228,10 @@
 	;;
 	st8.nta [in0]=3Dr16,8
 	st8.nta [r19]=3Dr17,8
-	br.cloop.sptk.few 1b
+	br.cloop.sptk.many 1b
 	;;
 	mov ar.lc=3Dr20			// restore ar.lc
-	br.ret.sptk.few rp
+	br.ret.sptk.many rp
 END(ia64_save_debug_regs)
=20
 GLOBAL_ENTRY(ia64_load_debug_regs)
@@ -251,10 +252,10 @@
 	srlz.d				// Errata 132 (NoFix status)
 #endif
 	mov ibr[r18]=3Dr17
-	br.cloop.sptk.few 1b
+	br.cloop.sptk.many 1b
 	;;
 	mov ar.lc=3Dr20			// restore ar.lc
-	br.ret.sptk.few rp
+	br.ret.sptk.many rp
 END(ia64_load_debug_regs)
=20
 GLOBAL_ENTRY(__ia64_save_fpu)
@@ -404,7 +405,7 @@
 	;;
 	stf.spill.nta [in0]=F126,32
 	stf.spill.nta [ r3]=F127,32
-	br.ret.sptk.few rp
+	br.ret.sptk.many rp
 END(__ia64_save_fpu)
=20
 GLOBAL_ENTRY(__ia64_load_fpu)
@@ -554,7 +555,7 @@
 	;;
 	ldf.fill.nta f126=3D[in0],32
 	ldf.fill.nta f127=3D[ r3],32
-	br.ret.sptk.few rp
+	br.ret.sptk.many rp
 END(__ia64_load_fpu)
=20
 GLOBAL_ENTRY(__ia64_init_fpu)
@@ -688,7 +689,7 @@
 	;;
 	ldf.fill f126=3D[sp]
 	mov      f127=F0
-	br.ret.sptk.few rp
+	br.ret.sptk.many rp
 END(__ia64_init_fpu)
=20
 /*
@@ -736,7 +737,7 @@
 	rfi				// must be last insn in group
 	;;
 1:	mov rp=3Dr14
-	br.ret.sptk.few rp
+	br.ret.sptk.many rp
 END(ia64_switch_mode)
=20
 #ifdef CONFIG_IA64_BRL_EMU
@@ -750,7 +751,7 @@
 	alloc r16=3Dar.pfs,1,0,0,0;		\
 	mov reg=3Dr32;				\
 	;;					\
-	br.ret.sptk rp;				\
+	br.ret.sptk.many rp;			\
  END(ia64_set_##reg)
=20
 SET_REG(b1);
@@ -814,7 +815,7 @@
 	;;
 	cmp.ne p15,p0=3Dtmp,r0
 	mov tmp=3Dar.itc
-(p15)	br.cond.sptk.few .retry	// lock is still busy
+(p15)	br.cond.sptk .retry	// lock is still busy
 	;;
 	// try acquiring lock (we know ar.ccv is still zero!):
 	mov tmp=3D1
diff -urN linux-davidm/arch/ia64/kernel/ia64_ksyms.c linux-2.4.10-lia/arch/=
ia64/kernel/ia64_ksyms.c
--- linux-davidm/arch/ia64/kernel/ia64_ksyms.c	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/ia64_ksyms.c	Mon Sep 24 21:47:44 2001
@@ -145,4 +145,3 @@
 #include <linux/proc_fs.h>
 extern struct proc_dir_entry *efi_dir;
 EXPORT_SYMBOL(efi_dir);
-
diff -urN linux-davidm/arch/ia64/kernel/iosapic.c linux-2.4.10-lia/arch/ia6=
4/kernel/iosapic.c
--- linux-davidm/arch/ia64/kernel/iosapic.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/iosapic.c	Mon Sep 24 21:47:52 2001
@@ -343,6 +343,54 @@
 }
=20
 /*
+ * ACPI can describe IOSAPIC interrupts via static tables and namespace
+ * methods.  This provides an interface to register those interrupts and
+ * program the IOSAPIC RTE.
+ */
+int
+iosapic_register_irq (u32 global_vector, unsigned long polarity, unsigned =
long
+                      edge_triggered, u32 base_irq, char *iosapic_address)
+{
+	irq_desc_t *idesc;
+	struct hw_interrupt_type *irq_type;
+	int vector;
+
+	vector =3D iosapic_irq_to_vector(global_vector);
+	if (vector < 0)
+		vector =3D ia64_alloc_irq();
+
+	/* fill in information from this vector's IOSAPIC */
+	iosapic_irq[vector].addr =3D iosapic_address;
+	iosapic_irq[vector].base_irq =3D base_irq;
+	iosapic_irq[vector].pin	=3D global_vector - iosapic_irq[vector].base_irq;
+	iosapic_irq[vector].polarity =3D polarity ? IOSAPIC_POL_HIGH : IOSAPIC_PO=
L_LOW;
+	iosapic_irq[vector].dmode    =3D IOSAPIC_LOWEST_PRIORITY;
+
+	if (edge_triggered) {
+		iosapic_irq[vector].trigger =3D IOSAPIC_EDGE;
+		irq_type =3D &irq_type_iosapic_edge;
+	} else {
+		iosapic_irq[vector].trigger =3D IOSAPIC_LEVEL;
+		irq_type =3D &irq_type_iosapic_level;
+	}
+
+	idesc =3D irq_desc(vector);
+	if (idesc->handler !=3D irq_type) {
+		if (idesc->handler !=3D &no_irq_type)
+			printk("iosapic_register_irq(): changing vector 0x%02x from"
+			       "%s to %s\n", vector, idesc->handler->typename, irq_type->typena=
me);
+		idesc->handler =3D irq_type;
+	}
+
+	printk("IOSAPIC %x(%s,%s) -> Vector %x\n", global_vector,
+	       (polarity ? "high" : "low"), (edge_triggered ? "edge" : "level"), =
vector);
+
+	/* program the IOSAPIC routing table */
+	set_rte(vector, (ia64_get_lid() >> 16) & 0xffff);
+	return vector;
+}
+
+/*
  * ACPI calls this when it finds an entry for a platform interrupt.
  * Note that the irq_base and IOSAPIC address must be set in iosapic_init(=
).
  */
@@ -392,7 +440,7 @@
 	}
=20
 	printk("PLATFORM int %x: IOSAPIC %x(%s,%s) -> Vector %x CPU %.02u:%.02u\n=
",
-	       int_type, global_vector, (polarity ? "hign" : "low"),
+	       int_type, global_vector, (polarity ? "high" : "low"),
 	       (edge_triggered ? "edge" : "level"), vector, eid, id);
=20
 	/* program the IOSAPIC routing table */
@@ -496,7 +544,7 @@
 			/* the interrupt route is for another controller... */
 			continue;
=20
-		if (irq < 16)
+		if (pcat_compat && (irq < 16))
 			vector =3D isa_irq_to_vector(irq);
 		else {
 			vector =3D iosapic_irq_to_vector(irq);
@@ -575,6 +623,23 @@
 				printk("PCI->APIC IRQ transform: (B%d,I%d,P%d) -> 0x%02x\n",
 				       dev->bus->number, PCI_SLOT(dev->devfn), pin, vector);
 				dev->irq =3D vector;
+
+#ifdef CONFIG_SMP
+				/*
+				 * For platforms that do not support interrupt redirect
+				 * via the XTP interface, we can round-robin the PCI
+				 * device interrupts to the processors
+				 */
+				if (!(smp_int_redirect & SMP_IRQ_REDIRECTION)) {
+					static int cpu_index =3D 0;
+
+					set_rte(vector, cpu_physical_id(cpu_index) & 0xffff);
+
+					cpu_index++;
+					if (cpu_index >=3D smp_num_cpus)
+						cpu_index =3D 0;
+				}
+#endif
 			}
 		}
 		/*
diff -urN linux-davidm/arch/ia64/kernel/irq.c linux-2.4.10-lia/arch/ia64/ke=
rnel/irq.c
--- linux-davidm/arch/ia64/kernel/irq.c	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/irq.c	Mon Sep 24 21:48:11 2001
@@ -33,6 +33,7 @@
 #include <linux/irq.h>
 #include <linux/proc_fs.h>
=20
+#include <asm/atomic.h>
 #include <asm/io.h>
 #include <asm/smp.h>
 #include <asm/system.h>
@@ -121,7 +122,10 @@
 	end_none
 };
=20
-volatile unsigned long irq_err_count;
+atomic_t irq_err_count;
+#if defined(CONFIG_X86) && defined(CONFIG_X86_IO_APIC) && defined(APIC_MIS=
MATCH_DEBUG)
+atomic_t irq_mis_count;
+#endif
=20
 /*
  * Generic, controller-independent functions:
@@ -164,14 +168,17 @@
 		p +=3D sprintf(p, "%10u ",
 			nmi_count(cpu_logical_map(j)));
 	p +=3D sprintf(p, "\n");
-#if defined(CONFIG_SMP) && defined(__i386__)
+#if defined(CONFIG_SMP) && defined(CONFIG_X86)
 	p +=3D sprintf(p, "LOC: ");
 	for (j =3D 0; j < smp_num_cpus; j++)
 		p +=3D sprintf(p, "%10u ",
 			apic_timer_irqs[cpu_logical_map(j)]);
 	p +=3D sprintf(p, "\n");
 #endif
-	p +=3D sprintf(p, "ERR: %10lu\n", irq_err_count);
+	p +=3D sprintf(p, "ERR: %10u\n", atomic_read(&irq_err_count));
+#if defined(CONFIG_X86) && defined(CONFIG_X86_IO_APIC) && defined(APIC_MIS=
MATCH_DEBUG)
+	p +=3D sprintf(p, "MIS: %10u\n", atomic_read(&irq_mis_count));
+#endif
 	return p - buf;
 }
=20
@@ -183,7 +190,7 @@
=20
 #ifdef CONFIG_SMP
 unsigned int global_irq_holder =3D NO_PROC_ID;
-volatile unsigned long global_irq_lock; /* long for set_bit --RR */
+unsigned volatile long global_irq_lock; /* pedantic: long for set_bit --RR=
 */
=20
 extern void show_stack(unsigned long* esp);
=20
@@ -201,14 +208,14 @@
 		printk(" %d",bh_count(i));
=20
 	printk(" ]\nStack dumps:");
-#if defined(__ia64__)
+#if defined(CONFIG_IA64)
 	/*
 	 * We can't unwind the stack of another CPU without access to
 	 * the registers of that CPU.  And sending an IPI when we're
 	 * in a potentially wedged state doesn't sound like a smart
 	 * idea.
 	 */
-#elif defined(__i386__)
+#elif defined(CONFIG_X86)
 	for(i=3D0;i< smp_num_cpus;i++) {
 		unsigned long esp;
 		if(i=3Dcpu)
@@ -261,7 +268,7 @@
 /*
  * We have to allow irqs to arrive between __sti and __cli
  */
-# ifdef __ia64__
+# ifdef CONFIG_IA64
 #  define SYNC_OTHER_CORES(x) __asm__ __volatile__ ("nop 0")
 # else
 #  define SYNC_OTHER_CORES(x) __asm__ __volatile__ ("nop")
@@ -331,6 +338,9 @@
 		/* Uhhuh.. Somebody else got it. Wait.. */
 		do {
 			do {
+#ifdef CONFIG_X86
+				rep_nop();
+#endif
 			} while (test_bit(0,&global_irq_lock));
 		} while (test_and_set_bit(0,&global_irq_lock));
 	}
@@ -364,7 +374,7 @@
 {
 	unsigned int flags;
=20
-#ifdef __ia64__
+#ifdef CONFIG_IA64
 	__save_flags(flags);
 	if (flags & IA64_PSR_I) {
 		__cli();
@@ -403,7 +413,7 @@
 	int cpu =3D smp_processor_id();
=20
 	__save_flags(flags);
-#ifdef __ia64__
+#ifdef CONFIG_IA64
 	local_enabled =3D (flags & IA64_PSR_I) !=3D 0;
 #else
 	local_enabled =3D (flags >> EFLAGS_IF_SHIFT) & 1;
@@ -476,13 +486,19 @@
 	return status;
 }
=20
-/*
- * Generic enable/disable code: this just calls
- * down into the PIC-specific version for the actual
- * hardware disable after having gotten the irq
- * controller lock.
+/**
+ *	disable_irq_nosync - disable an irq without waiting
+ *	@irq: Interrupt to disable
+ *
+ *	Disable the selected interrupt line.  Disables and Enables are
+ *	nested.
+ *	Unlike disable_irq(), this function does not ensure existing
+ *	instances of the IRQ handler have completed before returning.
+ *
+ *	This function may be called from IRQ context.
  */
-void inline disable_irq_nosync(unsigned int irq)
+
+inline void disable_irq_nosync(unsigned int irq)
 {
 	irq_desc_t *desc =3D irq_desc(irq);
 	unsigned long flags;
@@ -495,10 +511,19 @@
 	spin_unlock_irqrestore(&desc->lock, flags);
 }
=20
-/*
- * Synchronous version of the above, making sure the IRQ is
- * no longer running on any other IRQ..
+/**
+ *	disable_irq - disable an irq and wait for completion
+ *	@irq: Interrupt to disable
+ *
+ *	Disable the selected interrupt line.  Enables and Disables are
+ *	nested.
+ *	This function waits for any pending IRQ handlers for this interrupt
+ *	to complete before returning. If you use this function while
+ *	holding a resource the IRQ handler may need you will deadlock.
+ *
+ *	This function may be called - with care - from IRQ context.
  */
+
 void disable_irq(unsigned int irq)
 {
 	disable_irq_nosync(irq);
@@ -512,6 +537,17 @@
 #endif
 }
=20
+/**
+ *	enable_irq - enable handling of an irq
+ *	@irq: Interrupt to enable
+ *
+ *	Undoes the effect of one call to disable_irq().  If this
+ *	matches the last disable, processing of interrupts on this
+ *	IRQ line is re-enabled.
+ *
+ *	This function may be called from IRQ context.
+ */
+
 void enable_irq(unsigned int irq)
 {
 	irq_desc_t *desc =3D irq_desc(irq);
@@ -533,7 +569,8 @@
 		desc->depth--;
 		break;
 	case 0:
-		printk("enable_irq() unbalanced from %p\n", (void *) __builtin_return_ad=
dress(0));
+		printk("enable_irq(%u) unbalanced from %p\n",
+		       irq, (void *) __builtin_return_address(0));
 	}
 	spin_unlock_irqrestore(&desc->lock, flags);
 }
@@ -626,11 +663,41 @@
 		desc->handler->end(irq);
 		spin_unlock(&desc->lock);
 	}
-	if (local_softirq_pending())
-		do_softirq();
 	return 1;
 }
=20
+/**
+ *	request_irq - allocate an interrupt line
+ *	@irq: Interrupt line to allocate
+ *	@handler: Function to be called when the IRQ occurs
+ *	@irqflags: Interrupt type flags
+ *	@devname: An ascii name for the claiming device
+ *	@dev_id: A cookie passed back to the handler function
+ *
+ *	This call allocates interrupt resources and enables the
+ *	interrupt line and IRQ handling. From the point this
+ *	call is made your handler function may be invoked. Since
+ *	your handler function must clear any interrupt the board=20
+ *	raises, you must take care both to initialise your hardware
+ *	and to set up the interrupt handler in the right order.
+ *
+ *	Dev_id must be globally unique. Normally the address of the
+ *	device data structure is used as the cookie. Since the handler
+ *	receives this value it makes sense to use it.
+ *
+ *	If your interrupt is shared you must pass a non NULL dev_id
+ *	as this is required when freeing the interrupt.
+ *
+ *	Flags:
+ *
+ *	SA_SHIRQ		Interrupt is shared
+ *
+ *	SA_INTERRUPT		Disable local interrupts while processing
+ *
+ *	SA_SAMPLE_RANDOM	The interrupt can be used for entropy
+ *
+ */
+
 int request_irq(unsigned int irq,
 		void (*handler)(int, void *, struct pt_regs *),
 		unsigned long irqflags,
@@ -676,6 +743,24 @@
 	return retval;
 }
=20
+/**
+ *	free_irq - free an interrupt
+ *	@irq: Interrupt line to free
+ *	@dev_id: Device identity to free
+ *
+ *	Remove an interrupt handler. The handler is removed and if the
+ *	interrupt line is no longer in use by any driver it is disabled.
+ *	On a shared IRQ the caller must ensure the interrupt is disabled
+ *	on the card it drives before calling this function. The function
+ *	does not return until any executing interrupts for this IRQ
+ *	have completed.
+ *
+ *	This function may be called from interrupt context.=20
+ *
+ *	Bugs: Attempting to free an irq in a handler for the same irq hangs
+ *	      the machine.
+ */
+
 void free_irq(unsigned int irq, void *dev_id)
 {
 	irq_desc_t *desc;
@@ -726,6 +811,17 @@
  * with "IRQ_WAITING" cleared and the interrupt
  * disabled.
  */
+
+static DECLARE_MUTEX(probe_sem);
+
+/**
+ *	probe_irq_on	- begin an interrupt autodetect
+ *
+ *	Commence probing for an interrupt. The interrupts are scanned
+ *	and a mask of potential interrupt lines is returned.
+ *
+ */
+
 unsigned long probe_irq_on(void)
 {
 	unsigned int i;
@@ -733,6 +829,7 @@
 	unsigned long val;
 	unsigned long delay;
=20
+	down(&probe_sem);
 	/*
 	 * something may have generated an irq long ago and we want to
 	 * flush such a longstanding irq before considering it as spurious.
@@ -799,10 +896,19 @@
 	return val;
 }
=20
-/*
- * Return a mask of triggered interrupts (this
- * can handle only legacy ISA interrupts).
+/**
+ *	probe_irq_mask - scan a bitmap of interrupt lines
+ *	@val:	mask of interrupts to consider
+ *
+ *	Scan the ISA bus interrupt lines and return a bitmap of
+ *	active interrupts. The interrupt probe logic state is then
+ *	returned to its previous value.
+ *
+ *	Note: we need to scan all the irq's even though we will
+ *	only return ISA irq numbers - just so that we reset them
+ *	all to a known state.
  */
+
 unsigned int probe_irq_mask(unsigned long val)
 {
 	int i;
@@ -825,14 +931,29 @@
 		}
 		spin_unlock_irq(&desc->lock);
 	}
+	up(&probe_sem);
=20
 	return mask & val;
 }
=20
-/*
- * Return the one interrupt that triggered (this can
- * handle any interrupt source)
+/**
+ *	probe_irq_off	- end an interrupt autodetect
+ *	@val: mask of potential interrupts (unused)
+ *
+ *	Scans the unused interrupt lines and returns the line which
+ *	appears to have triggered the interrupt. If no interrupt was
+ *	found then zero is returned. If more than one interrupt is
+ *	found then minus the first candidate is returned to indicate
+ *	their is doubt.
+ *
+ *	The interrupt probe logic state is returned to its previous
+ *	value.
+ *
+ *	BUGS: When used in a module (which arguably shouldnt happen)
+ *	nothing prevents two IRQ probe callers from overlapping. The
+ *	results of this are non-optimal.
  */
+
 int probe_irq_off(unsigned long val)
 {
 	int i, irq_found, nr_irqs;
@@ -857,6 +978,7 @@
 		}
 		spin_unlock_irq(&desc->lock);
 	}
+	up(&probe_sem);
=20
 	if (nr_irqs > 1)
 		irq_found =3D -irq_found;
@@ -911,7 +1033,7 @@
=20
 	if (!shared) {
 		desc->depth =3D 0;
-		desc->status &=3D ~IRQ_DISABLED;
+		desc->status &=3D ~(IRQ_DISABLED | IRQ_AUTODETECT | IRQ_WAITING);
 		desc->handler->startup(irq);
 	}
 	spin_unlock_irqrestore(&desc->lock,flags);
@@ -922,20 +1044,9 @@
=20
 static struct proc_dir_entry * root_irq_dir;
 static struct proc_dir_entry * irq_dir [NR_IRQS];
-static struct proc_dir_entry * smp_affinity_entry [NR_IRQS];
-
-static unsigned long irq_affinity [NR_IRQS] =3D { [0 ... NR_IRQS-1] =3D ~0=
UL };
=20
 #define HEX_DIGITS 8
=20
-static int irq_affinity_read_proc (char *page, char **start, off_t off,
-			int count, int *eof, void *data)
-{
-	if (count < HEX_DIGITS+1)
-		return -EINVAL;
-	return sprintf (page, "%08lx\n", irq_affinity[(long)data]);
-}
-
 static unsigned int parse_hex_value (const char *buffer,
 		unsigned long count, unsigned long *ret)
 {
@@ -973,6 +1084,20 @@
 	return 0;
 }
=20
+#if CONFIG_SMP
+
+static struct proc_dir_entry * smp_affinity_entry [NR_IRQS];
+
+static unsigned long irq_affinity [NR_IRQS] =3D { [0 ... NR_IRQS-1] =3D ~0=
UL };
+
+static int irq_affinity_read_proc (char *page, char **start, off_t off,
+			int count, int *eof, void *data)
+{
+	if (count < HEX_DIGITS+1)
+		return -EINVAL;
+	return sprintf (page, "%08lx\n", irq_affinity[(long)data]);
+}
+
 static int irq_affinity_write_proc (struct file *file, const char *buffer,
 					unsigned long count, void *data)
 {
@@ -984,7 +1109,6 @@
=20
 	err =3D parse_hex_value(buffer, count, &new_value);
=20
-#if CONFIG_SMP
 	/*
 	 * Do not allow disabling IRQs completely - it's a too easy
 	 * way to make the system unusable accidentally :-) At least
@@ -992,7 +1116,6 @@
 	 */
 	if (!(new_value & cpu_online_map))
 		return -EINVAL;
-#endif
=20
 	irq_affinity[irq] =3D new_value;
 	irq_desc(irq)->handler->set_affinity(irq, new_value);
@@ -1000,6 +1123,8 @@
 	return full_count;
 }
=20
+#endif /* CONFIG_SMP */
+
 static int prof_cpu_mask_read_proc (char *page, char **start, off_t off,
 			int count, int *eof, void *data)
 {
@@ -1027,7 +1152,6 @@
=20
 static void register_irq_proc (unsigned int irq)
 {
-	struct proc_dir_entry *entry;
 	char name [MAX_NAMELEN];
=20
 	if (!root_irq_dir || (irq_desc(irq)->handler =3D &no_irq_type))
@@ -1039,15 +1163,22 @@
 	/* create /proc/irq/1234 */
 	irq_dir[irq] =3D proc_mkdir(name, root_irq_dir);
=20
-	/* create /proc/irq/1234/smp_affinity */
-	entry =3D create_proc_entry("smp_affinity", 0600, irq_dir[irq]);
-
-	entry->nlink =3D 1;
-	entry->data =3D (void *)(long)irq;
-	entry->read_proc =3D irq_affinity_read_proc;
-	entry->write_proc =3D irq_affinity_write_proc;
+#if CONFIG_SMP
+	{
+		struct proc_dir_entry *entry;
+		/* create /proc/irq/1234/smp_affinity */
+		entry =3D create_proc_entry("smp_affinity", 0600, irq_dir[irq]);
+
+		if (entry) {
+			entry->nlink =3D 1;
+			entry->data =3D (void *)(long)irq;
+			entry->read_proc =3D irq_affinity_read_proc;
+			entry->write_proc =3D irq_affinity_write_proc;
+		}
=20
-	smp_affinity_entry[irq] =3D entry;
+		smp_affinity_entry[irq] =3D entry;
+	}
+#endif
 }
=20
 unsigned long prof_cpu_mask =3D -1;
@@ -1062,6 +1193,9 @@
=20
 	/* create /proc/irq/prof_cpu_mask */
 	entry =3D create_proc_entry("prof_cpu_mask", 0600, root_irq_dir);
+
+	if (!entry)
+		return;
=20
 	entry->nlink =3D 1;
 	entry->data =3D (void *)&prof_cpu_mask;
diff -urN linux-davidm/arch/ia64/kernel/irq_ia64.c linux-2.4.10-lia/arch/ia=
64/kernel/irq_ia64.c
--- linux-davidm/arch/ia64/kernel/irq_ia64.c	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/irq_ia64.c	Mon Sep 24 21:48:36 2001
@@ -1,9 +1,9 @@
 /*
  * linux/arch/ia64/kernel/irq.c
  *
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 Stephane Eranian <eranian@hpl.hp.com>
- * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ *	Stephane Eranian <eranian@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  *  6/10/99: Updated to bring in sync with x86 version to facilitate
  *	     support for SMP and different interrupt controllers.
@@ -131,6 +131,13 @@
 		ia64_eoi();
 		vector =3D ia64_get_ivr();
 	}
+	/*
+	 * This must be done *after* the ia64_eoi().  For example, the keyboard s=
oftirq
+	 * handler needs to be able to wait for further keyboard interrupts, whic=
h can't
+	 * come through until ia64_eoi() has been done.
+	 */
+	if (local_softirq_pending())
+		do_softirq();
 }
=20
 #ifdef CONFIG_SMP
diff -urN linux-davidm/arch/ia64/kernel/ivt.S linux-2.4.10-lia/arch/ia64/ke=
rnel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/ivt.S	Mon Sep 24 21:48:47 2001
@@ -2,8 +2,8 @@
  * arch/ia64/kernel/ivt.S
  *
  * Copyright (C) 1998-2001 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 Stephane Eranian <eranian@hpl.hp.com>
- * Copyright (C) 1998-2001 David Mosberger <davidm@hpl.hp.com>
+ *	Stephane Eranian <eranian@hpl.hp.com>
+ *	David Mosberger <davidm@hpl.hp.com>
  *
  * 00/08/23 Asit Mallick <asit.k.mallick@intel.com> TLB handling for SMP
  * 00/12/20 David Mosberger-Tang <davidm@hpl.hp.com> DTLB/ITLB handler now=
 uses virtual PT.
@@ -157,7 +157,7 @@
 	;;
 (p10)	itc.i r18				// insert the instruction TLB entry
 (p11)	itc.d r18				// insert the data TLB entry
-(p6)	br.spnt.many page_fault			// handle bad address/page not present (pag=
e fault)
+(p6)	br.cond.spnt.many page_fault		// handle bad address/page not present =
(page fault)
 	mov cr.ifa=3Dr22
=20
 	/*
@@ -213,7 +213,7 @@
 	;;
 	mov b0=3Dr29
 	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?
-(p6)	br.cond.spnt.many page_fault
+(p6)	br.cond.spnt page_fault
 	;;
 	itc.i r18
 	;;
@@ -251,7 +251,7 @@
 	;;
 	mov b0=3Dr29
 	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?
-(p6)	br.cond.spnt.many page_fault
+(p6)	br.cond.spnt page_fault
 	;;
 	itc.d r18
 	;;
@@ -286,7 +286,7 @@
 	;;
 (p8)	mov cr.iha=3Dr17
 (p8)	mov r29=B0				// save b0
-(p8)	br.cond.dptk.many itlb_fault
+(p8)	br.cond.dptk itlb_fault
 #endif
 	extr.u r23=3Dr21,IA64_PSR_CPL0_BIT,2	// extract psr.cpl
 	shr.u r18=3Dr16,57	// move address bit 61 to bit 4
@@ -297,7 +297,7 @@
 	dep r19=3Dr17,r19,0,12	// insert PTE control bits into r19
 	;;
 	or r19=3Dr19,r18		// set bit 4 (uncached) if the access was to region 6
-(p8)	br.cond.spnt.many page_fault
+(p8)	br.cond.spnt page_fault
 	;;
 	itc.i r19		// insert the TLB entry
 	mov pr=3Dr31,-1
@@ -324,7 +324,7 @@
 	;;
 (p8)	mov cr.iha=3Dr17
 (p8)	mov r29=B0				// save b0
-(p8)	br.cond.dptk.many dtlb_fault
+(p8)	br.cond.dptk dtlb_fault
 #endif
 	extr.u r23=3Dr21,IA64_PSR_CPL0_BIT,2	// extract psr.cpl
 	tbit.nz p6,p7=3Dr20,IA64_ISR_SP_BIT	// is speculation bit on?
@@ -333,7 +333,7 @@
 	;;
 	andcm r18=3D0x10,r18	// bit 4=3D~address-bit(61)
 	cmp.ne p8,p0=3Dr0,r23
-(p8)	br.cond.spnt.many page_fault
+(p8)	br.cond.spnt page_fault
=20
 	dep r21=3D-1,r21,IA64_PSR_ED_BIT,1
 	dep r19=3Dr17,r19,0,12	// insert PTE control bits into r19
@@ -429,7 +429,7 @@
 	;;
 (p7)	cmp.eq.or.andcm p6,p7=3Dr17,r0		// was L2 entry NULL?
 	dep r17=3Dr19,r17,3,(PAGE_SHIFT-3)	// compute address of L3 page table en=
try
-(p6)	br.cond.spnt.many page_fault
+(p6)	br.cond.spnt page_fault
 	mov b0=3Dr30
 	br.sptk.many b0				// return to continuation point
 END(nested_dtlb_miss)
@@ -622,7 +622,7 @@
 	mov r31=3Dpr		// prepare to save predicates
 	;;
 	cmp.eq p0,p7=3Dr16,r17	// is this a system call? (p7 <- false, if so)
-(p7)	br.cond.spnt.many non_syscall
+(p7)	br.cond.spnt non_syscall
=20
 	SAVE_MIN				// uses r31; defines r2:
=20
@@ -638,7 +638,7 @@
 	adds r3=3D8,r2		// set up second base pointer for SAVE_REST
 	;;
 	SAVE_REST
-	br.call.sptk rp=DEmine_args		// clear NaT bits in (potential) syscall args
+	br.call.sptk.many rp=DEmine_args	// clear NaT bits in (potential) syscall=
 args
=20
 	mov r3%5
 	adds r15=3D-1024,r15			// r15 contains the syscall number---subtract 1024
@@ -680,7 +680,7 @@
 	st8 [r16]=3Dr18				// store new value for cr.isr
=20
 (p8)	br.call.sptk.many b6=B6			// ignore this return addr
-	br.cond.sptk.many ia64_trace_syscall
+	br.cond.sptk ia64_trace_syscall
 	// NOT REACHED
 END(break_fault)
=20
@@ -793,8 +793,8 @@
 	mov b6=3Dr8
 	;;
 	cmp.ne p6,p0=3D0,r8
-(p6)	br.call.dpnt b6=B6		// call returns to ia64_leave_kernel
-	br.sptk ia64_leave_kernel
+(p6)	br.call.dpnt.many b6=B6		// call returns to ia64_leave_kernel
+	br.sptk.many ia64_leave_kernel
 END(dispatch_illegal_op_fault)
=20
 	.align 1024
@@ -837,12 +837,12 @@
 	adds r15=3DIA64_PT_REGS_R1_OFFSET + 16,sp
 	;;
 	cmp.eq pSys,pNonSys=3Dr0,r0 // set pSys=3D1, pNonSys=3D0
-	st8 [r15]=3Dr8		// save orignal EAX in r1 (IA32 procs don't use the GP)
+	st8 [r15]=3Dr8		// save original EAX in r1 (IA32 procs don't use the GP)
 	;;
 	alloc r15=3Dar.pfs,0,0,6,0	// must first in an insn group
 	;;
 	ld4 r8=3D[r14],8          // r8 =3D EAX (syscall number)
-	mov r15"2		// sys_vfork - last implemented system call
+	mov r15"2		// last entry in system call table
 	;;
 	cmp.leu.unc p6,p7=3Dr8,r15
 	ld4 out1=3D[r14],8        // r9 =3D ecx
@@ -871,7 +871,7 @@
 	;;
 	mov rp=3Dr15
 (p8)	br.call.sptk.many b6=B6
-	br.cond.sptk.many ia32_trace_syscall
+	br.cond.sptk ia32_trace_syscall
=20
 non_ia32_syscall:
 	alloc r15=3Dar.pfs,0,0,2,0
@@ -1067,7 +1067,7 @@
 	mov r31=3Dpr
 	;;
 	cmp4.eq p6,p0=3D0,r16
-(p6)	br.sptk dispatch_illegal_op_fault
+(p6)	br.sptk.many dispatch_illegal_op_fault
 	;;
 	mov r19$		// fault number
 	br.sptk.many dispatch_to_fault_handler
diff -urN linux-davidm/arch/ia64/kernel/mca.c linux-2.4.10-lia/arch/ia64/ke=
rnel/mca.c
--- linux-davidm/arch/ia64/kernel/mca.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/mca.c	Mon Sep 24 21:49:34 2001
@@ -125,7 +125,7 @@
 void
 ia64_mca_cpe_int_handler (int cpe_irq, void *arg, struct pt_regs *ptregs)
 {
-	IA64_MCA_DEBUG("ia64_mca_cpe_int_handler : received interrupt. vector =3D=
 %#x\n", cpe_irq);
+	IA64_MCA_DEBUG("ia64_mca_cpe_int_handler: received interrupt. vector =3D =
%#x\n", cpe_irq);
=20
 	/* Get the CMC error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);
@@ -200,12 +200,12 @@
 {
 	/* Register the CPE interrupt vector with SAL */
 	if (ia64_sal_mc_set_params(SAL_MC_PARAM_CPE_INT, SAL_MC_PARAM_MECHANISM_I=
NT, cpev, 0, 0)) {
-		printk("ia64_mca_platform_init : failed to register Corrected "
+		printk("ia64_mca_platform_init: failed to register Corrected "
 		       "Platform Error interrupt vector with SAL.\n");
 		return;
 	}
=20
-	IA64_MCA_DEBUG("ia64_mca_platform_init : corrected platform error "
+	IA64_MCA_DEBUG("ia64_mca_platform_init: corrected platform error "
 		       "vector %#x setup and enabled\n", cpev);
 }
=20
@@ -279,11 +279,11 @@
 	cmcv.cmcv_vector    =3D IA64_CMC_VECTOR;
 	ia64_set_cmcv(cmcv.cmcv_regval);
=20
-	IA64_MCA_DEBUG("ia64_mca_platform_init : CPU %d corrected "
+	IA64_MCA_DEBUG("ia64_mca_platform_init: CPU %d corrected "
 		       "machine check vector %#x setup and enabled.\n",
 		       smp_processor_id(), IA64_CMC_VECTOR);
=20
-	IA64_MCA_DEBUG("ia64_mca_platform_init : CPU %d CMCV =3D %#016lx\n",
+	IA64_MCA_DEBUG("ia64_mca_platform_init: CPU %d CMCV =3D %#016lx\n",
 		       smp_processor_id(), ia64_get_cmcv());
 }
=20
@@ -331,7 +331,7 @@
 	int     rc;
=20
 	if ((rc =3D memcmp((void *)test, (void *)target, sizeof(efi_guid_t)))) {
-		IA64_MCA_DEBUG("ia64_mca_print : invalid guid =3D "
+		IA64_MCA_DEBUG("ia64_mca_print: invalid guid =3D "
 			       "{ %08x, %04x, %04x, { %#02x, %#02x, %#02x, %#02x, "
 			       "%#02x, %#02x, %#02x, %#02x, } } \n ",
 			       test->data1, test->data2, test->data3, test->data4[0],
@@ -372,10 +372,10 @@
 	int i;
 	s64 rc;
=20
-	IA64_MCA_DEBUG("ia64_mca_init : begin\n");
+	IA64_MCA_DEBUG("ia64_mca_init: begin\n");
=20
 	/* Clear the Rendez checkin flag for all cpus */
-	for(i =3D 0 ; i < IA64_MAXCPUS; i++)
+	for(i =3D 0 ; i < NR_CPUS; i++)
 		ia64_mc_info.imi_rendez_checkin[i] =3D IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
=20
 	/*
@@ -389,7 +389,7 @@
 					 IA64_MCA_RENDEZ_TIMEOUT,
 					 0)))
 	{
-		printk("ia64_mca_init : Failed to register rendezvous interrupt "
+		printk("ia64_mca_init: Failed to register rendezvous interrupt "
 		       "with SAL.  rc =3D %ld\n", rc);
 		return;
 	}
@@ -400,12 +400,12 @@
 					 IA64_MCA_WAKEUP_VECTOR,
 					 0, 0)))
 	{
-		printk("ia64_mca_init : Failed to register wakeup interrupt with SAL.  r=
c =3D %ld\n",
+		printk("ia64_mca_init: Failed to register wakeup interrupt with SAL.  rc=
 =3D %ld\n",
 		       rc);
 		return;
 	}
=20
-	IA64_MCA_DEBUG("ia64_mca_init : registered mca rendezvous spinloop and wa=
keup mech.\n");
+	IA64_MCA_DEBUG("ia64_mca_init: registered mca rendezvous spinloop and wak=
eup mech.\n");
=20
 	ia64_mc_info.imi_mca_handler        =3D __pa(mca_hldlr_ptr->fp);
 	/*
@@ -421,12 +421,12 @@
 				       ia64_mc_info.imi_mca_handler_size,
 				       0, 0, 0)))
 	{
-		printk("ia64_mca_init : Failed to register os mca handler with SAL.  rc =
=3D %ld\n",
+		printk("ia64_mca_init: Failed to register os mca handler with SAL.  rc =
=3D %ld\n",
 		       rc);
 		return;
 	}
=20
-	IA64_MCA_DEBUG("ia64_mca_init : registered os mca handler with SAL at 0x%=
lx, gp =3D 0x%lx\n",
+	IA64_MCA_DEBUG("ia64_mca_init: registered os mca handler with SAL at 0x%l=
x, gp =3D 0x%lx\n",
 		       ia64_mc_info.imi_mca_handler, mca_hldlr_ptr->gp);
=20
 	/*
@@ -438,7 +438,7 @@
 	ia64_mc_info.imi_slave_init_handler		=3D __pa(slave_init_ptr->fp);
 	ia64_mc_info.imi_slave_init_handler_size	=3D 0;
=20
-	IA64_MCA_DEBUG("ia64_mca_init : os init handler at %lx\n",
+	IA64_MCA_DEBUG("ia64_mca_init: os init handler at %lx\n",
 		       ia64_mc_info.imi_monarch_init_handler);
=20
 	/* Register the os init handler with SAL */
@@ -450,12 +450,12 @@
 				       __pa(ia64_get_gp()),
 				       ia64_mc_info.imi_slave_init_handler_size)))
 	{
-		printk("ia64_mca_init : Failed to register m/s init handlers with SAL. r=
c =3D %ld\n",
+		printk("ia64_mca_init: Failed to register m/s init handlers with SAL. rc=
 =3D %ld\n",
 		       rc);
 		return;
 	}
=20
-	IA64_MCA_DEBUG("ia64_mca_init : registered os init handler with SAL\n");
+	IA64_MCA_DEBUG("ia64_mca_init: registered os init handler with SAL\n");
=20
 	/*
 	 *  Configure the CMCI vector and handler. Interrupts for CMC are
@@ -486,7 +486,7 @@
 				}
 			ia64_mca_register_cpev(cpev);
 		} else
-			printk("ia64_mca_init : Failed to get routed CPEI vector from ACPI.\n");
+			printk("ia64_mca_init: Failed to get routed CPEI vector from ACPI.\n");
 	}
=20
 	/* Initialize the areas set aside by the OS to buffer the
@@ -732,7 +732,7 @@
 void
 ia64_mca_cmc_int_handler(int cmc_irq, void *arg, struct pt_regs *ptregs)
 {
-	IA64_MCA_DEBUG("ia64_mca_cmc_int_handler : received interrupt vector =3D =
%#x on CPU %d\n",
+	IA64_MCA_DEBUG("ia64_mca_cmc_int_handler: received interrupt vector =3D %=
#x on CPU %d\n",
 		       cmc_irq, smp_processor_id());
=20
 	/* Get the CMC error record and log it */
@@ -922,7 +922,7 @@
 		return total_len;
 	} else {
 		IA64_LOG_UNLOCK(sal_info_type);
-		prfunc("ia64_log_get : Failed to retrieve SAL error record type %d\n",
+		prfunc("ia64_log_get: Failed to retrieve SAL error record type %d\n",
 		       sal_info_type);
 		return 0;
 	}
@@ -1082,7 +1082,7 @@
 	u64                     target_addr;
=20
 	if (!cache_check_info->valid.check_info) {
-		IA64_MCA_DEBUG("ia64_mca_log_print : invalid cache_check_info[%d]\n",i);
+		IA64_MCA_DEBUG("ia64_mca_log_print: invalid cache_check_info[%d]\n",i);
 		return;                 /* If check info data not valid, skip it */
 	}
=20
@@ -1132,7 +1132,7 @@
 	pal_tlb_check_info_t    *info;
=20
 	if (!tlb_check_info->valid.check_info) {
-		IA64_MCA_DEBUG("ia64_mca_log_print : invalid tlb_check_info[%d]\n", i);
+		IA64_MCA_DEBUG("ia64_mca_log_print: invalid tlb_check_info[%d]\n", i);
 		return;                 /* If check info data not valid, skip it */
 	}
=20
@@ -1177,7 +1177,7 @@
 	/* or obtained from */
=20
 	if (!bus_check_info->valid.check_info) {
-		IA64_MCA_DEBUG("ia64_mca_log_print : invalid bus_check_info[%d]\n", i);
+		IA64_MCA_DEBUG("ia64_mca_log_print: invalid bus_check_info[%d]\n", i);
 		return;                 /* If check info data not valid, skip it */
 	}
=20
@@ -1696,7 +1696,7 @@
 #endif  // MCA_PRT_XTRA_DATA for test only @FVL
=20
 	if ((ercd_pos =3D sizeof(sal_log_record_header_t)) >=3D lh->len) {
-		IA64_MCA_DEBUG("ia64_mca_log_print : "
+		IA64_MCA_DEBUG("ia64_mca_log_print: "
 			       "truncated SAL CMC error record. len =3D %d\n",
 			       lh->len);
 		return;
@@ -1714,7 +1714,7 @@
 #endif  // MCA_PRT_XTRA_DATA for test only @FVL
=20
 		if (verify_guid((void *)&slsh->guid, (void *)&(SAL_PROC_DEV_ERR_SECT_GUI=
D))) {
-			IA64_MCA_DEBUG("ia64_mca_log_print : unsupported record section\n");
+			IA64_MCA_DEBUG("ia64_mca_log_print: unsupported record section\n");
 			continue;
 		}
=20
@@ -1725,7 +1725,7 @@
 						 printk);
 	}
=20
-	IA64_MCA_DEBUG("ia64_mca_log_print : "
+	IA64_MCA_DEBUG("ia64_mca_log_print: "
 		       "found %d sections in SAL CMC error record. len =3D %d\n",
 		       n_sects, lh->len);
 	if (!n_sects) {
@@ -1759,7 +1759,7 @@
 #endif  // MCA_PRT_XTRA_DATA for test only @FVL
=20
 	if ((ercd_pos =3D sizeof(sal_log_record_header_t)) >=3D lh->len) {
-		IA64_MCA_DEBUG("ia64_mca_log_print : "
+		IA64_MCA_DEBUG("ia64_mca_log_print: "
 			       "truncated SAL error record. len =3D %d\n",
 			       lh->len);
 		return;
@@ -1826,12 +1826,12 @@
 			ia64_log_plat_bus_err_info_print((sal_log_plat_bus_err_info_t *)slsh,
 							 prfunc);
 		} else {
-			IA64_MCA_DEBUG("ia64_mca_log_print : unsupported record section\n");
+			IA64_MCA_DEBUG("ia64_mca_log_print: unsupported record section\n");
 			continue;
 		}
 	}
=20
-	IA64_MCA_DEBUG("ia64_mca_log_print : found %d sections in SAL error recor=
d. len =3D %d\n",
+	IA64_MCA_DEBUG("ia64_mca_log_print: found %d sections in SAL error record=
. len =3D %d\n",
 		       n_sects, lh->len);
 	if (!n_sects) {
 		prfunc("No Platform Error Info Sections found\n");
diff -urN linux-davidm/arch/ia64/kernel/mca_asm.S linux-2.4.10-lia/arch/ia6=
4/kernel/mca_asm.S
--- linux-davidm/arch/ia64/kernel/mca_asm.S	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/mca_asm.S	Mon Sep 24 21:49:52 2001
@@ -116,7 +116,7 @@
 	// call our handler
 	movl		r2=3Dia64_mca_ucmc_handler;;
 	mov		b6=3Dr2;;
-	br.call.sptk.few    b0=B6;;
+	br.call.sptk.many    b0=B6;;
 .ret0:
 	// Revert back to physical mode before going back to SAL
 	PHYSICAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_end, r4)
@@ -724,7 +724,7 @@
 	adds out0=16,sp				// out0 =3D pointer to pt_regs
 	;;
=20
-	br.call.sptk.few rp=3Dia64_init_handler
+	br.call.sptk.many rp=3Dia64_init_handler
 .ret1:
=20
 return_from_init:
diff -urN linux-davidm/arch/ia64/kernel/pal.S linux-2.4.10-lia/arch/ia64/ke=
rnel/pal.S
--- linux-davidm/arch/ia64/kernel/pal.S	Thu Apr  5 12:51:47 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/pal.S	Mon Sep 24 21:50:01 2001
@@ -4,8 +4,9 @@
  *
  * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
- * Copyright (C) 1999-2000 David Mosberger <davidm@hpl.hp.com>
- * Copyright (C) 2000 Stephane Eranian <eranian@hpl.hp.com>
+ * Copyright (C) 1999-2001 Hewlett-Packard Co
+ *	David Mosberger <davidm@hpl.hp.com>
+ *	Stephane Eranian <eranian@hpl.hp.com>
  *
  * 05/22/2000 eranian Added support for stacked register calls
  * 05/24/2000 eranian Added support for physical mode static calls
@@ -31,7 +32,7 @@
 	movl r2=3Dpal_entry_point
 	;;
 	st8 [r2]=3Din0
-	br.ret.sptk.few rp
+	br.ret.sptk.many rp
 END(ia64_pal_handler_init)
=20
 /*
@@ -41,7 +42,7 @@
  */
 GLOBAL_ENTRY(ia64_pal_default_handler)
 	mov r8=3D-1
-	br.cond.sptk.few rp
+	br.cond.sptk.many rp
 END(ia64_pal_default_handler)
=20
 /*
@@ -79,13 +80,13 @@
 	;;
 (p6)	srlz.i
 	mov rp =3D r8
-	br.cond.sptk.few b7
+	br.cond.sptk.many b7
 1:	mov psr.l =3D loc3
 	mov ar.pfs =3D loc1
 	mov rp =3D loc0
 	;;
 	srlz.d				// seralize restoration of psr.l
-	br.ret.sptk.few	b0
+	br.ret.sptk.many b0
 END(ia64_pal_call_static)
=20
 /*
@@ -120,7 +121,7 @@
 	mov rp =3D loc0
 	;;
 	srlz.d				// serialize restoration of psr.l
-	br.ret.sptk.few	b0
+	br.ret.sptk.many b0
 END(ia64_pal_call_stacked)
=20
 /*
@@ -173,13 +174,13 @@
 	or loc3=3Dloc3,r17		// add in psr the bits to set
 	;;
 	andcm r16=3Dloc3,r16		// removes bits to clear from psr
-	br.call.sptk.few rp=3Dia64_switch_mode
+	br.call.sptk.many rp=3Dia64_switch_mode
 .ret1:	mov rp =3D r8			// install return address (physical)
-	br.cond.sptk.few b7
+	br.cond.sptk.many b7
 1:
 	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
 	mov r16=3Dloc3			// r16=3D original psr
-	br.call.sptk.few rp=3Dia64_switch_mode // return to virtual mode
+	br.call.sptk.many rp=3Dia64_switch_mode // return to virtual mode
 .ret2:
 	mov psr.l =3D loc3		// restore init PSR
=20
@@ -188,7 +189,7 @@
 	;;
 	mov ar.rsc=3Dloc4			// restore RSE configuration
 	srlz.d				// seralize restoration of psr.l
-	br.ret.sptk.few	b0
+	br.ret.sptk.many b0
 END(ia64_pal_call_phys_static)
=20
 /*
@@ -227,13 +228,13 @@
 	mov b7 =3D loc2			// install target to branch reg
 	;;
 	andcm r16=3Dloc3,r16		// removes bits to clear from psr
-	br.call.sptk.few rp=3Dia64_switch_mode
+	br.call.sptk.many rp=3Dia64_switch_mode
 .ret6:
 	br.call.sptk.many rp=B7		// now make the call
 .ret7:
 	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
 	mov r16=3Dloc3			// r16=3D original psr
-	br.call.sptk.few rp=3Dia64_switch_mode	// return to virtual mode
+	br.call.sptk.many rp=3Dia64_switch_mode	// return to virtual mode
=20
 .ret8:	mov psr.l  =3D loc3		// restore init PSR
 	mov ar.pfs =3D loc1
@@ -241,6 +242,6 @@
 	;;
 	mov ar.rsc=3Dloc4			// restore RSE configuration
 	srlz.d				// seralize restoration of psr.l
-	br.ret.sptk.few	b0
+	br.ret.sptk.many b0
 END(ia64_pal_call_phys_stacked)
=20
diff -urN linux-davidm/arch/ia64/kernel/perfmon.c linux-2.4.10-lia/arch/ia6=
4/kernel/perfmon.c
--- linux-davidm/arch/ia64/kernel/perfmon.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/perfmon.c	Mon Sep 24 21:50:18 2001
@@ -33,13 +33,12 @@
 #include <asm/signal.h>
 #include <asm/system.h>
 #include <asm/system.h>
-#include <asm/system.h>
 #include <asm/uaccess.h>
 #include <asm/delay.h> /* for ia64_get_itc() */
=20
 #ifdef CONFIG_PERFMON
=20
-#define PFM_VERSION		"0.2"
+#define PFM_VERSION		"0.3"
 #define PFM_SMPL_HDR_VERSION	1
=20
 #define PMU_FIRST_COUNTER	4	/* first generic counter */
@@ -53,6 +52,7 @@
 #define PFM_DISABLE		0xa6	/* freeze only */
 #define PFM_RESTART		0xcf
 #define PFM_CREATE_CONTEXT	0xa7
+#define PFM_DESTROY_CONTEXT	0xa8
 /*
  * Those 2 are just meant for debugging. I considered using sysctl() for
  * that but it is a little bit too pervasive. This solution is at least
@@ -61,6 +61,8 @@
 #define PFM_DEBUG_ON		0xe0
 #define PFM_DEBUG_OFF		0xe1
=20
+#define PFM_DEBUG_BASE		PFM_DEBUG_ON
+
=20
 /*
  * perfmon API flags
@@ -69,7 +71,8 @@
 #define PFM_FL_INHERIT_ONCE	 0x01	/* clone pfm_context only once across fo=
rk() */
 #define PFM_FL_INHERIT_ALL	 0x02	/* always clone pfm_context across fork()=
 */
 #define PFM_FL_SMPL_OVFL_NOBLOCK 0x04	/* do not block on sampling buffer o=
verflow */
-#define PFM_FL_SYSTEMWIDE	 0x08	/* create a systemwide context */
+#define PFM_FL_SYSTEM_WIDE	 0x08	/* create a system wide context */
+#define PFM_FL_EXCL_INTR	 0x10	/* exclude interrupt from system wide monit=
oring */
=20
 /*
  * PMC API flags
@@ -88,7 +91,7 @@
 #endif
=20
 #define PMC_IS_IMPL(i)		(i < pmu_conf.num_pmcs && pmu_conf.impl_regs[i>>6]=
 & (1<< (i&~(64-1))))
-#define PMD_IS_IMPL(i)	(i < pmu_conf.num_pmds &&  pmu_conf.impl_regs[4+(i>=
>6)] & (1<< (i&~(64-1))))
+#define PMD_IS_IMPL(i)		(i < pmu_conf.num_pmds &&  pmu_conf.impl_regs[4+(i=
>>6)] & (1<< (i&~(64-1))))
 #define PMD_IS_COUNTER(i)	(i>=3DPMU_FIRST_COUNTER && i < (PMU_FIRST_COUNTE=
R+pmu_conf.max_counters))
 #define PMC_IS_COUNTER(i)	(i>=3DPMU_FIRST_COUNTER && i < (PMU_FIRST_COUNTE=
R+pmu_conf.max_counters))
=20
@@ -198,7 +201,8 @@
 	unsigned int noblock:1;	/* block/don't block on overflow with notificatio=
n */
 	unsigned int system:1;	/* do system wide monitoring */
 	unsigned int frozen:1;	/* pmu must be kept frozen on ctxsw in */
-	unsigned int reserved:27;
+	unsigned int exclintr:1;/* exlcude interrupts from system wide monitoring=
 */
+	unsigned int reserved:26;
 } pfm_context_flags_t;
=20
 typedef struct pfm_context {
@@ -208,26 +212,33 @@
 	unsigned long		ctx_iear_counter;	/* which PMD holds I-EAR */
 	unsigned long		ctx_btb_counter;	/* which PMD holds BTB */
=20
-	pid_t			ctx_notify_pid;	/* who to notify on overflow */
-	int			ctx_notify_sig;	/* XXX: SIGPROF or other */
-	pfm_context_flags_t	ctx_flags;	/* block/noblock */
-	pid_t			ctx_creator;	/* pid of creator (debug) */
-	unsigned long		ctx_ovfl_regs;	/* which registers just overflowed (notific=
ation) */
-	unsigned long		ctx_smpl_regs;	/* which registers to record on overflow */
+	spinlock_t		ctx_notify_lock;
+	pfm_context_flags_t	ctx_flags;		/* block/noblock */
+	int			ctx_notify_sig;		/* XXX: SIGPROF or other */
+	struct task_struct	*ctx_notify_task;	/* who to notify on overflow */
+	struct task_struct	*ctx_creator;		/* pid of creator (debug) */
+
+	unsigned long		ctx_ovfl_regs;		/* which registers just overflowed (notifi=
cation) */
+	unsigned long		ctx_smpl_regs;		/* which registers to record on overflow */
+
+	struct semaphore	ctx_restart_sem; 	/* use for blocking notification mode =
*/
=20
-	struct semaphore	ctx_restart_sem; /* use for blocking notification mode */
+	unsigned long		ctx_used_pmds[4]; 	/* bitmask of used PMD (speedup ctxsw) =
*/
+	unsigned long		ctx_used_pmcs[4]; 	/* bitmask of used PMC (speedup ctxsw) =
*/
=20
 	pfm_counter_t		ctx_pmds[IA64_NUM_PMD_COUNTERS]; /* XXX: size should be dy=
namic */
+
 } pfm_context_t;
=20
+#define CTX_USED_PMD(ctx,n) (ctx)->ctx_used_pmds[(n)>>6] |=3D 1<< ((n) % 6=
4)
+#define CTX_USED_PMC(ctx,n) (ctx)->ctx_used_pmcs[(n)>>6] |=3D 1<< ((n) % 6=
4)
+
 #define ctx_fl_inherit	ctx_flags.inherit
 #define ctx_fl_noblock	ctx_flags.noblock
 #define ctx_fl_system	ctx_flags.system
 #define ctx_fl_frozen	ctx_flags.frozen
+#define ctx_fl_exclintr	ctx_flags.exclintr
=20
-#define CTX_IS_DEAR(c,n)	((c)->ctx_dear_counter =3D (n))
-#define CTX_IS_IEAR(c,n)	((c)->ctx_iear_counter =3D (n))
-#define CTX_IS_BTB(c,n)		((c)->ctx_btb_counter =3D (n))
 #define CTX_OVFL_NOBLOCK(c)	((c)->ctx_fl_noblock =3D 1)
 #define CTX_INHERIT_MODE(c)	((c)->ctx_fl_inherit)
 #define CTX_HAS_SMPL(c)		((c)->ctx_smpl_buf !=3D NULL)
@@ -235,17 +246,15 @@
 static pmu_config_t pmu_conf;
=20
 /* for debug only */
-static unsigned long pfm_debug=3D0;	/* 0=3D nodebug, >0=3D debug output on=
 */
+static int pfm_debug=3D0;	/* 0=3D nodebug, >0=3D debug output on */
+
 #define DBprintk(a) \
 	do { \
-		if (pfm_debug >0) { printk(__FUNCTION__" "); printk a; } \
+		if (pfm_debug >0) { printk(__FUNCTION__" %d: ", __LINE__); printk a; } \
 	} while (0);
=20
-static void perfmon_softint(unsigned long ignored);
 static void ia64_reset_pmu(void);
=20
-DECLARE_TASKLET(pfm_tasklet, perfmon_softint, 0);
-
 /*
  * structure used to pass information between the interrupt handler
  * and the tasklet.
@@ -257,26 +266,42 @@
 	unsigned long	bitvect;	/* which counters have overflowed */
 } notification_info_t;
=20
-#define notification_is_invalid(i)	(i->to_pid < 2)
=20
-/* will need to be cache line padded */
-static notification_info_t notify_info[NR_CPUS];
+typedef struct {
+	unsigned long pfs_proc_sessions;
+	unsigned long pfs_sys_session; /* can only be 0/1 */
+	unsigned long pfs_dfl_dcr;	/* XXX: hack */
+	unsigned int  pfs_pp;
+} pfm_session_t;
=20
-/*
- * We force cache line alignment to avoid false sharing
- * given that we have one entry per CPU.
- */
-static struct {
+struct {
 	struct task_struct *owner;
 } ____cacheline_aligned pmu_owners[NR_CPUS];
-/* helper macros */
+
+
+/*=20
+ * helper macros
+ */
 #define SET_PMU_OWNER(t)	do { pmu_owners[smp_processor_id()].owner =3D (t)=
; } while(0);
 #define PMU_OWNER()		pmu_owners[smp_processor_id()].owner
=20
+#ifdef CONFIG_SMP
+#define PFM_CAN_DO_LAZY()	(smp_num_cpus=3D1 && pfs_info.pfs_sys_session=3D=
0)
+#else
+#define PFM_CAN_DO_LAZY()	(pfs_info.pfs_sys_session=3D0)
+#endif
+
+static void pfm_lazy_save_regs (struct task_struct *ta);
+
 /* for debug only */
 static struct proc_dir_entry *perfmon_dir;
=20
 /*
+ * XXX: hack to indicate that a system wide monitoring session is active
+ */
+static pfm_session_t pfs_info;
+
+/*
  * finds the number of PM(C|D) registers given
  * the bitvector returned by PAL
  */
@@ -340,8 +365,7 @@
 static inline unsigned long
 kvirt_to_pa(unsigned long adr)
 {
-	__u64 pa;
-	__asm__ __volatile__ ("tpa %0 =3D %1" : "=3Dr"(pa) : "r"(adr) : "memory");
+	__u64 pa =3D ia64_tpa(adr);
 	DBprintk(("kv2pa(%lx-->%lx)\n", adr, pa));
 	return pa;
 }
@@ -569,25 +593,44 @@
 static int
 pfx_is_sane(pfreq_context_t *pfx)
 {
+	int ctx_flags;
+
 	/* valid signal */
-	if (pfx->notify_sig < 1 || pfx->notify_sig >=3D _NSIG) return 0;
+	//if (pfx->notify_sig < 1 || pfx->notify_sig >=3D _NSIG) return -EINVAL;
+	if (pfx->notify_sig !=3D0 && pfx->notify_sig !=3D SIGPROF) return -EINVAL;
=20
 	/* cannot send to process 1, 0 means do not notify */
-	if (pfx->notify_pid < 0 || pfx->notify_pid =3D 1) return 0;
+	if (pfx->notify_pid < 0 || pfx->notify_pid =3D 1) return -EINVAL;
+
+	ctx_flags =3D pfx->flags;
=20
+	if (ctx_flags & PFM_FL_SYSTEM_WIDE) {
+#ifdef CONFIG_SMP
+		if (smp_num_cpus > 1) {
+			printk("perfmon: system wide monitoring on SMP not yet supported\n");
+			return -EINVAL;
+		}
+#endif
+		if ((ctx_flags & PFM_FL_SMPL_OVFL_NOBLOCK) =3D 0) {
+			printk("perfmon: system wide monitoring cannot use blocking notificatio=
n mode\n");
+			return -EINVAL;
+		}
+	}
 	/* probably more to add here */
=20
-	return 1;
+	return 0;
 }
=20
 static int
-pfm_context_create(struct task_struct *task, int flags, perfmon_req_t *req)
+pfm_context_create(int flags, perfmon_req_t *req)
 {
 	pfm_context_t *ctx;
+	struct task_struct *task =3D NULL;
 	perfmon_req_t tmp;
 	void *uaddr =3D NULL;
-	int ret =3D -EFAULT;
+	int ret;
 	int ctx_flags;
+	pid_t pid;
=20
 	/* to go away */
 	if (flags) {
@@ -596,48 +639,156 @@
=20
 	if (copy_from_user(&tmp, req, sizeof(tmp))) return -EFAULT;
=20
+	ret =3D pfx_is_sane(&tmp.pfr_ctx);
+	if (ret < 0) return ret;
+
 	ctx_flags =3D tmp.pfr_ctx.flags;
=20
-	/* not yet supported */
-	if (ctx_flags & PFM_FL_SYSTEMWIDE) return -EINVAL;
+	if (ctx_flags & PFM_FL_SYSTEM_WIDE) {
+		/*
+		 * XXX: This is not AT ALL SMP safe
+		 */
+		if (pfs_info.pfs_proc_sessions > 0) return -EBUSY;
+		if (pfs_info.pfs_sys_session > 0) return -EBUSY;
+
+		pfs_info.pfs_sys_session =3D 1;
=20
-	if (!pfx_is_sane(&tmp.pfr_ctx)) return -EINVAL;
+	} else if (pfs_info.pfs_sys_session >0) {
+		/* no per-process monitoring while there is a system wide session */
+		return -EBUSY;
+	} else
+		pfs_info.pfs_proc_sessions++;
=20
 	ctx =3D pfm_context_alloc();
-	if (!ctx) return -ENOMEM;
+	if (!ctx) goto error;
+
+	/* record the creator (debug only) */
+	ctx->ctx_creator =3D current;
+
+	pid =3D tmp.pfr_ctx.notify_pid;
+
+	spin_lock_init(&ctx->ctx_notify_lock);
+
+	if (pid =3D current->pid) {
+		ctx->ctx_notify_task =3D task =3D current;
+		current->thread.pfm_context =3D ctx;
+
+		atomic_set(&current->thread.pfm_notifiers_check, 1);
=20
-	/* record who the creator is (for debug) */
-	ctx->ctx_creator =3D task->pid;
+	} else if (pid!=3D0) {
+		read_lock(&tasklist_lock);
+
+		task =3D find_task_by_pid(pid);
+		if (task) {
+			/*
+		 	 * record who to notify
+		 	 */
+			ctx->ctx_notify_task =3D task;
+
+			/*=20
+		 	 * make visible
+		 	 * must be done inside critical section
+		 	 *
+		 	 * if the initialization does not go through it is still
+		 	 * okay because child will do the scan for nothing which
+		 	 * won't hurt.
+		 	 */
+			current->thread.pfm_context =3D ctx;
+
+			/*
+			 * will cause task to check on exit for monitored
+			 * processes that would notify it. see release_thread()
+			 * Note: the scan MUST be done in release thread, once the
+			 * task has been detached from the tasklist otherwise you are
+			 * exposed to race conditions.
+			 */
+			atomic_add(1, &task->thread.pfm_notifiers_check);
+		}
+		read_unlock(&tasklist_lock);
+	}
+
+	/*
+	 * notification process does not exist
+	 */
+	if (pid !=3D 0 && task =3D NULL) {
+		ret =3D -EINVAL;
+		goto buffer_error;
+	}
=20
-	ctx->ctx_notify_pid =3D tmp.pfr_ctx.notify_pid;
 	ctx->ctx_notify_sig =3D SIGPROF;	/* siginfo imposes a fixed signal */
=20
 	if (tmp.pfr_ctx.smpl_entries) {
 		DBprintk((" sampling entries=3D%ld\n",tmp.pfr_ctx.smpl_entries));
-		if ((ret=3Dpfm_smpl_buffer_alloc(ctx, tmp.pfr_ctx.smpl_regs, tmp.pfr_ctx=
.smpl_entries, &uaddr)) ) goto buffer_error;
+
+		ret =3D pfm_smpl_buffer_alloc(ctx, tmp.pfr_ctx.smpl_regs,=20
+						 tmp.pfr_ctx.smpl_entries, &uaddr);
+		if (ret<0) goto buffer_error;
+
 		tmp.pfr_ctx.smpl_vaddr =3D uaddr;
 	}
 	/* initialization of context's flags */
-	ctx->ctx_fl_inherit =3D ctx_flags & PFM_FL_INHERIT_MASK;
-	ctx->ctx_fl_noblock =3D (ctx_flags & PFM_FL_SMPL_OVFL_NOBLOCK) ? 1 : 0;
-	ctx->ctx_fl_system  =3D (ctx_flags & PFM_FL_SYSTEMWIDE) ? 1: 0;
-	ctx->ctx_fl_frozen  =3D 0;
+	ctx->ctx_fl_inherit  =3D ctx_flags & PFM_FL_INHERIT_MASK;
+	ctx->ctx_fl_noblock  =3D (ctx_flags & PFM_FL_SMPL_OVFL_NOBLOCK) ? 1 : 0;
+	ctx->ctx_fl_system   =3D (ctx_flags & PFM_FL_SYSTEM_WIDE) ? 1: 0;
+	ctx->ctx_fl_exclintr =3D (ctx_flags & PFM_FL_EXCL_INTR) ? 1: 0;
+	ctx->ctx_fl_frozen   =3D 0;
+
+	/*=20
+	 * Keep track of the pmds we want to sample
+	 * XXX: may be we don't need to save/restore the DEAR/IEAR pmds
+	 * but we do need the BTB for sure. This is because of a hardware
+	 * buffer of 1 only for non-BTB pmds.
+	 */
+	ctx->ctx_used_pmds[0] =3D tmp.pfr_ctx.smpl_regs;
+	ctx->ctx_used_pmcs[0] =3D 1; /* always save/restore PMC[0] */
=20
 	sema_init(&ctx->ctx_restart_sem, 0); /* init this semaphore to locked */
=20
-	if (copy_to_user(req, &tmp, sizeof(tmp))) goto buffer_error;
=20
-	DBprintk((" context=3D%p, pid=3D%d notify_sig %d notify_pid=3D%d\n",(void=
 *)ctx, task->pid, ctx->ctx_notify_sig, ctx->ctx_notify_pid));
-	DBprintk((" context=3D%p, pid=3D%d flags=3D0x%x inherit=3D%d noblock=3D%d=
 system=3D%d\n",(void *)ctx, task->pid, ctx_flags, ctx->ctx_fl_inherit, ctx=
->ctx_fl_noblock, ctx->ctx_fl_system));
+	if (copy_to_user(req, &tmp, sizeof(tmp))) {
+		ret =3D -EFAULT;
+		goto buffer_error;
+	}
+
+	DBprintk((" context=3D%p, pid=3D%d notify_sig %d notify_task=3D%p\n",(voi=
d *)ctx, current->pid, ctx->ctx_notify_sig, ctx->ctx_notify_task));
+	DBprintk((" context=3D%p, pid=3D%d flags=3D0x%x inherit=3D%d noblock=3D%d=
 system=3D%d\n",(void *)ctx, current->pid, ctx_flags, ctx->ctx_fl_inherit, =
ctx->ctx_fl_noblock, ctx->ctx_fl_system));
+
+	/*
+	 * when no notification is required, we can make this visible at the last=
 moment
+	 */
+	if (pid =3D 0) current->thread.pfm_context =3D ctx;
+
+	/*
+	 * by default, we always include interrupts for system wide
+	 * DCR.pp is set by default to zero by kernel  in cpu_init()
+	 */
+	if (ctx->ctx_fl_system) {
+		if (ctx->ctx_fl_exclintr =3D 0) {
+			unsigned long dcr =3D ia64_get_dcr();
+
+			ia64_set_dcr(dcr|IA64_DCR_PP);
+			/*
+			* keep track of the kernel default value
+			 */
+			pfs_info.pfs_dfl_dcr =3D dcr;
=20
-	/* link with task */
-	task->thread.pfm_context =3D ctx;
+			DBprintk((" dcr.pp is set\n"));
+		}
+	}=20
=20
 	return 0;
=20
 buffer_error:
-	vfree(ctx);
-
+	pfm_context_free(ctx);
+error:
+	/*
+	 * undo session reservation
+	 */
+	if (ctx_flags & PFM_FL_SYSTEM_WIDE) {
+		pfs_info.pfs_sys_session =3D 0;
+	} else {
+		pfs_info.pfs_proc_sessions--;
+	}
 	return ret;
 }
=20
@@ -658,10 +809,10 @@
 			/* upper part is ignored on rval */
 			ia64_set_pmd(cnum, ctx->ctx_pmds[i].smpl_rval);
=20
-			/*=20
+			/*
 			 * we must reset BTB index (clears pmd16.full to make
 			 * sure we do not report the same branches twice.
-			 * The non-blocking case in handled in update_counters().
+			 * The non-blocking case in handled in update_counters()
 			 */
 			if (cnum =3D ctx->ctx_btb_counter) {
 				DBprintk(("reseting PMD16\n"));
@@ -669,6 +820,8 @@
 			}
 		}
 	}
+	/* just in case ! */
+	ctx->ctx_ovfl_regs =3D 0;
 }
=20
 static int
@@ -706,20 +859,23 @@
 			} else if (PMC_IS_BTB(&tmp.pfr_reg.reg_value)) {
 				ctx->ctx_btb_counter =3D cnum;
 			}
-
+#if 0
 			if (tmp.pfr_reg.reg_flags & PFM_REGFL_OVFL_NOTIFY)
 				ctx->ctx_pmds[cnum - PMU_FIRST_COUNTER].flags |=3D PFM_REGFL_OVFL_NOTI=
FY;
+#endif
 		}
-
+		/* keep track of what we use */
+		CTX_USED_PMC(ctx, cnum);
 		ia64_set_pmc(cnum, tmp.pfr_reg.reg_value);
-			DBprintk((" setting PMC[%ld]=3D0x%lx flags=3D0x%x\n", cnum, tmp.pfr_reg=
.reg_value, ctx->ctx_pmds[cnum - PMU_FIRST_COUNTER].flags));
+
+		DBprintk((" setting PMC[%ld]=3D0x%lx flags=3D0x%x used_pmcs=3D0%lx\n", c=
num, tmp.pfr_reg.reg_value, ctx->ctx_pmds[cnum - PMU_FIRST_COUNTER].flags, =
ctx->ctx_used_pmcs[0]));
=20
 	}
 	/*
 	 * we have to set this here event hough we haven't necessarily started mo=
nitoring
 	 * because we may be context switched out
 	 */
-	th->flags |=3D IA64_THREAD_PM_VALID;
+	if (ctx->ctx_fl_system=3D0) th->flags |=3D IA64_THREAD_PM_VALID;
=20
 	return 0;
 }
@@ -752,25 +908,32 @@
 			ctx->ctx_pmds[k].val  =3D tmp.pfr_reg.reg_value & ~pmu_conf.perf_ovfl_v=
al;
 			ctx->ctx_pmds[k].smpl_rval =3D tmp.pfr_reg.reg_smpl_reset;
 			ctx->ctx_pmds[k].ovfl_rval =3D tmp.pfr_reg.reg_ovfl_reset;
+
+			if (tmp.pfr_reg.reg_flags & PFM_REGFL_OVFL_NOTIFY)
+				ctx->ctx_pmds[cnum - PMU_FIRST_COUNTER].flags |=3D PFM_REGFL_OVFL_NOTI=
FY;
 		}
+		/* keep track of what we use */
+		CTX_USED_PMD(ctx, cnum);
=20
 		/* writes to unimplemented part is ignored, so this is safe */
 		ia64_set_pmd(cnum, tmp.pfr_reg.reg_value);
=20
 		/* to go away */
 		ia64_srlz_d();
-		DBprintk((" setting PMD[%ld]:  pmd.val=3D0x%lx pmd.ovfl_rval=3D0x%lx pmd=
.smpl_rval=3D0x%lx pmd=3D%lx\n",
+		DBprintk((" setting PMD[%ld]:  ovfl_notify=3D%d pmd.val=3D0x%lx pmd.ovfl=
_rval=3D0x%lx pmd.smpl_rval=3D0x%lx pmd=3D%lx used_pmds=3D0%lx\n",
 					cnum,
+					PMD_OVFL_NOTIFY(ctx, cnum - PMU_FIRST_COUNTER),
 					ctx->ctx_pmds[k].val,
 					ctx->ctx_pmds[k].ovfl_rval,
 					ctx->ctx_pmds[k].smpl_rval,
-					ia64_get_pmd(cnum) & pmu_conf.perf_ovfl_val));
+					ia64_get_pmd(cnum) & pmu_conf.perf_ovfl_val,
+					ctx->ctx_used_pmds[0]));
 	}
 	/*
 	 * we have to set this here event hough we haven't necessarily started mo=
nitoring
 	 * because we may be context switched out
 	 */
-	th->flags |=3D IA64_THREAD_PM_VALID;
+	if (ctx->ctx_fl_system=3D0) th->flags |=3D IA64_THREAD_PM_VALID;
=20
 	return 0;
 }
@@ -821,7 +984,8 @@
 		}
 		tmp.pfr_reg.reg_value =3D val;
=20
-		DBprintk((" reading PMD[%ld]=3D0x%lx reg=3D0x%lx ctx_val=3D0x%lx pmc=3D0=
x%lx\n", tmp.pfr_reg.reg_num, val, reg_val, ctx_val, ia64_get_pmc(tmp.pfr_r=
eg.reg_num)));
+		DBprintk((" reading PMD[%ld]=3D0x%lx reg=3D0x%lx ctx_val=3D0x%lx pmc=3D0=
x%lx\n",=20
+					tmp.pfr_reg.reg_num, val, reg_val, ctx_val, ia64_get_pmc(tmp.pfr_reg.=
reg_num)));
=20
 		if (copy_to_user(req, &tmp, sizeof(tmp))) return -EFAULT;
 	}
@@ -836,7 +1000,7 @@
 	void *sem =3D &ctx->ctx_restart_sem;
=20
 	if (task =3D current) {
-		DBprintk((" restartig self %d frozen=3D%d \n", current->pid, ctx->ctx_fl=
_frozen));
+		DBprintk((" restarting self %d frozen=3D%d \n", current->pid, ctx->ctx_f=
l_frozen));
=20
 		pfm_reset_regs(ctx);
=20
@@ -885,6 +1049,23 @@
 	return 0;
 }
=20
+/*
+ * system-wide mode: propagate activation/desactivation throughout the tas=
klist
+ *
+ * XXX: does not work for SMP, of course
+ */
+static void
+pfm_process_tasklist(int cmd)
+{
+	struct task_struct *p;
+	struct pt_regs *regs;
+
+	for_each_task(p) {
+		regs =3D (struct pt_regs *)((unsigned long)p + IA64_STK_OFFSET);
+		regs--;
+		ia64_psr(regs)->pp =3D cmd;
+	}
+}
=20
 static int
 do_perfmonctl (struct task_struct *task, int cmd, int flags, perfmon_req_t=
 *req, int count, struct pt_regs *regs)
@@ -895,19 +1076,26 @@
=20
 	memset(&tmp, 0, sizeof(tmp));
=20
+	if (ctx =3D NULL && cmd !=3D PFM_CREATE_CONTEXT && cmd < PFM_DEBUG_BASE) {
+		DBprintk((" PFM_WRITE_PMCS: no context for task %d\n", task->pid));
+		return -EINVAL;
+	}
+
 	switch (cmd) {
 		case PFM_CREATE_CONTEXT:
 			/* a context has already been defined */
 			if (ctx) return -EBUSY;
=20
-			/* may be a temporary limitation */
+			/*
+			 * cannot directly create a context in another process
+			 */
 			if (task !=3D current) return -EINVAL;
=20
 			if (req =3D NULL || count !=3D 1) return -EINVAL;
=20
 			if (!access_ok(VERIFY_READ, req, sizeof(struct perfmon_req_t)*count)) r=
eturn -EFAULT;
=20
-			return pfm_context_create(task, flags, req);
+			return pfm_context_create(flags, req);
=20
 		case PFM_WRITE_PMCS:
 			/* we don't quite support this right now */
@@ -915,10 +1103,6 @@
=20
 			if (!access_ok(VERIFY_READ, req, sizeof(struct perfmon_req_t)*count)) r=
eturn -EFAULT;
=20
-			if (!ctx) {
-				DBprintk((" PFM_WRITE_PMCS: no context for task %d\n", task->pid));
-				return -EINVAL;
-			}
 			return pfm_write_pmcs(task, req, count);
=20
 		case PFM_WRITE_PMDS:
@@ -927,45 +1111,41 @@
=20
 			if (!access_ok(VERIFY_READ, req, sizeof(struct perfmon_req_t)*count)) r=
eturn -EFAULT;
=20
-			if (!ctx) {
-				DBprintk((" PFM_WRITE_PMDS: no context for task %d\n", task->pid));
-				return -EINVAL;
-			}
 			return pfm_write_pmds(task, req, count);
=20
 		case PFM_START:
 			/* we don't quite support this right now */
 			if (task !=3D current) return -EINVAL;
=20
-			if (!ctx) {
-				DBprintk((" PFM_START: no context for task %d\n", task->pid));
-				return -EINVAL;
-			}
+			if (PMU_OWNER()  && PMU_OWNER() !=3D current && PFM_CAN_DO_LAZY()) pfm_=
lazy_save_regs(PMU_OWNER());
=20
 			SET_PMU_OWNER(current);
=20
 			/* will start monitoring right after rfi */
 			ia64_psr(regs)->up =3D 1;
+			ia64_psr(regs)->pp =3D 1;
+
+			if (ctx->ctx_fl_system) {
+				pfm_process_tasklist(1);
+				pfs_info.pfs_pp =3D 1;
+			}
=20
 			/*
 			 * mark the state as valid.
 			 * this will trigger save/restore at context switch
 			 */
-			th->flags |=3D IA64_THREAD_PM_VALID;
+			if (ctx->ctx_fl_system=3D0) th->flags |=3D IA64_THREAD_PM_VALID;
=20
 			ia64_set_pmc(0, 0);
 			ia64_srlz_d();
=20
-		break;
+			break;
=20
 		case PFM_ENABLE:
 			/* we don't quite support this right now */
 			if (task !=3D current) return -EINVAL;
=20
-			if (!ctx) {
-				DBprintk((" PFM_ENABLE: no context for task %d\n", task->pid));
-				return -EINVAL;
-			}
+			if (PMU_OWNER()  && PMU_OWNER() !=3D current && PFM_CAN_DO_LAZY()) pfm_=
lazy_save_regs(PMU_OWNER());
=20
 			/* reset all registers to stable quiet state */
 			ia64_reset_pmu();
@@ -983,7 +1163,7 @@
 			 * mark the state as valid.
 			 * this will trigger save/restore at context switch
 			 */
-			th->flags |=3D IA64_THREAD_PM_VALID;
+			if (ctx->ctx_fl_system=3D0) th->flags |=3D IA64_THREAD_PM_VALID;
=20
 			/* simply unfreeze */
 			ia64_set_pmc(0, 0);
@@ -997,54 +1177,41 @@
 			/* simply freeze */
 			ia64_set_pmc(0, 1);
 			ia64_srlz_d();
+			/*
+			 * XXX: cannot really toggle IA64_THREAD_PM_VALID
+			 * but context is still considered valid, so any=20
+			 * read request would return something valid. Same
+			 * thing when this task terminates (pfm_flush_regs()).
+			 */
 			break;
=20
 		case PFM_READ_PMDS:
 			if (!access_ok(VERIFY_READ, req, sizeof(struct perfmon_req_t)*count)) r=
eturn -EFAULT;
 			if (!access_ok(VERIFY_WRITE, req, sizeof(struct perfmon_req_t)*count)) =
return -EFAULT;
=20
-			if (!ctx) {
-				DBprintk((" PFM_READ_PMDS: no context for task %d\n", task->pid));
-				return -EINVAL;
-			}
 			return pfm_read_pmds(task, req, count);
=20
 	      case PFM_STOP:
 			/* we don't quite support this right now */
 			if (task !=3D current) return -EINVAL;
=20
-			ia64_set_pmc(0, 1);
-			ia64_srlz_d();
-
+			/* simply stop monitors, not PMU */
 			ia64_psr(regs)->up =3D 0;
+			ia64_psr(regs)->pp =3D 0;
=20
-			th->flags &=3D ~IA64_THREAD_PM_VALID;
-
-			SET_PMU_OWNER(NULL);
-
-			/* we probably will need some more cleanup here */
-			break;
-
-	      case PFM_DEBUG_ON:
-			printk(" debugging on\n");
-			pfm_debug =3D 1;
-			break;
+			if (ctx->ctx_fl_system) {
+				pfm_process_tasklist(0);
+				pfs_info.pfs_pp =3D 0;
+			}
=20
-	      case PFM_DEBUG_OFF:
-			printk(" debugging off\n");
-			pfm_debug =3D 0;
 			break;
=20
 	      case PFM_RESTART: /* temporary, will most likely end up as a PFM_EN=
ABLE */
=20
-			if ((th->flags & IA64_THREAD_PM_VALID) =3D 0) {
+			if ((th->flags & IA64_THREAD_PM_VALID) =3D 0 && ctx->ctx_fl_system=3D0)=
 {
 				printk(" PFM_RESTART not monitoring\n");
 				return -EINVAL;
 			}
-			if (!ctx) {
-				printk(" PFM_RESTART no ctx for %d\n", task->pid);
-				return -EINVAL;
-			}
 			if (CTX_OVFL_NOBLOCK(ctx) =3D 0 && ctx->ctx_fl_frozen=3D0) {
 				printk("task %d without pmu_frozen set\n", task->pid);
 				return -EINVAL;
@@ -1052,6 +1219,37 @@
=20
 			return pfm_do_restart(task); /* we only look at first entry */
=20
+	      case PFM_DESTROY_CONTEXT:
+			/* we don't quite support this right now */
+			if (task !=3D current) return -EINVAL;
+
+			/* first stop monitors */
+			ia64_psr(regs)->up =3D 0;
+			ia64_psr(regs)->pp =3D 0;
+
+			/* then freeze PMU */
+			ia64_set_pmc(0, 1);
+			ia64_srlz_d();
+
+			/* don't save/restore on context switch */
+			if (ctx->ctx_fl_system =3D0) task->thread.flags &=3D ~IA64_THREAD_PM_VA=
LID;
+
+			SET_PMU_OWNER(NULL);
+
+			/* now free context and related state */
+			pfm_context_exit(task);
+			break;
+
+	      case PFM_DEBUG_ON:
+			printk("perfmon debugging on\n");
+			pfm_debug =3D 1;
+			break;
+
+	      case PFM_DEBUG_OFF:
+			printk("perfmon debugging off\n");
+			pfm_debug =3D 0;
+			break;
+
 	      default:
 			DBprintk((" UNknown command 0x%x\n", cmd));
 			return -EINVAL;
@@ -1088,11 +1286,8 @@
 	/* XXX: pid interface is going away in favor of pfm context */
 	if (pid !=3D current->pid) {
 		read_lock(&tasklist_lock);
-		{
-			child =3D find_task_by_pid(pid);
-			if (child)
-				get_task_struct(child);
-		}
+
+		child =3D find_task_by_pid(pid);
=20
 		if (!child) goto abort_call;
=20
@@ -1115,93 +1310,44 @@
 	return ret;
 }
=20
-
-/*
- * This function is invoked on the exit path of the kernel. Therefore it m=
ust make sure
- * it does does modify the caller's input registers (in0-in7) in case of e=
ntry by system call
- * which can be restarted. That's why it's declared as a system call and a=
ll 8 possible args
- * are declared even though not used.
- */
 #if __GNUC__ >=3D 3
 void asmlinkage
-pfm_overflow_notify(void)
+pfm_block_on_overflow(void)
 #else
 void asmlinkage
-pfm_overflow_notify(u64 arg0, u64 arg1, u64 arg2, u64 arg3, u64 arg4, u64 =
arg5, u64 arg6, u64 arg7)
+pfm_block_on_overflow(u64 arg0, u64 arg1, u64 arg2, u64 arg3, u64 arg4, u6=
4 arg5, u64 arg6, u64 arg7)
 #endif
 {
-	struct task_struct *task;
 	struct thread_struct *th =3D &current->thread;
 	pfm_context_t *ctx =3D current->thread.pfm_context;
-	struct siginfo si;
 	int ret;
=20
 	/*
-	 * do some sanity checks first
-	 */
-	if (!ctx) {
-		printk("perfmon: process %d has no PFM context\n", current->pid);
-		return;
-	}
-	if (ctx->ctx_notify_pid < 2) {
-		printk("perfmon: process %d invalid notify_pid=3D%d\n", current->pid, ct=
x->ctx_notify_pid);
-		return;
-	}
-
-	DBprintk((" current=3D%d ctx=3D%p bv=3D0%lx\n", current->pid, (void *)ctx=
, ctx->ctx_ovfl_regs));
-	/*
 	 * NO matter what notify_pid is,
 	 * we clear overflow, won't notify again
 	 */
-	th->pfm_pend_notify =3D 0;
+	th->pfm_must_block =3D 0;
=20
 	/*
-	 * When measuring in kernel mode and non-blocking fashion, it is possible=
 to
-	 * get an overflow while executing this code. Therefore the state of pend=
_notify
-	 * and ovfl_regs can be altered. The important point is not to loose any =
notification.
-	 * It is fine to get called for nothing. To make sure we do collect as mu=
ch state as
-	 * possible, update_counters() always uses |=3D to add bit to the ovfl_re=
gs field.
-	 *
-	 * In certain cases, it is possible to come here, with ovfl_regs =3D 0;
-	 *
-	 * XXX: pend_notify and ovfl_regs could be merged maybe !
+	 * do some sanity checks first
 	 */
-	if (ctx->ctx_ovfl_regs =3D 0) {
-		DBprintk(("perfmon: spurious overflow notification from pid %d\n", curre=
nt->pid));
+	if (!ctx) {
+		printk("perfmon: process %d has no PFM context\n", current->pid);
 		return;
 	}
-	read_lock(&tasklist_lock);
-
-	task =3D find_task_by_pid(ctx->ctx_notify_pid);
-
-	if (task) {
-		si.si_signo    =3D ctx->ctx_notify_sig;
-		si.si_errno    =3D 0;
-		si.si_code     =3D PROF_OVFL; /* goes to user */
-		si.si_addr     =3D NULL;
-		si.si_pid      =3D current->pid; /* who is sending */
-		si.si_pfm_ovfl =3D ctx->ctx_ovfl_regs;
-
-		DBprintk((" SIGPROF to %d @ %p\n", task->pid, (void *)task));
-
-		/* must be done with tasklist_lock locked */
-		ret =3D send_sig_info(ctx->ctx_notify_sig, &si, task);
-		if (ret !=3D 0) {
-			DBprintk((" send_sig_info(process %d, SIGPROF)=3D%d\n", ctx->ctx_notify=
_pid, ret));
-			task =3D NULL; /* will cause return */
-		}
-	} else {
-		printk("perfmon: notify_pid %d not found\n", ctx->ctx_notify_pid);
+	if (ctx->ctx_notify_task =3D 0) {
+		printk("perfmon: process %d has no task to notify\n", current->pid);
+		return;
 	}
=20
-	read_unlock(&tasklist_lock);
+	DBprintk((" current=3D%d task=3D%d\n", current->pid, ctx->ctx_notify_task=
->pid));
=20
-	/* now that we have released the lock handle error condition */
-	if (!task || CTX_OVFL_NOBLOCK(ctx)) {
-		/* we clear all pending overflow bits in noblock mode */
-		ctx->ctx_ovfl_regs =3D 0;
+	/* should not happen */
+	if (CTX_OVFL_NOBLOCK(ctx)) {
+		printk("perfmon: process %d non-blocking ctx should not be here\n", curr=
ent->pid);
 		return;
 	}
+
 	DBprintk((" CPU%d %d before sleep\n", smp_processor_id(), current->pid));
=20
 	/*
@@ -1225,9 +1371,6 @@
=20
 		pfm_reset_regs(ctx);
=20
-		/* now we can clear this mask */
-		ctx->ctx_ovfl_regs =3D 0;
-
 		/*
 		 * Unlock sampling buffer and reset index atomically
 		 * XXX: not really needed when blocking
@@ -1246,84 +1389,14 @@
 	}
 }
=20
-static void
-perfmon_softint(unsigned long ignored)
-{
-	notification_info_t *info;
-	int my_cpu =3D smp_processor_id();
-	struct task_struct *task;
-	struct siginfo si;
-
-	info =3D notify_info+my_cpu;
-
-	DBprintk((" CPU%d current=3D%d to_pid=3D%d from_pid=3D%d bv=3D0x%lx\n", \
-		smp_processor_id(), current->pid, info->to_pid, info->from_pid, info->bi=
tvect));
-
-	/* assumption check */
-	if (info->from_pid =3D info->to_pid) {
-		DBprintk((" Tasklet assumption error: from=3D%d tor=3D%d\n", info->from_=
pid, info->to_pid));
-		return;
-	}
-
-	if (notification_is_invalid(info)) {
-		DBprintk((" invalid notification information\n"));
-		return;
-	}
-
-	/* sanity check */
-	if (info->to_pid =3D 1) {
-		DBprintk((" cannot notify init\n"));
-		return;
-	}
-	/*
-	 * XXX: needs way more checks here to make sure we send to a task we have=
 control over
-	 */
-	read_lock(&tasklist_lock);
-
-	task =3D find_task_by_pid(info->to_pid);
-
-	DBprintk((" after find %p\n", (void *)task));
-
-	if (task) {
-		int ret;
-
-		si.si_signo    =3D SIGPROF;
-		si.si_errno    =3D 0;
-		si.si_code     =3D PROF_OVFL; /* goes to user */
-		si.si_addr     =3D  NULL;
-		si.si_pid      =3D info->from_pid; /* who is sending */
-		si.si_pfm_ovfl =3D info->bitvect;
-
-		DBprintk((" SIGPROF to %d @ %p\n", task->pid, (void *)task));
-
-		/* must be done with tasklist_lock locked */
-		ret =3D send_sig_info(SIGPROF, &si, task);
-		if (ret !=3D 0)
-			DBprintk((" send_sig_info(process %d, SIGPROF)=3D%d\n", info->to_pid, r=
et));
-
-		/* invalidate notification */
-		info->to_pid  =3D info->from_pid =3D 0;
-		info->bitvect =3D 0;
-	}
-
-	read_unlock(&tasklist_lock);
-
-	DBprintk((" after unlock %p\n", (void *)task));
-
-	if (!task) {
-		printk("perfmon: CPU%d cannot find process %d\n", smp_processor_id(), in=
fo->to_pid);
-	}
-}
-
 /*
  * main overflow processing routine.
  * it can be called from the interrupt path or explicitely during the cont=
ext switch code
  * Return:
- *	0 : do not unfreeze the PMU
- *	1 : PMU can be unfrozen
+ *	new value of pmc[0]. if 0x0 then unfreeze, else keep frozen
  */
-static unsigned long
-update_counters (struct task_struct *ta, u64 pmc0, struct pt_regs *regs)
+unsigned long
+update_counters (struct task_struct *task, u64 pmc0, struct pt_regs *regs)
 {
 	unsigned long mask, i, cnum;
 	struct thread_struct *th;
@@ -1331,7 +1404,9 @@
 	unsigned long bv =3D 0;
 	int my_cpu =3D smp_processor_id();
 	int ret =3D 1, buffer_is_full =3D 0;
-	int ovfl_is_smpl, can_notify, need_reset_pmd16=3D0;
+	int ovfl_has_long_recovery, can_notify, need_reset_pmd16=3D0;
+	struct siginfo si;
+
 	/*
 	 * It is never safe to access the task for which the overflow interrupt i=
s destinated
 	 * using the current variable as the interrupt may occur in the middle of=
 a context switch
@@ -1345,25 +1420,23 @@
 	 * valid one, i.e. the one that caused the interrupt.
 	 */
=20
-	if (ta =3D NULL) {
+	if (task =3D NULL) {
 		DBprintk((" owners[%d]=3DNULL\n", my_cpu));
 		return 0x1;
 	}
-	th  =3D &ta->thread;
+	th  =3D &task->thread;
 	ctx =3D th->pfm_context;
=20
 	/*
 	 * XXX: debug test
 	 * Don't think this could happen given upfront tests
 	 */
-	if ((th->flags & IA64_THREAD_PM_VALID) =3D 0) {
-		DBprintk(("perfmon: Spurious overflow interrupt: process %d not using pe=
rfmon\n",
-			  ta->pid));
+	if ((th->flags & IA64_THREAD_PM_VALID) =3D 0 && ctx->ctx_fl_system =3D 0)=
 {
+		printk("perfmon: Spurious overflow interrupt: process %d not using perfm=
on\n", task->pid);
 		return 0x1;
 	}
 	if (!ctx) {
-		DBprintk(("perfmon: Spurious overflow interrupt: process %d has no PFM c=
ontext\n",
-			  ta->pid));
+		printk("perfmon: Spurious overflow interrupt: process %d has no PFM cont=
ext\n", task->pid);
 		return 0;
 	}
=20
@@ -1371,16 +1444,21 @@
 	 * sanity test. Should never happen
 	 */
 	if ((pmc0 & 0x1 )=3D 0) {
-		printk("perfmon: pid %d pmc0=3D0x%lx assumption error for freeze bit\n",=
 ta->pid, pmc0);
+		printk("perfmon: pid %d pmc0=3D0x%lx assumption error for freeze bit\n",=
 task->pid, pmc0);
 		return 0x0;
 	}
=20
 	mask =3D pmc0 >> PMU_FIRST_COUNTER;
=20
-	DBprintk(("pmc0=3D0x%lx pid=3D%d\n", pmc0, ta->pid));
-
-	DBprintk(("ctx is in %s mode\n", CTX_OVFL_NOBLOCK(ctx) ? "NO-BLOCK" : "BL=
OCK"));
+	DBprintk(("pmc0=3D0x%lx pid=3D%d owner=3D%d iip=3D0x%lx, ctx is in %s mod=
e used_pmds=3D0x%lx used_pmcs=3D0x%lx\n",=20
+				pmc0, task->pid, PMU_OWNER()->pid, regs->cr_iip,=20
+				CTX_OVFL_NOBLOCK(ctx) ? "NO-BLOCK" : "BLOCK",
+				ctx->ctx_used_pmds[0],
+				ctx->ctx_used_pmcs[0]));
=20
+	/*
+	 * XXX: need to record sample only when an EAR/BTB has overflowed
+	 */
 	if (CTX_HAS_SMPL(ctx)) {
 		pfm_smpl_buffer_desc_t *psb =3D ctx->ctx_smpl_buf;
 		unsigned long *e, m, idx=3D0;
@@ -1388,11 +1466,15 @@
 		int j;
=20
 		idx =3D ia64_fetch_and_add(1, &psb->psb_index);
-		DBprintk((" trying to record index=3D%ld entries=3D%ld\n", idx, psb->psb=
_entries));
+		DBprintk((" recording index=3D%ld entries=3D%ld\n", idx, psb->psb_entrie=
s));
=20
 		/*
 		 * XXX: there is a small chance that we could run out on index before re=
setting
 		 * but index is unsigned long, so it will take some time.....
+		 * We use > instead of =3D because fetch_and_add() is off by one (see be=
low)
+		 *
+		 * This case can happen in non-blocking mode or with multiple processes.
+		 * For non-blocking, we need to reload and continue.
 		 */
 		if (idx > psb->psb_entries) {
 			buffer_is_full =3D 1;
@@ -1404,7 +1486,7 @@
=20
 		h =3D (perfmon_smpl_entry_t *)(((char *)psb->psb_addr) + idx*(psb->psb_e=
ntry_size));
=20
-		h->pid  =3D ta->pid;
+		h->pid  =3D task->pid;
 		h->cpu  =3D my_cpu;
 		h->rate =3D 0;
 		h->ip   =3D regs ? regs->cr_iip : 0x0; /* where did the fault happened */
@@ -1414,6 +1496,7 @@
 		h->stamp =3D perfmon_get_stamp();
=20
 		e =3D (unsigned long *)(h+1);
+
 		/*
 		 * selectively store PMDs in increasing index number
 		 */
@@ -1422,35 +1505,66 @@
 				if (PMD_IS_COUNTER(j))
 					*e =3D  ctx->ctx_pmds[j-PMU_FIRST_COUNTER].val
 					    + (ia64_get_pmd(j) & pmu_conf.perf_ovfl_val);
-				else
+				else {
 					*e =3D ia64_get_pmd(j); /* slow */
+				}
 				DBprintk((" e=3D%p pmd%d =3D0x%lx\n", (void *)e, j, *e));
 				e++;
 			}
 		}
-		/* make the new entry visible to user, needs to be atomic */
+		/*
+		 * make the new entry visible to user, needs to be atomic
+		 */
 		ia64_fetch_and_add(1, &psb->psb_hdr->hdr_count);
=20
 		DBprintk((" index=3D%ld entries=3D%ld hdr_count=3D%ld\n", idx, psb->psb_=
entries, psb->psb_hdr->hdr_count));
-
-		/* sampling buffer full ? */
+		/*=20
+		 * sampling buffer full ?=20
+		 */
 		if (idx =3D (psb->psb_entries-1)) {
-			bv =3D mask;
+			/*
+			 * will cause notification, cannot be 0
+			 */
+			bv =3D mask << PMU_FIRST_COUNTER;
+
 			buffer_is_full =3D 1;
=20
 			DBprintk((" sampling buffer full must notify bv=3D0x%lx\n", bv));
=20
-			if (!CTX_OVFL_NOBLOCK(ctx)) goto buffer_full;
+			/*
+			 * we do not reload here, when context is blocking
+			 */
+			if (!CTX_OVFL_NOBLOCK(ctx)) goto no_reload;
+
 			/*
 			 * here, we have a full buffer but we are in non-blocking mode
-			 * so we need to reloads overflowed PMDs with sampling reset values
-			 * and restart
+			 * so we need to reload overflowed PMDs with sampling reset values
+			 * and restart right away.
 			 */
 		}
+		/* FALL THROUGH */
 	}
 reload_pmds:
-	ovfl_is_smpl =3D CTX_OVFL_NOBLOCK(ctx) && buffer_is_full;
-	can_notify   =3D CTX_HAS_SMPL(ctx) =3D 0 && ctx->ctx_notify_pid;
+
+	/*
+	 * in the case of a non-blocking context, we reload
+	 * with the ovfl_rval when no user notification is taking place (short re=
covery)
+	 * otherwise when the buffer is full which requires user interaction) the=
n we use
+	 * smpl_rval which is the long_recovery path (disturbance introduce by us=
er execution).
+	 *
+	 * XXX: implies that when buffer is full then there is always notificatio=
n.
+	 */
+	ovfl_has_long_recovery =3D CTX_OVFL_NOBLOCK(ctx) && buffer_is_full;
+
+	/*
+	 * XXX: CTX_HAS_SMPL() should really be something like CTX_HAS_SMPL() and=
 is activated,i.e.,
+	 * one of the PMC is configured for EAR/BTB.
+	 *
+	 * When sampling, we can only notify when the sampling buffer is full.
+	 */
+	can_notify   =3D CTX_HAS_SMPL(ctx) =3D 0 && ctx->ctx_notify_task;
+
+	DBprintk((" ovfl_has_long_recovery=3D%d can_notify=3D%d\n", ovfl_has_long=
_recovery, can_notify));
=20
 	for (i =3D 0, cnum =3D PMU_FIRST_COUNTER; mask ; cnum++, i++, mask >>=3D =
1) {
=20
@@ -1472,7 +1586,7 @@
 		DBprintk((" pmod[%ld].val=3D0x%lx pmd=3D0x%lx\n", i, ctx->ctx_pmds[i].va=
l, ia64_get_pmd(cnum)&pmu_conf.perf_ovfl_val));
=20
 		if (can_notify && PMD_OVFL_NOTIFY(ctx, i)) {
-			DBprintk((" CPU%d should notify process %d with signal %d\n", my_cpu, c=
tx->ctx_notify_pid, ctx->ctx_notify_sig));
+			DBprintk((" CPU%d should notify task %p with signal %d\n", my_cpu, ctx-=
>ctx_notify_task, ctx->ctx_notify_sig));
 			bv |=3D 1 << i;
 		} else {
 			DBprintk((" CPU%d PMD[%ld] overflow, no notification\n", my_cpu, cnum));
@@ -1483,93 +1597,150 @@
 			 */
=20
 			/* writes to upper part are ignored, so this is safe */
-			if (ovfl_is_smpl) {
-				DBprintk((" CPU%d PMD[%ld] reloaded with smpl_val=3D%lx\n", my_cpu, cn=
um,ctx->ctx_pmds[i].smpl_rval));
+			if (ovfl_has_long_recovery) {
+				DBprintk((" CPU%d PMD[%ld] reload with smpl_val=3D%lx\n", my_cpu, cnum=
,ctx->ctx_pmds[i].smpl_rval));
 				ia64_set_pmd(cnum, ctx->ctx_pmds[i].smpl_rval);
 			} else {
-				DBprintk((" CPU%d PMD[%ld] reloaded with ovfl_val=3D%lx\n", my_cpu, cn=
um,ctx->ctx_pmds[i].smpl_rval));
+				DBprintk((" CPU%d PMD[%ld] reload with ovfl_val=3D%lx\n", my_cpu, cnum=
,ctx->ctx_pmds[i].smpl_rval));
 				ia64_set_pmd(cnum, ctx->ctx_pmds[i].ovfl_rval);
 			}
 		}
 		if (cnum =3D ctx->ctx_btb_counter) need_reset_pmd16=3D1;
 	}
 	/*
-	 * In case of BTB, overflow
-	 * we need to reset the BTB index.
+	 * In case of BTB overflow we need to reset the BTB index.
 	 */
 	if (need_reset_pmd16) {
 		DBprintk(("reset PMD16\n"));
 		ia64_set_pmd(16, 0);
 	}
-buffer_full:
-	/* see pfm_overflow_notify() on details for why we use |=3D here */
-	ctx->ctx_ovfl_regs  |=3D bv;
=20
-	/* nobody to notify, return and unfreeze */
+no_reload:
+
+	/*
+	 * some counters overflowed, but they did not require
+	 * user notification, so after having reloaded them above
+	 * we simply restart
+	 */
 	if (!bv) return 0x0;
=20
+	ctx->ctx_ovfl_regs  =3D bv; /* keep track of what to reset when unblockin=
g */
+	/*
+	 * Now we know that:
+	 * 	- we have some counters which overflowed (contains in bv)
+	 * 	- someone has asked to be notified on overflow.=20
+	 */
+
+=09
+	/*
+	 * If the notification task is still present, then notify_task is non
+	 * null. It is clean by that task if it ever exits before we do.=20
+	 */
=20
-	if (ctx->ctx_notify_pid =3D ta->pid) {
-		struct siginfo si;
+	if (ctx->ctx_notify_task) {
=20
 		si.si_errno    =3D 0;
 		si.si_addr     =3D NULL;
-		si.si_pid      =3D ta->pid; /* who is sending */
-
+		si.si_pid      =3D task->pid; /* who is sending */
=20
 		si.si_signo    =3D ctx->ctx_notify_sig; /* is SIGPROF */
 		si.si_code     =3D PROF_OVFL; /* goes to user */
 		si.si_pfm_ovfl =3D bv;
=20
=20
+=09
 		/*
-		 * in this case, we don't stop the task, we let it go on. It will
-		 * necessarily go to the signal handler (if any) when it goes back to
-		 * user mode.
+		 * when the target of the signal is not ourself, we have to be more
+		 * careful. The notify_task may being cleared by the target task itself
+		 * in release_thread(). We must ensure mutual exclusion here such that
+		 * the signal is delivered (even to a dying task) safely.
 		 */
-		DBprintk((" sending %d notification to self %d\n", si.si_signo, ta->pid)=
);
-
=20
-		/* this call is safe in an interrupt handler */
-		ret =3D send_sig_info(ctx->ctx_notify_sig, &si, ta);
-		if (ret !=3D 0)
-			printk(" send_sig_info(process %d, SIGPROF)=3D%d\n", ta->pid, ret);
-		/*
-		 * no matter if we block or not, we keep PMU frozen and do not unfreeze =
on ctxsw
-		 */
-		ctx->ctx_fl_frozen =3D 1;
+		if (ctx->ctx_notify_task !=3D current) {
+			/*
+			 * grab the notification lock for this task
+			 */
+			spin_lock(&ctx->ctx_notify_lock);
=20
-	} else {
-#if 0
 			/*
-			 * The tasklet is guaranteed to be scheduled for this CPU only
+			 * now notify_task cannot be modified until we're done
+			 * if NULL, they it got modified while we were in the handler
 			 */
-			notify_info[my_cpu].to_pid   =3D ctx->notify_pid;
-			notify_info[my_cpu].from_pid =3D ta->pid; /* for debug only */
-			notify_info[my_cpu].bitvect  =3D bv;
-			/* tasklet is inserted and active */
-			tasklet_schedule(&pfm_tasklet);
-#endif
+			if (ctx->ctx_notify_task =3D NULL) {
+				spin_unlock(&ctx->ctx_notify_lock);
+				goto lost_notify;
+			}
 			/*
-			 * stored the vector of overflowed registers for use in notification
-			 * mark that a notification/blocking is pending (arm the trap)
+			 * required by send_sig_info() to make sure the target
+			 * task does not disappear on us.
 			 */
-		th->pfm_pend_notify =3D 1;
+			read_lock(&tasklist_lock);
+		}
+		/*
+	 	 * in this case, we don't stop the task, we let it go on. It will
+	 	 * necessarily go to the signal handler (if any) when it goes back to
+	 	 * user mode.
+	 	 */
+		DBprintk((" %d sending %d notification to %d\n", task->pid, si.si_signo,=
 ctx->ctx_notify_task->pid));
=20
+
+		/*=20
+		 * this call is safe in an interrupt handler, so does read_lock() on tas=
klist_lock
+		 */
+		ret =3D send_sig_info(ctx->ctx_notify_sig, &si, ctx->ctx_notify_task);
+		if (ret !=3D 0) printk(" send_sig_info(process %d, SIGPROF)=3D%d\n",  ct=
x->ctx_notify_task->pid, ret);
 		/*
-		 * if we do block, then keep PMU frozen until restart
+		 * now undo the protections in order
 		 */
-		if (!CTX_OVFL_NOBLOCK(ctx)) ctx->ctx_fl_frozen =3D 1;
+		if (ctx->ctx_notify_task !=3D current) {
+			read_unlock(&tasklist_lock);
+			spin_unlock(&ctx->ctx_notify_lock);
+		}
+
+		/*
+		 * if we block set the pfm_must_block bit
+		 * when in block mode, we can effectively block only when the notified
+		 * task is not self, otherwise we would deadlock.=20
+		 * in this configuration, the notification is sent, the task will not=20
+		 * block on the way back to user mode, but the PMU will be kept frozen
+		 * until PFM_RESTART.
+		 * Note that here there is still a race condition with notify_task
+		 * possibly being nullified behind our back, but this is fine because
+		 * it can only be changed to NULL which by construction, can only be
+		 * done when notify_task !=3D current. So if it was already different
+		 * before, changing it to NULL will still maintain this invariant.
+		 * Of course, when it is equal to current it cannot change at this point.
+		 */
+		if (!CTX_OVFL_NOBLOCK(ctx) && ctx->ctx_notify_task !=3D current) {
+				th->pfm_must_block =3D 1; /* will cause blocking */
+		}
+	} else {
+lost_notify:
+		DBprintk((" notification task has disappeared !\n"));
+		/*
+		 * for a non-blocking context, we make sure we do not fall into the pfm_=
overflow_notify()
+		 * trap. Also in the case of a blocking context with lost notify process=
, then we do not
+		 * want to block either (even though it is interruptible). In this case,=
 the PMU will be kept
+		 * frozen and the process will run to completion without monitoring enab=
led.
+		 *
+		 * Of course, we cannot loose notify process when self-monitoring.
+		 */
+		th->pfm_must_block =3D 0;=20
=20
-		DBprintk((" process %d notify ovfl_regs=3D0x%lx\n", ta->pid, bv));
 	}
 	/*
-	 * keep PMU frozen (and overflowed bits cleared) when we have to stop,
-	 * otherwise return a resume 'value' for PMC[0]
-	 *
-	 * XXX: maybe that's enough to get rid of ctx_fl_frozen ?
+	 * if we block, we keep the PMU frozen. If non-blocking we restart.
+	 * in the case of non-blocking were the notify process is lost, we also=20
+	 * restart.=20
 	 */
-	DBprintk((" will return pmc0=3D0x%x\n",ctx->ctx_fl_frozen ? 0x1 : 0x0));
+	if (!CTX_OVFL_NOBLOCK(ctx))=20
+		ctx->ctx_fl_frozen  =3D 1;
+	else
+		ctx->ctx_fl_frozen =3D 0;
+
+	DBprintk((" reload pmc0=3D0x%x must_block=3D%ld\n",
+				ctx->ctx_fl_frozen ? 0x1 : 0x0, th->pfm_must_block));
+
 	return ctx->ctx_fl_frozen ? 0x1 : 0x0;
 }
=20
@@ -1599,8 +1770,7 @@
 		ia64_set_pmc(0, pmc0);
 		ia64_srlz_d();
 	} else {
-		DBprintk(("perfmon: Spurious PMU overflow interrupt: pmc0=3D0x%lx owner=
=3D%p\n",
-			  pmc0, (void *)PMU_OWNER()));
+		printk("perfmon: Spurious PMU overflow interrupt: pmc0=3D0x%lx owner=3D%=
p\n", pmc0, (void *)PMU_OWNER());
 	}
 }
=20
@@ -1612,10 +1782,17 @@
 	u64 pmc0 =3D ia64_get_pmc(0);
 	int i;
=20
-	p +=3D sprintf(p, "PMC[0]=3D%lx\nPerfmon debug: %s\n", pmc0, pfm_debug ? =
"On" : "Off");
+	p +=3D sprintf(p, "CPU%d.pmc[0]=3D%lx\nPerfmon debug: %s\n", smp_processo=
r_id(), pmc0, pfm_debug ? "On" : "Off");
+	p +=3D sprintf(p, "proc_sessions=3D%lu sys_sessions=3D%lu\n",=20
+			pfs_info.pfs_proc_sessions,=20
+			pfs_info.pfs_sys_session);
+
 	for(i=3D0; i < NR_CPUS; i++) {
-		if (cpu_is_online(i))
-			p +=3D sprintf(p, "CPU%d.PMU %d\n", i, pmu_owners[i].owner ? pmu_owners=
[i].owner->pid: 0);
+		if (cpu_is_online(i)) {
+			p +=3D sprintf(p, "CPU%d.pmu_owner: %-6d\n",
+					i,=20
+					pmu_owners[i].owner ? pmu_owners[i].owner->pid: -1);
+		}
 	}
 	return p - page;
 }
@@ -1698,21 +1875,19 @@
 	ia64_srlz_d();
 }
=20
-/*
- * XXX: for system wide this function MUST never be called
- */
 void
 pfm_save_regs (struct task_struct *ta)
 {
 	struct task_struct *owner;
+	pfm_context_t *ctx;
 	struct thread_struct *t;
 	u64 pmc0, psr;
+	unsigned long mask;
 	int i;
=20
-	if (ta =3D NULL) {
-		panic(__FUNCTION__" task is NULL\n");
-	}
-	t =3D &ta->thread;
+	t   =3D &ta->thread;
+	ctx =3D ta->thread.pfm_context;
+
 	/*
 	 * We must make sure that we don't loose any potential overflow
 	 * interrupt while saving PMU context. In this code, external
@@ -1732,7 +1907,7 @@
 	 * in kernel.
 	 * By now, we could still have an overflow interrupt in-flight.
 	 */
-	__asm__ __volatile__ ("rum psr.up;;"::: "memory");
+	__asm__ __volatile__ ("rsm psr.up|psr.pp;;"::: "memory");
=20
 	/*
 	 * Mark the PMU as not owned
@@ -1761,7 +1936,6 @@
 	 * next process does not start with monitoring on if not requested
 	 */
 	ia64_set_pmc(0, 1);
-	ia64_srlz_d();
=20
 	/*
 	 * Check for overflow bits and proceed manually if needed
@@ -1772,87 +1946,104 @@
 	 * next time the task exits from the kernel.
 	 */
 	if (pmc0 & ~0x1) {
-		if (owner !=3D ta) printk(__FUNCTION__" owner=3D%p task=3D%p\n", (void *=
)owner, (void *)ta);
-		DBprintk((__FUNCTION__" Warning: pmc[0]=3D0x%lx explicit call\n", pmc0));
-
-		pmc0 =3D update_counters(owner, pmc0, NULL);
+		update_counters(owner, pmc0, NULL);
 		/* we will save the updated version of pmc0 */
 	}
-
 	/*
 	 * restore PSR for context switch to save
 	 */
 	__asm__ __volatile__ ("mov psr.l=3D%0;; srlz.i;;"::"r"(psr): "memory");
=20
+	/*
+	 * we do not save registers if we can do lazy
+	 */
+	if (PFM_CAN_DO_LAZY()) {
+		SET_PMU_OWNER(owner);
+		return;
+	}
=20
 	/*
 	 * XXX needs further optimization.
 	 * Also must take holes into account
 	 */
-	for (i=3D0; i< pmu_conf.num_pmds; i++) {
-		t->pmd[i] =3D ia64_get_pmd(i);
+	mask =3D ctx->ctx_used_pmds[0];
+	for (i=3D0; mask; i++, mask>>=3D1) {
+		if (mask & 0x1) t->pmd[i] =3Dia64_get_pmd(i);
 	}
=20
 	/* skip PMC[0], we handle it separately */
-	for (i=3D1; i< pmu_conf.num_pmcs; i++) {
-		t->pmc[i] =3D ia64_get_pmc(i);
+	mask =3D ctx->ctx_used_pmcs[0]>>1;
+	for (i=3D1; mask; i++, mask>>=3D1) {
+		if (mask & 0x1) t->pmc[i] =3D ia64_get_pmc(i);
 	}
-
 	/*
 	 * Throughout this code we could have gotten an overflow interrupt. It is=
 transformed
 	 * into a spurious interrupt as soon as we give up pmu ownership.
 	 */
 }
=20
-void
-pfm_load_regs (struct task_struct *ta)
+static void
+pfm_lazy_save_regs (struct task_struct *ta)
 {
-	struct thread_struct *t =3D &ta->thread;
-	pfm_context_t *ctx =3D ta->thread.pfm_context;
+	pfm_context_t *ctx;
+	struct thread_struct *t;
+	unsigned long mask;
 	int i;
=20
+	DBprintk(("  on [%d] by [%d]\n", ta->pid, current->pid));
+
+	t   =3D &ta->thread;
+	ctx =3D ta->thread.pfm_context;
 	/*
 	 * XXX needs further optimization.
 	 * Also must take holes into account
 	 */
-	for (i=3D0; i< pmu_conf.num_pmds; i++) {
-		ia64_set_pmd(i, t->pmd[i]);
+	mask =3D ctx->ctx_used_pmds[0];
+	for (i=3D0; mask; i++, mask>>=3D1) {
+		if (mask & 0x1) t->pmd[i] =3Dia64_get_pmd(i);
 	}
-
-	/* skip PMC[0] to avoid side effects */
-	for (i=3D1; i< pmu_conf.num_pmcs; i++) {
-		ia64_set_pmc(i, t->pmc[i]);
+=09
+	/* skip PMC[0], we handle it separately */
+	mask =3D ctx->ctx_used_pmcs[0]>>1;
+	for (i=3D1; mask; i++, mask>>=3D1) {
+		if (mask & 0x1) t->pmc[i] =3D ia64_get_pmc(i);
 	}
+	SET_PMU_OWNER(NULL);
+}
+
+void
+pfm_load_regs (struct task_struct *ta)
+{
+	struct thread_struct *t =3D &ta->thread;
+	pfm_context_t *ctx =3D ta->thread.pfm_context;
+	struct task_struct *owner;
+	unsigned long mask;
+	int i;
+
+	owner =3D PMU_OWNER();
+	if (owner =3D ta) goto skip_restore;
+	if (owner) pfm_lazy_save_regs(owner);
=20
-	/*
-	 * we first restore ownership of the PMU to the 'soon to be current'
-	 * context. This way, if, as soon as we unfreeze the PMU at the end
-	 * of this function, we get an interrupt, we attribute it to the correct
-	 * task
-	 */
 	SET_PMU_OWNER(ta);
=20
-#if 0
-	/*
-	 * check if we had pending overflow before context switching out
-	 * If so, we invoke the handler manually, i.e. simulate interrupt.
-	 *
-	 * XXX: given that we do not use the tasklet anymore to stop, we can
-	 * move this back to the pfm_save_regs() routine.
-	 */
-	if (t->pmc[0] & ~0x1) {
-		/* freeze set in pfm_save_regs() */
-		DBprintk((" pmc[0]=3D0x%lx manual interrupt\n",t->pmc[0]));
-		update_counters(ta, t->pmc[0], NULL);
+	mask =3D ctx->ctx_used_pmds[0];
+	for (i=3D0; mask; i++, mask>>=3D1) {
+		if (mask & 0x1) ia64_set_pmd(i, t->pmd[i]);
 	}
-#endif
=20
+	/* skip PMC[0] to avoid side effects */
+	mask =3D ctx->ctx_used_pmcs[0]>>1;
+	for (i=3D1; mask; i++, mask>>=3D1) {
+		if (mask & 0x1) ia64_set_pmc(i, t->pmc[i]);
+	}
+skip_restore:
 	/*
 	 * unfreeze only when possible
 	 */
 	if (ctx->ctx_fl_frozen =3D 0) {
 		ia64_set_pmc(0, 0);
 		ia64_srlz_d();
+		/* place where we potentially (kernel level) start monitoring again */
 	}
 }
=20
@@ -2002,7 +2193,7 @@
=20
 	/* clears all PMD registers */
 	for(i=3D0;i< pmu_conf.num_pmds; i++) {
-		if (PMD_IS_IMPL(i)) ia64_set_pmd(i,0);
+		if (PMD_IS_IMPL(i))  ia64_set_pmd(i,0);
 	}
 	ia64_srlz_d();
 }
@@ -2011,7 +2202,7 @@
  * task is the newly created task
  */
 int
-pfm_inherit(struct task_struct *task)
+pfm_inherit(struct task_struct *task, struct pt_regs *regs)
 {
 	pfm_context_t *ctx =3D current->thread.pfm_context;
 	pfm_context_t *nctx;
@@ -2019,12 +2210,22 @@
 	int i, cnum;
=20
 	/*
+	 * bypass completely for system wide
+	 */
+	if (pfs_info.pfs_sys_session) {
+		DBprintk((" enabling psr.pp for %d\n", task->pid));
+		ia64_psr(regs)->pp =3D pfs_info.pfs_pp;
+		return 0;
+	}
+
+	/*
 	 * takes care of easiest case first
 	 */
 	if (CTX_INHERIT_MODE(ctx) =3D PFM_FL_INHERIT_NONE) {
 		DBprintk((" removing PFM context for %d\n", task->pid));
 		task->thread.pfm_context     =3D NULL;
-		task->thread.pfm_pend_notify =3D 0;
+		task->thread.pfm_must_block  =3D 0;
+		atomic_set(&task->thread.pfm_notifiers_check, 0);
 		/* copy_thread() clears IA64_THREAD_PM_VALID */
 		return 0;
 	}
@@ -2034,9 +2235,11 @@
 	/* copy content */
 	*nctx =3D *ctx;
=20
-	if (ctx->ctx_fl_inherit =3D PFM_FL_INHERIT_ONCE) {
+	if (CTX_INHERIT_MODE(ctx) =3D PFM_FL_INHERIT_ONCE) {
 		nctx->ctx_fl_inherit =3D PFM_FL_INHERIT_NONE;
+		atomic_set(&task->thread.pfm_notifiers_check, 0);
 		DBprintk((" downgrading to INHERIT_NONE for %d\n", task->pid));
+		pfs_info.pfs_proc_sessions++;
 	}
=20
 	/* initialize counters in new context */
@@ -2058,7 +2261,7 @@
 	sema_init(&nctx->ctx_restart_sem, 0); /* reset this semaphore to locked */
=20
 	/* clear pending notification */
-	th->pfm_pend_notify =3D 0;
+	th->pfm_must_block =3D 0;
=20
 	/* link with new task */
 	th->pfm_context     =3D nctx;
@@ -2077,7 +2280,10 @@
 	return 0;
 }
=20
-/* called from exit_thread() */
+/*=20
+ * called from release_thread(), at this point this task is not in the=20
+ * tasklist anymore
+ */
 void
 pfm_context_exit(struct task_struct *task)
 {
@@ -2093,16 +2299,126 @@
 		pfm_smpl_buffer_desc_t *psb =3D ctx->ctx_smpl_buf;
=20
 		/* if only user left, then remove */
-		DBprintk((" pid %d: task %d sampling psb->refcnt=3D%d\n", current->pid, =
task->pid, psb->psb_refcnt.counter));
+		DBprintk((" [%d] [%d] psb->refcnt=3D%d\n", current->pid, task->pid, psb-=
>psb_refcnt.counter));
=20
 		if (atomic_dec_and_test(&psb->psb_refcnt) ) {
 			rvfree(psb->psb_hdr, psb->psb_size);
 			vfree(psb);
-			DBprintk((" pid %d: cleaning task %d sampling buffer\n", current->pid, =
task->pid ));
+			DBprintk((" [%d] cleaning [%d] sampling buffer\n", current->pid, task->=
pid ));
+		}
+	}
+	DBprintk((" [%d] cleaning [%d] pfm_context @%p\n", current->pid, task->pi=
d, (void *)ctx));
+
+	/*
+	 * To avoid getting the notified task scan the entire process list
+	 * when it exits because it would have pfm_notifiers_check set, we=20
+	 * decrease it by 1 to inform the task, that one less task is going
+	 * to send it notification. each new notifer increases this field by
+	 * 1 in pfm_context_create(). Of course, there is race condition between
+	 * decreasing the value and the notified task exiting. The danger comes
+	 * from the fact that we have a direct pointer to its task structure
+	 * thereby bypassing the tasklist. We must make sure that if we have=20
+	 * notify_task!=3D NULL, the target task is still somewhat present. It may
+	 * already be detached from the tasklist but that's okay. Note that it is
+	 * okay if we 'miss the deadline' and the task scans the list for nothing,
+	 * it will affect performance but not correctness. The correctness is ens=
ured
+	 * by using the notify_lock whic prevents the notify_task from changing o=
n us.
+	 * Once holdhing this lock, if we see notify_task!=3D NULL, then it will =
stay like
+	 * that until we release the lock. If it is NULL already then we came too=
 late.
+	 */
+	spin_lock(&ctx->ctx_notify_lock);
+
+	if (ctx->ctx_notify_task) {
+		DBprintk((" [%d] [%d] atomic_sub on [%d] notifiers=3D%u\n", current->pid=
, task->pid,
+					ctx->ctx_notify_task->pid,=20
+					atomic_read(&ctx->ctx_notify_task->thread.pfm_notifiers_check)));
+
+		atomic_sub(1, &ctx->ctx_notify_task->thread.pfm_notifiers_check);
+	}
+
+	spin_unlock(&ctx->ctx_notify_lock);
+
+	if (ctx->ctx_fl_system) {
+		/*
+		 * if included interrupts (true by default), then reset
+		 * to get default value
+		 */
+		if (ctx->ctx_fl_exclintr =3D 0) {
+			/*
+			 * reload kernel default DCR value
+			 */
+			ia64_set_dcr(pfs_info.pfs_dfl_dcr);
+			DBprintk((" restored dcr to 0x%lx\n", pfs_info.pfs_dfl_dcr));
 		}
+		/*=20
+		 * free system wide session slot
+		 */
+		pfs_info.pfs_sys_session =3D 0;
+	} else {
+		pfs_info.pfs_proc_sessions--;
 	}
-	DBprintk((" pid %d: task %d pfm_context is freed @%p\n", current->pid, ta=
sk->pid, (void *)ctx));
+
 	pfm_context_free(ctx);
+	/*=20
+	 *  clean pfm state in thread structure,
+	 */
+	task->thread.pfm_context    =3D NULL;
+	task->thread.pfm_must_block =3D 0;
+	/* pfm_notifiers is cleaned in pfm_cleanup_notifiers() */
+
+}
+
+void
+pfm_cleanup_notifiers(struct task_struct *task)
+{
+	struct task_struct *p;
+	pfm_context_t *ctx;
+
+	DBprintk((" [%d] called\n", task->pid));
+
+	read_lock(&tasklist_lock);
+
+	for_each_task(p) {
+		/*
+		 * It is safe to do the 2-step test here, because thread.ctx
+		 * is cleaned up only in release_thread() and at that point
+		 * the task has been detached from the tasklist which is an
+		 * operation which uses the write_lock() on the tasklist_lock
+		 * so it cannot run concurrently to this loop. So we have the
+		 * guarantee that if we find p and it has a perfmon ctx then
+		 * it is going to stay like this for the entire execution of this
+		 * loop.
+		 */
+		ctx =3D p->thread.pfm_context;
+
+		DBprintk((" [%d] scanning task [%d] ctx=3D%p\n", task->pid, p->pid, ctx)=
);
+
+		if (ctx && ctx->ctx_notify_task =3D task) {
+			DBprintk((" trying for notifier %d in %d\n", task->pid, p->pid));
+			/*
+			 * the spinlock is required to take care of a race condition
+			 * with the send_sig_info() call. We must make sure that=20
+			 * either the send_sig_info() completes using a valid task,
+			 * or the notify_task is cleared before the send_sig_info()
+			 * can pick up a stale value. Note that by the time this
+			 * function is executed the 'task' is already detached from the
+			 * tasklist. The problem is that the notifiers have a direct
+			 * pointer to it. It is okay to send a signal to a task in this
+			 * stage, it simply will have no effect. But it is better than sending
+			 * to a completely destroyed task or worse to a new task using the same
+			 * task_struct address.
+			 */
+			spin_lock(&ctx->ctx_notify_lock);
+
+			ctx->ctx_notify_task =3D NULL;
+
+			spin_unlock(&ctx->ctx_notify_lock);
+
+			DBprintk((" done for notifier %d in %d\n", task->pid, p->pid));
+		}
+	}
+	read_unlock(&tasklist_lock);
+
 }
=20
 #else /* !CONFIG_PERFMON */
diff -urN linux-davidm/arch/ia64/kernel/process.c linux-2.4.10-lia/arch/ia6=
4/kernel/process.c
--- linux-davidm/arch/ia64/kernel/process.c	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/process.c	Mon Sep 24 23:22:59 2001
@@ -63,7 +63,8 @@
 {
 	unsigned long ip =3D regs->cr_iip + ia64_psr(regs)->ri;
=20
-	printk("\npsr : %016lx ifs : %016lx ip  : [<%016lx>]\n",
+	printk("\nPid: %d, comm: %20s\n", current->pid, current->comm);
+	printk("psr : %016lx ifs : %016lx ip  : [<%016lx>]\n",
 	       regs->cr_ipsr, regs->cr_ifs, ip);
 	printk("unat: %016lx pfs : %016lx rsc : %016lx\n",
 	       regs->ar_unat, regs->ar_pfs, regs->ar_rsc);
@@ -201,7 +202,7 @@
 {
 	unsigned long rbs, child_rbs, rbs_size, stack_offset, stack_top, stack_us=
ed;
 	struct switch_stack *child_stack, *stack;
-	extern char ia64_ret_from_clone;
+	extern char ia64_ret_from_clone, ia32_ret_from_clone;
 	struct pt_regs *child_ptregs;
 	int retval =3D 0;
=20
@@ -250,7 +251,10 @@
 		child_ptregs->r12 =3D (unsigned long) (child_ptregs + 1); /* kernel sp */
 		child_ptregs->r13 =3D (unsigned long) p;		/* set `current' pointer */
 	}
-	child_stack->b0 =3D (unsigned long) &ia64_ret_from_clone;
+	if (IS_IA32_PROCESS(regs))
+		child_stack->b0 =3D (unsigned long) &ia32_ret_from_clone;
+	else
+		child_stack->b0 =3D (unsigned long) &ia64_ret_from_clone;
 	child_stack->ar_bspstore =3D child_rbs + rbs_size;
=20
 	/* copy parts of thread_struct: */
@@ -285,9 +289,8 @@
 		ia32_save_state(p);
 #endif
 #ifdef CONFIG_PERFMON
-	p->thread.pfm_pend_notify =3D 0;
 	if (p->thread.pfm_context)
-		retval =3D pfm_inherit(p);
+		retval =3D pfm_inherit(p, child_ptregs);
 #endif
 	return retval;
 }
@@ -441,11 +444,24 @@
 }
=20
 #ifdef CONFIG_PERFMON
+/*
+ * By the time we get here, the task is detached from the tasklist. This i=
s important
+ * because it means that no other tasks can ever find it as a notifiied ta=
sk, therfore
+ * there is no race condition between this code and let's say a pfm_contex=
t_create().
+ * Conversely, the pfm_cleanup_notifiers() cannot try to access a task's p=
fm context if
+ * this other task is in the middle of its own pfm_context_exit() because =
it would alreayd
+ * be out of the task list. Note that this case is very unlikely between a=
 direct child
+ * and its parents (if it is the notified process) because of the way the =
exit is notified
+ * via SIGCHLD.
+ */
 void
 release_thread (struct task_struct *task)
 {
 	if (task->thread.pfm_context)
 		pfm_context_exit(task);
+
+	if(atomic_read(&task->thread.pfm_notifiers_check) >0)
+		pfm_cleanup_notifiers(task);
 }
 #endif
=20
@@ -524,6 +540,10 @@
 void
 machine_halt (void)
 {
+#if 0
+	while (1)
+		ia64_pal_halt(0);
+#endif
 }
=20
 void
diff -urN linux-davidm/arch/ia64/kernel/ptrace.c linux-2.4.10-lia/arch/ia64=
/kernel/ptrace.c
--- linux-davidm/arch/ia64/kernel/ptrace.c	Mon Sep 24 15:06:13 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/ptrace.c	Mon Sep 24 21:51:40 2001
@@ -2,7 +2,7 @@
  * Kernel support for the ptrace() and syscall tracing interfaces.
  *
  * Copyright (C) 1999-2001 Hewlett-Packard Co
- * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * Derived from the x86 and Alpha versions.  Most of the code in here
  * could actually be factored into a common set of routines.
@@ -794,11 +794,14 @@
  *
  * Make sure the single step bit is not set.
  */
-void ptrace_disable(struct task_struct *child)
+void
+ptrace_disable (struct task_struct *child)
 {
+	struct ia64_psr *child_psr =3D ia64_psr(ia64_task_regs(child));
+
 	/* make sure the single step/take-branch tra bits are not set: */
-	ia64_psr(pt)->ss =3D 0;
-	ia64_psr(pt)->tb =3D 0;
+	child_psr->ss =3D 0;
+	child_psr->tb =3D 0;
=20
 	/* Turn off flag indicating that the KRBS is sync'd with child's VM: */
 	child->thread.flags &=3D ~IA64_THREAD_KRBS_SYNCED;
@@ -855,6 +858,19 @@
 	if (child->p_pptr !=3D current)
 		goto out_tsk;
=20
+	if (request !=3D PTRACE_KILL) {
+		if (child->state !=3D TASK_STOPPED)
+			goto out_tsk;
+
+#ifdef CONFIG_SMP
+		while (child->has_cpu) {
+			if (child->state !=3D TASK_STOPPED)
+				goto out_tsk;
+			barrier();
+		}
+#endif
+	}
+
 	pt =3D ia64_task_regs(child);
 	sw =3D (struct switch_stack *) (child->thread.ksp + 16);
=20
@@ -925,7 +941,7 @@
 			child->ptrace &=3D ~PT_TRACESYS;
 		child->exit_code =3D data;
=20
-		/* make sure the single step/take-branch tra bits are not set: */
+		/* make sure the single step/taken-branch trap bits are not set: */
 		ia64_psr(pt)->ss =3D 0;
 		ia64_psr(pt)->tb =3D 0;
=20
diff -urN linux-davidm/arch/ia64/kernel/sal.c linux-2.4.10-lia/arch/ia64/ke=
rnel/sal.c
--- linux-davidm/arch/ia64/kernel/sal.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/sal.c	Mon Sep 24 21:51:59 2001
@@ -2,7 +2,7 @@
  * System Abstraction Layer (SAL) interface routines.
  *
  * Copyright (C) 1998, 1999, 2001 Hewlett-Packard Co
- * Copyright (C) 1998, 1999, 2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
  */
@@ -18,8 +18,6 @@
 #include <asm/sal.h>
 #include <asm/pal.h>
=20
-#define SAL_DEBUG
-
 spinlock_t sal_lock =3D SPIN_LOCK_UNLOCKED;
=20
 static struct {
@@ -122,10 +120,8 @@
 		switch (*p) {
 		      case SAL_DESC_ENTRY_POINT:
 			ep =3D (struct ia64_sal_desc_entry_point *) p;
-#ifdef SAL_DEBUG
-			printk("sal[%d] - entry: pal_proc=3D0x%lx, sal_proc=3D0x%lx\n",
-			       i, ep->pal_proc, ep->sal_proc);
-#endif
+			printk("SAL: entry: pal_proc=3D0x%lx, sal_proc=3D0x%lx\n",
+			       ep->pal_proc, ep->sal_proc);
 			ia64_pal_handler_init(__va(ep->pal_proc));
 			ia64_sal_handler_init(__va(ep->sal_proc), __va(ep->gp));
 			break;
@@ -138,17 +134,12 @@
 #ifdef CONFIG_SMP
 		      {
 			      struct ia64_sal_desc_ap_wakeup *ap =3D (void *) p;
-# ifdef SAL_DEBUG
-			      printk("sal[%d] - wakeup type %x, 0x%lx\n",
-				     i, ap->mechanism, ap->vector);
-# endif
+
 			      switch (ap->mechanism) {
 				    case IA64_SAL_AP_EXTERNAL_INT:
 				      ap_wakeup_vector =3D ap->vector;
-# ifdef SAL_DEBUG
 				      printk("SAL: AP wakeup using external interrupt "
 					     "vector 0x%lx\n", ap_wakeup_vector);
-# endif
 				      break;
=20
 				    default:
@@ -169,7 +160,7 @@
 			      if (pf->feature_mask & (1 << 1)) {
 				      printk("IRQ_Redirection ");
 #ifdef CONFIG_SMP
-				      if (no_int_routing)=20
+				      if (no_int_routing)
 					      smp_int_redirect &=3D ~SMP_IRQ_REDIRECTION;
 				      else
 					      smp_int_redirect |=3D SMP_IRQ_REDIRECTION;
diff -urN linux-davidm/arch/ia64/kernel/setup.c linux-2.4.10-lia/arch/ia64/=
kernel/setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/setup.c	Mon Sep 24 21:52:16 2001
@@ -534,10 +534,13 @@
 	/*
 	 * Initialize default control register to defer all speculative faults.  =
The
 	 * kernel MUST NOT depend on a particular setting of these bits (in other=
 words,
-	 * the kernel must have recovery code for all speculative accesses).
+	 * the kernel must have recovery code for all speculative accesses).  Tur=
n on
+	 * dcr.lc as per recommendation by the architecture team.  Most IA-32 apps
+	 * shouldn't be affected by this (moral: keep your ia32 locks aligned and=
 you'll
+	 * be fine).
 	 */
 	ia64_set_dcr(  IA64_DCR_DM | IA64_DCR_DP | IA64_DCR_DK | IA64_DCR_DX | IA=
64_DCR_DR
-		     | IA64_DCR_DA | IA64_DCR_DD);
+		     | IA64_DCR_DA | IA64_DCR_DD | IA64_DCR_LC);
 #ifndef CONFIG_SMP
 	ia64_set_fpu_owner(0);
 #endif
diff -urN linux-davidm/arch/ia64/kernel/sigframe.h linux-2.4.10-lia/arch/ia=
64/kernel/sigframe.h
--- linux-davidm/arch/ia64/kernel/sigframe.h	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/sigframe.h	Mon Sep 24 21:52:26 2001
@@ -7,10 +7,11 @@
 	unsigned long arg0;		/* signum */
 	unsigned long arg1;		/* siginfo pointer */
 	unsigned long arg2;		/* sigcontext pointer */
+	/*
+	 * End of architected state.
+	 */
=20
-	unsigned long rbs_base;		/* base of new register backing store (or NULL) =
*/
 	void *handler;			/* pointer to the plabel of the signal handler */
-
 	struct siginfo info;
 	struct sigcontext sc;
 };
diff -urN linux-davidm/arch/ia64/kernel/signal.c linux-2.4.10-lia/arch/ia64=
/kernel/signal.c
--- linux-davidm/arch/ia64/kernel/signal.c	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/signal.c	Mon Sep 24 21:52:38 2001
@@ -139,10 +139,9 @@
 		struct ia64_psr *psr =3D ia64_psr(&scr->pt);
=20
 		__copy_from_user(current->thread.fph, &sc->sc_fr[32], 96*16);
-		if (!psr->dfh) {
-			psr->mfh =3D 0;
+		psr->mfh =3D 0;	/* drop signal handler's fph contents... */
+		if (!psr->dfh)
 			__ia64_load_fpu(current->thread.fph);
-		}
 	}
 	return err;
 }
@@ -380,7 +379,8 @@
 	err  =3D __put_user(sig, &frame->arg0);
 	err |=3D __put_user(&frame->info, &frame->arg1);
 	err |=3D __put_user(&frame->sc, &frame->arg2);
-	err |=3D __put_user(new_rbs, &frame->rbs_base);
+	err |=3D __put_user(new_rbs, &frame->sc.sc_rbs_base);
+	err |=3D __put_user(0, &frame->sc.sc_loadrs);	/* initialize to zero */
 	err |=3D __put_user(ka->sa.sa_handler, &frame->handler);
=20
 	err |=3D copy_siginfo_to_user(&frame->info, info);
@@ -460,6 +460,7 @@
 long
 ia64_do_signal (sigset_t *oldset, struct sigscratch *scr, long in_syscall)
 {
+	struct signal_struct *sig;
 	struct k_sigaction *ka;
 	siginfo_t info;
 	long restart =3D in_syscall;
@@ -571,8 +572,8 @@
 			      case SIGSTOP:
 				current->state =3D TASK_STOPPED;
 				current->exit_code =3D signr;
-				if (!(current->p_pptr->sig->action[SIGCHLD-1].sa.sa_flags
-				      & SA_NOCLDSTOP))
+				sig =3D current->p_pptr->sig;
+				if (sig && !(sig->action[SIGCHLD-1].sa.sa_flags & SA_NOCLDSTOP))
 					notify_parent(current, SIGCHLD);
 				schedule();
 				continue;
diff -urN linux-davidm/arch/ia64/kernel/smp.c linux-2.4.10-lia/arch/ia64/ke=
rnel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/smp.c	Mon Sep 24 21:53:18 2001
@@ -222,8 +222,9 @@
 		atomic_set(&data.finished, 0);
=20
 	spin_lock_bh(&call_lock);
-	call_data =3D &data;
=20
+	call_data =3D &data;
+	mb();	/* ensure store to call_data precedes setting of IPI_CALL_FUNC */
   	send_IPI_single(cpuid, IPI_CALL_FUNC);
=20
 	/* Wait for response */
@@ -275,8 +276,9 @@
 		atomic_set(&data.finished, 0);
=20
 	spin_lock_bh(&call_lock);
-	call_data =3D &data;
=20
+	call_data =3D &data;
+	mb();	/* ensure store to call_data precedes setting of IPI_CALL_FUNC */
 	send_IPI_allbutself(IPI_CALL_FUNC);
=20
 	/* Wait for response */
diff -urN linux-davidm/arch/ia64/kernel/smpboot.c linux-2.4.10-lia/arch/ia6=
4/kernel/smpboot.c
--- linux-davidm/arch/ia64/kernel/smpboot.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/smpboot.c	Mon Sep 24 21:53:33 2001
@@ -33,6 +33,7 @@
 #include <asm/io.h>
 #include <asm/irq.h>
 #include <asm/machvec.h>
+#include <asm/mca.h>
 #include <asm/page.h>
 #include <asm/pgalloc.h>
 #include <asm/pgtable.h>
@@ -42,6 +43,8 @@
 #include <asm/system.h>
 #include <asm/unistd.h>
=20
+#define SMP_DEBUG 0
+
 #if SMP_DEBUG
 #define Dprintk(x...)  printk(x)
 #else
@@ -310,7 +313,7 @@
 }
=20
=20
-void __init
+static void __init
 smp_callin (void)
 {
 	int cpuid, phys_id;
@@ -369,14 +372,15 @@
 {
 	extern int cpu_idle (void);
=20
+	Dprintk("start_secondary: starting CPU 0x%x\n", hard_smp_processor_id());
 	efi_map_pal_code();
 	cpu_init();
 	smp_callin();
-	Dprintk("CPU %d is set to go. \n", smp_processor_id());
+	Dprintk("CPU %d is set to go.\n", smp_processor_id());
 	while (!atomic_read(&smp_commenced))
 		;
=20
-	Dprintk("CPU %d is starting idle. \n", smp_processor_id());
+	Dprintk("CPU %d is starting idle.\n", smp_processor_id());
 	return cpu_idle();
 }
=20
@@ -420,7 +424,7 @@
 	unhash_process(idle);
 	init_tasks[cpu] =3D idle;
=20
-	Dprintk("Sending Wakeup Vector to AP 0x%x/0x%x.\n", cpu, sapicid);
+	Dprintk("Sending wakeup vector %u to AP 0x%x/0x%x.\n", ap_wakeup_vector, =
cpu, sapicid);
=20
 	platform_send_ipi(cpu, ap_wakeup_vector, IA64_IPI_DM_INT, 0);
=20
@@ -429,7 +433,6 @@
 	 */
 	Dprintk("Waiting on callin_map ...");
 	for (timeout =3D 0; timeout < 100000; timeout++) {
-		Dprintk(".");
 		if (test_bit(cpu, &cpu_callin_map))
 			break;  /* It has booted */
 		udelay(100);
diff -urN linux-davidm/arch/ia64/kernel/sys_ia64.c linux-2.4.10-lia/arch/ia=
64/kernel/sys_ia64.c
--- linux-davidm/arch/ia64/kernel/sys_ia64.c	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/sys_ia64.c	Mon Sep 24 21:53:53 2001
@@ -19,24 +19,29 @@
 #include <asm/shmparam.h>
 #include <asm/uaccess.h>
=20
-#define COLOR_ALIGN(addr)	(((addr) + SHMLBA - 1) & ~(SHMLBA - 1))
-
 unsigned long
 arch_get_unmapped_area (struct file *filp, unsigned long addr, unsigned lo=
ng len,
 			unsigned long pgoff, unsigned long flags)
 {
-	struct vm_area_struct * vmm;
 	long map_shared =3D (flags & MAP_SHARED);
+	unsigned long align_mask =3D PAGE_SIZE - 1;
+	struct vm_area_struct * vmm;
=20
 	if (len > RGN_MAP_LIMIT)
 		return -ENOMEM;
 	if (!addr)
 		addr =3D TASK_UNMAPPED_BASE;
=20
-	if (map_shared)
-		addr =3D COLOR_ALIGN(addr);
-	else
-		addr =3D PAGE_ALIGN(addr);
+	if (map_shared && (TASK_SIZE > 0xfffffffful))
+		/*
+		 * For 64-bit tasks, align shared segments to 1MB to avoid potential
+		 * performance penalty due to virtual aliasing (see ASDM).  For 32-bit
+		 * tasks, we prefer to avoid exhausting the address space too quickly by
+		 * limiting alignment to a single page.
+		 */
+		align_mask =3D SHMLBA - 1;
+
+	addr =3D (addr + align_mask) & ~align_mask;
=20
 	for (vmm =3D find_vma(current->mm, addr); ; vmm =3D vmm->vm_next) {
 		/* At this point:  (!vmm || addr < vmm->vm_end). */
@@ -46,9 +51,7 @@
 			return -ENOMEM;
 		if (!vmm || addr + len <=3D vmm->vm_start)
 			return addr;
-		addr =3D vmm->vm_end;
-		if (map_shared)
-			addr =3D COLOR_ALIGN(addr);
+		addr =3D (vmm->vm_end + align_mask) & ~align_mask;
 	}
 }
=20
@@ -184,8 +187,10 @@
 		if (!file)
 			return -EBADF;
=20
-		if (!file->f_op || !file->f_op->mmap)
-			return -ENODEV;
+		if (!file->f_op || !file->f_op->mmap) {
+			addr =3D -ENODEV;
+			goto out;
+		}
 	}
=20
 	/*
@@ -194,22 +199,26 @@
 	 */
 	len =3D PAGE_ALIGN(len);
 	if (len =3D 0)
-		return addr;
+		goto out;
=20
 	/* don't permit mappings into unmapped space or the virtual page table of=
 a region: */
 	roff =3D rgn_offset(addr);
-	if ((len | roff | (roff + len)) >=3D RGN_MAP_LIMIT)
-		return -EINVAL;
+	if ((len | roff | (roff + len)) >=3D RGN_MAP_LIMIT) {
+		addr =3D -EINVAL;
+		goto out;
+	}
=20
 	/* don't permit mappings that would cross a region boundary: */
-	if (rgn_index(addr) !=3D rgn_index(addr + len))
-		return -EINVAL;
+	if (rgn_index(addr) !=3D rgn_index(addr + len)) {
+		addr =3D -EINVAL;
+		goto out;
+	}
=20
 	down_write(&current->mm->mmap_sem);
 	addr =3D do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
 	up_write(&current->mm->mmap_sem);
=20
-	if (file)
+out:	if (file)
 		fput(file);
 	return addr;
 }
diff -urN linux-davidm/arch/ia64/kernel/traps.c linux-2.4.10-lia/arch/ia64/=
kernel/traps.c
--- linux-davidm/arch/ia64/kernel/traps.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/traps.c	Mon Sep 24 21:54:49 2001
@@ -2,7 +2,7 @@
  * Architecture-specific trap handling.
  *
  * Copyright (C) 1998-2001 Hewlett-Packard Co
- * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * 05/12/00 grao <goutham.rao@intel.com> : added isr in siginfo for SIGFPE
  */
@@ -32,13 +32,17 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/sched.h>
+#include <linux/vt_kern.h>		/* For unblank_screen() */
=20
+#include <asm/hardirq.h>
 #include <asm/ia32.h>
 #include <asm/processor.h>
 #include <asm/uaccess.h>
=20
 #include <asm/fpswa.h>
=20
+extern spinlock_t timerlist_lock;
+
 static fpswa_interface_t *fpswa_interface;
=20
 void __init
@@ -50,22 +54,48 @@
 		fpswa_interface =3D __va(ia64_boot_param->fpswa);
 }
=20
+/*
+ * Unlock any spinlocks which will prevent us from getting the message out=
 (timerlist_lock
+ * is acquired through the console unblank code)
+ */
 void
-die_if_kernel (char *str, struct pt_regs *regs, long err)
+bust_spinlocks (int yes)
 {
-	if (user_mode(regs)) {
-#if 0
-		/* XXX for debugging only */
-		printk ("!!die_if_kernel: %s(%d): %s %ld\n",
-			current->comm, current->pid, str, err);
-		show_regs(regs);
+	spin_lock_init(&timerlist_lock);
+	if (yes) {
+		oops_in_progress =3D 1;
+#ifdef CONFIG_SMP
+		global_irq_lock =3D 0;	/* Many serial drivers do __global_cli() */
 #endif
-		return;
+	} else {
+		int loglevel_save =3D console_loglevel;
+#ifdef CONFIG_VT
+		unblank_screen();
+#endif
+		oops_in_progress =3D 0;
+		/*
+		 * OK, the message is on the console.  Now we call printk() without
+		 * oops_in_progress set so that printk will give klogd a poke.  Hold onto
+		 * your hats...
+		 */
+		console_loglevel =3D 15;		/* NMI oopser may have shut the console up */
+		printk(" ");
+		console_loglevel =3D loglevel_save;
 	}
+}
=20
-	printk("%s[%d]: %s %ld\n", current->comm, current->pid, str, err);
+void
+die (const char *str, struct pt_regs *regs, long err)
+{
+	static spinlock_t die_lock =3D SPIN_LOCK_UNLOCKED;
=20
+	console_verbose();
+	spin_lock_irq(&die_lock);
+	bust_spinlocks(1);
+	printk("%s[%d]: %s %ld\n", current->comm, current->pid, str, err);
 	show_regs(regs);
+	bust_spinlocks(0);
+	spin_unlock_irq(&die_lock);
=20
 	if (current->thread.flags & IA64_KERNEL_DEATH) {
 		printk("die_if_kernel recursion detected.\n");
@@ -77,6 +107,13 @@
 }
=20
 void
+die_if_kernel (char *str, struct pt_regs *regs, long err)
+{
+	if (!user_mode(regs))
+		die(str, regs, err);
+}
+
+void
 ia64_bad_break (unsigned long break_num, struct pt_regs *regs)
 {
 	siginfo_t siginfo;
@@ -168,14 +205,12 @@
 }
=20
 /*
- * disabled_fph_fault() is called when a user-level process attempts
- * to access one of the registers f32..f127 when it doesn't own the
- * fp-high register partition.  When this happens, we save the current
- * fph partition in the task_struct of the fpu-owner (if necessary)
- * and then load the fp-high partition of the current task (if
- * necessary).  Note that the kernel has access to fph by the time we
- * get here, as the IVT's "Diabled FP-Register" handler takes care of
- * clearing psr.dfh.
+ * disabled_fph_fault() is called when a user-level process attempts to ac=
cess f32..f127
+ * and it doesn't own the fp-high register partition.  When this happens, =
we save the
+ * current fph partition in the task_struct of the fpu-owner (if necessary=
) and then load
+ * the fp-high partition of the current task (if necessary).  Note that th=
e kernel has
+ * access to fph by the time we get here, as the IVT's "Disabled FP-Regist=
er" handler takes
+ * care of clearing psr.dfh.
  */
 static inline void
 disabled_fph_fault (struct pt_regs *regs)
diff -urN linux-davidm/arch/ia64/kernel/unwind.c linux-2.4.10-lia/arch/ia64=
/kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/kernel/unwind.c	Mon Sep 24 21:55:01 2001
@@ -504,7 +504,7 @@
 	return 0;
 }
=20
-inline int
+int
 unw_access_pr (struct unw_frame_info *info, unsigned long *val, int write)
 {
 	unsigned long *addr;
diff -urN linux-davidm/arch/ia64/lib/clear_page.S linux-2.4.10-lia/arch/ia6=
4/lib/clear_page.S
--- linux-davidm/arch/ia64/lib/clear_page.S	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/lib/clear_page.S	Mon Sep 24 21:55:10 2001
@@ -47,5 +47,5 @@
 	br.cloop.dptk.few 1b
 	;;
 	mov ar.lc =3D r2		// restore lc
-	br.ret.sptk.few rp
+	br.ret.sptk.many rp
 END(clear_page)
diff -urN linux-davidm/arch/ia64/lib/clear_user.S linux-2.4.10-lia/arch/ia6=
4/lib/clear_user.S
--- linux-davidm/arch/ia64/lib/clear_user.S	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/lib/clear_user.S	Mon Sep 24 21:55:19 2001
@@ -8,7 +8,7 @@
  *	r8:	number of bytes that didn't get cleared due to a fault
  *
  * Copyright (C) 1998, 1999, 2001 Hewlett-Packard Co
- * Copyright (C) 1999 Stephane Eranian <eranian@hpl.hp.com>
+ *	Stephane Eranian <eranian@hpl.hp.com>
  */
=20
 #include <asm/asmmacro.h>
@@ -62,11 +62,11 @@
 	;;				// avoid WAW on CFM
 	adds tmp=3D-1,len			// br.ctop is repeat/until
 	mov ret0=3Dlen			// return value is length at this point
-(p6)	br.ret.spnt.few rp
+(p6)	br.ret.spnt.many rp
 	;;
 	cmp.lt p6,p0=16,len		// if len > 16 then long memset
 	mov ar.lc=3Dtmp			// initialize lc for small count
-(p6)	br.cond.dptk.few long_do_clear
+(p6)	br.cond.dptk .long_do_clear
 	;;				// WAR on ar.lc
 	//
 	// worst case 16 iterations, avg 8 iterations
@@ -79,7 +79,7 @@
 1:
 	EX( .Lexit1, st1 [buf]=3Dr0,1 )
 	adds len=3D-1,len			// countdown length using len
-	br.cloop.dptk.few 1b
+	br.cloop.dptk 1b
 	;;				// avoid RAW on ar.lc
 	//
 	// .Lexit4: comes from byte by byte loop
@@ -87,7 +87,7 @@
 .Lexit1:
 	mov ret0=3Dlen			// faster than using ar.lc
 	mov ar.lc=3Dsaved_lc
-	br.ret.sptk.few rp		// end of short clear_user
+	br.ret.sptk.many rp		// end of short clear_user
=20
=20
 	//
@@ -98,7 +98,7 @@
 	// instead of ret0 is due to the fact that the exception code
 	// changes the values of r8.
 	//
-long_do_clear:
+.long_do_clear:
 	tbit.nz p6,p0=3Dbuf,0		// odd alignment (for long_do_clear)
 	;;
 	EX( .Lexit3, (p6) st1 [buf]=3Dr0,1 )	// 1-byte aligned
@@ -119,7 +119,7 @@
 	;;
 	cmp.eq p6,p0=3Dr0,cnt
 	adds tmp=3D-1,cnt
-(p6)	br.cond.dpnt.few .dotail	// we have less than 16 bytes left
+(p6)	br.cond.dpnt .dotail		// we have less than 16 bytes left
 	;;
 	adds buf2=3D8,buf			// setup second base pointer
 	mov ar.lc=3Dtmp
@@ -148,7 +148,7 @@
 	;;				// needed to get len correct when error
 	st8 [buf2]=3Dr0,16
 	adds len=3D-16,len
-	br.cloop.dptk.few 2b
+	br.cloop.dptk 2b
 	;;
 	mov ar.lc=3Dsaved_lc
 	//
@@ -178,7 +178,7 @@
 	;;
 	EX( .Lexit2, (p7) st1 [buf]=3Dr0 )	// only 1 byte left
 	mov ret0=3Dr0				// success
-	br.ret.dptk.few rp			// end of most likely path
+	br.ret.sptk.many rp			// end of most likely path
=20
 	//
 	// Outlined error handling code
@@ -205,5 +205,5 @@
 .Lexit3:
 	mov ret0=3Dlen
 	mov ar.lc=3Dsaved_lc
-	br.ret.dptk.few rp
+	br.ret.sptk.many rp
 END(__do_clear_user)
diff -urN linux-davidm/arch/ia64/lib/copy_page.S linux-2.4.10-lia/arch/ia64=
/lib/copy_page.S
--- linux-davidm/arch/ia64/lib/copy_page.S	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/lib/copy_page.S	Mon Sep 24 21:55:37 2001
@@ -90,5 +90,5 @@
 	mov pr=3Dsaved_pr,0xffffffffffff0000	// restore predicates
 	mov ar.pfs=3Dsaved_pfs
 	mov ar.lc=3Dsaved_lc
-	br.ret.sptk.few rp
+	br.ret.sptk.many rp
 END(copy_page)
diff -urN linux-davidm/arch/ia64/lib/copy_user.S linux-2.4.10-lia/arch/ia64=
/lib/copy_user.S
--- linux-davidm/arch/ia64/lib/copy_user.S	Tue Jul 31 10:30:08 2001
+++ linux-2.4.10-lia/arch/ia64/lib/copy_user.S	Mon Sep 24 21:55:46 2001
@@ -19,8 +19,8 @@
  *	ret0	0 in case of success. The number of bytes NOT copied in
  *		case of error.
  *
- * Copyright (C) 2000 Hewlett-Packard Co
- * Copyright (C) 2000 Stephane Eranian <eranian@hpl.hp.com>
+ * Copyright (C) 2000-2001 Hewlett-Packard Co
+ *	Stephane Eranian <eranian@hpl.hp.com>
  *
  * Fixme:
  *	- handle the case where we have more than 16 bytes and the alignment
@@ -85,7 +85,7 @@
 	cmp.eq p8,p0=3Dr0,len	// check for zero length
 	.save ar.lc, saved_lc
 	mov saved_lc=3Dar.lc	// preserve ar.lc (slow)
-(p8)	br.ret.spnt.few rp	// empty mempcy()
+(p8)	br.ret.spnt.many rp	// empty mempcy()
 	;;
 	add enddst=3Ddst,len	// first byte after end of source
 	add endsrc=3Dsrc,len	// first byte after end of destination
@@ -103,26 +103,26 @@
 	cmp.lt p10,p7=3DCOPY_BREAK,len	// if len > COPY_BREAK then long copy
=20
 	xor tmp=3Dsrc,dst		// same alignment test prepare
-(p10)	br.cond.dptk.few long_copy_user
+(p10)	br.cond.dptk .long_copy_user
 	;;			// RAW pr.rot/p16 ?
 	//
 	// Now we do the byte by byte loop with software pipeline
 	//
 	// p7 is necessarily false by now
 1:
-	EX(failure_in_pipe1,(p16) ld1 val1[0]=3D[src1],1)
-	EX(failure_out,(EPI) st1 [dst1]=3Dval1[PIPE_DEPTH-1],1)
+	EX(.failure_in_pipe1,(p16) ld1 val1[0]=3D[src1],1)
+	EX(.failure_out,(EPI) st1 [dst1]=3Dval1[PIPE_DEPTH-1],1)
 	br.ctop.dptk.few 1b
 	;;
 	mov ar.lc=3Dsaved_lc
 	mov pr=3Dsaved_pr,0xffffffffffff0000
 	mov ar.pfs=3Dsaved_pfs		// restore ar.ec
-	br.ret.sptk.few rp	// end of short memcpy
+	br.ret.sptk.many rp		// end of short memcpy
=20
 	//
 	// Not 8-byte aligned
 	//
-diff_align_copy_user:
+.diff_align_copy_user:
 	// At this point we know we have more than 16 bytes to copy
 	// and also that src and dest do _not_ have the same alignment.
 	and src2=3D0x7,src1				// src offset
@@ -153,7 +153,7 @@
 	// We know src1 is not 8-byte aligned in this case.
 	//
 	cmp.eq p14,p15=3Dr0,dst2
-(p15)	br.cond.spnt.few 1f
+(p15)	br.cond.spnt 1f
 	;;
 	sub t1=3D8,src2
 	mov t2=3Dsrc2
@@ -163,7 +163,7 @@
 	;;
 	sub lshiftd,rshift
 	;;
-	br.cond.spnt.few word_copy_user
+	br.cond.spnt .word_copy_user
 	;;
 1:
 	cmp.leu	p14,p15=3Dsrc2,dst2
@@ -192,15 +192,15 @@
 	mov ar.lc=3Dcnt
 	;;
 2:
-	EX(failure_in_pipe2,(p16) ld1 val1[0]=3D[src1],1)
-	EX(failure_out,(EPI) st1 [dst1]=3Dval1[PIPE_DEPTH-1],1)
+	EX(.failure_in_pipe2,(p16) ld1 val1[0]=3D[src1],1)
+	EX(.failure_out,(EPI) st1 [dst1]=3Dval1[PIPE_DEPTH-1],1)
 	br.ctop.dptk.few 2b
 	;;
 	clrrrb
 	;;
-word_copy_user:
+.word_copy_user:
 	cmp.gtu p9,p0=16,len1
-(p9)	br.cond.spnt.few 4f		// if (16 > len1) skip 8-byte copy
+(p9)	br.cond.spnt 4f			// if (16 > len1) skip 8-byte copy
 	;;
 	shr.u cnt=3Dlen1,3		// number of 64-bit words
 	;;
@@ -232,24 +232,24 @@
 #define EPI_1		p[PIPE_DEPTH-2]
 #define SWITCH(pred, shift)	cmp.eq pred,p0=3Dshift,rshift
 #define CASE(pred, shift)	\
-	(pred)	br.cond.spnt.few copy_user_bit##shift
+	(pred)	br.cond.spnt .copy_user_bit##shift
 #define BODY(rshift)						\
-copy_user_bit##rshift:						\
+.copy_user_bit##rshift:						\
 1:								\
-	EX(failure_out,(EPI) st8 [dst1]=3Dtmp,8);			\
+	EX(.failure_out,(EPI) st8 [dst1]=3Dtmp,8);		\
 (EPI_1) shrp tmp=3Dval1[PIPE_DEPTH-3],val1[PIPE_DEPTH-2],rshift;	\
 	EX(3f,(p16) ld8 val1[0]=3D[src1],8);			\
-	br.ctop.dptk.few 1b;					\
+	br.ctop.dptk 1b;					\
 	;;							\
-	br.cond.sptk.few .diff_align_do_tail;			\
+	br.cond.sptk.many .diff_align_do_tail;			\
 2:								\
 (EPI)	st8 [dst1]=3Dtmp,8;					\
 (EPI_1)	shrp tmp=3Dval1[PIPE_DEPTH-3],val1[PIPE_DEPTH-2],rshift;	\
 3:								\
 (p16)	mov val1[0]=3Dr0;						\
-	br.ctop.dptk.few 2b;					\
+	br.ctop.dptk 2b;					\
 	;;							\
-	br.cond.sptk.few failure_in2
+	br.cond.sptk.many .failure_in2
=20
 	//
 	// Since the instruction 'shrp' requires a fixed 128-bit value
@@ -301,25 +301,25 @@
 	mov ar.lc=3Dlen1
 	;;
 5:
-	EX(failure_in_pipe1,(p16) ld1 val1[0]=3D[src1],1)
-	EX(failure_out,(EPI) st1 [dst1]=3Dval1[PIPE_DEPTH-1],1)
+	EX(.failure_in_pipe1,(p16) ld1 val1[0]=3D[src1],1)
+	EX(.failure_out,(EPI) st1 [dst1]=3Dval1[PIPE_DEPTH-1],1)
 	br.ctop.dptk.few 5b
 	;;
 	mov ar.lc=3Dsaved_lc
 	mov pr=3Dsaved_pr,0xffffffffffff0000
 	mov ar.pfs=3Dsaved_pfs
-	br.ret.dptk.few rp
+	br.ret.sptk.many rp
=20
 	//
 	// Beginning of long mempcy (i.e. > 16 bytes)
 	//
-long_copy_user:
+.long_copy_user:
 	tbit.nz p6,p7=3Dsrc1,0	// odd alignement
 	and tmp=3D7,tmp
 	;;
 	cmp.eq p10,p8=3Dr0,tmp
 	mov len1=3Dlen		// copy because of rotation
-(p8)	br.cond.dpnt.few diff_align_copy_user
+(p8)	br.cond.dpnt .diff_align_copy_user
 	;;
 	// At this point we know we have more than 16 bytes to copy
 	// and also that both src and dest have the same alignment
@@ -327,11 +327,11 @@
 	// forward slowly until we reach 16byte alignment: no need to
 	// worry about reaching the end of buffer.
 	//
-	EX(failure_in1,(p6) ld1 val1[0]=3D[src1],1)	// 1-byte aligned
+	EX(.failure_in1,(p6) ld1 val1[0]=3D[src1],1)	// 1-byte aligned
 (p6)	adds len1=3D-1,len1;;
 	tbit.nz p7,p0=3Dsrc1,1
 	;;
-	EX(failure_in1,(p7) ld2 val1[1]=3D[src1],2)	// 2-byte aligned
+	EX(.failure_in1,(p7) ld2 val1[1]=3D[src1],2)	// 2-byte aligned
 (p7)	adds len1=3D-2,len1;;
 	tbit.nz p8,p0=3Dsrc1,2
 	;;
@@ -339,28 +339,28 @@
 	// Stop bit not required after ld4 because if we fail on ld4
 	// we have never executed the ld1, therefore st1 is not executed.
 	//
-	EX(failure_in1,(p8) ld4 val2[0]=3D[src1],4)	// 4-byte aligned
+	EX(.failure_in1,(p8) ld4 val2[0]=3D[src1],4)	// 4-byte aligned
 	;;
-	EX(failure_out,(p6) st1 [dst1]=3Dval1[0],1)
+	EX(.failure_out,(p6) st1 [dst1]=3Dval1[0],1)
 	tbit.nz p9,p0=3Dsrc1,3
 	;;
 	//
 	// Stop bit not required after ld8 because if we fail on ld8
 	// we have never executed the ld2, therefore st2 is not executed.
 	//
-	EX(failure_in1,(p9) ld8 val2[1]=3D[src1],8)	// 8-byte aligned
-	EX(failure_out,(p7) st2 [dst1]=3Dval1[1],2)
+	EX(.failure_in1,(p9) ld8 val2[1]=3D[src1],8)	// 8-byte aligned
+	EX(.failure_out,(p7) st2 [dst1]=3Dval1[1],2)
 (p8)	adds len1=3D-4,len1
 	;;
-	EX(failure_out, (p8) st4 [dst1]=3Dval2[0],4)
+	EX(.failure_out, (p8) st4 [dst1]=3Dval2[0],4)
 (p9)	adds len1=3D-8,len1;;
 	shr.u cnt=3Dlen1,4		// number of 128-bit (2x64bit) words
 	;;
-	EX(failure_out, (p9) st8 [dst1]=3Dval2[1],8)
+	EX(.failure_out, (p9) st8 [dst1]=3Dval2[1],8)
 	tbit.nz p6,p0=3Dlen1,3
 	cmp.eq p7,p0=3Dr0,cnt
 	adds tmp=3D-1,cnt			// br.ctop is repeat/until
-(p7)	br.cond.dpnt.few .dotail	// we have less than 16 bytes left
+(p7)	br.cond.dpnt .dotail		// we have less than 16 bytes left
 	;;
 	adds src2=3D8,src1
 	adds dst2=3D8,dst1
@@ -370,12 +370,12 @@
 	// 16bytes/iteration
 	//
 2:
-	EX(failure_in3,(p16) ld8 val1[0]=3D[src1],16)
+	EX(.failure_in3,(p16) ld8 val1[0]=3D[src1],16)
 (p16)	ld8 val2[0]=3D[src2],16
=20
-	EX(failure_out, (EPI)	st8 [dst1]=3Dval1[PIPE_DEPTH-1],16)
+	EX(.failure_out, (EPI)	st8 [dst1]=3Dval1[PIPE_DEPTH-1],16)
 (EPI)	st8 [dst2]=3Dval2[PIPE_DEPTH-1],16
-	br.ctop.dptk.few 2b
+	br.ctop.dptk 2b
 	;;			// RAW on src1 when fall through from loop
 	//
 	// Tail correction based on len only
@@ -384,29 +384,28 @@
 	// is 16 byte aligned AND we have less than 16 bytes to copy.
 	//
 .dotail:
-	EX(failure_in1,(p6) ld8 val1[0]=3D[src1],8)	// at least 8 bytes
+	EX(.failure_in1,(p6) ld8 val1[0]=3D[src1],8)	// at least 8 bytes
 	tbit.nz p7,p0=3Dlen1,2
 	;;
-	EX(failure_in1,(p7) ld4 val1[1]=3D[src1],4)	// at least 4 bytes
+	EX(.failure_in1,(p7) ld4 val1[1]=3D[src1],4)	// at least 4 bytes
 	tbit.nz p8,p0=3Dlen1,1
 	;;
-	EX(failure_in1,(p8) ld2 val2[0]=3D[src1],2)	// at least 2 bytes
+	EX(.failure_in1,(p8) ld2 val2[0]=3D[src1],2)	// at least 2 bytes
 	tbit.nz p9,p0=3Dlen1,0
 	;;
-	EX(failure_out, (p6) st8 [dst1]=3Dval1[0],8)
+	EX(.failure_out, (p6) st8 [dst1]=3Dval1[0],8)
 	;;
-	EX(failure_in1,(p9) ld1 val2[1]=3D[src1])		// only 1 byte left
+	EX(.failure_in1,(p9) ld1 val2[1]=3D[src1])	// only 1 byte left
 	mov ar.lc=3Dsaved_lc
 	;;
-	EX(failure_out,(p7) st4 [dst1]=3Dval1[1],4)
+	EX(.failure_out,(p7) st4 [dst1]=3Dval1[1],4)
 	mov pr=3Dsaved_pr,0xffffffffffff0000
 	;;
-	EX(failure_out, (p8)	st2 [dst1]=3Dval2[0],2)
+	EX(.failure_out, (p8)	st2 [dst1]=3Dval2[0],2)
 	mov ar.pfs=3Dsaved_pfs
 	;;
-	EX(failure_out, (p9)	st1 [dst1]=3Dval2[1])
-	br.ret.dptk.few rp
-
+	EX(.failure_out, (p9)	st1 [dst1]=3Dval2[1])
+	br.ret.sptk.many rp
=20
=20
 	//
@@ -433,32 +432,32 @@
 	//	  pipeline going. We can't really do this inline because
 	//	  p16 is always reset to 1 when lc > 0.
 	//
-failure_in_pipe1:
+.failure_in_pipe1:
 	sub ret0=3Dendsrc,src1	// number of bytes to zero, i.e. not copied
 1:
 (p16)	mov val1[0]=3Dr0
 (EPI)	st1 [dst1]=3Dval1[PIPE_DEPTH-1],1
-	br.ctop.dptk.few 1b
+	br.ctop.dptk 1b
 	;;
 	mov pr=3Dsaved_pr,0xffffffffffff0000
 	mov ar.lc=3Dsaved_lc
 	mov ar.pfs=3Dsaved_pfs
-	br.ret.dptk.few rp
+	br.ret.sptk.many rp
=20
 	//
 	// This is the case where the byte by byte copy fails on the load
 	// when we copy the head. We need to finish the pipeline and copy
 	// zeros for the rest of the destination. Since this happens
 	// at the top we still need to fill the body and tail.
-failure_in_pipe2:
+.failure_in_pipe2:
 	sub ret0=3Dendsrc,src1	// number of bytes to zero, i.e. not copied
 2:
 (p16)	mov val1[0]=3Dr0
 (EPI)	st1 [dst1]=3Dval1[PIPE_DEPTH-1],1
-	br.ctop.dptk.few 2b
+	br.ctop.dptk 2b
 	;;
 	sub len=3Denddst,dst1,1		// precompute len
-	br.cond.dptk.few failure_in1bis
+	br.cond.dptk.many .failure_in1bis
 	;;
=20
 	//
@@ -533,9 +532,7 @@
 	// This means that we are in a situation similar the a fault in the
 	// head part. That's nice!
 	//
-failure_in1:
-//	sub ret0=3Denddst,dst1	// number of bytes to zero, i.e. not copied
-//	sub len=3Denddst,dst1,1
+.failure_in1:
 	sub ret0=3Dendsrc,src1	// number of bytes to zero, i.e. not copied
 	sub len=3Dendsrc,src1,1
 	//
@@ -546,18 +543,17 @@
 	// calling side.
 	//
 	;;
-failure_in1bis:			// from (failure_in3)
+.failure_in1bis:		// from (.failure_in3)
 	mov ar.lc=3Dlen		// Continue with a stupid byte store.
 	;;
 5:
 	st1 [dst1]=3Dr0,1
-	br.cloop.dptk.few 5b
+	br.cloop.dptk 5b
 	;;
-skip_loop:
 	mov pr=3Dsaved_pr,0xffffffffffff0000
 	mov ar.lc=3Dsaved_lc
 	mov ar.pfs=3Dsaved_pfs
-	br.ret.dptk.few rp
+	br.ret.sptk.many rp
=20
 	//
 	// Here we simply restart the loop but instead
@@ -569,7 +565,7 @@
 	// we MUST use src1/endsrc here and not dst1/enddst because
 	// of the pipeline effect.
 	//
-failure_in3:
+.failure_in3:
 	sub ret0=3Dendsrc,src1	// number of bytes to zero, i.e. not copied
 	;;
 2:
@@ -577,36 +573,36 @@
 (p16)	mov val2[0]=3Dr0
 (EPI)	st8 [dst1]=3Dval1[PIPE_DEPTH-1],16
 (EPI)	st8 [dst2]=3Dval2[PIPE_DEPTH-1],16
-	br.ctop.dptk.few 2b
+	br.ctop.dptk 2b
 	;;
 	cmp.ne p6,p0=3Ddst1,enddst	// Do we need to finish the tail ?
 	sub len=3Denddst,dst1,1		// precompute len
-(p6)	br.cond.dptk.few failure_in1bis
+(p6)	br.cond.dptk .failure_in1bis
 	;;
 	mov pr=3Dsaved_pr,0xffffffffffff0000
 	mov ar.lc=3Dsaved_lc
 	mov ar.pfs=3Dsaved_pfs
-	br.ret.dptk.few rp
+	br.ret.sptk.many rp
=20
-failure_in2:
+.failure_in2:
 	sub ret0=3Dendsrc,src1
 	cmp.ne p6,p0=3Ddst1,enddst	// Do we need to finish the tail ?
 	sub len=3Denddst,dst1,1		// precompute len
-(p6)	br.cond.dptk.few failure_in1bis
+(p6)	br.cond.dptk .failure_in1bis
 	;;
 	mov pr=3Dsaved_pr,0xffffffffffff0000
 	mov ar.lc=3Dsaved_lc
 	mov ar.pfs=3Dsaved_pfs
-	br.ret.dptk.few rp
+	br.ret.sptk.many rp
=20
 	//
 	// handling of failures on stores: that's the easy part
 	//
-failure_out:
+.failure_out:
 	sub ret0=3Denddst,dst1
 	mov pr=3Dsaved_pr,0xffffffffffff0000
 	mov ar.lc=3Dsaved_lc
=20
 	mov ar.pfs=3Dsaved_pfs
-	br.ret.dptk.few rp
+	br.ret.sptk.many rp
 END(__copy_user)
diff -urN linux-davidm/arch/ia64/lib/do_csum.S linux-2.4.10-lia/arch/ia64/l=
ib/do_csum.S
--- linux-davidm/arch/ia64/lib/do_csum.S	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/lib/do_csum.S	Mon Sep 24 21:56:08 2001
@@ -129,7 +129,7 @@
 	;;			// avoid WAW on CFM
 	mov tmp3=3D0x7		// a temporary mask/value
 	add tmp1=3Dbuf,len	// last byte's address
-(p6)	br.ret.spnt.few rp	// return if true (hope we can avoid that)
+(p6)	br.ret.spnt.many rp	// return if true (hope we can avoid that)
=20
 	and firstoff=3D7,buf	// how many bytes off for first1 element
 	tbit.nz p15,p0=3Dbuf,0	// is buf an odd address ?
@@ -180,9 +180,9 @@
 	cmp.ltu p6,p0=3Dresult1[0],word1[0]	// check the carry
 	;;
 (p6)	adds result1[0]=3D1,result1[0]
-(p8)	br.cond.dptk.few do_csum_exit	// if (within an 8-byte word)
+(p8)	br.cond.dptk .do_csum_exit	// if (within an 8-byte word)
 	;;
-(p11)	br.cond.dptk.few do_csum16	// if (count is even)
+(p11)	br.cond.dptk .do_csum16		// if (count is even)
 	;;
 	// Here count is odd.
 	ld8 word1[1]=3D[first1],8		// load an 8-byte word
@@ -195,14 +195,14 @@
 	;;
 (p6)	adds result1[0]=3D1,result1[0]
 	;;
-(p9)	br.cond.sptk.few do_csum_exit	// if (count =3D 1) exit
+(p9)	br.cond.sptk .do_csum_exit	// if (count =3D 1) exit
 	// Fall through to caluculate the checksum, feeding result1[0] as
 	// the initial value in result1[0].
 	;;
 	//
 	// Calculate the checksum loading two 8-byte words per loop.
 	//
-do_csum16:
+.do_csum16:
 	mov saved_lc=3Dar.lc
 	shr.u count=3Dcount,1	// we do 16 bytes per loop
 	;;
@@ -224,7 +224,7 @@
 	;;
 	add first2=3D8,first1
 	;;
-(p9)	br.cond.sptk.few do_csum_exit
+(p9)	br.cond.sptk .do_csum_exit
 	;;
 	nop.m	0
 	nop.i	0
@@ -240,7 +240,7 @@
 2:
 (p16)	ld8 word1[0]=3D[first1],16
 (p16)	ld8 word2[0]=3D[first2],16
-	br.ctop.sptk.few 1b
+	br.ctop.sptk 1b
 	;;
 	// Since len is a 32-bit value, carry cannot be larger than
 	// a 64-bit value.
@@ -262,7 +262,7 @@
 	;;
 (p6)	adds result1[0]=3D1,result1[0]
 	;;
-do_csum_exit:
+.do_csum_exit:
 	movl tmp3=3D0xffffffff
 	;;
 	// XXX Fixme
@@ -298,7 +298,7 @@
 	;;
 	mov ar.lc=3Dsaved_lc
 (p15)	shr.u ret0=3Dret0,64-16	// + shift back to position =3D swap bytes
-	br.ret.sptk.few rp
+	br.ret.sptk.many rp
=20
 //	I (Jun Nakajima) wrote an equivalent code (see below), but it was
 //	not much better than the original. So keep the original there so that
@@ -330,6 +330,6 @@
 //(p15)	mux1 ret0=3Dret0,@rev		// reverse word
 //	;;
 //(p15)	shr.u ret0=3Dret0,64-16	// + shift back to position =3D swap bytes
-//	br.ret.sptk.few rp
+//	br.ret.sptk.many rp
=20
 END(do_csum)
diff -urN linux-davidm/arch/ia64/lib/idiv32.S linux-2.4.10-lia/arch/ia64/li=
b/idiv32.S
--- linux-davidm/arch/ia64/lib/idiv32.S	Mon Oct  9 17:54:56 2000
+++ linux-2.4.10-lia/arch/ia64/lib/idiv32.S	Mon Sep 24 21:56:20 2001
@@ -79,5 +79,5 @@
 	;;
 #endif
 	getf.sig r8 =3D f6		// transfer result to result register
-	br.ret.sptk rp
+	br.ret.sptk.many rp
 END(NAME)
diff -urN linux-davidm/arch/ia64/lib/idiv64.S linux-2.4.10-lia/arch/ia64/li=
b/idiv64.S
--- linux-davidm/arch/ia64/lib/idiv64.S	Thu Apr  5 12:51:47 2001
+++ linux-2.4.10-lia/arch/ia64/lib/idiv64.S	Mon Sep 24 21:56:27 2001
@@ -89,5 +89,5 @@
 #endif
 	getf.sig r8 =3D f17		// transfer result to result register
 	ldf.fill f17 =3D [sp]
-	br.ret.sptk rp
+	br.ret.sptk.many rp
 END(NAME)
diff -urN linux-davidm/arch/ia64/lib/memcpy.S linux-2.4.10-lia/arch/ia64/li=
b/memcpy.S
--- linux-davidm/arch/ia64/lib/memcpy.S	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/lib/memcpy.S	Mon Sep 24 21:56:35 2001
@@ -9,9 +9,9 @@
  * Output:
  * 	no return value
  *
- * Copyright (C) 2001 Hewlett-Packard Co
- * Copyright (C) 2000 Stephane Eranian <eranian@hpl.hp.com>
- * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 2000-2001 Hewlett-Packard Co
+ *	Stephane Eranian <eranian@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #include <linux/config.h>
=20
@@ -97,8 +97,8 @@
 	cmp.ne p6,p0=3Dt0,r0
=20
 	mov src=3Din1		// copy because of rotation
-(p7)	br.cond.spnt.few memcpy_short
-(p6)	br.cond.spnt.few memcpy_long
+(p7)	br.cond.spnt.few .memcpy_short
+(p6)	br.cond.spnt.few .memcpy_long
 	;;
 	nop.m	0
 	;;
@@ -133,7 +133,7 @@
 	 * issues, we want to avoid read-modify-write of entire words.
 	 */
 	.align 32
-memcpy_short:
+.memcpy_short:
 	adds cnt=3D-1,in2		// br.ctop is repeat/until
 	mov ar.ec=3DMEM_LAT
 	brp.loop.imp 1f, 2f
@@ -196,7 +196,7 @@
=20
 #define LOG_LOOP_SIZE	6
=20
-memcpy_long:
+.memcpy_long:
 	alloc t3=3Dar.pfs,3,Nrot,0,Nrot	// resize register frame
 	and t0=3D-8,src		// t0 =3D src & ~7
 	and t2=3D7,src		// t2 =3D src & 7
@@ -241,7 +241,7 @@
 	mov t4=3Dip
   }	;;
 	and src2=3D-8,src			// align source pointer
-	adds t4=3Dmemcpy_loops-1b,t4
+	adds t4=3D.memcpy_loops-1b,t4
 	mov ar.ec=3DN
=20
 	and t0=3D7,src			// t0 =3D src & 7
@@ -260,7 +260,7 @@
 	mov pr=3Dcnt,0x38			// set (p5,p4,p3) to # of bytes last-word bytes to co=
py
 	mov ar.lc=3Dt2
 	;;
-	nop.m	0		=09
+	nop.m	0
 	;;
 	nop.m	0
 	nop.i	0
@@ -272,7 +272,7 @@
 	br.sptk.few b6
 	;;
=20
-memcpy_tail:
+.memcpy_tail:
 	// At this point, (p5,p4,p3) are set to the number of bytes left to copy =
(which is
 	// less than 8) and t0 contains the last few bytes of the src buffer:
 (p5)	st4 [dst]=3Dt0,4
@@ -305,8 +305,8 @@
 			ld8 val[N-1]=3D[src_end];	/* load last word (may be same as val[N]) */	\
 			;;									\
 			shrp t0=3Dval[N-1],val[N-index],shift;					\
-			br memcpy_tail
-memcpy_loops:
+			br .memcpy_tail
+.memcpy_loops:
 	COPY(0, 1) /* no point special casing this---it doesn't go any faster wit=
hout shrp */
 	COPY(8, 0)
 	COPY(16, 0)
diff -urN linux-davidm/arch/ia64/lib/memset.S linux-2.4.10-lia/arch/ia64/li=
b/memset.S
--- linux-davidm/arch/ia64/lib/memset.S	Thu Apr  5 12:51:47 2001
+++ linux-2.4.10-lia/arch/ia64/lib/memset.S	Mon Sep 24 21:56:50 2001
@@ -43,11 +43,11 @@
=20
 	adds tmp=3D-1,len		// br.ctop is repeat/until
 	tbit.nz p6,p0=3Dbuf,0	// odd alignment
-(p8)	br.ret.spnt.few rp
+(p8)	br.ret.spnt.many rp
=20
 	cmp.lt p7,p0=16,len	// if len > 16 then long memset
 	mux1 val=3Dval,@brcst	// prepare value
-(p7)	br.cond.dptk.few long_memset
+(p7)	br.cond.dptk .long_memset
 	;;
 	mov ar.lc=3Dtmp		// initialize lc for small count
 	;;			// avoid RAW and WAW on ar.lc
@@ -57,11 +57,11 @@
 	;;				// avoid RAW on ar.lc
 	mov ar.lc=3Dsaved_lc
 	mov ar.pfs=3Dsaved_pfs
-	br.ret.sptk.few rp	// end of short memset
+	br.ret.sptk.many rp	// end of short memset
=20
 	// at this point we know we have more than 16 bytes to copy
 	// so we focus on alignment
-long_memset:
+.long_memset:
 (p6)	st1 [buf]=3Dval,1		// 1-byte aligned
 (p6)	adds len=3D-1,len;;	// sync because buf is modified
 	tbit.nz p6,p0=3Dbuf,1
@@ -80,7 +80,7 @@
 	;;
 	cmp.eq p6,p0=3Dr0,cnt
 	adds tmp=3D-1,cnt
-(p6)	br.cond.dpnt.few .dotail // we have less than 16 bytes left
+(p6)	br.cond.dpnt .dotail	// we have less than 16 bytes left
 	;;
 	adds buf2=3D8,buf		// setup second base pointer
 	mov ar.lc=3Dtmp
@@ -104,5 +104,5 @@
 	mov ar.lc=3Dsaved_lc
 	;;
 (p6)	st1 [buf]=3Dval		// only 1 byte left
-	br.ret.dptk.few rp
+	br.ret.sptk.many rp
 END(memset)
diff -urN linux-davidm/arch/ia64/lib/strlen.S linux-2.4.10-lia/arch/ia64/li=
b/strlen.S
--- linux-davidm/arch/ia64/lib/strlen.S	Thu Apr  5 12:51:47 2001
+++ linux-2.4.10-lia/arch/ia64/lib/strlen.S	Mon Sep 24 21:56:58 2001
@@ -11,7 +11,7 @@
  *	does not count the \0
  *
  * Copyright (C) 1999, 2001 Hewlett-Packard Co
- * Copyright (C) 1999 Stephane Eranian <eranian@hpl.hp.com>
+ *	Stephane Eranian <eranian@hpl.hp.com>
  *
  * 09/24/99 S.Eranian add speculation recovery code
  */
@@ -116,7 +116,7 @@
 	ld8.s w[0]=3D[src],8	// speculatively load next to next
 	cmp.eq.and p6,p0=3D8,val1	// p6 =3D p6 and val1=3D8
 	cmp.eq.and p6,p0=3D8,val2	// p6 =3D p6 and mask=3D8
-(p6)	br.wtop.dptk.few 1b	// loop until p6 =3D 0
+(p6)	br.wtop.dptk 1b		// loop until p6 =3D 0
 	;;
 	//
 	// We must return try the recovery code iff
@@ -127,14 +127,14 @@
 	//
 	cmp.eq  p8,p9=3D8,val1	// p6 =3D val1 had zero (disambiguate)
 	tnat.nz p6,p7=3Dval1	// test NaT on val1
-(p6)	br.cond.spnt.few recover// jump to recovery if val1 is NaT
+(p6)	br.cond.spnt .recover	// jump to recovery if val1 is NaT
 	;;
 	//
 	// if we come here p7 is true, i.e., initialized for // cmp
 	//
 	cmp.eq.and  p7,p0=3D8,val1// val1=3D8?
 	tnat.nz.and p7,p0=3Dval2	// test NaT if val2
-(p7)	br.cond.spnt.few recover// jump to recovery if val2 is NaT
+(p7)	br.cond.spnt .recover	// jump to recovery if val2 is NaT
 	;;
 (p8)	mov val1=3Dval2		// the other test got us out of the loop
 (p8)	adds src=3D-16,src	// correct position when 3 ahead
@@ -146,7 +146,7 @@
 	;;
 	sub ret0=3Dret0,tmp	// adjust
 	mov ar.pfs=3Dsaved_pfs	// because of ar.ec, restore no matter what
-	br.ret.sptk.few rp	// end of normal execution
+	br.ret.sptk.many rp	// end of normal execution
=20
 	//
 	// Outlined recovery code when speculation failed
@@ -165,7 +165,7 @@
 	//	- today we restart from the beginning of the string instead
 	//	  of trying to continue where we left off.
 	//
-recover:
+.recover:
 	ld8 val=3D[base],8	// will fail if unrecoverable fault
 	;;
 	or val=3Dval,mask		// remask first bytes
@@ -180,7 +180,7 @@
 	czx1.r val1=3Dval		// search 0 byte from right
 	;;
 	cmp.eq p6,p0=3D8,val1	// val1=3D8 ?
-(p6)	br.wtop.dptk.few 2b	// loop until p6 =3D 0
+(p6)	br.wtop.dptk 2b		// loop until p6 =3D 0
 	;;			// (avoid WAW on p63)
 	sub ret0=BAse,orig	// distance from base
 	sub tmp=3D8,val1
@@ -188,5 +188,5 @@
 	;;
 	sub ret0=3Dret0,tmp	// length=3Dnow - back -1
 	mov ar.pfs=3Dsaved_pfs	// because of ar.ec, restore no matter what
-	br.ret.sptk.few rp	// end of successful recovery code
+	br.ret.sptk.many rp	// end of successful recovery code
 END(strlen)
diff -urN linux-davidm/arch/ia64/lib/strlen_user.S linux-2.4.10-lia/arch/ia=
64/lib/strlen_user.S
--- linux-davidm/arch/ia64/lib/strlen_user.S	Thu Apr  5 12:51:47 2001
+++ linux-2.4.10-lia/arch/ia64/lib/strlen_user.S	Mon Sep 24 21:57:08 2001
@@ -8,8 +8,8 @@
  *	ret0	0 in case of fault, strlen(buffer)+1 otherwise
  *
  * Copyright (C) 1998, 1999, 2001 Hewlett-Packard Co
- * Copyright (C) 1998, 1999, 2001 David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 1998, 1999 Stephane Eranian <eranian@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+ *	Stephane Eranian <eranian@hpl.hp.com>
  *
  * 01/19/99 S.Eranian heavily enhanced version (see details below)
  * 09/24/99 S.Eranian added speculation recovery code
@@ -108,7 +108,7 @@
 	mov ar.ec=3Dr0		// clear epilogue counter (saved in ar.pfs)
 	;;
 	add base=3D-16,src	// keep track of aligned base
-	chk.s v[1], recover	// if already NaT, then directly skip to recover
+	chk.s v[1], .recover	// if already NaT, then directly skip to recover
 	or v[1]=3Dv[1],mask	// now we have a safe initial byte pattern
 	;;
 1:
@@ -130,14 +130,14 @@
 	//
 	cmp.eq  p8,p9=3D8,val1	// p6 =3D val1 had zero (disambiguate)
 	tnat.nz p6,p7=3Dval1	// test NaT on val1
-(p6)	br.cond.spnt.few recover// jump to recovery if val1 is NaT
+(p6)	br.cond.spnt .recover	// jump to recovery if val1 is NaT
 	;;
 	//
 	// if we come here p7 is true, i.e., initialized for // cmp
 	//
 	cmp.eq.and  p7,p0=3D8,val1// val1=3D8?
 	tnat.nz.and p7,p0=3Dval2	// test NaT if val2
-(p7)	br.cond.spnt.few recover// jump to recovery if val2 is NaT
+(p7)	br.cond.spnt .recover	// jump to recovery if val2 is NaT
 	;;
 (p8)	mov val1=3Dval2		// val2 contains the value
 (p8)	adds src=3D-16,src	// correct position when 3 ahead
@@ -149,7 +149,7 @@
 	;;
 	sub ret0=3Dret0,tmp	// length=3Dnow - back -1
 	mov ar.pfs=3Dsaved_pfs	// because of ar.ec, restore no matter what
-	br.ret.sptk.few rp	// end of normal execution
+	br.ret.sptk.many rp	// end of normal execution
=20
 	//
 	// Outlined recovery code when speculation failed
@@ -162,7 +162,7 @@
 	//	- today we restart from the beginning of the string instead
 	//	  of trying to continue where we left off.
 	//
-recover:
+.recover:
 	EX(.Lexit1, ld8 val=3D[base],8)	// load the initial bytes
 	;;
 	or val=3Dval,mask			// remask first bytes
@@ -185,7 +185,7 @@
 	;;
 	sub ret0=3Dret0,tmp	// length=3Dnow - back -1
 	mov ar.pfs=3Dsaved_pfs	// because of ar.ec, restore no matter what
-	br.ret.sptk.few rp	// end of successful recovery code
+	br.ret.sptk.many rp	// end of successful recovery code
=20
 	//
 	// We failed even on the normal load (called from exception handler)
@@ -194,5 +194,5 @@
 	mov ret0=3D0
 	mov pr=3Dsaved_pr,0xffffffffffff0000
 	mov ar.pfs=3Dsaved_pfs	// because of ar.ec, restore no matter what
-	br.ret.sptk.few rp
+	br.ret.sptk.many rp
 END(__strlen_user)
diff -urN linux-davidm/arch/ia64/lib/strncpy_from_user.S linux-2.4.10-lia/a=
rch/ia64/lib/strncpy_from_user.S
--- linux-davidm/arch/ia64/lib/strncpy_from_user.S	Thu Apr  5 12:51:47 2001
+++ linux-2.4.10-lia/arch/ia64/lib/strncpy_from_user.S	Mon Sep 24 21:57:19 =
2001
@@ -40,5 +40,5 @@
 (p6)	mov r8=3Din2		// buffer filled up---return buffer length
 (p7)	sub r8=3Din1,r9,1		// return string length (excluding NUL character)
 [.Lexit:]
-	br.ret.sptk.few rp
+	br.ret.sptk.many rp
 END(__strncpy_from_user)
diff -urN linux-davidm/arch/ia64/lib/strnlen_user.S linux-2.4.10-lia/arch/i=
a64/lib/strnlen_user.S
--- linux-davidm/arch/ia64/lib/strnlen_user.S	Thu Apr  5 12:51:47 2001
+++ linux-2.4.10-lia/arch/ia64/lib/strnlen_user.S	Mon Sep 24 21:57:28 2001
@@ -33,7 +33,7 @@
 	add r9=3D1,r9
 	;;
 	cmp.eq p6,p0=3Dr8,r0
-(p6)	br.dpnt.few .Lexit
+(p6)	br.cond.dpnt .Lexit
 	br.cloop.dptk.few .Loop1
=20
 	add r9=3D1,in1			// NUL not found---return N+1
@@ -41,5 +41,5 @@
 .Lexit:
 	mov r8=3Dr9
 	mov ar.lc=3Dr16			// restore ar.lc
-	br.ret.sptk.few rp
+	br.ret.sptk.many rp
 END(__strnlen_user)
diff -urN linux-davidm/arch/ia64/mm/fault.c linux-2.4.10-lia/arch/ia64/mm/f=
ault.c
--- linux-davidm/arch/ia64/mm/fault.c	Thu Apr  5 12:51:47 2001
+++ linux-2.4.10-lia/arch/ia64/mm/fault.c	Mon Sep 24 21:58:13 2001
@@ -1,8 +1,8 @@
 /*
  * MMU fault handling support.
  *
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #include <linux/sched.h>
 #include <linux/kernel.h>
@@ -16,7 +16,7 @@
 #include <asm/uaccess.h>
 #include <asm/hardirq.h>
=20
-extern void die_if_kernel (char *, struct pt_regs *, long);
+extern void die (char *, struct pt_regs *, long);
=20
 /*
  * This routine is analogous to expand_stack() but instead grows the
@@ -46,16 +46,15 @@
 void
 ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_re=
gs *regs)
 {
+	int signal =3D SIGSEGV, code =3D SEGV_MAPERR;
+	struct vm_area_struct *vma, *prev_vma;
 	struct mm_struct *mm =3D current->mm;
 	struct exception_fixup fix;
-	struct vm_area_struct *vma, *prev_vma;
 	struct siginfo si;
-	int signal =3D SIGSEGV;
 	unsigned long mask;
=20
 	/*
-	 * If we're in an interrupt or have no user
-	 * context, we must not take the fault..
+	 * If we're in an interrupt or have no user context, we must not take the=
 fault..
 	 */
 	if (in_interrupt() || !mm)
 		goto no_context;
@@ -71,6 +70,8 @@
 		goto check_expansion;
=20
   good_area:
+	code =3D SEGV_ACCERR;
+
 	/* OK, we've got a good vm_area for this memory area.  Check the access p=
ermissions: */
=20
 #	define VM_READ_BIT	0
@@ -89,12 +90,13 @@
 	if ((vma->vm_flags & mask) !=3D mask)
 		goto bad_area;
=20
+  survive:
 	/*
 	 * If for any reason at all we couldn't handle the fault, make
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */
-	switch (handle_mm_fault(mm, vma, address, mask) !=3D 0) {
+	switch (handle_mm_fault(mm, vma, address, mask)) {
 	      case 1:
 		++current->min_flt;
 		break;
@@ -147,7 +149,7 @@
 	if (user_mode(regs)) {
 		si.si_signo =3D signal;
 		si.si_errno =3D 0;
-		si.si_code =3D SI_KERNEL;
+		si.si_code =3D code;
 		si.si_addr =3D (void *) address;
 		force_sig_info(signal, &si, current);
 		return;
@@ -174,17 +176,29 @@
 	}
=20
 	/*
-	 * Oops. The kernel tried to access some bad page. We'll have
-	 * to terminate things with extreme prejudice.
+	 * Oops. The kernel tried to access some bad page. We'll have to terminat=
e things
+	 * with extreme prejudice.
 	 */
-	printk(KERN_ALERT "Unable to handle kernel paging request at "
-	       "virtual address %016lx\n", address);
-	die_if_kernel("Oops", regs, isr);
+	bust_spinlocks(1);
+
+	if (address < PAGE_SIZE)
+		printk(KERN_ALERT "Unable to handle kernel NULL pointer dereference");
+	else
+		printk(KERN_ALERT "Unable to handle kernel paging request at "
+		       "virtual address %016lx\n", address);
+	die("Oops", regs, isr);
+	bust_spinlocks(0);
 	do_exit(SIGKILL);
 	return;
=20
   out_of_memory:
 	up_read(&mm->mmap_sem);
+	if (current->pid =3D 1) {
+		current->policy |=3D SCHED_YIELD;
+		schedule();
+		down_read(&mm->mmap_sem);
+		goto survive;
+	}
 	printk("VM: killing process %s\n", current->comm);
 	if (user_mode(regs))
 		do_exit(SIGKILL);
diff -urN linux-davidm/arch/ia64/mm/tlb.c linux-2.4.10-lia/arch/ia64/mm/tlb=
.c
--- linux-davidm/arch/ia64/mm/tlb.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/arch/ia64/mm/tlb.c	Mon Sep 24 21:59:16 2001
@@ -2,7 +2,7 @@
  * TLB support routines.
  *
  * Copyright (C) 1998-2001 Hewlett-Packard Co
- * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * 08/02/00 A. Mallick <asit.k.mallick@intel.com>
  *		Modified RID allocation for SMP
@@ -41,11 +41,6 @@
 };
=20
 /*
- * Seralize usage of ptc.g
- */
-spinlock_t ptcg_lock =3D SPIN_LOCK_UNLOCKED; /* see <asm/pgtable.h> */
-
-/*
  * Acquire the ia64_ctx.lock before calling this function!
  */
 void
@@ -84,6 +79,26 @@
 	flush_tlb_all();
 }
=20
+static void
+ia64_global_tlb_purge (unsigned long start, unsigned long end, unsigned lo=
ng nbits)
+{
+	static spinlock_t ptcg_lock =3D SPIN_LOCK_UNLOCKED;
+
+	/* HW requires global serialization of ptc.ga.  */
+	spin_lock(&ptcg_lock);
+	{
+		do {
+			/*
+			 * Flush ALAT entries also.
+			 */
+			asm volatile ("ptc.ga %0,%1;;srlz.i;;" :: "r"(start), "r"(nbits<<2)
+				      : "memory");
+			start +=3D (1UL << nbits);
+		} while (start < end);
+	}
+	spin_unlock(&ptcg_lock);
+}
+
 void
 __flush_tlb_all (void)
 {
@@ -144,19 +159,15 @@
 	}
 	start &=3D ~((1UL << nbits) - 1);
=20
-	spin_lock(&ptcg_lock);
 	do {
 # ifdef CONFIG_SMP
-		/*
-		 * Flush ALAT entries also.
-		 */
-		asm volatile ("ptc.ga %0,%1;;srlz.i;;" :: "r"(start), "r"(nbits<<2) : "m=
emory");
+		platform_global_tlb_purge(start, end, nbits);
 # else
 		asm volatile ("ptc.l %0,%1" :: "r"(start), "r"(nbits<<2) : "memory");
 # endif
 		start +=3D (1UL << nbits);
 	} while (start < end);
-	spin_unlock(&ptcg_lock);
+
 	ia64_insn_group_barrier();
 	ia64_srlz_i();			/* srlz.i implies srlz.d */
 	ia64_insn_group_barrier();
diff -urN linux-davidm/arch/ia64/tools/print_offsets.c linux-2.4.10-lia/arc=
h/ia64/tools/print_offsets.c
--- linux-davidm/arch/ia64/tools/print_offsets.c	Tue Jul 31 10:30:09 2001
+++ linux-2.4.10-lia/arch/ia64/tools/print_offsets.c	Mon Sep 24 21:59:30 20=
01
@@ -61,7 +61,7 @@
     { "IA64_TASK_THREAD_SIGMASK_OFFSET",offsetof (struct task_struct, thre=
ad.un.sigmask) },
 #endif
 #ifdef CONFIG_PERFMON
-    { "IA64_TASK_PFM_NOTIFY_OFFSET",	offsetof(struct task_struct, thread.p=
fm_pend_notify) },
+    { "IA64_TASK_PFM_MUST_BLOCK_OFFSET",offsetof(struct task_struct, threa=
d.pfm_must_block) },
 #endif
     { "IA64_TASK_PID_OFFSET",		offsetof (struct task_struct, pid) },
     { "IA64_TASK_MM_OFFSET",		offsetof (struct task_struct, mm) },
@@ -165,17 +165,18 @@
     { "IA64_SIGCONTEXT_FR6_OFFSET",	offsetof (struct sigcontext, sc_fr[6])=
 },
     { "IA64_SIGCONTEXT_PR_OFFSET",	offsetof (struct sigcontext, sc_pr) },
     { "IA64_SIGCONTEXT_R12_OFFSET",	offsetof (struct sigcontext, sc_gr[12]=
) },
+    { "IA64_SIGCONTEXT_RBS_BASE_OFFSET",offsetof (struct sigcontext, sc_rb=
s_base) },
+    { "IA64_SIGCONTEXT_LOADRS_OFFSET",	offsetof (struct sigcontext, sc_loa=
drs) },
     { "IA64_SIGFRAME_ARG0_OFFSET",		offsetof (struct sigframe, arg0) },
     { "IA64_SIGFRAME_ARG1_OFFSET",		offsetof (struct sigframe, arg1) },
     { "IA64_SIGFRAME_ARG2_OFFSET",		offsetof (struct sigframe, arg2) },
-    { "IA64_SIGFRAME_RBS_BASE_OFFSET",		offsetof (struct sigframe, rbs_bas=
e) },
     { "IA64_SIGFRAME_HANDLER_OFFSET",		offsetof (struct sigframe, handler)=
 },
     { "IA64_SIGFRAME_SIGCONTEXT_OFFSET",	offsetof (struct sigframe, sc) },
     { "IA64_CLONE_VFORK",		CLONE_VFORK },
     { "IA64_CLONE_VM",			CLONE_VM },
     { "IA64_CPU_IRQ_COUNT_OFFSET",	offsetof (struct cpuinfo_ia64, irq_stat=
.f.irq_count) },
     { "IA64_CPU_BH_COUNT_OFFSET",	offsetof (struct cpuinfo_ia64, irq_stat.=
f.bh_count) },
-    { "IA64_CPU_PHYS_STACKED_SIZE_P8_OFFSET",	offsetof (struct cpuinfo_ia6=
4, phys_stacked_size_p8) },
+    { "IA64_CPU_PHYS_STACKED_SIZE_P8_OFFSET",offsetof (struct cpuinfo_ia64=
, phys_stacked_size_p8)},
 };
=20
 static const char *tabs =3D "\t\t\t\t\t\t\t\t\t\t";
diff -urN linux-davidm/drivers/acpi/Makefile linux-2.4.10-lia/drivers/acpi/=
Makefile
--- linux-davidm/drivers/acpi/Makefile	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/drivers/acpi/Makefile	Mon Sep 24 21:59:51 2001
@@ -39,7 +39,7 @@
 obj-$(CONFIG_ACPI)	+=3D os.o acpi_ksyms.o
 obj-$(CONFIG_ACPI)	+=3D $(foreach dir,$(acpi-subdirs),$(dir)/$(dir).o)=20
 ifdef CONFIG_ACPI_KERNEL_CONFIG
-   obj-$(CONFIG_ACPI) 	+=3D acpiconf.o osconf.o
+   obj-$(CONFIG_ACPI) 	+=3D acpiconf.o osconf.o driver.o
 endif
 obj-$(CONFIG_ACPI)	+=3D driver.o
=20
diff -urN linux-davidm/drivers/acpi/acpiconf.c linux-2.4.10-lia/drivers/acp=
i/acpiconf.c
--- linux-davidm/drivers/acpi/acpiconf.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/drivers/acpi/acpiconf.c	Mon Sep 24 22:00:01 2001
@@ -30,12 +30,12 @@
=20
 static	int	acpi_cf_initialized __initdata =3D 0;
=20
-ACPI_STATUS	__init
+acpi_status	__init
 acpi_cf_init (
 	void * rsdp
 	)
 {
-	ACPI_STATUS	status;
+	acpi_status	status;
=20
 	acpi_os_bind_osd(ACPI_CF_PHASE_BOOTTIME);
=20
@@ -44,9 +44,9 @@
 		printk ("Acpi cfg:initialize_subsystem error=3D0x%x\n", status);
 		return status;
 	}
-	dprintk(("Acpi cfg:initializ_subsysteme pass\n"));
+	dprintk(("Acpi cfg:initialize_subsystem pass\n"));
=20
-	status =3D acpi_load_tables ((u64)rsdp);
+	status =3D acpi_load_tables ();
 	if (ACPI_FAILURE(status)) {
 		printk ("Acpi cfg:load firmware tables error=3D0x%x\n", status);
 		acpi_terminate();
@@ -68,13 +68,15 @@
 }
=20
=20
-ACPI_STATUS	__init
+acpi_status	__init
 acpi_cf_terminate ( void )
 {
-	ACPI_STATUS	status;
+	acpi_status	status;
=20
-	if (! ACPI_CF_INITIALIZED())
+	if (! ACPI_CF_INITIALIZED()) {
+		acpi_os_bind_osd(ACPI_CF_PHASE_RUNTIME);
 		return AE_ERROR;
+	}
=20
 	status =3D acpi_disable ();
 	if (ACPI_FAILURE(status)) {
@@ -97,13 +99,13 @@
 }
=20
=20
-ACPI_STATUS	__init
+acpi_status	__init
 acpi_cf_get_pci_vectors (
 	struct pci_vector_struct	**vectors,
 	int				*num_pci_vectors
 	)
 {
-	ACPI_STATUS	status;
+	acpi_status	status;
 	void		*prts;
=20
 	if (! ACPI_CF_INITIALIZED()) {
@@ -134,28 +136,28 @@
 }
=20
=20
-static	PCI_ROUTING_TABLE	*pci_routing_tables[PCI_MAX_BUS] __initdata =3D {=
NULL};
+static	pci_routing_table	*pci_routing_tables[PCI_MAX_BUS] __initdata =3D {=
NULL};
=20
=20
 typedef struct _acpi_rpb {
 	NATIVE_UINT	rpb_busnum;
 	NATIVE_UINT	lastbusnum;
-	ACPI_HANDLE	rpb_handle;
+	acpi_handle	rpb_handle;
 } acpi_rpb_t;
=20
=20
-static ACPI_STATUS	__init
+static acpi_status	__init
 acpi_cf_evaluate_method (
-	ACPI_HANDLE	handle,
+	acpi_handle	handle,
 	UINT8		*method_name,
 	NATIVE_UINT	*nuint
 	)
 {
 	UINT32			tnuint =3D 0;
-	ACPI_STATUS		status;
+	acpi_status		status;
=20
-	ACPI_BUFFER		ret_buf;
-	ACPI_OBJECT		*ext_obj;
+	acpi_buffer		ret_buf;
+	acpi_object		*ext_obj;
 	UINT8			buf[PATHNAME_MAX];
=20
=20
@@ -170,7 +172,7 @@
 			printk("Acpi cfg: %s fail=3D0x%x\n", method_name, status);
 		}
 	} else {
-		ext_obj =3D (ACPI_OBJECT *) ret_buf.pointer;
+		ext_obj =3D (acpi_object *) ret_buf.pointer;
=20
 		switch (ext_obj->type) {
 		case ACPI_TYPE_INTEGER:
@@ -188,14 +190,14 @@
 }
=20
=20
-static ACPI_STATUS	__init
+static acpi_status	__init
 acpi_cf_evaluate_PRT (
-	ACPI_HANDLE		handle,
-	PCI_ROUTING_TABLE	**prt
+	acpi_handle		handle,
+	pci_routing_table	**prt
 	)
 {
-	ACPI_BUFFER		acpi_buffer;
-	ACPI_STATUS		status;
+	acpi_buffer		acpi_buffer;
+	acpi_status		status;
=20
 	acpi_buffer.length  =3D 0;
 	acpi_buffer.pointer =3D NULL;
@@ -213,7 +215,7 @@
 		return status;
 	}
=20
-	*prt =3D (PCI_ROUTING_TABLE *) acpi_os_callocate (acpi_buffer.length);
+	*prt =3D (pci_routing_table *) acpi_os_callocate (acpi_buffer.length);
 	if (!*prt) {
 		printk("Acpi cfg: callocate %d bytes for _PRT fail\n",
 			acpi_buffer.length);
@@ -230,23 +232,22 @@
 	return status;
 }
=20
-static ACPI_STATUS	__init
+static acpi_status	__init
 acpi_cf_get_root_pci_callback (
-	ACPI_HANDLE		handle,
+	acpi_handle		handle,
 	UINT32			Level,
 	void			*context,
 	void			**retval
 	)
 {
 	NATIVE_UINT		busnum =3D 0;
-	ACPI_STATUS		status;
+	acpi_status		status;
 	acpi_rpb_t		rpb;
-	PCI_ROUTING_TABLE	*prt;
+	pci_routing_table	*prt;
=20
 	UINT8			path_name[PATHNAME_MAX];
-
 #ifdef	CONFIG_ACPI_KERNEL_CONFIG_DEBUG
-	ACPI_BUFFER		ret_buf;
+	acpi_buffer		ret_buf;
=20
 	ret_buf.length  =3D PATHNAME_MAX;
 	ret_buf.pointer =3D (void *) path_name;
@@ -313,23 +314,24 @@
 /*
  * handle _PRTs of immediate P2Ps of root pci.=20
  */
-static ACPI_STATUS	__init
+static acpi_status	__init
 acpi_cf_associate_prt_to_bus (
-	ACPI_HANDLE		handle,
+	acpi_handle		handle,
 	acpi_rpb_t		*rpb,
 	NATIVE_UINT		*retbusnum,
 	NATIVE_UINT		depth
 	)
 {
-	ACPI_STATUS		status;
+	acpi_status		status;
 	UINT32			segbus;
 	NATIVE_UINT		devfn;
 	UINT8			bn;
=20
 	UINT8			path_name[PATHNAME_MAX];
+	acpi_pci_id		pci_id;
=20
 #ifdef	CONFIG_ACPI_KERNEL_CONFIG_DEBUG
-	ACPI_BUFFER		ret_buf;
+	acpi_buffer		ret_buf;
=20
 	ret_buf.length  =3D PATHNAME_MAX;
 	ret_buf.pointer =3D (void *) path_name;
@@ -356,10 +358,13 @@
 	 * access pci config space for bus number
 	 *	segbus =3D from rpb, devfn =3D from _ADR
 	 */
-	segbus =3D (UINT32)(rpb->rpb_busnum & 0xFFFFFFFF);
+	pci_id.segment =3D 0;
+	pci_id.bus =3D (u16)(rpb->rpb_busnum & 0xffffffff);
+	pci_id.device =3D (u16)((devfn >> 16) & 0xffff);
+	pci_id.function =3D (u16)(devfn & 0xffff);
=20
-	status =3D acpi_os_read_pci_cfg_byte(segbus,
-				(UINT32)devfn, PCI_PRIMARY_BUS, &bn);
+	status =3D acpi_os_read_pci_configuration(&pci_id, PCI_PRIMARY_BUS,
+						&bn, 1);
 	if (ACPI_FAILURE(status)) {
 		*retbusnum =3D rpb->rpb_busnum + 1;
 		printk("Acpi cfg:%s pci read fail=3D0x%x. b:df:a=3D%x:%x:%x\n",
@@ -372,8 +377,8 @@
 	dprintk(("Acpi cfg:%s pribus %d\n", path_name, bn));
=20
=20
-	status =3D acpi_os_read_pci_cfg_byte(segbus,
-				(UINT32)devfn, PCI_SECONDARY_BUS, &bn);
+	status =3D acpi_os_read_pci_configuration(&pci_id, PCI_SECONDARY_BUS,
+						&bn, 1);
 	if (ACPI_FAILURE(status)) {
 		*retbusnum =3D rpb->rpb_busnum + 1;
 		printk("Acpi cfg:%s pci read fail=3D0x%x. b:df:a=3D%x:%x:%x\n",
@@ -390,12 +395,12 @@
 }
=20
=20
-static ACPI_STATUS	__init
+static acpi_status	__init
 acpi_cf_get_prt (
 	void		**prts
 	)
 {
-	ACPI_STATUS	status;
+	acpi_status	status;
=20
 	status =3D acpi_get_devices ( PCI_ROOT_HID_STRING,
 				acpi_cf_get_root_pci_callback,
@@ -411,23 +416,23 @@
 	return status;
 }
=20
-static ACPI_STATUS	__init
+static acpi_status	__init
 acpi_cf_get_prt_callback (
-	ACPI_HANDLE		handle,
+	acpi_handle		handle,
 	UINT32			Level,
 	void			*context,
 	void			**retval
 	)
 {
-	PCI_ROUTING_TABLE	*prt;
+	pci_routing_table	*prt;
 	NATIVE_UINT		busnum =3D 0;
 	NATIVE_UINT		temp =3D 0x0F;
-	ACPI_STATUS		status;
+	acpi_status		status;
=20
 	UINT8			path_name[PATHNAME_MAX];
=20
 #ifdef	CONFIG_ACPI_KERNEL_CONFIG_DEBUG
-	ACPI_BUFFER		ret_buf;
+	acpi_buffer		ret_buf;
=20
 	ret_buf.length  =3D PATHNAME_MAX;
 	ret_buf.pointer =3D (void *) path_name;
@@ -487,7 +492,7 @@
 static void	__init
 acpi_cf_add_to_pci_routing_tables (
 	NATIVE_UINT		busnum,
-	PCI_ROUTING_TABLE	*prt
+	pci_routing_table	*prt
 	)
 {
 	if ( busnum >=3D PCI_MAX_BUS ) {
@@ -507,7 +512,7 @@
=20
 #define	DUMPVECTOR(pv)	printk("PCI bus=3D0x%x id=3D0x%x pin=3D0x%x irq=3D0=
x%x\n", pv->bus, pv->pci_id, pv->pin, pv->irq);
=20
-static ACPI_STATUS	__init
+static acpi_status	__init
 acpi_cf_convert_prt_to_vectors (
 	void				*prts,
 	struct pci_vector_struct	**vectors,
@@ -515,18 +520,18 @@
 	)
 {
 	struct pci_vector_struct	*pvec;
-	PCI_ROUTING_TABLE		**pprts, *prt, *prtf;
+	pci_routing_table		**pprts, *prt, *prtf;
 	int				nvec =3D 0;
 	int				i;
=20
=20
-	pprts =3D (PCI_ROUTING_TABLE **)prts;
+	pprts =3D (pci_routing_table **)prts;
=20
 	for ( i =3D 0; i < PCI_MAX_BUS; i++) {
 		prt =3D *pprts++;
 		if (prt) {
 			for ( ; prt->length > 0; nvec++) {
-				prt =3D (PCI_ROUTING_TABLE *) ((NATIVE_UINT)prt + (NATIVE_UINT)prt->le=
ngth);
+				prt =3D (pci_routing_table *) ((NATIVE_UINT)prt + (NATIVE_UINT)prt->le=
ngth);
 			}
 		}
 	}
@@ -539,7 +544,7 @@
 	}
=20
 	pvec =3D *vectors;
-	pprts =3D (PCI_ROUTING_TABLE **)prts;
+	pprts =3D (pci_routing_table **)prts;
=20
 	for ( i =3D 0; i < PCI_MAX_BUS; i++) {
 		prt =3D prtf =3D *pprts++;
@@ -550,7 +555,7 @@
 				pvec->pin	=3D (UINT8)prt->pin;
 				pvec->irq	=3D (UINT8)prt->source_index;
=20
-				prt =3D (PCI_ROUTING_TABLE *) ((NATIVE_UINT)prt + (NATIVE_UINT)prt->le=
ngth);
+				prt =3D (pci_routing_table *) ((NATIVE_UINT)prt + (NATIVE_UINT)prt->le=
ngth);
 			}
 			acpi_os_free((void *)prtf);
 		}
diff -urN linux-davidm/drivers/acpi/acpiconf.h linux-2.4.10-lia/drivers/acp=
i/acpiconf.h
--- linux-davidm/drivers/acpi/acpiconf.h	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/drivers/acpi/acpiconf.h	Mon Sep 24 22:21:57 2001
@@ -27,14 +27,14 @@
=20
=20
 static
-ACPI_STATUS	__init
+acpi_status	__init
 acpi_cf_get_prt (void **prts);
=20
=20
 static
-ACPI_STATUS	__init
+acpi_status	__init
 acpi_cf_get_prt_callback (
-	ACPI_HANDLE		handle,
+	acpi_handle		handle,
 	UINT32			level,
 	void			*context,
 	void			**retval
@@ -45,12 +45,12 @@
 void	__init
 acpi_cf_add_to_pci_routing_tables (
 	NATIVE_UINT		busnum,
-	PCI_ROUTING_TABLE	*prt
+	pci_routing_table	*prt
 	);
=20
=20
 static
-ACPI_STATUS	__init
+acpi_status	__init
 acpi_cf_convert_prt_to_vectors (
 	void				*prts,
 	struct pci_vector_struct	**vectors,
diff -urN linux-davidm/drivers/acpi/driver.c linux-2.4.10-lia/drivers/acpi/=
driver.c
--- linux-davidm/drivers/acpi/driver.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/drivers/acpi/driver.c	Mon Sep 24 21:30:52 2001
@@ -112,9 +112,7 @@
=20
 	printk(KERN_INFO "ACPI: Subsystem enabled\n");
=20
-#ifdef CONFIG_PM
 	pm_active =3D 1;
-#endif
=20
 	return 0;
 }
@@ -127,9 +125,7 @@
 {
 	acpi_terminate();
=20
-#ifdef CONFIG_PM
 	pm_active =3D 0;
-#endif
=20
 	printk(KERN_ERR "ACPI: Subsystem disabled\n");
 }
diff -urN linux-davidm/drivers/acpi/hardware/hwacpi.c linux-2.4.10-lia/driv=
ers/acpi/hardware/hwacpi.c
--- linux-davidm/drivers/acpi/hardware/hwacpi.c	Mon Sep 24 15:06:41 2001
+++ linux-2.4.10-lia/drivers/acpi/hardware/hwacpi.c	Mon Sep 24 22:00:26 2001
@@ -196,6 +196,7 @@
 {
=20
 	acpi_status             status =3D AE_NO_HARDWARE_RESPONSE;
+	u32			retries =3D 20;
=20
=20
 	FUNCTION_TRACE ("Hw_set_mode");
@@ -220,11 +221,14 @@
=20
 	/* Give the platform some time to react */
=20
-	acpi_os_stall (5000);
+	while (retries-- > 0) {
+		acpi_os_stall (5000);
=20
-	if (acpi_hw_get_mode () =3D mode) {
-		ACPI_DEBUG_PRINT ((ACPI_DB_INFO, "Mode %X successfully enabled\n", mode)=
);
-		status =3D AE_OK;
+		if (acpi_hw_get_mode () =3D mode) {
+			ACPI_DEBUG_PRINT ((ACPI_DB_INFO, "Mode %X successfully enabled\n", mode=
));
+			status =3D AE_OK;
+			break;
+		}
 	}
=20
 	return_ACPI_STATUS (status);
diff -urN linux-davidm/drivers/acpi/include/actypes.h linux-2.4.10-lia/driv=
ers/acpi/include/actypes.h
--- linux-davidm/drivers/acpi/include/actypes.h	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/drivers/acpi/include/actypes.h	Mon Sep 24 22:00:40 2001
@@ -60,7 +60,7 @@
 typedef int                             INT32;
 typedef unsigned int                    UINT32;
 typedef COMPILER_DEPENDENT_UINT64       UINT64;
-typedef long				INT64;
+typedef	long				INT64;
=20
 typedef UINT64                          NATIVE_UINT;
 typedef INT64                           NATIVE_INT;
diff -urN linux-davidm/drivers/acpi/os.c linux-2.4.10-lia/drivers/acpi/os.c
--- linux-davidm/drivers/acpi/os.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/drivers/acpi/os.c	Mon Sep 24 21:30:48 2001
@@ -39,13 +39,10 @@
 #include <linux/pci.h>
 #include <linux/interrupt.h>
 #include <linux/kmod.h>
-#include <linux/irq.h>
 #include <linux/delay.h>
 #include <asm/io.h>
 #include <acpi.h>
-#ifndef	CONFIG_ACPI_KERNEL_CONFIG_ONLY
 #include "driver.h"
-#endif
=20
 #ifdef CONFIG_ACPI_EFI
 #include <asm/efi.h>
@@ -53,7 +50,8 @@
=20
 #ifdef _IA64
 #include <asm/hw_irq.h>
-#endif=20
+#include <asm/delay.h>
+#endif
=20
 #define _COMPONENT	ACPI_OS_SERVICES
 	MODULE_NAME	("os")
@@ -66,7 +64,7 @@
=20
=20
 /*************************************************************************=
****
- *			       Debugger Stuff
+ *			       Function Binding
  *************************************************************************=
****/
=20
 #ifdef	CONFIG_ACPI_KERNEL_CONFIG
@@ -78,26 +76,24 @@
 	acpi_os_callocate_rt,
 	acpi_os_free_rt,
 	acpi_os_queue_for_execution_rt,
-	acpi_os_read_pci_cfg_byte_rt,
-	acpi_os_read_pci_cfg_word_rt,
-	acpi_os_read_pci_cfg_dword_rt,
-	acpi_os_write_pci_cfg_byte_rt,
-	acpi_os_write_pci_cfg_word_rt,
-	acpi_os_write_pci_cfg_dword_rt
+	acpi_os_read_pci_configuration_rt,
+	acpi_os_write_pci_configuration_rt,
+	acpi_os_stall_rt
 };
 #else
 #define	acpi_os_allocate_rt		acpi_os_allocate
 #define	acpi_os_callocate_rt		acpi_os_callocate
 #define	acpi_os_free_rt			acpi_os_free
 #define acpi_os_queue_for_execution_rt	acpi_os_queue_for_execution
-#define acpi_os_read_pci_cfg_byte_rt	acpi_os_read_pci_cfg_byte
-#define acpi_os_read_pci_cfg_word_rt	acpi_os_read_pci_cfg_word
-#define acpi_os_read_pci_cfg_dword_rt	acpi_os_read_pci_cfg_dword
-#define acpi_os_write_pci_cfg_byte_rt	acpi_os_write_pci_cfg_byte
-#define acpi_os_write_pci_cfg_word_rt	acpi_os_write_pci_cfg_word
-#define acpi_os_write_pci_cfg_dword_rt	acpi_os_write_pci_cfg_dword
+#define acpi_os_read_pci_configuration_rt	acpi_os_read_pci_configuration
+#define acpi_os_write_pci_configuration_rt	acpi_os_write_pci_configuration
+#define acpi_os_stall_rt acpi_os_stall
 #endif
=20
+/*************************************************************************=
****
+ *			       Debugger Stuff
+ *************************************************************************=
****/
+
 #ifdef ENABLE_DEBUGGER
=20
 #include <linux/kdb.h>
@@ -267,12 +263,105 @@
 	(*acpi_irq_handler)(acpi_irq_context);
 }
=20
+#ifdef	CONFIG_ACPI_KERNEL_CONFIG
+struct irqaction	acpiirqaction;
+/*
+ * codes from request_irq and free_irq.
+ */
 acpi_status
 acpi_os_install_interrupt_handler(u32 irq, OSD_HANDLER handler, void *cont=
ext)
 {
-#ifdef _IA64
+	struct irqaction	*act;
+	int	retval;
+
+	if (irq >=3D NR_IRQS) {
+		printk("ACPI: install SCI handler fail: invalid irq%d\n", irq);
+		return AE_ERROR;
+	}
+
+	if (!handler) {
+		printk("ACPI: install SCI handler fail: invalid handler\n");
+		return AE_ERROR;
+	}
+
+	act =3D & acpiirqaction;
+
 	irq =3D isa_irq_to_vector(irq);
-#endif /*_IA64*/
+	acpi_irq_irq =3D irq;
+	acpi_irq_handler =3D handler;
+	acpi_irq_context =3D context;
+
+	act->handler =3D acpi_irq;
+	act->flags =3D SA_INTERRUPT | SA_SHIRQ;
+	act->mask =3D 0;
+	act->name =3D "acpi";
+	act->next =3D NULL;
+	act->dev_id =3D acpi_irq;
+
+	retval =3D setup_irq(irq, act);
+	if (retval) {
+		printk("ACPI: install SCI handler fail: setup_irq\n");
+		acpi_irq_handler =3D NULL;
+		return AE_ERROR;
+	}
+	printk("ACPI: install SCI %d handler pass\n", irq);
+
+	return AE_OK;
+}
+
+acpi_status
+acpi_os_remove_interrupt_handler(u32 irq, OSD_HANDLER handler)
+{
+	irq_desc_t *desc;
+	struct irqaction **p;
+	unsigned long flags;
+
+	if (!acpi_irq_handler)
+		return AE_OK;
+
+	irq =3D isa_irq_to_vector(irq);
+	if (irq !=3D acpi_irq_irq) return AE_ERROR;
+
+	acpi_irq_handler =3D NULL;
+
+	desc =3D irq_desc(irq);
+	spin_lock_irqsave(&desc->lock,flags);
+	p =3D &desc->action;
+	for (;;) {
+		struct irqaction * action =3D *p;
+		if (action) {
+			struct irqaction **pp =3D p;
+			p =3D &action->next;
+			if (action->dev_id !=3D acpi_irq)
+				continue;
+
+			/* Found it - now remove it from the list of entries */
+			*pp =3D action->next;
+			if (!desc->action) {
+				desc->status |=3D IRQ_DISABLED;
+				desc->handler->shutdown(irq);
+			}
+			spin_unlock_irqrestore(&desc->lock,flags);
+
+#ifdef CONFIG_SMP
+			/* Wait to make sure it's not being used on another CPU */
+			while (desc->status & IRQ_INPROGRESS)
+				barrier();
+#endif
+			return AE_OK;
+		}
+		printk("ACPI: Trying to free free IRQ%d\n",irq);
+		spin_unlock_irqrestore(&desc->lock,flags);
+		return AE_OK;
+	}
+
+	return AE_OK;
+}
+
+#else
+acpi_status
+acpi_os_install_interrupt_handler(u32 irq, OSD_HANDLER handler, void *cont=
ext)
+{
 	acpi_irq_irq =3D irq;
 	acpi_irq_handler =3D handler;
 	acpi_irq_context =3D context;
@@ -315,7 +404,7 @@
 }
=20
 void
-acpi_os_stall(u32 us)
+acpi_os_stall_rt(u32 us)
 {
 	if (us > 10000) {
 		mdelay(us / 1000);
@@ -357,7 +446,7 @@
 acpi_status
 acpi_os_write_port(
 	ACPI_IO_ADDRESS	port,
-	u32		value,
+	NATIVE_UINT	value,
 	u32		width)
 {
 	switch (width)
@@ -410,7 +499,7 @@
 acpi_status
 acpi_os_write_memory(
 	ACPI_PHYSICAL_ADDRESS	phys_addr,
-	u32			value,
+	NATIVE_UINT		value,
 	u32			width)
 {
 	switch (width)
@@ -470,27 +559,6 @@
 	return (result ? AE_ERROR : AE_OK);
 }
=20
-#ifdef CONFIG_ACPI_KERNEL_CONFIG
-/*
- * Queue for interpreter thread
- */
-
-ACPI_STATUS
-acpi_os_queue_for_execution_rt(
-			    u32 priority,
-			    OSD_EXECUTION_CALLBACK callback,
-			    void *context)
-{
-# ifndef CONFIG_ACPI_KERNEL_CONFIG_ONLY
-	if (acpi_run(callback, context))
-		return AE_ERROR;
-# else
-	(*callback)(context);
-# endif
-	return AE_OK;
-}
-#endif
-
 acpi_status
 acpi_os_write_pci_configuration (
 	acpi_pci_id             *pci_id,
@@ -524,7 +592,7 @@
 #else /*CONFIG_ACPI_PCI*/
=20
 acpi_status
-acpi_os_read_pci_configuration (
+acpi_os_read_pci_configuration_rt (
 	acpi_pci_id	*pci_id,
 	u32		reg,
 	void		*value,
@@ -558,10 +626,10 @@
 }
=20
 acpi_status
-acpi_os_write_pci_configuration (
+acpi_os_write_pci_configuration_rt (
 	acpi_pci_id	*pci_id,
 	u32		reg,
-	u32		value,
+	NATIVE_UINT	value,
 	u32		width)
 {
 	int devfn =3D PCI_DEVFN(pci_id->device, pci_id->function);
@@ -676,6 +744,22 @@
 		acpi_os_free(dpc);
 	}
 }
+
+#ifdef CONFIG_ACPI_KERNEL_CONFIG
+/*
+ * Queue for interpreter thread
+ */
+
+acpi_status
+acpi_os_queue_for_execution_rt(
+	u32 priority,
+	OSD_EXECUTION_CALLBACK callback,
+	void *context)
+{
+	(*callback)(context);
+	return AE_OK;
+}
+#endif
=20
 acpi_status
 acpi_os_queue_for_execution(
diff -urN linux-davidm/drivers/acpi/osconf.c linux-2.4.10-lia/drivers/acpi/=
osconf.c
--- linux-davidm/drivers/acpi/osconf.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/drivers/acpi/osconf.c	Mon Sep 24 22:00:48 2001
@@ -16,6 +16,7 @@
 #include <asm/system.h>
 #include <asm/io.h>
 #include <asm/sal.h>
+#include <asm/delay.h>
=20
 #include "acpi.h"
 #include "osconf.h"
@@ -24,34 +25,22 @@
 static void * __init acpi_os_allocate_bt(u32 size);
 static void * __init acpi_os_callocate_bt(u32 size);
 static void __init acpi_os_free_bt(void *ptr);
+static void __init acpi_os_stall_bt(u32 us);
=20
-static ACPI_STATUS __init
+static acpi_status __init
 acpi_os_queue_for_execution_bt(
 	u32			priority,
 	OSD_EXECUTION_CALLBACK	callback,
 	void			*context
 	);
=20
-static ACPI_STATUS __init
-acpi_os_read_pci_cfg_byte_bt( u32 segbus, u32 func, u32 addr, u8 * val);
+static acpi_status __init
+acpi_os_read_pci_configuration_bt( acpi_pci_id *pci_id, u32 reg, void *val=
ue, u32 width);
=20
-static ACPI_STATUS __init
-acpi_os_read_pci_cfg_word_bt( u32 segbus, u32 func, u32 addr, u16 * val);
+static acpi_status __init
+acpi_os_write_pci_configuration_bt( acpi_pci_id *pci_id, u32 reg, NATIVE_U=
INT value, u32 width);
=20
-static ACPI_STATUS __init
-acpi_os_read_pci_cfg_dword_bt( u32 segbus, u32 func, u32 addr, u32 * val);
=20
-static ACPI_STATUS __init
-acpi_os_write_pci_cfg_byte_bt( u32 segbus, u32 func, u32 addr, u8 val);
-
-static ACPI_STATUS __init
-acpi_os_write_pci_cfg_word_bt( u32 segbus, u32 func, u32 addr, u16 val);
-
-static ACPI_STATUS __init
-acpi_os_write_pci_cfg_dword_bt( u32 segbus, u32 func, u32 addr, u32 val);
-
-
-static struct acpi_osd *acpi_osd;
 extern struct acpi_osd acpi_osd_rt;
 static struct acpi_osd acpi_osd_bt __initdata =3D {
 	/* these are boottime osd entries that differ from runtime entries */
@@ -59,13 +48,11 @@
 	acpi_os_callocate_bt,
 	acpi_os_free_bt,
 	acpi_os_queue_for_execution_bt,
-	acpi_os_read_pci_cfg_byte_bt,
-	acpi_os_read_pci_cfg_word_bt,
-	acpi_os_read_pci_cfg_dword_bt,
-	acpi_os_write_pci_cfg_byte_bt,
-	acpi_os_write_pci_cfg_word_bt,
-	acpi_os_write_pci_cfg_dword_bt
+	acpi_os_read_pci_configuration_bt,
+	acpi_os_write_pci_configuration_bt,
+	acpi_os_stall_bt
 };
+static struct acpi_osd *acpi_osd =3D &acpi_osd_rt;
=20
 #ifdef	CONFIG_ACPI_KERNEL_CONFIG_BM_PROFILE
 static void	__init
@@ -110,48 +97,27 @@
 	return;
 }
=20
-
-ACPI_STATUS
-acpi_os_read_pci_cfg_byte( u32 segbus, u32 func, u32 addr, u8 * val)
-{
-	return acpi_osd->read_pci_cfg_byte(segbus, func, addr, val);
-}
-
-
-ACPI_STATUS
-acpi_os_read_pci_cfg_word( u32 segbus, u32 func, u32 addr, u16 * val)
-{
-	return acpi_osd->read_pci_cfg_word(segbus, func, addr, val);
-}
-
-
-ACPI_STATUS
-acpi_os_read_pci_cfg_dword( u32 segbus, u32 func, u32 addr, u32 * val)
+void
+acpi_os_stall(u32 us)
 {
-	return acpi_osd->read_pci_cfg_dword(segbus, func, addr, val);
+	acpi_osd->stall(us);
+	return;
 }
=20
-
-ACPI_STATUS
-acpi_os_write_pci_cfg_byte( u32 segbus, u32 func, u32 addr, u8 val)
+acpi_status
+acpi_os_read_pci_configuration( acpi_pci_id *pci_id, u32 reg, void *value,=
 u32 width)
 {
-	return acpi_osd->write_pci_cfg_byte(segbus, func, addr, val);
+	return acpi_osd->read_pci_configuration(pci_id, reg, value, width);
 }
=20
=20
-ACPI_STATUS
-acpi_os_write_pci_cfg_word( u32 segbus, u32 func, u32 addr, u16 val)
+acpi_status
+acpi_os_write_pci_configuration( acpi_pci_id *pci_id, u32 reg, NATIVE_UINT=
 value, u32 width)
 {
-	return acpi_osd->write_pci_cfg_word(segbus, func, addr, val);
+	return acpi_osd->write_pci_configuration(pci_id, reg, value, width);
 }
=20
=20
-ACPI_STATUS
-acpi_os_write_pci_cfg_dword( u32 segbus, u32 func, u32 addr, u32 val)
-{
-	return acpi_osd->write_pci_cfg_dword(segbus, func, addr, val);
-}
-
 #ifdef	CONFIG_ACPI_KERNEL_CONFIG_BM_PROFILE
 /*
  * Let's profile bootmem usage to see how much we consume. J.I.
@@ -230,7 +196,17 @@
 }
=20
=20
-static ACPI_STATUS __init
+static void __init
+acpi_os_stall_bt(u32 us)
+{
+	unsigned long start =3D ia64_get_itc();
+	unsigned long cycles =3D us*733;	/* XXX: 733 or 800 */
+	while (ia64_get_itc() - start < cycles)
+		/* skip */;
+}
+
+
+static acpi_status __init
 acpi_os_queue_for_execution_bt(
 	u32			priority,
 	OSD_EXECUTION_CALLBACK	callback,
@@ -244,78 +220,67 @@
 }
=20
=20
-static ACPI_STATUS __init
-acpi_os_read_pci_cfg_byte_bt( u32 segbus, u32 func, u32 addr, u8 * val)
+static acpi_status __init
+acpi_os_read_pci_configuration_bt (
+	acpi_pci_id	*pci_id,
+	u32		reg,
+	void		*value,
+	u32		width)
 {
 	unsigned int	devfn;
 	s64		status;
 	u64		lval;
=20
-	devfn =3D PCI_DEVFN((func >> 16) & 0xffff, func & 0xffff);
-	status =3D ia64_sal_pci_config_read(PCI_CONFIG_ADDRESS((segbus & 0xffff),=
 devfn, addr), 1, &lval);
-	*val =3D lval;
-
-	return status;
-}
-
-
-static ACPI_STATUS __init
-acpi_os_read_pci_cfg_word_bt( u32 segbus, u32 func, u32 addr, u16 * val)
-{
-	unsigned int	devfn;
-	s64		status;
-	u64		lval;
+	devfn =3D PCI_DEVFN(pci_id->device, pci_id->function);
=20
-	devfn =3D PCI_DEVFN((func >> 16) & 0xffff, func & 0xffff);
-	status =3D ia64_sal_pci_config_read(PCI_CONFIG_ADDRESS((segbus & 0xffff),=
 devfn, addr), 2, &lval);
-	*val =3D lval;
+	switch (width)
+	{
+	case 8:
+		status =3D ia64_sal_pci_config_read(PCI_CONFIG_ADDRESS((pci_id->bus), de=
vfn, reg), 1, &lval);
+		*(u8*)value =3D (u8)lval;
+		break;
+	case 16:
+		status =3D ia64_sal_pci_config_read(PCI_CONFIG_ADDRESS((pci_id->bus), de=
vfn, reg), 2, &lval);
+		*(u16*)value =3D (u16)lval;
+		break;
+	case 32:
+		status =3D ia64_sal_pci_config_read(PCI_CONFIG_ADDRESS((pci_id->bus), de=
vfn, reg), 4, &lval);
+		*(u32*)value =3D (u32)lval;
+		break;
+	default:
+		BUG();
+	}
=20
 	return status;
 }
=20
=20
-static ACPI_STATUS __init
-acpi_os_read_pci_cfg_dword_bt( u32 segbus, u32 func, u32 addr, u32 * val)
+static acpi_status __init
+acpi_os_write_pci_configuration_bt (
+	acpi_pci_id	*pci_id,
+	u32		reg,
+	NATIVE_UINT	value,
+	u32		width)
 {
 	unsigned int	devfn;
 	s64		status;
-	u64		lval;
-
-	devfn =3D PCI_DEVFN((func >> 16) & 0xffff, func & 0xffff);
-	status =3D ia64_sal_pci_config_read(PCI_CONFIG_ADDRESS((segbus & 0xffff),=
 devfn, addr), 4, &lval);
-	*val =3D lval;
-
-	return status;
-}
-
-
-static ACPI_STATUS __init
-acpi_os_write_pci_cfg_byte_bt( u32 segbus, u32 func, u32 addr, u8 val)
-{
-	unsigned int	devfn;
-
-	devfn =3D PCI_DEVFN((func >> 16) & 0xffff, func & 0xffff);
-	return ia64_sal_pci_config_write(PCI_CONFIG_ADDRESS((segbus & 0xffff), de=
vfn, addr), 1, val);
-}
=20
+	devfn =3D PCI_DEVFN(pci_id->device, pci_id->function);
=20
-static ACPI_STATUS __init
-acpi_os_write_pci_cfg_word_bt( u32 segbus, u32 func, u32 addr, u16 val)
-{
-	unsigned int	devfn;
-
-	devfn =3D PCI_DEVFN((func >> 16) & 0xffff, func & 0xffff);
-	return ia64_sal_pci_config_write(PCI_CONFIG_ADDRESS((segbus & 0xffff), de=
vfn, addr), 2, val);
-}
-
-
-static ACPI_STATUS __init
-acpi_os_write_pci_cfg_dword_bt( u32 segbus, u32 func, u32 addr, u32 val)
-{
-	unsigned int	devfn;
+	switch (width)
+	{
+	case 8:
+		status =3D ia64_sal_pci_config_write(PCI_CONFIG_ADDRESS((pci_id->bus), d=
evfn, reg), 1, value);
+		break;
+	case 16:
+		status =3D ia64_sal_pci_config_write(PCI_CONFIG_ADDRESS((pci_id->bus), d=
evfn, reg), 2, value);
+		break;
+	case 32:
+		status =3D ia64_sal_pci_config_write(PCI_CONFIG_ADDRESS((pci_id->bus), d=
evfn, reg), 4, value);
+		break;
+	default:
+		BUG();
+	}
=20
-	devfn =3D PCI_DEVFN((func >> 16) & 0xffff, func & 0xffff);
-	return ia64_sal_pci_config_write(PCI_CONFIG_ADDRESS((segbus & 0xffff), de=
vfn, addr), 4, val);
+	return status;
 }
-
-
diff -urN linux-davidm/drivers/acpi/osconf.h linux-2.4.10-lia/drivers/acpi/=
osconf.h
--- linux-davidm/drivers/acpi/osconf.h	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/drivers/acpi/osconf.h	Mon Sep 24 22:01:49 2001
@@ -10,13 +10,10 @@
 	void * (*allocate)(u32 size);
 	void * (*callocate)(u32 size);
 	void  (*free)(void *ptr);
-	ACPI_STATUS (*queue_for_exec)(u32 pri, OSD_EXECUTION_CALLBACK cb, void *c=
ontext);
-	ACPI_STATUS (*read_pci_cfg_byte)(u32 bus, u32 func, u32 addr, u8 *val);
-	ACPI_STATUS (*read_pci_cfg_word)(u32 bus, u32 func, u32 addr, u16 *val);
-	ACPI_STATUS (*read_pci_cfg_dword)(u32 bus, u32 func, u32 addr, u32 *val);
-	ACPI_STATUS (*write_pci_cfg_byte)(u32 bus, u32 func, u32 addr, u8 val);
-	ACPI_STATUS (*write_pci_cfg_word)(u32 bus, u32 func, u32 addr, u16 val);
-	ACPI_STATUS (*write_pci_cfg_dword)(u32 bus, u32 func, u32 addr, u32 val);
+	acpi_status (*queue_for_exec)(u32 pri, OSD_EXECUTION_CALLBACK cb, void *c=
ontext);
+	acpi_status (*read_pci_configuration)(acpi_pci_id *pci_id, u32 reg, void =
*value, u32 width);
+	acpi_status (*write_pci_configuration)(acpi_pci_id *pci_id, u32 reg, NATI=
VE_UINT value, u32 width);
+	void (*stall)(u32 us);
 };
=20
=20
@@ -31,54 +28,30 @@
 void * acpi_os_allocate(u32 size);
 void * acpi_os_callocate(u32 size);
 void acpi_os_free(void *ptr);
+void acpi_os_stall(u32 us);
=20
+acpi_status
+acpi_os_read_pci_configuration( acpi_pci_id *pci_id, u32 reg, void *value,=
 u32 width );
=20
-ACPI_STATUS
-acpi_os_read_pci_cfg_byte( u32 segbus, u32 func, u32 addr, u8 * val);
-
-ACPI_STATUS
-acpi_os_read_pci_cfg_word( u32 segbus, u32 func, u32 addr, u16 * val);
-
-ACPI_STATUS
-acpi_os_read_pci_cfg_dword( u32 segbus, u32 func, u32 addr, u32 * val);
-
-ACPI_STATUS
-acpi_os_write_pci_cfg_byte( u32 segbus, u32 func, u32 addr, u8 val);
-
-ACPI_STATUS
-acpi_os_write_pci_cfg_word( u32 segbus, u32 func, u32 addr, u16 val);
-
-ACPI_STATUS
-acpi_os_write_pci_cfg_dword( u32 segbus, u32 func, u32 addr, u32 val);
+acpi_status
+acpi_os_write_pci_configuration( acpi_pci_id *pci_id, u32 reg, NATIVE_UINT=
 value, u32 width );
=20
=20
 /* acpi_osd_rt functions */
 extern void * acpi_os_allocate_rt(u32 size);
 extern void * acpi_os_callocate_rt(u32 size);
 extern void acpi_os_free_rt(void *ptr);
+extern void acpi_os_stall_rt(u32 us);
=20
-extern ACPI_STATUS
+extern acpi_status
 acpi_os_queue_for_execution_rt(
 	u32			priority,
 	OSD_EXECUTION_CALLBACK	callback,
 	void			*context
 	);
=20
-extern ACPI_STATUS
-acpi_os_read_pci_cfg_byte_rt( u32 segbus, u32 func, u32 addr, u8 * val);
-
-extern ACPI_STATUS
-acpi_os_read_pci_cfg_word_rt( u32 segbus, u32 func, u32 addr, u16 * val);
-
-extern ACPI_STATUS
-acpi_os_read_pci_cfg_dword_rt( u32 segbus, u32 func, u32 addr, u32 * val);
-
-extern ACPI_STATUS
-acpi_os_write_pci_cfg_byte_rt( u32 segbus, u32 func, u32 addr, u8 val);
-
-extern ACPI_STATUS
-acpi_os_write_pci_cfg_word_rt( u32 segbus, u32 func, u32 addr, u16 val);
-
-extern ACPI_STATUS
-acpi_os_write_pci_cfg_dword_rt( u32 segbus, u32 func, u32 addr, u32 val);
+extern acpi_status
+acpi_os_read_pci_configuration_rt( acpi_pci_id *pci_id, u32 reg, void *val=
ue, u32 width );
=20
+extern acpi_status
+acpi_os_write_pci_configuration_rt( acpi_pci_id *pci_id, u32 reg, NATIVE_U=
INT value, u32 width );
diff -urN linux-davidm/drivers/acpi/ospm/include/ec.h linux-2.4.10-lia/driv=
ers/acpi/ospm/include/ec.h
--- linux-davidm/drivers/acpi/ospm/include/ec.h	Mon Sep 24 15:06:44 2001
+++ linux-2.4.10-lia/drivers/acpi/ospm/include/ec.h	Mon Sep 24 22:03:30 2001
@@ -167,14 +167,14 @@
 acpi_status
 ec_io_read (
 	EC_CONTEXT              *ec,
-	u32         		io_port,
+	ACPI_IO_ADDRESS		io_port,
 	u8                      *data,
 	EC_EVENT                wait_event);
=20
 acpi_status
 ec_io_write (
 	EC_CONTEXT              *ec,
-	u32         		io_port,
+	ACPI_IO_ADDRESS		io_port,
 	u8                      data,
 	EC_EVENT                wait_event);
=20
diff -urN linux-davidm/drivers/acpi/ospm/system/sm_osl.c linux-2.4.10-lia/d=
rivers/acpi/ospm/system/sm_osl.c
--- linux-davidm/drivers/acpi/ospm/system/sm_osl.c	Mon Sep 24 15:06:44 2001
+++ linux-2.4.10-lia/drivers/acpi/ospm/system/sm_osl.c	Mon Sep 24 22:03:42 =
2001
@@ -33,7 +33,9 @@
 #include <asm/uaccess.h>
 #include <linux/acpi.h>
 #include <asm/io.h>
+#ifndef __ia64__
 #include <linux/mc146818rtc.h>
+#endif
 #include <linux/delay.h>
=20
 #include <acpi.h>
@@ -278,6 +280,7 @@
 	int                     *eof,
 	void                    *context)
 {
+#ifndef _IA64
 	char *str =3D page;
 	int len;
 	u32 sec,min,hr;
@@ -351,6 +354,9 @@
 	*start =3D page;
=20
 	return len;
+#else
+	return 0;
+#endif
 }
=20
 static int get_date_field(char **str, u32 *value)
@@ -381,6 +387,7 @@
 	unsigned long count,
 	void *data)
 {
+#ifndef _IA64
 	char buf[30];
 	char *str =3D buf;
 	u32 sec,min,hr;
@@ -520,6 +527,9 @@
 	error =3D 0;
  out:
 	return error ? error : count;
+#else
+	return 0;
+#endif
 }
=20
 static int=20
diff -urN linux-davidm/drivers/char/agp/agpgart_be.c linux-2.4.10-lia/drive=
rs/char/agp/agpgart_be.c
--- linux-davidm/drivers/char/agp/agpgart_be.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/drivers/char/agp/agpgart_be.c	Mon Sep 24 16:11:04 2001
@@ -466,9 +466,9 @@
 /*=20
  * Driver routines - start
  * Currently this module supports the following chipsets:
- * i810, i815, 440lx, 440bx, 440gx, i840, i850, via vp3, via mvp3,
- * via kx133, via kt133, amd irongate, amd 761, amd 762, ALi M1541,
- * and generic support for the SiS chipsets.
+ * i810, 440lx, 440bx, 440gx, 460gx, i840, i850, via vp3, via mvp3, via kx=
133,=20
+ * via kt133, amd irongate, ALi M1541, and generic support for the SiS=20
+ * chipsets.
  */
=20
 /* Generic Agp routines - Start */
@@ -1200,6 +1200,633 @@
=20
 #endif /* CONFIG_AGP_I810 */
=20
+#ifdef CONFIG_AGP_I460
+
+/* BIOS configures the chipset so that one of two apbase registers are use=
d */
+static u8 intel_i460_dynamic_apbase =3D 0x10;
+
+/* 460 supports multiple GART page sizes, so GART pageshift is dynamic */ =

+static u8 intel_i460_pageshift =3D 12;
+
+/* Keep track of which is larger, chipset or kernel page size. */
+static u32 intel_i460_cpk =3D 1;
+
+/* Structure for tracking partial use of 4MB GART pages */
+static u32 **i460_pg_detail =3D NULL;
+static u32 *i460_pg_count =3D NULL;
+
+#define I460_CPAGES_PER_KPAGE (PAGE_SIZE >> intel_i460_pageshift)
+#define I460_KPAGES_PER_CPAGE ((1 << intel_i460_pageshift) >> PAGE_SHIFT)
+
+#define I460_SRAM_IO_DISABLE		(1 << 4)
+#define I460_BAPBASE_ENABLE		(1 << 3)
+#define I460_AGPSIZ_MASK		0x7
+#define I460_4M_PS			(1 << 1)
+
+#define log2(x)				ffz(~(x))
+
+static int intel_i460_fetch_size(void)
+{
+	int i;
+	u8 temp;
+	aper_size_info_8 *values;
+
+	/* Determine the GART page size */
+	pci_read_config_byte(agp_bridge.dev, INTEL_I460_GXBCTL, &temp);
+	intel_i460_pageshift =3D (temp & I460_4M_PS) ? 22 : 12;
+
+	values =3D A_SIZE_8(agp_bridge.aperture_sizes);
+
+	pci_read_config_byte(agp_bridge.dev, INTEL_I460_AGPSIZ, &temp);
+
+	/* Exit now if the IO drivers for the GART SRAMS are turned off */
+	if(temp & I460_SRAM_IO_DISABLE) {
+		printk("[agpgart] GART SRAMS disabled on 460GX chipset\n");
+		printk("[agpgart] AGPGART operation not possible\n");
+		return 0;
+	}
+
+	/* Make sure we don't try to create an 2 ^ 23 entry GATT */
+	if((intel_i460_pageshift =3D 0) && ((temp & I460_AGPSIZ_MASK) =3D 4)) {
+		printk("[agpgart] We can't have a 32GB aperture with 4KB"
+			" GART pages\n");
+		return 0;
+	}
+
+	/* Determine the proper APBASE register */
+	if(temp & I460_BAPBASE_ENABLE)
+		intel_i460_dynamic_apbase =3D INTEL_I460_BAPBASE;
+	else intel_i460_dynamic_apbase =3D INTEL_I460_APBASE;
+
+	for (i =3D 0; i < agp_bridge.num_aperture_sizes; i++) {
+
+		/*
+		 * Dynamically calculate the proper num_entries and page_order=20
+		 * values for the define aperture sizes. Take care not to
+		 * shift off the end of values[i].size.
+		 */=09
+		values[i].num_entries =3D (values[i].size << 8) >>
+						(intel_i460_pageshift - 12);
+		values[i].page_order =3D log2((sizeof(u32)*values[i].num_entries)
+						>> PAGE_SHIFT);
+	}
+
+	for (i =3D 0; i < agp_bridge.num_aperture_sizes; i++) {
+		/* Neglect control bits when matching up size_value */
+		if ((temp & I460_AGPSIZ_MASK) =3D values[i].size_value) {
+			agp_bridge.previous_size +			    agp_bridge.current_size =3D (void *) (=
values + i);
+			agp_bridge.aperture_size_idx =3D i;
+			return values[i].size;
+		}
+	}
+
+	return 0;
+}
+
+/* There isn't anything to do here since 460 has no GART TLB. */=20
+static void intel_i460_tlb_flush(agp_memory * mem)
+{
+	return;
+}
+
+/*
+ * This utility function is needed to prevent corruption of the control bi=
ts
+ * which are stored along with the aperture size in 460's AGPSIZ register
+ */
+static void intel_i460_write_agpsiz(u8 size_value)
+{
+	u8 temp;
+
+	pci_read_config_byte(agp_bridge.dev, INTEL_I460_AGPSIZ, &temp);
+	pci_write_config_byte(agp_bridge.dev, INTEL_I460_AGPSIZ,
+		((temp & ~I460_AGPSIZ_MASK) | size_value));
+}
+
+static void intel_i460_cleanup(void)
+{
+	aper_size_info_8 *previous_size;
+
+	previous_size =3D A_SIZE_8(agp_bridge.previous_size);
+	intel_i460_write_agpsiz(previous_size->size_value);
+
+	if(intel_i460_cpk =3D 0)
+	{
+		vfree(i460_pg_detail);
+		vfree(i460_pg_count);
+	}
+}
+
+
+/* Control bits for Out-Of-GART coherency and Burst Write Combining */
+#define I460_GXBCTL_OOG		(1UL << 0)
+#define I460_GXBCTL_BWC		(1UL << 2)
+
+static int intel_i460_configure(void)
+{
+	union {
+		u32 small[2];
+		u64 large;
+	} temp;
+	u8 scratch;
+	int i;
+
+	aper_size_info_8 *current_size;
+
+	temp.large =3D 0;
+
+	current_size =3D A_SIZE_8(agp_bridge.current_size);
+	intel_i460_write_agpsiz(current_size->size_value);=09
+
+	/*
+	 * Do the necessary rigmarole to read all eight bytes of APBASE.
+	 * This has to be done since the AGP aperture can be above 4GB on
+	 * 460 based systems.
+	 */
+	pci_read_config_dword(agp_bridge.dev, intel_i460_dynamic_apbase,=20
+		&(temp.small[0]));
+	pci_read_config_dword(agp_bridge.dev, intel_i460_dynamic_apbase + 4,
+		&(temp.small[1]));
+
+	/* Clear BAR control bits */
+	agp_bridge.gart_bus_addr =3D temp.large & ~((1UL << 3) - 1);=20
+
+	pci_read_config_byte(agp_bridge.dev, INTEL_I460_GXBCTL, &scratch);
+	pci_write_config_byte(agp_bridge.dev, INTEL_I460_GXBCTL,
+			  (scratch & 0x02) | I460_GXBCTL_OOG | I460_GXBCTL_BWC);
+
+	/*=20
+	 * Initialize partial allocation trackers if a GART page is bigger than
+	 * a kernel page.
+	 */
+	if(I460_CPAGES_PER_KPAGE >=3D 1) {
+		intel_i460_cpk =3D 1;
+	} else {
+		intel_i460_cpk =3D 0;
+
+		i460_pg_detail =3D (void *) vmalloc(sizeof(*i460_pg_detail) *
+					current_size->num_entries);
+		i460_pg_count =3D (void *) vmalloc(sizeof(*i460_pg_count) *
+					current_size->num_entries);
+=09
+		for (i =3D 0; i < current_size->num_entries; i++) {
+			i460_pg_count[i] =3D 0;
+			i460_pg_detail[i] =3D NULL;
+		}
+	}
+
+	return 0;
+}
+
+static int intel_i460_create_gatt_table(void) {
+
+	char *table;
+	int i;
+	int page_order;
+	int num_entries;
+	void *temp;
+	unsigned int read_back;
+
+	/*
+	 * Load up the fixed address of the GART SRAMS which hold our
+	 * GATT table.
+	 */
+	table =3D (char *) __va(INTEL_I460_ATTBASE);
+
+	temp =3D agp_bridge.current_size;
+	page_order =3D A_SIZE_8(temp)->page_order;
+	num_entries =3D A_SIZE_8(temp)->num_entries;
+
+	agp_bridge.gatt_table_real =3D (u32 *) table;
+	agp_bridge.gatt_table =3D ioremap_nocache(virt_to_phys(table),
+		 			     (PAGE_SIZE * (1 << page_order)));
+	agp_bridge.gatt_bus_addr =3D virt_to_phys(agp_bridge.gatt_table_real);
+
+	for (i =3D 0; i < num_entries; i++) {
+		agp_bridge.gatt_table[i] =3D 0;
+	}
+
+	/*=20
+	 * The 460 spec says we have to read the last location written to=20
+	 * make sure that all writes have taken effect
+	 */
+	read_back =3D agp_bridge.gatt_table[i - 1];
+
+	return 0;
+}
+
+static int intel_i460_free_gatt_table(void)
+{
+	int num_entries;
+	int i;
+	void *temp;
+	unsigned int read_back;
+
+	temp =3D agp_bridge.current_size;
+
+	num_entries =3D A_SIZE_8(temp)->num_entries;
+
+	for (i =3D 0; i < num_entries; i++) {
+		agp_bridge.gatt_table[i] =3D 0;
+	}
+=09
+	/*=20
+	 * The 460 spec says we have to read the last location written to=20
+	 * make sure that all writes have taken effect
+	 */
+	read_back =3D agp_bridge.gatt_table[i - 1];
+
+	iounmap(agp_bridge.gatt_table);
+
+	return 0;
+}
+
+/* These functions are called when PAGE_SIZE exceeds the GART page size */=
=09
+
+static int intel_i460_insert_memory_cpk(agp_memory * mem,
+				     off_t pg_start, int type)
+{
+	int i, j, k, num_entries;
+	void *temp;
+	unsigned int hold;
+	unsigned int read_back;
+
+	/*=20
+	 * The rest of the kernel will compute page offsets in terms of
+	 * PAGE_SIZE.
+	 */
+	pg_start =3D I460_CPAGES_PER_KPAGE * pg_start;
+
+	temp =3D agp_bridge.current_size;
+	num_entries =3D A_SIZE_8(temp)->num_entries;
+
+	if((pg_start + I460_CPAGES_PER_KPAGE * mem->page_count) > num_entries) {
+		printk("[agpgart] Looks like we're out of AGP memory\n");
+		return -EINVAL;
+	}
+
+	j =3D pg_start;
+	while (j < (pg_start + I460_CPAGES_PER_KPAGE * mem->page_count)) {
+		if (!PGE_EMPTY(agp_bridge.gatt_table[j])) {
+			return -EBUSY;
+		}
+		j++;
+	}
+
+	if (mem->is_flushed =3D FALSE) {
+		CACHE_FLUSH();
+		mem->is_flushed =3D TRUE;
+	}
+
+	for (i =3D 0, j =3D pg_start; i < mem->page_count; i++) {
+
+		hold =3D (unsigned int) (mem->memory[i]);
+
+		for (k =3D 0; k < I460_CPAGES_PER_KPAGE; k++, j++, hold++)
+			agp_bridge.gatt_table[j] =3D hold;
+	}
+
+	/*=20
+	 * The 460 spec says we have to read the last location written to=20
+	 * make sure that all writes have taken effect
+	 */
+	read_back =3D agp_bridge.gatt_table[j - 1];
+
+	return 0;
+}
+
+static int intel_i460_remove_memory_cpk(agp_memory * mem, off_t pg_start,
+				     int type)
+{
+	int i;
+	unsigned int read_back;
+
+	pg_start =3D I460_CPAGES_PER_KPAGE * pg_start;
+
+	for (i =3D pg_start; i < (pg_start + I460_CPAGES_PER_KPAGE *=20
+							mem->page_count); i++)=20
+		agp_bridge.gatt_table[i] =3D 0;
+
+	/*=20
+	 * The 460 spec says we have to read the last location written to=20
+	 * make sure that all writes have taken effect
+	 */
+	read_back =3D agp_bridge.gatt_table[i - 1];
+
+	return 0;
+}
+
+/*
+ * These functions are called when the GART page size exceeds PAGE_SIZE.
+ *
+ * This situation is interesting since AGP memory allocations that are
+ * smaller than a single GART page are possible.  The structures i460_pg_c=
ount
+ * and i460_pg_detail track partial allocation of the large GART pages to
+ * work around this issue.
+ *
+ * i460_pg_count[pg_num] tracks the number of kernel pages in use within
+ * GART page pg_num.  i460_pg_detail[pg_num] is an array containing a
+ * psuedo-GART entry for each of the aforementioned kernel pages.  The who=
le
+ * of i460_pg_detail is equivalent to a giant GATT with page size equal to
+ * that of the kernel.
+ */=09
+
+static void *intel_i460_alloc_large_page(int pg_num)
+{
+	int i;
+	void *bp, *bp_end;
+	struct page *page;
+
+	i460_pg_detail[pg_num] =3D (void *) vmalloc(sizeof(u32) *=20
+							I460_KPAGES_PER_CPAGE);
+	if(i460_pg_detail[pg_num] =3D NULL) {
+		printk("[agpgart] Out of memory, we're in trouble...\n");
+		return NULL;
+	}
+
+	for(i =3D 0; i < I460_KPAGES_PER_CPAGE; i++)
+		i460_pg_detail[pg_num][i] =3D 0;
+
+	bp =3D (void *) __get_free_pages(GFP_KERNEL,=20
+					intel_i460_pageshift - PAGE_SHIFT);
+	if(bp =3D NULL) {
+		printk("[agpgart] Couldn't alloc 4M GART page...\n");
+		return NULL;
+	}
+
+	bp_end =3D bp + ((PAGE_SIZE *=20
+			    (1 << (intel_i460_pageshift - PAGE_SHIFT))) - 1);
+
+	for (page =3D virt_to_page(bp); page <=3D virt_to_page(bp_end); page++)
+	{
+		atomic_inc(&page->count);
+		set_bit(PG_locked, &page->flags);
+		atomic_inc(&agp_bridge.current_memory_agp);
+	}
+
+	return bp;	=09
+}
+
+static void intel_i460_free_large_page(int pg_num, unsigned long addr)
+{
+	struct page *page;
+	void *bp, *bp_end;
+
+	bp =3D (void *) __va(addr);
+	bp_end =3D bp + (PAGE_SIZE *=20
+			(1 << (intel_i460_pageshift - PAGE_SHIFT)));
+
+	vfree(i460_pg_detail[pg_num]);
+	i460_pg_detail[pg_num] =3D NULL;
+
+	for (page =3D virt_to_page(bp); page < virt_to_page(bp_end); page++)
+	{
+		atomic_dec(&page->count);
+		clear_bit(PG_locked, &page->flags);
+		wake_up(&page->wait);
+		atomic_dec(&agp_bridge.current_memory_agp);
+	}
+
+	free_pages((unsigned long) bp, intel_i460_pageshift - PAGE_SHIFT);
+}
+=09
+static int intel_i460_insert_memory_kpc(agp_memory * mem,
+				     off_t pg_start, int type)
+{
+	int i, pg, start_pg, end_pg, start_offset, end_offset, idx;
+	int num_entries;=09
+	void *temp;
+	unsigned int read_back;
+
+	temp =3D agp_bridge.current_size;
+	num_entries =3D A_SIZE_8(temp)->num_entries;
+
+	/* Figure out what pg_start means in terms of our large GART pages */
+	start_pg 	=3D pg_start / I460_KPAGES_PER_CPAGE;
+	start_offset 	=3D pg_start % I460_KPAGES_PER_CPAGE;
+	end_pg 		=3D (pg_start + mem->page_count - 1) /=20
+							I460_KPAGES_PER_CPAGE;
+	end_offset 	=3D (pg_start + mem->page_count - 1) %=20
+							I460_KPAGES_PER_CPAGE;
+
+	if(end_pg > num_entries)
+	{
+		printk("[agpgart] Looks like we're out of AGP memory\n");
+		return -EINVAL;
+	}
+
+	/* Check if the requested region of the aperture is free */
+	for(pg =3D start_pg; pg <=3D end_pg; pg++)
+	{
+		/* Allocate new GART pages if necessary */
+		if(i460_pg_detail[pg] =3D NULL) {
+			temp =3D intel_i460_alloc_large_page(pg);
+			if(temp =3D NULL)
+				return -ENOMEM;
+			agp_bridge.gatt_table[pg] =3D agp_bridge.mask_memory(
+			    			       (unsigned long) temp, 0);
+			read_back =3D agp_bridge.gatt_table[pg];
+		}
+
+		for(idx =3D ((pg =3D start_pg) ? start_offset : 0);
+		    idx < ((pg =3D end_pg) ? (end_offset + 1)=20
+				       : I460_KPAGES_PER_CPAGE);
+		    idx++)=20
+		{
+			if(i460_pg_detail[pg][idx] !=3D 0)
+				return -EBUSY;
+		}
+	}
+	=09
+	if (mem->is_flushed =3D FALSE) {
+		CACHE_FLUSH();
+		mem->is_flushed =3D TRUE;
+	}
+
+	for(pg =3D start_pg, i =3D 0; pg <=3D end_pg; pg++)
+	{
+		for(idx =3D ((pg =3D start_pg) ? start_offset : 0);
+		    idx < ((pg =3D end_pg) ? (end_offset + 1)
+				       : I460_KPAGES_PER_CPAGE);
+		    idx++, i++)
+		{
+			i460_pg_detail[pg][idx] =3D agp_bridge.gatt_table[pg] +=20
+						      ((idx * PAGE_SIZE) >> 12);
+			i460_pg_count[pg]++;
+
+			/* Finally we fill in mem->memory... */
+			mem->memory[i] =3D ((unsigned long) (0xffffff &=20
+						i460_pg_detail[pg][idx])) << 12;
+		}
+	}
+
+	return 0;
+}
+=09
+static int intel_i460_remove_memory_kpc(agp_memory * mem,
+				     off_t pg_start, int type)
+{
+	int i, pg, start_pg, end_pg, start_offset, end_offset, idx;
+	int num_entries;
+	void *temp;
+	unsigned int read_back;
+	unsigned long addr;
+
+	temp =3D agp_bridge.current_size;
+	num_entries =3D A_SIZE_8(temp)->num_entries;
+
+	/* Figure out what pg_start means in terms of our large GART pages */
+	start_pg 	=3D pg_start / I460_KPAGES_PER_CPAGE;
+	start_offset 	=3D pg_start % I460_KPAGES_PER_CPAGE;
+	end_pg 		=3D (pg_start + mem->page_count - 1) /=20
+						I460_KPAGES_PER_CPAGE;
+	end_offset 	=3D (pg_start + mem->page_count - 1) %=20
+						I460_KPAGES_PER_CPAGE;
+
+	for(i =3D 0, pg =3D start_pg; pg <=3D end_pg; pg++)
+	{
+		for(idx =3D ((pg =3D start_pg) ? start_offset : 0);
+		    idx < ((pg =3D end_pg) ? (end_offset + 1)
+				       : I460_KPAGES_PER_CPAGE);
+		    idx++, i++)=20
+		{
+			mem->memory[i] =3D 0;
+			i460_pg_detail[pg][idx] =3D 0;
+			i460_pg_count[pg]--;
+		}
+
+		/* Free GART pages if they are unused */
+		if(i460_pg_count[pg] =3D 0) {
+			addr =3D (0xffffffUL & (unsigned long)=20
+					     (agp_bridge.gatt_table[pg])) << 12;
+
+			agp_bridge.gatt_table[pg] =3D 0;
+			read_back =3D agp_bridge.gatt_table[pg];
+
+			intel_i460_free_large_page(pg, addr);
+		}
+	}
+	=09
+	return 0;
+}
+
+/* Dummy routines to call the approriate {cpk,kpc} function */
+
+static int intel_i460_insert_memory(agp_memory * mem,
+				     off_t pg_start, int type)
+{
+	if(intel_i460_cpk)
+		return intel_i460_insert_memory_cpk(mem, pg_start, type);
+	else
+		return intel_i460_insert_memory_kpc(mem, pg_start, type);
+}
+
+static int intel_i460_remove_memory(agp_memory * mem,
+				     off_t pg_start, int type)
+{
+	if(intel_i460_cpk)
+		return intel_i460_remove_memory_cpk(mem, pg_start, type);
+	else
+		return intel_i460_remove_memory_kpc(mem, pg_start, type);
+}
+
+/*
+ * If the kernel page size is smaller that the chipset page size, we don't
+ * want to allocate memory until we know where it is to be bound in the
+ * aperture (a multi-kernel-page alloc might fit inside of an already
+ * allocated GART page).  Consequently, don't allocate or free anything
+ * if i460_cpk (meaning chipset pages per kernel page) isn't set.
+ *
+ * Let's just hope nobody counts on the allocated AGP memory being there
+ * before bind time (I don't think current drivers do)...
+ */=20
+static unsigned long intel_i460_alloc_page(void)
+{
+	if(intel_i460_cpk)
+		return agp_generic_alloc_page();
+
+	/* Returning NULL would cause problems */
+	return ((unsigned long) ~0UL);
+}
+
+static void intel_i460_destroy_page(unsigned long page)
+{
+	if(intel_i460_cpk)
+		agp_generic_destroy_page(page);
+}
+
+static gatt_mask intel_i460_masks[] +{
+	{=20
+	  INTEL_I460_GATT_VALID,=20
+	  0
+	}
+};
+
+static unsigned long intel_i460_mask_memory(unsigned long addr, int type) =

+{
+	/* Make sure the returned address is a valid GATT entry */
+	return (agp_bridge.masks[0].mask | (((addr &=20
+		     ~((1 << intel_i460_pageshift) - 1)) & 0xffffff000) >> 12));
+}
+
+static unsigned long intel_i460_unmask_memory(unsigned long addr)
+{
+	/* Turn a GATT entry into a physical address */
+	return ((addr & 0xffffff) << 12);
+}
+
+static aper_size_info_8 intel_i460_sizes[3] +{
+	/*=20
+	 * The 32GB aperture is only available with a 4M GART page size.
+	 * Due to the dynamic GART page size, we can't figure out page_order
+	 * or num_entries until runtime.
+	 */
+	{32768, 0, 0, 4},
+	{1024, 0, 0, 2},
+	{256, 0, 0, 1}
+};
+
+static int __init intel_i460_setup (struct pci_dev *pdev)
+{
+
+        agp_bridge.masks =3D intel_i460_masks;
+        agp_bridge.num_of_masks =3D 1;
+        agp_bridge.aperture_sizes =3D (void *) intel_i460_sizes;
+        agp_bridge.size_type =3D U8_APER_SIZE;
+        agp_bridge.num_aperture_sizes =3D 3;
+        agp_bridge.dev_private_data =3D NULL;
+        agp_bridge.needs_scratch_page =3D FALSE;
+        agp_bridge.configure =3D intel_i460_configure;
+        agp_bridge.fetch_size =3D intel_i460_fetch_size;
+        agp_bridge.cleanup =3D intel_i460_cleanup;
+        agp_bridge.tlb_flush =3D intel_i460_tlb_flush;
+        agp_bridge.mask_memory =3D intel_i460_mask_memory;
+        agp_bridge.unmask_memory =3D intel_i460_unmask_memory;
+        agp_bridge.agp_enable =3D agp_generic_agp_enable;
+        agp_bridge.cache_flush =3D global_cache_flush;
+        agp_bridge.create_gatt_table =3D intel_i460_create_gatt_table;
+        agp_bridge.free_gatt_table =3D intel_i460_free_gatt_table;
+        agp_bridge.insert_memory =3D intel_i460_insert_memory;
+        agp_bridge.remove_memory =3D intel_i460_remove_memory;
+        agp_bridge.alloc_by_type =3D agp_generic_alloc_by_type;
+        agp_bridge.free_by_type =3D agp_generic_free_by_type;
+        agp_bridge.agp_alloc_page =3D intel_i460_alloc_page;
+        agp_bridge.agp_destroy_page =3D intel_i460_destroy_page;
+#if 0
+	agp_bridge.suspend =3D ??;
+	agp_bridge.resume =3D ??;
+#endif
+	agp_bridge.cant_use_aperture =3D 1;
+
+        return 0;
+
+        (void) pdev; /* unused */
+}
+
+#endif		/* CONFIG_AGP_I460 */
+
 #ifdef CONFIG_AGP_INTEL
=20
 static int intel_fetch_size(void)
@@ -1415,7 +2042,6 @@
 	agp_bridge.tlb_flush =3D intel_tlbflush;
 	agp_bridge.mask_memory =3D intel_mask_memory;
 	agp_bridge.unmask_memory =3D agp_generic_unmask_memory;
-	agp_bridge.unmask_memory =3D agp_generic_unmask_memory;
 	agp_bridge.agp_enable =3D agp_generic_agp_enable;
 	agp_bridge.cache_flush =3D global_cache_flush;
 	agp_bridge.create_gatt_table =3D agp_generic_create_gatt_table;
@@ -1449,6 +2075,7 @@
 	agp_bridge.cleanup =3D intel_cleanup;
 	agp_bridge.tlb_flush =3D intel_tlbflush;
 	agp_bridge.mask_memory =3D intel_mask_memory;
+	agp_bridge.unmask_memory =3D agp_generic_unmask_memory;
 	agp_bridge.agp_enable =3D agp_generic_agp_enable;
 	agp_bridge.cache_flush =3D global_cache_flush;
 	agp_bridge.create_gatt_table =3D agp_generic_create_gatt_table;
diff -urN linux-davidm/drivers/char/drm/ati_pcigart.h linux-2.4.10-lia/driv=
ers/char/drm/ati_pcigart.h
--- linux-davidm/drivers/char/drm/ati_pcigart.h	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/drivers/char/drm/ati_pcigart.h	Mon Sep 24 15:57:21 2001
@@ -106,6 +106,7 @@
 		goto done;
 	}
=20
+#if defined(__alpha__) && (LINUX_VERSION_CODE >=3D 0x020400)
 	if ( !dev->pdev ) {
 		DRM_ERROR( "PCI device unknown!\n" );
 		goto done;
@@ -120,6 +121,9 @@
 		address =3D 0;
 		goto done;
 	}
+#else
+	bus_address =3D virt_to_bus( (void *)address );
+#endif
=20
 	pci_gart =3D (u32 *)address;
=20
@@ -129,6 +133,7 @@
 	memset( pci_gart, 0, ATI_MAX_PCIGART_PAGES * sizeof(u32) );
=20
 	for ( i =3D 0 ; i < pages ; i++ ) {
+#if defined(__alpha__) && (LINUX_VERSION_CODE >=3D 0x020400)
 		/* we need to support large memory configurations */
 		entry->busaddr[i] =3D pci_map_single(dev->pdev,
 					   page_address( entry->pagelist[i] ),
@@ -142,7 +147,9 @@
 			goto done;
 		}
 		page_base =3D (u32) entry->busaddr[i];
-
+#else
+		page_base =3D page_to_bus( entry->pagelist[i] );
+#endif
 		for (j =3D 0; j < (PAGE_SIZE / ATI_PCIGART_PAGE_SIZE); j++) {
 			*pci_gart++ =3D cpu_to_le32( page_base );
 			page_base +=3D ATI_PCIGART_PAGE_SIZE;
@@ -167,6 +174,7 @@
 			      unsigned long addr,
 			      dma_addr_t bus_addr)
 {
+#if defined(__alpha__) && (LINUX_VERSION_CODE >=3D 0x020400)
 	drm_sg_mem_t *entry =3D dev->sg;
 	unsigned long pages;
 	int i;
@@ -191,6 +199,8 @@
 					 PAGE_SIZE, PCI_DMA_TODEVICE);
 		}
 	}
+
+#endif
=20
 	if ( addr ) {
 		DRM(ati_free_pcigart_table)( addr );
diff -urN linux-davidm/drivers/char/drm/drmP.h linux-2.4.10-lia/drivers/cha=
r/drm/drmP.h
--- linux-davidm/drivers/char/drm/drmP.h	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/drivers/char/drm/drmP.h	Mon Sep 24 16:13:22 2001
@@ -87,17 +87,6 @@
 #define pci_unmap_single(hwdev, dma_addr, size, direction)
 #endif
=20
-/* page_to_bus for earlier kernels, not optimal in all cases */
-#ifndef page_to_bus
-#define page_to_bus(page)	((unsigned int)(virt_to_bus(page_address(page))))
-#endif
-
-/* We just use virt_to_bus for pci_map_single on older kernels */
-#if LINUX_VERSION_CODE < 0x020400
-#define pci_map_single(hwdev, ptr, size, direction)	virt_to_bus(ptr)
-#define pci_unmap_single(hwdev, dma_addr, size, direction)
-#endif
-
 /* DRM template customization defaults
  */
 #ifndef __HAVE_AGP
@@ -377,14 +366,13 @@
    if (len > DRM_PROC_LIMIT) { ret; *eof =3D 1; return len - offset; }
=20
 				/* Mapping helper macros */
-#define DRM_IOREMAP(map, dev)						\
+#define DRM_IOREMAP(map)						\
 	(map)->handle =3D DRM(ioremap)( (map)->offset, (map)->size, (dev) )
=20
-#define DRM_IOREMAPFREE(map, dev)					\
+#define DRM_IOREMAPFREE(map)						\
 	do {								\
 		if ( (map)->handle && (map)->size )			\
-			DRM(ioremapfree)( (map)->handle,		\
-						 (map)->size, (dev) );	\
+			DRM(ioremapfree)( (map)->handle, (map)->size, (dev) );	\
 	} while (0)
=20
 #define DRM_FIND_MAP(_map, _o)						\
@@ -838,10 +826,8 @@
 extern unsigned long DRM(alloc_pages)(int order, int area);
 extern void	     DRM(free_pages)(unsigned long address, int order,
 				     int area);
-extern void	     *DRM(ioremap)(unsigned long offset,
-					unsigned long size, drm_device_t *dev);
-extern void	     DRM(ioremapfree)(void *pt,
-					unsigned long size, drm_device_t *dev);
+extern void	     *DRM(ioremap)(unsigned long offset, unsigned long size, d=
rm_device_t *dev);
+extern void	     DRM(ioremapfree)(void *pt, unsigned long size, drm_device=
_t *dev);
=20
 #if __REALLY_HAVE_AGP
 extern agp_memory    *DRM(alloc_agp)(int pages, u32 type);
diff -urN linux-davidm/drivers/char/drm/drm_memory.h linux-2.4.10-lia/drive=
rs/char/drm/drm_memory.h
--- linux-davidm/drivers/char/drm/drm_memory.h	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/drivers/char/drm/drm_memory.h	Wed Aug 22 11:05:01 2001
@@ -309,6 +309,11 @@
 void *DRM(ioremap)(unsigned long offset, unsigned long size, drm_device_t =
*dev)
 {
 	void *pt;
+#if __REALLY_HAVE_AGP
+	drm_map_t *map =3D NULL;
+	drm_map_list_t *r_list;
+	struct list_head *list;
+#endif
=20
 	if (!size) {
 		DRM_MEM_ERROR(DRM_MEM_MAPPINGS,
@@ -316,52 +321,51 @@
 		return NULL;
 	}
=20
-	if(dev->agp->cant_use_aperture =3D 0) {
+#if __REALLY_HAVE_AGP
+	if(dev->agp->cant_use_aperture =3D 0)
 		goto standard_ioremap;
-	} else {
-		drm_map_t *map    =3D NULL;
-		drm_map_list_t  *r_list;
-		struct list_head *list, *head;
-
-		list_for_each(list, &dev->maplist->head) {
-			r_list =3D (drm_map_list_t *)list;
-			map =3D r_list->map;
-			if (!map) continue;
-			if (map->offset <=3D offset &&
-				(map->offset + map->size) >=3D (offset + size))
+
+	list_for_each(list, &dev->maplist->head) {
+		r_list =3D (drm_map_list_t *)list;
+		map =3D r_list->map;
+		if (!map) continue;
+		if (map->offset <=3D offset &&
+			(map->offset + map->size) >=3D (offset + size))
+			break;
+	}
+=09
+	if(map && map->type =3D _DRM_AGP) {
+		struct drm_agp_mem *agpmem;
+
+		for(agpmem =3D dev->agp->memory; agpmem;
+					agpmem =3D agpmem->next) {
+			if(agpmem->bound <=3D offset &&
+			   (agpmem->bound + (agpmem->pages
+				<< PAGE_SHIFT)) >=3D (offset + size))
 				break;
 		}
-	=09
-		if(map && map->type =3D _DRM_AGP) {
-			struct drm_agp_mem *agpmem;
-
-			for(agpmem =3D dev->agp->memory; agpmem;
-						agpmem =3D agpmem->next) {
-				if(agpmem->bound <=3D offset &&
-				   (agpmem->bound + (agpmem->pages
-					<< PAGE_SHIFT)) >=3D (offset + size))
-					break;
-			}
-
-			if(agpmem =3D NULL)
-				goto standard_ioremap;
-
-			pt =3D agpmem->memory->vmptr + (offset - agpmem->bound);
-			goto ioremap_success;
-		} else {
-			goto standard_ioremap;
-		}
+
+		if(agpmem =3D NULL)
+			goto ioremap_failure;
+
+		pt =3D agpmem->memory->vmptr + (offset - agpmem->bound);
+		goto ioremap_success;
 	}
=20
 standard_ioremap:
+#endif
 	if (!(pt =3D ioremap(offset, size))) {
+#if __REALLY_HAVE_AGP
+ioremap_failure:
+#endif
 		spin_lock(&DRM(mem_lock));
 		++DRM(mem_stats)[DRM_MEM_MAPPINGS].fail_count;
 		spin_unlock(&DRM(mem_lock));
 		return NULL;
 	}
-
+#if __REALLY_HAVE_AGP
 ioremap_success:
+#endif
 	spin_lock(&DRM(mem_lock));
 	++DRM(mem_stats)[DRM_MEM_MAPPINGS].succeed_count;
 	DRM(mem_stats)[DRM_MEM_MAPPINGS].bytes_allocated +=3D size;
@@ -377,7 +381,11 @@
 	if (!pt)
 		DRM_MEM_ERROR(DRM_MEM_MAPPINGS,
 			      "Attempt to free NULL pointer\n");
+#if __REALLY_HAVE_AGP
 	else if(dev->agp->cant_use_aperture =3D 0)
+#else
+	else
+#endif
 		iounmap(pt);
=20
 	spin_lock(&DRM(mem_lock));
diff -urN linux-davidm/drivers/char/drm/drm_scatter.h linux-2.4.10-lia/driv=
ers/char/drm/drm_scatter.h
--- linux-davidm/drivers/char/drm/drm_scatter.h	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/drivers/char/drm/drm_scatter.h	Mon Sep 24 15:25:55 2001
@@ -47,9 +47,11 @@
=20
 	vfree( entry->virtual );
=20
+#if defined(__alpha__) && (LINUX_VERSION_CODE >=3D 0x020400)
 	DRM(free)( entry->busaddr,
 		   entry->pages * sizeof(*entry->busaddr),
 		   DRM_MEM_PAGES );
+#endif
 	DRM(free)( entry->pagelist,
 		   entry->pages * sizeof(*entry->pagelist),
 		   DRM_MEM_PAGES );
@@ -97,6 +99,7 @@
 		return -ENOMEM;
 	}
=20
+#if defined(__alpha__) && (LINUX_VERSION_CODE >=3D 0x020400)
 	entry->busaddr =3D DRM(alloc)( pages * sizeof(*entry->busaddr),
 				     DRM_MEM_PAGES );
 	if ( !entry->busaddr ) {
@@ -109,12 +112,15 @@
 		return -ENOMEM;
 	}
 	memset( (void *)entry->busaddr, 0, pages * sizeof(*entry->busaddr) );
+#endif
=20
 	entry->virtual =3D vmalloc_32( pages << PAGE_SHIFT );
 	if ( !entry->virtual ) {
+#if defined(__alpha__) && (LINUX_VERSION_CODE >=3D 0x020400)
 		DRM(free)( entry->busaddr,
 			   entry->pages * sizeof(*entry->busaddr),
 			   DRM_MEM_PAGES );
+#endif
 		DRM(free)( entry->pagelist,
 			   entry->pages * sizeof(*entry->pagelist),
 			   DRM_MEM_PAGES );
diff -urN linux-davidm/drivers/char/drm/drm_vm.h linux-2.4.10-lia/drivers/c=
har/drm/drm_vm.h
--- linux-davidm/drivers/char/drm/drm_vm.h	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/drivers/char/drm/drm_vm.h	Mon Sep 24 16:16:20 2001
@@ -89,7 +89,7 @@
=20
 	if (map && map->type =3D _DRM_AGP) {
 		unsigned long offset =3D address - vma->vm_start;
-		unsigned long baddr =3D VM_OFFSET(vma) + offset;
+		unsigned long baddr =3D VM_OFFSET(vma) + offset, paddr;
 		struct drm_agp_mem *agpmem;
 		struct page *page;
=20
@@ -115,8 +115,19 @@
                  * Get the page, inc the use count, and return it
                  */
 		offset =3D (baddr - agpmem->bound) >> PAGE_SHIFT;
-		agpmem->memory->memory[offset] &=3D dev->agp->page_mask;
-		page =3D virt_to_page(__va(agpmem->memory->memory[offset]));
+
+		/*
+		 * This is bad.  What we really want to do here is unmask
+		 * the GART table entry held in the agp_memory structure.
+		 * There isn't a convenient way to call agp_bridge.unmask_
+		 * memory from here, so hard code it for now.
+		 */
+#if defined(__ia64__)
+		paddr =3D (agpmem->memory->memory[offset] & 0xffffff) << 12;
+#else
+		paddr =3D agpmem->memory->memory[offset] & dev->agp->page_mask;
+#endif
+		page =3D virt_to_page(__va(paddr));
 		get_page(page);
=20
 		DRM_DEBUG("baddr =3D 0x%lx page =3D 0x%p, offset =3D 0x%lx\n",
@@ -503,15 +514,21 @@
=20
 	switch (map->type) {
         case _DRM_AGP:
-#if defined(__alpha__)
-                /*
-                 * On Alpha we can't talk to bus dma address from the
-                 * CPU, so for memory of type DRM_AGP, we'll deal with
-                 * sorting out the real physical pages and mappings
-                 * in nopage()
-                 */
-                vma->vm_ops =3D &DRM(vm_ops);
-                break;
+#if __REALLY_HAVE_AGP
+		if(dev->agp->cant_use_aperture =3D 1) {
+                	/*
+                	 * On some systems we can't talk to bus dma address from
+                	 * the CPU, so for memory of type DRM_AGP, we'll deal
+                	 * with sorting out the real physical pages and mappings
+                	 * in nopage()
+                	 */
+                	vma->vm_ops =3D &DRM(vm_ops);
+#if defined(__ia64__)
+			if (map->type !=3D _DRM_AGP)
+				vma->vm_page_prot =3D pgprot_writecombine(vma->vm_page_prot);
+#endif
+			goto mapswitch_out;
+		}
 #endif
                 /* fall through to _DRM_FRAME_BUFFER... */       =20
 	case _DRM_FRAME_BUFFER:
@@ -565,6 +582,9 @@
 	default:
 		return -EINVAL;	/* This should never happen. */
 	}
+#if __REALLY_HAVE_AGP
+mapswitch_out:
+#endif
 	vma->vm_flags |=3D VM_LOCKED | VM_SHM; /* Don't swap */
=20
 #if LINUX_VERSION_CODE < 0x020203 /* KERNEL_VERSION(2,2,3) */
diff -urN linux-davidm/drivers/char/drm/r128_cce.c linux-2.4.10-lia/drivers=
/char/drm/r128_cce.c
--- linux-davidm/drivers/char/drm/r128_cce.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/drivers/char/drm/r128_cce.c	Mon Sep 24 15:25:55 2001
@@ -384,11 +384,20 @@
 		tmp_ofs =3D dev_priv->ring_rptr->offset - dev->sg->handle;
 		page_ofs =3D tmp_ofs >> PAGE_SHIFT;
=20
+#if defined(__alpha__) && (LINUX_VERSION_CODE >=3D 0x020400)
 		R128_WRITE( R128_PM4_BUFFER_DL_RPTR_ADDR,
      			    entry->busaddr[page_ofs]);
 		DRM_DEBUG( "ring rptr: offset=3D0x%08x handle=3D0x%08lx\n",
 			   entry->busaddr[page_ofs],
      			   entry->handle + tmp_ofs );
+#else
+		R128_WRITE( R128_PM4_BUFFER_DL_RPTR_ADDR,
+			    page_to_bus(entry->pagelist[page_ofs]));
+
+		DRM_DEBUG( "ring rptr: offset=3D0x%08lx handle=3D0x%08lx\n",
+			   page_to_bus(entry->pagelist[page_ofs]),
+			   entry->handle + tmp_ofs );
+#endif
 	}
=20
 	/* Set watermark control */
@@ -658,9 +667,9 @@
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
@@ -668,6 +677,21 @@
 				DRM_ERROR( "failed to cleanup PCI GART!\n" );
 		}
=20
+#if defined(CONFIG_AGP_I460) && defined(__ia64__)
+		/*
+		 * Free the page we grabbed for RPTR_ADDR
+		 */
+		if( dev->agp->agp_info.chipset =3D INTEL_460GX ) {
+			unsigned long alt_rh_off +				(unsigned long) dev_priv->ring.head;
+
+			atomic_dec(&virt_to_page(alt_rh_off)->count);
+			clear_bit(PG_locked, &virt_to_page(alt_rh_off)->flags);
+			wake_up(&virt_to_page(alt_rh_off)->wait);
+			free_page(alt_rh_off);
+		}
+#endif
+=09
 		DRM(free)( dev->dev_private, sizeof(drm_r128_private_t),
 			   DRM_MEM_DRIVER );
 		dev->dev_private =3D NULL;
diff -urN linux-davidm/drivers/char/drm/radeon_cp.c linux-2.4.10-lia/driver=
s/char/drm/radeon_cp.c
--- linux-davidm/drivers/char/drm/radeon_cp.c	Mon Sep 24 22:31:43 2001
+++ linux-2.4.10-lia/drivers/char/drm/radeon_cp.c	Mon Sep 24 15:25:55 2001
@@ -640,11 +640,19 @@
 		tmp_ofs =3D dev_priv->ring_rptr->offset - dev->sg->handle;
 		page_ofs =3D tmp_ofs >> PAGE_SHIFT;
=20
+#if defined(__alpha__) && (LINUX_VERSION_CODE >=3D 0x020400)
 		RADEON_WRITE( RADEON_CP_RB_RPTR_ADDR,
 			     entry->busaddr[page_ofs]);
 		DRM_DEBUG( "ring rptr: offset=3D0x%08x handle=3D0x%08lx\n",
 			   entry->busaddr[page_ofs],
 			   entry->handle + tmp_ofs );
+#else
+		RADEON_WRITE( RADEON_CP_RB_RPTR_ADDR,
+			     entry->busaddr[page_ofs]);
+		DRM_DEBUG( "ring rptr: offset=3D0x%08x handle=3D0x%08lx\n",
+			   entry->busaddr[page_ofs],
+			   entry->handle + tmp_ofs );
+#endif
 	}
=20
 	/* Set ring buffer size */
@@ -1002,9 +1010,9 @@
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
@@ -1012,6 +1020,21 @@
 				DRM_ERROR( "failed to cleanup PCI GART!\n" );
 		}
=20
+#if defined(CONFIG_AGP_I460) && defined(__ia64__)
+		/*
+		 * Free the page we grabbed for RPTR_ADDR
+		 */
+		if( dev->agp->agp_info.chipset =3D INTEL_460GX ) {
+			unsigned long alt_rh_off +				(unsigned long) dev_priv->ring.head;
+
+			atomic_dec(&virt_to_page(alt_rh_off)->count);
+			clear_bit(PG_locked, &virt_to_page(alt_rh_off)->flags);
+			wake_up(&virt_to_page(alt_rh_off)->wait);
+			free_page(alt_rh_off);
+		}
+#endif
+=09
 		DRM(free)( dev->dev_private, sizeof(drm_radeon_private_t),
 			   DRM_MEM_DRIVER );
 		dev->dev_private =3D NULL;
diff -urN linux-davidm/fs/exec.c linux-2.4.10-lia/fs/exec.c
--- linux-davidm/fs/exec.c	Mon Sep 24 22:31:44 2001
+++ linux-2.4.10-lia/fs/exec.c	Mon Sep 24 22:04:08 2001
@@ -176,7 +176,7 @@
 }
=20
 /*
- * 'copy_strings()' copies argument/envelope strings from user
+ * 'copy_strings()' copies argument/environment strings from user
  * memory to free pages in kernel mem. These are in a format ready
  * to be put directly into the top of new user memory.
  */
diff -urN linux-davidm/fs/inode.c linux-2.4.10-lia/fs/inode.c
--- linux-davidm/fs/inode.c	Mon Sep 24 22:31:45 2001
+++ linux-2.4.10-lia/fs/inode.c	Mon Sep 24 21:29:26 2001
@@ -16,7 +16,6 @@
 #include <linux/swap.h>
 #include <linux/swapctl.h>
 #include <linux/prefetch.h>
-#include <linux/locks.h>
=20
 /*
  * New inode.c implementation.
@@ -836,7 +835,7 @@
 {
 	struct inode * inode;
=20
-	prefetch_spin_lock(&inode_lock);
+	spin_lock_prefetch(&inode_lock);
 =09
 	inode =3D alloc_inode();
 	if (inode) {
diff -urN linux-davidm/fs/namei.c linux-2.4.10-lia/fs/namei.c
--- linux-davidm/fs/namei.c	Mon Sep 24 15:08:16 2001
+++ linux-2.4.10-lia/fs/namei.c	Mon Sep 24 22:04:25 2001
@@ -629,10 +629,14 @@
 static int __emul_lookup_dentry(const char *name, struct nameidata *nd)
 {
 	if (path_walk(name, nd))
-		return 0;
+		return 0;		/* something went wrong... */
=20
-	if (!nd->dentry->d_inode) {
+	if (!nd->dentry->d_inode || S_ISDIR(nd->dentry->d_inode->i_mode)) {
 		struct nameidata nd_root;
+		/*
+		 * NAME was not found in alternate root or it's a directory.  Try to find
+		 * it in the normal root:
+		 */
 		nd_root.last_type =3D LAST_ROOT;
 		nd_root.flags =3D nd->flags;
 		read_lock(&current->fs->lock);
@@ -642,12 +646,14 @@
 		if (path_walk(name, &nd_root))
 			return 1;
 		if (nd_root.dentry->d_inode) {
+			/* file exists in normal root filesystem: */
 			path_release(nd);
 			nd->dentry =3D nd_root.dentry;
 			nd->mnt =3D nd_root.mnt;
 			nd->last =3D nd_root.last;
 			return 1;
 		}
+		/* file doesn't exist */
 		path_release(&nd_root);
 	}
 	return 1;
diff -urN linux-davidm/include/asm-ia64/ia32.h linux-2.4.10-lia/include/asm=
-ia64/ia32.h
--- linux-davidm/include/asm-ia64/ia32.h	Tue Jul 31 10:30:09 2001
+++ linux-2.4.10-lia/include/asm-ia64/ia32.h	Mon Sep 24 22:56:58 2001
@@ -33,7 +33,9 @@
 typedef __kernel_fsid_t	       __kernel_fsid_t32;
=20
 #define IA32_PAGE_SHIFT		12	/* 4KB pages */
-#define IA32_PAGE_SIZE		(1ULL << IA32_PAGE_SHIFT)
+#define IA32_PAGE_SIZE		(1UL << IA32_PAGE_SHIFT)
+#define IA32_PAGE_MASK		(~(IA32_PAGE_SIZE - 1))
+#define IA32_PAGE_ALIGN(addr)	(((addr) + IA32_PAGE_SIZE - 1) & IA32_PAGE_M=
ASK)
 #define IA32_CLOCKS_PER_SEC	100	/* Cast in stone for IA32 Linux */
 #define IA32_TICK(tick)		((unsigned long long)(tick) * IA32_CLOCKS_PER_SEC=
 / CLOCKS_PER_SEC)
=20
@@ -46,6 +48,9 @@
        __kernel_pid_t32 l_pid;
 };
=20
+#define F_GETLK64	12
+#define F_SETLK64	13
+#define F_SETLKW64	14
=20
 /* sigcontext.h */
 /*
@@ -103,13 +108,19 @@
 #define _IA32_NSIG_BPW	       32
 #define _IA32_NSIG_WORDS	       (_IA32_NSIG / _IA32_NSIG_BPW)
=20
+#define IA32_SET_SA_HANDLER(ka,handler,restorer)				\
+				((ka)->sa.sa_handler =3D (__sighandler_t)		\
+					(((unsigned long)(restorer) << 32)	\
+					 | ((handler) & 0xffffffff)))
+#define IA32_SA_HANDLER(ka)	((unsigned long) (ka)->sa.sa_handler & 0xfffff=
fff)
+#define IA32_SA_RESTORER(ka)	((unsigned long) (ka)->sa.sa_handler >> 32)
+
 typedef struct {
        unsigned int sig[_IA32_NSIG_WORDS];
 } sigset32_t;
=20
 struct sigaction32 {
-       unsigned int  sa_handler;	/* Really a pointer, but need to deal
-					     with 32 bits */
+       unsigned int sa_handler;		/* Really a pointer, but need to deal wit=
h 32 bits */
        unsigned int sa_flags;
        unsigned int sa_restorer;	/* Another 32 bit pointer */
        sigset32_t sa_mask;		/* A 32 bit mask */
@@ -162,6 +173,31 @@
        unsigned int  __unused5;
 };
=20
+struct stat64 {
+	unsigned short	st_dev;
+	unsigned char	__pad0[10];
+	unsigned int	__st_ino;
+	unsigned int	st_mode;
+	unsigned int	st_nlink;
+	unsigned int	st_uid;
+	unsigned int	st_gid;
+	unsigned short	st_rdev;
+	unsigned char	__pad3[10];
+	unsigned int	st_size_lo;
+	unsigned int	st_size_hi;
+	unsigned int	st_blksize;
+	unsigned int	st_blocks;	/* Number 512-byte blocks allocated. */
+	unsigned int	__pad4;		/* future possible st_blocks high bits */
+	unsigned int	st_atime;
+	unsigned int	__pad5;
+	unsigned int	st_mtime;
+	unsigned int	__pad6;
+	unsigned int	st_ctime;
+	unsigned int	__pad7;		/* will be high 32 bits of ctime someday */
+	unsigned int	st_ino_lo;
+	unsigned int	st_ino_hi;
+};
+
 struct statfs32 {
        int f_type;
        int f_bsize;
@@ -252,7 +288,7 @@
 #define ELF_ARCH	EM_386
=20
 #define IA32_PAGE_OFFSET	0xc0000000
-#define IA32_STACK_TOP		((IA32_PAGE_OFFSET/3) * 2)
+#define IA32_STACK_TOP		IA32_PAGE_OFFSET
=20
 /*
  * The system segments (GDT, TSS, LDT) have to be mapped below 4GB so the =
IA-32 engine can
@@ -377,7 +413,7 @@
  */
=20
 #define IA32_FSR_DEFAULT	0x55550000		/* set all tag bits */
-#define IA32_FCR_DEFAULT	0x17800000037fULL	/* extended precision, all mask=
s */
+#define IA32_FCR_DEFAULT	0x17800000037fUL	/* extended precision, all masks=
 */
=20
 #define IA32_PTRACE_GETREGS	12
 #define IA32_PTRACE_SETREGS	13
@@ -421,6 +457,7 @@
 extern void ia32_init_addr_space (struct pt_regs *regs);
 extern int ia32_setup_arg_pages (struct linux_binprm *bprm);
 extern int ia32_exception (struct pt_regs *regs, unsigned long isr);
+extern unsigned long ia32_do_mmap (struct file *, unsigned long, unsigned =
long, int, int, loff_t);
=20
 #endif /* !CONFIG_IA32_SUPPORT */
=20
diff -urN linux-davidm/include/asm-ia64/iosapic.h linux-2.4.10-lia/include/=
asm-ia64/iosapic.h
--- linux-davidm/include/asm-ia64/iosapic.h	Mon Sep 24 22:31:45 2001
+++ linux-2.4.10-lia/include/asm-ia64/iosapic.h	Mon Sep 24 22:05:11 2001
@@ -53,9 +53,15 @@
=20
 extern void __init iosapic_init (unsigned long address, unsigned int base_=
irq,
                                  int pcat_compat);
+extern int iosapic_register_irq (u32 global_vector, unsigned long polarity,
+                                 unsigned long edge_triggered, u32 base_ir=
q,
+                                 char *iosapic_address);
 extern void iosapic_register_legacy_irq (unsigned long irq, unsigned long =
pin,
 					 unsigned long polarity, unsigned long trigger);
-extern int iosapic_register_platform_irq (u32 int_type, u32 global_vector,=
 u32 iosapic_vector, u16 eid, u16 id, unsigned long polarity, unsigned long=
 edge_triggered, u32 base_irq, char *iosapic_address);
+extern int iosapic_register_platform_irq (u32 int_type, u32 global_vector,=
 u32 iosapic_vector,
+					  u16 eid, u16 id, unsigned long polarity,
+					  unsigned long edge_triggered, u32 base_irq,
+					  char *iosapic_address);
 extern unsigned int iosapic_version (char *addr);
=20
 extern void iosapic_pci_fixup (int);
diff -urN linux-davidm/include/asm-ia64/ipc.h linux-2.4.10-lia/include/asm-=
ia64/ipc.h
--- linux-davidm/include/asm-ia64/ipc.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.10-lia/include/asm-ia64/ipc.h	Wed Dec 31 16:00:00 1969
@@ -1,31 +0,0 @@
-#ifndef __i386_IPC_H__
-#define __i386_IPC_H__
-
-/*=20
- * These are used to wrap system calls on x86.
- *
- * See arch/i386/kernel/sys_i386.c for ugly details..
- */
-struct ipc_kludge {
-	struct msgbuf *msgp;
-	long msgtyp;
-};
-
-#define SEMOP		 1
-#define SEMGET		 2
-#define SEMCTL		 3
-#define MSGSND		11
-#define MSGRCV		12
-#define MSGGET		13
-#define MSGCTL		14
-#define SHMAT		21
-#define SHMDT		22
-#define SHMGET		23
-#define SHMCTL		24
-
-/* Used by the DIPC package, try and avoid reusing it */
-#define DIPC            25
-
-#define IPCCALL(version,op)	((version)<<16 | (op))
-
-#endif
diff -urN linux-davidm/include/asm-ia64/keyboard.h linux-2.4.10-lia/include=
/asm-ia64/keyboard.h
--- linux-davidm/include/asm-ia64/keyboard.h	Mon Sep 24 22:31:45 2001
+++ linux-2.4.10-lia/include/asm-ia64/keyboard.h	Mon Sep 24 23:00:16 2001
@@ -23,7 +23,6 @@
 			   char raw_mode);
 extern char pckbd_unexpected_up(unsigned char keycode);
 extern void pckbd_leds(unsigned char leds);
-extern int pckbd_rate(struct kbd_repeat *rep);
 extern void pckbd_init_hw(void);
 extern unsigned char pckbd_sysrq_xlate[128];
=20
@@ -33,7 +32,6 @@
 #define kbd_translate		pckbd_translate
 #define kbd_unexpected_up	pckbd_unexpected_up
 #define kbd_leds		pckbd_leds
-#define kbd_rate		pckbd_rate
 #define kbd_init_hw		pckbd_init_hw
 #define kbd_sysrq_xlate		pckbd_sysrq_xlate
=20
diff -urN linux-davidm/include/asm-ia64/machvec.h linux-2.4.10-lia/include/=
asm-ia64/machvec.h
--- linux-davidm/include/asm-ia64/machvec.h	Thu Apr  5 12:51:47 2001
+++ linux-2.4.10-lia/include/asm-ia64/machvec.h	Mon Sep 24 22:20:43 2001
@@ -1,11 +1,11 @@
 /*
  * Machine vector for IA-64.
- *=20
+ *
  * Copyright (C) 1999 Silicon Graphics, Inc.
  * Copyright (C) Srinivasa Thirumalachar <sprasad@engr.sgi.com>
  * Copyright (C) Vijay Chander <vijay@engr.sgi.com>
  * Copyright (C) 1999-2001 Hewlett-Packard Co.
- * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #ifndef _ASM_IA64_MACHVEC_H
 #define _ASM_IA64_MACHVEC_H
@@ -28,6 +28,7 @@
 typedef void ia64_mv_cmci_handler_t (int, void *, struct pt_regs *);
 typedef void ia64_mv_log_print_t (void);
 typedef void ia64_mv_send_ipi_t (int, int, int, int);
+typedef void ia64_mv_global_tlb_purge_t (unsigned long, unsigned long, uns=
igned long);
 typedef struct irq_desc *ia64_mv_irq_desc (unsigned int);
 typedef u8 ia64_mv_irq_to_vector (u8);
 typedef unsigned int ia64_mv_local_vector_to_irq (u8 vector);
@@ -67,6 +68,8 @@
 #  include <asm/machvec_dig.h>
 # elif defined (CONFIG_IA64_SGI_SN1)
 #  include <asm/machvec_sn1.h>
+# elif defined (CONFIG_IA64_SGI_SN2)
+#  include <asm/machvec_sn2.h>
 # elif defined (CONFIG_IA64_GENERIC)
=20
 # ifdef MACHVEC_PLATFORM_HEADER
@@ -82,6 +85,7 @@
 #  define platform_log_print	ia64_mv.log_print
 #  define platform_pci_fixup	ia64_mv.pci_fixup
 #  define platform_send_ipi	ia64_mv.send_ipi
+#  define platform_global_tlb_purge	ia64_mv.global_tlb_purge
 #  define platform_pci_dma_init		ia64_mv.dma_init
 #  define platform_pci_alloc_consistent	ia64_mv.alloc_consistent
 #  define platform_pci_free_consistent	ia64_mv.free_consistent
@@ -147,6 +151,7 @@
 	platform_cmci_handler,			\
 	platform_log_print,			\
 	platform_send_ipi,			\
+	platform_global_tlb_purge,		\
 	platform_pci_dma_init,			\
 	platform_pci_alloc_consistent,		\
 	platform_pci_free_consistent,		\
@@ -216,6 +221,9 @@
 #endif
 #ifndef platform_send_ipi
 # define platform_send_ipi	ia64_send_ipi	/* default to architected version=
 */
+#endif
+#ifndef platform_global_tlb_purge
+# define platform_global_tlb_purge	ia64_global_tlb_purge /* default to arc=
hitected version */
 #endif
 #ifndef platform_pci_dma_init
 # define platform_pci_dma_init		swiotlb_init
diff -urN linux-davidm/include/asm-ia64/machvec_sn1.h linux-2.4.10-lia/incl=
ude/asm-ia64/machvec_sn1.h
--- linux-davidm/include/asm-ia64/machvec_sn1.h	Thu Apr  5 12:51:47 2001
+++ linux-2.4.10-lia/include/asm-ia64/machvec_sn1.h	Mon Sep 24 22:06:06 2001
@@ -5,6 +5,7 @@
 extern ia64_mv_irq_init_t sn1_irq_init;
 extern ia64_mv_map_nr_t sn1_map_nr;
 extern ia64_mv_send_ipi_t sn1_send_IPI;
+extern ia64_mv_global_tlb_purge_t sn1_global_tlb_purge;
 extern ia64_mv_pci_fixup_t sn1_pci_fixup;
 extern ia64_mv_inb_t sn1_inb;
 extern ia64_mv_inw_t sn1_inw;
@@ -34,6 +35,7 @@
 #define platform_irq_init	sn1_irq_init
 #define platform_map_nr		sn1_map_nr
 #define platform_send_ipi	sn1_send_IPI
+#define platform_global_tlb_purge       sn1_global_tlb_purge
 #define platform_pci_fixup	sn1_pci_fixup
 #define platform_inb		sn1_inb
 #define platform_inw		sn1_inw
diff -urN linux-davidm/include/asm-ia64/mca.h linux-2.4.10-lia/include/asm-=
ia64/mca.h
--- linux-davidm/include/asm-ia64/mca.h	Mon Sep 24 22:31:45 2001
+++ linux-2.4.10-lia/include/asm-ia64/mca.h	Mon Sep 24 22:58:05 2001
@@ -61,8 +61,6 @@
 	IA64_MCA_RENDEZ_CHECKIN_DONE	=3D	0x1
 };
=20
-#define IA64_MAXCPUS	64	/* Need to do something about this */
-
 /* Information maintained by the MC infrastructure */
 typedef struct ia64_mc_info_s {
 	u64		imi_mca_handler;
@@ -71,7 +69,7 @@
 	size_t		imi_monarch_init_handler_size;
 	u64		imi_slave_init_handler;
 	size_t		imi_slave_init_handler_size;
-	u8		imi_rendez_checkin[IA64_MAXCPUS];
+	u8		imi_rendez_checkin[NR_CPUS];
=20
 } ia64_mc_info_t;
=20
diff -urN linux-davidm/include/asm-ia64/mmu_context.h linux-2.4.10-lia/incl=
ude/asm-ia64/mmu_context.h
--- linux-davidm/include/asm-ia64/mmu_context.h	Thu Apr  5 12:51:47 2001
+++ linux-2.4.10-lia/include/asm-ia64/mmu_context.h	Mon Sep 24 23:02:56 2001
@@ -60,7 +60,6 @@
 static inline void
 get_mmu_context (struct mm_struct *mm)
 {
-	/* check if our ASN is of an older generation and thus invalid: */
 	if (mm->context =3D 0)
 		get_new_mmu_context(mm);
 }
diff -urN linux-davidm/include/asm-ia64/module.h linux-2.4.10-lia/include/a=
sm-ia64/module.h
--- linux-davidm/include/asm-ia64/module.h	Mon Sep 24 15:08:24 2001
+++ linux-2.4.10-lia/include/asm-ia64/module.h	Mon Sep 24 22:57:00 2001
@@ -14,7 +14,6 @@
 #define module_map(x)		vmalloc(x)
 #define module_unmap(x)		ia64_module_unmap(x)
 #define module_arch_init(x)	ia64_module_init(x)
-#define arch_init_modules(x)	do { } while (0)
=20
 /*
  * This must match in size and layout the data created by
@@ -28,12 +27,23 @@
 	const char *gp;
 };
=20
+static inline void
+arch_init_modules (struct module *kmod)
+{
+	static struct archdata archdata;
+	register char *kernel_gp asm ("gp");
+
+	archdata.gp =3D kernel_gp;
+	kmod->archdata_start =3D (const char *) &archdata;
+	kmod->archdata_end   =3D (const char *) (&archdata + 1);
+}
+
 /*
  * functions to add/remove a modules unwind info when
  * it is loaded or unloaded.
  */
 static inline int
-ia64_module_init(struct module *mod)
+ia64_module_init (struct module *mod)
 {
 	struct archdata *archdata;
=20
@@ -45,28 +55,23 @@
 	 * Make sure the unwind pointers are sane.
 	 */
=20
-	if (archdata->unw_table)
-	{
+	if (archdata->unw_table) {
 		printk(KERN_ERR "module_arch_init: archdata->unw_table must be zero.\n");
 		return 1;
 	}
-	if (!mod_bound(archdata->gp, 0, mod))
-	{
+	if (!mod_bound(archdata->gp, 0, mod)) {
 		printk(KERN_ERR "module_arch_init: archdata->gp out of bounds.\n");
 		return 1;
 	}
-	if (!mod_bound(archdata->unw_start, 0, mod))
-	{
+	if (!mod_bound(archdata->unw_start, 0, mod)) {
 		printk(KERN_ERR "module_arch_init: archdata->unw_start out of bounds.\n"=
);
 		return 1;
 	}
-	if (!mod_bound(archdata->unw_end, 0, mod))
-	{
+	if (!mod_bound(archdata->unw_end, 0, mod)) {
 		printk(KERN_ERR "module_arch_init: archdata->unw_end out of bounds.\n");
 		return 1;
 	}
-	if (!mod_bound(archdata->segment_base, 0, mod))
-	{
+	if (!mod_bound(archdata->segment_base, 0, mod)) {
 		printk(KERN_ERR "module_arch_init: archdata->unw_table out of bounds.\n"=
);
 		return 1;
 	}
@@ -82,7 +87,7 @@
 }
=20
 static inline void
-ia64_module_unmap(void * addr)
+ia64_module_unmap (void * addr)
 {
 	struct module *mod =3D (struct module *) addr;
 	struct archdata *archdata;
@@ -90,8 +95,7 @@
 	/*
 	 * Before freeing the module memory remove the unwind table entry
 	 */
-	if (mod_member_present(mod, archdata_start) && mod->archdata_start)
-	{
+	if (mod_member_present(mod, archdata_start) && mod->archdata_start) {
 		archdata =3D (struct archdata *)(mod->archdata_start);
=20
 		if (archdata->unw_table !=3D NULL)
diff -urN linux-davidm/include/asm-ia64/msgbuf.h linux-2.4.10-lia/include/a=
sm-ia64/msgbuf.h
--- linux-davidm/include/asm-ia64/msgbuf.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.10-lia/include/asm-ia64/msgbuf.h	Mon Sep 24 22:06:49 2001
@@ -1,7 +1,7 @@
 #ifndef _ASM_IA64_MSGBUF_H
 #define _ASM_IA64_MSGBUF_H
=20
-/*=20
+/*
  * The msqid64_ds structure for IA-64 architecture.
  * Note extra padding because this structure is passed back and forth
  * between kernel and user space.
diff -urN linux-davidm/include/asm-ia64/namei.h linux-2.4.10-lia/include/as=
m-ia64/namei.h
--- linux-davidm/include/asm-ia64/namei.h	Sun Apr  2 15:49:07 2000
+++ linux-2.4.10-lia/include/asm-ia64/namei.h	Mon Sep 24 23:01:39 2001
@@ -2,15 +2,24 @@
 #define _ASM_IA64_NAMEI_H
=20
 /*
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998, 1999, 2001 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
-/*
- * This dummy routine maybe changed to something useful
- * for /usr/gnemul/ emulation stuff.
- * Look at asm-sparc/namei.h for details.
- */
-#define __emul_prefix() NULL
+#include <asm/ptrace.h>
+#include <asm/system.h>
+
+#define EMUL_PREFIX_LINUX_IA32 "emul/ia32-linux/"
+
+static inline char *
+__emul_prefix (void)
+{
+	switch (current->personality) {
+	      case PER_LINUX32:
+		return EMUL_PREFIX_LINUX_IA32;
+	      default:
+		return NULL;
+	}
+}
=20
 #endif /* _ASM_IA64_NAMEI_H */
diff -urN linux-davidm/include/asm-ia64/offsets.h linux-2.4.10-lia/include/=
asm-ia64/offsets.h
--- linux-davidm/include/asm-ia64/offsets.h	Tue Jul 31 10:30:09 2001
+++ linux-2.4.10-lia/include/asm-ia64/offsets.h	Mon Sep 24 22:07:13 2001
@@ -8,23 +8,23 @@
  */
 #define PT_PTRACED_BIT		0
 #define PT_TRACESYS_BIT		1
-#define IA64_TASK_SIZE			3904	/* 0xf40 */
+#define IA64_TASK_SIZE			3920	/* 0xf50 */
 #define IA64_PT_REGS_SIZE		400	/* 0x190 */
 #define IA64_SWITCH_STACK_SIZE		560	/* 0x230 */
 #define IA64_SIGINFO_SIZE		128	/* 0x80 */
 #define IA64_CPU_SIZE			16384	/* 0x4000 */
-#define SIGFRAME_SIZE			2832	/* 0xb10 */
+#define SIGFRAME_SIZE			2816	/* 0xb00 */
 #define UNW_FRAME_INFO_SIZE		448	/* 0x1c0 */
=20
 #define IA64_TASK_PTRACE_OFFSET		48	/* 0x30 */
 #define IA64_TASK_SIGPENDING_OFFSET	16	/* 0x10 */
 #define IA64_TASK_NEED_RESCHED_OFFSET	40	/* 0x28 */
 #define IA64_TASK_PROCESSOR_OFFSET	100	/* 0x64 */
-#define IA64_TASK_THREAD_OFFSET		1456	/* 0x5b0 */
-#define IA64_TASK_THREAD_KSP_OFFSET	1456	/* 0x5b0 */
-#define IA64_TASK_THREAD_SIGMASK_OFFSET	1568	/* 0x620 */
-#define IA64_TASK_PFM_NOTIFY_OFFSET	2088	/* 0x828 */
-#define IA64_TASK_PID_OFFSET		196	/* 0xc4 */
+#define IA64_TASK_THREAD_OFFSET		1472	/* 0x5c0 */
+#define IA64_TASK_THREAD_KSP_OFFSET	1472	/* 0x5c0 */
+#define IA64_TASK_THREAD_SIGMASK_OFFSET	1584	/* 0x630 */
+#define IA64_TASK_PFM_MUST_BLOCK_OFFSET	2104	/* 0x838 */
+#define IA64_TASK_PID_OFFSET		220	/* 0xdc */
 #define IA64_TASK_MM_OFFSET		88	/* 0x58 */
 #define IA64_PT_REGS_CR_IPSR_OFFSET	0	/* 0x0 */
 #define IA64_PT_REGS_CR_IIP_OFFSET	8	/* 0x8 */
@@ -126,12 +126,13 @@
 #define IA64_SIGCONTEXT_FR6_OFFSET	560	/* 0x230 */
 #define IA64_SIGCONTEXT_PR_OFFSET	128	/* 0x80 */
 #define IA64_SIGCONTEXT_R12_OFFSET	296	/* 0x128 */
+#define IA64_SIGCONTEXT_RBS_BASE_OFFSET	2512	/* 0x9d0 */
+#define IA64_SIGCONTEXT_LOADRS_OFFSET	2520	/* 0x9d8 */
 #define IA64_SIGFRAME_ARG0_OFFSET	0	/* 0x0 */
 #define IA64_SIGFRAME_ARG1_OFFSET	8	/* 0x8 */
 #define IA64_SIGFRAME_ARG2_OFFSET	16	/* 0x10 */
-#define IA64_SIGFRAME_RBS_BASE_OFFSET	24	/* 0x18 */
-#define IA64_SIGFRAME_HANDLER_OFFSET	32	/* 0x20 */
-#define IA64_SIGFRAME_SIGCONTEXT_OFFSET	176	/* 0xb0 */
+#define IA64_SIGFRAME_HANDLER_OFFSET	24	/* 0x18 */
+#define IA64_SIGFRAME_SIGCONTEXT_OFFSET	160	/* 0xa0 */
 #define IA64_CLONE_VFORK		16384	/* 0x4000 */
 #define IA64_CLONE_VM			256	/* 0x100 */
 #define IA64_CPU_IRQ_COUNT_OFFSET	0	/* 0x0 */
diff -urN linux-davidm/include/asm-ia64/pal.h linux-2.4.10-lia/include/asm-=
ia64/pal.h
--- linux-davidm/include/asm-ia64/pal.h	Thu Apr  5 12:51:47 2001
+++ linux-2.4.10-lia/include/asm-ia64/pal.h	Mon Sep 24 22:07:25 2001
@@ -7,9 +7,9 @@
  * This is based on Intel IA-64 Architecture Software Developer's Manual r=
ev 1.0
  * chapter 11 IA-64 Processor Abstraction Layer
  *
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 2000 Stephane Eranian <eranian@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+ *	Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
  * Copyright (C) 1999 Srinivasa Prasad Thirumalachar <sprasad@sprasad.engr=
.sgi.com>
@@ -17,7 +17,7 @@
  * 99/10/01	davidm	Make sure we pass zero for reserved parameters.
  * 00/03/07	davidm	Updated pal_cache_flush() to be in sync with PAL v2.6.
  * 00/03/23     cfleck  Modified processor min-state save area to match up=
dated PAL & SAL info
- * 00/05/24     eranian Updated to latest PAL spec, fix structures bugs, a=
dded=20
+ * 00/05/24     eranian Updated to latest PAL spec, fix structures bugs, a=
dded
  * 00/05/25	eranian Support for stack calls, and static physical calls
  * 00/06/18	eranian Support for stacked physical calls
  */
@@ -91,9 +91,9 @@
 #define PAL_STATUS_UNIMPLEMENTED	-1	/* Unimplemented procedure */
 #define PAL_STATUS_EINVAL		-2	/* Invalid argument */
 #define PAL_STATUS_ERROR		-3	/* Error */
-#define PAL_STATUS_CACHE_INIT_FAIL	-4	/* Could not initialize the=20
+#define PAL_STATUS_CACHE_INIT_FAIL	-4	/* Could not initialize the
 						 * specified level and type of
-						 * cache without sideeffects=20
+						 * cache without sideeffects
 						 * and "restrict" was 1
 						 */
=20
@@ -189,8 +189,8 @@
=20
 #define PAL_CACHE_ATTR_WT		0	/* Write through cache */
 #define PAL_CACHE_ATTR_WB		1	/* Write back cache */
-#define PAL_CACHE_ATTR_WT_OR_WB		2	/* Either write thru or write=20
-						 * back depending on TLB=20
+#define PAL_CACHE_ATTR_WT_OR_WB		2	/* Either write thru or write
+						 * back depending on TLB
 						 * memory attributes
 						 */
=20
@@ -211,13 +211,13 @@
=20
 				tagprot_lsb	: 6, /* Least -do- */
 				tagprot_msb	: 6, /* Most Sig. tag address
-						      * bit that this=20
+						      * bit that this
 						      * protection covers.
 						      */
 				prot_bits	: 6, /* # of protection bits */
 				method		: 4, /* Protection method */
-			        t_d		: 2; /* Indicates which part
-						      * of the cache this=20
+				t_d		: 2; /* Indicates which part
+						      * of the cache this
 						      * protection encoding
 						      * applies.
 						      */
@@ -239,7 +239,7 @@
 						 */
 #define PAL_CACHE_PROT_PART_DATA_TAG	3	/* Data+tag protection (data is
 						 * more significant )
-						 */=20
+						 */
 #define PAL_CACHE_PROT_PART_MAX		6
=20
=20
@@ -247,7 +247,7 @@
 	pal_status_t			pcpi_status;
 	pal_cache_protection_element_t	pcp_info[PAL_CACHE_PROT_PART_MAX];
 } pal_cache_protection_info_t;
-=09
+
=20
 /* Processor cache protection method encodings */
 #define PAL_CACHE_PROT_METHOD_NONE		0	/* No protection */
@@ -262,41 +262,41 @@
 	struct {
 		u64		cache_type	: 8,	/* 7-0 cache type */
 				level		: 8,	/* 15-8 level of the
-							 * cache in the=20
+							 * cache in the
 							 * heirarchy.
 							 */
 				way		: 8,	/* 23-16 way in the set
 							 */
 				part		: 8,	/* 31-24 part of the
-							 * cache=20
+							 * cache
 							 */
 				reserved	: 32;	/* 63-32 is reserved*/
 	} pclid_info_read;
 	struct {
 		u64		cache_type	: 8,	/* 7-0 cache type */
 				level		: 8,	/* 15-8 level of the
-							 * cache in the=20
+							 * cache in the
 							 * heirarchy.
 							 */
 				way		: 8,	/* 23-16 way in the set
 							 */
 				part		: 8,	/* 31-24 part of the
-							 * cache=20
+							 * cache
 							 */
-				mesi		: 8,	/* 39-32 cache line=20
+				mesi		: 8,	/* 39-32 cache line
 							 * state
 							 */
 				start		: 8,	/* 47-40 lsb of data to
 							 * invert
 							 */
 				length		: 8,	/* 55-48 #bits to
-							 * invert=20
+							 * invert
 							 */
 				trigger		: 8;	/* 63-56 Trigger error
-							 * by doing a load=20
-							 * after the write=20
-						         */
-			=09
+							 * by doing a load
+							 * after the write
+							 */
+
 	} pclid_info_write;
 } pal_cache_line_id_u_t;
=20
@@ -319,11 +319,11 @@
 #define PAL_CACHE_LINE_ID_PART_TAG		1	/* Tag */
 #define PAL_CACHE_LINE_ID_PART_DATA_PROT	2	/* Data protection */
 #define PAL_CACHE_LINE_ID_PART_TAG_PROT		3	/* Tag protection */
-#define PAL_CACHE_LINE_ID_PART_DATA_TAG_PROT	4	/* Data+tag=20
+#define PAL_CACHE_LINE_ID_PART_DATA_TAG_PROT	4	/* Data+tag
 							 * protection
 							 */
 typedef struct pal_cache_line_info_s {
-	pal_status_t		pcli_status;		/* Return status of the read cache line=20
+	pal_status_t		pcli_status;		/* Return status of the read cache line
 							 * info call.
 							 */
 	u64			pcli_data;		/* 64-bit data, tag, protection bits .. */
@@ -351,15 +351,15 @@
 #define PAL_MC_INFO_REQ_ADDR			4	/* Requestor address */
 #define PAL_MC_INFO_RESP_ADDR			5	/* Responder address */
 #define PAL_MC_INFO_TARGET_ADDR			6	/* Target address */
-#define PAL_MC_INFO_IMPL_DEP			7	/* Implementation=20
-							 * dependent=20
+#define PAL_MC_INFO_IMPL_DEP			7	/* Implementation
+							 * dependent
 							 */
=20
=20
 typedef struct pal_process_state_info_s {
 	u64		reserved1	: 2,
 			rz		: 1,	/* PAL_CHECK processor
-						 * rendezvous=20
+						 * rendezvous
 						 * successful.
 						 */
=20
@@ -370,13 +370,13 @@
 						 * errors occurred
 						 */
=20
-			mn		: 1,	/* Min. state save=20
-						 * area has been=20
+			mn		: 1,	/* Min. state save
+						 * area has been
 						 * registered with PAL
 						 */
=20
 			sy		: 1,	/* Storage integrity
-						 * synched=20
+						 * synched
 						 */
=20
=20
@@ -389,8 +389,8 @@
=20
 			hd		: 1,	/* Non-essential hw
 						 * lost (no loss of
-						 * functionality)=20
-						 * causing the=20
+						 * functionality)
+						 * causing the
 						 * processor to run in
 						 * degraded mode.
 						 */
@@ -398,9 +398,9 @@
 			tl		: 1,	/* 1 =3D> MC occurred
 						 * after an instr was
 						 * executed but before
-						 * the trap that=20
+						 * the trap that
 						 * resulted from instr
-						 * execution was=20
+						 * execution was
 						 * generated.
 						 * (Trap Lost )
 						 */
@@ -410,7 +410,7 @@
 						 */
=20
 			dy		: 1,	/* Processor dynamic
-						 * state valid=20
+						 * state valid
 						 */
=20
=20
@@ -441,10 +441,10 @@
 						 * are valid
 						 */
 			gr		: 1,	/* General registers
-						 * are valid=20
+						 * are valid
 						 * (excl. banked regs)
 						 */
-			dsize		: 16,	/* size of dynamic=20
+			dsize		: 16,	/* size of dynamic
 						 * state returned
 						 * by the processor
 						 */
@@ -459,8 +459,8 @@
=20
 typedef struct pal_cache_check_info_s {
 	u64		reserved1	: 16,
-			way		: 5,	/* Way in which the=20
-						 * error occurred=20
+			way		: 5,	/* Way in which the
+						 * error occurred
 						 */
 			reserved2	: 1,
 			mc		: 1,	/* Machine check corrected */
@@ -469,8 +469,8 @@
 						 */
=20
 			wv		: 1,	/* Way field valid */
-			op		: 3,	/* Type of cache=20
-						 * operation that=20
+			op		: 3,	/* Type of cache
+						 * operation that
 						 * caused the machine
 						 * check.
 						 */
@@ -493,7 +493,7 @@
 typedef struct pal_tlb_check_info_s {
=20
 	u64		tr_slot		: 8,	/* Slot# of TR where
-						 * error occurred=20
+						 * error occurred
 						 */
 			reserved2	: 8,
 			dtr		: 1,	/* Fail in data TR */
@@ -509,7 +509,7 @@
 	u64		size		: 5,	/* Xaction size*/
 			ib		: 1,	/* Internal bus error */
 			eb		: 1,	/* External bus error */
-			cc		: 1,	/* Error occurred=20
+			cc		: 1,	/* Error occurred
 						 * during cache-cache
 						 * transfer.
 						 */
@@ -518,7 +518,7 @@
 			tv		: 1,	/* Targ addr valid */
 			rp		: 1,	/* Resp addr valid */
 			rq		: 1,	/* Req addr valid */
-			bsi		: 8,	/* Bus error status=20
+			bsi		: 8,	/* Bus error status
 						 * info
 						 */
 			mc		: 1,	/* Machine check corrected */
@@ -601,8 +601,8 @@
 #define pmci_bus_external_error			pme_bus.eb
 #define pmci_bus_mc				pme_bus.mc
=20
-/*=20
- * NOTE: this min_state_save area struct only includes the 1KB=20
+/*
+ * NOTE: this min_state_save area struct only includes the 1KB
  * architectural state save area.  The other 3 KB is scratch space
  * for PAL.
  */
@@ -703,12 +703,12 @@
 		u64	pbf_disable_bus_addr_err_signal		:	1;
 		u64	pbf_disable_bus_data_err_check		:	1;
 	} pal_bus_features_s;
-} pal_bus_features_u_t;=20
+} pal_bus_features_u_t;
=20
 extern void pal_bus_features_print (u64);
=20
 /* Provide information about configurable processor bus features */
-static inline s64=20
+static inline s64
 ia64_pal_bus_get_features (pal_bus_features_u_t *features_avail,
 			   pal_bus_features_u_t *features_status,
 			   pal_bus_features_u_t *features_control)
@@ -721,13 +721,13 @@
 		features_status->pal_bus_features_val =3D iprv.v1;
 	if (features_control)
 		features_control->pal_bus_features_val =3D iprv.v2;
-	return iprv.status;=09
+	return iprv.status;
 }
=20
 /* Enables/disables specific processor bus features */
-static inline s64=20
-ia64_pal_bus_set_features (pal_bus_features_u_t feature_select)=20
-{=09
+static inline s64
+ia64_pal_bus_set_features (pal_bus_features_u_t feature_select)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL_PHYS(iprv, PAL_BUS_SET_FEATURES, feature_select.pal_bus_features=
_val, 0, 0);
 	return iprv.status;
@@ -739,7 +739,7 @@
 {
 	struct ia64_pal_retval iprv;
=20
-	PAL_CALL(iprv, PAL_CACHE_INFO, cache_level, cache_type, 0);=20
+	PAL_CALL(iprv, PAL_CACHE_INFO, cache_level, cache_type, 0);
=20
 	if (iprv.status =3D 0) {
 		conf->pcci_status                 =3D iprv.status;
@@ -747,7 +747,7 @@
 		conf->pcci_info_2.pcci2_data      =3D iprv.v1;
 		conf->pcci_reserved               =3D iprv.v2;
 	}
-	return iprv.status;=20
+	return iprv.status;
=20
 }
=20
@@ -757,7 +757,7 @@
 {
 	struct ia64_pal_retval iprv;
=20
-	PAL_CALL(iprv, PAL_CACHE_PROT_INFO, cache_level, cache_type, 0);=20
+	PAL_CALL(iprv, PAL_CACHE_PROT_INFO, cache_level, cache_type, 0);
=20
 	if (iprv.status =3D 0) {
 		prot->pcpi_status           =3D iprv.status;
@@ -768,106 +768,106 @@
 		prot->pcp_info[4].pcpi_data =3D iprv.v2 & 0xffffffff;
 		prot->pcp_info[5].pcpi_data =3D iprv.v2 >> 32;
 	}
-	return iprv.status;=20
+	return iprv.status;
 }
-=20
+
 /*
  * Flush the processor instruction or data caches.  *PROGRESS must be
  * initialized to zero before calling this for the first time..
  */
-static inline s64=20
-ia64_pal_cache_flush (u64 cache_type, u64 invalidate, u64 *progress)=20
-{=09
+static inline s64
+ia64_pal_cache_flush (u64 cache_type, u64 invalidate, u64 *progress)
+{
 	struct ia64_pal_retval iprv;
-	PAL_CALL_IC_OFF(iprv, PAL_CACHE_FLUSH, cache_type, invalidate, *progress)=
;=20
+	PAL_CALL_IC_OFF(iprv, PAL_CACHE_FLUSH, cache_type, invalidate, *progress);
 	*progress =3D iprv.v1;
-	return iprv.status;=20
+	return iprv.status;
 }
=20
=20
 /* Initialize the processor controlled caches */
-static inline s64=20
-ia64_pal_cache_init (u64 level, u64 cache_type, u64 restrict)=20
-{=09
+static inline s64
+ia64_pal_cache_init (u64 level, u64 cache_type, u64 restrict)
+{
 	struct ia64_pal_retval iprv;
-	PAL_CALL(iprv, PAL_CACHE_INIT, level, cache_type, restrict);=20
-	return iprv.status;=20
+	PAL_CALL(iprv, PAL_CACHE_INIT, level, cache_type, restrict);
+	return iprv.status;
 }
=20
-/* Initialize the tags and data of a data or unified cache line of=20
- * processor controlled cache to known values without the availability=20
+/* Initialize the tags and data of a data or unified cache line of
+ * processor controlled cache to known values without the availability
  * of backing memory.
  */
-static inline s64=20
-ia64_pal_cache_line_init (u64 physical_addr, u64 data_value)=20
-{=09
+static inline s64
+ia64_pal_cache_line_init (u64 physical_addr, u64 data_value)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_CACHE_LINE_INIT, physical_addr, data_value, 0);
-	return iprv.status;=20
+	return iprv.status;
 }
=20
=20
 /* Read the data and tag of a processor controlled cache line for diags */
-static inline s64=20
-ia64_pal_cache_read (pal_cache_line_id_u_t line_id, u64 physical_addr)=20
-{=09
+static inline s64
+ia64_pal_cache_read (pal_cache_line_id_u_t line_id, u64 physical_addr)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_CACHE_READ, line_id.pclid_data, physical_addr, 0);
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /* Return summary information about the heirarchy of caches controlled by =
the processor */
-static inline s64=20
-ia64_pal_cache_summary (u64 *cache_levels, u64 *unique_caches)=20
-{=09
+static inline s64
+ia64_pal_cache_summary (u64 *cache_levels, u64 *unique_caches)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_CACHE_SUMMARY, 0, 0, 0);
 	if (cache_levels)
 		*cache_levels =3D iprv.v0;
 	if (unique_caches)
 		*unique_caches =3D iprv.v1;
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /* Write the data and tag of a processor-controlled cache line for diags */
-static inline s64=20
-ia64_pal_cache_write (pal_cache_line_id_u_t line_id, u64 physical_addr, u6=
4 data)=20
-{=09
-	struct ia64_pal_retval iprv;=09
+static inline s64
+ia64_pal_cache_write (pal_cache_line_id_u_t line_id, u64 physical_addr, u6=
4 data)
+{
+	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_CACHE_WRITE, line_id.pclid_data, physical_addr, data);
-	return iprv.status;=20
+	return iprv.status;
 }
=20
=20
 /* Return the parameters needed to copy relocatable PAL procedures from RO=
M to memory */
-static inline s64=20
+static inline s64
 ia64_pal_copy_info (u64 copy_type, u64 num_procs, u64 num_iopics,
-		    u64 *buffer_size, u64 *buffer_align)=20
-{=09
+		    u64 *buffer_size, u64 *buffer_align)
+{
 	struct ia64_pal_retval iprv;
-	PAL_CALL(iprv, PAL_COPY_INFO, copy_type, num_procs, num_iopics);=20
+	PAL_CALL(iprv, PAL_COPY_INFO, copy_type, num_procs, num_iopics);
 	if (buffer_size)
 		*buffer_size =3D iprv.v0;
 	if (buffer_align)
 		*buffer_align =3D iprv.v1;
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /* Copy relocatable PAL procedures from ROM to memory */
-static inline s64=20
-ia64_pal_copy_pal (u64 target_addr, u64 alloc_size, u64 processor, u64 *pa=
l_proc_offset)=20
-{=09
+static inline s64
+ia64_pal_copy_pal (u64 target_addr, u64 alloc_size, u64 processor, u64 *pa=
l_proc_offset)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_COPY_PAL, target_addr, alloc_size, processor);
 	if (pal_proc_offset)
 		*pal_proc_offset =3D iprv.v0;
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /* Return the number of instruction and data debug register pairs */
-static inline s64=20
-ia64_pal_debug_info (u64 *inst_regs,  u64 *data_regs)=20
-{=09
+static inline s64
+ia64_pal_debug_info (u64 *inst_regs,  u64 *data_regs)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_DEBUG_INFO, 0, 0, 0);
 	if (inst_regs)
@@ -875,50 +875,50 @@
 	if (data_regs)
 		*data_regs =3D iprv.v1;
=20
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 #ifdef TBD
 /* Switch from IA64-system environment to IA-32 system environment */
-static inline s64=20
-ia64_pal_enter_ia32_env (ia32_env1, ia32_env2, ia32_env3)=20
-{=09
+static inline s64
+ia64_pal_enter_ia32_env (ia32_env1, ia32_env2, ia32_env3)
+{
 	struct ia64_pal_retval iprv;
-	PAL_CALL(iprv, PAL_ENTER_IA_32_ENV, ia32_env1, ia32_env2, ia32_env3);=20
-	return iprv.status;=20
+	PAL_CALL(iprv, PAL_ENTER_IA_32_ENV, ia32_env1, ia32_env2, ia32_env3);
+	return iprv.status;
 }
 #endif
=20
 /* Get unique geographical address of this processor on its bus */
-static inline s64=20
-ia64_pal_fixed_addr (u64 *global_unique_addr)=20
-{=09
+static inline s64
+ia64_pal_fixed_addr (u64 *global_unique_addr)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_FIXED_ADDR, 0, 0, 0);
 	if (global_unique_addr)
 		*global_unique_addr =3D iprv.v0;
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /* Get base frequency of the platform if generated by the processor */
-static inline s64=20
-ia64_pal_freq_base (u64 *platform_base_freq)=20
-{=09
+static inline s64
+ia64_pal_freq_base (u64 *platform_base_freq)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_FREQ_BASE, 0, 0, 0);
 	if (platform_base_freq)
 		*platform_base_freq =3D iprv.v0;
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /*
  * Get the ratios for processor frequency, bus frequency and interval time=
r to
- * to base frequency of the platform=20
+ * to base frequency of the platform
  */
-static inline s64=20
+static inline s64
 ia64_pal_freq_ratios (struct pal_freq_ratio *proc_ratio, struct pal_freq_r=
atio *bus_ratio,
-		      struct pal_freq_ratio *itc_ratio)=20
-{=09
+		      struct pal_freq_ratio *itc_ratio)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_FREQ_RATIOS, 0, 0, 0);
 	if (proc_ratio)
@@ -927,20 +927,21 @@
 		*(u64 *)bus_ratio =3D iprv.v1;
 	if (itc_ratio)
 		*(u64 *)itc_ratio =3D iprv.v2;
-	return iprv.status;=20
+	return iprv.status;
 }
=20
-/* Make the processor enter HALT or one of the implementation dependent lo=
w=20
+/* Make the processor enter HALT or one of the implementation dependent low
  * power states where prefetching and execution are suspended and cache and
  * TLB coherency is not maintained.
  */
-static inline s64=20
-ia64_pal_halt (u64 halt_state)=20
-{=09
+static inline s64
+ia64_pal_halt (u64 halt_state)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_HALT, halt_state, 0, 0);
-	return iprv.status;=20
+	return iprv.status;
 }
+
 typedef union pal_power_mgmt_info_u {
 	u64			ppmi_data;
 	struct {
@@ -954,87 +955,87 @@
 } pal_power_mgmt_info_u_t;
=20
 /* Return information about processor's optional power management capabili=
ties. */
-static inline s64=20
-ia64_pal_halt_info (pal_power_mgmt_info_u_t *power_buf)=20
-{=09
+static inline s64
+ia64_pal_halt_info (pal_power_mgmt_info_u_t *power_buf)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL_STK(iprv, PAL_HALT_INFO, (unsigned long) power_buf, 0, 0);
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /* Cause the processor to enter LIGHT HALT state, where prefetching and ex=
ecution are
  * suspended, but cache and TLB coherency is maintained.
  */
-static inline s64=20
-ia64_pal_halt_light (void)=20
-{=09
+static inline s64
+ia64_pal_halt_light (void)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_HALT_LIGHT, 0, 0, 0);
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /* Clear all the processor error logging   registers and reset the indicat=
or that allows
  * the error logging registers to be written. This procedure also checks t=
he pending
  * machine check bit and pending INIT bit and reports their states.
  */
-static inline s64=20
-ia64_pal_mc_clear_log (u64 *pending_vector)=20
-{=09
+static inline s64
+ia64_pal_mc_clear_log (u64 *pending_vector)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_MC_CLEAR_LOG, 0, 0, 0);
 	if (pending_vector)
 		*pending_vector =3D iprv.v0;
-	return iprv.status;=20
+	return iprv.status;
 }
=20
-/* Ensure that all outstanding transactions in a processor are completed o=
r that any=20
+/* Ensure that all outstanding transactions in a processor are completed o=
r that any
  * MCA due to thes outstanding transaction is taken.
  */
-static inline s64=20
-ia64_pal_mc_drain (void)=20
-{=09
+static inline s64
+ia64_pal_mc_drain (void)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_MC_DRAIN, 0, 0, 0);
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /* Return the machine check dynamic processor state */
-static inline s64=20
-ia64_pal_mc_dynamic_state (u64 offset, u64 *size, u64 *pds)=20
-{=09
+static inline s64
+ia64_pal_mc_dynamic_state (u64 offset, u64 *size, u64 *pds)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_MC_DYNAMIC_STATE, offset, 0, 0);
 	if (size)
 		*size =3D iprv.v0;
 	if (pds)
 		*pds =3D iprv.v1;
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /* Return processor machine check information */
-static inline s64=20
-ia64_pal_mc_error_info (u64 info_index, u64 type_index, u64 *size, u64 *er=
ror_info)=20
-{=09
+static inline s64
+ia64_pal_mc_error_info (u64 info_index, u64 type_index, u64 *size, u64 *er=
ror_info)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_MC_ERROR_INFO, info_index, type_index, 0);
 	if (size)
 		*size =3D iprv.v0;
 	if (error_info)
-		*error_info =3D iprv.v1;=09
-	return iprv.status;=20
+		*error_info =3D iprv.v1;
+	return iprv.status;
 }
=20
 /* Inform PALE_CHECK whether a machine check is expected so that PALE_CHEC=
K willnot
  * attempt to correct any expected machine checks.
  */
-static inline s64=20
-ia64_pal_mc_expected (u64 expected, u64 *previous)=20
-{=09
+static inline s64
+ia64_pal_mc_expected (u64 expected, u64 *previous)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_MC_EXPECTED, expected, 0, 0);
 	if (previous)
 		*previous =3D iprv.v0;
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /* Register a platform dependent location with PAL to which it can save
@@ -1042,39 +1043,39 @@
  * event.
  */
 static inline s64
-ia64_pal_mc_register_mem (u64 physical_addr)=20
-{=09
+ia64_pal_mc_register_mem (u64 physical_addr)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_MC_REGISTER_MEM, physical_addr, 0, 0);
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /* Restore minimal architectural processor state, set CMC interrupt if nec=
essary
  * and resume execution
  */
-static inline s64=20
-ia64_pal_mc_resume (u64 set_cmci, u64 save_ptr)=20
-{=09
+static inline s64
+ia64_pal_mc_resume (u64 set_cmci, u64 save_ptr)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_MC_RESUME, set_cmci, save_ptr, 0);
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /* Return the memory attributes implemented by the processor */
-static inline s64=20
-ia64_pal_mem_attrib (u64 *mem_attrib)=20
-{=09
+static inline s64
+ia64_pal_mem_attrib (u64 *mem_attrib)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_MEM_ATTRIB, 0, 0, 0);
 	if (mem_attrib)
 		*mem_attrib =3D iprv.v0 & 0xff;
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /* Return the amount of memory needed for second phase of processor
  * self-test and the required alignment of memory.
  */
-static inline s64=20
+static inline s64
 ia64_pal_mem_for_test (u64 *bytes_needed, u64 *alignment)
 {
 	struct ia64_pal_retval iprv;
@@ -1083,60 +1084,60 @@
 		*bytes_needed =3D iprv.v0;
 	if (alignment)
 		*alignment =3D iprv.v1;
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 typedef union pal_perf_mon_info_u {
 	u64			  ppmi_data;
 	struct {
 	       u64		generic		: 8,
-	       			width		: 8,
-		       		cycles		: 8,
+				width		: 8,
+				cycles		: 8,
 				retired		: 8,
 				reserved	: 32;
 	} pal_perf_mon_info_s;
 } pal_perf_mon_info_u_t;
-	      =20
+
 /* Return the performance monitor information about what can be counted
  * and how to configure the monitors to count the desired events.
  */
-static inline s64=20
-ia64_pal_perf_mon_info (u64 *pm_buffer, pal_perf_mon_info_u_t *pm_info)=20
-{=09
+static inline s64
+ia64_pal_perf_mon_info (u64 *pm_buffer, pal_perf_mon_info_u_t *pm_info)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_PERF_MON_INFO, (unsigned long) pm_buffer, 0, 0);
 	if (pm_info)
 		pm_info->ppmi_data =3D iprv.v0;
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /* Specifies the physical address of the processor interrupt block
  * and I/O port space.
  */
-static inline s64=20
-ia64_pal_platform_addr (u64 type, u64 physical_addr)=20
-{=09
+static inline s64
+ia64_pal_platform_addr (u64 type, u64 physical_addr)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_PLATFORM_ADDR, type, physical_addr, 0);
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /* Set the SAL PMI entrypoint in memory */
-static inline s64=20
-ia64_pal_pmi_entrypoint (u64 sal_pmi_entry_addr)=20
-{=09
+static inline s64
+ia64_pal_pmi_entrypoint (u64 sal_pmi_entry_addr)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_PMI_ENTRYPOINT, sal_pmi_entry_addr, 0, 0);
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 struct pal_features_s;
 /* Provide information about configurable processor features */
-static inline s64=20
-ia64_pal_proc_get_features (u64 *features_avail,=20
-			    u64 *features_status,=20
+static inline s64
+ia64_pal_proc_get_features (u64 *features_avail,
+			    u64 *features_status,
 			    u64 *features_control)
-{=09
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL_PHYS(iprv, PAL_PROC_GET_FEATURES, 0, 0, 0);
 	if (iprv.status =3D 0) {
@@ -1144,16 +1145,16 @@
 		*features_status  =3D iprv.v1;
 		*features_control =3D iprv.v2;
 	}
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /* Enable/disable processor dependent features */
-static inline s64=20
-ia64_pal_proc_set_features (u64 feature_select)=20
-{=09
+static inline s64
+ia64_pal_proc_set_features (u64 feature_select)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL_PHYS(iprv, PAL_PROC_SET_FEATURES, feature_select, 0, 0);
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /*
@@ -1162,7 +1163,7 @@
  */
 typedef struct ia64_ptce_info_s {
 	u64		base;
-	u32 		count[2];
+	u32		count[2];
 	u32		stride[2];
 } ia64_ptce_info_t;
=20
@@ -1189,9 +1190,9 @@
 }
=20
 /* Return info about implemented application and control registers. */
-static inline s64=20
-ia64_pal_register_info (u64 info_request, u64 *reg_info_1, u64 *reg_info_2=
)=20
-{=09
+static inline s64
+ia64_pal_register_info (u64 info_request, u64 *reg_info_1, u64 *reg_info_2)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_REGISTER_INFO, info_request, 0, 0);
 	if (reg_info_1)
@@ -1199,7 +1200,7 @@
 	if (reg_info_2)
 		*reg_info_2 =3D iprv.v1;
 	return iprv.status;
-}=09
+}
=20
 typedef union pal_hints_u {
 	u64			ph_data;
@@ -1210,62 +1211,62 @@
 	} pal_hints_s;
 } pal_hints_u_t;
=20
-/* Return information about the register stack and RSE for this processor =

+/* Return information about the register stack and RSE for this processor
  * implementation.
  */
-static inline s64=20
+static inline s64
 ia64_pal_rse_info (u64 *num_phys_stacked, pal_hints_u_t *hints)
-{=09
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_RSE_INFO, 0, 0, 0);
 	if (num_phys_stacked)
 		*num_phys_stacked =3D iprv.v0;
 	if (hints)
 		hints->ph_data =3D iprv.v1;
-	return iprv.status;=09
+	return iprv.status;
 }
=20
-/* Cause the processor to enter	SHUTDOWN state, where prefetching and exec=
ution are=20
+/* Cause the processor to enter	SHUTDOWN state, where prefetching and exec=
ution are
  * suspended, but cause cache and TLB coherency to be maintained.
  * This is usually called in IA-32 mode.
  */
-static inline s64=20
-ia64_pal_shutdown (void)=20
-{=09
+static inline s64
+ia64_pal_shutdown (void)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_SHUTDOWN, 0, 0, 0);
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 /* Perform the second phase of processor self-test. */
-static inline s64=20
+static inline s64
 ia64_pal_test_proc (u64 test_addr, u64 test_size, u64 attributes, u64 *sel=
f_test_state)
 {
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_TEST_PROC, test_addr, test_size, attributes);
 	if (self_test_state)
 		*self_test_state =3D iprv.v0;
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 typedef union  pal_version_u {
 	u64	pal_version_val;
 	struct {
-		u64	pv_pal_b_rev 		: 	8;
+		u64	pv_pal_b_rev		:	8;
 		u64	pv_pal_b_model		:	8;
 		u64	pv_reserved1		:	8;
 		u64	pv_pal_vendor		:	8;
 		u64	pv_pal_a_rev		:	8;
 		u64	pv_pal_a_model		:	8;
-		u64	pv_reserved2		: 	16;
+		u64	pv_reserved2		:	16;
 	} pal_version_s;
 } pal_version_u_t;
=20
=20
 /* Return PAL version information */
-static inline s64=20
-ia64_pal_version (pal_version_u_t *pal_min_version, pal_version_u_t *pal_c=
ur_version)=20
-{=09
+static inline s64
+ia64_pal_version (pal_version_u_t *pal_min_version, pal_version_u_t *pal_c=
ur_version)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL_PHYS(iprv, PAL_VERSION, 0, 0, 0);
 	if (pal_min_version)
@@ -1274,7 +1275,7 @@
 	if (pal_cur_version)
 		pal_cur_version->pal_version_val =3D iprv.v1;
=20
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 typedef union pal_tc_info_u {
@@ -1288,8 +1289,8 @@
 				reduce_tr	:	1,
 				reserved	:	29;
 	} pal_tc_info_s;
-} pal_tc_info_u_t;			=09
-			=09
+} pal_tc_info_u_t;
+
 #define tc_reduce_tr		pal_tc_info_s.reduce_tr
 #define tc_unified		pal_tc_info_s.unified
 #define tc_pf			pal_tc_info_s.pf
@@ -1298,10 +1299,10 @@
 #define tc_num_sets		pal_tc_info_s.num_sets
=20
=20
-/* Return information about the virtual memory characteristics of the proc=
essor=20
+/* Return information about the virtual memory characteristics of the proc=
essor
  * implementation.
  */
-static inline s64=20
+static inline s64
 ia64_pal_vm_info (u64 tc_level, u64 tc_type,  pal_tc_info_u_t *tc_info, u6=
4 *tc_pages)
 {
 	struct ia64_pal_retval iprv;
@@ -1309,14 +1310,14 @@
 	if (tc_info)
 		tc_info->pti_val =3D iprv.v0;
 	if (tc_pages)
-		*tc_pages =3D iprv.v1;=09
-	return iprv.status;=20
+		*tc_pages =3D iprv.v1;
+	return iprv.status;
 }
=20
-/* Get page size information about the virtual memory characteristics of t=
he processor=20
+/* Get page size information about the virtual memory characteristics of t=
he processor
  * implementation.
  */
-static inline s64=20
+static inline s64
 ia64_pal_vm_page_size (u64 *tr_pages, u64 *vw_pages)
 {
 	struct ia64_pal_retval iprv;
@@ -1324,8 +1325,8 @@
 	if (tr_pages)
 		*tr_pages =3D iprv.v0;
 	if (vw_pages)
-		*vw_pages =3D iprv.v1;=09
-	return iprv.status;=20
+		*vw_pages =3D iprv.v1;
+	return iprv.status;
 }
=20
 typedef union pal_vm_info_1_u {
@@ -1348,23 +1349,23 @@
 	struct {
 		u64		impl_va_msb	: 8,
 				rid_size	: 8,
-				reserved	: 48;	=09
+				reserved	: 48;
 	} pal_vm_info_2_s;
 } pal_vm_info_2_u_t;
-	=09
-/* Get summary information about the virtual memory characteristics of the=
 processor=20
+
+/* Get summary information about the virtual memory characteristics of the=
 processor
  * implementation.
  */
-static inline s64=20
-ia64_pal_vm_summary (pal_vm_info_1_u_t *vm_info_1, pal_vm_info_2_u_t *vm_i=
nfo_2)=20
-{=09
+static inline s64
+ia64_pal_vm_summary (pal_vm_info_1_u_t *vm_info_1, pal_vm_info_2_u_t *vm_i=
nfo_2)
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_VM_SUMMARY, 0, 0, 0);
 	if (vm_info_1)
 		vm_info_1->pvi1_val =3D iprv.v0;
 	if (vm_info_2)
 		vm_info_2->pvi2_val =3D iprv.v1;
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 typedef union pal_itr_valid_u {
@@ -1379,14 +1380,14 @@
 } pal_tr_valid_u_t;
=20
 /* Read a translation register */
-static inline s64=20
+static inline s64
 ia64_pal_tr_read (u64 reg_num, u64 tr_type, u64 *tr_buffer, pal_tr_valid_u=
_t *tr_valid)
 {
 	struct ia64_pal_retval iprv;
 	PAL_CALL_PHYS_STK(iprv, PAL_VM_TR_READ, reg_num, tr_type,(u64)__pa(tr_buf=
fer));
 	if (tr_valid)
 		tr_valid->piv_val =3D iprv.v0;
-	return iprv.status;=20
+	return iprv.status;
 }
=20
 static inline s64
diff -urN linux-davidm/include/asm-ia64/perfmon.h linux-2.4.10-lia/include/=
asm-ia64/perfmon.h
--- linux-davidm/include/asm-ia64/perfmon.h	Thu Apr  5 12:51:47 2001
+++ linux-2.4.10-lia/include/asm-ia64/perfmon.h	Mon Sep 24 22:07:39 2001
@@ -9,7 +9,7 @@
 #include <linux/types.h>
=20
 /*
- * Structure used to define a context
+ * Request structure used to define a context
  */
 typedef struct {
 	unsigned long smpl_entries;	/* how many entries in sampling buffer */
@@ -23,7 +23,7 @@
 } pfreq_context_t;
=20
 /*
- * Structure used to configure a PMC or PMD
+ * Request structure used to write/read a PMC or PMD
  */
 typedef struct {
 	unsigned long	reg_num;	/* which register */
@@ -41,11 +41,16 @@
 	pfreq_reg_t	pfr_reg;	/* request to configure a PMD/PMC */
 } perfmon_req_t;
=20
+#ifdef __KERNEL__
+
 extern void pfm_save_regs (struct task_struct *);
 extern void pfm_load_regs (struct task_struct *);
=20
-extern int pfm_inherit (struct task_struct *);
+extern int pfm_inherit (struct task_struct *, struct pt_regs *);
 extern void pfm_context_exit (struct task_struct *);
 extern void pfm_flush_regs (struct task_struct *);
+extern void pfm_cleanup_notifiers (struct task_struct *);
+
+#endif /* __KERNEL__ */
=20
 #endif /* _ASM_IA64_PERFMON_H */
diff -urN linux-davidm/include/asm-ia64/pgalloc.h linux-2.4.10-lia/include/=
asm-ia64/pgalloc.h
--- linux-davidm/include/asm-ia64/pgalloc.h	Tue Jul 31 10:30:09 2001
+++ linux-2.4.10-lia/include/asm-ia64/pgalloc.h	Mon Sep 24 23:02:56 2001
@@ -9,7 +9,7 @@
  * in <asm/page.h> (currently 8192).
  *
  * Copyright (C) 1998-2001 Hewlett-Packard Co
- * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 2000, Goutham Rao <goutham.rao@intel.com>
  */
=20
@@ -164,11 +164,6 @@
 #else
 # define flush_tlb_all()	__flush_tlb_all()
 #endif
-
-/*
- * Serialize usage of ptc.g:
- */
-extern spinlock_t ptcg_lock;
=20
 /*
  * Flush a specified user mapping
diff -urN linux-davidm/include/asm-ia64/processor.h linux-2.4.10-lia/includ=
e/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Mon Sep 24 22:31:45 2001
+++ linux-2.4.10-lia/include/asm-ia64/processor.h	Mon Sep 24 22:26:48 2001
@@ -190,6 +190,7 @@
 #include <asm/page.h>
 #include <asm/rse.h>
 #include <asm/unwind.h>
+#include <asm/atomic.h>
=20
 /* like above but expressed as bitfields for more efficient access: */
 struct ia64_psr {
@@ -332,6 +333,9 @@
 	__u64 map_base;			/* base address for get_unmapped_area() */
 	__u64 task_size;		/* limit for task size */
 	struct siginfo *siginfo;	/* current siginfo struct for ptrace() */
+#if JITTER_BUG
+	__u64 mem;
+#endif
=20
 #ifdef CONFIG_IA32_SUPPORT
 	__u64 eflag;			/* IA32 EFLAGS reg */
@@ -353,9 +357,10 @@
 #ifdef CONFIG_PERFMON
 	__u64 pmc[IA64_NUM_PMC_REGS];
 	__u64 pmd[IA64_NUM_PMD_REGS];
-	unsigned long pfm_pend_notify;	/* non-zero if we need to notify and block=
 */
+	unsigned long pfm_must_block;	/* non-zero if we need to block on overflow=
 */
 	void *pfm_context;		/* pointer to detailed PMU context */
-# define INIT_THREAD_PM		{0, }, {0, }, 0, 0,
+	atomic_t pfm_notifiers_check;	/* indicate if release_thread much check ta=
sklist */
+# define INIT_THREAD_PM		{0, }, {0, }, 0, 0, {0},
 #else
 # define INIT_THREAD_PM
 #endif
@@ -815,9 +820,22 @@
=20
 #define THREAD_SIZE	IA64_STK_OFFSET
 /* NOTE: The task struct and the stacks are allocated together.  */
-#define alloc_task_struct() \
+#if JITTER_BUG
+# define alloc_task_struct()									 \
+({												 \
+	unsigned long color, mem =3D __get_free_pages(GFP_KERNEL, IA64_TASK_STRUC=
T_LOG_NUM_PAGES); \
+	struct task_struct *p;									 \
+	color =3D ia64_fetch_and_add(1, &task_color) % NUM_TASK_COLORS;				 \
+	p =3D (struct task_struct *) (mem + color*MAX_JITTER_SIZE/(NUM_TASK_COLOR=
S - 1));		 \
+	p->thread.mem =3D mem;									 \
+	p;											 \
+})
+# define free_task_struct(p)	free_pages((p)->thread.mem, IA64_TASK_STRUCT_=
LOG_NUM_PAGES)
+#else
+# define alloc_task_struct() \
         ((struct task_struct *) __get_free_pages(GFP_KERNEL, IA64_TASK_STR=
UCT_LOG_NUM_PAGES))
-#define free_task_struct(p)     free_pages((unsigned long)(p), IA64_TASK_S=
TRUCT_LOG_NUM_PAGES)
+# define free_task_struct(p)	free_pages((unsigned long)(p), IA64_TASK_STRU=
CT_LOG_NUM_PAGES)
+#endif
 #define get_task_struct(tsk)	atomic_inc(&virt_to_page(tsk)->count)
=20
 #define init_task	(init_task_union.task)
@@ -970,45 +988,33 @@
 	return result;
 }
=20
-#define ARCH_HAS_PREFETCH
-#define ARCH_HAS_PREFETCHW
-#define ARCH_HAS_SPINLOCK_PREFETCH
-
-#define PREFETCH_STRIDE		256
-
-extern inline void
-prefetch (const void *x)
-{
-	__asm__ __volatile__ ("lfetch [%0]" : : "r"(x));
-}
-
-extern inline void
-prefetchw (const void *x)
+static inline __u64
+ia64_tpa (__u64 addr)
 {
-	__asm__ __volatile__ ("lfetch.excl [%0]" : : "r"(x));
+	__u64 result;
+	asm ("tpa %0=3D%1" : "=3Dr"(result) : "r"(addr));
+	return result;
 }
=20
-#define prefetch_spin_lock(x)   prefetchw(x)
-
-
 #define ARCH_HAS_PREFETCH
 #define ARCH_HAS_PREFETCHW
 #define ARCH_HAS_SPINLOCK_PREFETCH
 #define PREFETCH_STRIDE 256
=20
-extern inline void prefetch(const void *x)
+extern inline void
+prefetch (const void *x)
 {
          __asm__ __volatile__ ("lfetch [%0]" : : "r"(x));
 }
-        =20
-extern inline void prefetchw(const void *x)
+
+extern inline void
+prefetchw (const void *x)
 {
 	__asm__ __volatile__ ("lfetch.excl [%0]" : : "r"(x));
 }
=20
-#define spin_lock_prefetch(x)   prefetchw(x)
+#define spin_lock_prefetch(x)	prefetchw(x)
=20
-                 =20
 #endif /* !__ASSEMBLY__ */
=20
 #endif /* _ASM_IA64_PROCESSOR_H */
diff -urN linux-davidm/include/asm-ia64/sal.h linux-2.4.10-lia/include/asm-=
ia64/sal.h
--- linux-davidm/include/asm-ia64/sal.h	Mon Sep 24 22:31:45 2001
+++ linux-2.4.10-lia/include/asm-ia64/sal.h	Mon Sep 24 22:57:49 2001
@@ -179,10 +179,8 @@
 } ia64_sal_ptc_domain_info_t;
=20
 typedef struct ia64_sal_ptc_domain_proc_entry {
-	u64 reserved : 16;
-	u64 eid : 8;		/* eid of processor */
 	u64 id  : 8;		/* id of processor */
-	u64 ignored : 32;
+	u64 eid : 8;		/* eid of processor */
 } ia64_sal_ptc_domain_proc_entry_t;
=20
=20
diff -urN linux-davidm/include/asm-ia64/semaphore.h linux-2.4.10-lia/includ=
e/asm-ia64/semaphore.h
--- linux-davidm/include/asm-ia64/semaphore.h	Tue Apr 17 17:19:31 2001
+++ linux-2.4.10-lia/include/asm-ia64/semaphore.h	Mon Sep 24 23:02:56 2001
@@ -63,8 +63,6 @@
 extern int  __down_trylock (struct semaphore * sem);
 extern void __up (struct semaphore * sem);
=20
-extern spinlock_t semaphore_wake_lock;
-
 /*
  * Atomically decrement the semaphore's count.  If it goes negative,
  * block the calling thread in the TASK_UNINTERRUPTIBLE state.
diff -urN linux-davidm/include/asm-ia64/sembuf.h linux-2.4.10-lia/include/a=
sm-ia64/sembuf.h
--- linux-davidm/include/asm-ia64/sembuf.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.10-lia/include/asm-ia64/sembuf.h	Mon Sep 24 22:10:28 2001
@@ -1,7 +1,7 @@
 #ifndef _ASM_IA64_SEMBUF_H
 #define _ASM_IA64_SEMBUF_H
=20
-/*=20
+/*
  * The semid64_ds structure for IA-64 architecture.
  * Note extra padding because this structure is passed back and forth
  * between kernel and user space.
diff -urN linux-davidm/include/asm-ia64/shmbuf.h linux-2.4.10-lia/include/a=
sm-ia64/shmbuf.h
--- linux-davidm/include/asm-ia64/shmbuf.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.10-lia/include/asm-ia64/shmbuf.h	Mon Sep 24 22:10:36 2001
@@ -1,7 +1,7 @@
 #ifndef _ASM_IA64_SHMBUF_H
 #define _ASM_IA64_SHMBUF_H
=20
-/*=20
+/*
  * The shmid64_ds structure for IA-64 architecture.
  * Note extra padding because this structure is passed back and forth
  * between kernel and user space.
diff -urN linux-davidm/include/asm-ia64/sigcontext.h linux-2.4.10-lia/inclu=
de/asm-ia64/sigcontext.h
--- linux-davidm/include/asm-ia64/sigcontext.h	Mon Sep 24 22:31:45 2001
+++ linux-2.4.10-lia/include/asm-ia64/sigcontext.h	Mon Sep 24 22:10:45 2001
@@ -18,6 +18,19 @@
=20
 # ifndef __ASSEMBLY__
=20
+/*
+ * Note on handling of register backing store: sc_ar_bsp contains the addr=
ess that would
+ * be found in ar.bsp after executing a "cover" instruction the context in=
 which the
+ * signal was raised.  If signal delivery required switching to an alterna=
te signal stack
+ * (sc_rbs_base is not NULL), the "dirty" partition (as it would exist aft=
er executing the
+ * imaginary "cover" instruction) is backed by the *alternate* signal stac=
k, not the
+ * original one.  In this case, sc_rbs_base contains the base address of t=
he new register
+ * backing store.  The number of registers in the dirty partition can be c=
alculated as:
+ *
+ *   ndirty =3D ia64_rse_num_regs(sc_rbs_base, sc_rbs_base + (sc_loadrs >>=
 16))
+ *
+ */
+
 struct sigcontext {
 	unsigned long		sc_flags;	/* see manifest constants above */
 	unsigned long		sc_nat;		/* bit i =3D 1 iff scratch reg gr[i] is a NaT */
@@ -40,8 +53,10 @@
 	unsigned long		sc_gr[32];	/* general registers (static partition) */
 	struct ia64_fpreg	sc_fr[128];	/* floating-point registers */
=20
-	unsigned long		sc_rsvd[16];	/* reserved for future use */
+	unsigned long		sc_rbs_base;	/* NULL or new base of sighandler's rbs */
+	unsigned long		sc_loadrs;	/* see description above */
=20
+	unsigned long		sc_rsvd[14];	/* reserved for future use */
 	/*
 	 * The mask must come last so we can increase _NSIG_WORDS
 	 * without breaking binary compatibility.
diff -urN linux-davidm/include/asm-ia64/signal.h linux-2.4.10-lia/include/a=
sm-ia64/signal.h
--- linux-davidm/include/asm-ia64/signal.h	Tue Jul 31 10:30:09 2001
+++ linux-2.4.10-lia/include/asm-ia64/signal.h	Mon Sep 24 22:10:57 2001
@@ -2,8 +2,8 @@
 #define _ASM_IA64_SIGNAL_H
=20
 /*
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * Unfortunately, this file is being included by bits/signal.h in
  * glibc-2.x.  Hence the #ifdef __KERNEL__ ugliness.
@@ -80,14 +80,24 @@
=20
 #define SA_RESTORER	0x04000000
=20
-/*=20
+/*
  * sigaltstack controls
  */
 #define SS_ONSTACK	1
 #define SS_DISABLE	2
=20
-#define MINSIGSTKSZ	2048
-#define SIGSTKSZ	8192
+/*
+ * The minimum stack size needs to be fairly large because we want to
+ * be sure that an app compiled for today's CPUs will continue to run
+ * on all future CPU models.  The CPU model matters because the signal
+ * frame needs to have space for the complete machine state, including
+ * all physical stacked registers.  The number of physical stacked
+ * registers is CPU model dependent, but given that the width of
+ * ar.rsc.loadrs is 14 bits, we can assume that they'll never take up
+ * more than 16KB of space.
+ */
+#define MINSIGSTKSZ	131027	/* min. stack size for sigaltstack() */
+#define SIGSTKSZ	262144	/* default stack size for sigaltstack() */
=20
 #ifdef __KERNEL__
=20
diff -urN linux-davidm/include/asm-ia64/smp.h linux-2.4.10-lia/include/asm-=
ia64/smp.h
--- linux-davidm/include/asm-ia64/smp.h	Tue Jul 31 10:30:09 2001
+++ linux-2.4.10-lia/include/asm-ia64/smp.h	Mon Sep 24 22:26:48 2001
@@ -4,7 +4,7 @@
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
  * Copyright (C) 2001 Hewlett-Packard Co
- * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #ifndef _ASM_IA64_SMP_H
 #define _ASM_IA64_SMP_H
@@ -18,6 +18,7 @@
 #include <linux/kernel.h>
=20
 #include <asm/io.h>
+#include <asm/param.h>
 #include <asm/processor.h>
 #include <asm/ptrace.h>
=20
@@ -107,7 +108,12 @@
 	return lid.f.id << 8 | lid.f.eid;
 }
=20
-#define NO_PROC_ID		(-1)
+#define NO_PROC_ID		0xffffffff	/* no processor magic marker */
+
+/*
+ * Extra overhead to move a task from one cpu to another (due to TLB and c=
ache misses).
+ * Expressed in "negative nice value" units (larger number means higher pr=
iority/penalty).
+ */
 #define PROC_CHANGE_PENALTY	20
=20
 extern void __init init_smp_config (void);
diff -urN linux-davidm/include/asm-ia64/smplock.h linux-2.4.10-lia/include/=
asm-ia64/smplock.h
--- linux-davidm/include/asm-ia64/smplock.h	Thu Apr  5 12:51:47 2001
+++ linux-2.4.10-lia/include/asm-ia64/smplock.h	Mon Sep 24 23:02:56 2001
@@ -17,7 +17,7 @@
 /*
  * Release global kernel lock and global interrupt lock
  */
-static __inline__ void=20
+static __inline__ void
 release_kernel_lock(struct task_struct *task, int cpu)
 {
 	if (task->lock_depth >=3D 0)
@@ -29,7 +29,7 @@
 /*
  * Re-acquire the kernel lock
  */
-static __inline__ void=20
+static __inline__ void
 reacquire_kernel_lock(struct task_struct *task)
 {
 	if (task->lock_depth >=3D 0)
@@ -43,14 +43,14 @@
  * so we only need to worry about other
  * CPU's.
  */
-static __inline__ void=20
+static __inline__ void
 lock_kernel(void)
 {
 	if (!++current->lock_depth)
 		spin_lock(&kernel_flag);
 }
=20
-static __inline__ void=20
+static __inline__ void
 unlock_kernel(void)
 {
 	if (--current->lock_depth < 0)
diff -urN linux-davidm/include/asm-ia64/spinlock.h linux-2.4.10-lia/include=
/asm-ia64/spinlock.h
--- linux-davidm/include/asm-ia64/spinlock.h	Mon Sep 24 22:31:45 2001
+++ linux-2.4.10-lia/include/asm-ia64/spinlock.h	Mon Sep 24 22:56:20 2001
@@ -84,7 +84,7 @@
 	"mov r29 =3D 1\n"						\
 	";;\n"							\
 	"1:\n"							\
-	"ld4 r2 =3D [%0]\n"					\
+	"ld4.bias r2 =3D [%0]\n"					\
 	";;\n"							\
 	"cmp4.eq p0,p7 =3D r0,r2\n"				\
 	"(p7) br.cond.spnt.few 1b \n"				\
diff -urN linux-davidm/include/linux/highmem.h linux-2.4.10-lia/include/lin=
ux/highmem.h
--- linux-davidm/include/linux/highmem.h	Mon Sep 24 22:31:45 2001
+++ linux-2.4.10-lia/include/linux/highmem.h	Mon Sep 24 23:02:56 2001
@@ -46,7 +46,7 @@
 static inline void clear_user_highpage(struct page *page, unsigned long va=
ddr)
 {
 	void *addr =3D kmap_atomic(page, KM_USER0);
-	clear_user_page(addr, vaddr);
+	clear_user_page(addr, vaddr, page);
 	kunmap_atomic(addr, KM_USER0);
 }
=20
@@ -88,7 +88,7 @@
=20
 	vfrom =3D kmap_atomic(from, KM_USER0);
 	vto =3D kmap_atomic(to, KM_USER1);
-	copy_user_page(vto, vfrom, vaddr);
+	copy_user_page(vto, vfrom, vaddr, to);
 	kunmap_atomic(vfrom, KM_USER0);
 	kunmap_atomic(vto, KM_USER1);
 }
diff -urN linux-davidm/include/linux/list.h linux-2.4.10-lia/include/linux/=
list.h
--- linux-davidm/include/linux/list.h	Mon Sep 24 22:31:45 2001
+++ linux-2.4.10-lia/include/linux/list.h	Mon Sep 24 22:26:48 2001
@@ -5,8 +5,6 @@
=20
 #include <linux/prefetch.h>
=20
-#include <linux/prefetch.h>
-
 /*
  * Simple doubly linked list implementation.
  *
diff -urN linux-davidm/include/linux/smp.h linux-2.4.10-lia/include/linux/s=
mp.h
--- linux-davidm/include/linux/smp.h	Mon Sep 24 22:31:45 2001
+++ linux-2.4.10-lia/include/linux/smp.h	Mon Sep 24 22:26:48 2001
@@ -35,11 +35,6 @@
 extern void smp_boot_cpus(void);
=20
 /*
- * Processor call in. Must hold processors until ..
- */
-extern void smp_callin(void);
-
-/*
  * Multiprocessors may now schedule
  */
 extern void smp_commence(void);
@@ -56,10 +51,6 @@
 extern volatile int smp_threads_ready;
=20
 extern int smp_num_cpus;
-
-extern volatile unsigned long smp_msg_data;
-extern volatile int smp_src_cpu;
-extern volatile int smp_msg_id;
=20
 #define MSG_ALL_BUT_SELF	0x8000	/* Assume <32768 CPU's */
 #define MSG_ALL			0x8001
diff -urN linux-davidm/kernel/module.c linux-2.4.10-lia/kernel/module.c
--- linux-davidm/kernel/module.c	Mon Sep 24 22:31:45 2001
+++ linux-2.4.10-lia/kernel/module.c	Mon Sep 24 21:29:34 2001
@@ -245,7 +245,6 @@
 void __init init_modules(void)
 {
 	kernel_module.nsyms =3D __stop___ksymtab - __start___ksymtab;
-
 	arch_init_modules(&kernel_module);
 }
=20
diff -urN linux-davidm/kernel/printk.c linux-2.4.10-lia/kernel/printk.c
--- linux-davidm/kernel/printk.c	Mon Sep 24 22:31:45 2001
+++ linux-2.4.10-lia/kernel/printk.c	Mon Sep 24 21:29:44 2001
@@ -16,8 +16,6 @@
  *	01Mar01 Andrew Morton <andrewm@uow.edu.au>
  */
=20
-#include <linux/config.h>
-
 #include <linux/mm.h>
 #include <linux/tty.h>
 #include <linux/tty_driver.h>
@@ -312,6 +310,12 @@
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
@@ -662,12 +666,13 @@
 static int current_ypos =3D VGALINES, current_xpos =3D 0;
=20
 void
-early_printk (const char *str)
+early_printk (const char *str, size_t len)
 {
 	char c;
 	int  i, k, j;
=20
-	while ((c =3D *str++) !=3D '\0') {
+	while (len-- > 0) {
+		c =3D *str++;
 		if (current_ypos >=3D VGALINES) {
 			/* scroll 1 line up */
 			for (k =3D 1, j =3D 0; k < VGALINES; k++, j++) {
diff -urN linux-davidm/kernel/sched.c linux-2.4.10-lia/kernel/sched.c
--- linux-davidm/kernel/sched.c	Mon Sep 24 22:31:45 2001
+++ linux-2.4.10-lia/kernel/sched.c	Mon Sep 24 21:29:47 2001
@@ -540,9 +540,6 @@
=20
 	spin_lock_prefetch(&runqueue_lock);
=20
-
-	prefetch_spin_lock(&runqueue_lock);
-
 	if (!current->active_mm) BUG();
 need_resched_back:
 	prev =3D current;
diff -urN linux-davidm/kernel/signal.c linux-2.4.10-lia/kernel/signal.c
--- linux-davidm/kernel/signal.c	Mon Sep 24 15:08:37 2001
+++ linux-2.4.10-lia/kernel/signal.c	Mon Sep 24 22:13:29 2001
@@ -1104,8 +1104,19 @@
 			ss_sp =3D NULL;
 		} else {
 			error =3D -ENOMEM;
+#ifdef __ia64__
+			/*
+			 * XXX fix me: due to an oversight, MINSIGSTKSZ used to be defined
+			 * as 2KB, which is far too small.  This was after Linux kernel
+			 * 2.4.9 but since there are a fair number of ia64 apps out there,
+			 * we continue to allow "too" small sigaltstacks for a while.
+			 */
+			if (ss_size < 2048)
+				goto out;
+#else
 			if (ss_size < MINSIGSTKSZ)
 				goto out;
+#endif
 		}
=20
 		current->sas_ss_sp =3D (unsigned long) ss_sp;
diff -urN linux-davidm/lib/Makefile linux-2.4.10-lia/lib/Makefile
--- linux-davidm/lib/Makefile	Mon Sep 24 22:31:45 2001
+++ linux-2.4.10-lia/lib/Makefile	Mon Sep 24 21:29:52 2001
@@ -10,7 +10,7 @@
=20
 export-objs :=3D cmdline.o dec_and_lock.o rwsem-spinlock.o rwsem.o
=20
-obj-y :=3D errno.o ctype.o string.o vsprintf.o brlock.o cmdline.o bust_spi=
nlocks.o rbtree.o
+obj-y :=3D errno.o ctype.o string.o vsprintf.o brlock.o cmdline.o bust_spi=
nlocks.o rbtree.o crc32.o
=20
 obj-$(CONFIG_RWSEM_GENERIC_SPINLOCK) +=3D rwsem-spinlock.o
 obj-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) +=3D rwsem.o
diff -urN linux-davidm/lib/dec_and_lock.c linux-2.4.10-lia/lib/dec_and_lock=
.c
--- linux-davidm/lib/dec_and_lock.c	Mon Sep 24 15:08:39 2001
+++ linux-2.4.10-lia/lib/dec_and_lock.c	Mon Sep 24 22:13:39 2001
@@ -26,7 +26,6 @@
  * store-conditional approach, for example.
  */
=20
-#ifndef atomic_dec_and_lock
 int atomic_dec_and_lock(atomic_t *atomic, spinlock_t *lock)
 {
 	spin_lock(lock);
@@ -37,4 +36,3 @@
 }
=20
 EXPORT_SYMBOL(atomic_dec_and_lock);
-#endif
diff -urN linux-davidm/mm/memory.c linux-2.4.10-lia/mm/memory.c
--- linux-davidm/mm/memory.c	Mon Sep 24 22:31:45 2001
+++ linux-2.4.10-lia/mm/memory.c	Mon Sep 24 21:30:00 2001
@@ -127,7 +127,7 @@
 	pmd =3D pmd_offset(dir, 0);
 	pgd_clear(dir);
 	for (j =3D 0; j < PTRS_PER_PMD ; j++) {
-		prefetchw(pmd+j+(PREFETCH_STRIDE/16));
+		prefetchw(pmd + j + PREFETCH_STRIDE/sizeof(*pmd));
 		free_one_pmd(pmd+j);
 	}
 	pmd_free(pmd);

