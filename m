From: Keith Owens <kaos@sgi.com>
Date: Wed, 18 Jan 2006 04:38:14 +0000
Subject: [patch 2.6.16-rc1] Recursive flags do not work for selective builds
Message-Id: <8734.1137559094@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

arch/ia64/sn/Makefile sets CPPFLAGS, expecting that setting to
propogate to all the subdirectories.  For a normal build with its
recursive descent it does work, but doing a selective build like
'make arch/ia64/sn/kernel/io_init.i' does not do a recursive descent,
it goes directly to arch/ia64/sn/kernel/Makefile so the flags do not
get set.

To support selective builds, set the flags in all the subordinate Makefiles.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

This only fixes the sn Makefiles, other subtrees may have the same
problem.

 Makefile            |    2 --
 kernel/Makefile     |    2 ++
 kernel/sn2/Makefile |    2 ++
 pci/Makefile        |    2 ++
 pci/pcibr/Makefile  |    2 ++
 5 files changed, 8 insertions(+), 2 deletions(-)

Index: linux/arch/ia64/sn/Makefile
=================================--- linux.orig/arch/ia64/sn/Makefile	2006-01-03 14:21:10.000000000 +1100
+++ linux/arch/ia64/sn/Makefile	2006-01-18 15:21:08.348599626 +1100
@@ -9,6 +9,4 @@
 # Makefile for the sn ia64 subplatform
 #
 
-CPPFLAGS += -I$(srctree)/arch/ia64/sn/include
-
 obj-y += kernel/ pci/
Index: linux/arch/ia64/sn/kernel/Makefile
=================================--- linux.orig/arch/ia64/sn/kernel/Makefile	2006-01-03 14:21:10.000000000 +1100
+++ linux/arch/ia64/sn/kernel/Makefile	2006-01-18 15:21:29.739207327 +1100
@@ -7,6 +7,8 @@
 # Copyright (C) 1999,2001-2005 Silicon Graphics, Inc.  All Rights Reserved.
 #
 
+CPPFLAGS += -I$(srctree)/arch/ia64/sn/include
+
 obj-y				+= setup.o bte.o bte_error.o irq.o mca.o idle.o \
 				   huberror.o io_init.o iomv.o klconflib.o sn2/
 obj-$(CONFIG_IA64_GENERIC)      += machvec.o
Index: linux/arch/ia64/sn/kernel/sn2/Makefile
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/Makefile	2006-01-03 14:21:10.000000000 +1100
+++ linux/arch/ia64/sn/kernel/sn2/Makefile	2006-01-18 15:21:35.709087973 +1100
@@ -9,5 +9,7 @@
 # sn2 specific kernel files
 #
 
+CPPFLAGS += -I$(srctree)/arch/ia64/sn/include
+
 obj-y += cache.o io.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o \
 	 prominfo_proc.o timer.o timer_interrupt.o sn_hwperf.o
Index: linux/arch/ia64/sn/pci/Makefile
=================================--- linux.orig/arch/ia64/sn/pci/Makefile	2006-01-03 14:21:10.000000000 +1100
+++ linux/arch/ia64/sn/pci/Makefile	2006-01-18 15:21:41.877183495 +1100
@@ -7,4 +7,6 @@
 #
 # Makefile for the sn pci general routines.
 
+CPPFLAGS += -I$(srctree)/arch/ia64/sn/include
+
 obj-y := pci_dma.o tioca_provider.o tioce_provider.o pcibr/
Index: linux/arch/ia64/sn/pci/pcibr/Makefile
=================================--- linux.orig/arch/ia64/sn/pci/pcibr/Makefile	2006-01-03 14:21:10.000000000 +1100
+++ linux/arch/ia64/sn/pci/pcibr/Makefile	2006-01-18 15:21:46.363870041 +1100
@@ -7,5 +7,7 @@
 #
 # Makefile for the sn2 io routines.
 
+CPPFLAGS += -I$(srctree)/arch/ia64/sn/include
+
 obj-y				+=  pcibr_dma.o pcibr_reg.o \
 				    pcibr_ate.o pcibr_provider.o

