From: Martin Hicks <mort@wildopensource.com>
Date: Mon, 09 Jun 2003 18:27:27 +0000
Subject: Re: [Linux-ia64] [PATCH] Compile fix for perfmon 2
Message-Id: <marc-linux-ia64-105590723706198@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706197@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706197@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jun 09, 2003 at 01:29:23PM -0400, Martin Hicks wrote:
> 
> Stephane and David,
> 
> Here is a little patch to fix compilation of perfmon 2 when it
> is turned off.

I jumped the gun on this a bit.  With the first patch perfmon*.c
compiles, but the kernel doesn't link.  Here's a fix.

mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1126  -> 1.1127 
#	arch/ia64/kernel/Makefile	1.19    -> 1.20   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/09	mort@green.i.bork.org	1.1127
# This lets the kernel link properly if perfmon is turned off.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- a/arch/ia64/kernel/Makefile	Mon Jun  9 14:25:22 2003
+++ b/arch/ia64/kernel/Makefile	Mon Jun  9 14:25:22 2003
@@ -5,7 +5,7 @@
 extra-y	:= head.o init_task.o
 
 obj-y := acpi.o entry.o efi.o efi_stub.o gate.o ia64_ksyms.o irq.o irq_ia64.o irq_lsapic.o	\
-	 ivt.o machvec.o pal.o perfmon.o perfmon_default_smpl.o process.o ptrace.o sal.o \
+	 ivt.o machvec.o pal.o perfmon.o process.o ptrace.o sal.o \
 	 semaphore.o setup.o signal.o sys_ia64.o time.o traps.o unaligned.o unwind.o
 
 obj-$(CONFIG_EFI_VARS)		+= efivars.o
@@ -18,6 +18,7 @@
 obj-$(CONFIG_IOSAPIC)		+= iosapic.o
 obj-$(CONFIG_MODULES)		+= module.o
 obj-$(CONFIG_SMP)		+= smp.o smpboot.o
+obj-$(CONFIG_PERFMON)		+= perfmon_default_smpl.o
 
 arch/$(ARCH)/kernel/asm-offsets.s: include/asm-$(ARCH)/.offsets.h.stamp
 

