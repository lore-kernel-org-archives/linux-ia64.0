From: Sam Ravnborg <sam@ravnborg.org>
Date: Sat, 07 Dec 2002 22:01:45 +0000
Subject: Re: [Linux-ia64] ia64 arch makefile update
Message-Id: <marc-linux-ia64-105590709805515@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805512@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805512@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Second try ready.
Other architectures does not practice this, but I added a rule to
copy vmlinux.gz + bootloader to root of kernel-tree.

bootloader is build when needed, therefore the boot: target has not been
re-introduced.

Complete summary of changes:
o Copy vmlinux-gz + bootloader to root of kernel-tree
o Fix "make clean"
o Delete vmlinux.gz + bootloader during make clean
> o Simplified arch/ia64/Makefile
>   - During this process the boot: target were removed
> o Moved final generation of vmlinux.gz to boot/Makefile
>   - This allowed me to use some of the kbuild infrastructure
>   - Final file "vmlinux.gz" is now saved in arch/ia64/boot in line with
>     other architectures.
> o s/$(ARCH)/ia64 - since we know that this is the architecture we use
> o Small clean up all over, e.g. removed inclusion of Rules.make
>   Also made some nicer indenting, but no functional changes.

I had to modify a few files to build the kernel, but they did not
have anything to do with the Makefiles.

Any feedback appreciated,
	Sam

 Makefile             |   77 ++++++++++++++++++++++------------------------=
----  boot/Makefile        |   33 ++++++++++++++-------
 dig/Makefile         |    2 -
 hp/common/Makefile   |    2 -
 hp/sim/Makefile      |    2 -
 hp/zx1/Makefile      |    2 -
 ia32/Makefile        |    6 +--
 kernel/Makefile      |    9 +++--
 mm/Makefile          |   12 +------
 pci/Makefile         |    5 +--
 sn/fakeprom/Makefile |    4 --
 11 files changed, 69 insertions(+), 85 deletions(-)

=3D=3D=3D arch/ia64/Makefile 1.27 vs edited =3D=3D--- 1.27/arch/ia64/Makefi=
le	Fri Oct 25 06:35:08 2002
+++ edited/arch/ia64/Makefile	Sat Dec  7 23:00:32 2002
@@ -9,16 +9,15 @@
 #
=20
 NM :=3D $(CROSS_COMPILE)nm -B
-AWK :=3D awk
=20
 export AWK
=20
-OBJCOPYFLAGS :=3D --strip-all
-LDFLAGS_vmlinux :=3D -static
-AFLAGS_KERNEL :=3D -mconstant-gp
-EXTRA	+OBJCOPYFLAGS	:=3D --strip-all
+LDFLAGS_vmlinux	:=3D -static
+AFLAGS_KERNEL	:=3D -mconstant-gp
+EXTRA		:=20
-CFLAGS :=3D $(CFLAGS) -pipe $(EXTRA) -ffixed-r13 -mfixed-range=F10-f15,f32=
-f127 \
+cflags-y :=3D -pipe $(EXTRA) -ffixed-r13 -mfixed-range=F10-f15,f32-f127 \
 	  -falign-functions2
 # -ffunction-sections
 CFLAGS_KERNEL :=3D -mconstant-gp
@@ -29,52 +28,43 @@
 	CFLAGS +=3D -frename-registers --param max-inline-insnsP00
 endif
=20
-ifeq ($(CONFIG_ITANIUM_BSTEP_SPECIFIC),y)
-	CFLAGS +=3D -mb-step
-endif
-
-HEAD :=3D arch/$(ARCH)/kernel/head.o arch/$(ARCH)/kernel/init_task.o
+cflags-$(CONFIG_ITANIUM_BSTEP_SPECIFIC)	+=3D -mb-step
+cflags-$(CONFIG_IA64_SGI_SN)		+=3D -DBRINGUP
=20
-libs-y				+=3D arch/$(ARCH)/lib/
-core-y				+=3D arch/$(ARCH)/kernel/ arch/$(ARCH)/mm/
-core-$(CONFIG_IA32_SUPPORT)	+=3D arch/$(ARCH)/ia32/
-core-$(CONFIG_IA64_DIG) 	+=3D arch/$(ARCH)/dig/
-core-$(CONFIG_IA64_GENERIC) 	+=3D arch/$(ARCH)/dig/ arch/$(ARCH)/hp/common=
/ arch/$(ARCH)/hp/zx1/ \
-				   arch/$(ARCH)/hp/sim/
-core-$(CONFIG_IA64_HP_ZX1)	+=3D arch/$(ARCH)/dig/
-core-$(CONFIG_IA64_SGI_SN)	+=3D arch/$(ARCH)/sn/kernel arch/$(ARCH)/sn/io \
-				   arch/$(ARCH)/sn/fakeprom
-drivers-$(CONFIG_PCI)		+=3D arch/$(ARCH)/pci/
-drivers-$(CONFIG_IA64_HP_SIM)	+=3D arch/$(ARCH)/hp/sim/
-drivers-$(CONFIG_IA64_HP_ZX1)	+=3D arch/$(ARCH)/hp/common/ arch/$(ARCH)/hp=
/zx1/
-
-ifdef CONFIG_IA64_SGI_SN
-	CFLAGS			+=3D -DBRINGUP
-        SUBDIRS         	+=3D arch/$(ARCH)/sn/fakeprom
-endif
+HEAD :=3D arch/ia64/kernel/head.o arch/ia64/kernel/init_task.o
=20
-makeboot =3D $(call descend,arch/ia64/boot,$(1))
-maketool =3D $(call descend,arch/ia64/tools,$(1))
+libs-y				+=3D arch/ia64/lib/
+core-y				+=3D arch/ia64/kernel/ arch/ia64/mm/
+core-$(CONFIG_IA32_SUPPORT)	+=3D arch/ia64/ia32/
+core-$(CONFIG_IA64_DIG) 	+=3D arch/ia64/dig/
+core-$(CONFIG_IA64_GENERIC) 	+=3D arch/ia64/dig/ arch/ia64/hp/common/
+core-$(CONFIG_IA64_GENERIC)	+=3D arch/ia64/hp/zx1/ arch/ia64/hp/sim/
+core-$(CONFIG_IA64_HP_ZX1)	+=3D arch/ia64/dig/
+core-$(CONFIG_IA64_SGI_SN)	+=3D arch/ia64/sn/kernel/ arch/ia64/sn/io/ \
+				   arch/ia64/sn/fakeprom/
+drivers-$(CONFIG_PCI)		+=3D arch/ia64/pci/
+drivers-$(CONFIG_IA64_HP_SIM)	+=3D arch/ia64/hp/sim/
+drivers-$(CONFIG_IA64_HP_ZX1)	+=3D arch/ia64/hp/common/ arch/ia64/hp/zx1/
+
+makeboot =3D$(Q)$(MAKE) -f scripts/Makefile.build obj=3Darch/ia64/boot $(1)
+maketool =3D$(Q)$(MAKE) -f scripts/Makefile.build obj=3Darch/ia64/tools $(=
1)
=20
-.PHONY: compressed archclean archmrproper $(TOPDIR)/include/asm-ia64/offse=
ts.h
+.PHONY: compressed archclean archmrproper include/asm-ia64/offsets.h
=20
-all: compressed boot
+all compressed: vmlinux.gz
=20
-boot: vmlinux
-	+@$(call makeboot,all)
+vmlinux.gz: vmlinux
+	$(call makeboot,vmlinux.gz)
=20
-compressed: vmlinux
-	$(OBJCOPY) $(OBJCOPYFLAGS) vmlinux vmlinux-tmp
-	gzip vmlinux-tmp
-	mv vmlinux-tmp.gz vmlinux.gz
=20
+archmrproper:
 archclean:
-	$(MAKE) -rR -f scripts/Makefile.clean obj=3Darch/$(ARCH)/boot
+	$(Q)$(MAKE) -f scripts/Makefile.clean obj=3Darch/ia64/boot
=20
-archmrproper:
+CLEAN_FILES +=3D include/asm-ia64/offsets.h vmlinux.gz bootloader
=20
-prepare: $(TOPDIR)/include/asm-ia64/offsets.h
+prepare: include/asm-ia64/offsets.h
=20
-$(TOPDIR)/include/asm-ia64/offsets.h: include/asm include/linux/version.h \
-				      include/config/MARKER
-	+@$(call maketool,$@)
+include/asm-ia64/offsets.h: include/asm include/linux/version.h \
+			    include/config/MARKER
+	$(call maketool,$@)
=3D=3D=3D arch/ia64/boot/Makefile 1.6 vs edited =3D=3D--- 1.6/arch/ia64/boo=
t/Makefile	Mon Oct 28 03:20:05 2002
+++ edited/arch/ia64/boot/Makefile	Sat Dec  7 22:49:21 2002
@@ -8,20 +8,31 @@
 # Copyright (C) 1998 by David Mosberger-Tang <davidm@hpl.hp.com>
 #
=20
-LINKFLAGS =3D -static -T $(src)/bootloader.lds
+EXTRA_TARGETS :=3D vmlinux.bin vmlinux.gz
=20
-OBJS	=3D $(obj)/bootloader.o
+targets-$(CONFIG_IA64_HP_SIM)  +=3D bootloader
+targets-$(CONFIG_IA64_GENERIC) +=3D bootloader
+EXTRA_TARGETS +=3D $(sort $(targets-y))
=20
-targets-$(CONFIG_IA64_HP_SIM)	+=3D bootloader
-targets-$(CONFIG_IA64_GENERIC)	+=3D bootloader
+quiet_cmd_cptotop =3D CP      $@
+      cmd_cptotop =3D cp $< $@
=20
-CFLAGS	:=3D $(CFLAGS) $(CFLAGS_KERNEL)
+vmlinux.gz: $(obj)/vmlinux.gz $(targets-y)
+	$(call cmd,cptotop)
+	@echo '  Kernel: $@ is ready'
=20
-all:	$(targets-y)
+bootloader: $(obj)/bootloader
+	$(call cmd,cptotop)
=20
-bootloader: $(OBJS)
-	$(LD) $(LINKFLAGS) $(OBJS) $(TOPDIR)/lib/lib.a $(TOPDIR)/arch/$(ARCH)/lib=
/lib.a \
-	-o bootloader
+$(obj)/vmlinux.gz: $(obj)/vmlinux.bin FORCE
+	$(call if_changed,gzip)
=20
-clean:
-	rm -f $(TARGETS)
+$(obj)/vmlinux.bin: vmlinux FORCE
+	$(call if_changed,objcopy)
+
+
+LDFLAGS_bootloader =3D -static -T
+
+$(obj)/bootloader: $(src)/bootloader.lds $(obj)/bootloader.o \
+                   lib/lib.a arch/ia64/lib/lib.a FORCE
+	$(call if_changed,ld)
=3D=3D=3D arch/ia64/dig/Makefile 1.5 vs edited =3D=3D--- 1.5/arch/ia64/dig/=
Makefile	Mon Sep 23 01:34:27 2002
+++ edited/arch/ia64/dig/Makefile	Fri Dec  6 22:16:01 2002
@@ -7,5 +7,3 @@
=20
 obj-y :=3D setup.o
 obj-$(CONFIG_IA64_GENERIC) +=3D machvec.o
-
-include $(TOPDIR)/Rules.make
=3D=3D=3D arch/ia64/hp/common/Makefile 1.4 vs edited =3D=3D--- 1.4/arch/ia6=
4/hp/common/Makefile	Sat Sep 21 10:25:52 2002
+++ edited/arch/ia64/hp/common/Makefile	Fri Dec  6 22:16:02 2002
@@ -8,5 +8,3 @@
 export-objs :=3D sba_iommu.o
=20
 obj-y :=3D sba_iommu.o
-
-include $(TOPDIR)/Rules.make
=3D=3D=3D arch/ia64/hp/sim/Makefile 1.4 vs edited =3D=3D--- 1.4/arch/ia64/h=
p/sim/Makefile	Mon Sep 23 01:34:28 2002
+++ edited/arch/ia64/hp/sim/Makefile	Fri Dec  6 22:16:03 2002
@@ -13,5 +13,3 @@
 obj-$(CONFIG_HP_SIMETH)	+=3D simeth.o
 obj-$(CONFIG_HP_SIMSERIAL) +=3D simserial.o
 obj-$(CONFIG_HP_SIMSCSI) +=3D simscsi.o
-
-include $(TOPDIR)/Rules.make
=3D=3D=3D arch/ia64/hp/zx1/Makefile 1.4 vs edited =3D=3D--- 1.4/arch/ia64/h=
p/zx1/Makefile	Sat Sep 21 10:25:52 2002
+++ edited/arch/ia64/hp/zx1/Makefile	Fri Dec  6 22:16:04 2002
@@ -7,5 +7,3 @@
=20
 obj-y :=3D hpzx1_misc.o
 obj-$(CONFIG_IA64_GENERIC) +=3D hpzx1_machvec.o
-
-include $(TOPDIR)/Rules.make
=3D=3D=3D arch/ia64/ia32/Makefile 1.7 vs edited =3D=3D--- 1.7/arch/ia64/ia3=
2/Makefile	Mon Sep 23 01:34:28 2002
+++ edited/arch/ia64/ia32/Makefile	Fri Dec  6 22:16:04 2002
@@ -2,7 +2,5 @@
 # Makefile for the ia32 kernel emulation subsystem.
 #
=20
-obj-y :=3D ia32_entry.o sys_ia32.o ia32_ioctl.o ia32_signal.o ia32_support=
.o ia32_traps.o \
-	 binfmt_elf32.o ia32_ldt.o
-
-include $(TOPDIR)/Rules.make
+obj-y :=3D ia32_entry.o sys_ia32.o ia32_ioctl.o ia32_signal.o \
+	 ia32_support.o ia32_traps.o binfmt_elf32.o ia32_ldt.o
=3D=3D=3D arch/ia64/kernel/Makefile 1.10 vs edited =3D=3D--- 1.10/arch/ia64=
/kernel/Makefile	Sat Sep 21 10:25:52 2002
+++ edited/arch/ia64/kernel/Makefile	Fri Dec  6 22:16:05 2002
@@ -6,14 +6,15 @@
=20
 export-objs :=3D ia64_ksyms.o
=20
-obj-y :=3D acpi.o entry.o gate.o efi.o efi_stub.o ia64_ksyms.o irq.o irq_i=
a64.o irq_lsapic.o ivt.o \
-	 machvec.o pal.o process.o perfmon.o ptrace.o sal.o semaphore.o setup.o	\
+obj-y :=3D acpi.o entry.o gate.o efi.o efi_stub.o ia64_ksyms.o \
+	 irq.o irq_ia64.o irq_lsapic.o ivt.o \
+	 machvec.o pal.o process.o perfmon.o ptrace.o sal.o \
+	 semaphore.o setup.o	\
 	 signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o
+
 obj-$(CONFIG_IOSAPIC) +=3D iosapic.o
 obj-$(CONFIG_IA64_PALINFO) +=3D palinfo.o
 obj-$(CONFIG_EFI_VARS) +=3D efivars.o
 obj-$(CONFIG_SMP) +=3D smp.o smpboot.o
 obj-$(CONFIG_IA64_MCA) +=3D mca.o mca_asm.o
 obj-$(CONFIG_IA64_BRL_EMU) +=3D brl_emu.o
-
-include $(TOPDIR)/Rules.make
=3D=3D=3D arch/ia64/mm/Makefile 1.5 vs edited =3D=3D--- 1.5/arch/ia64/mm/Ma=
kefile	Tue Oct 22 15:48:03 2002
+++ edited/arch/ia64/mm/Makefile	Fri Dec  6 22:16:05 2002
@@ -1,15 +1,9 @@
 #
 # Makefile for the ia64-specific parts of the memory manager.
 #
-# Note! Dependencies are done automagically by 'make dep', which also
-# removes any old dependencies. DON'T put your own dependencies here
-# unless it's something special (ie not a .c file).
-#
-# Note 2! The CFLAGS definition is now in the main makefile...
=20
-obj-y	 :=3D init.o fault.o tlb.o extable.o
+obj-y :=3D init.o fault.o tlb.o extable.o
+
 obj-$(CONFIG_HUGETLB_PAGE) +=3D hugetlbpage.o
-obj-$(CONFIG_NUMA) +=3D numa.o
+obj-$(CONFIG_NUMA)	   +=3D numa.o
 obj-$(CONFIG_DISCONTIGMEM) +=3D discontig.o
-
-include $(TOPDIR)/Rules.make
=3D=3D=3D arch/ia64/pci/Makefile 1.1 vs edited =3D=3D--- 1.1/arch/ia64/pci/=
Makefile	Sat Sep 21 10:25:52 2002
+++ edited/arch/ia64/pci/Makefile	Fri Dec  6 22:16:06 2002
@@ -1,3 +1,4 @@
+#
+# Makefile for the ia64-specific parts of the pci bus
+#
 obj-y		:=3D pci.o
-
-include $(TOPDIR)/Rules.make
=3D=3D=3D arch/ia64/sn/fakeprom/Makefile 1.8 vs edited =3D=3D--- 1.8/arch/i=
a64/sn/fakeprom/Makefile	Sat Aug 17 04:50:17 2002
+++ edited/arch/ia64/sn/fakeprom/Makefile	Sat Dec  7 22:55:14 2002
@@ -18,7 +18,3 @@
=20
 clean:
 	rm -f *.o fprom
-
-
-include $(TOPDIR)/Rules.make
-

