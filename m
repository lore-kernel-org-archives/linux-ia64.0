From: Christoph Hellwig <hch@lst.de>
Date: Wed, 07 Aug 2019 13:30:37 +0000
Subject: [PATCH 17/29] ia64: remove the hpsim platform
Message-Id: <20190807133049.20893-18-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190807133049.20893-1-hch@lst.de>
In-Reply-To: <20190807133049.20893-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The hpsim platform supports the HP IA64 simulator which was useful as a
bring up platform.  But it is fairly non-standard vs real IA64 system
in that it for example doesn't support ACPI.  It also comes with a
whole bunch of simulator specific drivers.  Remove it to simplify the
IA64 port.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/Kconfig                     |  34 +-
 arch/ia64/Makefile                    |  15 +-
 arch/ia64/configs/sim_defconfig       |  52 ---
 arch/ia64/hp/sim/Kconfig              |  23 --
 arch/ia64/hp/sim/Makefile             |  17 -
 arch/ia64/hp/sim/boot/Makefile        |  37 --
 arch/ia64/hp/sim/boot/boot_head.S     | 165 --------
 arch/ia64/hp/sim/boot/bootloader.c    | 175 ---------
 arch/ia64/hp/sim/boot/bootloader.lds  |  67 ----
 arch/ia64/hp/sim/boot/fw-emu.c        | 374 ------------------
 arch/ia64/hp/sim/boot/ssc.h           |  36 --
 arch/ia64/hp/sim/hpsim.S              |  11 -
 arch/ia64/hp/sim/hpsim_console.c      |  77 ----
 arch/ia64/hp/sim/hpsim_irq.c          |  76 ----
 arch/ia64/hp/sim/hpsim_machvec.c      |   3 -
 arch/ia64/hp/sim/hpsim_setup.c        |  41 --
 arch/ia64/hp/sim/hpsim_ssc.h          |  37 --
 arch/ia64/hp/sim/simeth.c             | 510 -------------------------
 arch/ia64/hp/sim/simscsi.c            | 373 ------------------
 arch/ia64/hp/sim/simserial.c          | 521 --------------------------
 arch/ia64/include/asm/acpi.h          |   4 +-
 arch/ia64/include/asm/hpsim.h         |  17 -
 arch/ia64/include/asm/iosapic.h       |  12 -
 arch/ia64/include/asm/machvec.h       |  11 +-
 arch/ia64/include/asm/machvec_hpsim.h |  19 -
 arch/ia64/kernel/Makefile             |   3 +-
 arch/ia64/kernel/irq_ia64.c           |   2 -
 arch/ia64/kernel/setup.c              |  13 +-
 28 files changed, 15 insertions(+), 2710 deletions(-)
 delete mode 100644 arch/ia64/configs/sim_defconfig
 delete mode 100644 arch/ia64/hp/sim/Kconfig
 delete mode 100644 arch/ia64/hp/sim/Makefile
 delete mode 100644 arch/ia64/hp/sim/boot/Makefile
 delete mode 100644 arch/ia64/hp/sim/boot/boot_head.S
 delete mode 100644 arch/ia64/hp/sim/boot/bootloader.c
 delete mode 100644 arch/ia64/hp/sim/boot/bootloader.lds
 delete mode 100644 arch/ia64/hp/sim/boot/fw-emu.c
 delete mode 100644 arch/ia64/hp/sim/boot/ssc.h
 delete mode 100644 arch/ia64/hp/sim/hpsim.S
 delete mode 100644 arch/ia64/hp/sim/hpsim_console.c
 delete mode 100644 arch/ia64/hp/sim/hpsim_irq.c
 delete mode 100644 arch/ia64/hp/sim/hpsim_machvec.c
 delete mode 100644 arch/ia64/hp/sim/hpsim_setup.c
 delete mode 100644 arch/ia64/hp/sim/hpsim_ssc.h
 delete mode 100644 arch/ia64/hp/sim/simeth.c
 delete mode 100644 arch/ia64/hp/sim/simscsi.c
 delete mode 100644 arch/ia64/hp/sim/simserial.c
 delete mode 100644 arch/ia64/include/asm/hpsim.h
 delete mode 100644 arch/ia64/include/asm/machvec_hpsim.h

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index ae3aca14506e..63db7a5378ac 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -10,11 +10,11 @@ config IA64
 	bool
 	select ARCH_MIGHT_HAVE_PC_PARPORT
 	select ARCH_MIGHT_HAVE_PC_SERIO
-	select ACPI if (!IA64_HP_SIM)
-	select ARCH_SUPPORTS_ACPI if (!IA64_HP_SIM)
+	select ACPI
+	select ARCH_SUPPORTS_ACPI
 	select ACPI_SYSTEM_POWER_STATES_SUPPORT if ACPI
 	select ARCH_MIGHT_HAVE_ACPI_PDC if ACPI
-	select FORCE_PCI if (!IA64_HP_SIM)
+	select FORCE_PCI
 	select PCI_DOMAINS if PCI
 	select PCI_SYSCALL if PCI
 	select HAVE_UNSTABLE_SCHED_CLOCK
@@ -140,7 +140,6 @@ config IA64_GENERIC
 	  HP-zx1/sx1000		For HP systems
 	  HP-zx1/sx1000+swiotlb	For HP systems with (broken) DMA-constrained devi=
ces.
 	  SGI-UV		For SGI UV systems
-	  Ski-simulator		For the HP simulator <http://www.hpl.hp.com/research/lin=
ux/ski/>
=20
 	  If you don't know what to do, choose "generic".
=20
@@ -181,11 +180,6 @@ config IA64_SGI_UV
 	  to select this option.  If in doubt, select ia64 generic support
 	  instead.
=20
-config IA64_HP_SIM
-	bool "Ski-simulator"
-	select SWIOTLB
-	depends on !PM
-
 endchoice
=20
 choice
@@ -239,14 +233,7 @@ config IA64_PAGE_SIZE_64KB
=20
 endchoice
=20
-if IA64_HP_SIM
-config HZ
-	default 32
-endif
-
-if !IA64_HP_SIM
 source "kernel/Kconfig.hz"
-endif
=20
 config IA64_BRL_EMU
 	bool
@@ -265,11 +252,6 @@ config IA64_CYCLONE
 	  Say Y here to enable support for IBM EXA Cyclone time source.
 	  If you're unsure, answer N.
=20
-config IOSAPIC
-	bool
-	depends on !IA64_HP_SIM
-	default y
-
 config FORCE_MAX_ZONEORDER
 	int "MAX_ORDER (11 - 17)"  if !HUGETLB_PAGE
 	range 11 17  if !HUGETLB_PAGE
@@ -373,7 +355,7 @@ config ARCH_DISCONTIGMEM_DEFAULT
=20
 config NUMA
 	bool "NUMA support"
-	depends on !IA64_HP_SIM && !FLATMEM
+	depends on !FLATMEM
 	select ACPI_NUMA if ACPI
 	help
 	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
@@ -395,7 +377,7 @@ config NODES_SHIFT
 config VIRTUAL_MEM_MAP
 	bool "Virtual mem map"
 	depends on !SPARSEMEM
-	default y if !IA64_HP_SIM
+	default y
 	help
 	  Say Y to compile the kernel with support for a virtual mem map.
 	  This code also only takes effect if a memory hole of greater than
@@ -478,7 +460,7 @@ config IA64_HP_AML_NFW
=20
 config KEXEC
 	bool "kexec system call"
-	depends on !IA64_HP_SIM && (!SMP || HOTPLUG_CPU)
+	depends on !SMP || HOTPLUG_CPU
 	select KEXEC_CORE
 	help
 	  kexec is a system call that implements the ability to shutdown your
@@ -496,7 +478,7 @@ config KEXEC
=20
 config CRASH_DUMP
 	  bool "kernel crash dumps"
-	  depends on IA64_MCA_RECOVERY && !IA64_HP_SIM && (!SMP || HOTPLUG_CPU)
+	  depends on IA64_MCA_RECOVERY && (!SMP || HOTPLUG_CPU)
 	  help
 	    Generate crash dump after being started by kexec.
=20
@@ -518,8 +500,6 @@ endif
=20
 endmenu
=20
-source "arch/ia64/hp/sim/Kconfig"
-
 config MSPEC
 	tristate "Memory special operations driver"
 	depends on IA64
diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 0d730b061f72..8f650541d4eb 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -52,15 +52,12 @@ core-$(CONFIG_IA64_HP_ZX1_SWIOTLB) +=3D arch/ia64/dig/
 core-$(CONFIG_IA64_SGI_UV)	+=3D arch/ia64/uv/
=20
 drivers-$(CONFIG_PCI)		+=3D arch/ia64/pci/
-drivers-$(CONFIG_IA64_HP_SIM)	+=3D arch/ia64/hp/sim/
 drivers-$(CONFIG_IA64_HP_ZX1)	+=3D arch/ia64/hp/common/ arch/ia64/hp/zx1/
 drivers-$(CONFIG_IA64_HP_ZX1_SWIOTLB) +=3D arch/ia64/hp/common/ arch/ia64/=
hp/zx1/
-drivers-$(CONFIG_IA64_GENERIC)	+=3D arch/ia64/hp/common/ arch/ia64/hp/zx1/=
 arch/ia64/hp/sim/ arch/ia64/uv/
+drivers-$(CONFIG_IA64_GENERIC)	+=3D arch/ia64/hp/common/ arch/ia64/hp/zx1/=
 arch/ia64/uv/
 drivers-$(CONFIG_OPROFILE)	+=3D arch/ia64/oprofile/
=20
-boot :=3D arch/ia64/hp/sim/boot
-
-PHONY +=3D boot compressed check
+PHONY +=3D compressed check
=20
 all: compressed unwcheck
=20
@@ -69,21 +66,16 @@ compressed: vmlinux.gz
 vmlinuz: vmlinux.gz
=20
 vmlinux.gz: vmlinux
-	$(Q)$(MAKE) $(build)=3D$(boot) $@
=20
 unwcheck: vmlinux
 	-$(Q)READELF=3D$(READELF) $(PYTHON) $(srctree)/arch/ia64/scripts/unwcheck=
.py $<
=20
 archclean:
-	$(Q)$(MAKE) $(clean)=3D$(boot)
=20
 archheaders:
 	$(Q)$(MAKE) $(build)=3Darch/ia64/kernel/syscalls all
=20
-CLEAN_FILES +=3D vmlinux.gz bootloader
-
-boot:	lib/lib.a vmlinux
-	$(Q)$(MAKE) $(build)=3D$(boot) $@
+CLEAN_FILES +=3D vmlinux.gz
=20
 install: vmlinux.gz
 	sh $(srctree)/arch/ia64/install.sh $(KERNELRELEASE) $< System.map "$(INST=
ALL_PATH)"
@@ -91,7 +83,6 @@ install: vmlinux.gz
 define archhelp
   echo '* compressed	- Build compressed kernel image'
   echo '  install	- Install compressed kernel image'
-  echo '  boot		- Build vmlinux and bootloader for Ski simulator'
   echo '* unwcheck	- Check vmlinux for invalid unwind info'
 endef
=20
diff --git a/arch/ia64/configs/sim_defconfig b/arch/ia64/configs/sim_defcon=
fig
deleted file mode 100644
index f0f69fdbddae..000000000000
--- a/arch/ia64/configs/sim_defconfig
+++ /dev/null
@@ -1,52 +0,0 @@
-CONFIG_SYSVIPC=3Dy
-CONFIG_IKCONFIG=3Dy
-CONFIG_IKCONFIG_PROC=3Dy
-CONFIG_LOG_BUF_SHIFT=16
-CONFIG_MODULES=3Dy
-CONFIG_MODULE_UNLOAD=3Dy
-CONFIG_MODULE_FORCE_UNLOAD=3Dy
-CONFIG_MODVERSIONS=3Dy
-CONFIG_PARTITION_ADVANCED=3Dy
-CONFIG_IA64_HP_SIM=3Dy
-CONFIG_MCKINLEY=3Dy
-CONFIG_IA64_PAGE_SIZE_64KB=3Dy
-CONFIG_SMP=3Dy
-CONFIG_NR_CPUSd
-CONFIG_PREEMPT=3Dy
-CONFIG_IA64_PALINFO=3Dm
-CONFIG_EFI_VARS=3Dy
-CONFIG_BINFMT_MISC=3Dy
-CONFIG_NET=3Dy
-CONFIG_PACKET=3Dy
-CONFIG_INET=3Dy
-CONFIG_IP_MULTICAST=3Dy
-# CONFIG_IPV6 is not set
-# CONFIG_STANDALONE is not set
-CONFIG_BLK_DEV_LOOP=3Dy
-CONFIG_BLK_DEV_RAM=3Dy
-CONFIG_SCSI=3Dy
-CONFIG_BLK_DEV_SD=3Dy
-CONFIG_SCSI_CONSTANTS=3Dy
-CONFIG_SCSI_LOGGING=3Dy
-CONFIG_SCSI_SPI_ATTRS=3Dy
-# CONFIG_INPUT_KEYBOARD is not set
-# CONFIG_INPUT_MOUSE is not set
-# CONFIG_SERIO_I8042 is not set
-# CONFIG_LEGACY_PTYS is not set
-CONFIG_EFI_RTC=3Dy
-# CONFIG_VGA_CONSOLE is not set
-CONFIG_HP_SIMETH=3Dy
-CONFIG_HP_SIMSERIAL=3Dy
-CONFIG_HP_SIMSERIAL_CONSOLE=3Dy
-CONFIG_HP_SIMSCSI=3Dy
-CONFIG_EXT2_FS=3Dy
-CONFIG_EXT3_FS=3Dy
-# CONFIG_EXT3_FS_XATTR is not set
-CONFIG_PROC_KCORE=3Dy
-CONFIG_HUGETLBFS=3Dy
-CONFIG_NFS_FS=3Dy
-CONFIG_NFSD=3Dy
-CONFIG_NFSD_V3=3Dy
-CONFIG_DEBUG_INFO=3Dy
-CONFIG_DEBUG_KERNEL=3Dy
-CONFIG_DEBUG_MUTEXES=3Dy
diff --git a/arch/ia64/hp/sim/Kconfig b/arch/ia64/hp/sim/Kconfig
deleted file mode 100644
index 56fb4f1d4f7c..000000000000
--- a/arch/ia64/hp/sim/Kconfig
+++ /dev/null
@@ -1,23 +0,0 @@
-# SPDX-License-Identifier: GPL-2.0
-
-menu "HP Simulator drivers"
-	depends on IA64_HP_SIM || IA64_GENERIC
-
-config HP_SIMETH
-	bool "Simulated Ethernet "
-	depends on NET
-
-config HP_SIMSERIAL
-	bool "Simulated serial driver support"
-	depends on TTY
-
-config HP_SIMSERIAL_CONSOLE
-	bool "Console for HP simulator"
-	depends on HP_SIMSERIAL
-
-config HP_SIMSCSI
-	bool "Simulated SCSI disk"
-	depends on SCSI=3Dy
-
-endmenu
-
diff --git a/arch/ia64/hp/sim/Makefile b/arch/ia64/hp/sim/Makefile
deleted file mode 100644
index 0224a13d2c5b..000000000000
--- a/arch/ia64/hp/sim/Makefile
+++ /dev/null
@@ -1,17 +0,0 @@
-# SPDX-License-Identifier: GPL-2.0
-#
-# ia64/platform/hp/sim/Makefile
-#
-# Copyright (C) 2002 Hewlett-Packard Co.
-#	David Mosberger-Tang <davidm@hpl.hp.com>
-# Copyright (C) 1999 Silicon Graphics, Inc.
-# Copyright (C) Srinivasa Thirumalachar (sprasad@engr.sgi.com)
-#
-
-obj-y :=3D hpsim_irq.o hpsim_setup.o hpsim.o
-obj-$(CONFIG_IA64_GENERIC) +=3D hpsim_machvec.o
-
-obj-$(CONFIG_HP_SIMETH)	+=3D simeth.o
-obj-$(CONFIG_HP_SIMSERIAL) +=3D simserial.o
-obj-$(CONFIG_HP_SIMSERIAL_CONSOLE) +=3D hpsim_console.o
-obj-$(CONFIG_HP_SIMSCSI) +=3D simscsi.o
diff --git a/arch/ia64/hp/sim/boot/Makefile b/arch/ia64/hp/sim/boot/Makefile
deleted file mode 100644
index df6e9968c845..000000000000
--- a/arch/ia64/hp/sim/boot/Makefile
+++ /dev/null
@@ -1,37 +0,0 @@
-#
-# ia64/boot/Makefile
-#
-# This file is subject to the terms and conditions of the GNU General Publ=
ic
-# License.  See the file "COPYING" in the main directory of this archive
-# for more details.
-#
-# Copyright (C) 1998, 2003 by David Mosberger-Tang <davidm@hpl.hp.com>
-#
-
-targets-$(CONFIG_IA64_HP_SIM)  +=3D bootloader
-targets :=3D vmlinux.bin vmlinux.gz $(targets-y)
-
-quiet_cmd_cptotop =3D LN      $@
-      cmd_cptotop =3D ln -f $< $@
-
-vmlinux.gz: $(obj)/vmlinux.gz $(addprefix $(obj)/,$(targets-y))
-	$(call cmd,cptotop)
-	@echo '  Kernel: $@ is ready'
-
-boot: bootloader
-
-bootloader: $(obj)/bootloader
-	$(call cmd,cptotop)
-
-$(obj)/vmlinux.gz: $(obj)/vmlinux.bin FORCE
-	$(call if_changed,gzip)
-
-$(obj)/vmlinux.bin: vmlinux FORCE
-	$(call if_changed,objcopy)
-
-
-LDFLAGS_bootloader =3D -static -T
-
-$(obj)/bootloader: $(src)/bootloader.lds $(obj)/bootloader.o $(obj)/boot_h=
ead.o $(obj)/fw-emu.o \
-                   lib/lib.a arch/ia64/lib/lib.a FORCE
-	$(call if_changed,ld)
diff --git a/arch/ia64/hp/sim/boot/boot_head.S b/arch/ia64/hp/sim/boot/boot=
_head.S
deleted file mode 100644
index a7d178fb41e8..000000000000
--- a/arch/ia64/hp/sim/boot/boot_head.S
+++ /dev/null
@@ -1,165 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 */
-/*
- * Copyright (C) 1998-2003 Hewlett-Packard Co
- *	David Mosberger-Tang <davidm@hpl.hp.com>
- */
-
-#include <asm/asmmacro.h>
-#include <asm/pal.h>
-
-	.bss
-	.align 16
-stack_mem:
-	.skip 16834
-
-	.text
-
-/* This needs to be defined because lib/string.c:strlcat() calls it in cas=
e of error... */
-GLOBAL_ENTRY(printk)
-	break 0
-END(printk)
-
-GLOBAL_ENTRY(_start)
-	.prologue
-	.save rp, r0
-	.body
-	movl gp =3D __gp
-	movl sp =3D stack_mem+16384-16
-	bsw.1
-	br.call.sptk.many rp=3Dstart_bootloader
-0:	nop 0		  /* dummy nop to make unwinding work */
-END(_start)
-
-/*
- * Set a break point on this function so that symbols are available to set=
 breakpoints in
- * the kernel being debugged.
- */
-GLOBAL_ENTRY(debug_break)
-	br.ret.sptk.many b0
-END(debug_break)
-
-GLOBAL_ENTRY(ssc)
-	.regstk 5,0,0,0
-	mov r15=3Din4
-	break 0x80001
-	br.ret.sptk.many b0
-END(ssc)
-
-GLOBAL_ENTRY(jmp_to_kernel)
-	.regstk 2,0,0,0
-	mov r28=3Din0
-	mov b7=3Din1
-	br.sptk.few b7
-END(jmp_to_kernel)
-
-/*
- * r28 contains the index of the PAL function
- * r29--31 the args
- * Return values in ret0--3 (r8--11)
- */
-GLOBAL_ENTRY(pal_emulator_static)
-	mov r8=3D-1
-	mov r9%6
-	;;
-	cmp.gtu p6,p7=3Dr9,r28		/* r28 <=3D 255? */
-(p6)	br.cond.sptk.few static
-	;;
-	mov r9Q2
-	;;
-	cmp.gtu p6,p7=3Dr9,r28
-(p6)	br.cond.sptk.few stacked
-	;;
-static:	cmp.eq p6,p7=3DPAL_PTCE_INFO,r28
-(p7)	br.cond.sptk.few 1f
-	;;
-	mov r8=3D0			/* status =3D 0 */
-	movl r9=3D0x100000000		/* tc.base */
-	movl r10=3D0x0000000200000003	/* count[0], count[1] */
-	movl r11=3D0x1000000000002000	/* stride[0], stride[1] */
-	br.cond.sptk.few rp
-1:	cmp.eq p6,p7=3DPAL_FREQ_RATIOS,r28
-(p7)	br.cond.sptk.few 1f
-	mov r8=3D0			/* status =3D 0 */
-	movl r9 =3D0x100000064		/* proc_ratio (1/100) */
-	movl r10=3D0x100000100		/* bus_ratio<<32 (1/256) */
-	movl r11=3D0x100000064		/* itc_ratio<<32 (1/100) */
-	;;
-1:	cmp.eq p6,p7=3DPAL_RSE_INFO,r28
-(p7)	br.cond.sptk.few 1f
-	mov r8=3D0			/* status =3D 0 */
-	mov r9=96			/* num phys stacked */
-	mov r10=3D0			/* hints */
-	mov r11=3D0
-	br.cond.sptk.few rp
-1:	cmp.eq p6,p7=3DPAL_CACHE_FLUSH,r28		/* PAL_CACHE_FLUSH */
-(p7)	br.cond.sptk.few 1f
-	mov r9=3Dar.lc
-	movl r8R4288			/* flush 512k million cache lines (16MB) */
-	;;
-	mov ar.lc=3Dr8
-	movl r8=3D0xe000000000000000
-	;;
-.loop:	fc r8
-	add r82,r8
-	br.cloop.sptk.few .loop
-	sync.i
-	;;
-	srlz.i
-	;;
-	mov ar.lc=3Dr9
-	mov r8=3Dr0
-	;;
-1:	cmp.eq p6,p7=3DPAL_PERF_MON_INFO,r28
-(p7)	br.cond.sptk.few 1f
-	mov r8=3D0			/* status =3D 0 */
-	movl r9 =3D0x08122f04		/* generic=3D4 widthG retired=3D8 cycles=18 */
-	mov r10=3D0			/* reserved */
-	mov r11=3D0			/* reserved */
-	mov r16=3D0xffff			/* implemented PMC */
-	mov r17=3D0x3ffff			/* implemented PMD */
-	add r18=3D8,r29			/* second index */
-	;;
-	st8 [r29]=3Dr16,16		/* store implemented PMC */
-	st8 [r18]=3Dr0,16			/* clear remaining bits  */
-	;;
-	st8 [r29]=3Dr0,16			/* clear remaining bits  */
-	st8 [r18]=3Dr0,16			/* clear remaining bits  */
-	;;
-	st8 [r29]=3Dr17,16		/* store implemented PMD */
-	st8 [r18]=3Dr0,16			/* clear remaining bits  */
-	mov r16=3D0xf0			/* cycles count capable PMC */
-	;;
-	st8 [r29]=3Dr0,16			/* clear remaining bits  */
-	st8 [r18]=3Dr0,16			/* clear remaining bits  */
-	mov r17=3D0xf0			/* retired bundles capable PMC */
-	;;
-	st8 [r29]=3Dr16,16		/* store cycles capable */
-	st8 [r18]=3Dr0,16			/* clear remaining bits  */
-	;;
-	st8 [r29]=3Dr0,16			/* clear remaining bits  */
-	st8 [r18]=3Dr0,16			/* clear remaining bits  */
-	;;
-	st8 [r29]=3Dr17,16		/* store retired bundle capable */
-	st8 [r18]=3Dr0,16			/* clear remaining bits  */
-	;;
-	st8 [r29]=3Dr0,16			/* clear remaining bits  */
-	st8 [r18]=3Dr0,16			/* clear remaining bits  */
-	;;
-1:	cmp.eq p6,p7=3DPAL_VM_SUMMARY,r28
-(p7)	br.cond.sptk.few 1f
-	mov	r8=3D0			/* status =3D 0  */
-	movl	r9=3D0x2044040020F1865	/* num_tc_levels=3D2, num_unique_tcs=3D4 */
-					/* max_itr_entryd, max_dtr_entryd */
-					/* hash_tag_id=3D2, max_pkr=15 */
-					/* key_size$, phys_add_sizeP, vw=3D1 */
-	movl	r10=3D0x183C		/* rid_size$, impl_va_msb` */
-	;;
-1:	cmp.eq p6,p7=3DPAL_MEM_ATTRIB,r28
-(p7)	br.cond.sptk.few 1f
-	mov	r8=3D0			/* status =3D 0 */
-	mov	r9=3D0x80|0x01		/* NatPage|WB */
-	;;
-1:	br.cond.sptk.few rp
-stacked:
-	br.ret.sptk.few rp
-END(pal_emulator_static)
diff --git a/arch/ia64/hp/sim/boot/bootloader.c b/arch/ia64/hp/sim/boot/boo=
tloader.c
deleted file mode 100644
index 6d804608dc81..000000000000
--- a/arch/ia64/hp/sim/boot/bootloader.c
+++ /dev/null
@@ -1,175 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * arch/ia64/hp/sim/boot/bootloader.c
- *
- * Loads an ELF kernel.
- *
- * Copyright (C) 1998-2003 Hewlett-Packard Co
- *	David Mosberger-Tang <davidm@hpl.hp.com>
- *	Stephane Eranian <eranian@hpl.hp.com>
- *
- * 01/07/99 S.Eranian modified to pass command line arguments to kernel
- */
-struct task_struct;	/* forward declaration for elf.h */
-
-#include <linux/elf.h>
-#include <linux/init.h>
-#include <linux/kernel.h>
-
-#include <asm/elf.h>
-#include <asm/intrinsics.h>
-#include <asm/pal.h>
-#include <asm/pgtable.h>
-#include <asm/sal.h>
-
-#include "ssc.h"
-
-struct disk_req {
-	unsigned long addr;
-	unsigned len;
-};
-
-struct disk_stat {
-	int fd;
-	unsigned count;
-};
-
-extern void jmp_to_kernel (unsigned long bp, unsigned long e_entry);
-extern struct ia64_boot_param *sys_fw_init (const char *args, int arglen);
-extern void debug_break (void);
-
-static void
-cons_write (const char *buf)
-{
-	unsigned long ch;
-
-	while ((ch =3D *buf++) !=3D '\0') {
-		ssc(ch, 0, 0, 0, SSC_PUTCHAR);
-		if (ch =3D '\n')
-		  ssc('\r', 0, 0, 0, SSC_PUTCHAR);
-	}
-}
-
-#define MAX_ARGS 32
-
-void
-start_bootloader (void)
-{
-	static char mem[4096];
-	static char buffer[1024];
-	unsigned long off;
-	int fd, i;
-	struct disk_req req;
-	struct disk_stat stat;
-	struct elfhdr *elf;
-	struct elf_phdr *elf_phdr;	/* program header */
-	unsigned long e_entry, e_phoff, e_phnum;
-	register struct ia64_boot_param *bp;
-	char *kpath, *args;
-	long arglen =3D 0;
-
-	ssc(0, 0, 0, 0, SSC_CONSOLE_INIT);
-
-	/*
-	 * S.Eranian: extract the commandline argument from the simulator
-	 *
-	 * The expected format is as follows:
-         *
-	 *	kernelname args...
-	 *
-	 * Both are optional but you can't have the second one without the first.
-	 */
-	arglen =3D ssc((long) buffer, 0, 0, 0, SSC_GET_ARGS);
-
-	kpath =3D "vmlinux";
-	args =3D buffer;
-	if (arglen > 0) {
-		kpath =3D buffer;
-		while (*args !=3D ' ' && *args !=3D '\0')
-			++args, --arglen;
-		if (*args =3D ' ')
-			*args++ =3D '\0', --arglen;
-	}
-
-	if (arglen <=3D 0) {
-		args =3D "";
-		arglen =3D 1;
-	}
-
-	fd =3D ssc((long) kpath, 1, 0, 0, SSC_OPEN);
-
-	if (fd < 0) {
-		cons_write(kpath);
-		cons_write(": file not found, reboot now\n");
-		for(;;);
-	}
-	stat.fd =3D fd;
-	off =3D 0;
-
-	req.len =3D sizeof(mem);
-	req.addr =3D (long) mem;
-	ssc(fd, 1, (long) &req, off, SSC_READ);
-	ssc((long) &stat, 0, 0, 0, SSC_WAIT_COMPLETION);
-
-	elf =3D (struct elfhdr *) mem;
-	if (elf->e_ident[0] =3D 0x7f && strncmp(elf->e_ident + 1, "ELF", 3) !=3D =
0) {
-		cons_write("not an ELF file\n");
-		return;
-	}
-	if (elf->e_type !=3D ET_EXEC) {
-		cons_write("not an ELF executable\n");
-		return;
-	}
-	if (!elf_check_arch(elf)) {
-		cons_write("kernel not for this processor\n");
-		return;
-	}
-
-	e_entry =3D elf->e_entry;
-	e_phnum =3D elf->e_phnum;
-	e_phoff =3D elf->e_phoff;
-
-	cons_write("loading ");
-	cons_write(kpath);
-	cons_write("...\n");
-
-	for (i =3D 0; i < e_phnum; ++i) {
-		req.len =3D sizeof(*elf_phdr);
-		req.addr =3D (long) mem;
-		ssc(fd, 1, (long) &req, e_phoff, SSC_READ);
-		ssc((long) &stat, 0, 0, 0, SSC_WAIT_COMPLETION);
-		if (stat.count !=3D sizeof(*elf_phdr)) {
-			cons_write("failed to read phdr\n");
-			return;
-		}
-		e_phoff +=3D sizeof(*elf_phdr);
-
-		elf_phdr =3D (struct elf_phdr *) mem;
-
-		if (elf_phdr->p_type !=3D PT_LOAD)
-			continue;
-
-		req.len =3D elf_phdr->p_filesz;
-		req.addr =3D __pa(elf_phdr->p_paddr);
-		ssc(fd, 1, (long) &req, elf_phdr->p_offset, SSC_READ);
-		ssc((long) &stat, 0, 0, 0, SSC_WAIT_COMPLETION);
-		memset((char *)__pa(elf_phdr->p_paddr) + elf_phdr->p_filesz, 0,
-		       elf_phdr->p_memsz - elf_phdr->p_filesz);
-	}
-	ssc(fd, 0, 0, 0, SSC_CLOSE);
-
-	cons_write("starting kernel...\n");
-
-	/* fake an I/O base address: */
-	ia64_setreg(_IA64_REG_AR_KR0, 0xffffc000000UL);
-
-	bp =3D sys_fw_init(args, arglen);
-
-	ssc(0, (long) kpath, 0, 0, SSC_LOAD_SYMBOLS);
-
-	debug_break();
-	jmp_to_kernel((unsigned long) bp, e_entry);
-
-	cons_write("kernel returned!\n");
-	ssc(-1, 0, 0, 0, SSC_EXIT);
-}
diff --git a/arch/ia64/hp/sim/boot/bootloader.lds b/arch/ia64/hp/sim/boot/b=
ootloader.lds
deleted file mode 100644
index f3f284d6514c..000000000000
--- a/arch/ia64/hp/sim/boot/bootloader.lds
+++ /dev/null
@@ -1,67 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 */
-OUTPUT_FORMAT("elf64-ia64-little")
-OUTPUT_ARCH(ia64)
-ENTRY(_start)
-SECTIONS
-{
-  /* Read-only sections, merged into text segment: */
-  . =3D 0x100000;
-
-  _text =3D .;
-  .text : { *(__ivt_section) *(.text) }
-  _etext =3D .;
-
-  /* Global data */
-  _data =3D .;
-  .rodata : { *(.rodata) *(.rodata.*) }
-  .data    : { *(.data) *(.gnu.linkonce.d*) CONSTRUCTORS }
-  __gp =3D ALIGN (8) + 0x200000;
-  .got           : { *(.got.plt) *(.got) }
-  /* We want the small data sections together, so single-instruction offse=
ts
-     can access them all, and initialized data all before uninitialized, so
-     we can shorten the on-disk segment size.  */
-  .sdata     : { *(.sdata) }
-  _edata  =3D  .;
-
-  __bss_start =3D .;
-  .sbss      : { *(.sbss) *(.scommon) }
-  .bss       : { *(.bss) *(COMMON) }
-  . =3D ALIGN(64 / 8);
-  __bss_stop =3D .;
-  _end =3D . ;
-
-  /* Stabs debugging sections.  */
-  .stab 0 : { *(.stab) }
-  .stabstr 0 : { *(.stabstr) }
-  .stab.excl 0 : { *(.stab.excl) }
-  .stab.exclstr 0 : { *(.stab.exclstr) }
-  .stab.index 0 : { *(.stab.index) }
-  .stab.indexstr 0 : { *(.stab.indexstr) }
-  .comment 0 : { *(.comment) }
-  /* DWARF debug sections.
-     Symbols in the DWARF debugging sections are relative to the beginning
-     of the section so we begin them at 0.  */
-  /* DWARF 1 */
-  .debug          0 : { *(.debug) }
-  .line           0 : { *(.line) }
-  /* GNU DWARF 1 extensions */
-  .debug_srcinfo  0 : { *(.debug_srcinfo) }
-  .debug_sfnames  0 : { *(.debug_sfnames) }
-  /* DWARF 1.1 and DWARF 2 */
-  .debug_aranges  0 : { *(.debug_aranges) }
-  .debug_pubnames 0 : { *(.debug_pubnames) }
-  /* DWARF 2 */
-  .debug_info     0 : { *(.debug_info) }
-  .debug_abbrev   0 : { *(.debug_abbrev) }
-  .debug_line     0 : { *(.debug_line) }
-  .debug_frame    0 : { *(.debug_frame) }
-  .debug_str      0 : { *(.debug_str) }
-  .debug_loc      0 : { *(.debug_loc) }
-  .debug_macinfo  0 : { *(.debug_macinfo) }
-  /* SGI/MIPS DWARF 2 extensions */
-  .debug_weaknames 0 : { *(.debug_weaknames) }
-  .debug_funcnames 0 : { *(.debug_funcnames) }
-  .debug_typenames 0 : { *(.debug_typenames) }
-  .debug_varnames  0 : { *(.debug_varnames) }
-  /* These must appear regardless of  .  */
-}
diff --git a/arch/ia64/hp/sim/boot/fw-emu.c b/arch/ia64/hp/sim/boot/fw-emu.c
deleted file mode 100644
index 517fb2822e04..000000000000
--- a/arch/ia64/hp/sim/boot/fw-emu.c
+++ /dev/null
@@ -1,374 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * PAL & SAL emulation.
- *
- * Copyright (C) 1998-2001 Hewlett-Packard Co
- *	David Mosberger-Tang <davidm@hpl.hp.com>
- */
-
-#ifdef CONFIG_PCI
-# include <linux/pci.h>
-#endif
-
-#include <linux/efi.h>
-#include <asm/io.h>
-#include <asm/pal.h>
-#include <asm/sal.h>
-#include <asm/setup.h>
-
-#include "ssc.h"
-
-#define MB	(1024*1024UL)
-
-#define SIMPLE_MEMMAP	1
-
-#if SIMPLE_MEMMAP
-# define NUM_MEM_DESCS	4
-#else
-# define NUM_MEM_DESCS	16
-#endif
-
-static char fw_mem[(  sizeof(struct ia64_boot_param)
-		    + sizeof(efi_system_table_t)
-		    + sizeof(efi_runtime_services_t)
-		    + 1*sizeof(efi_config_table_t)
-		    + sizeof(struct ia64_sal_systab)
-		    + sizeof(struct ia64_sal_desc_entry_point)
-		    + NUM_MEM_DESCS*(sizeof(efi_memory_desc_t))
-		    + 1024)] __attribute__ ((aligned (8)));
-
-#define SECS_PER_HOUR   (60 * 60)
-#define SECS_PER_DAY    (SECS_PER_HOUR * 24)
-
-/* Compute the `struct tm' representation of *T,
-   offset OFFSET seconds east of UTC,
-   and store year, yday, mon, mday, wday, hour, min, sec into *TP.
-   Return nonzero if successful.  */
-int
-offtime (unsigned long t, efi_time_t *tp)
-{
-	const unsigned short int __mon_yday[2][13] -	{
-		/* Normal years.  */
-		{ 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365 },
-		/* Leap years.  */
-		{ 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366 }
-	};
-	long int days, rem, y;
-	const unsigned short int *ip;
-
-	days =3D t / SECS_PER_DAY;
-	rem =3D t % SECS_PER_DAY;
-	while (rem < 0) {
-		rem +=3D SECS_PER_DAY;
-		--days;
-	}
-	while (rem >=3D SECS_PER_DAY) {
-		rem -=3D SECS_PER_DAY;
-		++days;
-	}
-	tp->hour =3D rem / SECS_PER_HOUR;
-	rem %=3D SECS_PER_HOUR;
-	tp->minute =3D rem / 60;
-	tp->second =3D rem % 60;
-	/* January 1, 1970 was a Thursday.  */
-	y =3D 1970;
-
-#	define DIV(a, b) ((a) / (b) - ((a) % (b) < 0))
-#	define LEAPS_THRU_END_OF(y) (DIV (y, 4) - DIV (y, 100) + DIV (y, 400))
-#	define __isleap(year) \
-	  ((year) % 4 =3D 0 && ((year) % 100 !=3D 0 || (year) % 400 =3D 0))
-
-	while (days < 0 || days >=3D (__isleap (y) ? 366 : 365)) {
-		/* Guess a corrected year, assuming 365 days per year.  */
-		long int yg =3D y + days / 365 - (days % 365 < 0);
-
-		/* Adjust DAYS and Y to match the guessed year.  */
-		days -=3D ((yg - y) * 365 + LEAPS_THRU_END_OF (yg - 1)
-			 - LEAPS_THRU_END_OF (y - 1));
-		y =3D yg;
-	}
-	tp->year =3D y;
-	ip =3D __mon_yday[__isleap(y)];
-	for (y =3D 11; days < (long int) ip[y]; --y)
-		continue;
-	days -=3D ip[y];
-	tp->month =3D y + 1;
-	tp->day =3D days + 1;
-	return 1;
-}
-
-extern void pal_emulator_static (void);
-
-/* Macro to emulate SAL call using legacy IN and OUT calls to CF8, CFC etc=
.. */
-
-#define BUILD_CMD(addr)		((0x80000000 | (addr)) & ~3)
-
-#define REG_OFFSET(addr)	(0x00000000000000FF & (addr))
-#define DEVICE_FUNCTION(addr)	(0x000000000000FF00 & (addr))
-#define BUS_NUMBER(addr)	(0x0000000000FF0000 & (addr))
-
-static efi_status_t
-fw_efi_get_time (efi_time_t *tm, efi_time_cap_t *tc)
-{
-#if defined(CONFIG_IA64_HP_SIM) || defined(CONFIG_IA64_GENERIC)
-	struct {
-		int tv_sec;	/* must be 32bits to work */
-		int tv_usec;
-	} tv32bits;
-
-	ssc((unsigned long) &tv32bits, 0, 0, 0, SSC_GET_TOD);
-
-	memset(tm, 0, sizeof(*tm));
-	offtime(tv32bits.tv_sec, tm);
-
-	if (tc)
-		memset(tc, 0, sizeof(*tc));
-#else
-#	error Not implemented yet...
-#endif
-	return EFI_SUCCESS;
-}
-
-static void
-efi_reset_system (int reset_type, efi_status_t status, unsigned long data_=
size, efi_char16_t *data)
-{
-#if defined(CONFIG_IA64_HP_SIM) || defined(CONFIG_IA64_GENERIC)
-	ssc(status, 0, 0, 0, SSC_EXIT);
-#else
-#	error Not implemented yet...
-#endif
-}
-
-static efi_status_t
-efi_unimplemented (void)
-{
-	return EFI_UNSUPPORTED;
-}
-
-static struct sal_ret_values
-sal_emulator (long index, unsigned long in1, unsigned long in2,
-	      unsigned long in3, unsigned long in4, unsigned long in5,
-	      unsigned long in6, unsigned long in7)
-{
-	long r9  =3D 0;
-	long r10 =3D 0;
-	long r11 =3D 0;
-	long status;
-
-	/*
-	 * Don't do a "switch" here since that gives us code that
-	 * isn't self-relocatable.
-	 */
-	status =3D 0;
-	if (index =3D SAL_FREQ_BASE) {
-		if (in1 =3D SAL_FREQ_BASE_PLATFORM)
-			r9 =3D 200000000;
-		else if (in1 =3D SAL_FREQ_BASE_INTERVAL_TIMER) {
-			/*
-			 * Is this supposed to be the cr.itc frequency
-			 * or something platform specific?  The SAL
-			 * doc ain't exactly clear on this...
-			 */
-			r9 =3D 700000000;
-		} else if (in1 =3D SAL_FREQ_BASE_REALTIME_CLOCK)
-			r9 =3D 1;
-		else
-			status =3D -1;
-	} else if (index =3D SAL_SET_VECTORS) {
-		;
-	} else if (index =3D SAL_GET_STATE_INFO) {
-		;
-	} else if (index =3D SAL_GET_STATE_INFO_SIZE) {
-		;
-	} else if (index =3D SAL_CLEAR_STATE_INFO) {
-		;
-	} else if (index =3D SAL_MC_RENDEZ) {
-		;
-	} else if (index =3D SAL_MC_SET_PARAMS) {
-		;
-	} else if (index =3D SAL_CACHE_FLUSH) {
-		;
-	} else if (index =3D SAL_CACHE_INIT) {
-		;
-#ifdef CONFIG_PCI
-	} else if (index =3D SAL_PCI_CONFIG_READ) {
-		/*
-		 * in1 contains the PCI configuration address and in2
-		 * the size of the read.  The value that is read is
-		 * returned via the general register r9.
-		 */
-                outl(BUILD_CMD(in1), 0xCF8);
-                if (in2 =3D 1)                           /* Reading byte  =
*/
-                        r9 =3D inb(0xCFC + ((REG_OFFSET(in1) & 3)));
-                else if (in2 =3D 2)                      /* Reading word  =
*/
-                        r9 =3D inw(0xCFC + ((REG_OFFSET(in1) & 2)));
-                else                                    /* Reading dword */
-                        r9 =3D inl(0xCFC);
-                status =3D PCIBIOS_SUCCESSFUL;
-	} else if (index =3D SAL_PCI_CONFIG_WRITE) {
-	      	/*
-		 * in1 contains the PCI configuration address, in2 the
-		 * size of the write, and in3 the actual value to be
-		 * written out.
-		 */
-                outl(BUILD_CMD(in1), 0xCF8);
-                if (in2 =3D 1)                           /* Writing byte  =
*/
-                        outb(in3, 0xCFC + ((REG_OFFSET(in1) & 3)));
-                else if (in2 =3D 2)                      /* Writing word  =
*/
-                        outw(in3, 0xCFC + ((REG_OFFSET(in1) & 2)));
-                else                                    /* Writing dword */
-                        outl(in3, 0xCFC);
-                status =3D PCIBIOS_SUCCESSFUL;
-#endif /* CONFIG_PCI */
-	} else if (index =3D SAL_UPDATE_PAL) {
-		;
-	} else {
-		status =3D -1;
-	}
-	return ((struct sal_ret_values) {status, r9, r10, r11});
-}
-
-struct ia64_boot_param *
-sys_fw_init (const char *args, int arglen)
-{
-	efi_system_table_t *efi_systab;
-	efi_runtime_services_t *efi_runtime;
-	efi_config_table_t *efi_tables;
-	struct ia64_sal_systab *sal_systab;
-	efi_memory_desc_t *efi_memmap, *md;
-	unsigned long *pal_desc, *sal_desc;
-	struct ia64_sal_desc_entry_point *sal_ed;
-	struct ia64_boot_param *bp;
-	unsigned char checksum =3D 0;
-	char *cp, *cmd_line;
-	int i =3D 0;
-#	define MAKE_MD(typ, attr, start, end)		\
-	do {						\
-		md =3D efi_memmap + i++;			\
-		md->type =3D typ;				\
-		md->pad =3D 0;				\
-		md->phys_addr =3D start;			\
-		md->virt_addr =3D 0;			\
-		md->num_pages =3D (end - start) >> 12;	\
-		md->attribute =3D attr;			\
-	} while (0)
-
-	memset(fw_mem, 0, sizeof(fw_mem));
-
-	pal_desc =3D (unsigned long *) &pal_emulator_static;
-	sal_desc =3D (unsigned long *) &sal_emulator;
-
-	cp =3D fw_mem;
-	efi_systab  =3D (void *) cp; cp +=3D sizeof(*efi_systab);
-	efi_runtime =3D (void *) cp; cp +=3D sizeof(*efi_runtime);
-	efi_tables  =3D (void *) cp; cp +=3D sizeof(*efi_tables);
-	sal_systab  =3D (void *) cp; cp +=3D sizeof(*sal_systab);
-	sal_ed      =3D (void *) cp; cp +=3D sizeof(*sal_ed);
-	efi_memmap  =3D (void *) cp; cp +=3D NUM_MEM_DESCS*sizeof(*efi_memmap);
-	bp	    =3D (void *) cp; cp +=3D sizeof(*bp);
-	cmd_line    =3D (void *) cp;
-
-	if (args) {
-		if (arglen >=3D 1024)
-			arglen =3D 1023;
-		memcpy(cmd_line, args, arglen);
-	} else {
-		arglen =3D 0;
-	}
-	cmd_line[arglen] =3D '\0';
-
-	memset(efi_systab, 0, sizeof(*efi_systab));
-	efi_systab->hdr.signature =3D EFI_SYSTEM_TABLE_SIGNATURE;
-	efi_systab->hdr.revision  =3D ((1 << 16) | 00);
-	efi_systab->hdr.headersize =3D sizeof(efi_systab->hdr);
-	efi_systab->fw_vendor =3D __pa("H\0e\0w\0l\0e\0t\0t\0-\0P\0a\0c\0k\0a\0r\=
0d\0\0");
-	efi_systab->fw_revision =3D 1;
-	efi_systab->runtime =3D (void *) __pa(efi_runtime);
-	efi_systab->nr_tables =3D 1;
-	efi_systab->tables =3D __pa(efi_tables);
-
-	efi_runtime->hdr.signature =3D EFI_RUNTIME_SERVICES_SIGNATURE;
-	efi_runtime->hdr.revision =3D EFI_RUNTIME_SERVICES_REVISION;
-	efi_runtime->hdr.headersize =3D sizeof(efi_runtime->hdr);
-	efi_runtime->get_time =3D (void *)__pa(&fw_efi_get_time);
-	efi_runtime->set_time =3D (void *)__pa(&efi_unimplemented);
-	efi_runtime->get_wakeup_time =3D (void *)__pa(&efi_unimplemented);
-	efi_runtime->set_wakeup_time =3D (void *)__pa(&efi_unimplemented);
-	efi_runtime->set_virtual_address_map =3D (void *)__pa(&efi_unimplemented);
-	efi_runtime->get_variable =3D (void *)__pa(&efi_unimplemented);
-	efi_runtime->get_next_variable =3D (void *)__pa(&efi_unimplemented);
-	efi_runtime->set_variable =3D (void *)__pa(&efi_unimplemented);
-	efi_runtime->get_next_high_mono_count =3D (void *)__pa(&efi_unimplemented=
);
-	efi_runtime->reset_system =3D (void *)__pa(&efi_reset_system);
-
-	efi_tables->guid =3D SAL_SYSTEM_TABLE_GUID;
-	efi_tables->table =3D __pa(sal_systab);
-
-	/* fill in the SAL system table: */
-	memcpy(sal_systab->signature, "SST_", 4);
-	sal_systab->size =3D sizeof(*sal_systab);
-	sal_systab->sal_rev_minor =3D 1;
-	sal_systab->sal_rev_major =3D 0;
-	sal_systab->entry_count =3D 1;
-
-#ifdef CONFIG_IA64_GENERIC
-        strcpy(sal_systab->oem_id, "Generic");
-        strcpy(sal_systab->product_id, "IA-64 system");
-#endif
-
-#ifdef CONFIG_IA64_HP_SIM
-	strcpy(sal_systab->oem_id, "Hewlett-Packard");
-	strcpy(sal_systab->product_id, "HP-simulator");
-#endif
-
-	/* fill in an entry point: */
-	sal_ed->type =3D SAL_DESC_ENTRY_POINT;
-	sal_ed->pal_proc =3D __pa(pal_desc[0]);
-	sal_ed->sal_proc =3D __pa(sal_desc[0]);
-	sal_ed->gp =3D __pa(sal_desc[1]);
-
-	for (cp =3D (char *) sal_systab; cp < (char *) efi_memmap; ++cp)
-		checksum +=3D *cp;
-
-	sal_systab->checksum =3D -checksum;
-
-#if SIMPLE_MEMMAP
-	/* simulate free memory at physical address zero */
-	MAKE_MD(EFI_BOOT_SERVICES_DATA,		EFI_MEMORY_WB,    0*MB,    1*MB);
-	MAKE_MD(EFI_PAL_CODE,			EFI_MEMORY_WB,    1*MB,    2*MB);
-	MAKE_MD(EFI_CONVENTIONAL_MEMORY,	EFI_MEMORY_WB,    2*MB,  130*MB);
-	MAKE_MD(EFI_CONVENTIONAL_MEMORY,	EFI_MEMORY_WB, 4096*MB, 4128*MB);
-#else
-	MAKE_MD( 4,		   0x9, 0x0000000000000000, 0x0000000000001000);
-	MAKE_MD( 7,		   0x9, 0x0000000000001000, 0x000000000008a000);
-	MAKE_MD( 4,		   0x9, 0x000000000008a000, 0x00000000000a0000);
-	MAKE_MD( 5, 0x8000000000000009, 0x00000000000c0000, 0x0000000000100000);
-	MAKE_MD( 7,		   0x9, 0x0000000000100000, 0x0000000004400000);
-	MAKE_MD( 2,		   0x9, 0x0000000004400000, 0x0000000004be5000);
-	MAKE_MD( 7,		   0x9, 0x0000000004be5000, 0x000000007f77e000);
-	MAKE_MD( 6, 0x8000000000000009, 0x000000007f77e000, 0x000000007fb94000);
-	MAKE_MD( 6, 0x8000000000000009, 0x000000007fb94000, 0x000000007fb95000);
-	MAKE_MD( 6, 0x8000000000000009, 0x000000007fb95000, 0x000000007fc00000);
-	MAKE_MD(13, 0x8000000000000009, 0x000000007fc00000, 0x000000007fc3a000);
-	MAKE_MD( 7,		   0x9, 0x000000007fc3a000, 0x000000007fea0000);
-	MAKE_MD( 5, 0x8000000000000009, 0x000000007fea0000, 0x000000007fea8000);
-	MAKE_MD( 7,		   0x9, 0x000000007fea8000, 0x000000007feab000);
-	MAKE_MD( 5, 0x8000000000000009, 0x000000007feab000, 0x000000007ffff000);
-	MAKE_MD( 7,		   0x9, 0x00000000ff400000, 0x0000000104000000);
-#endif
-
-	bp->efi_systab =3D __pa(&fw_mem);
-	bp->efi_memmap =3D __pa(efi_memmap);
-	bp->efi_memmap_size =3D NUM_MEM_DESCS*sizeof(efi_memory_desc_t);
-	bp->efi_memdesc_size =3D sizeof(efi_memory_desc_t);
-	bp->efi_memdesc_version =3D 1;
-	bp->command_line =3D __pa(cmd_line);
-	bp->console_info.num_cols =3D 80;
-	bp->console_info.num_rows =3D 25;
-	bp->console_info.orig_x =3D 0;
-	bp->console_info.orig_y =3D 24;
-	bp->fpswa =3D 0;
-
-	return bp;
-}
diff --git a/arch/ia64/hp/sim/boot/ssc.h b/arch/ia64/hp/sim/boot/ssc.h
deleted file mode 100644
index 88752c7509e0..000000000000
--- a/arch/ia64/hp/sim/boot/ssc.h
+++ /dev/null
@@ -1,36 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 */
-/*
- * Copyright (C) 1998-2003 Hewlett-Packard Co
- *	David Mosberger-Tang <davidm@hpl.hp.com>
- *	Stephane Eranian <eranian@hpl.hp.com>
- */
-#ifndef ssc_h
-#define ssc_h
-
-/* Simulator system calls: */
-
-#define SSC_CONSOLE_INIT		20
-#define SSC_GETCHAR			21
-#define SSC_PUTCHAR			31
-#define SSC_OPEN			50
-#define SSC_CLOSE			51
-#define SSC_READ			52
-#define SSC_WRITE			53
-#define SSC_GET_COMPLETION		54
-#define SSC_WAIT_COMPLETION		55
-#define SSC_CONNECT_INTERRUPT		58
-#define SSC_GENERATE_INTERRUPT		59
-#define SSC_SET_PERIODIC_INTERRUPT	60
-#define SSC_GET_RTC			65
-#define SSC_EXIT			66
-#define SSC_LOAD_SYMBOLS		69
-#define SSC_GET_TOD			74
-
-#define SSC_GET_ARGS			75
-
-/*
- * Simulator system call.
- */
-extern long ssc (long arg0, long arg1, long arg2, long arg3, int nr);
-
-#endif /* ssc_h */
diff --git a/arch/ia64/hp/sim/hpsim.S b/arch/ia64/hp/sim/hpsim.S
deleted file mode 100644
index 44b4d53e1689..000000000000
--- a/arch/ia64/hp/sim/hpsim.S
+++ /dev/null
@@ -1,11 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 */
-#include <asm/asmmacro.h>
-
-/*
- * Simulator system call.
- */
-GLOBAL_ENTRY(ia64_ssc)
-	mov r15=3Dr36
-	break 0x80001
-	br.ret.sptk.many rp
-END(ia64_ssc)
diff --git a/arch/ia64/hp/sim/hpsim_console.c b/arch/ia64/hp/sim/hpsim_cons=
ole.c
deleted file mode 100644
index bffd9f67a8a1..000000000000
--- a/arch/ia64/hp/sim/hpsim_console.c
+++ /dev/null
@@ -1,77 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * Platform dependent support for HP simulator.
- *
- * Copyright (C) 1998, 1999, 2002 Hewlett-Packard Co
- *	David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 1999 Vijay Chander <vijay@engr.sgi.com>
- */
-
-#include <linux/init.h>
-#include <linux/kernel.h>
-#include <linux/param.h>
-#include <linux/string.h>
-#include <linux/types.h>
-#include <linux/tty.h>
-#include <linux/kdev_t.h>
-#include <linux/console.h>
-
-#include <asm/delay.h>
-#include <asm/irq.h>
-#include <asm/pal.h>
-#include <asm/machvec.h>
-#include <asm/pgtable.h>
-#include <asm/sal.h>
-#include <asm/hpsim.h>
-
-#include "hpsim_ssc.h"
-
-static int simcons_init (struct console *, char *);
-static void simcons_write (struct console *, const char *, unsigned);
-static struct tty_driver *simcons_console_device (struct console *, int *);
-
-static struct console hpsim_cons =3D {
-	.name =3D		"simcons",
-	.write =3D	simcons_write,
-	.device =3D	simcons_console_device,
-	.setup =3D	simcons_init,
-	.flags =3D	CON_PRINTBUFFER,
-	.index =3D	-1,
-};
-
-static int
-simcons_init (struct console *cons, char *options)
-{
-	return 0;
-}
-
-static void
-simcons_write (struct console *cons, const char *buf, unsigned count)
-{
-	unsigned long ch;
-
-	while (count-- > 0) {
-		ch =3D *buf++;
-		ia64_ssc(ch, 0, 0, 0, SSC_PUTCHAR);
-		if (ch =3D '\n')
-		  ia64_ssc('\r', 0, 0, 0, SSC_PUTCHAR);
-	}
-}
-
-static struct tty_driver *simcons_console_device (struct console *c, int *=
index)
-{
-	*index =3D c->index;
-	return hp_simserial_driver;
-}
-
-int simcons_register(void)
-{
-	if (!ia64_platform_is("hpsim"))
-		return 1;
-
-	if (hpsim_cons.flags & CON_ENABLED)
-		return 1;
-
-	register_console(&hpsim_cons);
-	return 0;
-}
diff --git a/arch/ia64/hp/sim/hpsim_irq.c b/arch/ia64/hp/sim/hpsim_irq.c
deleted file mode 100644
index 2f1cc59650ab..000000000000
--- a/arch/ia64/hp/sim/hpsim_irq.c
+++ /dev/null
@@ -1,76 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * Platform dependent support for HP simulator.
- *
- * Copyright (C) 1998-2001 Hewlett-Packard Co
- * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
- */
-
-#include <linux/init.h>
-#include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/irq.h>
-
-#include "hpsim_ssc.h"
-
-static unsigned int
-hpsim_irq_startup(struct irq_data *data)
-{
-	return 0;
-}
-
-static void
-hpsim_irq_noop(struct irq_data *data)
-{
-}
-
-static int
-hpsim_set_affinity_noop(struct irq_data *d, const struct cpumask *b, bool =
f)
-{
-	return 0;
-}
-
-static struct irq_chip irq_type_hp_sim =3D {
-	.name =3D			"hpsim",
-	.irq_startup =3D		hpsim_irq_startup,
-	.irq_shutdown =3D		hpsim_irq_noop,
-	.irq_enable =3D		hpsim_irq_noop,
-	.irq_disable =3D		hpsim_irq_noop,
-	.irq_ack =3D		hpsim_irq_noop,
-	.irq_set_affinity =3D	hpsim_set_affinity_noop,
-};
-
-static void hpsim_irq_set_chip(int irq)
-{
-	struct irq_chip *chip =3D irq_get_chip(irq);
-
-	if (chip =3D &no_irq_chip)
-		irq_set_chip(irq, &irq_type_hp_sim);
-}
-
-static void hpsim_connect_irq(int intr, int irq)
-{
-	ia64_ssc(intr, irq, 0, 0, SSC_CONNECT_INTERRUPT);
-}
-
-int hpsim_get_irq(int intr)
-{
-	int irq =3D assign_irq_vector(AUTO_ASSIGN);
-
-	if (irq >=3D 0) {
-		hpsim_irq_set_chip(irq);
-		irq_set_handler(irq, handle_simple_irq);
-		hpsim_connect_irq(intr, irq);
-	}
-
-	return irq;
-}
-
-void __init
-hpsim_irq_init (void)
-{
-	int i;
-
-	for_each_active_irq(i)
-		hpsim_irq_set_chip(i);
-}
diff --git a/arch/ia64/hp/sim/hpsim_machvec.c b/arch/ia64/hp/sim/hpsim_mach=
vec.c
deleted file mode 100644
index c21419359185..000000000000
--- a/arch/ia64/hp/sim/hpsim_machvec.c
+++ /dev/null
@@ -1,3 +0,0 @@
-#define MACHVEC_PLATFORM_NAME		hpsim
-#define MACHVEC_PLATFORM_HEADER		<asm/machvec_hpsim.h>
-#include <asm/machvec_init.h>
diff --git a/arch/ia64/hp/sim/hpsim_setup.c b/arch/ia64/hp/sim/hpsim_setup.c
deleted file mode 100644
index 41d21d51dc4d..000000000000
--- a/arch/ia64/hp/sim/hpsim_setup.c
+++ /dev/null
@@ -1,41 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * Platform dependent support for HP simulator.
- *
- * Copyright (C) 1998, 1999, 2002 Hewlett-Packard Co
- *	David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 1999 Vijay Chander <vijay@engr.sgi.com>
- */
-#include <linux/console.h>
-#include <linux/init.h>
-#include <linux/kdev_t.h>
-#include <linux/kernel.h>
-#include <linux/major.h>
-#include <linux/param.h>
-#include <linux/root_dev.h>
-#include <linux/string.h>
-#include <linux/types.h>
-
-#include <asm/delay.h>
-#include <asm/irq.h>
-#include <asm/pal.h>
-#include <asm/machvec.h>
-#include <asm/pgtable.h>
-#include <asm/sal.h>
-#include <asm/hpsim.h>
-
-#include "hpsim_ssc.h"
-
-void
-ia64_ctl_trace (long on)
-{
-	ia64_ssc(on, 0, 0, 0, SSC_CTL_TRACE);
-}
-
-void __init
-hpsim_setup (char **cmdline_p)
-{
-	ROOT_DEV =3D Root_SDA1;		/* default to first SCSI drive */
-
-	simcons_register();
-}
diff --git a/arch/ia64/hp/sim/hpsim_ssc.h b/arch/ia64/hp/sim/hpsim_ssc.h
deleted file mode 100644
index 6fd97a487811..000000000000
--- a/arch/ia64/hp/sim/hpsim_ssc.h
+++ /dev/null
@@ -1,37 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 */
-/*
- * Platform dependent support for HP simulator.
- *
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 1999 Vijay Chander <vijay@engr.sgi.com>
- */
-#ifndef _IA64_PLATFORM_HPSIM_SSC_H
-#define _IA64_PLATFORM_HPSIM_SSC_H
-
-/* Simulator system calls: */
-
-#define SSC_CONSOLE_INIT		20
-#define SSC_GETCHAR			21
-#define SSC_PUTCHAR			31
-#define SSC_CONNECT_INTERRUPT		58
-#define SSC_GENERATE_INTERRUPT		59
-#define SSC_SET_PERIODIC_INTERRUPT	60
-#define SSC_GET_RTC			65
-#define SSC_EXIT			66
-#define SSC_LOAD_SYMBOLS		69
-#define SSC_GET_TOD			74
-#define SSC_CTL_TRACE			76
-
-#define SSC_NETDEV_PROBE		100
-#define SSC_NETDEV_SEND			101
-#define SSC_NETDEV_RECV			102
-#define SSC_NETDEV_ATTACH		103
-#define SSC_NETDEV_DETACH		104
-
-/*
- * Simulator system call.
- */
-extern long ia64_ssc (long arg0, long arg1, long arg2, long arg3, int nr);
-
-#endif /* _IA64_PLATFORM_HPSIM_SSC_H */
diff --git a/arch/ia64/hp/sim/simeth.c b/arch/ia64/hp/sim/simeth.c
deleted file mode 100644
index f39ef2b4ed72..000000000000
--- a/arch/ia64/hp/sim/simeth.c
+++ /dev/null
@@ -1,510 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * Simulated Ethernet Driver
- *
- * Copyright (C) 1999-2001, 2003 Hewlett-Packard Co
- *	Stephane Eranian <eranian@hpl.hp.com>
- */
-#include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/types.h>
-#include <linux/in.h>
-#include <linux/string.h>
-#include <linux/init.h>
-#include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/inetdevice.h>
-#include <linux/if_ether.h>
-#include <linux/if_arp.h>
-#include <linux/skbuff.h>
-#include <linux/notifier.h>
-#include <linux/bitops.h>
-#include <asm/irq.h>
-#include <asm/hpsim.h>
-
-#include "hpsim_ssc.h"
-
-#define SIMETH_RECV_MAX	10
-
-/*
- * Maximum possible received frame for Ethernet.
- * We preallocate an sk_buff of that size to avoid costly
- * memcpy for temporary buffer into sk_buff. We do basically
- * what's done in other drivers, like eepro with a ring.
- * The difference is, of course, that we don't have real DMA !!!
- */
-#define SIMETH_FRAME_SIZE	ETH_FRAME_LEN
-
-
-#define NETWORK_INTR			8
-
-struct simeth_local {
-	struct net_device_stats stats;
-	int 			simfd;	 /* descriptor in the simulator */
-};
-
-static int simeth_probe1(void);
-static int simeth_open(struct net_device *dev);
-static int simeth_close(struct net_device *dev);
-static int simeth_tx(struct sk_buff *skb, struct net_device *dev);
-static int simeth_rx(struct net_device *dev);
-static struct net_device_stats *simeth_get_stats(struct net_device *dev);
-static irqreturn_t simeth_interrupt(int irq, void *dev_id);
-static void set_multicast_list(struct net_device *dev);
-static int simeth_device_event(struct notifier_block *this,unsigned long e=
vent, void *ptr);
-
-static char *simeth_version=3D"0.3";
-
-/*
- * This variable is used to establish a mapping between the Linux/ia64 ker=
nel
- * and the host linux kernel.
- *
- * As of today, we support only one card, even though most of the code
- * is ready for many more. The mapping is then:
- *	linux/ia64 -> linux/x86
- * 	   eth0    -> eth1
- *
- * In the future, we some string operations, we could easily support up
- * to 10 cards (0-9).
- *
- * The default mapping can be changed on the kernel command line by
- * specifying simeth=3DethX (or whatever string you want).
- */
-static char *simeth_device=3D"eth0";	 /* default host interface to use */
-
-
-
-static volatile unsigned int card_count; /* how many cards "found" so far =
*/
-static int simeth_debug;		/* set to 1 to get debug information */
-
-/*
- * Used to catch IFF_UP & IFF_DOWN events
- */
-static struct notifier_block simeth_dev_notifier =3D {
-	simeth_device_event,
-	NULL
-};
-
-
-/*
- * Function used when using a kernel command line option.
- *
- * Format: simeth=3Dinterface_name (like eth0)
- */
-static int __init
-simeth_setup(char *str)
-{
-	simeth_device =3D str;
-	return 1;
-}
-
-__setup("simeth=3D", simeth_setup);
-
-/*
- * Function used to probe for simeth devices when not installed
- * as a loadable module
- */
-
-int __init
-simeth_probe (void)
-{
-	int r;
-
-	printk(KERN_INFO "simeth: v%s\n", simeth_version);
-
-	r =3D simeth_probe1();
-
-	if (r =3D 0) register_netdevice_notifier(&simeth_dev_notifier);
-
-	return r;
-}
-
-static inline int
-netdev_probe(char *name, unsigned char *ether)
-{
-	return ia64_ssc(__pa(name), __pa(ether), 0,0, SSC_NETDEV_PROBE);
-}
-
-
-static inline int
-netdev_attach(int fd, int irq, unsigned int ipaddr)
-{
-	/* this puts the host interface in the right mode (start interrupting) */
-	return ia64_ssc(fd, ipaddr, 0,0, SSC_NETDEV_ATTACH);
-}
-
-
-static inline int
-netdev_detach(int fd)
-{
-	/*
-	 * inactivate the host interface (don't interrupt anymore) */
-	return ia64_ssc(fd, 0,0,0, SSC_NETDEV_DETACH);
-}
-
-static inline int
-netdev_send(int fd, unsigned char *buf, unsigned int len)
-{
-	return ia64_ssc(fd, __pa(buf), len, 0, SSC_NETDEV_SEND);
-}
-
-static inline int
-netdev_read(int fd, unsigned char *buf, unsigned int len)
-{
-	return ia64_ssc(fd, __pa(buf), len, 0, SSC_NETDEV_RECV);
-}
-
-static const struct net_device_ops simeth_netdev_ops =3D {
-	.ndo_open		=3D simeth_open,
-	.ndo_stop		=3D simeth_close,
-	.ndo_start_xmit		=3D simeth_tx,
-	.ndo_get_stats		=3D simeth_get_stats,
-	.ndo_set_rx_mode	=3D set_multicast_list, /* not yet used */
-
-};
-
-/*
- * Function shared with module code, so cannot be in init section
- *
- * So far this function "detects" only one card (test_&_set) but could
- * be extended easily.
- *
- * Return:
- * 	- -ENODEV is no device found
- *	- -ENOMEM is no more memory
- *	- 0 otherwise
- */
-static int
-simeth_probe1(void)
-{
-	unsigned char mac_addr[ETH_ALEN];
-	struct simeth_local *local;
-	struct net_device *dev;
-	int fd, err, rc;
-
-	/*
-	 * XXX Fix me
-	 * let's support just one card for now
-	 */
-	if (test_and_set_bit(0, &card_count))
-		return -ENODEV;
-
-	/*
-	 * check with the simulator for the device
-	 */
-	fd =3D netdev_probe(simeth_device, mac_addr);
-	if (fd =3D -1)
-		return -ENODEV;
-
-	dev =3D alloc_etherdev(sizeof(struct simeth_local));
-	if (!dev)
-		return -ENOMEM;
-
-	memcpy(dev->dev_addr, mac_addr, sizeof(mac_addr));
-
-	local =3D netdev_priv(dev);
-	local->simfd =3D fd; /* keep track of underlying file descriptor */
-
-	dev->netdev_ops =3D &simeth_netdev_ops;
-
-	err =3D register_netdev(dev);
-	if (err) {
-		free_netdev(dev);
-		return err;
-	}
-
-	/*
-	 * attach the interrupt in the simulator, this does enable interrupts
-	 * until a netdev_attach() is called
-	 */
-	if ((rc =3D hpsim_get_irq(NETWORK_INTR)) < 0)
-		panic("%s: out of interrupt vectors!\n", __func__);
-	dev->irq =3D rc;
-
-	printk(KERN_INFO "%s: hosteth=3D%s simfd=3D%d, HwAddr=3D%pm, IRQ %d\n",
-	       dev->name, simeth_device, local->simfd, dev->dev_addr, dev->irq);
-
-	return 0;
-}
-
-/*
- * actually binds the device to an interrupt vector
- */
-static int
-simeth_open(struct net_device *dev)
-{
-	if (request_irq(dev->irq, simeth_interrupt, 0, "simeth", dev)) {
-		printk(KERN_WARNING "simeth: unable to get IRQ %d.\n", dev->irq);
-		return -EAGAIN;
-	}
-
-	netif_start_queue(dev);
-
-	return 0;
-}
-
-/* copied from lapbether.c */
-static __inline__ int dev_is_ethdev(struct net_device *dev)
-{
-       return ( dev->type =3D ARPHRD_ETHER && strncmp(dev->name, "dummy", =
5));
-}
-
-
-/*
- * Handler for IFF_UP or IFF_DOWN
- *
- * The reason for that is that we don't want to be interrupted when the
- * interface is down. There is no way to unconnect in the simualtor. Inste=
ad
- * we use this function to shutdown packet processing in the frame filter
- * in the simulator. Thus no interrupts are generated
- *
- *
- * That's also the place where we pass the IP address of this device to the
- * simulator so that that we can start filtering packets for it
- *
- * There may be a better way of doing this, but I don't know which yet.
- */
-static int
-simeth_device_event(struct notifier_block *this,unsigned long event, void =
*ptr)
-{
-	struct net_device *dev =3D netdev_notifier_info_to_dev(ptr);
-	struct simeth_local *local;
-	struct in_device *in_dev;
-	struct in_ifaddr **ifap =3D NULL;
-	struct in_ifaddr *ifa =3D NULL;
-	int r;
-
-
-	if ( ! dev ) {
-		printk(KERN_WARNING "simeth_device_event dev=3D0\n");
-		return NOTIFY_DONE;
-	}
-
-	if (dev_net(dev) !=3D &init_net)
-		return NOTIFY_DONE;
-
-	if ( event !=3D NETDEV_UP && event !=3D NETDEV_DOWN ) return NOTIFY_DONE;
-
-	/*
-	 * Check whether or not it's for an ethernet device
-	 *
-	 * XXX Fixme: This works only as long as we support one
-	 * type of ethernet device.
-	 */
-	if ( !dev_is_ethdev(dev) ) return NOTIFY_DONE;
-
-	if ((in_dev=DEv->ip_ptr) !=3D NULL) {
-		for (ifap=3D&in_dev->ifa_list; (ifa=3D*ifap) !=3D NULL; ifap=3D&ifa->ifa=
_next)
-			if (strcmp(dev->name, ifa->ifa_label) =3D 0) break;
-	}
-	if ( ifa =3D NULL ) {
-		printk(KERN_ERR "simeth_open: can't find device %s's ifa\n", dev->name);
-		return NOTIFY_DONE;
-	}
-
-	printk(KERN_INFO "simeth_device_event: %s ipaddr=3D0x%x\n",
-	       dev->name, ntohl(ifa->ifa_local));
-
-	/*
-	 * XXX Fix me
-	 * if the device was up, and we're simply reconfiguring it, not sure
-	 * we get DOWN then UP.
-	 */
-
-	local =3D netdev_priv(dev);
-	/* now do it for real */
-	r =3D event =3D NETDEV_UP ?
-		netdev_attach(local->simfd, dev->irq, ntohl(ifa->ifa_local)):
-		netdev_detach(local->simfd);
-
-	printk(KERN_INFO "simeth: netdev_attach/detach: event=3D%s ->%d\n",
-	       event =3D NETDEV_UP ? "attach":"detach", r);
-
-	return NOTIFY_DONE;
-}
-
-static int
-simeth_close(struct net_device *dev)
-{
-	netif_stop_queue(dev);
-
-	free_irq(dev->irq, dev);
-
-	return 0;
-}
-
-/*
- * Only used for debug
- */
-static void
-frame_print(unsigned char *from, unsigned char *frame, int len)
-{
-	int i;
-
-	printk("%s: (%d) %02x", from, len, frame[0] & 0xff);
-	for(i=3D1; i < 6; i++ ) {
-		printk(":%02x", frame[i] &0xff);
-	}
-	printk(" %2x", frame[6] &0xff);
-	for(i=3D7; i < 12; i++ ) {
-		printk(":%02x", frame[i] &0xff);
-	}
-	printk(" [%02x%02x]\n", frame[12], frame[13]);
-
-	for(i=14; i < len; i++ ) {
-		printk("%02x ", frame[i] &0xff);
-		if ( (i%10)=3D0) printk("\n");
-	}
-	printk("\n");
-}
-
-
-/*
- * Function used to transmit of frame, very last one on the path before
- * going to the simulator.
- */
-static int
-simeth_tx(struct sk_buff *skb, struct net_device *dev)
-{
-	struct simeth_local *local =3D netdev_priv(dev);
-
-#if 0
-	/* ensure we have at least ETH_ZLEN bytes (min frame size) */
-	unsigned int length =3D ETH_ZLEN < skb->len ? skb->len : ETH_ZLEN;
-	/* Where do the extra padding bytes comes from inthe skbuff ? */
-#else
-	/* the real driver in the host system is going to take care of that
-	 * or maybe it's the NIC itself.
-	 */
-	unsigned int length =3D skb->len;
-#endif
-
-	local->stats.tx_bytes +=3D skb->len;
-	local->stats.tx_packets++;
-
-
-	if (simeth_debug > 5) frame_print("simeth_tx", skb->data, length);
-
-	netdev_send(local->simfd, skb->data, length);
-
-	/*
-	 * we are synchronous on write, so we don't simulate a
-	 * trasnmit complete interrupt, thus we don't need to arm a tx
-	 */
-
-	dev_kfree_skb(skb);
-	return NETDEV_TX_OK;
-}
-
-static inline struct sk_buff *
-make_new_skb(struct net_device *dev)
-{
-	struct sk_buff *nskb;
-
-	/*
-	 * The +2 is used to make sure that the IP header is nicely
-	 * aligned (on 4byte boundary I assume 14+2=16)
-	 */
-	nskb =3D dev_alloc_skb(SIMETH_FRAME_SIZE + 2);
-	if ( nskb =3D NULL ) {
-		printk(KERN_NOTICE "%s: memory squeeze. dropping packet.\n", dev->name);
-		return NULL;
-	}
-
-	skb_reserve(nskb, 2);	/* Align IP on 16 byte boundaries */
-
-	skb_put(nskb,SIMETH_FRAME_SIZE);
-
-	return nskb;
-}
-
-/*
- * called from interrupt handler to process a received frame
- */
-static int
-simeth_rx(struct net_device *dev)
-{
-	struct simeth_local	*local;
-	struct sk_buff		*skb;
-	int			len;
-	int			rcv_count =3D SIMETH_RECV_MAX;
-
-	local =3D netdev_priv(dev);
-	/*
-	 * the loop concept has been borrowed from other drivers
-	 * looks to me like it's a throttling thing to avoid pushing to many
-	 * packets at one time into the stack. Making sure we can process them
-	 * upstream and make forward progress overall
-	 */
-	do {
-		if ( (skb=3Dmake_new_skb(dev)) =3D NULL ) {
-			printk(KERN_NOTICE "%s: memory squeeze. dropping packet.\n", dev->name);
-			local->stats.rx_dropped++;
-			return 0;
-		}
-		/*
-		 * Read only one frame at a time
-		 */
-		len =3D netdev_read(local->simfd, skb->data, SIMETH_FRAME_SIZE);
-		if ( len =3D 0 ) {
-			if ( simeth_debug > 0 ) printk(KERN_WARNING "%s: count=3D%d netdev_read=
=3D0\n",
-						       dev->name, SIMETH_RECV_MAX-rcv_count);
-			break;
-		}
-#if 0
-		/*
-		 * XXX Fix me
-		 * Should really do a csum+copy here
-		 */
-		skb_copy_to_linear_data(skb, frame, len);
-#endif
-		skb->protocol =3D eth_type_trans(skb, dev);
-
-		if ( simeth_debug > 6 ) frame_print("simeth_rx", skb->data, len);
-
-		/*
-		 * push the packet up & trigger software interrupt
-		 */
-		netif_rx(skb);
-
-		local->stats.rx_packets++;
-		local->stats.rx_bytes +=3D len;
-
-	} while ( --rcv_count );
-
-	return len; /* 0 =3D nothing left to read, otherwise, we can try again */
-}
-
-/*
- * Interrupt handler (Yes, we can do it too !!!)
- */
-static irqreturn_t
-simeth_interrupt(int irq, void *dev_id)
-{
-	struct net_device *dev =3D dev_id;
-
-	/*
-	 * very simple loop because we get interrupts only when receiving
-	 */
-	while (simeth_rx(dev));
-	return IRQ_HANDLED;
-}
-
-static struct net_device_stats *
-simeth_get_stats(struct net_device *dev)
-{
-	struct simeth_local *local =3D netdev_priv(dev);
-
-	return &local->stats;
-}
-
-/* fake multicast ability */
-static void
-set_multicast_list(struct net_device *dev)
-{
-	printk(KERN_WARNING "%s: set_multicast_list called\n", dev->name);
-}
-
-__initcall(simeth_probe);
diff --git a/arch/ia64/hp/sim/simscsi.c b/arch/ia64/hp/sim/simscsi.c
deleted file mode 100644
index 0a8a74271173..000000000000
--- a/arch/ia64/hp/sim/simscsi.c
+++ /dev/null
@@ -1,373 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * Simulated SCSI driver.
- *
- * Copyright (C) 1999, 2001-2003 Hewlett-Packard Co
- *	David Mosberger-Tang <davidm@hpl.hp.com>
- *	Stephane Eranian <eranian@hpl.hp.com>
- *
- * 02/01/15 David Mosberger	Updated for v2.5.1
- * 99/12/18 David Mosberger	Added support for READ10/WRITE10 needed by lin=
ux v2.3.33
- */
-#include <linux/blkdev.h>
-#include <linux/init.h>
-#include <linux/interrupt.h>
-#include <linux/kernel.h>
-#include <linux/timer.h>
-#include <asm/irq.h>
-#include "hpsim_ssc.h"
-
-#include <scsi/scsi.h>
-#include <scsi/scsi_cmnd.h>
-#include <scsi/scsi_device.h>
-#include <scsi/scsi_host.h>
-
-#define DEBUG_SIMSCSI	0
-
-#define SIMSCSI_REQ_QUEUE_LEN	64
-#define DEFAULT_SIMSCSI_ROOT	"/var/ski-disks/sd"
-
-/* Simulator system calls: */
-
-#define SSC_OPEN			50
-#define SSC_CLOSE			51
-#define SSC_READ			52
-#define SSC_WRITE			53
-#define SSC_GET_COMPLETION		54
-#define SSC_WAIT_COMPLETION		55
-
-#define SSC_WRITE_ACCESS		2
-#define SSC_READ_ACCESS			1
-
-#if DEBUG_SIMSCSI
-  int simscsi_debug;
-# define DBG	simscsi_debug
-#else
-# define DBG	0
-#endif
-
-static struct Scsi_Host *host;
-
-static void simscsi_interrupt (unsigned long val);
-static DECLARE_TASKLET(simscsi_tasklet, simscsi_interrupt, 0);
-
-struct disk_req {
-	unsigned long addr;
-	unsigned len;
-};
-
-struct disk_stat {
-	int fd;
-	unsigned count;
-};
-
-static int desc[16] =3D {
-	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
-};
-
-static struct queue_entry {
-	struct scsi_cmnd *sc;
-} queue[SIMSCSI_REQ_QUEUE_LEN];
-
-static int rd, wr;
-static atomic_t num_reqs =3D ATOMIC_INIT(0);
-
-/* base name for default disks */
-static char *simscsi_root =3D DEFAULT_SIMSCSI_ROOT;
-
-#define MAX_ROOT_LEN	128
-
-/*
- * used to setup a new base for disk images
- * to use /foo/bar/disk[a-z] as disk images
- * you have to specify simscsi=3D/foo/bar/disk on the command line
- */
-static int __init
-simscsi_setup (char *s)
-{
-	/* XXX Fix me we may need to strcpy() ? */
-	if (strlen(s) > MAX_ROOT_LEN) {
-		printk(KERN_ERR "simscsi_setup: prefix too long---using default %s\n",
-		       simscsi_root);
-	} else
-		simscsi_root =3D s;
-	return 1;
-}
-
-__setup("simscsi=3D", simscsi_setup);
-
-static void
-simscsi_interrupt (unsigned long val)
-{
-	struct scsi_cmnd *sc;
-
-	while ((sc =3D queue[rd].sc) !=3D NULL) {
-		atomic_dec(&num_reqs);
-		queue[rd].sc =3D NULL;
-		if (DBG)
-			printk("simscsi_interrupt: done with %u\n",
-			       sc->request->tag);
-		(*sc->scsi_done)(sc);
-		rd =3D (rd + 1) % SIMSCSI_REQ_QUEUE_LEN;
-	}
-}
-
-static int
-simscsi_biosparam (struct scsi_device *sdev, struct block_device *n,
-		sector_t capacity, int ip[])
-{
-	ip[0] =3D 64;		/* heads */
-	ip[1] =3D 32;		/* sectors */
-	ip[2] =3D capacity >> 11;	/* cylinders */
-	return 0;
-}
-
-static void
-simscsi_sg_readwrite (struct scsi_cmnd *sc, int mode, unsigned long offset)
-{
-	int i;
-	struct scatterlist *sl;
-	struct disk_stat stat;
-	struct disk_req req;
-
-	stat.fd =3D desc[sc->device->id];
-
-	scsi_for_each_sg(sc, sl, scsi_sg_count(sc), i) {
-		req.addr =3D __pa(sg_virt(sl));
-		req.len  =3D sl->length;
-		if (DBG)
-			printk("simscsi_sg_%s @ %lx (off %lx) use_sg=3D%d len=3D%d\n",
-			       mode =3D SSC_READ ? "read":"write", req.addr, offset,
-			       scsi_sg_count(sc) - i, sl->length);
-		ia64_ssc(stat.fd, 1, __pa(&req), offset, mode);
-		ia64_ssc(__pa(&stat), 0, 0, 0, SSC_WAIT_COMPLETION);
-
-		/* should not happen in our case */
-		if (stat.count !=3D req.len) {
-			sc->result =3D DID_ERROR << 16;
-			return;
-		}
-		offset +=3D  sl->length;
-	}
-	sc->result =3D GOOD;
-}
-
-/*
- * function handling both READ_6/WRITE_6 (non-scatter/gather mode)
- * commands.
- * Added 02/26/99 S.Eranian
- */
-static void
-simscsi_readwrite6 (struct scsi_cmnd *sc, int mode)
-{
-	unsigned long offset;
-
-	offset =3D (((sc->cmnd[1] & 0x1f) << 16) | (sc->cmnd[2] << 8) | sc->cmnd[=
3])*512;
-	simscsi_sg_readwrite(sc, mode, offset);
-}
-
-static size_t
-simscsi_get_disk_size (int fd)
-{
-	struct disk_stat stat;
-	size_t bit, sectors =3D 0;
-	struct disk_req req;
-	char buf[512];
-
-	/*
-	 * This is a bit kludgey: the simulator doesn't provide a
-	 * direct way of determining the disk size, so we do a binary
-	 * search, assuming a maximum disk size of 128GB.
-	 */
-	for (bit =3D (128UL << 30)/512; bit !=3D 0; bit >>=3D 1) {
-		req.addr =3D __pa(&buf);
-		req.len =3D sizeof(buf);
-		ia64_ssc(fd, 1, __pa(&req), ((sectors | bit) - 1)*512, SSC_READ);
-		stat.fd =3D fd;
-		ia64_ssc(__pa(&stat), 0, 0, 0, SSC_WAIT_COMPLETION);
-		if (stat.count =3D sizeof(buf))
-			sectors |=3D bit;
-	}
-	return sectors - 1;	/* return last valid sector number */
-}
-
-static void
-simscsi_readwrite10 (struct scsi_cmnd *sc, int mode)
-{
-	unsigned long offset;
-
-	offset =3D (((unsigned long)sc->cmnd[2] << 24)=20
-		| ((unsigned long)sc->cmnd[3] << 16)
-		| ((unsigned long)sc->cmnd[4] <<  8)=20
-		| ((unsigned long)sc->cmnd[5] <<  0))*512UL;
-	simscsi_sg_readwrite(sc, mode, offset);
-}
-
-static int
-simscsi_queuecommand_lck (struct scsi_cmnd *sc, void (*done)(struct scsi_c=
mnd *))
-{
-	unsigned int target_id =3D sc->device->id;
-	char fname[MAX_ROOT_LEN+16];
-	size_t disk_size;
-	char *buf;
-	char localbuf[36];
-#if DEBUG_SIMSCSI
-	register long sp asm ("sp");
-
-	if (DBG)
-		printk("simscsi_queuecommand: target=3D%d,cmnd=3D%u,sc=3D%u,sp=3D%lx,don=
e=3D%p\n",
-		       target_id, sc->cmnd[0], sc->request->tag, sp, done);
-#endif
-
-	sc->result =3D DID_BAD_TARGET << 16;
-	sc->scsi_done =3D done;
-	if (target_id <=3D 15 && sc->device->lun =3D 0) {
-		switch (sc->cmnd[0]) {
-		      case INQUIRY:
-			if (scsi_bufflen(sc) < 35) {
-				break;
-			}
-			sprintf (fname, "%s%c", simscsi_root, 'a' + target_id);
-			desc[target_id] =3D ia64_ssc(__pa(fname), SSC_READ_ACCESS|SSC_WRITE_ACC=
ESS,
-						   0, 0, SSC_OPEN);
-			if (desc[target_id] < 0) {
-				/* disk doesn't exist... */
-				break;
-			}
-			buf =3D localbuf;
-			buf[0] =3D 0;	/* magnetic disk */
-			buf[1] =3D 0;	/* not a removable medium */
-			buf[2] =3D 2;	/* SCSI-2 compliant device */
-			buf[3] =3D 2;	/* SCSI-2 response data format */
-			buf[4] =3D 31;	/* additional length (bytes) */
-			buf[5] =3D 0;	/* reserved */
-			buf[6] =3D 0;	/* reserved */
-			buf[7] =3D 0;	/* various flags */
-			memcpy(buf + 8, "HP      SIMULATED DISK  0.00",  28);
-			scsi_sg_copy_from_buffer(sc, buf, 36);
-			sc->result =3D GOOD;
-			break;
-
-		      case TEST_UNIT_READY:
-			sc->result =3D GOOD;
-			break;
-
-		      case READ_6:
-			if (desc[target_id] < 0 )
-				break;
-			simscsi_readwrite6(sc, SSC_READ);
-			break;
-
-		      case READ_10:
-			if (desc[target_id] < 0 )
-				break;
-			simscsi_readwrite10(sc, SSC_READ);
-			break;
-
-		      case WRITE_6:
-			if (desc[target_id] < 0)
-				break;
-			simscsi_readwrite6(sc, SSC_WRITE);
-			break;
-
-		      case WRITE_10:
-			if (desc[target_id] < 0)
-				break;
-			simscsi_readwrite10(sc, SSC_WRITE);
-			break;
-
-		      case READ_CAPACITY:
-			if (desc[target_id] < 0 || scsi_bufflen(sc) < 8) {
-				break;
-			}
-			buf =3D localbuf;
-			disk_size =3D simscsi_get_disk_size(desc[target_id]);
-
-			buf[0] =3D (disk_size >> 24) & 0xff;
-			buf[1] =3D (disk_size >> 16) & 0xff;
-			buf[2] =3D (disk_size >>  8) & 0xff;
-			buf[3] =3D (disk_size >>  0) & 0xff;
-			/* set block size of 512 bytes: */
-			buf[4] =3D 0;
-			buf[5] =3D 0;
-			buf[6] =3D 2;
-			buf[7] =3D 0;
-			scsi_sg_copy_from_buffer(sc, buf, 8);
-			sc->result =3D GOOD;
-			break;
-
-		      case MODE_SENSE:
-		      case MODE_SENSE_10:
-			/* sd.c uses this to determine whether disk does write-caching. */
-			scsi_sg_copy_from_buffer(sc, (char *)empty_zero_page,
-						 PAGE_SIZE);
-			sc->result =3D GOOD;
-			break;
-
-		      case START_STOP:
-			printk(KERN_ERR "START_STOP\n");
-			break;
-
-		      default:
-			panic("simscsi: unknown SCSI command %u\n", sc->cmnd[0]);
-		}
-	}
-	if (sc->result =3D DID_BAD_TARGET) {
-		sc->result |=3D DRIVER_SENSE << 24;
-		sc->sense_buffer[0] =3D 0x70;
-		sc->sense_buffer[2] =3D 0x00;
-	}
-	if (atomic_read(&num_reqs) >=3D SIMSCSI_REQ_QUEUE_LEN) {
-		panic("Attempt to queue command while command is pending!!");
-	}
-	atomic_inc(&num_reqs);
-	queue[wr].sc =3D sc;
-	wr =3D (wr + 1) % SIMSCSI_REQ_QUEUE_LEN;
-
-	tasklet_schedule(&simscsi_tasklet);
-	return 0;
-}
-
-static DEF_SCSI_QCMD(simscsi_queuecommand)
-
-static int
-simscsi_host_reset (struct scsi_cmnd *sc)
-{
-	printk(KERN_ERR "simscsi_host_reset: not implemented\n");
-	return 0;
-}
-
-static struct scsi_host_template driver_template =3D {
-	.name			=3D "simulated SCSI host adapter",
-	.proc_name		=3D "simscsi",
-	.queuecommand		=3D simscsi_queuecommand,
-	.eh_host_reset_handler	=3D simscsi_host_reset,
-	.bios_param		=3D simscsi_biosparam,
-	.can_queue		=3D SIMSCSI_REQ_QUEUE_LEN,
-	.this_id		=3D -1,
-	.sg_tablesize		=3D SG_ALL,
-	.max_sectors		=3D 1024,
-	.cmd_per_lun		=3D SIMSCSI_REQ_QUEUE_LEN,
-	.dma_boundary		=3D PAGE_SIZE - 1,
-};
-
-static int __init
-simscsi_init(void)
-{
-	int error;
-
-	host =3D scsi_host_alloc(&driver_template, 0);
-	if (!host)
-		return -ENOMEM;
-
-	error =3D scsi_add_host(host, NULL);
-	if (error)
-		goto free_host;
-	scsi_scan_host(host);
-	return 0;
-
- free_host:
-	scsi_host_put(host);
-	return error;
-}
-device_initcall(simscsi_init);
diff --git a/arch/ia64/hp/sim/simserial.c b/arch/ia64/hp/sim/simserial.c
deleted file mode 100644
index 1a338e541334..000000000000
--- a/arch/ia64/hp/sim/simserial.c
+++ /dev/null
@@ -1,521 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * Simulated Serial Driver (fake serial)
- *
- * This driver is mostly used for bringup purposes and will go away.
- * It has a strong dependency on the system console. All outputs
- * are rerouted to the same facility as the one used by printk which, in o=
ur
- * case means sys_sim.c console (goes via the simulator).
- *
- * Copyright (C) 1999-2000, 2002-2003 Hewlett-Packard Co
- *	Stephane Eranian <eranian@hpl.hp.com>
- *	David Mosberger-Tang <davidm@hpl.hp.com>
- */
-
-#include <linux/init.h>
-#include <linux/errno.h>
-#include <linux/sched.h>
-#include <linux/sched/debug.h>
-#include <linux/tty.h>
-#include <linux/tty_flip.h>
-#include <linux/major.h>
-#include <linux/fcntl.h>
-#include <linux/mm.h>
-#include <linux/seq_file.h>
-#include <linux/slab.h>
-#include <linux/capability.h>
-#include <linux/circ_buf.h>
-#include <linux/console.h>
-#include <linux/irq.h>
-#include <linux/module.h>
-#include <linux/serial.h>
-#include <linux/sysrq.h>
-#include <linux/uaccess.h>
-
-#include <asm/hpsim.h>
-
-#include "hpsim_ssc.h"
-
-#undef SIMSERIAL_DEBUG	/* define this to get some debug information */
-
-#define KEYBOARD_INTR	3	/* must match with simulator! */
-
-#define NR_PORTS	1	/* only one port for now */
-
-struct serial_state {
-	struct tty_port port;
-	struct circ_buf xmit;
-	int irq;
-	int x_char;
-};
-
-static struct serial_state rs_table[NR_PORTS];
-
-struct tty_driver *hp_simserial_driver;
-
-static struct console *console;
-
-static void receive_chars(struct tty_port *port)
-{
-	unsigned char ch;
-	static unsigned char seen_esc =3D 0;
-
-	while ( (ch =3D ia64_ssc(0, 0, 0, 0, SSC_GETCHAR)) ) {
-		if (ch =3D 27 && seen_esc =3D 0) {
-			seen_esc =3D 1;
-			continue;
-		} else if (seen_esc =3D 1 && ch =3D 'O') {
-			seen_esc =3D 2;
-			continue;
-		} else if (seen_esc =3D 2) {
-			if (ch =3D 'P') /* F1 */
-				show_state();
-#ifdef CONFIG_MAGIC_SYSRQ
-			if (ch =3D 'S') { /* F4 */
-				do {
-					ch =3D ia64_ssc(0, 0, 0, 0, SSC_GETCHAR);
-				} while (!ch);
-				handle_sysrq(ch);
-			}
-#endif
-			seen_esc =3D 0;
-			continue;
-		}
-		seen_esc =3D 0;
-
-		if (tty_insert_flip_char(port, ch, TTY_NORMAL) =3D 0)
-			break;
-	}
-	tty_flip_buffer_push(port);
-}
-
-/*
- * This is the serial driver's interrupt routine for a single port
- */
-static irqreturn_t rs_interrupt_single(int irq, void *dev_id)
-{
-	struct serial_state *info =3D dev_id;
-
-	receive_chars(&info->port);
-
-	return IRQ_HANDLED;
-}
-
-/*
- * -------------------------------------------------------------------
- * Here ends the serial interrupt routines.
- * -------------------------------------------------------------------
- */
-
-static int rs_put_char(struct tty_struct *tty, unsigned char ch)
-{
-	struct serial_state *info =3D tty->driver_data;
-	unsigned long flags;
-
-	if (!info->xmit.buf)
-		return 0;
-
-	local_irq_save(flags);
-	if (CIRC_SPACE(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE) =3D 0)=
 {
-		local_irq_restore(flags);
-		return 0;
-	}
-	info->xmit.buf[info->xmit.head] =3D ch;
-	info->xmit.head =3D (info->xmit.head + 1) & (SERIAL_XMIT_SIZE-1);
-	local_irq_restore(flags);
-	return 1;
-}
-
-static void transmit_chars(struct tty_struct *tty, struct serial_state *in=
fo,
-		int *intr_done)
-{
-	int count;
-	unsigned long flags;
-
-	local_irq_save(flags);
-
-	if (info->x_char) {
-		char c =3D info->x_char;
-
-		console->write(console, &c, 1);
-
-		info->x_char =3D 0;
-
-		goto out;
-	}
-
-	if (info->xmit.head =3D info->xmit.tail || tty->stopped) {
-#ifdef SIMSERIAL_DEBUG
-		printk("transmit_chars: head=3D%d, tail=3D%d, stopped=3D%d\n",
-		       info->xmit.head, info->xmit.tail, tty->stopped);
-#endif
-		goto out;
-	}
-	/*
-	 * We removed the loop and try to do it in to chunks. We need
-	 * 2 operations maximum because it's a ring buffer.
-	 *
-	 * First from current to tail if possible.
-	 * Then from the beginning of the buffer until necessary
-	 */
-
-	count =3D min(CIRC_CNT(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE=
),
-		    SERIAL_XMIT_SIZE - info->xmit.tail);
-	console->write(console, info->xmit.buf+info->xmit.tail, count);
-
-	info->xmit.tail =3D (info->xmit.tail+count) & (SERIAL_XMIT_SIZE-1);
-
-	/*
-	 * We have more at the beginning of the buffer
-	 */
-	count =3D CIRC_CNT(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE);
-	if (count) {
-		console->write(console, info->xmit.buf, count);
-		info->xmit.tail +=3D count;
-	}
-out:
-	local_irq_restore(flags);
-}
-
-static void rs_flush_chars(struct tty_struct *tty)
-{
-	struct serial_state *info =3D tty->driver_data;
-
-	if (info->xmit.head =3D info->xmit.tail || tty->stopped ||
-			!info->xmit.buf)
-		return;
-
-	transmit_chars(tty, info, NULL);
-}
-
-static int rs_write(struct tty_struct * tty,
-		    const unsigned char *buf, int count)
-{
-	struct serial_state *info =3D tty->driver_data;
-	int	c, ret =3D 0;
-	unsigned long flags;
-
-	if (!info->xmit.buf)
-		return 0;
-
-	local_irq_save(flags);
-	while (1) {
-		c =3D CIRC_SPACE_TO_END(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SI=
ZE);
-		if (count < c)
-			c =3D count;
-		if (c <=3D 0) {
-			break;
-		}
-		memcpy(info->xmit.buf + info->xmit.head, buf, c);
-		info->xmit.head =3D ((info->xmit.head + c) &
-				   (SERIAL_XMIT_SIZE-1));
-		buf +=3D c;
-		count -=3D c;
-		ret +=3D c;
-	}
-	local_irq_restore(flags);
-	/*
-	 * Hey, we transmit directly from here in our case
-	 */
-	if (CIRC_CNT(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE) &&
-			!tty->stopped)
-		transmit_chars(tty, info, NULL);
-
-	return ret;
-}
-
-static int rs_write_room(struct tty_struct *tty)
-{
-	struct serial_state *info =3D tty->driver_data;
-
-	return CIRC_SPACE(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE);
-}
-
-static int rs_chars_in_buffer(struct tty_struct *tty)
-{
-	struct serial_state *info =3D tty->driver_data;
-
-	return CIRC_CNT(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE);
-}
-
-static void rs_flush_buffer(struct tty_struct *tty)
-{
-	struct serial_state *info =3D tty->driver_data;
-	unsigned long flags;
-
-	local_irq_save(flags);
-	info->xmit.head =3D info->xmit.tail =3D 0;
-	local_irq_restore(flags);
-
-	tty_wakeup(tty);
-}
-
-/*
- * This function is used to send a high-priority XON/XOFF character to
- * the device
- */
-static void rs_send_xchar(struct tty_struct *tty, char ch)
-{
-	struct serial_state *info =3D tty->driver_data;
-
-	info->x_char =3D ch;
-	if (ch) {
-		/*
-		 * I guess we could call console->write() directly but
-		 * let's do that for now.
-		 */
-		transmit_chars(tty, info, NULL);
-	}
-}
-
-/*
- * ------------------------------------------------------------
- * rs_throttle()
- *
- * This routine is called by the upper-layer tty layer to signal that
- * incoming characters should be throttled.
- * ------------------------------------------------------------
- */
-static void rs_throttle(struct tty_struct * tty)
-{
-	if (I_IXOFF(tty))
-		rs_send_xchar(tty, STOP_CHAR(tty));
-
-	printk(KERN_INFO "simrs_throttle called\n");
-}
-
-static void rs_unthrottle(struct tty_struct * tty)
-{
-	struct serial_state *info =3D tty->driver_data;
-
-	if (I_IXOFF(tty)) {
-		if (info->x_char)
-			info->x_char =3D 0;
-		else
-			rs_send_xchar(tty, START_CHAR(tty));
-	}
-	printk(KERN_INFO "simrs_unthrottle called\n");
-}
-
-static int rs_setserial(struct tty_struct *tty, struct serial_struct *ss)
-{
-	return 0;
-}
-
-static int rs_getserial(struct tty_struct *tty, struct serial_struct *ss)
-{
-	return 0;
-}
-
-static int rs_ioctl(struct tty_struct *tty, unsigned int cmd, unsigned lon=
g arg)
-{
-	if ((cmd !=3D TIOCSERCONFIG) && (cmd !=3D TIOCMIWAIT)) {
-		if (tty_io_error(tty))
-		    return -EIO;
-	}
-
-	switch (cmd) {
-	case TIOCMIWAIT:
-		return 0;
-	case TIOCSERCONFIG:
-	case TIOCSERGETLSR: /* Get line status register */
-		return -EINVAL;
-	}
-	return -ENOIOCTLCMD;
-}
-
-/*
- * This routine will shutdown a serial port; interrupts are disabled, and
- * DTR is dropped if the hangup on close termio flag is on.
- */
-static void shutdown(struct tty_port *port)
-{
-	struct serial_state *info =3D container_of(port, struct serial_state,
-			port);
-	unsigned long flags;
-
-	local_irq_save(flags);
-	if (info->irq)
-		free_irq(info->irq, info);
-
-	if (info->xmit.buf) {
-		free_page((unsigned long) info->xmit.buf);
-		info->xmit.buf =3D NULL;
-	}
-	local_irq_restore(flags);
-}
-
-static void rs_close(struct tty_struct *tty, struct file * filp)
-{
-	struct serial_state *info =3D tty->driver_data;
-
-	tty_port_close(&info->port, tty, filp);
-}
-
-static void rs_hangup(struct tty_struct *tty)
-{
-	struct serial_state *info =3D tty->driver_data;
-
-	rs_flush_buffer(tty);
-	tty_port_hangup(&info->port);
-}
-
-static int activate(struct tty_port *port, struct tty_struct *tty)
-{
-	struct serial_state *state =3D container_of(port, struct serial_state,
-			port);
-	unsigned long flags, page;
-	int retval =3D 0;
-
-	page =3D get_zeroed_page(GFP_KERNEL);
-	if (!page)
-		return -ENOMEM;
-
-	local_irq_save(flags);
-
-	if (state->xmit.buf)
-		free_page(page);
-	else
-		state->xmit.buf =3D (unsigned char *) page;
-
-	if (state->irq) {
-		retval =3D request_irq(state->irq, rs_interrupt_single, 0,
-				"simserial", state);
-		if (retval)
-			goto errout;
-	}
-
-	state->xmit.head =3D state->xmit.tail =3D 0;
-errout:
-	local_irq_restore(flags);
-	return retval;
-}
-
-
-/*
- * This routine is called whenever a serial port is opened.  It
- * enables interrupts for a serial port, linking in its async structure in=
to
- * the IRQ chain.   It also performs the serial-specific
- * initialization for the tty structure.
- */
-static int rs_open(struct tty_struct *tty, struct file * filp)
-{
-	struct serial_state *info =3D rs_table + tty->index;
-	struct tty_port *port =3D &info->port;
-
-	tty->driver_data =3D info;
-	port->low_latency =3D (port->flags & ASYNC_LOW_LATENCY) ? 1 : 0;
-
-	/*
-	 * figure out which console to use (should be one already)
-	 */
-	console =3D console_drivers;
-	while (console) {
-		if ((console->flags & CON_ENABLED) && console->write) break;
-		console =3D console->next;
-	}
-
-	return tty_port_open(port, tty, filp);
-}
-
-/*
- * /proc fs routines....
- */
-
-static int rs_proc_show(struct seq_file *m, void *v)
-{
-	int i;
-
-	seq_printf(m, "simserinfo:1.0\n");
-	for (i =3D 0; i < NR_PORTS; i++)
-		seq_printf(m, "%d: uart:16550 port:3F8 irq:%d\n",
-		       i, rs_table[i].irq);
-	return 0;
-}
-
-static const struct tty_operations hp_ops =3D {
-	.open =3D rs_open,
-	.close =3D rs_close,
-	.write =3D rs_write,
-	.put_char =3D rs_put_char,
-	.flush_chars =3D rs_flush_chars,
-	.write_room =3D rs_write_room,
-	.chars_in_buffer =3D rs_chars_in_buffer,
-	.flush_buffer =3D rs_flush_buffer,
-	.ioctl =3D rs_ioctl,
-	.throttle =3D rs_throttle,
-	.unthrottle =3D rs_unthrottle,
-	.send_xchar =3D rs_send_xchar,
-	.set_serial =3D rs_setserial,
-	.get_serial =3D rs_getserial,
-	.hangup =3D rs_hangup,
-	.proc_show =3D rs_proc_show,
-};
-
-static const struct tty_port_operations hp_port_ops =3D {
-	.activate =3D activate,
-	.shutdown =3D shutdown,
-};
-
-static int __init simrs_init(void)
-{
-	struct serial_state *state;
-	int retval;
-
-	if (!ia64_platform_is("hpsim"))
-		return -ENODEV;
-
-	hp_simserial_driver =3D alloc_tty_driver(NR_PORTS);
-	if (!hp_simserial_driver)
-		return -ENOMEM;
-
-	printk(KERN_INFO "SimSerial driver with no serial options enabled\n");
-
-	/* Initialize the tty_driver structure */
-
-	hp_simserial_driver->driver_name =3D "simserial";
-	hp_simserial_driver->name =3D "ttyS";
-	hp_simserial_driver->major =3D TTY_MAJOR;
-	hp_simserial_driver->minor_start =3D 64;
-	hp_simserial_driver->type =3D TTY_DRIVER_TYPE_SERIAL;
-	hp_simserial_driver->subtype =3D SERIAL_TYPE_NORMAL;
-	hp_simserial_driver->init_termios =3D tty_std_termios;
-	hp_simserial_driver->init_termios.c_cflag -		B9600 | CS8 | CREAD | HUPCL =
| CLOCAL;
-	hp_simserial_driver->flags =3D TTY_DRIVER_REAL_RAW;
-	tty_set_operations(hp_simserial_driver, &hp_ops);
-
-	state =3D rs_table;
-	tty_port_init(&state->port);
-	state->port.ops =3D &hp_port_ops;
-	state->port.close_delay =3D 0; /* XXX really 0? */
-
-	retval =3D hpsim_get_irq(KEYBOARD_INTR);
-	if (retval < 0) {
-		printk(KERN_ERR "%s: out of interrupt vectors!\n",
-				__func__);
-		goto err_free_tty;
-	}
-
-	state->irq =3D retval;
-
-	/* the port is imaginary */
-	printk(KERN_INFO "ttyS0 at 0x03f8 (irq =3D %d) is a 16550\n", state->irq);
-
-	tty_port_link_device(&state->port, hp_simserial_driver, 0);
-	retval =3D tty_register_driver(hp_simserial_driver);
-	if (retval) {
-		printk(KERN_ERR "Couldn't register simserial driver\n");
-		goto err_free_tty;
-	}
-
-	return 0;
-err_free_tty:
-	put_tty_driver(hp_simserial_driver);
-	tty_port_destroy(&state->port);
-	return retval;
-}
-
-#ifndef MODULE
-__initcall(simrs_init);
-#endif
diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
index 80c5ef8f475e..0afb3bc4b4a1 100644
--- a/arch/ia64/include/asm/acpi.h
+++ b/arch/ia64/include/asm/acpi.h
@@ -37,9 +37,7 @@ const char *acpi_get_sysname (void);
 #else
 static inline const char *acpi_get_sysname (void)
 {
-# if defined (CONFIG_IA64_HP_SIM)
-	return "hpsim";
-# elif defined (CONFIG_IA64_HP_ZX1)
+# if defined (CONFIG_IA64_HP_ZX1)
 	return "hpzx1";
 # elif defined (CONFIG_IA64_HP_ZX1_SWIOTLB)
 	return "hpzx1_swiotlb";
diff --git a/arch/ia64/include/asm/hpsim.h b/arch/ia64/include/asm/hpsim.h
deleted file mode 100644
index 00fbd5cc8ab8..000000000000
--- a/arch/ia64/include/asm/hpsim.h
+++ /dev/null
@@ -1,17 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 */
-#ifndef _ASMIA64_HPSIM_H
-#define _ASMIA64_HPSIM_H
-
-#ifndef CONFIG_HP_SIMSERIAL_CONSOLE
-static inline int simcons_register(void) { return 1; }
-#else
-int simcons_register(void);
-#endif
-
-struct tty_driver;
-extern struct tty_driver *hp_simserial_driver;
-
-extern int hpsim_get_irq(int intr);
-void ia64_ctl_trace(long on);
-
-#endif
diff --git a/arch/ia64/include/asm/iosapic.h b/arch/ia64/include/asm/iosapi=
c.h
index f48556cb8afc..a91aeb413e17 100644
--- a/arch/ia64/include/asm/iosapic.h
+++ b/arch/ia64/include/asm/iosapic.h
@@ -52,8 +52,6 @@
=20
 #ifndef __ASSEMBLY__
=20
-#ifdef CONFIG_IOSAPIC
-
 #define NR_IOSAPICS			256
=20
 #define iosapic_pcat_compat_init	ia64_native_iosapic_pcat_compat_init
@@ -103,16 +101,6 @@ extern int __init iosapic_register_platform_intr (u32 =
int_type,
 #ifdef CONFIG_NUMA
 extern void map_iosapic_to_node (unsigned int, int);
 #endif
-#else
-#define iosapic_system_init(pcat_compat)			do { } while (0)
-#define iosapic_init(address,gsi_base)				(-EINVAL)
-#define iosapic_remove(gsi_base)				(-ENODEV)
-#define iosapic_register_intr(gsi,polarity,trigger)		(gsi)
-#define iosapic_unregister_intr(irq)				do { } while (0)
-#define iosapic_override_isa_irq(isa_irq,gsi,polarity,trigger)	do { } whil=
e (0)
-#define iosapic_register_platform_intr(type,gsi,pmi,eid,id, \
-	polarity,trigger)					(gsi)
-#endif
=20
 # endif /* !__ASSEMBLY__ */
 #endif /* __ASM_IA64_IOSAPIC_H */
diff --git a/arch/ia64/include/asm/machvec.h b/arch/ia64/include/asm/machve=
c.h
index f426a9829595..5a9a8af79308 100644
--- a/arch/ia64/include/asm/machvec.h
+++ b/arch/ia64/include/asm/machvec.h
@@ -16,7 +16,6 @@
 struct device;
=20
 typedef void ia64_mv_setup_t (char **);
-typedef void ia64_mv_irq_init_t (void);
 typedef void ia64_mv_dma_init (void);
 typedef const struct dma_map_ops *ia64_mv_dma_get_ops(struct device *);
=20
@@ -27,9 +26,7 @@ machvec_noop (void)
=20
 extern void machvec_setup (char **);
=20
-# if defined (CONFIG_IA64_HP_SIM)
-#  include <asm/machvec_hpsim.h>
-# elif defined (CONFIG_IA64_DIG)
+# if defined (CONFIG_IA64_DIG)
 #  include <asm/machvec_dig.h>
 # elif defined(CONFIG_IA64_DIG_VTD)
 #  include <asm/machvec_dig_vtd.h>
@@ -46,7 +43,6 @@ extern void machvec_setup (char **);
 # else
 #  define ia64_platform_name	ia64_mv.name
 #  define platform_setup	ia64_mv.setup
-#  define platform_irq_init	ia64_mv.irq_init
 #  define platform_dma_init		ia64_mv.dma_init
 #  define platform_dma_get_ops		ia64_mv.dma_get_ops
 # endif
@@ -59,7 +55,6 @@ extern void machvec_setup (char **);
 struct ia64_machine_vector {
 	const char *name;
 	ia64_mv_setup_t *setup;
-	ia64_mv_irq_init_t *irq_init;
 	ia64_mv_dma_init *dma_init;
 	ia64_mv_dma_get_ops *dma_get_ops;
 } __attribute__((__aligned__(16))); /* align attrib? see above comment */
@@ -68,7 +63,6 @@ struct ia64_machine_vector {
 {						\
 	#name,					\
 	platform_setup,				\
-	platform_irq_init,			\
 	platform_dma_init,			\
 	platform_dma_get_ops,			\
 }
@@ -91,9 +85,6 @@ extern const struct dma_map_ops *dma_get_ops(struct devic=
e *);
 #ifndef platform_setup
 # define platform_setup			machvec_setup
 #endif
-#ifndef platform_irq_init
-# define platform_irq_init		machvec_noop
-#endif
 #ifndef platform_dma_init
 # define platform_dma_init		swiotlb_dma_init
 #endif
diff --git a/arch/ia64/include/asm/machvec_hpsim.h b/arch/ia64/include/asm/=
machvec_hpsim.h
deleted file mode 100644
index 056f8405822e..000000000000
--- a/arch/ia64/include/asm/machvec_hpsim.h
+++ /dev/null
@@ -1,19 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 */
-#ifndef _ASM_IA64_MACHVEC_HPSIM_h
-#define _ASM_IA64_MACHVEC_HPSIM_h
-
-extern ia64_mv_setup_t hpsim_setup;
-extern ia64_mv_irq_init_t hpsim_irq_init;
-
-/*
- * This stuff has dual use!
- *
- * For a generic kernel, the macros are used to initialize the
- * platform's machvec structure.  When compiling a non-generic kernel,
- * the macros are used directly.
- */
-#define ia64_platform_name	"hpsim"
-#define platform_setup		hpsim_setup
-#define platform_irq_init	hpsim_irq_init
-
-#endif /* _ASM_IA64_MACHVEC_HPSIM_h */
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 4ba05140b249..3ada440ff893 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -12,13 +12,12 @@ extra-y	:=3D head.o vmlinux.lds
 obj-y :=3D entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksyms.o irq.o =
irq_ia64.o	\
 	 irq_lsapic.o ivt.o machvec.o pal.o patch.o process.o perfmon.o ptrace.o =
sal.o		\
 	 salinfo.o setup.o signal.o sys_ia64.o time.o traps.o unaligned.o \
-	 unwind.o mca.o mca_asm.o topology.o dma-mapping.o
+	 unwind.o mca.o mca_asm.o topology.o dma-mapping.o iosapic.o
=20
 obj-$(CONFIG_ACPI)		+=3D acpi.o acpi-ext.o
 obj-$(CONFIG_IA64_BRL_EMU)	+=3D brl_emu.o
=20
 obj-$(CONFIG_IA64_PALINFO)	+=3D palinfo.o
-obj-$(CONFIG_IOSAPIC)		+=3D iosapic.o
 obj-$(CONFIG_MODULES)		+=3D module.o
 obj-$(CONFIG_SMP)		+=3D smp.o smpboot.o
 obj-$(CONFIG_NUMA)		+=3D numa.o
diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 1c81ec752b04..e3874734b149 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -53,7 +53,6 @@
 #define IRQ_USED		(1)
 #define IRQ_RSVD		(2)
=20
-/* These can be overridden in platform_irq_init */
 int ia64_first_device_vector =3D IA64_DEF_FIRST_DEVICE_VECTOR;
 int ia64_last_device_vector =3D IA64_DEF_LAST_DEVICE_VECTOR;
=20
@@ -648,7 +647,6 @@ init_IRQ (void)
 #ifdef CONFIG_PERFMON
 	pfm_init_percpu();
 #endif
-	platform_irq_init();
 }
=20
 void
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 4dc74500eac5..42ef03ce2fd4 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -63,7 +63,6 @@
 #include <asm/smp.h>
 #include <asm/tlbflush.h>
 #include <asm/unistd.h>
-#include <asm/hpsim.h>
=20
 #if defined(CONFIG_SMP) && (IA64_CPU_SIZE > PAGE_SIZE)
 # error "struct cpuinfo_ia64 too big!"
@@ -461,16 +460,11 @@ io_port_init (void)
 static inline int __init
 early_console_setup (char *cmdline)
 {
-	int earlycons =3D 0;
-
 #ifdef CONFIG_EFI_PCDP
 	if (!efi_setup_pcdp_console(cmdline))
-		earlycons++;
+		return 0;
 #endif
-	if (!simcons_register())
-		earlycons++;
-
-	return (earlycons) ? 0 : -1;
+	return -1;
 }
=20
 static inline void
@@ -608,9 +602,6 @@ setup_arch (char **cmdline_p)
 		ia64_mca_init();
=20
 	platform_setup(cmdline_p);
-#ifndef CONFIG_IA64_HP_SIM
-	check_sal_cache_flush();
-#endif
 	paging_init();
=20
 	clear_sched_clock_stable();
--=20
2.20.1
