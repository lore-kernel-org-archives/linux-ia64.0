From: matt mooney <mfm@muteddisk.com>
Date: Thu, 23 Sep 2010 06:50:29 +0000
Subject: [PATCH 06/20] ia64: change to new flag variables
Message-Id: <1285224629-29640-1-git-send-email-mfm@muteddisk.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Xiantao Zhang <xiantao.zhang@intel.com>
Cc: Tony Luck <tony.luck@intel.com>, Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

Replace EXTRA_CFLAGS with ccflags-y and EXTRA_AFLAGS with asflags-y.

Signed-off-by: matt mooney <mfm@muteddisk.com>
---
 arch/ia64/kvm/Makefile           |    4 ++--
 arch/ia64/sn/kernel/Makefile     |    2 +-
 arch/ia64/sn/kernel/sn2/Makefile |    2 +-
 arch/ia64/sn/pci/Makefile        |    2 +-
 arch/ia64/sn/pci/pcibr/Makefile  |    2 +-
 arch/ia64/uv/kernel/Makefile     |    2 +-
 6 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/kvm/Makefile b/arch/ia64/kvm/Makefile
index 1089b3e..db3d7c5 100644
--- a/arch/ia64/kvm/Makefile
+++ b/arch/ia64/kvm/Makefile
@@ -45,8 +45,8 @@ FORCE : $(obj)/$(offsets-file)
 # Makefile for Kernel-based Virtual Machine module
 #
 
-EXTRA_CFLAGS += -Ivirt/kvm -Iarch/ia64/kvm/
-EXTRA_AFLAGS += -Ivirt/kvm -Iarch/ia64/kvm/
+ccflags-y := -Ivirt/kvm -Iarch/ia64/kvm/
+asflags-y := -Ivirt/kvm -Iarch/ia64/kvm/
 
 common-objs = $(addprefix ../../../virt/kvm/, kvm_main.o ioapic.o \
 		coalesced_mmio.o irq_comm.o assigned-dev.o)
diff --git a/arch/ia64/sn/kernel/Makefile b/arch/ia64/sn/kernel/Makefile
index 0591038..d27df1d 100644
--- a/arch/ia64/sn/kernel/Makefile
+++ b/arch/ia64/sn/kernel/Makefile
@@ -7,7 +7,7 @@
 # Copyright (C) 1999,2001-2006,2008 Silicon Graphics, Inc.  All Rights Reserved.
 #
 
-EXTRA_CFLAGS += -Iarch/ia64/sn/include
+ccflags-y := -Iarch/ia64/sn/include
 
 obj-y				+= setup.o bte.o bte_error.o irq.o mca.o idle.o \
 				   huberror.o io_acpi_init.o io_common.o \
diff --git a/arch/ia64/sn/kernel/sn2/Makefile b/arch/ia64/sn/kernel/sn2/Makefile
index 08e6565..3d09108 100644
--- a/arch/ia64/sn/kernel/sn2/Makefile
+++ b/arch/ia64/sn/kernel/sn2/Makefile
@@ -9,7 +9,7 @@
 # sn2 specific kernel files
 #
 
-EXTRA_CFLAGS += -Iarch/ia64/sn/include
+ccflags-y := -Iarch/ia64/sn/include
 
 obj-y += cache.o io.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o \
 	 prominfo_proc.o timer.o timer_interrupt.o sn_hwperf.o
diff --git a/arch/ia64/sn/pci/Makefile b/arch/ia64/sn/pci/Makefile
index ad4ef34..df2a901 100644
--- a/arch/ia64/sn/pci/Makefile
+++ b/arch/ia64/sn/pci/Makefile
@@ -7,6 +7,6 @@
 #
 # Makefile for the sn pci general routines.
 
-EXTRA_CFLAGS += -Iarch/ia64/sn/include
+ccflags-y := -Iarch/ia64/sn/include
 
 obj-y := pci_dma.o tioca_provider.o tioce_provider.o pcibr/
diff --git a/arch/ia64/sn/pci/pcibr/Makefile b/arch/ia64/sn/pci/pcibr/Makefile
index 01192d3..396bcae 100644
--- a/arch/ia64/sn/pci/pcibr/Makefile
+++ b/arch/ia64/sn/pci/pcibr/Makefile
@@ -7,7 +7,7 @@
 #
 # Makefile for the sn2 io routines.
 
-EXTRA_CFLAGS += -Iarch/ia64/sn/include
+ccflags-y := -Iarch/ia64/sn/include
 
 obj-y				+=  pcibr_dma.o pcibr_reg.o \
 				    pcibr_ate.o pcibr_provider.o
diff --git a/arch/ia64/uv/kernel/Makefile b/arch/ia64/uv/kernel/Makefile
index 8d92b46..124e441 100644
--- a/arch/ia64/uv/kernel/Makefile
+++ b/arch/ia64/uv/kernel/Makefile
@@ -7,7 +7,7 @@
 # Copyright (C) 2008 Silicon Graphics, Inc.  All Rights Reserved.
 #
 
-EXTRA_CFLAGS += -Iarch/ia64/sn/include
+ccflags-y := -Iarch/ia64/sn/include
 
 obj-y				+= setup.o
 obj-$(CONFIG_IA64_GENERIC)      += machvec.o
-- 
1.7.2.1

