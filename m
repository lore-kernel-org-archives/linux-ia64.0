From: Keith Owens <kaos@sgi.com>
Date: Thu, 20 Nov 2003 07:52:33 +0000
Subject: Re: Problems using psr.dd
Message-Id: <marc-linux-ia64-106931487414940@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106879020623297@msgid-missing>
In-Reply-To: <marc-linux-ia64-106879020623297@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

DavidM suggested that I redo the test debug module without kdb_printf()
and the problem went away!

It turns out that the problem is not kdb, it is an RSE problem which is
highly sensitive to the amount of RSE activity that occurs inside the
hardware breakpoint handler.  kdb_printf() always prints its messages
using polling mode, printk() delays output if the kernel is in
interrupt context.  The extra work that is done by kdb_printf() as
opposed to printk() is enough to trip the RSE problem.

If there is enough RSE activity during the hardware breakpoint handler
to flush the registers at the time of the breakpoint then returning
with psr.db = 1 and psr.dd = 1 to step over the hardware breakpoint
will not work.  The RSE activity that occurs as the flushed registers
are restored is counted as a valid instruction, psr.dd is cleared, the
original instruction is reexecuted and it trips again.

Beware of doing too much activity in the hardware breakpoint handler.
I will create a patch against traps.c to detect a return with psr.dd
set and issue loadrs to ensure that the RSE problem does not bite us.

The debug.c module below demonstrates the problem.  "modprobe debug.o"
usually works, but even without flushrs it sometimes trips the RSE
problem, depending on system activity.  "modprobe debug.o do_flushrs=1"
always hits the problem.

== debug.c ==

#include <linux/config.h>
#include <linux/slab.h>
#include <linux/module.h>
#include <linux/console.h>

int victim;
int do_flushrs;
static int trap29count;
extern int (*trap29)(unsigned long ifa, struct pt_regs *regs);

MODULE_LICENSE("GPL");
MODULE_PARM(do_flushrs, "i");

static int do_trap29(unsigned long ifa, struct pt_regs *regs)
{
	if (user_mode(regs))
		return 0;
	printk("trap 29 ifa=0x%016lx iip=0x%016lx count=%d victim=%d\n", ifa, regs->cr_iip, trap29count, victim);
	if (do_flushrs)
		asm volatile (";;flushrs;; " :::"memory");
	if (trap29count >= 3) {
		printk("db is looping, disabling it\n");
		ia64_psr(regs)->db = 0;
	} else {
		++trap29count;
		ia64_psr(regs)->dd = 1;
	}
	return 1;
}

static void setdbr(unsigned long regnum, unsigned long address, unsigned long mask)
{
	__asm__ __volatile__ ("mov dbr[%0]=%1;;mov dbr[%2]=%3;;"::"r"(regnum),"r"(address),"r"(regnum+1),"r"(mask));
	ia64_srlz_d();
}

static void setpsrdb(int on)
{
	unsigned long tmp;
	if (on)
		__asm__ __volatile__ ("mov %0=psr;;dep %0=-1,%0,24,1;;mov psr.l=%0;;srlz.d;;srlz.i;;":"=r"(tmp)::"memory");
	else
		__asm__ __volatile__ ("mov %0=psr;;dep %0=0,%0,24,1;;mov psr.l=%0;;srlz.d;;srlz.i;;":"=r"(tmp)::"memory");
}

static int __init init_debug(void)
{
	trap29 = &do_trap29;
	setdbr(0, (unsigned long)&victim, 1UL<<62 | 1UL<<56 | (-4UL & 0xffffffffffffffUL));
	setpsrdb(1);
	victim = 1;
	barrier();
	victim = 2;
	setpsrdb(0);
	return 0;
}

static void __exit exit_debug(void)
{
	trap29 = NULL;
	setdbr(0, 0, 0);
}

module_init(init_debug)
module_exit(exit_debug)

======

Patch against traps.c to invoke the test trap29() handler in module
debug.c.

--- 2.4.23-pre9-cset-1.1069.1.104-to-1.1111/arch/ia64/kernel/Makefile	Fri Oct 31 10:40:52 2003
+++ 2.4.23-pre9-cset-1.1069.1.104-to-1.1111-psr.dd/arch/ia64/kernel/Makefile	Thu Nov 20 18:49:15 2003
@@ -11,7 +11,7 @@ all: kernel.o head.o init_task.o
 
 O_TARGET := kernel.o
 
-export-objs := ia64_ksyms.o
+export-objs := ia64_ksyms.o traps.o
 
 obj-y := acpi.o entry.o gate.o efi.o efi_stub.o ia64_ksyms.o irq.o irq_ia64.o irq_lsapic.o ivt.o \
 	 machvec.o pal.o process.o perfmon.o ptrace.o sal.o salinfo.o semaphore.o setup.o	 \
--- 2.4.23-pre9-cset-1.1069.1.104-to-1.1111/arch/ia64/kernel/traps.c	Thu Nov 20 16:04:45 2003
+++ 2.4.23-pre9-cset-1.1069.1.104-to-1.1111-psr.dd/arch/ia64/kernel/traps.c	Thu Nov 20 18:49:15 2003
@@ -429,6 +429,10 @@ ia64_illegal_op_fault (unsigned long ec,
 	return rv;
 }
 
+#include <linux/module.h>
+int (*trap29)(unsigned long ifa, struct pt_regs *regs);
+EXPORT_SYMBOL(trap29);
+
 void
 ia64_fault (unsigned long vector, unsigned long isr, unsigned long ifa,
 	    unsigned long iim, unsigned long itir, unsigned long arg5,
@@ -528,6 +532,8 @@ ia64_fault (unsigned long vector, unsign
 		break;
 
 	      case 29: /* Debug */
+			if (trap29 && trap29(ifa, regs))
+				return;
 	      case 35: /* Taken Branch Trap */
 	      case 36: /* Single Step Trap */
 		switch (vector) {

