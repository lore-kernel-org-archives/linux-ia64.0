From: Keith Owens <kaos@sgi.com>
Date: Fri, 14 Nov 2003 06:09:15 +0000
Subject: Problems using psr.dd
Message-Id: <marc-linux-ia64-106879020623297@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am unable to successfully use psr.dd on 2.4 and 2.6 kernels.  The
patches below plus the debug.c module demonstrate the problem.
do_trap29() sets regs->cr_ipsr.dd and returns.  The kernel drops
through ia64_leave_kernel, loads the modified ipsr and does rfi.
However the same debug fault occurs again, as if psr.dd were being
ignored.

What am I missing?

# depmod -ae;rmmod debug 2>/dev/null; modprobe debug
init_debug: start
dbr[0]=0xa0000000000b8f90 dbr[1]=0x41fffffffffffffc
setpsrdb: on=1
init_debug: test
trap 29 ifa=0xa0000000000b8f90 iip=0xa0000000000b8430 count=0
trap 29 ifa=0xa0000000000b8f90 iip=0xa0000000000b8430 count=1
trap 29 ifa=0xa0000000000b8f90 iip=0xa0000000000b8430 count=2
trap 29 ifa=0xa0000000000b8f90 iip=0xa0000000000b8430 count=3
db is looping, disabling it
setpsrdb: on=0
init_debug: end


--- linux/arch/ia64/kernel/Makefile_1.24	Fri Nov 14 16:57:08 2003
+++ linux/arch/ia64/kernel/Makefile	Fri Nov 14 16:19:49 2003
@@ -11,7 +11,7 @@
 
 O_TARGET := kernel.o
 
-export-objs := ia64_ksyms.o sal.o
+export-objs := ia64_ksyms.o sal.o traps.o
 
 obj-y := acpi.o entry.o gate.o efi.o efi_stub.o ia64_ksyms.o irq.o irq_ia64.o irq_lsapic.o ivt.o \
 	 machvec.o pal.o process.o perfmon.o ptrace.o sal.o salinfo.o semaphore.o setup.o	 \

--- linux/arch/ia64/kernel/entry.S_1.33	Fri Nov 14 16:57:08 2003
+++ linux/arch/ia64/kernel/entry.S	Fri Nov 14 16:55:03 2003
@@ -771,7 +771,127 @@
 	mov ar.rsc=rARRSC
 	mov ar.unat=rARUNAT
 	mov pr=rARPR,-1
-	rfi
+	;;
+	// lots of nops for Itanium2 errata 11
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	;;
+	rfi;;
+	// lots of nops for Itanium2 errata 11
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	nop 0
+	nop 0
+	nop 0;;
+	;;
+	;;
 END(ia64_leave_kernel)
 
 ENTRY(handle_syscall_error)

--- linux/arch/ia64/kernel/traps.c_1.27	Fri Nov 14 16:57:08 2003
+++ linux/arch/ia64/kernel/traps.c	Fri Nov 14 16:27:57 2003
@@ -452,6 +452,10 @@
 	return rv;
 }
 
+#include <linux/module.h>
+int (*trap29)(unsigned long ifa, struct pt_regs *regs);
+EXPORT_SYMBOL(trap29);
+
 void
 ia64_fault (unsigned long vector, unsigned long isr, unsigned long ifa,
 	    unsigned long iim, unsigned long itir, unsigned long arg5,
@@ -551,6 +555,8 @@
 		break;
 
 	      case 29: /* Debug */
+			if (trap29 && trap29(ifa, regs))
+				return;
 	      case 35: /* Taken Branch Trap */
 	      case 36: /* Single Step Trap */
 		switch (vector) {


== debug.c =
#include <linux/config.h>
#include <linux/slab.h>
#include <linux/kdb.h>
#include <linux/module.h>

MODULE_LICENSE("GPL");

int victim;
static int trap29count;
extern int (*trap29)(unsigned long ifa, struct pt_regs *regs);

static int do_trap29(unsigned long ifa, struct pt_regs *regs)
{
	if (user_mode(regs))
		return 0;
	kdb_printf("trap 29 ifa=0x%016lx iip=0x%016lx count=%d\n", ifa, regs->cr_iip, trap29count);
	if (trap29count >= 3) {
		kdb_printf("db is looping, disabling it\n");
		ia64_psr(regs)->db = 0;
	} else {
		++trap29count;
		ia64_psr(regs)->dd = 1;
	}
	return 1;
}

static void setdbr(unsigned long regnum, unsigned long address, unsigned long mask)
{
	kdb_printf("dbr[%ld]=0x%016lx dbr[%ld]=0x%016lx\n", regnum, address, regnum+1, mask);
	__asm__ __volatile__ ("mov dbr[%0]=%1;;mov dbr[%2]=%3;;"::"r"(regnum),"r"(address),"r"(regnum+1),"r"(mask));
	ia64_srlz_d();
}

static void setpsrdb(int on)
{
	unsigned long tmp;
	kdb_printf("%s: on=%d\n", __FUNCTION__, on);
	if (on)
		__asm__ __volatile__ ("mov %0=psr;;dep %0=-1,%0,24,1;;mov psr.l=%0;;srlz.d;;srlz.i;;":"=r"(tmp)::"memory");
	else
		__asm__ __volatile__ ("mov %0=psr;;dep %0=0,%0,24,1;;mov psr.l=%0;;srlz.d;;srlz.i;;":"=r"(tmp)::"memory");
}


static int __init init_debug(void)
{
	kdb_printf("%s: start\n", __FUNCTION__);
	trap29 = &do_trap29;
	setdbr(0, (unsigned long)&victim, 1UL<<62 | 1UL<<56 | (-4UL & 0xffffffffffffffUL));
	setpsrdb(1);
	kdb_printf("%s: test\n", __FUNCTION__);
	victim = 1;
	setpsrdb(0);
	kdb_printf("%s: end\n", __FUNCTION__);
	return 0;
}

static void __exit exit_debug(void)
{
	kdb_printf("%s: start\n", __FUNCTION__);
	trap29 = NULL;
	setdbr(0, 0, 0);
	kdb_printf("%s: end\n", __FUNCTION__);
}

module_init(init_debug)
module_exit(exit_debug)

