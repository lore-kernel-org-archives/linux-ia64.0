From: Richard Weinberger <richard@nod.at>
Date: Sun, 13 Jul 2014 14:58:57 +0000
Subject: [PATCH 1/2] arm: Remove RISC OS personality
Message-Id: <1405263538-27589-2-git-send-email-richard@nod.at>
List-Id: <linux-ia64.vger.kernel.org>
References: <1405263538-27589-1-git-send-email-richard@nod.at>
In-Reply-To: <1405263538-27589-1-git-send-email-richard@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com, linux@arm.linux.org.uk
Cc: linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Richard Weinberger <richard@nod.at>

The RISC OS personality seems to be unused and untested for a long time.
Let's rip it out.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 arch/arm/Kconfig                  | 12 -----
 arch/arm/configs/badge4_defconfig |  1 -
 arch/arm/kernel/Makefile          |  1 -
 arch/arm/kernel/arthur.c          | 94 ---------------------------------------
 4 files changed, 108 deletions(-)
 delete mode 100644 arch/arm/kernel/arthur.c

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 245058b..b57afd3 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -2177,18 +2177,6 @@ menu "Userspace binary formats"
 
 source "fs/Kconfig.binfmt"
 
-config ARTHUR
-	tristate "RISC OS personality"
-	depends on !AEABI
-	help
-	  Say Y here to include the kernel code necessary if you want to run
-	  Acorn RISC OS/Arthur binaries under Linux. This code is still very
-	  experimental; if this sounds frightening, say N and sleep in peace.
-	  You can also say M here to compile this support as a module (which
-	  will be called arthur).
-
-endmenu
-
 menu "Power management options"
 
 source "kernel/power/Kconfig"
diff --git a/arch/arm/configs/badge4_defconfig b/arch/arm/configs/badge4_defconfig
index 0494c8f..d590098 100644
--- a/arch/arm/configs/badge4_defconfig
+++ b/arch/arm/configs/badge4_defconfig
@@ -12,7 +12,6 @@ CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
 CONFIG_FPE_NWFPE=y
 CONFIG_BINFMT_AOUT=m
 CONFIG_BINFMT_MISC=m
-CONFIG_ARTHUR=m
 CONFIG_NET=y
 CONFIG_PACKET=y
 CONFIG_UNIX=y
diff --git a/arch/arm/kernel/Makefile b/arch/arm/kernel/Makefile
index 38ddd9f..742e076 100644
--- a/arch/arm/kernel/Makefile
+++ b/arch/arm/kernel/Makefile
@@ -35,7 +35,6 @@ obj-$(CONFIG_CPU_IDLE)		+= cpuidle.o
 obj-$(CONFIG_ISA_DMA_API)	+= dma.o
 obj-$(CONFIG_FIQ)		+= fiq.o fiqasm.o
 obj-$(CONFIG_MODULES)		+= armksyms.o module.o
-obj-$(CONFIG_ARTHUR)		+= arthur.o
 obj-$(CONFIG_ISA_DMA)		+= dma-isa.o
 obj-$(CONFIG_PCI)		+= bios32.o isa.o
 obj-$(CONFIG_ARM_CPU_SUSPEND)	+= sleep.o suspend.o
diff --git a/arch/arm/kernel/arthur.c b/arch/arm/kernel/arthur.c
deleted file mode 100644
index 321c529..0000000
--- a/arch/arm/kernel/arthur.c
+++ /dev/null
@@ -1,94 +0,0 @@
-/*
- *  linux/arch/arm/kernel/arthur.c
- *
- *  Copyright (C) 1998, 1999, 2000, 2001 Philip Blundell
- *
- * Arthur personality
- */
-
-/*
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#include <linux/module.h>
-#include <linux/personality.h>
-#include <linux/stddef.h>
-#include <linux/signal.h>
-#include <linux/init.h>
-#include <linux/sched.h>
-
-#include <asm/ptrace.h>
-
-/* Arthur doesn't have many signals, and a lot of those that it does
-   have don't map easily to any Linux equivalent.  Never mind.  */
-
-#define ARTHUR_SIGABRT		1
-#define ARTHUR_SIGFPE		2
-#define ARTHUR_SIGILL		3
-#define ARTHUR_SIGINT		4
-#define ARTHUR_SIGSEGV		5
-#define ARTHUR_SIGTERM		6
-#define ARTHUR_SIGSTAK		7
-#define ARTHUR_SIGUSR1		8
-#define ARTHUR_SIGUSR2		9
-#define ARTHUR_SIGOSERROR	10
-
-static unsigned long arthur_to_linux_signals[32] = {
-	0,	1,	2,	3,	4,	5,	6,	7,
-	8,	9,	10,	11,	12,	13,	14,	15,
-	16,	17,	18,	19,	20,	21,	22,	23,
-	24,	25,	26,	27,	28,	29,	30,	31
-};
-
-static unsigned long linux_to_arthur_signals[32] = {
-	0,		-1,		ARTHUR_SIGINT,	-1,
-       	ARTHUR_SIGILL,	5,		ARTHUR_SIGABRT,	7,
-	ARTHUR_SIGFPE,	9,		ARTHUR_SIGUSR1,	ARTHUR_SIGSEGV,	
-	ARTHUR_SIGUSR2,	13,		14,		ARTHUR_SIGTERM,
-	16,		17,		18,		19,
-	20,		21,		22,		23,
-	24,		25,		26,		27,
-	28,		29,		30,		31
-};
-
-static void arthur_lcall7(int nr, struct pt_regs *regs)
-{
-	struct siginfo info;
-	info.si_signo = SIGSWI;
-	info.si_errno = nr;
-	/* Bounce it to the emulator */
-	send_sig_info(SIGSWI, &info, current);
-}
-
-static struct exec_domain arthur_exec_domain = {
-	.name		= "Arthur",
-	.handler	= arthur_lcall7,
-	.pers_low	= PER_RISCOS,
-	.pers_high	= PER_RISCOS,
-	.signal_map	= arthur_to_linux_signals,
-	.signal_invmap	= linux_to_arthur_signals,
-	.module		= THIS_MODULE,
-};
-
-/*
- * We could do with some locking to stop Arthur being removed while
- * processes are using it.
- */
-
-static int __init arthur_init(void)
-{
-	return register_exec_domain(&arthur_exec_domain);
-}
-
-static void __exit arthur_exit(void)
-{
-	unregister_exec_domain(&arthur_exec_domain);
-}
-
-module_init(arthur_init);
-module_exit(arthur_exit);
-
-MODULE_LICENSE("GPL");
-- 
2.0.1

