From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 09 Sep 2000 06:51:50 +0000
Subject: [Linux-ia64] kernel update (relative to v2.4.0-test8)
Message-Id: <marc-linux-ia64-105590678205467@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest IA-64 kernel diff is now available at:

    ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file linux-2.4.0-test8-ia64-000908.diff.gz.  The most important
changes since the previous version:

	- SMP should be MUCH more stable again, thanks to Asit's fixed
	  for fph and the deadlock fix to read/write-lock.  Note that
	  for SMP, I eliminated the notion of "fpu_owner" completely,
	  as it made no sense with the current setup.  Longer term, I
	  think it would be better to manage the the fph partition in
	  a completely lazy fashion as we do on UP.  IMHO, if you have
	  four threads and four CPUs, the fph contents should never
	  have to be switched.

	- Don's IA-32 updates (support for inb/outb et al...)

	- Updated qla1280 driver from Qlogic.  This one uses the PCI
	  DMA interface.  It should boot on any machine independent of
	  whether >4GB addressing is enabled.  Of course, for best
	  performance you'll want to make sure >4GB addressing is
	  enabled on machines with memory above 4GB.

	- Stephane's efi_map_pal_code() updates to avoid overlapping
	  TLB translations.  Also some updates to /proc/pal.

	- Bill added a bunch of symbols to ia64_ksyms.

	- Rob's fix for ia64_pal_cache_flush (psr.ic needs to be off)
	  and addition of ia64_pal_prefetch_visibility() call.

	- ar.ec is now accessible via ptrace() again (got dropped
          accidentally..).

	- Hacked the eepro100 driver to make it possible to DMA
	  incoming packets in a way that will yield properly aligned
	  IP headers.  This results in a very significant saving of
	  CPU utilization during heavy Ethernet I/O.  I also added an
	  option to force device socket buffer allocation to be below
	  4GB, which should avoid bounce buffers on systems with
	  memory above 4GB.  It won't eliminate them completely
	  though.  Haven't had a chance to determine the performance
	  effect of this.  It's just a hack until 2.5 comes along and
	  gives us an all-improved memory allocation scheme... ;-)

The patch below is once again a rough approximation of what changed
since the last update.  This kernel has been tested on the HP Ski
simulator, Big Sur (UP and MP), and Lion (MP).

Enjoy,

	--david

diff -urN linux-davidm/Documentation/Configure.help lia64/Documentation/Configure.help
--- linux-davidm/Documentation/Configure.help	Fri Sep  8 22:36:14 2000
+++ lia64/Documentation/Configure.help	Fri Sep  8 16:19:57 2000
@@ -16607,6 +16607,17 @@
   Say Y here to enable hacks to make the kernel work on the NEC
   AzusA platform.  Select N here if you're unsure.
 
+Force socket buffers below 4GB?
+CONFIG_SKB_BELOW_4GB
+  Most of today's network interface cards (NICs) support DMA to
+  the low 32 bits of the address space only.  On machines with
+  more then 4GB of memory, this can cause the system to slow
+  down if there is no I/O TLB hardware.  Turning this option on
+  avoids the slow-down by forcing socket buffers to be allocated
+  from memory below 4GB.  The downside is that your system could
+  run out of memory below 4GB before all memory has been used up.
+  If you're unsure how to answer this question, answer Y.
+
 Enable IA-64 Machine Check Abort
 CONFIG_IA64_MCA
   Say Y here to enable machine check support for IA-64.  If you're
diff -urN linux-davidm/arch/ia64/config.in lia64/arch/ia64/config.in
--- linux-davidm/arch/ia64/config.in	Fri Sep  8 22:36:14 2000
+++ lia64/arch/ia64/config.in	Fri Sep  8 16:21:07 2000
@@ -51,6 +51,7 @@
 	bool '  Enable SoftSDV hacks' CONFIG_IA64_SOFTSDV_HACKS
 	bool '  Enable AzusA hacks' CONFIG_IA64_AZUSA_HACKS
 	bool '  Enable IA-64 Machine Check Abort' CONFIG_IA64_MCA
+	bool '  Force socket buffers below 4GB?' CONFIG_SKB_BELOW_4GB
 
 	bool '  ACPI kernel configuration manager (EXPERIMENTAL)' CONFIG_ACPI_KERNEL_CONFIG
 	if [ "$CONFIG_ACPI_KERNEL_CONFIG" = "y" ]; then
diff -urN linux-davidm/arch/ia64/ia32/binfmt_elf32.c lia64/arch/ia64/ia32/binfmt_elf32.c
--- linux-davidm/arch/ia64/ia32/binfmt_elf32.c	Thu Aug 10 19:56:18 2000
+++ lia64/arch/ia64/ia32/binfmt_elf32.c	Fri Sep  8 16:21:30 2000
@@ -52,7 +52,7 @@
 	pte_t * pte;
 
 	if (page_count(page) != 1)
-		printk("mem_map disagrees with %p at %08lx\n", page, address);
+		printk("mem_map disagrees with %p at %08lx\n", (void *) page, address);
 	pgd = pgd_offset(tsk->mm, address);
 	pmd = pmd_alloc(pgd, address);
 	if (!pmd) {
@@ -120,6 +120,8 @@
 		: "r" ((ulong)IA32_FCR_DEFAULT));
 	__asm__("mov ar.fir = r0");
 	__asm__("mov ar.fdr = r0");
+	__asm__("mov %0=ar.k0 ;;" : "=r" (current->thread.old_iob));
+	__asm__("mov ar.k0=%0 ;;" :: "r"(IA32_IOBASE));
 	/* TSS */
 	__asm__("mov ar.k1 = %0"
 		: /* no outputs */
diff -urN linux-davidm/arch/ia64/ia32/ia32_signal.c lia64/arch/ia64/ia32/ia32_signal.c
--- linux-davidm/arch/ia64/ia32/ia32_signal.c	Thu Jun 22 07:09:44 2000
+++ lia64/arch/ia64/ia32/ia32_signal.c	Fri Sep  8 16:21:40 2000
@@ -278,7 +278,7 @@
 
        err |= setup_sigcontext_ia32(&frame->sc, &frame->fpstate, regs, set->sig[0]);
 
-       if (_NSIG_WORDS > 1) {
+       if (_IA32_NSIG_WORDS > 1) {
                err |= __copy_to_user(frame->extramask, &set->sig[1],
                                      sizeof(frame->extramask));
        }
@@ -310,7 +310,7 @@
 
 #if 0
        printk("SIG deliver (%s:%d): sig=%d sp=%p pc=%lx ra=%x\n",
-               current->comm, current->pid, sig, frame, regs->cr_iip, frame->pretcode);
+               current->comm, current->pid, sig, (void *) frame, regs->cr_iip, frame->pretcode);
 #endif
 
        return 1;
@@ -380,7 +380,7 @@
 
 #if 0
        printk("SIG deliver (%s:%d): sp=%p pc=%lx ra=%x\n",
-               current->comm, current->pid, frame, regs->cr_iip, frame->pretcode);
+               current->comm, current->pid, (void *) frame, regs->cr_iip, frame->pretcode);
 #endif
 
        return 1;
diff -urN linux-davidm/arch/ia64/ia32/ia32_support.c lia64/arch/ia64/ia32/ia32_support.c
--- linux-davidm/arch/ia64/ia32/ia32_support.c	Thu Jun 22 07:09:44 2000
+++ lia64/arch/ia64/ia32/ia32_support.c	Fri Sep  8 16:21:50 2000
@@ -42,6 +42,7 @@
 	thread->csd = csd;
 	thread->ssd = ssd;
 	thread->tssd = tssd;
+	asm ("mov ar.k0=%0 ;;" :: "r"(thread->old_iob));
 }
 
 void
@@ -68,6 +69,8 @@
 		      "mov ar.k1=%7"
 		      :: "r"(eflag), "r"(fsr), "r"(fcr), "r"(fir), "r"(fdr),
 		         "r"(csd), "r"(ssd), "r"(tssd));
+	asm ("mov %0=ar.k0 ;;" : "=r"(thread->old_iob));
+	asm ("mov ar.k0=%0 ;;" :: "r"(IA32_IOBASE));
 }
 
 /*
diff -urN linux-davidm/arch/ia64/ia32/sys_ia32.c lia64/arch/ia64/ia32/sys_ia32.c
--- linux-davidm/arch/ia64/ia32/sys_ia32.c	Fri Sep  8 22:36:14 2000
+++ lia64/arch/ia64/ia32/sys_ia32.c	Fri Sep  8 16:22:05 2000
@@ -75,11 +75,11 @@
 	n = 0;
 	do {
 		err = get_user(addr, (int *)A(arg));
-		if (IS_ERR(err))
+		if (err)
 			return err;
 		if (ap) {		/* no access_ok needed, we allocated */
 			err = __put_user((char *)A(addr), ap++);
-			if (IS_ERR(err))
+			if (err)
 				return err;
 		}
 		arg += sizeof(unsigned int);
@@ -102,13 +102,14 @@
 {
 	struct pt_regs *regs = (struct pt_regs *)&stack;
 	char **av, **ae;
-	int na, ne, r, len;
+	int na, ne, len;
+	long r;
 
 	na = nargs(argv, NULL);
-	if (IS_ERR(na))
+	if (na < 0)
 		return(na);
 	ne = nargs(envp, NULL);
-	if (IS_ERR(ne))
+	if (ne < 0)
 		return(ne);
 	len = (na + ne + 2) * sizeof(*av);
 	/*
@@ -130,19 +131,19 @@
 		return (long)av;
 	ae = av + na + 1;
 	r = __put_user(0, (av + na));
-	if (IS_ERR(r))
+	if (r)
 		goto out;
 	r = __put_user(0, (ae + ne));
-	if (IS_ERR(r))
+	if (r)
 		goto out;
 	r = nargs(argv, av);
-	if (IS_ERR(r))
+	if (r < 0)
 		goto out;
 	r = nargs(envp, ae);
-	if (IS_ERR(r))
+	if (r < 0)
 		goto out;
 	r = sys_execve(filename, av, ae, regs);
-	if (IS_ERR(r))
+	if (r < 0)
 out:
 		sys_munmap((unsigned long) av, len);
 	return(r);
@@ -297,7 +298,7 @@
  		error = do_mmap(file, addr, len, prot, flags, poff);
   		up(&current->mm->mmap_sem);
 
- 		if (!IS_ERR(error))
+ 		if (!IS_ERR((void *) error))
  			error += offset - poff;
  	} else {
   		down(&current->mm->mmap_sem);
@@ -2544,6 +2545,78 @@
 	printk("IA32 syscall #%d issued, maybe we should implement it\n",
 		(int)regs->r1);
 	return(sys_ni_syscall());
+}
+
+/*
+ *  The IA64 maps 4 I/O ports for each 4K page
+ */
+#define IOLEN	((65536 / 4) * 4096)
+
+asmlinkage long
+sys_iopl (int level, long arg1, long arg2, long arg3)
+{
+	extern unsigned long ia64_iobase;
+	int fd;
+	struct file * file;
+	unsigned int old;
+	unsigned long addr;
+	mm_segment_t old_fs = get_fs ();
+
+	if (level != 3)
+		return(-EINVAL);
+	/* Trying to gain more privileges? */
+	__asm__ __volatile__("mov %0=ar.eflag ;;" : "=r"(old));
+	if (level > ((old >> 12) & 3)) {
+		if (!capable(CAP_SYS_RAWIO))
+			return -EPERM;
+	}
+	set_fs(KERNEL_DS);
+	fd = sys_open("/dev/mem", O_SYNC | O_RDWR, 0);
+	set_fs(old_fs);
+	if (fd < 0)
+		return fd;
+	file = fget(fd);
+	if (file = NULL) {
+		sys_close(fd);
+		return(-EFAULT);
+	}
+
+	down(&current->mm->mmap_sem);
+	lock_kernel();
+
+	addr = do_mmap_pgoff(file, IA32_IOBASE,
+			IOLEN, PROT_READ|PROT_WRITE, MAP_SHARED,
+			(ia64_iobase & ~PAGE_OFFSET) >> PAGE_SHIFT);
+
+	unlock_kernel();
+	up(&current->mm->mmap_sem);
+
+	if (addr >= 0) {
+		__asm__ __volatile__("mov ar.k0=%0 ;;" :: "r"(addr));
+		old = (old & ~0x3000) | (level << 12);
+		__asm__ __volatile__("mov ar.eflag=%0 ;;" :: "r"(old));
+	}
+
+	fput(file);
+	sys_close(fd);
+	return 0;
+}
+
+asmlinkage long
+sys_ioperm (unsigned long from, unsigned long num, int on)
+{
+
+	/*
+	 *  Since IA64 doesn't have permission bits we'd have to go to
+	 *    a lot of trouble to simulate them in software.  There's
+	 *    no point, only trusted programs can make this call so we'll
+	 *    just turn it into an iopl call and let the process have
+	 *    access to all I/O ports.
+	 *
+	 * XXX proper ioperm() support should be emulated by
+	 *	manipulating the page protections...
+	 */
+	return(sys_iopl(3, 0, 0, 0));
 }
 
 #ifdef	NOTYET  /* UNTESTED FOR IA64 FROM HERE DOWN */
diff -urN linux-davidm/arch/ia64/kernel/efi.c lia64/arch/ia64/kernel/efi.c
--- linux-davidm/arch/ia64/kernel/efi.c	Thu Aug 24 08:17:30 2000
+++ lia64/arch/ia64/kernel/efi.c	Fri Sep  8 16:22:33 2000
@@ -247,12 +247,41 @@
 			       md->phys_addr);
 			continue;
 		}
-		mask  = ~((1 << _PAGE_SIZE_4M)-1);	/* XXX should be dynamic? */
+		/*
+		 * We must use the same page size as the one used
+		 * for the kernel region when we map the PAL code.
+		 * This way, we avoid overlapping TRs if code is 
+		 * executed nearby. The Alt I-TLB installs 256MB
+		 * page sizes as defined for region 7.
+		 *
+		 * XXX Fixme: should be dynamic here (for page size)
+		 */
+		mask  = ~((1 << _PAGE_SIZE_256M)-1);
 		vaddr = PAGE_OFFSET + md->phys_addr;
 
-	  	printk(__FUNCTION__": mapping PAL code [0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
-		       md->phys_addr, md->phys_addr + (md->num_pages << 12),
-		       vaddr & mask, (vaddr & mask) + 4*1024*1024);
+		/*
+		 * We must check that the PAL mapping won't overlap
+		 * with the kernel mapping on ITR1. 
+		 *
+		 * PAL code is guaranteed to be aligned on a power of 2
+		 * between 4k and 256KB.
+		 * Also from the documentation, it seems like there is an
+		 * implicit guarantee that you will need only ONE ITR to
+		 * map it. This implies that the PAL code is always aligned
+		 * on its size, i.e., the closest matching page size supported
+		 * by the TLB. Therefore PAL code is guaranteed never to cross
+		 * a 256MB unless it is bigger than 256MB (very unlikely!).
+		 * So for now the following test is enough to determine whether
+		 * or not we need a dedicated ITR for the PAL code.
+		 */
+		if ((vaddr & mask) = (PAGE_OFFSET & mask)) {
+			printk(__FUNCTION__ " : no need to install ITR for PAL Code\n");
+			continue;
+		}
+
+	  	printk(__FUNCTION__": CPU %d mapping PAL code [0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
+		       smp_processor_id(), md->phys_addr, md->phys_addr + (md->num_pages << 12),
+		       vaddr & mask, (vaddr & mask) + 256*1024*1024);
 
 		/*
 		 * Cannot write to CRx with PSR.ic=1
@@ -263,12 +292,11 @@
 		 * ITR0/DTR0: used for kernel code/data
 		 * ITR1/DTR1: used by HP simulator
 		 * ITR2/DTR2: map PAL code
-		 * ITR3/DTR3: used to map PAL calls buffer
 		 */
 		ia64_itr(0x1, 2, vaddr & mask,
 			 pte_val(mk_pte_phys(md->phys_addr,
 					     __pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RX))),
-			 _PAGE_SIZE_4M);
+			 _PAGE_SIZE_256M);
 		local_irq_restore(flags);
 		ia64_srlz_i ();
 	}
diff -urN linux-davidm/arch/ia64/kernel/ia64_ksyms.c lia64/arch/ia64/kernel/ia64_ksyms.c
--- linux-davidm/arch/ia64/kernel/ia64_ksyms.c	Thu Aug 24 08:17:30 2000
+++ lia64/arch/ia64/kernel/ia64_ksyms.c	Fri Sep  8 16:22:52 2000
@@ -18,6 +18,8 @@
 EXPORT_SYMBOL(strncat);
 EXPORT_SYMBOL(strncmp);
 EXPORT_SYMBOL(strncpy);
+EXPORT_SYMBOL(strnlen);
+EXPORT_SYMBOL(strrchr);
 EXPORT_SYMBOL(strstr);
 EXPORT_SYMBOL(strtok);
 
@@ -28,11 +30,25 @@
 #include <linux/in6.h>
 #include <asm/checksum.h>
 EXPORT_SYMBOL(csum_partial_copy_nocheck);
+EXPORT_SYMBOL(csum_tcpudp_magic);
+EXPORT_SYMBOL(ip_compute_csum);
+EXPORT_SYMBOL(ip_fast_csum);
 
 #include <asm/irq.h>
 EXPORT_SYMBOL(enable_irq);
 EXPORT_SYMBOL(disable_irq);
 
+#include <asm/page.h>
+EXPORT_SYMBOL(clear_page);
+
+#include <asm/pci.h>
+EXPORT_SYMBOL(pci_dma_sync_sg);
+EXPORT_SYMBOL(pci_dma_sync_single);
+EXPORT_SYMBOL(pci_map_sg);
+EXPORT_SYMBOL(pci_map_single);
+EXPORT_SYMBOL(pci_unmap_sg);
+EXPORT_SYMBOL(pci_unmap_single);
+
 #include <asm/processor.h>
 EXPORT_SYMBOL(cpu_data);
 EXPORT_SYMBOL(kernel_thread);
@@ -40,6 +56,10 @@
 #ifdef CONFIG_SMP
 #include <asm/hardirq.h>
 EXPORT_SYMBOL(synchronize_irq);
+
+#include <asm/smp.h>
+EXPORT_SYMBOL(smp_call_function);
+EXPORT_SYMBOL(smp_num_cpus);
 
 #include <asm/smplock.h>
 EXPORT_SYMBOL(kernel_flag);
diff -urN linux-davidm/arch/ia64/kernel/irq.c lia64/arch/ia64/kernel/irq.c
--- linux-davidm/arch/ia64/kernel/irq.c	Thu Aug 10 19:56:18 2000
+++ lia64/arch/ia64/kernel/irq.c	Fri Sep  8 16:23:06 2000
@@ -536,8 +536,7 @@
 		desc->depth--;
 		break;
 	case 0:
-		printk("enable_irq() unbalanced from %p\n",
-		       __builtin_return_address(0));
+		printk("enable_irq() unbalanced from %p\n", (void *) __builtin_return_address(0));
 	}
 	spin_unlock_irqrestore(&desc->lock, flags);
 }
diff -urN linux-davidm/arch/ia64/kernel/minstate.h lia64/arch/ia64/kernel/minstate.h
--- linux-davidm/arch/ia64/kernel/minstate.h	Thu Jun 22 07:09:44 2000
+++ lia64/arch/ia64/kernel/minstate.h	Fri Sep  8 16:23:20 2000
@@ -192,13 +192,3 @@
 #define SAVE_MIN_WITH_COVER	DO_SAVE_MIN(cover;; mov rCRIFS=cr.ifs,) STOPS
 #define SAVE_MIN_WITH_COVER_R19	DO_SAVE_MIN(cover;; mov rCRIFS=cr.ifs, mov r15=r19) STOPS
 #define SAVE_MIN		DO_SAVE_MIN(mov rCRIFS=r0,) STOPS
-
-#ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
-# define STOPS	nop.i 0x0;; nop.i 0x0;; nop.i 0x0;;
-#else
-# define STOPS
-#endif
-
-#define SAVE_MIN_WITH_COVER	DO_SAVE_MIN(cover;; mov rCRIFS=cr.ifs,) STOPS
-#define SAVE_MIN_WITH_COVER_R19	DO_SAVE_MIN(cover;; mov rCRIFS=cr.ifs, mov r15=r19) STOPS
-#define SAVE_MIN		DO_SAVE_MIN(mov rCRIFS=r0,) STOPS
diff -urN linux-davidm/arch/ia64/kernel/pal.S lia64/arch/ia64/kernel/pal.S
--- linux-davidm/arch/ia64/kernel/pal.S	Thu Aug 24 08:17:30 2000
+++ lia64/arch/ia64/kernel/pal.S	Fri Sep  8 16:23:31 2000
@@ -54,7 +54,8 @@
  *
  * in0         Pointer to struct ia64_pal_retval
  * in1         Index of PAL service
- * in2 - in4   Remaning PAL arguments
+ * in2 - in4   Remaining PAL arguments
+ * in5	       1 => clear psr.ic,  0 => don't clear psr.ic
  *
  */
 GLOBAL_ENTRY(ia64_pal_call_static)
@@ -68,18 +69,22 @@
 	}
 	;;
 	ld8 loc2 = [loc2]		// loc2 <- entry point
-	mov r30 = in2
-	mov r31 = in3
+	tbit.nz p6,p7 = in5, 0
+	adds r8 = 1f-1b,r8
 	;;
 	mov loc3 = psr
 	mov loc0 = rp
 	UNW(.body)
-	adds r8 = 1f-1b,r8
-	;; 
-	rsm psr.i
+	mov r30 = in2
+
+(p6)	rsm psr.i | psr.ic
+	mov r31 = in3
 	mov b7 = loc2
+
+(p7)	rsm psr.i
+	;;
+(p6)	srlz.i
 	mov rp = r8
-	;; 
 	br.cond.sptk.few b7
 1:	mov psr.l = loc3
 	mov ar.pfs = loc1
diff -urN linux-davidm/arch/ia64/kernel/palinfo.c lia64/arch/ia64/kernel/palinfo.c
--- linux-davidm/arch/ia64/kernel/palinfo.c	Fri Sep  8 22:36:14 2000
+++ lia64/arch/ia64/kernel/palinfo.c	Fri Sep  8 16:23:41 2000
@@ -131,38 +131,6 @@
 	"NaTPage"			/* 111 */
 };
 
-
-
-/*
- * Allocate a buffer suitable for calling PAL code in Virtual mode
- *
- * The documentation (PAL2.6) allows DTLB misses on the buffer. So 
- * using the TC is enough, no need to pin the entry.
- *
- * We allocate a kernel-sized page (at least 4KB). This is enough to
- * hold any possible reply.
- */
-static inline void *
-get_palcall_buffer(void)
-{
-	void *tmp;
-
-	tmp = (void *)__get_free_page(GFP_KERNEL);
-	if (tmp = 0) {
-		printk(KERN_ERR __FUNCTION__" : can't get a buffer page\n"); 
-	} 
-	return tmp;
-}
-
-/*
- * Free a palcall buffer allocated with the previous call
- */
-static inline void
-free_palcall_buffer(void *addr)
-{
-	__free_page(addr);
-}
-
 /*
  * Take a 64bit vector and produces a string such that
  * if bit n is set then 2^n in clear text is generated. The adjustment
@@ -242,17 +210,12 @@
 {
 	s64 status;
 	char *p = page;
-	pal_power_mgmt_info_u_t *halt_info;
+	u64 halt_info_buffer[8];
+	pal_power_mgmt_info_u_t *halt_info =(pal_power_mgmt_info_u_t *)halt_info_buffer;
 	int i;
 
-	halt_info = get_palcall_buffer();
-	if (halt_info = 0) return 0;
-
 	status = ia64_pal_halt_info(halt_info);
-	if (status != 0) {
-		free_palcall_buffer(halt_info);
-		return 0;
-	}
+	if (status != 0) return 0;
 
 	for (i=0; i < 8 ; i++ ) {
 		if (halt_info[i].pal_power_mgmt_info_s.im = 1) {
@@ -269,9 +232,6 @@
 			p += sprintf(p,"Power level %d: not implemented\n",i);
 		}
 	}
-
-	free_palcall_buffer(halt_info);
-
 	return p - page;
 }
 
@@ -674,16 +634,10 @@
 perfmon_info(char *page)
 {
 	char *p = page;
-	u64 *pm_buffer;
+	u64 pm_buffer[16];
 	pal_perf_mon_info_u_t pm_info;
 
-	pm_buffer = (u64 *)get_palcall_buffer();
-	if (pm_buffer = 0) return 0;
-
-	if (ia64_pal_perf_mon_info(pm_buffer, &pm_info) != 0) {
-		free_palcall_buffer(pm_buffer);
-		return 0;
-	}
+	if (ia64_pal_perf_mon_info(pm_buffer, &pm_info) != 0) return 0;
 
 #ifdef IA64_PAL_PERF_MON_INFO_BUG
 	/*
@@ -719,8 +673,6 @@
 	p = bitregister_process(p, pm_buffer+12, 256);
 
 	p += sprintf(p, "\n");
-
-	free_palcall_buffer(pm_buffer);
 
 	return p - page;
 }
diff -urN linux-davidm/arch/ia64/kernel/pci-dma.c lia64/arch/ia64/kernel/pci-dma.c
--- linux-davidm/arch/ia64/kernel/pci-dma.c	Fri Sep  8 22:36:14 2000
+++ lia64/arch/ia64/kernel/pci-dma.c	Fri Sep  8 16:24:04 2000
@@ -97,7 +97,8 @@
 	io_tlb_index = 0;
 	io_tlb_orig_addr = alloc_bootmem(io_tlb_nslabs * sizeof(char *));
 
-	printk("Placing software IO TLB between 0x%p - 0x%p\n", io_tlb_start, io_tlb_end);
+	printk("Placing software IO TLB between 0x%p - 0x%p\n",
+	       (void *) io_tlb_start, (void *) io_tlb_end);
 }
 
 /*
diff -urN linux-davidm/arch/ia64/kernel/process.c lia64/arch/ia64/kernel/process.c
--- linux-davidm/arch/ia64/kernel/process.c	Thu Aug 24 08:17:30 2000
+++ lia64/arch/ia64/kernel/process.c	Fri Sep  8 16:24:19 2000
@@ -370,7 +370,6 @@
 void
 do_dump_fpu (struct unw_frame_info *info, void *arg)
 {
-	struct task_struct *fpu_owner = ia64_get_fpu_owner();
 	elf_fpreg_t *dst = arg;
 	int i;
 
@@ -384,10 +383,9 @@
 	for (i = 2; i < 32; ++i)
 		unw_get_fr(info, i, dst + i);
 
-	if ((fpu_owner = current) || (current->thread.flags & IA64_THREAD_FPH_VALID)) {
-		ia64_sync_fph(current);
+	ia64_flush_fph(current);
+	if ((current->thread.flags & IA64_THREAD_FPH_VALID) != 0)
 		memcpy(dst + 32, current->thread.fph, 96*16);
-	}
 }
 
 #endif /* CONFIG_IA64_NEW_UNWIND */
@@ -463,7 +461,6 @@
 	unw_init_running(do_dump_fpu, dst);
 #else
 	struct switch_stack *sw = ((struct switch_stack *) pt) - 1;
-	struct task_struct *fpu_owner = ia64_get_fpu_owner();
 
 	memset(dst, 0, sizeof (dst));	/* don't leak any "random" bits */
 
@@ -472,12 +469,9 @@
 	dst[8] = pt->f8; dst[9] = pt->f9;
 	memcpy(dst + 10, &sw->f10, 22*16);	/* f10-f31 are contiguous */
 
-	if ((fpu_owner = current) || (current->thread.flags & IA64_THREAD_FPH_VALID)) {
-		if (fpu_owner = current) {
-			__ia64_save_fpu(current->thread.fph);
-		}
+	ia64_flush_fph(current);
+	if ((current->thread.flags & IA64_THREAD_FPH_VALID) != 0)
 		memcpy(dst + 32, current->thread.fph, 96*16);
-	}
 #endif
 	return 1;	/* f0-f31 are always valid so we always return 1 */
 }
@@ -520,9 +514,10 @@
 	/* drop floating-point and debug-register state if it exists: */
 	current->thread.flags &= ~(IA64_THREAD_FPH_VALID | IA64_THREAD_DBG_VALID);
 
-	if (ia64_get_fpu_owner() = current) {
+#ifndef CONFIG_SMP
+	if (ia64_get_fpu_owner() = current)
 		ia64_set_fpu_owner(0);
-	}
+#endif
 }
 
 /*
@@ -532,9 +527,10 @@
 void
 exit_thread (void)
 {
-	if (ia64_get_fpu_owner() = current) {
+#ifndef CONFIG_SMP
+	if (ia64_get_fpu_owner() = current)
 		ia64_set_fpu_owner(0);
-	}
+#endif
 }
 
 unsigned long
diff -urN linux-davidm/arch/ia64/kernel/ptrace.c lia64/arch/ia64/kernel/ptrace.c
--- linux-davidm/arch/ia64/kernel/ptrace.c	Thu Aug 24 08:17:30 2000
+++ lia64/arch/ia64/kernel/ptrace.c	Fri Sep  8 16:24:37 2000
@@ -376,7 +376,8 @@
 				ret = 0;
 			} else {
 				if  ((unsigned long) laddr >= (unsigned long) high_memory) {
-					printk("yikes: trying to access long at %p\n", laddr);
+					printk("yikes: trying to access long at %p\n",
+					       (void *) laddr);
 					return -EIO;
 				}
 				ret = *laddr;
@@ -542,18 +543,28 @@
 	child->thread.flags |= IA64_THREAD_KRBS_SYNCED;
 }
 
-/*
- * Ensure the state in child->thread.fph is up-to-date.
- */
 void
-ia64_sync_fph (struct task_struct *child)
+ia64_flush_fph (struct task_struct *child)
 {
-	if (ia64_psr(ia64_task_regs(child))->mfh && ia64_get_fpu_owner() = child) {
-		ia64_psr(ia64_task_regs(child))->mfh = 0;
+	struct ia64_psr *psr = ia64_psr(ia64_task_regs(child));
+
+	if (psr->mfh) {
+		psr->mfh = 0;
+#ifndef CONFIG_SMP
 		ia64_set_fpu_owner(0);
+#endif
 		ia64_save_fpu(&child->thread.fph[0]);
 		child->thread.flags |= IA64_THREAD_FPH_VALID;
 	}
+}
+
+/*
+ * Ensure the state in child->thread.fph is up-to-date.
+ */
+void
+ia64_sync_fph (struct task_struct *child)
+{
+	ia64_flush_fph(child);
 	if (!(child->thread.flags & IA64_THREAD_FPH_VALID)) {
 		memset(&child->thread.fph, 0, sizeof(child->thread.fph));
 		child->thread.flags |= IA64_THREAD_FPH_VALID;
@@ -656,6 +667,9 @@
 		      case PT_B1: case PT_B2: case PT_B3: case PT_B4: case PT_B5:
 			return unw_access_br(&info, (addr - PT_B1)/8 + 1, data, write_access);
 
+		      case PT_AR_EC:
+			return unw_access_ar(&info, UNW_AR_EC, data, write_access);
+
 		      case PT_AR_LC:
 			return unw_access_ar(&info, UNW_AR_LC, data, write_access);
 
@@ -863,6 +877,14 @@
 			else
 				*data = (pt->cr_ipsr & IPSR_READ_MASK);
 			return 0;
+
+		      case PT_AR_EC:
+			if (write_access)
+				sw->ar_pfs = (((*data & 0x3f) << 52)
+					      | (sw->ar_pfs & ~(0x3fUL << 52)));
+			else
+				*data = (sw->ar_pfs >> 52) & 0x3f;
+			break;
 
 		      case PT_R1: case PT_R2: case PT_R3:
 		      case PT_R4: case PT_R5: case PT_R6: case PT_R7:
diff -urN linux-davidm/arch/ia64/kernel/setup.c lia64/arch/ia64/kernel/setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Fri Sep  8 22:36:14 2000
+++ lia64/arch/ia64/kernel/setup.c	Fri Sep  8 16:24:55 2000
@@ -57,6 +57,8 @@
 volatile unsigned long cpu_online_map;
 #endif
 
+unsigned long ia64_iobase;	/* virtual address for I/O accesses */
+
 #define COMMAND_LINE_SIZE	512
 
 char saved_command_line[COMMAND_LINE_SIZE]; /* used in proc filesystem */
@@ -112,6 +114,7 @@
 void __init
 setup_arch (char **cmdline_p)
 {
+	extern unsigned long ia64_iobase;
 	unsigned long max_pfn, bootmap_start, bootmap_size;
 
 	unw_init();
@@ -219,6 +222,13 @@
 	current->processor = 0;
 	cpu_physical_id(0) = hard_smp_processor_id();
 #endif
+	/*
+	 *  Set `iobase' to the appropriate address in region 6
+	 *    (uncached access range)
+	 */
+	__asm__ ("mov %0=ar.k0;;" : "=r"(ia64_iobase));
+	ia64_iobase = __IA64_UNCACHED_OFFSET | (ia64_iobase & ~PAGE_OFFSET);
+
 	cpu_init();	/* initialize the bootstrap CPU */
 
 #ifdef CONFIG_IA64_GENERIC
@@ -408,7 +418,9 @@
 	 * particular setting of these bits.
 	 */
 	ia64_set_dcr(IA64_DCR_DR | IA64_DCR_DK | IA64_DCR_DX | IA64_DCR_PP);
+#ifndef CONFIG_SMP
 	ia64_set_fpu_owner(0);		/* initialize ar.k5 */
+#endif
 
 	atomic_inc(&init_mm.mm_count);
 	current->active_mm = &init_mm;
diff -urN linux-davidm/arch/ia64/kernel/signal.c lia64/arch/ia64/kernel/signal.c
--- linux-davidm/arch/ia64/kernel/signal.c	Fri Sep  8 14:34:53 2000
+++ lia64/arch/ia64/kernel/signal.c	Fri Sep  8 16:25:17 2000
@@ -147,13 +147,12 @@
 	ia64_put_nat_bits(&scr->pt, &scr->sw, nat);	/* restore the original scratch NaT bits */
 #endif
 
-	if (flags & IA64_SC_FLAG_FPH_VALID) {
-		struct task_struct *fpu_owner = ia64_get_fpu_owner();
+	if ((flags & IA64_SC_FLAG_FPH_VALID)) {
+		struct ia64_psr *psr = ia64_psr(ia64_task_regs(current));
 
 		__copy_from_user(current->thread.fph, &sc->sc_fr[32], 96*16);
-		if (fpu_owner = current) {
+		if (!psr->dfh)
 			__ia64_load_fpu(current->thread.fph);
-		}
 	}
 	return err;
 }
@@ -235,9 +234,12 @@
 		goto give_sigsegv;
 
 	sigdelsetmask(&set, ~_BLOCKABLE);
+
 	spin_lock_irq(&current->sigmask_lock);
-	current->blocked = set;
-	recalc_sigpending(current);
+	{
+		current->blocked = set;
+		recalc_sigpending(current);
+	}
 	spin_unlock_irq(&current->sigmask_lock);
 
 	if (restore_sigcontext(sc, scr))
@@ -274,7 +276,6 @@
 static long
 setup_sigcontext (struct sigcontext *sc, sigset_t *mask, struct sigscratch *scr)
 {
-	struct task_struct *fpu_owner = ia64_get_fpu_owner();
 	unsigned long flags = 0, ifs, nat;
 	long err;
 
@@ -286,11 +287,9 @@
 		/* if cr_ifs isn't valid, we got here through a syscall */
 		flags |= IA64_SC_FLAG_IN_SYSCALL;
 	}
-	if ((fpu_owner = current) || (current->thread.flags & IA64_THREAD_FPH_VALID)) {
+	ia64_flush_fph(current);
+	if ((current->thread.flags & IA64_THREAD_FPH_VALID)) {
 		flags |= IA64_SC_FLAG_FPH_VALID;
-		if (fpu_owner = current) {
-			__ia64_save_fpu(current->thread.fph);
-		}
 		__copy_to_user(&sc->sc_fr[32], current->thread.fph, 96*16);
 	}
 
@@ -425,9 +424,11 @@
 
 	if (!(ka->sa.sa_flags & SA_NODEFER)) {
 		spin_lock_irq(&current->sigmask_lock);
-		sigorsets(&current->blocked, &current->blocked, &ka->sa.sa_mask);
-		sigaddset(&current->blocked, sig);
-		recalc_sigpending(current);
+		{
+			sigorsets(&current->blocked, &current->blocked, &ka->sa.sa_mask);
+			sigaddset(&current->blocked, sig);
+			recalc_sigpending(current);
+		}
 		spin_unlock_irq(&current->sigmask_lock);
 	}
 	return 1;
diff -urN linux-davidm/arch/ia64/kernel/smp.c lia64/arch/ia64/kernel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Fri Sep  8 22:36:14 2000
+++ lia64/arch/ia64/kernel/smp.c	Fri Sep  8 16:25:51 2000
@@ -453,14 +453,7 @@
 
         if (--data->prof_counter <= 0) {
 		data->prof_counter = data->prof_multiplier;
-		/*
-		 * update_process_times() expects us to have done irq_enter().
-		 * Besides, if we don't timer interrupts ignore the global
-		 * interrupt lock, which is the WrongThing (tm) to do.
-		 */
-		irq_enter(cpu, 0);
 		update_process_times(user);
-		irq_exit(cpu, 0);
 	}
 }
 
diff -urN linux-davidm/arch/ia64/kernel/smpboot.c lia64/arch/ia64/kernel/smpboot.c
--- linux-davidm/arch/ia64/kernel/smpboot.c	Fri Apr 21 15:21:24 2000
+++ lia64/arch/ia64/kernel/smpboot.c	Wed Dec 31 16:00:00 1969
@@ -1,2 +0,0 @@
-unsigned long cpu_online_map;
-
diff -urN linux-davidm/arch/ia64/kernel/sys_ia64.c lia64/arch/ia64/kernel/sys_ia64.c
--- linux-davidm/arch/ia64/kernel/sys_ia64.c	Wed Aug  2 18:54:02 2000
+++ lia64/arch/ia64/kernel/sys_ia64.c	Fri Sep  8 16:26:15 2000
@@ -147,7 +147,7 @@
 	struct pt_regs *regs = (struct pt_regs *) &stack;
 
 	addr = do_mmap2(addr, len, prot, flags, fd, pgoff);
-	if (!IS_ERR(addr))
+	if (!IS_ERR((void *) addr))
 		regs->r8 = 0;	/* ensure large addresses are not mistaken as failures... */
 	return addr;
 }
@@ -162,26 +162,12 @@
 		return -EINVAL;
 
 	addr = do_mmap2(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
-	if (!IS_ERR(addr))
+	if (!IS_ERR((void *) addr))
 		regs->r8 = 0;	/* ensure large addresses are not mistaken as failures... */
 	return addr;
 }
 
 asmlinkage long
-sys_ioperm (unsigned long from, unsigned long num, int on)
-{
-        printk(KERN_ERR "sys_ioperm(from=%lx, num=%lx, on=%d)\n", from, num, on);
-        return -EIO;
-}
-
-asmlinkage long
-sys_iopl (int level, long arg1, long arg2, long arg3)
-{
-        printk(KERN_ERR "sys_iopl(level=%d)!\n", level);
-        return -ENOSYS;
-}
-
-asmlinkage long
 sys_vm86 (long arg0, long arg1, long arg2, long arg3)
 {
         printk(KERN_ERR "sys_vm86(%lx, %lx, %lx, %lx)!\n", arg0, arg1, arg2, arg3);
@@ -204,7 +190,7 @@
 	unsigned long   addr;
 
 	addr = sys_create_module (name_user, size);
-	if (!IS_ERR(addr))
+	if (!IS_ERR((void *) addr))
 		regs->r8 = 0;	/* ensure large addresses are not mistaken as failures... */
 	return addr;
 }
diff -urN linux-davidm/arch/ia64/kernel/traps.c lia64/arch/ia64/kernel/traps.c
--- linux-davidm/arch/ia64/kernel/traps.c	Fri Sep  8 22:36:14 2000
+++ lia64/arch/ia64/kernel/traps.c	Fri Sep  8 16:26:57 2000
@@ -202,29 +202,44 @@
 static inline void
 disabled_fph_fault (struct pt_regs *regs)
 {
-	struct task_struct *fpu_owner = ia64_get_fpu_owner();
-
 	/* first, clear psr.dfh and psr.mfh: */
 	regs->cr_ipsr &= ~(IA64_PSR_DFH | IA64_PSR_MFH);
-	if (fpu_owner != current) {
-		ia64_set_fpu_owner(current);
+#ifdef CONFIG_SMP
+	if ((current->thread.flags & IA64_THREAD_FPH_VALID) != 0)
+		__ia64_load_fpu(current->thread.fph);
+	else {
+		__ia64_init_fpu();
+		/*
+		 * Set mfh because the state in thread.fph does not match
+		 * the state in the fph partition.
+		 */
+		ia64_psr(regs)->mfh = 1;
+	}
+#else /* !CONFIG_SMP */
+	{
+		struct task_struct *fpu_owner = ia64_get_fpu_owner();
 
-		if (fpu_owner && ia64_psr(ia64_task_regs(fpu_owner))->mfh) {
-			ia64_psr(ia64_task_regs(fpu_owner))->mfh = 0;
-			fpu_owner->thread.flags |= IA64_THREAD_FPH_VALID;
-			__ia64_save_fpu(fpu_owner->thread.fph);
-		}
-		if ((current->thread.flags & IA64_THREAD_FPH_VALID) != 0) {
-			__ia64_load_fpu(current->thread.fph);
-		} else {
-			__ia64_init_fpu();
-			/*
-			 * Set mfh because the state in thread.fph does not match
-			 * the state in the fph partition.
-			 */
-			ia64_psr(regs)->mfh = 1;
+		if (fpu_owner != current) {
+			ia64_set_fpu_owner(current);
+
+			if (fpu_owner && ia64_psr(ia64_task_regs(fpu_owner))->mfh) {
+				ia64_psr(ia64_task_regs(fpu_owner))->mfh = 0;
+				fpu_owner->thread.flags |= IA64_THREAD_FPH_VALID;
+				__ia64_save_fpu(fpu_owner->thread.fph);
+			}
+			if ((current->thread.flags & IA64_THREAD_FPH_VALID) != 0) {
+				__ia64_load_fpu(current->thread.fph);
+			} else {
+				__ia64_init_fpu();
+				/*
+				 * Set mfh because the state in thread.fph does not match
+				 * the state in the fph partition.
+				 */
+				ia64_psr(regs)->mfh = 1;
+			}
 		}
 	}
+#endif /* !CONFIG_SMP */
 }
 
 static inline int
diff -urN linux-davidm/arch/ia64/kernel/unaligned.c lia64/arch/ia64/kernel/unaligned.c
--- linux-davidm/arch/ia64/kernel/unaligned.c	Wed Aug  2 18:54:02 2000
+++ lia64/arch/ia64/kernel/unaligned.c	Fri Sep  8 16:27:16 2000
@@ -278,9 +278,9 @@
 	bspstore = (unsigned long *)regs->ar_bspstore;
 
 	DPRINT(("rse_slot_num=0x%lx\n",ia64_rse_slot_num((unsigned long *)sw->ar_bspstore)));
-	DPRINT(("kbs=%p nlocals=%ld\n", kbs, nlocals));
+	DPRINT(("kbs=%p nlocals=%ld\n", (void *) kbs, nlocals));
 	DPRINT(("bspstore next rnat slot %p\n",
-		ia64_rse_rnat_addr((unsigned long *)sw->ar_bspstore)));
+		(void *) ia64_rse_rnat_addr((unsigned long *)sw->ar_bspstore)));
 	DPRINT(("on_kbs=%ld rnats=%ld\n",
 		on_kbs, ((sw->ar_bspstore-(unsigned long)kbs)>>3) - on_kbs));
 
@@ -292,7 +292,7 @@
 	addr    = slot = ia64_rse_skip_regs(bsp, r1 - 32);
 
 	DPRINT(("ubs_end=%p bsp=%p addr=%p slot=0x%lx\n",
-		ubs_end, bsp, addr, ia64_rse_slot_num(addr)));
+		(void *) ubs_end, (void *) bsp, (void *) addr, ia64_rse_slot_num(addr)));
 
 	ia64_poke(regs, current, (unsigned long)addr, val);
 
@@ -303,7 +303,7 @@
 
 	ia64_peek(regs, current, (unsigned long)addr, &rnats);
 	DPRINT(("rnat @%p = 0x%lx nat=%d rnatval=%lx\n",
-		addr, rnats, nat, rnats &ia64_rse_slot_num(slot)));
+		(void *) addr, rnats, nat, rnats &ia64_rse_slot_num(slot)));
 	
 	if (nat) {
 		rnats |= __IA64_UL(1) << ia64_rse_slot_num(slot);
@@ -312,7 +312,7 @@
 	}
 	ia64_poke(regs, current, (unsigned long)addr, rnats);
 
-	DPRINT(("rnat changed to @%p = 0x%lx\n", addr, rnats));
+	DPRINT(("rnat changed to @%p = 0x%lx\n", (void *) addr, rnats));
 }
 
 
@@ -373,7 +373,7 @@
 	addr    = slot = ia64_rse_skip_regs(bsp, r1 - 32);
 
 	DPRINT(("ubs_end=%p bsp=%p addr=%p slot=0x%lx\n",
-		ubs_end, bsp, addr, ia64_rse_slot_num(addr)));
+		(void *) ubs_end, (void *) bsp, (void *) addr, ia64_rse_slot_num(addr)));
 	
 	ia64_peek(regs, current, (unsigned long)addr, val);
 
@@ -383,7 +383,7 @@
 	addr = ia64_rse_rnat_addr(addr);
 
 	ia64_peek(regs, current, (unsigned long)addr, &rnats);
-	DPRINT(("rnat @%p = 0x%lx\n", addr, rnats));
+	DPRINT(("rnat @%p = 0x%lx\n", (void *) addr, rnats));
 	
 	if (nat)
 		*nat = rnats >> ia64_rse_slot_num(slot) & 0x1;
@@ -437,13 +437,13 @@
 	 * UNAT bit_pos = GR[r3]{8:3} form EAS-2.4
 	 */
 	bitmask   = __IA64_UL(1) << (addr >> 3 & 0x3f);
-	DPRINT(("*0x%lx=0x%lx NaT=%d prev_unat @%p=%lx\n", addr, val, nat, unat, *unat));
+	DPRINT(("*0x%lx=0x%lx NaT=%d prev_unat @%p=%lx\n", addr, val, nat, (void *) unat, *unat));
 	if (nat) {
 		*unat |= bitmask;
 	} else {
 		*unat &= ~bitmask;
 	}
-	DPRINT(("*0x%lx=0x%lx NaT=%d new unat: %p=%lx\n", addr, val, nat, unat,*unat));
+	DPRINT(("*0x%lx=0x%lx NaT=%d new unat: %p=%lx\n", addr, val, nat, (void *) unat,*unat));
 }
 
 #define IA64_FPH_OFFS(r) (r - IA64_FIRST_ROTATING_FR)
diff -urN linux-davidm/arch/ia64/kernel/unwind.c lia64/arch/ia64/kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Fri Sep  8 22:36:14 2000
+++ lia64/arch/ia64/kernel/unwind.c	Fri Sep  8 16:27:28 2000
@@ -268,9 +268,10 @@
 					if ((unsigned long) addr < info->regstk.limit
 					    || (unsigned long) addr >= info->regstk.top)
 					{
-						dprintk("unwind: 0x%p outside of regstk "
+						dprintk("unwind: %p outside of regstk "
 							"[0x%lx-0x%lx)\n", addr,
-							info->regstk.limit, info->regstk.top);
+							(void *) info->regstk.limit,
+							info->regstk.top);
 						return -1;
 					}
 					if ((unsigned long) nat_addr >= info->regstk.top)
@@ -2005,7 +2006,7 @@
 			if (prevt->next = table)
 				break;
 		if (!prevt) {
-			dprintk("unwind: failed to find unwind table %p\n", table);
+			dprintk("unwind: failed to find unwind table %p\n", (void *) table);
 			spin_unlock_irqrestore(&unw.lock, flags);
 			return;
 		}
diff -urN linux-davidm/drivers/acpi/acpiconf.c lia64/drivers/acpi/acpiconf.c
--- linux-davidm/drivers/acpi/acpiconf.c	Fri Sep  8 22:36:14 2000
+++ lia64/drivers/acpi/acpiconf.c	Fri Sep  8 16:28:09 2000
@@ -43,6 +43,7 @@
 	status = acpi_load_firmware_tables ();
 	if (ACPI_FAILURE(status)) {
 		printk ("Acpi cfg:acpi load firmware tables error=0x%x\n", status);
+		acpi_terminate();
 		return status;
 	} else
 		printk ("Acpi cfg:acpi load firmware tables pass\n");
@@ -50,6 +51,7 @@
 	status = acpi_load_namespace ();
 	if (ACPI_FAILURE(status)) {
 		printk ("Acpi cfg:acpi load namespace error=0x%x\n", status);
+		acpi_terminate();
 		return status;
 	} else
 		printk ("Acpi cfg:acpi load namespace pass\n");
@@ -217,7 +219,7 @@
 		switch (ext_obj->type) {
 		case ACPI_TYPE_NUMBER:
 			busnum = (NATIVE_UINT) ext_obj->number.value;
-			next_busnum = busnum;
+			next_busnum = busnum + 1;
 			break;
 		default:
 			printk("Acpi cfg:_BBN object type incorrect: set busnum to %ld\n ", next_busnum);
@@ -301,7 +303,7 @@
 	)
 {
 	struct pci_vector_struct	*pvec;
-	PCI_ROUTING_TABLE		**pprts, *prt;
+	PCI_ROUTING_TABLE		**pprts, *prt, *prtf;
 	int				nvec = 0;
 	int				i;
 
@@ -309,7 +311,7 @@
 	pprts = (PCI_ROUTING_TABLE **)prts;
 
 	for ( i = 0; i < PCI_MAX_BUS; i++) {
-		prt = *pprts++;
+		prt = prtf = *pprts++;
 		if (prt) {
 			for ( ; prt->length > 0; nvec++) {
 				prt = (PCI_ROUTING_TABLE *) ((NATIVE_UINT)prt + (NATIVE_UINT)prt->length);
@@ -340,7 +342,7 @@
 				prt = (PCI_ROUTING_TABLE *) ((NATIVE_UINT)prt + (NATIVE_UINT)prt->length);
 				prt = (PCI_ROUTING_TABLE *) ROUND_UP_TO_4BYTES(prt);
 			}
-			acpi_os_free((void *)prt);
+			acpi_os_free((void *)prtf);
 		}
 	}
 
diff -urN linux-davidm/drivers/char/efirtc.c lia64/drivers/char/efirtc.c
--- linux-davidm/drivers/char/efirtc.c	Thu Aug 24 08:17:32 2000
+++ lia64/drivers/char/efirtc.c	Fri Sep  8 16:28:26 2000
@@ -249,7 +249,7 @@
 
 			convert_from_efi_time(&eft, &wtime);
 
-			return copy_to_user((void *)&ewp->time, &wtime, sizeof(struct rtc_time));
+			return copy_to_user((void *)&ewp->time, &wtime, sizeof(struct rtc_time)) ? - EFAULT : 0;
 	}
 	return -EINVAL;
 }
diff -urN linux-davidm/drivers/net/eepro100.c lia64/drivers/net/eepro100.c
--- linux-davidm/drivers/net/eepro100.c	Fri Sep  8 22:36:14 2000
+++ lia64/drivers/net/eepro100.c	Fri Sep  8 16:29:55 2000
@@ -25,6 +25,8 @@
 		Disabled FC and ER, to avoid lockups when when we get FCP interrupts.
 	2000 Jul 17 Goutham Rao <goutham.rao@intel.com>
 		PCI DMA API fixes, adding pci_dma_sync_single calls where neccesary
+    2000 Aug 31 David Mosberger <davidm@hpl.hp.com>
+	    RX_ALIGN support: enables rx DMA without causing unaligned accesses.
 */
 
 static const char *version @@ -42,17 +44,16 @@
 static int rxdmacount = 0;
 
 #ifdef __ia64__
-/*
- * Bug: this driver may generate unaligned accesses when not copying
- * an incoming packet.  Setting rx_copybreak to a large value force a
- * copy and prevents unaligned accesses.
- */
-static int rx_copybreak = 0x10000;
+  /* align rx buffers to 2 bytes so that IP header is aligned */
+# define RX_ALIGN
+# define RxFD_ALIGNMENT		__attribute__ ((aligned (2), packed))
 #else
+# define RxFD_ALIGNMENT
+#endif
+
 /* Set the copy breakpoint for the copy-only-tiny-buffer Rx method.
    Lower values use more memory, but are faster. */
 static int rx_copybreak = 200;
-#endif
 
 /* Maximum events (Rx packets, etc.) to handle at each interrupt. */
 static int max_interrupt_work = 20;
@@ -449,7 +450,7 @@
 	u32 link;					/* struct RxFD * */
 	u32 rx_buf_addr;			/* void * */
 	u32 count;
-};
+} RxFD_ALIGNMENT;
 
 /* Selected elements of the Tx/RxFD.status word. */
 enum RxFD_bits {
@@ -1216,6 +1217,9 @@
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		struct sk_buff *skb;
 		skb = dev_alloc_skb(PKT_BUF_SZ + sizeof(struct RxFD));
+#ifdef RX_ALIGN
+		skb_reserve(skb, 2);	/* Align IP on 16 byte boundary */
+#endif
 		sp->rx_skbuff[i] = skb;
 		if (skb = NULL)
 			break;			/* OK.  Just initially short of Rx bufs. */
@@ -1665,6 +1669,9 @@
 	struct sk_buff *skb;
 	/* Get a fresh skbuff to replace the consumed one. */
 	skb = dev_alloc_skb(PKT_BUF_SZ + sizeof(struct RxFD));
+#ifdef RX_ALIGN
+	skb_reserve(skb, 2);	/* Align IP on 16 byte boundary */
+#endif
 	sp->rx_skbuff[entry] = skb;
 	if (skb = NULL) {
 		sp->rx_ringp[entry] = NULL;
diff -urN linux-davidm/drivers/scsi/qla1280.c lia64/drivers/scsi/qla1280.c
--- linux-davidm/drivers/scsi/qla1280.c	Fri Sep  8 22:36:14 2000
+++ lia64/drivers/scsi/qla1280.c	Fri Sep  8 16:31:05 2000
@@ -1,162 +1,72 @@
 /********************************************************************************
- *                  QLOGIC LINUX SOFTWARE
- *
- * QLogic ISP1x80/1x160 device driver for Linux 2.3.x (redhat 6.X).
- *
- * COPYRIGHT (C) 1999-2000 QLOGIC CORPORATION    
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the Qlogic's Linux Software License. See below.
- *
- * This program is WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- *
- * 1. Redistribution's or source code must retain the above copyright
- *    notice, this list of conditions, and the following disclaimer,
- *    without modification, immediately at the beginning of the file.
- * 2. The name of the author may not be used to endorse or promote products
- *    derived from this software without specific prior written permission.
- *
- ********************************************************************************/
- 
-/*****************************************************************************************
-			QLOGIC CORPORATION SOFTWARE
-           "GNU" GENERAL PUBLIC LICENSE
-    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION
-                 AND MODIFICATION
-
-This GNU General Public License ("License") applies solely to QLogic Linux 
-Software ("Software") and may be distributed under the terms of this License.  
- 
-1. You may copy and distribute verbatim copies of the Software's source code as 
-you receive it, in any medium, provided that you conspicuously and appropriately 
-publish on each copy an appropriate copyright notice and disclaimer of warranty;
-keep intact all the notices that refer to this License and to the absence of any
-warranty; and give any other recipients of the Software a copy of this License along
-with the Software. 
-
-You may charge a fee for the physical act of transferring a copy, and you may at your
-option offer warranty protection in exchange for a fee.
- 
-2. You may modify your copy or copies of the Software or any portion of it, thus forming
-a work based on the Software, and copy and distribute such modifications or work under
-the terms of Section 1 above, provided that you also meet all of these conditions:
- 
-* a) You must cause the modified files to carry prominent notices stating that you
-changed the files and the date of any change. 
-
-* b) You must cause any work that you distribute or publish that in whole or in part
-contains or is derived from the Software or any part thereof, to be licensed as a
-whole at no charge to all third parties under the terms of this License. 
-
-* c) If the modified Software normally reads commands interactively when run, you
-must cause it, when started running for such interactive use in the most ordinary way,
-to print or display an announcement including an appropriate copyright notice and a 
-notice that there is no warranty (or else, saying that you provide a warranty) and that
-users may redistribute the Software under these conditions, and telling the user how to
-view a copy of this License. (Exception:if the Software itself is interactive but does 
-not normally print such an announcement, your work based on the Software is not required
-to print an announcement.) 
-
-These requirements apply to the modified work as a whole. If identifiable sections of
-that work are not derived from the Software, and can be reasonably considered independent
-and separate works in themselves, then this License, and its terms, do not apply to those
-sections when you distribute them as separate works. But when you distribute the same
-sections as part of a whole which is a work based on the Software, the distribution of the
-whole must be on the terms of this License, whose permissions for other licensees extend
-to the entire whole, and thus to each and every part regardless of who wrote it. 
-
-3. You may copy and distribute the Software (or a work based on it, under Section 2) in 
-object code or executable form under the terms of Sections 1 and 2 above provided that
-you also do one of the following: 
-
-* a) Accompany it with the complete corresponding machine-readable source code, which must
-be distributed under the terms of Sections 1 and 2 above on a medium customarily used for
-software interchange; or, 
-
-* b) Accompany it with a written offer, valid for at least three years, to give any third
-party, for a charge no more than your cost of physically performing source distribution,
-a complete machine-readable copy of the corresponding source code, to be distributed under
-the terms of Sections 1 and 2 above on a medium customarily used for software interchange;
-or,
-
-* c) Accompany it with the information you received as to the offer to distribute 
-corresponding source code. (This alternative is allowed only for noncommercial distribution
-and only if you received the Software in object code or executable form with such an offer,
-in accord with Subsection b above.) 
-
-The source code for a work means the preferred form of the work for making modifications
-to it. For an executable work, complete source code means all the source code for all 
-modules it contains, plus any associated interface definition files, plus the scripts used
-to control compilation and installation of the executable.     
-
-If distribution of executable or object code is made by offering access to copy from a 
-designated place, then offering equivalent access to copy the source code from the same
-place counts as distribution of the source code, even though third parties are not 
-compelled to copy the source along with the object code. 
-
-4. You may not copy, modify, sublicense, or distribute the Software except as expressly 
-provided under this License. Any attempt otherwise to copy, modify, sublicense or 
-distribute the Software is void, and will automatically terminate your rights under this
-License. However, parties who have received copies, or rights, from you under this License
-will not have their licenses terminated so long as such parties remain in full compliance. 
-
-5. This license grants you world wide, royalty free non-exclusive rights to modify or 
-distribute the Software or its derivative works. These actions are prohibited by law 
-if you do not accept this License. Therefore, by modifying or distributing the Software
-(or any work based on the Software), you indicate your acceptance of this License to do
-so, and all its terms and conditions for copying, distributing or modifying the Software
-or works based on it.
- 
-6. Each time you redistribute the Software (or any work based on the Software), the 
-recipient automatically receives a license from the original licensor to copy, distribute
-or modify the Software subject to these terms and conditions. You may not impose any 
-further restrictions on the recipients' exercise of the rights granted herein. You are
-not responsible for enforcing compliance by third parties to this License.
- 
-7. If, as a consequence of a court judgment or allegation of patent infringement or for
-any other reason (not limited to patent issues), conditions are imposed on you 
-(whether by court order, agreement or otherwise) that contradict the conditions of this
-License, they do not excuse you from the conditions of this License. If you cannot 
-distribute so as to satisfy simultaneously your obligations under this License 
-and any other pertinent obligations, then as a consequence you may not distribute the
-Software at all.    
-
-If any portion of this section is held invalid or unenforceable under any particular 
-circumstance, the balance of the section is intended to apply and the section as a whole
-is intended to apply in other circumstances. 
-NO WARRANTY
-
-11. THE SOFTWARE IS PROVIDED WITHOUT A WARRANTY OF ANY KIND. THERE IS NO 
-WARRANTY FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. 
-EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR 
-OTHER PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, 
-EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
-WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
-ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH YOU. 
-SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL 
-NECESSARY SERVICING, REPAIR OR CORRECTION.
- 
-12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING 
-WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR 
-REDISTRIBUTE THE SOFTWARE AS PERMITTED ABOVE, BE LIABLE TO YOU FOR 
-DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL 
-DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING 
-BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR 
-LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO 
-OPERATE WITH ANY OTHER SOFTWARES), EVEN IF SUCH HOLDER OR OTHER PARTY HAS 
-BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. 
-END OF TERMS AND CONDITIONS 
-
-*******************************************************************************************/ 
+*                  QLOGIC LINUX SOFTWARE
+*
+* QLogic  QLA1280 (Ultra2)  and  QLA12160 (Ultra3) SCSI driver
+* Copyright (C) 2000 Qlogic Corporation 
+* (www.qlogic.com)
+*
+* This program is free software; you can redistribute it and/or modify it
+* under the terms of the GNU General Public License as published by the
+* Free Software Foundation; either version 2, or (at your option) any
+* later version.
+*
+* This program is distributed in the hope that it will be useful, but
+* WITHOUT ANY WARRANTY; without even the implied warranty of
+* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+* General Public License for more details.
+**
+******************************************************************************/
 
 /****************************************************************************
     Revision History:
-    Rev. 3.00       Jan 17, 1999    DG  Qlogic
+    Rev. 3.16 Beta  August 25, 2000   BN  Qlogic
+        - Corrected 64 bit addressing issue on IA-64
+          where the upper 32 bits were not properly
+          passed to the RISC engine.
+    Rev. 3.15 Beta  August 22, 2000   BN  Qlogic
+        - Modified qla1280_setup_chip to properly load
+          ISP firmware for greater that 4 Gig memory on IA-64
+    Rev. 3.14 Beta  August 16, 2000   BN  Qlogic
+        - Added setting of dma_mask to full 64 bit
+          if flags.enable_64bit_addressing is set in NVRAM
+    Rev. 3.13 Beta  August 16, 2000   BN  Qlogic
+        - Use new PCI DMA mapping APIs for 2.4.x kernel
+    Rev. 3.12       July 18, 2000    Redhat & BN Qlogic
+        - Added check of pci_enable_device to detect() for 2.3.x
+        - Use pci_resource_start() instead of 
+          pdev->resource[0].start in detect() for 2.3.x
+        - Updated driver version
+    Rev. 3.11       July 14, 2000    BN  Qlogic
+	- Updated SCSI Firmware to following versions:
+	  qla1x80:   8.13.08
+	  qla1x160:  10.04.08
+	- Updated driver version to 3.11
+    Rev. 3.10    June 23, 2000   BN Qlogic
+        - Added filtering of AMI SubSys Vendor ID devices 
+    Rev. 3.9 
+        - DEBUG_QLA1280 undefined and  new version  BN Qlogic 
+    Rev. 3.08b      May 9, 2000    MD Dell
+        - Added logic to check against AMI subsystem vendor ID
+	Rev. 3.08       May 4, 2000    DG  Qlogic
+        - Added logic to check for PCI subsystem ID.
+	Rev. 3.07       Apr 24, 2000    DG & BN  Qlogic
+	   - Updated SCSI Firmware to following versions:
+	     qla12160:   10.01.19
+		 qla1280:     8.09.00
+	Rev. 3.06       Apr 12, 2000    DG & BN  Qlogic
+	   - Internal revision; not released
+    Rev. 3.05       Mar 28, 2000    DG & BN  Qlogic
+       - Edit correction for virt_to_bus and PROC.
+    Rev. 3.04       Mar 28, 2000    DG & BN  Qlogic
+       - Merge changes from ia64 port.
+    Rev. 3.03       Mar 28, 2000    BN  Qlogic
+       - Increase version to reflect new code drop with compile fix
+         of issue with inclusion of linux/spinlock for 2.3 kernels
+    Rev. 3.02       Mar 15, 2000    BN  Qlogic
+       - Merge qla1280_proc_info from 2.10 code base
+    Rev. 3.01       Feb 10, 2000    BN  Qlogic
+       - Corrected code to compile on a 2.2.x kernel.
+    Rev. 3.00       Jan 17, 2000    DG  Qlogic
 	   - Added 64-bit support.
     Rev. 2.07       Nov 9, 1999     DG  Qlogic
 	   - Added new routine to set target parameters for ISP12160. 
@@ -183,11 +93,12 @@
 *****************************************************************************/
 
 
+#include <linux/config.h>       
 #ifdef MODULE
 #include <linux/module.h>
 #endif
 
-#define QLA1280_VERSION      " 3.00-Beta"
+#define QLA1280_VERSION      "3.16 Beta"
 
 #include <stdarg.h>
 #include <asm/io.h>
@@ -207,8 +118,16 @@
 #include <linux/proc_fs.h>
 #include <linux/blk.h>
 #include <linux/tqueue.h>
-/* MRS #include <linux/tasks.h> */
+#ifndef KERNEL_VERSION
+#  define KERNEL_VERSION(x,y,z) (((x)<<16)+((y)<<8)+(z))
+#endif
+ 
+#if LINUX_VERSION_CODE > KERNEL_VERSION(2,3,18)
+#include <linux/pci_ids.h>
+#endif
+
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
+#include <linux/tasks.h>
 # include <linux/bios32.h>
 #endif
 #include "sd.h"
@@ -216,23 +135,16 @@
 #include "hosts.h"
 #define UNIQUE_FW_NAME
 #include "qla1280.h"
-#include "ql12160_fw.h"                     /* ISP RISC code */
+#include "ql12160_fw.h"   /* ISP RISC codes */
 #include "ql1280_fw.h"
 
 #include <linux/stat.h>
-#include <linux/malloc.h>        /* for kmalloc() */
-
-
-#ifndef KERNEL_VERSION
-#  define KERNEL_VERSION(x,y,z) (((x)<<16)+((y)<<8)+(z))
-#endif
-
+#include <linux/malloc.h> 
 
 /*
  * Compile time Options: 
  *            0 - Disable and 1 - Enable 
  */
-#define  QLA1280_64BIT_SUPPORT         1   /* 64-bit Support */
 #define  QL1280_TARGET_MODE_SUPPORT    0   /* Target mode support */
 #define  WATCHDOGTIMER                 0
 #define  MEMORY_MAPPED_IO              0
@@ -244,15 +156,16 @@
 #define  AUTO_ESCALATE_ABORT           0   /* Automatically escalate aborts */
 #define  STOP_ON_ERROR                 0   /* Stop on aborts and resets  */
 #define  STOP_ON_RESET                 0 
-#define  STOP_ON_ABORT                 0 
-#undef   DYNAMIC_MEM_ALLOC
-
-#define  DEBUG_QLA1280                 0    /* Debugging  */
-/* #define CHECKSRBSIZE */
+#define  STOP_ON_ABORT                 0
+ 
+#define  DEBUG_QLA1280                 0
 
-/*
- * These macros to assist programming
- */
+/*************** 64 BIT PCI DMA ******************************************/
+#define  FORCE_64BIT_PCI_DMA           0 /* set to one for testing only  */
+/* Applicable to 64 version of the Linux 2.4.x and above only            */
+/* NVRAM bit nv->cntr_flags_1.enable_64bit_addressing should be used for */
+/* administrator control of PCI DMA width size per system configuration  */
+/*************************************************************************/  
 
 #define	BZERO(ptr, amt)		memset(ptr, 0, amt)
 #define	BCOPY(src, dst, amt)	memcpy(dst, src, amt)
@@ -260,19 +173,23 @@
 #define	KMFREE(ip,siz)	kfree((ip))
 #define	SYS_DELAY(x)		udelay(x);barrier()
 #define QLA1280_DELAY(sec)  mdelay(sec * 1000)
-#define VIRT_TO_BUS(a) virt_to_bus((a))
-#if  QLA1280_64BIT_SUPPORT
+
+/* 3.16 */
+#define pci_dma_lo32(a) (a & 0xffffffff)
+#define pci_dma_hi32(a) ((a >> 32) & 0xffffffff)
+
+#define  VIRT_TO_BUS(a)  virt_to_bus(((void *)a))
+
 #if  BITS_PER_LONG <= 32
-#define  VIRT_TO_BUS_LOW(a) (uint32_t)virt_to_bus((a))
+#define  VIRT_TO_BUS_LOW(a) (uint32_t)virt_to_bus(((void *)a))
 #define  VIRT_TO_BUS_HIGH(a) (uint32_t)(0x0)
 #else
-#define  VIRT_TO_BUS_LOW(a) (uint32_t)(0xffffffff & virt_to_bus((a)))
-#define  VIRT_TO_BUS_HIGH(a) (uint32_t)(0xffffffff & (virt_to_bus((a))>>32))
+#define  VIRT_TO_BUS_LOW(a) (uint32_t)(0xffffffff & virt_to_bus((void *)(a)))
+#define  VIRT_TO_BUS_HIGH(a) (uint32_t)(0xffffffff & (virt_to_bus((void *)(a))>>32))
 #endif
-#endif  /* QLA1280_64BIT_SUPPORT */
 
-#define STATIC     
 
+#define STATIC     
 #define NVRAM_DELAY() udelay(500) /* 2 microsecond delay */
 void qla1280_device_queue_depth(scsi_qla_host_t *, Scsi_Device *);
 
@@ -285,11 +202,11 @@
 #define  LSB(x)          (uint8_t)(x)
 
 #if  BITS_PER_LONG <= 32
-#define  LS_64BITS(x) (uint32_t)(x)
-#define  MS_64BITS(x) (uint32_t)(0x0)
+#define  LS_64BITS(x) (uint32_t)((unsigned long) x)
+#define  MS_64BITS(x) (uint32_t)((unsigned long) 0x0)
 #else
-#define  LS_64BITS(x) (uint32_t)(0xffffffff & (x))
-#define  MS_64BITS(x) (uint32_t)(0xffffffff & ((x)>>32) )
+#define  LS_64BITS(x) (uint32_t)(0xffffffff & ((unsigned long)x))
+#define  MS_64BITS(x) (uint32_t)(0xffffffff & (((unsigned long)x)>>32) )
 #endif
 
 /*
@@ -300,9 +217,6 @@
 STATIC void   qla1280_putq_t(scsi_lu_t *, srb_t *);
 STATIC void   qla1280_done_q_put(srb_t *, srb_t **, srb_t **);
 STATIC void qla1280_select_queue_depth(struct Scsi_Host *, Scsi_Device *);
-#ifdef  QLA1280_UNUSED 
-static void qla1280_dump_regs(struct Scsi_Host *host);
-#endif
 #if  STOP_ON_ERROR 
 static void qla1280_panic(char *, struct Scsi_Host *host);
 #endif
@@ -313,9 +227,6 @@
 STATIC void qla1280_removeq(scsi_lu_t *q, srb_t *sp);
 STATIC void qla1280_mem_free(scsi_qla_host_t *ha);
 void qla1280_do_dpc(void *p);
-#ifdef  QLA1280_UNUSED 
-static void qla1280_set_flags(char * s);
-#endif
 static char	*qla1280_get_token(char *, char *);
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,0)
 STATIC inline void mdelay(int);
@@ -339,9 +250,7 @@
 STATIC uint8_t   qla1280_device_reset(scsi_qla_host_t *, uint8_t, uint32_t);
 STATIC uint8_t   qla1280_abort_device(scsi_qla_host_t *, uint8_t, uint32_t, uint32_t);
 STATIC uint8_t   qla1280_abort_command(scsi_qla_host_t *, srb_t *),
-#if  QLA1280_64BIT_SUPPORT
                  qla1280_64bit_start_scsi(scsi_qla_host_t *, srb_t *),
-#endif
                  qla1280_32bit_start_scsi(scsi_qla_host_t *, srb_t *),
                  qla1280_abort_isp(scsi_qla_host_t *);
 STATIC void      qla1280_nv_write(scsi_qla_host_t *, uint16_t),
@@ -374,12 +283,12 @@
                  qla1280_notify_ack(scsi_qla_host_t *, notify_entry_t *),
                  qla1280_immed_notify(scsi_qla_host_t *, notify_entry_t *),
                  qla1280_accept_io(scsi_qla_host_t *, ctio_ret_entry_t *),
-#if  QLA1280_64BIT_SUPPORT
-                 qla1280_64bit_continue_io(scsi_qla_host_t *, atio_entry_t *, uint32_t,
-                                     paddr32_t *),
-#endif
-                 qla1280_32bit_continue_io(scsi_qla_host_t *, atio_entry_t *, uint32_t,
-                                     paddr32_t *),
+                 qla1280_64bit_continue_io(scsi_qla_host_t *, 
+                                 atio_entry_t *, uint32_t,
+                                 paddr32_t *),
+                 qla1280_32bit_continue_io(scsi_qla_host_t *, 
+                                 atio_entry_t *, uint32_t,
+                                 paddr32_t *),
                  qla1280_atio_entry(scsi_qla_host_t *, atio_entry_t *),
                  qla1280_notify_entry(scsi_qla_host_t *, notify_entry_t *);
 #endif  /* QLA1280_TARGET_MODE_SUPPORT */
@@ -400,7 +309,7 @@
                 qla1280_dump_buffer(caddr_t, uint32_t);
 
 char          debug_buff[80];
-#if DEBUG_QLA1280 
+#if  DEBUG_QLA1280 
 STATIC uint8_t ql_debug_print = 1;
 #else
 STATIC uint8_t ql_debug_print = 0;
@@ -426,6 +335,22 @@
 
 #endif
 
+
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
+/*
+ * Our directory Entry in /proc/scsi for the user to 
+ * access the driver. 
+ */
+/* Need to add in proc_fs.h     PROC_SCSI_QL1280 */
+#define PROC_SCSI_QL1280  PROC_SCSI_QLOGICISP
+
+struct proc_dir_entry proc_scsi_qla1280 = {
+    PROC_SCSI_QL1280, 7, "qla1280",                           
+    S_IFDIR | S_IRUGO | S_IXUGO, 2,
+    0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL
+};
+#endif
+
 /* We use the Scsi_Pointer structure that's included with each command
  * SCSI_Cmnd as a scratchpad for our SRB.
  *
@@ -471,7 +396,7 @@
    unsigned char   *fwver;          /* Ptr to F/W version array    */
 } qla_boards_t;
 
-struct _qlaboards   QLBoardTbl[NUM_OF_ISP_DEVICES] = 
+struct _qlaboards   QL1280BoardTbl[NUM_OF_ISP_DEVICES] = 
 {
    /* Name ,  Board PCI Device ID,         Number of ports */
   {"QLA1080 ", QLA1080_DEVICE_ID,           1,        
@@ -567,152 +492,149 @@
  *
  * Returns:
  *************************************************************************/
-#ifdef QLA1280_PROFILE
-#define	PROC_BUF	(&qla1280_buffer[size])
-#define LUN_ID       (targ_lun>>(MAX_T_BITS+MAX_L_BITS)),((targ_lun>>MAX_L_BITS)&0xf), targ_lun&0x7 
-#endif
+#define	PROC_BUF	(&qla1280_buffer[len])
 int
-qla1280_proc_info ( char *buffer, char **start, off_t offset, int length, 
-                    int hostno, int inout)
-{
-#ifdef QLA1280_PROFILE
+qla1280_proc_info( char *buffer, char **start, off_t offset, int length, 
+                    int hostno, int inout) {
+#if QLA1280_PROFILE
   struct Scsi_Host *host;
   scsi_qla_host_t *ha;
   int    size = 0;
-  int  targ_lun;
   scsi_lu_t  *up;
-  int   no_devices;
+    int   len = 0;
+    qla_boards_t   *bdp; 
+    uint32_t        b, t, l;
 
-  printk("Entering proc_info 0x%p,0x%lx,0x%x,0x%x\n",buffer,offset,length,hostno);
   host = NULL;
-  /* find the host they want to look at */
-  for(ha=qla1280_hostlist; (ha != NULL) && ha->host->host_no != hostno; ha=ha->next)
+    
+    /* Find the host that was specified */
+    for( ha=qla1280_hostlist; (ha != NULL) && ha->host->host_no != hostno; ha=ha->next )
     ;
 
-  if (!ha)
-  {
-    size += sprintf(buffer, "Can't find adapter for host number %d\n", hostno);
-    if (size > length)
-    {
+    /* if host wasn't found then exit */
+    if( !ha ) {
+        size = sprintf(buffer, "Can't find adapter for host number %d\n", hostno);
+        if( size > length ) {
       return (size);
-    }
-    else
-    {
-      return (length);
+        } else {
+            return (0);
     }
   }
 
   host = ha->host;
-  if (inout = TRUE) /* Has data been written to the file? */ 
-  {
-    return (qla1280_set_info(buffer, length, host));
-  }
 
-  /* compute number of active devices */
-  no_devices = 0;
-  for (targ_lun = 0; targ_lun < MAX_EQ; targ_lun++)
+    if( inout = TRUE ) /* Has data been written to the file? */
   {
-          if( (up = ha->dev[targ_lun]) = NULL )
-              continue;
-          no_devices++;
+        printk("qla1280_proc: has data been written to the file. \n");
+        return (qla1280_set_info(buffer, length, host));
   }
-  /* size = 112 * no_devices; */
-  size = 4096;
-  /* round up to the next page */
   
   /* 
    * if our old buffer is the right size use it otherwise 
    * allocate a new one.
    */
-  if (qla1280_buffer_size != size)
-  {
+    size = 4096;  /* get a page */
+    if( qla1280_buffer_size != size ) {
     /* deallocate this buffer and get a new one */
-    if (qla1280_buffer != NULL) 
-    {
+        if( qla1280_buffer != NULL ) {
       kfree(qla1280_buffer);
       qla1280_buffer_size = 0;
     }
     qla1280_buffer = kmalloc(size, GFP_KERNEL);
   }
-  if (qla1280_buffer = NULL)
-  {
+    if( qla1280_buffer = NULL ) {
     size = sprintf(buffer, "qla1280 - kmalloc error at line %d\n",
         __LINE__);
     return size;
   }
+    /* save the size of our buffer */
   qla1280_buffer_size = size;
 
-  size = 0;
-  size += sprintf(PROC_BUF, "Qlogic 1280/1080 SCSI driver version: ");   /* 43 bytes */
-  size += sprintf(PROC_BUF, "%5s, ", QLA1280_VERSION);                         /* 5        */
-  size += sprintf(PROC_BUF, "Qlogic Firmware version: ");                     /* 25       */
-  size += sprintf(PROC_BUF, "%2d.%2d.%2d",_firmware_version[0],           /* 8        */
-                                          ql12_firmware_version[1],
-                                          ql12_firmware_version[2]);
-  size += sprintf(PROC_BUF, "\n");                                             /* 1       */
-                           
-  size += sprintf(PROC_BUF, "SCSI Host Adapter Information: %s\n", QLBoardTbl[ha->devnum].bdName);
-  size += sprintf(PROC_BUF, "Request Queue = 0x%lx, Response Queue = 0x%lx\n",
+    /* start building the print buffer */ 
+    bdp = &QL1280BoardTbl[ha->devnum];
+    size =  sprintf(PROC_BUF,
+            "QLogic PCI to SCSI Adapter for ISP 1280/12160:\n"
+            "        Firmware version: %2d.%02d.%02d, Driver version %s\n",                bdp->fwver[0], bdp->fwver[1], bdp->fwver[2], QLA1280_VERSION);
+
+    len += size;
+
+    size = sprintf(PROC_BUF, "SCSI Host Adapter Information: %s\n", bdp->bdName);
+    len += size;
+    size = sprintf(PROC_BUF, "Request Queue = 0x%lx, Response Queue = 0x%lx\n",
                         ha->request_dma,
                         ha->response_dma);
-  size += sprintf(PROC_BUF, "Request Queue count= 0x%x, Response Queue count= 0x%x\n",
+    len += size;
+    size = sprintf(PROC_BUF, "Request Queue count= 0x%lx, Response Queue count= 0x%lx\n",
                         REQUEST_ENTRY_CNT,
                         RESPONSE_ENTRY_CNT);
-  size += sprintf(PROC_BUF,"Number of pending commands = 0x%lx\n", ha->actthreads);
-  size += sprintf(PROC_BUF,"Number of queued commands = 0x%lx\n", ha->qthreads);
-  size += sprintf(PROC_BUF,"Number of free request entries = %d\n",ha->req_q_cnt);
-  size += sprintf(PROC_BUF, "\n");                                             /* 1       */
+    len += size; 
+    size = sprintf(PROC_BUF, "Number of pending commands = 0x%lx\n", ha->actthreads);
+    len += size;
+    size = sprintf(PROC_BUF, "Number of queued commands = 0x%lx\n", ha->qthreads);
+    len += size;
+    size = sprintf(PROC_BUF, "Number of free request entries = %d\n",ha->req_q_cnt);
+    len += size;
+    size = sprintf(PROC_BUF, "\n");                                             /* 1       */
+    len += size;
                         
-  size += sprintf(PROC_BUF, "Attached devices:\n");
+    size = sprintf(PROC_BUF, "SCSI device Information:\n");
+    len += size; 
   /* scan for all equipment stats */ 
-  for (targ_lun = 0; targ_lun < MAX_EQ; targ_lun++)
-  {
-      if( (up = ha->dev[targ_lun]) = NULL )
+	for (b = 0; b < MAX_BUSES; b++) 
+	for (t = 0; t < MAX_TARGETS; t++) {
+        for( l = 0; l < MAX_LUNS; l++ ) {
+           up = (scsi_lu_t *) LU_Q(ha, b, t, l);
+           if( up = NULL ) 
            continue;
-      if( up->io_cnt = 0 )
-      {
-          size += sprintf(PROC_BUF,"(%2d:%2d:%2d) No stats\n",LUN_ID);
+           /* unused device/lun */
+           if( up->io_cnt = 0 || up->io_cnt < 2 )
            continue;
-      }
       /* total reads since boot */
       /* total writes since boot */
       /* total requests since boot  */
-      size += sprintf(PROC_BUF, "Total requests %ld,",up->io_cnt);
+           size = sprintf(PROC_BUF, "(%2d:%2d:%2d): Total reqs %ld,",b,t,l,up->io_cnt);
+           len += size;
       /* current number of pending requests */
-      size += sprintf(PROC_BUF, "(%2d:%2d:%2d) pending requests %d,",LUN_ID,up->q_outcnt);
+           size = sprintf(PROC_BUF, " Pend reqs %d,",up->q_outcnt);
+           len += size;
+#if 0
       /* avg response time */
-      size += sprintf(PROC_BUF, "Avg response time %ld%%,",(up->resp_time/up->io_cnt)*100);
+           size = sprintf(PROC_BUF, " Avg resp time %ld%%,",(up->resp_time/up->io_cnt)*100);
+           len += size;
       
       /* avg active time */
-      size += sprintf(PROC_BUF, "Avg active time %ld%%\n",(up->act_time/up->io_cnt)*100);
+           size = sprintf(PROC_BUF, " Avg active time %ld%%\n",(up->act_time/up->io_cnt)*100);
+#else
+           size = sprintf(PROC_BUF, "\n");
+#endif
+           len += size; 
+        }
+        if( len >= qla1280_buffer_size ) 
+          break;
   }
 
-  if (size >= qla1280_buffer_size)
-  {
+    if( len >= qla1280_buffer_size ) {
     printk(KERN_WARNING "qla1280: Overflow buffer in qla1280_proc.c\n");
   }
 
-  if (offset > size - 1)
-  {
+    if( offset > len - 1 ) {
     kfree(qla1280_buffer);
     qla1280_buffer = NULL;
     qla1280_buffer_size = length = 0;
     *start = NULL;
-  }
-  else
-  {
+    } else {
     *start = &qla1280_buffer[offset];   /* Start of wanted data */
-    if (size - offset < length)
-    {
-      length = size - offset;
+        if( len - offset < length ) {
+            length = len - offset;
     }
   }
+    return (length);
+#else
+    return (0);
 #endif
 
-  return (length);
 }
 
-
 /**************************************************************************
  * qla1280_detect
  *    This routine will probe for Qlogic 1280 SCSI host adapters.
@@ -735,6 +657,9 @@
     scsi_qla_host_t *ha, *cur_ha;
     struct _qlaboards  *bdp;
     int i, j;
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
+    unsigned short subsys;
+#endif
 #if LINUX_VERSION_CODE <= KERNEL_VERSION(2,1,95)
     unsigned int piobase;
     unsigned char pci_bus, pci_devfn, pci_irq;
@@ -747,13 +672,19 @@
 #else
     int index;
 #endif
+#ifndef PCI_VENDOR_ID_AMI
+#define PCI_VENDOR_ID_AMI               0x101e
+#endif
 
     ENTER("qla1280_detect");
 
+    if (sizeof(srb_t) > sizeof(Scsi_Pointer) )
+      printk("qla1280_detect: [WARNING] srb_t Must Be Redefined");
+
 #ifdef CHECKSRBSIZE
     if (sizeof(srb_t) > sizeof(Scsi_Pointer) )
     {
-      printk("Redefine SRB - its too big");
+      printk("qla1280_detect:  srb_t Must Be Redefined - its too big");
       return 0;
     }
 #endif
@@ -784,41 +715,77 @@
                 "qla1280: insmod or else it might trash certain memory areas.\n");
 #endif
 
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
     if ((int) !pcibios_present())
+#else
+    if (!pci_present())
+#endif
     {
-		printk("scsi: PCI not present\n");
-		return 0;
-    } /* end of IF */
-    bdp = &QLBoardTbl[0];
+	printk("scsi: PCI not present\n");
+	return 0;
+    } 
+
+    bdp = &QL1280BoardTbl[0];
     qla1280_hostlist = NULL;
-#if 0
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
     template->proc_dir = &proc_scsi_qla1280;
 #else
-    template->proc_name = "qla1280";
+    template->proc_name = "qla1x80";
 #endif
-    
 	/* Try and find each different type of adapter we support */
 	for( i=0; bdp->device_id != 0 && i < NUM_OF_ISP_DEVICES; i++, bdp++ ) {
 #if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,95)
+#if LINUX_VERSION_CODE > KERNEL_VERSION(2,3,18)
+                /* PCI_SUBSYSTEM_IDS supported */ 
+		while ((pdev = pci_find_subsys(QLA1280_VENDOR_ID,
+			bdp->device_id, PCI_ANY_ID, PCI_ANY_ID, pdev) )) {
+			if (pci_enable_device(pdev)) continue;
+#else
 		while ((pdev = pci_find_device(QLA1280_VENDOR_ID,
 			bdp->device_id, pdev ) ))  {
-		if (pci_enable_device(pdev)) continue;
-#else
+#endif /* 2,3,18 */
+#else  /* less than 2,1,95 */  
 		while (!(pcibios_find_device(QLA1280_VENDOR_ID,
 			bdp->device_id,
 			index++, &pci_bus, &pci_devfn)) )  {
-#endif
+#endif /* 2,1,95 */ 
                 /* found a adapter */
-		template->unchecked_isa_dma = 1;
+#if LINUX_VERSION_CODE > KERNEL_VERSION(2,3,18)
+                  printk("qla1280: detect() found an HBA\n");
+		  printk("qla1280: VID=%x DID=%x SSVID=%x SSDID=%x\n",
+			pdev->vendor, pdev->device,
+			pdev->subsystem_vendor, pdev->subsystem_device); 
+		  /* If it's an AMI SubSys Vendor ID adapter, skip it. */
+                  if (pdev->subsystem_vendor = PCI_VENDOR_ID_AMI) 
+                    { 
+                      printk("qla1280: Skip AMI SubSys Vendor ID Chip\n");
+                      continue;
+                    }
+#else
+#if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,95)
+		  pci_read_config_word(pdev, PCI_SUBSYSTEM_VENDOR_ID,
+                                       &subsys);
+		  /* Bypass all AMI SUBSYS VENDOR IDs */
+                  if (subsys = PCI_VENDOR_ID_AMI) 
+                    { 
+                      printk("qla1280: Skip AMI SubSys Vendor ID  Chip\n");
+                      continue;
+                    }
+#endif /* 2,1,95 */
+#endif /* 2,3,18 */
 		host = scsi_register(template, sizeof(scsi_qla_host_t));
 		ha = (scsi_qla_host_t *) host->hostdata;
 		/* Clear our data area */
 		for( j =0, cp = (char *)ha;  j < sizeof(scsi_qla_host_t); j++)
-			*cp = 0;
+			*cp++ = 0;
 		/* Sanitize the information from PCI BIOS.  */
 #if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,95)
 		host->irq = pdev->irq;
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
+                host->io_port = (unsigned int) pdev->base_address[0];
+#else
 		host->io_port = pci_resource_start(pdev, 0);
+#endif
 		ha->pci_bus = pdev->bus->number;
 		ha->pci_device_fn = pdev->devfn;
 		ha->pdev = pdev;
@@ -835,35 +802,35 @@
     
                 ha->devnum = i;
 		if( qla1280_mem_alloc(ha) ) {
-			printk(KERN_INFO "qla1280: Failed to allocate memory for adapter\n");
+  	          printk(KERN_INFO "qla1280: Failed to get memory\n");
 		}
                 
                 ha->ports = bdp->numPorts; 
+                /* following needed for all cases of OS versions */
+                host->io_port &= PCI_BASE_ADDRESS_IO_MASK; 
                 ha->iobase = (device_reg_t *) host->io_port;
                 ha->host = host;
                 ha->host_no = host->host_no;
 
                 /* load the F/W, read paramaters, and init the H/W */
+                ha->instance = num_hosts;
                 if (qla1280_initialize_adapter(ha))
                 {
-
-                    printk(KERN_INFO "qla1280: Failed to initialized adapter\n");
-                    qla1280_mem_free(ha);
-                    scsi_unregister(host);
-                    continue;
+                   printk(KERN_INFO "qla1280: Failed to initialize adapter\n");
+                   qla1280_mem_free(ha);
+                   scsi_unregister(host);
+                   continue;
                 }
                 
                 host->max_channel = bdp->numPorts-1; 
-                ha->instance = num_hosts;
 		/* Register our resources with Linux */
 		if( qla1280_register_with_Linux(ha, bdp->numPorts-1) ) {
-			printk(KERN_INFO "qla1280: Failed to register our resources\n");
-			qla1280_mem_free(ha);
-			scsi_unregister(host);
-			continue;
+		  printk(KERN_INFO "qla1280: Failed to register resources\n");
+		  qla1280_mem_free(ha);
+		  scsi_unregister(host);
+		  continue;
 		}
 
-
                 reg = ha->iobase;
                 /* Disable ISP interrupts. */
 		qla1280_disable_intrs(ha);
@@ -920,8 +887,11 @@
 	host->can_queue = 0xfffff;  /* unlimited  */
 	host->cmd_per_lun = 1;
        host->select_queue_depths = qla1280_select_queue_depth;
-	host->n_io_port = 0xFF;
-	host->base = (unsigned long) ha->mmpbase;
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
+        host->base = (unsigned char *) ha->mmpbase;
+#else
+        host->base = (u_long) ha->mmpbase;
+#endif
 	host->max_channel = maxchannels; 
        host->max_lun = MAX_LUNS-1; 
 	host->unique_id = ha->instance;
@@ -1012,10 +982,10 @@
 
     bp = &qla1280_buffer[0];
     ha = (scsi_qla_host_t *)host->hostdata;
-    bdp = &QLBoardTbl[ha->devnum];
+    bdp = &QL1280BoardTbl[ha->devnum];
     memset(bp, 0, sizeof(qla1280_buffer));
     sprintf(bp,
-            "QLogic %sPCI to SCSI Host Adapter: bus %d device %d irq %d\n"
+            "QLogic %s PCI to SCSI Host Adapter: bus %d device %d irq %d\n"
             "       Firmware version: %2d.%02d.%02d, Driver version %s",
             (char *)&bdp->bdName[0], ha->pci_bus, (ha->pci_device_fn & 0xf8) >> 3, host->irq,
             bdp->fwver[0],bdp->fwver[1],bdp->fwver[2],
@@ -1047,8 +1017,8 @@
     scsi_lu_t       *q;
     u_long          handle;
 
-    ENTER("qla1280_queuecommand");
-    COMTRACE('C') 
+    /*ENTER("qla1280_queuecommand");
+      COMTRACE('C')*/ 
 
     host = cmd->host;
     ha = (scsi_qla_host_t *) host->hostdata;
@@ -1075,7 +1045,7 @@
         {
            LU_Q(ha, b, t, l) = q;
            BZERO(q,sizeof(struct scsi_lu));
-           DEBUG(sprintf(debug_buff,"Allocate new device queue 0x%x\n",q));
+           DEBUG(sprintf(debug_buff,"Allocate new device queue 0x%x\n\r",q));
            DEBUG(qla1280_print(debug_buff));
            DRIVER_UNLOCK
         }
@@ -1094,15 +1064,13 @@
     handle = INVALID_HANDLE;  
     CMD_HANDLE(cmd) = (unsigned char *)handle;
 
-    /* Bookkeeping information */
-    sp->r_start = jiffies;       /* time the request was recieved */
-    sp->u_start = 0;              
-
     /* add the command to our queue */
     ha->qthreads++;
     qla1280_putq_t(q,sp);
     
-    DEBUG(sprintf(debug_buff,"qla1280_queuecmd: queue pid=%d, hndl=0x%x\n\r",cmd->pid,handle));
+    DEBUG(sprintf(debug_buff,
+     "qla1280_QC: t=%x CDB=%x I/OSize=0x%x haQueueCount=0x%x\n\r",
+     t,cmd->cmnd[0],CMD_XFRLEN(cmd),ha->qthreads));
     DEBUG(qla1280_print(debug_buff));
 
     /* send command to adapter */
@@ -1112,7 +1080,7 @@
     DRIVER_UNLOCK
     
     
-    LEAVE("qla1280_queuecommand");
+    /*LEAVE("qla1280_queuecommand");*/
     return (0);
 }
 
@@ -1723,6 +1691,7 @@
     scsi_lu_t       *q;
     uint32_t        b, t, l;
     Scsi_Cmnd  *cmd;
+
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
     unsigned long cpu_flags = 0;
 #endif
@@ -1739,7 +1708,8 @@
             *done_q_last = NULL;
         else
             (*done_q_first)->s_prev = NULL;
-                cmd = sp->cmd;
+
+        cmd = sp->cmd;
         b = SCSI_BUS_32(cmd);
         t = SCSI_TCN_32(cmd);
         l = SCSI_LUN_32(cmd);
@@ -1753,8 +1723,6 @@
             q->q_flag &= ~QLA1280_QBUSY;
         }
         
-        q->resp_time += jiffies - sp->r_start;                /* Lun bookkeeping information */
-        q->act_time += jiffies - sp->u_start;
         q->io_cnt++;
         if( sp->dir & BIT_5 )
          q->r_cnt++;
@@ -1777,7 +1745,28 @@
             default:
                 break;
         }
-
+        /* 3.13   64 and 32 bit */
+        /* Release memory used for this I/O */
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,3,18)
+        if (cmd->use_sg) {
+            DEBUG(sprintf(debug_buff,
+            "S/G unmap_sg cmd=%x\n\r",cmd);)
+            DEBUG(qla1280_print(debug_buff));
+            pci_unmap_sg(ha->pdev, cmd->request_buffer,
+                         cmd->use_sg,
+                         scsi_to_pci_dma_dir(cmd->sc_data_direction));
+        }
+        else if (cmd->request_bufflen) {
+                 DEBUG(sprintf(debug_buff,
+                 "No S/G unmap_single cmd=%x saved_dma_handle=%lx\n\r",
+                  cmd,sp->saved_dma_handle);)
+                  DEBUG(qla1280_print(debug_buff);)
+
+                  pci_unmap_single(ha->pdev,sp->saved_dma_handle,
+                                  cmd->request_bufflen,
+                                  scsi_to_pci_dma_dir(cmd->sc_data_direction));
+       }
+#endif 
         /* Call the mid-level driver interrupt handler */
         CMD_HANDLE(sp->cmd) = (unsigned char *) 0;
         ha->actthreads--;
@@ -1791,8 +1780,6 @@
         qla1280_next(ha, q, b);
     }
     DRIVER_UNLOCK 
-
-
     COMTRACE('d') 
     LEAVE("qla1280_done");
 }
@@ -1964,7 +1951,7 @@
             if (q->q_outcnt >= ha->bus_settings[b].hiwat)
                 q->q_flag |= QLA1280_QBUSY;
 
-#if  QLA1280_64BIT_SUPPORT
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,3,18)
             if (ha->flags.enable_64bit_addressing)
                 status = qla1280_64bit_start_scsi(ha, sp);
             else
@@ -1981,7 +1968,7 @@
                     /* Wait for 30 sec for command to be accepted. */
                     for (cnt = 6000000; cnt; cnt--)
                     {
-#if  QLA1280_64BIT_SUPPORT
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,3,18)
                         if (ha->flags.enable_64bit_addressing)
                             status = qla1280_64bit_start_scsi(ha, sp);
                         else
@@ -2072,7 +2059,7 @@
     ENTER("qla1280_putq_t");
 #endif
     DRIVER_LOCK
-    DEBUG(sprintf(debug_buff,"Adding to device 0x%p<-(0x%p)\n\r",q,sp));
+    DEBUG(sprintf(debug_buff,"Adding to device q=0x%p<-(0x%p)sp\n\r",q,sp));
     DEBUG(qla1280_print(debug_buff));
     sp->s_next = NULL;
     if (!q->q_first)                  /* If queue empty */
@@ -2157,28 +2144,33 @@
 {
 
 	uint8_t   status = 1;
+#if LINUX_VERSION_CODE > KERNEL_VERSION(2,3,18)
+        dma_addr_t     dma_handle;
+#endif
 
 #ifdef QL_DEBUG_LEVEL_3
 	ENTER("qla1280_mem_alloc");
 #endif
 
-#ifdef DYNAMIC_MEM_ALLOC
-	ha->request_ring = qla1280_alloc_phys(REQUEST_ENTRY_SIZE * REQUEST_ENTRY_CNT,
-	&ha->request_dma);
-	if(ha->request_ring) {
-		ha->response_ring = qla1280_alloc_phys(RESPONSE_ENTRY_SIZE * RESPONSE_ENTRY_CNT,
-		&ha->response_dma);
-		if(ha->response_ring) {
-			status = 0;
-		}
-	}
-#else
+        /* 3.13 */
+        /* get consistent memory allocated for request and response rings */
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
 	ha->request_ring = &ha->req[0];
 	ha->request_dma = VIRT_TO_BUS(&ha->req[0]);
 	ha->response_ring = &ha->res[0];
 	ha->response_dma = VIRT_TO_BUS(&ha->res[0]);
 	status = 0;
-#endif
+#else
+        ha->request_ring  = pci_alloc_consistent(ha->pdev,
+                               ((REQUEST_ENTRY_CNT+1)*(sizeof(request_t))),
+                               &dma_handle);
+        ha->request_dma    = dma_handle;
+        ha->response_ring  = pci_alloc_consistent(ha->pdev,
+                               ((RESPONSE_ENTRY_CNT+1)*(sizeof(response_t))),
+                               &dma_handle);
+        ha->response_dma   = dma_handle;
+        status = 0; 
+#endif 
 
 	if(status) {
 #if defined(QL_DEBUG_LEVEL_2) || defined(QL_DEBUG_LEVEL_3)
@@ -2222,6 +2214,16 @@
             ha->dev[b] =  (scsi_lu_t  *)NULL;
     }
 
+    /* 3.13 */
+    /* free consistent memory allocated for request and response rings */
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,3,18)
+    pci_free_consistent(ha->pdev, ((REQUEST_ENTRY_CNT+1)*(sizeof(request_t))),
+                        ha->request_ring, ha->request_dma);
+
+    pci_free_consistent(ha->pdev,((RESPONSE_ENTRY_CNT+1)*(sizeof(response_t))),
+    ha->response_ring, ha->response_dma); 
+#endif 
+
     LEAVE("qlc1280_mem_free");
 }
 
@@ -2482,7 +2484,7 @@
         /* Verify checksum of loaded RISC code. */
         mb[0] = MBC_VERIFY_CHECKSUM;
         /* mb[1] = ql12_risc_code_addr01; */
-        mb[1] = *QLBoardTbl[ha->devnum].fwstart;  
+        mb[1] = *QL1280BoardTbl[ha->devnum].fwstart;  
 
         if (!(status = qla1280_mailbox_command(ha, BIT_1|BIT_0, &mb[0])))
         {
@@ -2492,7 +2494,7 @@
 #endif
             mb[0] = MBC_EXECUTE_FIRMWARE;
             /* mb[1] = ql12_risc_code_addr01; */
-            mb[1] = *QLBoardTbl[ha->devnum].fwstart;  
+            mb[1] = *QL1280BoardTbl[ha->devnum].fwstart;  
             qla1280_mailbox_command(ha, BIT_1|BIT_0, &mb[0]);
         }
         else
@@ -2527,18 +2529,69 @@
 qla1280_pci_config(scsi_qla_host_t *ha)
 {
     uint8_t      status = 1;
-    uint32_t     command;
 #if MEMORY_MAPPED_IO
     uint32_t  page_offset, base;
     uint32_t   mmapbase;
 #endif
-    config_reg_t *creg = 0;
     uint16_t     buf_wd;
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
+    uint32_t     command;
+    config_reg_t *creg = 0;
+#endif
+
 
     ENTER("qla1280_pci_config");
 
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,3,18)
+    /*
+     * Set Bus Master Enable, Memory Address Space Enable and
+     * reset any error bits, in the command register.
+     */
+    pci_read_config_word(ha->pdev, PCI_COMMAND, &buf_wd);
+    buf_wd &= ~0x7;
+#if MEMORY_MAPPED_IO
+    DEBUG(printk("qla1280: MEMORY MAPPED IO is enabled.\n"));
+    buf_wd |= BIT_2 + BIT_1 + BIT_0;
+#else
+    buf_wd |= BIT_2 + BIT_0;
+#endif
+    pci_write_config_word(ha->pdev, PCI_COMMAND, buf_wd);
+    /*
+     * Reset expansion ROM address decode enable.
+     */
+    pci_read_config_word(ha->pdev, PCI_ROM_ADDRESS, &buf_wd);
+    buf_wd &= ~PCI_ROM_ADDRESS_ENABLE;
+    pci_write_config_word(ha->pdev, PCI_ROM_ADDRESS, buf_wd);
+#if MEMORY_MAPPED_IO
+    /*
+     * Get memory mapped I/O address. 
+     */
+    pci_read_config_word(ha->pdev, PCI_BASE_ADDRESS_1, &mmapbase);
+    mmapbase &= PCI_BASE_ADDRESS_MEM_MASK;
+
+    /*
+     * Find proper memory chunk for memory map I/O reg.
+     */
+    base = mmapbase & PAGE_MASK;
+    page_offset = mmapbase - base;
+    /*
+     * Get virtual address for I/O registers.
+     */
+    ha->mmpbase = ioremap_nocache(base, page_offset + 256);
+    if( ha->mmpbase )
+    {
+        ha->mmpbase += page_offset;
+        /* ha->iobase = ha->mmpbase; */
+        status = 0;
+    }
+#else /* MEMORY_MAPPED_IO */
+    status = 0;
+#endif /* MEMORY_MAPPED_IO */
+
+#else /*LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18) */
+
     /* Get command register. */
-    if (pci_read_config_word(ha->pdev,OFFSET(creg->command), &buf_wd) = PCIBIOS_SUCCESSFUL)
+    if (pcibios_read_config_word(ha->pci_bus,ha->pci_device_fn, OFFSET(creg->command), &buf_wd) = PCIBIOS_SUCCESSFUL)
     {
         command = buf_wd;
         /*
@@ -2552,20 +2605,20 @@
 #else
         buf_wd |= BIT_2 + BIT_0;
 #endif
-        if( pci_write_config_word(ha->pdev,OFFSET(creg->command), buf_wd) )
+        if( pcibios_write_config_word(ha->pci_bus,ha->pci_device_fn, OFFSET(creg->command), buf_wd) )
         {
             printk(KERN_WARNING "qla1280: Could not write config word.\n");
         }
         /* Get expansion ROM address. */
-        if (pci_read_config_word(ha->pdev,OFFSET(creg->expansion_rom), &buf_wd) = PCIBIOS_SUCCESSFUL)
+        if (pcibios_read_config_word(ha->pci_bus,ha->pci_device_fn, OFFSET(creg->expansion_rom), &buf_wd) = PCIBIOS_SUCCESSFUL)
         {
             /* Reset expansion ROM address decode enable. */
             buf_wd &= ~BIT_0;
-            if (pci_write_config_word(ha->pdev,OFFSET(creg->expansion_rom), buf_wd) = PCIBIOS_SUCCESSFUL)
+            if (pcibios_write_config_word(ha->pci_bus,ha->pci_device_fn, OFFSET(creg->expansion_rom), buf_wd) = PCIBIOS_SUCCESSFUL)
             {
 #if MEMORY_MAPPED_IO
                 /* Get memory mapped I/O address. */
-                pci_read_config_dword(ha->pdev,OFFSET(cfgp->mem_base_addr), &mmapbase);
+                pcibios_read_config_dword(ha->pci_bus, ha->pci_device_fn,OFFSET(cfgp->mem_base_addr), &mmapbase);
                 mmapbase &= PCI_BASE_ADDRESS_MEM_MASK;
 
                 /* Find proper memory chunk for memory map I/O reg. */
@@ -2589,6 +2642,7 @@
             }
         }
     }
+#endif /* LINUX_VERSION_CODE >= KERNEL_VERSION(2,3,18) */
 
     LEAVE("qla1280_pci_config");
     return(status);
@@ -2719,6 +2773,7 @@
  * Returns:
  *      0 = success.
  */
+#define DUMP_IT_BACK 0   /* for debug of RISC loading */
 STATIC uint8_t
 qla1280_setup_chip(scsi_qla_host_t *ha)
 {
@@ -2727,37 +2782,52 @@
     uint16_t     *risc_code_address;
     long         risc_code_size;
     uint16_t     mb[MAILBOX_REGISTER_COUNT];
-#ifdef QLA1280_UNUSED
-    uint8_t	*sp;
-    int i;
-#endif
     uint16_t     cnt;
     int          num;
+#if DUMP_IT_BACK
+    int     i;
+    uint8_t *sp;
     uint8_t    *tbuf;
+#if BITS_PER_LONG > 32
     u_long     p_tbuf;
+#else
+    uint32_t   p_tbuf;
+#endif
+#endif
 
 #ifdef QL_DEBUG_LEVEL_3
     ENTER("qla1280_setup_chip");
 #endif
 
-	if( (tbuf = (uint8_t *)KMALLOC(8000) ) = NULL )
-        {
-            printk("setup_chip: couldn't alloacte memory\n");
-            return(1);
-        }
-        p_tbuf =  VIRT_TO_BUS(tbuf);
+    /* 3.13 */
+#if DUMP_IT_BACK
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
+    if( (tbuf = (uint8_t *)KMALLOC(8000) ) = NULL )
+    {
+        printk("setup_chip: couldn't alloacte memory\n");
+        return(1);
+    }
+    p_tbuf =  VIRT_TO_BUS(tbuf);
+#else
+    /* get consistent memory allocated for setup_chip */
+    tbuf   = pci_alloc_consistent(ha->pdev, 8000, &p_tbuf);
+#endif
+#endif
+
     /* Load RISC code. */
     /* 
     risc_address      = ql12_risc_code_addr01;
     risc_code_address = &ql12_risc_code01[0];
     risc_code_size    = ql12_risc_code_length01;
     */
-    risc_address = *QLBoardTbl[ha->devnum].fwstart;  
-    risc_code_address = QLBoardTbl[ha->devnum].fwcode;  
-    risc_code_size    = (long)(*QLBoardTbl[ha->devnum].fwlen & 0xffff);  
-
-    DEBUG(printk("qla1280: DMAing RISC code (%d) words.\n",(int)risc_code_size));
-    DEBUG(sprintf(debug_buff,"qla1280_setup_chip:  Loading RISC code size =(%ld).\n\r",risc_code_size);)
+    risc_address = *QL1280BoardTbl[ha->devnum].fwstart;  
+    risc_code_address = QL1280BoardTbl[ha->devnum].fwcode;  
+    risc_code_size    = (long)(*QL1280BoardTbl[ha->devnum].fwlen & 0xffff);  
+
+    DEBUG(printk("qla1280_setup_chip: DMA RISC code (%d) words\n",
+         (int)risc_code_size));
+    DEBUG(sprintf(debug_buff,
+       "qla1280_setup_chip: DMA RISC code (%d) words\n\r",risc_code_size);)
     DEBUG(qla1280_print(debug_buff));
     num =0;
     while (risc_code_size > 0 && !status)
@@ -2767,29 +2837,31 @@
         if ( cnt > risc_code_size ) 
             cnt = risc_code_size;
 
-        DEBUG(sprintf(debug_buff,"qla1280_setup_chip:  loading risc @ =(0x%p),%d,%d(0x%x).\n\r",risc_code_address,cnt,num,risc_address);)
+        DEBUG(sprintf(debug_buff,
+         "qla1280_setup_chip:  loading risc @ =(0x%p),%d,%d(0x%x).\n\r",
+          risc_code_address,cnt,num,risc_address);)
         DEBUG(qla1280_print(debug_buff));
-        DEBUG(printk("qla1280_setup_chip:  loading risc @ =code=(0x%p),cnt=%d,seg=%d,addr=0x%x\n\r",risc_code_address,cnt,num,risc_address));
-        BCOPY((caddr_t) risc_code_address,(caddr_t) ha->request_ring, (cnt <<1));
+        BCOPY((caddr_t) risc_code_address,(caddr_t) ha->request_ring,
+              (cnt <<1));
+
+        flush_cache_all(); 
+
         mb[0] = MBC_LOAD_RAM; 
-        /* mb[0] = MBC_LOAD_RAM_A64; */
         mb[1] = risc_address;
         mb[4] = cnt;
         mb[3] = (uint16_t)  ha->request_dma & 0xffff;
         mb[2] = (uint16_t) (ha->request_dma >> 16) & 0xffff;
         mb[7] = (uint16_t) (MS_64BITS(ha->request_dma) & 0xffff);
         mb[6] = (uint16_t) (MS_64BITS(ha->request_dma) >> 16) & 0xffff;
-        DEBUG(printk("qla1280_setup_chip: op=%d  0x%lx = 0x%4x,0x%4x,0x%4x,0x%4x\n",mb[0],ha->request_dma,mb[6],mb[7],mb[2],mb[3]));
+        DEBUG(printk("qla1280_setup_chip: op=%d  0x%p = 0x%4x,0x%4x,0x%4x,0x%4x\n",mb[0],ha->request_dma,mb[6],mb[7],mb[2],mb[3]));
         if( (status = qla1280_mailbox_command(ha, BIT_4|BIT_3|BIT_2|BIT_1|BIT_0,
             &mb[0]))  )
         {
             printk("Failed to load partial segment of f/w\n");
             break;
         }
-        /* dump it back */
-
-#if 0
-        mb[0] = MBC_DUMP_RAM_A64;
+#if DUMP_IT_BACK
+        mb[0] = MBC_READ_RAM_WORD;
         mb[1] = risc_address;
         mb[4] = cnt;
         mb[3] = (uint16_t)  p_tbuf & 0xffff;
@@ -2797,10 +2869,13 @@
         mb[7] = (uint16_t) (p_tbuf >> 32) & 0xffff;
         mb[6] = (uint16_t) (p_tbuf >> 48) & 0xffff;
 
-        if( (status = qla1280_mailbox_command(ha, BIT_4|BIT_3|BIT_2|BIT_1|BIT_0,
-            &mb[0]))  )
+        if( (status = qla1280_mailbox_command(ha, 
+                      BIT_4|BIT_3|BIT_2|BIT_1|BIT_0,&mb[0]))  )
         {
             printk("Failed to dump partial segment of f/w\n");
+            DEBUG(sprintf(debug_buff,
+               "setup_chip: Failed to dump partial segment of f/w\n\r");)
+            DEBUG(qla1280_print(debug_buff));
             break;
         }
         sp =  (uint8_t *)ha->request_ring;
@@ -2808,51 +2883,20 @@
         {
             if( tbuf[i] != sp[i] )
             {
-               printk("qla1280 : firmware compare error @ byte (0x%x)\n",i);
-                break;
+               printk("qla1280_setup_chip: FW compare error @ byte(0x%x) loop#=%x\n",i,num);
+               printk("setup_chip: FWbyte=%x  FWfromChip=%x\n",sp[i],tbuf[i]); 
+               DEBUG(sprintf(debug_buff,
+                "qla1280_setup_chip: FW compare error @ byte(0x%x) loop#=%x\n\r",i);)
+               DEBUG(qla1280_print(debug_buff);)
+               /*break;*/
             }
         }
-
 #endif
         risc_address += cnt;
         risc_code_size = risc_code_size - cnt;
         risc_code_address = risc_code_address + cnt;
         num++;
     }
-#ifdef QLA1280_UNUSED
-    DEBUG(ql_debug_print = 0;)
-    {
-        for (i = 0; i < ql12_risc_code_length01; i++)
-        {
-            mb[0] = 0x4;
-            mb[1] = ql12_risc_code_addr01 + i;
-            mb[2] = ql12_risc_code01[i];
-
-            status = qla1280_mailbox_command(ha, BIT_2|BIT_1|BIT_0,
-                    &mb[0]);
-            if (status)
-            {
-                printk("qla1280 : firmware load failure\n");
-                break;
-            }
-
-            mb[0] = 0x5;
-            mb[1] = ql12_risc_code_addr01 + i;
-            mb[2] = 0;
-
-            status = qla1280_mailbox_command(ha, BIT_2|BIT_1|BIT_0,
-                    &mb[0]);
-            if (status)
-            {
-                printk("qla1280 : firmware dump failure\n");
-                break;
-            }
-            if( mb[2] != ql12_risc_code01[i] )
-                printk("qla1280 : firmware compare error @ (0x%x)\n",ql12_risc_code_addr01+i);
-        }
-    }
-    DEBUG(ql_debug_print = 1;)
-#endif
 
     /* Verify checksum of loaded RISC code. */
     if (!status)
@@ -2860,22 +2904,29 @@
         DEBUG(printk("qla1280_setup_chip: Verifying checksum of loaded RISC code.\n");)
         mb[0] = MBC_VERIFY_CHECKSUM;
         /* mb[1] = ql12_risc_code_addr01; */
-        mb[1] = *QLBoardTbl[ha->devnum].fwstart;  
+        mb[1] = *QL1280BoardTbl[ha->devnum].fwstart;  
         
         if (!(status = qla1280_mailbox_command(ha, BIT_1|BIT_0, &mb[0])))
         {
             /* Start firmware execution. */
             DEBUG(qla1280_print("qla1280_setup_chip: start firmware running.\n\r");)
             mb[0] = MBC_EXECUTE_FIRMWARE;
-            /* mb[1] = ql12_risc_code_addr01; */
-            mb[1] = *QLBoardTbl[ha->devnum].fwstart;  
+            mb[1] = *QL1280BoardTbl[ha->devnum].fwstart;  
             qla1280_mailbox_command(ha, BIT_1|BIT_0, &mb[0]);
         }
         else
             printk("qla1280_setup_chip: Failed checksum.\n");
     }
 
-	KMFREE(tbuf,8000);
+    /* 3.13 */
+#if DUMP_IT_BACK
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
+    KMFREE(tbuf,8000);
+#else
+    /* free consistent memory allocated for setup_chip */
+    pci_free_consistent(ha->pdev, 8000, tbuf, p_tbuf);
+#endif
+#endif
 
 #if defined(QL_DEBUG_LEVEL_2) || defined(QL_DEBUG_LEVEL_3)
     if (status)
@@ -3152,10 +3203,28 @@
     /* Disable RISC load of firmware. */
     ha->flags.disable_risc_code_load              nv->cntr_flags_1.disable_loading_risc_code;
+
     /* Enable 64bit addressing. */
     ha->flags.enable_64bit_addressing              nv->cntr_flags_1.enable_64bit_addressing;
 
+#if FORCE_64BIT_PCI_DMA
+    ha->flags.enable_64bit_addressing = 1;
+#endif
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,3,18)
+    if (ha->flags.enable_64bit_addressing) {
+           printk("[[[ qla1x160: 64 Bit PCI Addressing Enabled ]]]\n");
+
+#if BITS_PER_LONG > 32
+           /* Update our PCI device dma_mask for full 64 bit mask */
+           //ha->pdev->dma_mask = (pci_dma_t) 0xffffffffffffffffull;
+           ha->pdev->dma_mask =  0xffffffffffffffff;
+
+#endif
+    }
+#endif
+
     /* Set ISP hardware DMA burst */
     mb[0] = nv->isp_config.c;
     WRT_REG_WORD(&reg->cfg_1, mb[0]);
@@ -3838,7 +3907,7 @@
 #endif
 }
 
-#if  QLA1280_64BIT_SUPPORT
+#if LINUX_VERSION_CODE > KERNEL_VERSION(2,3,18)
 /*
  * qla1280_64bit_start_scsi
  *      The start SCSI is responsible for building request packets on
@@ -3863,10 +3932,13 @@
     uint16_t        seg_cnt;
     struct scatterlist    *sg = (struct scatterlist *) NULL;
     uint32_t        *dword_ptr;
+    dma_addr_t       dma_handle;
 
-#ifdef QL_DEBUG_LEVEL_3
     ENTER("qla1280_64bit_start_scsi:");
-#endif
+
+    DEBUG(sprintf(debug_buff,
+          "64bit_start: cmd=%x sp=%x CDB=%x\n\r",cmd,sp,cmd->cmnd[0]);)
+    DEBUG(qla1280_print(debug_buff));
 
     if( qla1280_check_for_dead_scsi_bus(ha, sp) )
     {
@@ -3877,9 +3949,10 @@
     seg_cnt = 0;
     req_cnt = 1;
     if (cmd->use_sg)
-    {
-        seg_cnt =  cmd->use_sg;
+    {   /* 3.13 64 bit */
         sg = (struct scatterlist *) cmd->request_buffer;
+        seg_cnt = pci_map_sg(ha->pdev,sg,cmd->use_sg, 
+                    scsi_to_pci_dma_dir(cmd->sc_data_direction));
             
         if (seg_cnt > 2)
         {
@@ -3890,7 +3963,7 @@
     }
     else if (cmd->request_bufflen)  /* If data transfer. */
     {
-        DEBUG(printk("Single data transfer (0x%x)\n",cmd->request_bufflen));
+        DEBUG(printk("Single data transfer len=0x%x\n",cmd->request_bufflen));
         seg_cnt = 1;
     }
 
@@ -3951,7 +4024,7 @@
             /* Load SCSI command packet. */
             pkt->cdb_len = (uint16_t)CMD_CDBLEN(cmd);
             BCOPY(&(CMD_CDBP(cmd)), pkt->scsi_cdb, pkt->cdb_len);
-            DEBUG(printk("Build packet for command[0]=0x%x\n",pkt->scsi_cdb[0]));
+            //DEBUG(printk("Build packet for command[0]=0x%x\n",pkt->scsi_cdb[0]));
 
             /*
             * Load data segments.
@@ -3977,12 +4050,17 @@
                     /* Load command entry data segments. */
                     for (cnt = 0; cnt < 2 && seg_cnt; cnt++, seg_cnt--)
                     {
-                        DEBUG(sprintf(debug_buff,"SG Segment ap=0x%p, len=0x%x\n\r",sg->address,sg->length));
-                        DEBUG(qla1280_print(debug_buff));
-                        *dword_ptr++ = cpu_to_le32(VIRT_TO_BUS_LOW(sg->address));
-                        *dword_ptr++ = cpu_to_le32(VIRT_TO_BUS_HIGH(sg->address));
-                        *dword_ptr++ = sg->length;
+                        /* 3.13 64 bit */
+                        *dword_ptr++ = cpu_to_le32(pci_dma_lo32(sg_dma_address(sg)));
+                        *dword_ptr++ = cpu_to_le32(pci_dma_hi32(sg_dma_address(sg)));
+                        *dword_ptr++ = cpu_to_le32(sg_dma_len(sg));
                         sg++;
+                        DEBUG(sprintf(debug_buff,
+                         "S/G Segment phys_addr=%x %x, len=0x%x\n\r",
+                          cpu_to_le32(pci_dma_hi32(sg_dma_address(sg))),
+                          cpu_to_le32(pci_dma_lo32(sg_dma_address(sg))),
+                                      cpu_to_le32(sg_dma_len(sg)));)
+                        DEBUG(qla1280_print(debug_buff));
                     }
 #ifdef QL_DEBUG_LEVEL_5
                     qla1280_print(
@@ -3999,6 +4077,10 @@
                     /*
                     * Build continuation packets.
                     */
+                    DEBUG(sprintf(debug_buff,
+                    "S/G Building Continuation...seg_cnt=0x%x remains\n\r",
+                    seg_cnt);)
+                    DEBUG(qla1280_print(debug_buff));
                     while (seg_cnt > 0)
                     {
                         /* Adjust ring index. */
@@ -4032,10 +4114,17 @@
                         /* Load continuation entry data segments. */
                         for (cnt = 0; cnt < 5 && seg_cnt; cnt++, seg_cnt--)
                         {
-                            *dword_ptr++ = cpu_to_le32(VIRT_TO_BUS_LOW(sg->address));
-                            *dword_ptr++ = cpu_to_le32(VIRT_TO_BUS_HIGH(sg->address));
-                            *dword_ptr++ = sg->length;
-                            sg++;
+                           /* 3.13 64 bit */
+                           *dword_ptr++ = cpu_to_le32(pci_dma_lo32(sg_dma_address(sg)));
+                           *dword_ptr++ = cpu_to_le32(pci_dma_hi32(sg_dma_address(sg)));
+                           *dword_ptr++ = cpu_to_le32(sg_dma_len(sg));
+                           DEBUG(sprintf(debug_buff,
+                            "S/G Segment Cont. phys_addr=%x %x, len=0x%x\n\r",
+                             cpu_to_le32(pci_dma_hi32(sg_dma_address(sg))),
+                             cpu_to_le32(pci_dma_lo32(sg_dma_address(sg))),
+                             cpu_to_le32(sg_dma_len(sg)));)
+                           DEBUG(qla1280_print(debug_buff));
+                           sg++;
                         }
 #ifdef QL_DEBUG_LEVEL_5
                         qla1280_print(
@@ -4052,11 +4141,21 @@
 #endif
                     }
                 }
-                else                    /* No scatter gather data transfer */
-                {
-                    *dword_ptr++ = cpu_to_le32(VIRT_TO_BUS_LOW(cmd->request_buffer));
-                    *dword_ptr++ = cpu_to_le32(VIRT_TO_BUS_HIGH(cmd->request_buffer));
-                    *dword_ptr = (uint32_t) cmd->request_bufflen;
+                else         /* No scatter gather data transfer */
+                {   /* 3.13 64 bit */
+                    dma_handle = pci_map_single(ha->pdev, 
+                                                cmd->request_buffer,
+                                                cmd->request_bufflen,
+                                                scsi_to_pci_dma_dir(cmd->sc_data_direction));
+                    /* save dma_handle for pci_unmap_single */
+                    sp->saved_dma_handle = dma_handle;
+
+                    *dword_ptr++ = cpu_to_le32(pci_dma_lo32(dma_handle));
+                    *dword_ptr++ = cpu_to_le32(pci_dma_hi32(dma_handle));
+                    *dword_ptr   = (uint32_t) cmd->request_bufflen;
+                    DEBUG(sprintf(debug_buff,
+                    "No S/G map_single saved_dma_handle=%lx\n\r",dma_handle));
+                    DEBUG(qla1280_print(debug_buff));
 #ifdef QL_DEBUG_LEVEL_5
                     qla1280_print(
                             "qla1280_64bit_start_scsi: No scatter/gather command packet data - c");
@@ -4140,7 +4239,7 @@
 #endif
     return(status);
 }
-#endif  /* QLA1280_64BIT_SUPPORT */
+#endif
 
 /*
  * qla1280_32bit_start_scsi
@@ -4175,8 +4274,15 @@
     uint8_t        *data_ptr;
     uint32_t        *dword_ptr;
 
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,3,18)
+    dma_addr_t       dma_handle;
+#endif
+
     ENTER("qla1280_32bit_start_scsi");
 
+    DEBUG(sprintf(debug_buff,
+          "32bit_start: cmd=%x sp=%x CDB=%x\n\r",cmd,sp,cmd->cmnd[0]);)
+    DEBUG(qla1280_print(debug_buff));
 
     if( qla1280_check_for_dead_scsi_bus(ha, sp) )
     {
@@ -4193,8 +4299,15 @@
         * differences and the kernel SG list uses virtual addresses where
         * we need physical addresses.
         */
-        seg_cnt =  cmd->use_sg;
         sg = (struct scatterlist *) cmd->request_buffer;
+        /* 3.13 32 bit */
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
+        seg_cnt =  cmd->use_sg;
+#else
+        seg_cnt = pci_map_sg(ha->pdev,sg,cmd->use_sg, 
+                    scsi_to_pci_dma_dir(cmd->sc_data_direction));
+#endif
+
         /* 
         * if greater than four sg entries then we need to allocate
         * continuation entries
@@ -4205,17 +4318,22 @@
             if ((uint16_t)(seg_cnt - 4) % 7)
                 req_cnt++;
         }
-        DEBUG(sprintf(debug_buff,"S/G for data transfer -num segs(%d), req blk cnt(%d)\n\r",seg_cnt,req_cnt));
+        DEBUG(sprintf(debug_buff,
+         "S/G Transfer cmd=%x seg_cnt=0x%x, req_cnt=%x\n\r",
+          cmd,seg_cnt,req_cnt));
         DEBUG(qla1280_print(debug_buff));
     }
     else if (cmd->request_bufflen)  /* If data transfer. */
     {
-        DEBUG(printk("Single data transfer (0x%x)\n",cmd->request_bufflen));
+        DEBUG(sprintf(debug_buff,
+         "No S/G transfer t=%x cmd=%x len=%x CDB=%x\n\r",
+         SCSI_TCN_32(cmd),cmd,cmd->request_bufflen,cmd->cmnd[0]));
+        DEBUG(qla1280_print(debug_buff));
         seg_cnt = 1;
     }
     else
     {
-        DEBUG(printk("No data transfer \n"));
+      //DEBUG(printk("No data transfer \n"));
         seg_cnt = 0;
     }
 
@@ -4232,7 +4350,8 @@
             ha->req_q_cnt = REQUEST_ENTRY_CNT - (ha->req_ring_index - cnt);
     }
 
-    DEBUG(sprintf(debug_buff,"Number of free entries = (%d)\n\r",ha->req_q_cnt));
+    DEBUG(sprintf(debug_buff,"Number of free entries=(%d) seg_cnt=0x%x\n\r",
+          ha->req_q_cnt,seg_cnt));
     DEBUG(qla1280_print(debug_buff));
     /* If room for request in request ring. */
     if ((uint16_t)(req_cnt + 2) < ha->req_q_cnt)
@@ -4280,20 +4399,15 @@
             data_ptr = (uint8_t *) &(CMD_CDBP(cmd));
             for (cnt = 0; cnt < pkt->cdb_len; cnt++)
                 pkt->scsi_cdb[cnt] = *data_ptr++;
-            DEBUG(printk("Build packet for command[0]=0x%x\n",pkt->scsi_cdb[0]));
+            //DEBUG(printk("Build packet for command[0]=0x%x\n",pkt->scsi_cdb[0]));
             /*
             * Load data segments.
             */
             if (seg_cnt)
             {
-                DEBUG(printk("loading data segments..\n"));
                 /* Set transfer direction (READ and WRITE) */
                 /* Linux doesn't tell us                   */
-
                 /*
-                * 3/10 dg - Normally, we should need this check with our F/W
-                * but because of a small issue with it we do.
-                *
                 * For block devices, cmd->request.cmd has the operation 
                 * For character devices, this isn't always set properly, so
                 * we need to check data_cmnd[0].  This catches the conditions
@@ -4319,15 +4433,32 @@
                     /* Load command entry data segments. */
                     for (cnt = 0; cnt < 4 && seg_cnt; cnt++, seg_cnt--)
                     {
+                        /* 3.13 32 bit */
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
                         *dword_ptr++ = (uint32_t) cpu_to_le32(VIRT_TO_BUS(sg->address));
                         *dword_ptr++ = sg->length;
-                        DEBUG(sprintf(debug_buff,"SG Segment ap=0x%p, len=0x%x\n\r",sg->address,sg->length));
+                        DEBUG(sprintf(debug_buff,
+                         "S/G Segment phys_addr=0x%x, len=0x%x\n\r",
+                          cpu_to_le32(VIRT_TO_BUS(sg->address)),sg->length));
+                        DEBUG(qla1280_print(debug_buff));
+#else
+                        *dword_ptr++ = cpu_to_le32(pci_dma_lo32(sg_dma_address(sg)));
+                        *dword_ptr++ = cpu_to_le32(sg_dma_len(sg));
+                        DEBUG(sprintf(debug_buff,
+                         "S/G Segment phys_addr=0x%x, len=0x%x\n\r",
+                          cpu_to_le32(pci_dma_lo32(sg_dma_address(sg))),
+                          cpu_to_le32(sg_dma_len(sg)));)
                         DEBUG(qla1280_print(debug_buff));
+#endif 
                         sg++;
                     }
                     /*
                     * Build continuation packets.
                     */
+                    DEBUG(sprintf(debug_buff,
+                    "S/G Building Continuation...seg_cnt=0x%x remains\n\r",
+                    seg_cnt);)
+                    DEBUG(qla1280_print(debug_buff));
                     while (seg_cnt > 0)
                     {
                         /* Adjust ring index. */
@@ -4362,9 +4493,25 @@
                         /* Load continuation entry data segments. */
                         for (cnt = 0; cnt < 7 && seg_cnt; cnt++, seg_cnt--)
                         {
-                            *dword_ptr++ = (u_int) cpu_to_le32(VIRT_TO_BUS(sg->address));
-                            *dword_ptr++ = sg->length;
-                            sg++;
+                           /* 3.13 32 bit */
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
+                           *dword_ptr++ = (u_int) cpu_to_le32(VIRT_TO_BUS(sg->address));
+                           *dword_ptr++ = sg->length;
+                           DEBUG(sprintf(debug_buff,
+                           "S/G Segment Cont. phys_addr=0x%x, len=0x%x\n\r",
+                           cpu_to_le32(pci_dma_lo32(VIRT_TO_BUS(sg->address))),
+                           sg->length);)
+                           DEBUG(qla1280_print(debug_buff));
+#else
+                           *dword_ptr++ = cpu_to_le32(pci_dma_lo32(sg_dma_address(sg)));
+                           *dword_ptr++ = cpu_to_le32(sg_dma_len(sg));
+                           DEBUG(sprintf(debug_buff,
+                            "S/G Segment Cont. phys_addr=0x%x, len=0x%x\n\r",
+                             cpu_to_le32(pci_dma_lo32(sg_dma_address(sg))),
+                             cpu_to_le32(sg_dma_len(sg)));)
+                           DEBUG(qla1280_print(debug_buff));
+#endif
+                           sg++;
                         }
 #ifdef QL_DEBUG_LEVEL_5
                         qla1280_print(
@@ -4379,14 +4526,28 @@
 #endif
                     }
                 }
-                else                    /* No scatter gather data transfer */
+                else     /* No S/G data transfer */
                 {
+                    /* 3.13 32 bit */
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
                     *dword_ptr++ = (uint32_t) cpu_to_le32(VIRT_TO_BUS(cmd->request_buffer));
                     *dword_ptr = (uint32_t) cmd->request_bufflen;
-                    DEBUG(printk("Single Segment ap=0x%p, len=0x%x\n",cmd->request_buffer,cmd->request_bufflen));
+#else
+                    dma_handle = pci_map_single(ha->pdev, 
+                                                cmd->request_buffer,
+                                                cmd->request_bufflen,
+                                                scsi_to_pci_dma_dir(cmd->sc_data_direction));
+                    sp->saved_dma_handle = dma_handle;
+
+                    *dword_ptr++ = cpu_to_le32(pci_dma_lo32(dma_handle));
+                    *dword_ptr   = (uint32_t) cmd->request_bufflen;
+                    DEBUG(sprintf(debug_buff,
+                    "No S/G map_single saved_dma_handle=%lx\n\r",dma_handle));
+                    DEBUG(qla1280_print(debug_buff));
+#endif 
                 }
             }
-            else                            /* No data transfer */
+            else         /* No data transfer at all */
             {
                 *dword_ptr++ = (uint32_t) 0;
                 *dword_ptr = (uint32_t)  0;
@@ -4414,7 +4575,6 @@
             /* Set chip new ring index. */
             DEBUG(qla1280_print("qla1280_32bit_start_scsi: Wakeup RISC for pending command\n\r"));
             ha->qthreads--;
-            sp->u_start = jiffies;
             sp->flags |= SRB_SENT;
             ha->actthreads++;
             /* qla1280_output_number((uint32_t)ha->actthreads++, 16); */
@@ -4425,7 +4585,7 @@
             status = 1;
 #ifdef QL_DEBUG_LEVEL_2
             qla1280_print(
-                    "qla1280_32bit_start_scsi: NO ROOM IN OUTSTANDING ARRAY\n\r");
+            "qla1280_32bit_start_scsi: NO ROOM IN OUTSTANDING ARRAY\n\r");
             qla1280_print(" req_q_cnt=");
             qla1280_output_number((uint32_t)ha->req_q_cnt, 16);
             qla1280_print("\n\r");
@@ -4459,6 +4619,7 @@
     return(status);
 }
 
+
 /*
  * qla1280_req_pkt
  *      Function is responsible for locking ring and
@@ -4889,7 +5050,7 @@
 {
     device_reg_t    *reg = ha->iobase;
     response_t      *pkt;
-    srb_t           *sp;
+    srb_t           *sp = 0; 
     uint16_t        mailbox[MAILBOX_REGISTER_COUNT];
     uint16_t        *wptr;
     uint32_t        index;
@@ -4903,9 +5064,11 @@
     /* Check for mailbox interrupt. */
 
     mailbox[0] = RD_REG_WORD(&reg->semaphore);
+
     if (mailbox[0] & BIT_0)
     {
         /* Get mailbox data. */
+        //DEBUG(qla1280_print("qla1280_isr: In Get mailbox data \n\r");)
 
         wptr = &mailbox[0];
         *wptr++ = RD_REG_WORD(&reg->mailbox0);
@@ -4938,7 +5101,7 @@
         {
             case MBA_SCSI_COMPLETION:   /* Response completion */
 #ifdef QL_DEBUG_LEVEL_5
-                qla1280_print("qla1280_isr: mailbox response completion\n\r");
+                qla1280_print("qla1280_isr: mailbox SCSI response completion\n\r");
 #endif
                 if (ha->flags.online)
                 {
@@ -4967,9 +5130,11 @@
                         else
                             (*done_q_last)->s_next = sp;
                         *done_q_last = sp;
+
                     }
                     else
                     {
+
 #ifdef QL_DEBUG_LEVEL_2
                             qla1280_print("qla1280_isr: ISP invalid handle\n\r");
 #endif
@@ -5041,6 +5206,7 @@
 #endif
                 break;
             default:
+              //DEBUG(qla1280_print("qla1280_isr: default case of switch MB \n\r");)
                 if (mailbox[0] < MBA_ASYNC_EVENT)
                 {
                         wptr = &mailbox[0];
@@ -5057,9 +5223,9 @@
                 break;
         }
     }
-    else
+    else {
         WRT_REG_WORD(&reg->host_cmd, HC_CLR_RISC_INT);
-
+    }
     /*
     * Response ring
     */
@@ -5123,6 +5289,7 @@
                         qla1280_error_entry(ha, pkt,
                                 done_q_first, done_q_last);
 
+
                     /* Adjust ring index. */
                     ha->rsp_ring_index++;
                     if (ha->rsp_ring_index = RESPONSE_ENTRY_CNT)
@@ -5306,9 +5473,12 @@
             }
             pkt->scsi_status = S_CKCON;
             pkt->option_flags |= (uint32_t)OF_SSTS | (uint32_t)OF_NO_DATA;
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,3,18)
             if (ha->flags.enable_64bit_addressing)
                 qla1280_64bit_continue_io(ha, pkt, 0, 0);
             else
+#endif
                 qla1280_32bit_continue_io(ha, pkt, 0, 0);
             break;
         case 0x16:                  /* Requested Capability Not Available */
@@ -5667,10 +5837,12 @@
                             (uint32_t)OF_NO_DATA;
                     break;
             }
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,3,18)
             if (ha->flags.enable_64bit_addressing)
-                qla1280_64bit_continue_io(ha, pkt, len, (paddr32_t *)&phy_addr);
+               qla1280_64bit_continue_io(ha, pkt, len, (paddr32_t *)&phy_addr);
             else
-                qla1280_32bit_continue_io(ha, pkt, len, (paddr32_t *)&phy_addr);
+#endif
+               qla1280_32bit_continue_io(ha, pkt, len, (paddr32_t *)&phy_addr);
             break;
         default:
             break;
@@ -5744,11 +5916,13 @@
         ha->outstanding_cmds[pkt->handle] = 0;
 
         cp = sp->cmd;
+
         /* Generate LU queue on cntrl, target, LUN */
         b = SCSI_BUS_32(cp);
         t = SCSI_TCN_32(cp);
         l = SCSI_LUN_32(cp);
         q = LU_Q(ha, b, t, l);
+
         if( pkt->comp_status || pkt->scsi_status )
         {
             DEBUG(qla1280_print( "scsi: comp_status = ");)
@@ -5879,7 +6053,7 @@
         /* Place command on done queue. */
         qla1280_done_q_put(sp, done_q_first, done_q_last);
     }
-#if  QLA1280_64BIT_SUPPORT
+#if  BITS_PER_LONG > 32
     else if (pkt->entry_type = COMMAND_A64_TYPE)
     {
 #ifdef QL_DEBUG_LEVEL_2
@@ -5956,7 +6130,6 @@
                 sp->timeout += 2; */
 
                 /* Place request back on top of device queue. */
-                /* sp->flags &= ~(SRB_SENT | SRB_TIMEOUT); */ 
                 sp->flags = 0;
                 qla1280_putq_t(q, sp);
             }
@@ -6074,7 +6247,7 @@
                 }
             }
 #ifdef QL_DEBUG_LEVEL_3
-            qla1280_print("qla1280_restart_queues: exiting normally\n");
+            qla1280_print("qla1280_restart_queues: exiting normally\n\r");
 #endif
 }
 
@@ -6279,13 +6452,13 @@
 #if MEMORY_MAPPED_IO
     ret = *port;
 #else
-    ret = inb((int)port);
+    ret = inb((long)port);
 #endif
 
     if (ql_debug_print)
     {
         qla1280_print("qla1280_getbyte: address = ");
-        qla1280_output_number((uint32_t)port, 16);
+        qla1280_output_number((unsigned long)port, 16);
         qla1280_print(" data = 0x");
         qla1280_output_number((uint32_t)ret, 16);
         qla1280_print("\n\r");
@@ -6305,13 +6478,13 @@
 #if MEMORY_MAPPED_IO
     ret = *port;
 #else
-    ret = inw((int)port);
+    ret = inw((unsigned long)port);
 #endif
 
     if (ql_debug_print)
     {
         qla1280_print("qla1280_getword: address = ");
-        qla1280_output_number((uint32_t)port, 16);
+        qla1280_output_number((unsigned long)port, 16);
         qla1280_print(" data = 0x");
         qla1280_output_number((uint32_t)ret, 16);
         qla1280_print("\n\r");
@@ -6331,13 +6504,13 @@
 #if MEMORY_MAPPED_IO
     ret = *port;
 #else
-    ret = inl((int)port);
+    ret = inl((unsigned long)port);
 #endif
 
     if (ql_debug_print)
     {
         qla1280_print("qla1280_getdword: address = ");
-        qla1280_output_number((uint32_t)port, 16);
+        qla1280_output_number((unsigned long)port, 16);
         qla1280_print(" data = 0x");
         qla1280_output_number((uint32_t)ret, 16);
         qla1280_print("\n\r");
@@ -6355,13 +6528,13 @@
 #if MEMORY_MAPPED_IO
     *port = data;
 #else
-    outb(data, (int)port);
+    outb(data, (unsigned long)port);
 #endif
 
     if (ql_debug_print)
     {
         qla1280_print("qla1280_putbyte: address = ");
-        qla1280_output_number((uint32_t)port, 16);
+        qla1280_output_number((unsigned long)port, 16);
         qla1280_print(" data = 0x");
         qla1280_output_number((uint32_t)data, 16);
         qla1280_print("\n\r");
@@ -6380,14 +6553,14 @@
 #ifdef _LINUX_IOPORTS
     outw(data, (int)port);
 #else
-    outw((int)port, data);
+    outw((unsigned long)port, data);
 #endif
 #endif
 
     if (ql_debug_print)
     {
         qla1280_print("qla1280_putword: address = ");
-        qla1280_output_number((uint32_t)port, 16);
+        qla1280_output_number((unsigned long)port, 16);
         qla1280_print(" data = 0x");
         qla1280_output_number((uint32_t)data, 16);
         qla1280_print("\n\r");
@@ -6406,14 +6579,14 @@
 #ifdef _LINUX_IOPORTS
     outl(data,(int)port);
 #else
-    outl((int)port, data);
+    outl((unsigned long)port, data);
 #endif
 #endif
 
     if (ql_debug_print)
     {
         qla1280_print("qla1280_putdword: address = ");
-        qla1280_output_number((uint32_t)port, 16);
+        qla1280_output_number((unsigned long)port, 16);
         qla1280_print(" data = 0x");
         qla1280_output_number((uint32_t)data, 16);
         qla1280_print("\n\r");
@@ -6437,8 +6610,7 @@
 
 /*
  *  Out character to COM2 port.
- *      PORT must be at standard address for COM2 = 0x2F8,
- *      or COM1 = 0x3F8
+ *      PORT must be at standard address for COM1 = 0x3f8
  */
 #define OUTB(addr,data)   outb((data),(addr))
 
@@ -6448,7 +6620,7 @@
 #ifdef QL_DEBUG_CONSOLE
     printk("%c", c);
 #else
-    int     com_addr              = 0x2f8;
+    int     com_addr              = 0x3f8;
     int     hardware_flow_control = 1;
     int     software_flow_control = 0;
     uint8_t data;
@@ -6460,7 +6632,7 @@
     }while (!(data & BIT_6));
 
     /*
-    * Set BAUD rate for COM2 to 19200 (0x6)
+    * Set BAUD rate for COM2 to 9600 (0x6)
     */
 
     /* Select rate divisor. */
@@ -6656,8 +6828,6 @@
     qla1280_print(debug_buff);
     sprintf(debug_buff,"  Pid=%d, SP=0x%p\n\r", (int)cmd->pid, CMD_SP(cmd));
     qla1280_print(debug_buff);
-    sprintf(debug_buff,"  r_start=0x%lx, u_start=0x%lx\n\r",sp->r_start,sp->u_start);
-    qla1280_print(debug_buff);
     sprintf(debug_buff," underflow size = 0x%x, direction=0x%x, req.cmd=0x%x \n\r", cmd->underflow, sp->dir,cmd->request.cmd);    
     qla1280_print(debug_buff);
 }
@@ -6685,23 +6855,6 @@
 }
 #endif
 
-#ifdef  QLA1280_UNUSED 
-/**************************************************************************
- *   ql1280_dump_regs
- *
- **************************************************************************/
-static void qla1280_dump_regs(struct Scsi_Host *host)
-{
-    printk("Mailbox registers:\n");
-    printk("qla1280 : mbox 0 0x%04x \n", inw(host->io_port + 0x70));
-    printk("qla1280 : mbox 1 0x%04x \n", inw(host->io_port + 0x72));
-    printk("qla1280 : mbox 2 0x%04x \n", inw(host->io_port + 0x74));
-    printk("qla1280 : mbox 3 0x%04x \n", inw(host->io_port + 0x76));
-    printk("qla1280 : mbox 4 0x%04x \n", inw(host->io_port + 0x78));
-    printk("qla1280 : mbox 5 0x%04x \n", inw(host->io_port + 0x7a));
-}
-#endif
-
 
 
 #if  STOP_ON_ERROR 
@@ -6728,9 +6881,6 @@
     printk("HA flags =0x%lx\n", *fp);
     DEBUG2(ql_debug_print = 1;)
     /* DEBUG2(ql1280_dump_device((scsi_qla_host_t *) host->hostdata)); */
-#ifdef  QLA1280_UNUSED 
-    qla1280_dump_regs(host);
-#endif
     sti();  
     panic("Ooops");  
     /* cli(); 
@@ -6743,11 +6893,6 @@
 }
 #endif
 
-#ifdef  QLA1280_UNUSED 
-static void qla1280_set_flags(char * s)
-{
-}
-#endif
 
 /**************************************************************************
  *   qla1280_setup
@@ -6761,24 +6906,6 @@
 {
     char *end, *str, *cp;
 
-#ifdef  QLA1280_UNUSED 
-    static struct
-    {
-        const char *name;
-        int      siz;
-        void  (*func)();
-        int   arg;
-    } options[] -    {
-        { "dump_regs", 9,  &qla1280_dump_regs, 0 
-        },
-        { "verbose", 7, &qla1280_set_flags, 0x1 
-        },
-        { "",    0, NULL, 0 
-        }
-    };
-#endif
-
     printk("scsi: Processing Option str = %s\n", s);
     end = strchr(s, '\0');
     /* locate command */
@@ -6827,4 +6954,3 @@
  * tab-width: 8
  * End:
  */
-
diff -urN linux-davidm/drivers/scsi/qla1280.h lia64/drivers/scsi/qla1280.h
--- linux-davidm/drivers/scsi/qla1280.h	Fri Jul 14 17:24:15 2000
+++ lia64/drivers/scsi/qla1280.h	Fri Sep  8 17:16:54 2000
@@ -1,169 +1,35 @@
-/*************************************************************************
- *                  QLOGIC LINUX SOFTWARE
- *
- * QLogic ISP1x80/1x160 device driver for Linux 2.3.x (redhat 6.x).
- *
- * COPYRIGHT (C) 1996-2000 QLOGIC CORPORATION    
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the Qlogic's Linux Software License.
- *
- * This program is WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- *
- * 1. Redistribution's or source code must retain the above copyright
- *    notice, this list of conditions, and the following disclaimer,
- *    without modification, immediately at the beginning of the file.
- * 2. The name of the author may not be used to endorse or promote products
- *    derived from this software without specific prior written permission.
- *
- *****************************************************************************/
- 
-/*************************************************************************************
-			QLOGIC CORPORATION SOFTWARE
-           "GNU" GENERAL PUBLIC LICENSE
-    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION
-                 AND MODIFICATION
-
-This GNU General Public License ("License") applies solely to QLogic Linux 
-Software ("Software") and may be distributed under the terms of this License.  
- 
-1. You may copy and distribute verbatim copies of the Software's source code as 
-you receive it, in any medium, provided that you conspicuously and appropriately 
-publish on each copy an appropriate copyright notice and disclaimer of warranty;
-keep intact all the notices that refer to this License and to the absence of any
-warranty; and give any other recipients of the Software a copy of this License along
-with the Software. 
-
-You may charge a fee for the physical act of transferring a copy, and you may at your
-option offer warranty protection in exchange for a fee.
- 
-2. You may modify your copy or copies of the Software or any portion of it, thus forming
-a work based on the Software, and copy and distribute such modifications or work under
-the terms of Section 1 above, provided that you also meet all of these conditions:
- 
-* a) You must cause the modified files to carry prominent notices stating that you
-changed the files and the date of any change. 
-
-* b) You must cause any work that you distribute or publish that in whole or in part
-contains or is derived from the Software or any part thereof, to be licensed as a
-whole at no charge to all third parties under the terms of this License. 
-
-* c) If the modified Software normally reads commands interactively when run, you
-must cause it, when started running for such interactive use in the most ordinary way,
-to print or display an announcement including an appropriate copyright notice and a 
-notice that there is no warranty (or else, saying that you provide a warranty) and that
-users may redistribute the Software under these conditions, and telling the user how to
-view a copy of this License. (Exception:if the Software itself is interactive but does 
-not normally print such an announcement, your work based on the Software is not required
-to print an announcement.) 
-
-These requirements apply to the modified work as a whole. If identifiable sections of
-that work are not derived from the Software, and can be reasonably considered independent
-and separate works in themselves, then this License, and its terms, do not apply to those
-sections when you distribute them as separate works. But when you distribute the same
-sections as part of a whole which is a work based on the Software, the distribution of the
-whole must be on the terms of this License, whose permissions for other licensees extend
-to the entire whole, and thus to each and every part regardless of who wrote it. 
-
-3. You may copy and distribute the Software (or a work based on it, under Section 2) in 
-object code or executable form under the terms of Sections 1 and 2 above provided that
-you also do one of the following: 
-
-* a) Accompany it with the complete corresponding machine-readable source code, which must
-be distributed under the terms of Sections 1 and 2 above on a medium customarily used for
-software interchange; or, 
-
-* b) Accompany it with a written offer, valid for at least three years, to give any third
-party, for a charge no more than your cost of physically performing source distribution,
-a complete machine-readable copy of the corresponding source code, to be distributed under
-the terms of Sections 1 and 2 above on a medium customarily used for software interchange;
-or,
-
-* c) Accompany it with the information you received as to the offer to distribute 
-corresponding source code. (This alternative is allowed only for noncommercial distribution
-and only if you received the Software in object code or executable form with such an offer,
-in accord with Subsection b above.) 
-
-The source code for a work means the preferred form of the work for making modifications
-to it. For an executable work, complete source code means all the source code for all 
-modules it contains, plus any associated interface definition files, plus the scripts used
-to control compilation and installation of the executable.     
-
-If distribution of executable or object code is made by offering access to copy from a 
-designated place, then offering equivalent access to copy the source code from the same
-place counts as distribution of the source code, even though third parties are not 
-compelled to copy the source along with the object code. 
-
-4. You may not copy, modify, sublicense, or distribute the Software except as expressly 
-provided under this License. Any attempt otherwise to copy, modify, sublicense or 
-distribute the Software is void, and will automatically terminate your rights under this
-License. However, parties who have received copies, or rights, from you under this License
-will not have their licenses terminated so long as such parties remain in full compliance. 
-
-5. This license grants you world wide, royalty free non-exclusive rights to modify or 
-distribute the Software or its derivative works. These actions are prohibited by law 
-if you do not accept this License. Therefore, by modifying or distributing the Software
-(or any work based on the Software), you indicate your acceptance of this License to do
-so, and all its terms and conditions for copying, distributing or modifying the Software
-or works based on it.
- 
-6. Each time you redistribute the Software (or any work based on the Software), the 
-recipient automatically receives a license from the original licensor to copy, distribute
-or modify the Software subject to these terms and conditions. You may not impose any 
-further restrictions on the recipients' exercise of the rights granted herein. You are
-not responsible for enforcing compliance by third parties to this License.
- 
-7. If, as a consequence of a court judgment or allegation of patent infringement or for
-any other reason (not limited to patent issues), conditions are imposed on you 
-(whether by court order, agreement or otherwise) that contradict the conditions of this
-License, they do not excuse you from the conditions of this License. If you cannot 
-distribute so as to satisfy simultaneously your obligations under this License 
-and any other pertinent obligations, then as a consequence you may not distribute the
-Software at all.    
-
-If any portion of this section is held invalid or unenforceable under any particular 
-circumstance, the balance of the section is intended to apply and the section as a whole
-is intended to apply in other circumstances. 
-NO WARRANTY
-
-11. THE SOFTWARE IS PROVIDED WITHOUT A WARRANTY OF ANY KIND. THERE IS NO 
-WARRANTY FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. 
-EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR 
-OTHER PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, 
-EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
-WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
-ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH YOU. 
-SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL 
-NECESSARY SERVICING, REPAIR OR CORRECTION.
- 
-12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING 
-WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR 
-REDISTRIBUTE THE SOFTWARE AS PERMITTED ABOVE, BE LIABLE TO YOU FOR 
-DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL 
-DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING 
-BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR 
-LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO 
-OPERATE WITH ANY OTHER SOFTWARES), EVEN IF SUCH HOLDER OR OTHER PARTY HAS 
-BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. 
-END OF TERMS AND CONDITIONS 
+/********************************************************************************
+*                  QLOGIC LINUX SOFTWARE
+*
+* QLogic ISP1280 (Ultra2) /12160 (Ultra3) SCSI driver
+* Copyright (C) 2000 Qlogic Corporation 
+* (www.qlogic.com)
+*
+* This program is free software; you can redistribute it and/or modify it
+* under the terms of the GNU General Public License as published by the
+* Free Software Foundation; either version 2, or (at your option) any
+* later version.
+*
+* This program is distributed in the hope that it will be useful, but
+* WITHOUT ANY WARRANTY; without even the implied warranty of
+* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+* General Public License for more details.
+**
+******************************************************************************/
 
-*************************************************************************************/ 
-
- 
 #ifndef _IO_HBA_QLA1280_H           /* wrapper symbol for kernel use */
 #define _IO_HBA_QLA1280_H           /* subject to change without notice */
 
+
+#ifndef LINUX_VERSION_CODE 
+#include <linux/version.h>
+#endif  /* LINUX_VERSION_CODE not defined */
+
 #if defined(__cplusplus)
 extern "C" {
 #endif
 
-#include <linux/version.h>
-
+#ifndef HOSTS_C                     /* included in hosts.c */
 /*
  * Enable define statement to ignore Data Underrun Errors,
  * remove define statement to enable detection.
@@ -173,15 +39,18 @@
 /*
  * Driver debug definitions.
  */
-/* #define QL_DEBUG_LEVEL_1 */       /* Output register accesses to COM2. */
-/* #define QL_DEBUG_LEVEL_2 */           /* Output error msgs to COM2. */
-/* #define QL_DEBUG_LEVEL_3 */          /* Output function trace msgs to COM2. */
-/* #define QL_DEBUG_LEVEL_4 */       /* Output NVRAM trace msgs to COM2. */
-/* #define QL_DEBUG_LEVEL_5 */         /* Output ring trace msgs to COM2. */
-/* #define QL_DEBUG_LEVEL_6 */      /* Output WATCHDOG timer trace to COM2. */
-/* #define QL_DEBUG_LEVEL_7 */      /* Output RISC load trace msgs to COM2. */
+/* #define QL_DEBUG_LEVEL_1 */      /* Output register accesses to COM1 */
+/* #define QL_DEBUG_LEVEL_2 */      /* Output error msgs to COM1 */
+/* #define QL_DEBUG_LEVEL_3 */      /* Output function trace msgs to COM1 */
+/* #define QL_DEBUG_LEVEL_4 */      /* Output NVRAM trace msgs to COM1 */
+/* #define QL_DEBUG_LEVEL_5 */      /* Output ring trace msgs to COM1 */
+/* #define QL_DEBUG_LEVEL_6 */      /* Output WATCHDOG timer trace to COM1 */
+/* #define QL_DEBUG_LEVEL_7 */      /* Output RISC load trace msgs to COM1 */
+
+  #define QL_DEBUG_CONSOLE    /* Output to console instead of COM1   */
+  /* comment this #define to get output of qla1280_print to COM1         */
+  /* if COM1 is not connected to a host system, the driver hangs system! */
 
-#define QL_DEBUG_CONSOLE              /* Output to console instead of COM2. */
 
 #ifndef TRUE
 #  define TRUE 1
@@ -206,7 +75,11 @@
  * Locking
  */
 #if LINUX_VERSION_CODE > KERNEL_VERSION(2,1,0)
-#  include <linux/spinlock.h>
+#  if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,18)
+#    include <asm/spinlock.h>
+#  else
+#    include <linux/spinlock.h>
+#  endif
 #  include <linux/smp.h>
 #  define cpuid smp_processor_id()
 #  if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
@@ -314,12 +187,12 @@
 #define WRT_REG_DWORD(addr, data) qla1280_putdword((uint32_t *)addr, data)
 #else  /* QL_DEBUG_LEVEL_1 */
 #ifdef MEMORY_MAPPED_IO
-       #define RD_REG_BYTE(addr)         readb((unsigned long) (addr)
-       #define RD_REG_WORD(addr)         readw((unsigned long) (addr)
-       #define RD_REG_DWORD(addr)        readl((unsigned long) (addr)
-       #define WRT_REG_BYTE(addr, data)  writeb((data), (unsigned long) (addr))
-       #define WRT_REG_WORD(addr, data)  writew((data), (unsigned long) (addr))
-       #define WRT_REG_DWORD(addr, data) writel((data), (unsigned long) (addr))
+      #define RD_REG_BYTE(addr)         (*((volatile uint8_t *)addr))
+       #define RD_REG_WORD(addr)         (*((volatile uint16_t *)addr))
+       #define RD_REG_DWORD(addr)        (*((volatile uint32_t *)addr))
+       #define WRT_REG_BYTE(addr, data)  (*((volatile uint8_t *)addr) = data)
+       #define WRT_REG_WORD(addr, data)  (*((volatile uint16_t *)addr) = data)
+       #define WRT_REG_DWORD(addr, data) (*((volatile uint32_t *)addr) = data) 
 #else   /* MEMORY_MAPPED_IO */
 #define RD_REG_BYTE(addr)         (inb((unsigned long)addr))
 #define RD_REG_WORD(addr)         (inw((unsigned long)addr))
@@ -374,7 +247,8 @@
 typedef struct timer_list   timer_t;         /* timer */
 
 /*
- * SCSI Request Block structure
+ * SCSI Request Block structure  (sp)  that is placed
+ * on cmd->SCp location of every I/O
  */
 typedef struct srb
 {
@@ -383,10 +257,11 @@
     struct srb  *s_prev;             /* (4) Previous block on LU queue */
     uint8_t     flags;               /* (1) Status flags. */
     uint8_t     dir;                 /* direction of transfer */
-    uint8_t     unused[2];
-    u_long      r_start;             /* jiffies at start of request */
-    u_long      u_start;             /* jiffies when sent to F/W    */
-}srb_t;
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,3,18)
+    dma_addr_t  saved_dma_handle;    /* for unmap of single transfers */
+#endif
+   
+} srb_t;
 
 /*
  * SRB flag definitions
@@ -1564,13 +1439,13 @@
 
     request_t       req[REQUEST_ENTRY_CNT+1];
     response_t      res[RESPONSE_ENTRY_CNT+1];
-    unsigned long   request_dma;        /* Physical address. */
+    uint32_t        request_dma;        /* Physical address. */
     request_t       *request_ring;      /* Base virtual address */
     request_t       *request_ring_ptr;  /* Current address. */
     uint16_t        req_ring_index;     /* Current index. */
     uint16_t        req_q_cnt;          /* Number of available entries. */
 
-    unsigned long   response_dma;       /* Physical address. */
+    uint32_t        response_dma;       /* Physical address. */
     response_t      *response_ring;     /* Base virtual address */
     response_t      *response_ring_ptr; /* Current address. */
     uint16_t        rsp_ring_index;     /* Current index. */
@@ -1616,8 +1491,13 @@
        uint32_t     dpc                     :1;   /* 15 */
        uint32_t     dpc_sched               :1;   /* 16 */
        uint32_t     interrupts_on               :1;   /* 17 */
+       uint32_t     bios_enabled               :1;   /* 18 */
     }flags;
 
+  /* needed holders for PCI ordered list of hosts */
+  unsigned long io_port;
+  uint32_t irq;
+
 }scsi_qla_host_t;
 
 /*
@@ -1646,6 +1526,8 @@
 #define QLA1280_RING_LOCK(ha)  
 #define QLA1280_RING_UNLOCK(ha)   
 
+#endif  /* HOSTS_C */
+
 #if defined(__cplusplus)
 }
 #endif
@@ -1663,49 +1545,20 @@
 int qla1280_biosparam(Disk *, kdev_t, int[]);
 void qla1280_intr_handler(int, void *, struct pt_regs *);
 void qla1280_setup(char *s, int *dummy);
-#if defined(__386__)
+
 #  define QLA1280_BIOSPARAM  qla1280_biosparam
-#else
-#  define QLA1280_BIOSPARAM  NULL
-#endif
 
 /*
  * Scsi_Host_template (see hosts.h) 
  * Device driver Interfaces to mid-level SCSI driver.
  */
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,95)
-/* This interface is now obsolete !!! */ 
-#define QLA1280_LINUX_TEMPLATE {		                 \
-        next:           NULL,                                    \
-        usage_count:    NULL,                                    \
-	proc_dir:		NULL,          	                 \
-	proc_info:		NULL,	                         \
-	name:			"Qlogic ISP 1280",               \
-	detect:			qla1280_detect,	                 \
-	release:		qla1280_release,                 \
-	info:			qla1280_info,	                 \
-        command:        NULL,                                    \
-	queuecommand:	qla1280_queuecommand,	                 \
-	abort:			qla1280_abort,	                 \
-	reset:			qla1280_reset,	                 \
-        slave_attach:   NULL,                                    \
-	bios_param:		QLA1280_BIOSPARAM,               \
-	can_queue:		255, /* MAX_OUTSTANDING_COMMANDS */   \
-	this_id:		-1,  /* scsi id of host adapter */        \
-	sg_tablesize:	SG_ALL,	 \
-	cmd_per_lun:	3,	  /* max commands per lun */	       \
-	present:	    0,    /* number of 1280s present */	       \
-	unchecked_isa_dma: 0, /* no memeory DMA restrictions */    \
-	use_clustering:	ENABLE_CLUSTERING			               \
-}
-#else
 
-#define QLA1280_LINUX_TEMPLATE {		                 \
+#define QLA1280_LINUX_TEMPLATE {		                \
 	next: NULL,						\
 	module: NULL,						\
 	proc_dir: NULL,						\
 	proc_info: qla1280_proc_info,				\
-	name:			"Qlogic ISP 1280\1080",               \
+	name:			"Qlogic ISP 1280\12160",        \
 	detect: qla1280_detect,					\
 	release: qla1280_release,				\
 	info: qla1280_info,					\
@@ -1725,13 +1578,14 @@
 	this_id: -1,		/* scsi id of host adapter    */\
 	sg_tablesize: SG_ALL,	/* max scatter-gather cmds    */\
 	cmd_per_lun: 3,		/* cmds per lun (linked cmds) */\
-	present: 0,		/* number of 7xxx's present   */\
+	present: 0,		/* number of 1280's present   */\
 	unchecked_isa_dma: 0,	/* no memory DMA restrictions */\
 	use_clustering: ENABLE_CLUSTERING,			\
 	use_new_eh_code: 0,					\
 	emulated: 0					        \
 }
-#endif
+
 
 
 #endif /* _IO_HBA_QLA1280_H */
+
diff -urN linux-davidm/drivers/scsi/sd.c lia64/drivers/scsi/sd.c
--- linux-davidm/drivers/scsi/sd.c	Fri Sep  8 14:34:56 2000
+++ lia64/drivers/scsi/sd.c	Fri Sep  8 18:28:54 2000
@@ -1335,6 +1335,8 @@
 	return;
 }
 
+#ifdef MODULE
+
 int init_sd(void)
 {
 	sd_template.module = THIS_MODULE;
@@ -1390,3 +1392,5 @@
 
 module_init(init_sd);
 module_exit(exit_sd);
+
+#endif /* MODULE */
diff -urN linux-davidm/include/asm-ia64/ia32.h lia64/include/asm-ia64/ia32.h
--- linux-davidm/include/asm-ia64/ia32.h	Thu Aug 24 08:17:47 2000
+++ lia64/include/asm-ia64/ia32.h	Fri Sep  8 17:14:47 2000
@@ -351,6 +351,8 @@
 		(granularity << IA32_SEG_G)		       |       \
 		(((base >> 24) & 0xFF) << IA32_SEG_HIGH_BASE)) 
 
+#define IA32_IOBASE    0x2000000000000000 /* Virtual addres for I/O space */
+
 #define IA32_CR0       0x80000001      /* Enable PG and PE bits */
 #define IA32_CR4       0	       /* No architectural extensions */
 
diff -urN linux-davidm/include/asm-ia64/io.h lia64/include/asm-ia64/io.h
--- linux-davidm/include/asm-ia64/io.h	Thu Aug 24 08:17:47 2000
+++ lia64/include/asm-ia64/io.h	Fri Sep  8 17:14:30 2000
@@ -66,10 +66,9 @@
 extern inline const unsigned long
 __ia64_get_io_port_base (void)
 {
-	unsigned long addr;
+	extern unsigned long ia64_iobase;
 
-	__asm__ ("mov %0=ar.k0;;" : "=r"(addr));
-	return __IA64_UNCACHED_OFFSET | addr;
+	return ia64_iobase;
 }
 
 extern inline void*
diff -urN linux-davidm/include/asm-ia64/offsets.h lia64/include/asm-ia64/offsets.h
--- linux-davidm/include/asm-ia64/offsets.h	Fri Sep  8 22:36:14 2000
+++ lia64/include/asm-ia64/offsets.h	Fri Sep  8 16:34:23 2000
@@ -11,7 +11,7 @@
 #define PT_PTRACED_BIT			0
 #define PT_TRACESYS_BIT			1
 
-#define IA64_TASK_SIZE			2896	/* 0xb50 */
+#define IA64_TASK_SIZE			2928	/* 0xb70 */
 #define IA64_PT_REGS_SIZE		400	/* 0x190 */
 #define IA64_SWITCH_STACK_SIZE		560	/* 0x230 */
 #define IA64_SIGINFO_SIZE		128	/* 0x80 */
@@ -21,9 +21,9 @@
 #define IA64_TASK_SIGPENDING_OFFSET	16	/* 0x10 */
 #define IA64_TASK_NEED_RESCHED_OFFSET	40	/* 0x28 */
 #define IA64_TASK_PROCESSOR_OFFSET	100	/* 0x64 */
-#define IA64_TASK_THREAD_OFFSET		896	/* 0x380 */
-#define IA64_TASK_THREAD_KSP_OFFSET	896	/* 0x380 */
-#define IA64_TASK_THREAD_SIGMASK_OFFSET	2744	/* 0xab8 */
+#define IA64_TASK_THREAD_OFFSET		928	/* 0x3a0 */
+#define IA64_TASK_THREAD_KSP_OFFSET	928	/* 0x3a0 */
+#define IA64_TASK_THREAD_SIGMASK_OFFSET	2784	/* 0xae0 */
 #define IA64_TASK_PID_OFFSET		188	/* 0xbc */
 #define IA64_TASK_MM_OFFSET		88	/* 0x58 */
 #define IA64_PT_REGS_CR_IPSR_OFFSET	0	/* 0x0 */
diff -urN linux-davidm/include/asm-ia64/pal.h lia64/include/asm-ia64/pal.h
--- linux-davidm/include/asm-ia64/pal.h	Thu Aug 24 08:17:47 2000
+++ lia64/include/asm-ia64/pal.h	Fri Sep  8 16:34:36 2000
@@ -66,6 +66,7 @@
 #define PAL_CACHE_PROT_INFO	38	/* get i/d cache protection info */
 #define PAL_REGISTER_INFO	39	/* return AR and CR register information*/
 #define PAL_SHUTDOWN		40	/* enter processor shutdown state */
+#define PAL_PREFETCH_VISIBILITY	41
 
 #define PAL_COPY_PAL		256	/* relocate PAL procedures and PAL PMI */
 #define PAL_HALT_INFO		257	/* return the low power capabilities of processor */
@@ -644,15 +645,16 @@
  * (generally 0) MUST be passed.  Reserved parameters are not optional
  * parameters.
  */
-extern struct ia64_pal_retval ia64_pal_call_static (u64, u64, u64, u64); 
-extern struct ia64_pal_retval ia64_pal_call_stacked (u64, u64, u64, u64); 
-extern struct ia64_pal_retval ia64_pal_call_phys_static (u64, u64, u64, u64); 
-extern struct ia64_pal_retval ia64_pal_call_phys_stacked (u64, u64, u64, u64); 
-
-#define PAL_CALL(iprv,a0,a1,a2,a3)	iprv = ia64_pal_call_static(a0, a1, a2, a3)
-#define PAL_CALL_STK(iprv,a0,a1,a2,a3)	iprv = ia64_pal_call_stacked(a0, a1, a2, a3)
-#define PAL_CALL_PHYS(iprv,a0,a1,a2,a3) iprv = ia64_pal_call_phys_static(a0, a1, a2, a3)
-#define PAL_CALL_PHYS_STK(iprv,a0,a1,a2,a3) iprv = ia64_pal_call_phys_stacked(a0, a1, a2, a3)
+extern struct ia64_pal_retval ia64_pal_call_static (u64, u64, u64, u64, u64);
+extern struct ia64_pal_retval ia64_pal_call_stacked (u64, u64, u64, u64);
+extern struct ia64_pal_retval ia64_pal_call_phys_static (u64, u64, u64, u64);
+extern struct ia64_pal_retval ia64_pal_call_phys_stacked (u64, u64, u64, u64);
+
+#define PAL_CALL(iprv,a0,a1,a2,a3)		iprv = ia64_pal_call_static(a0, a1, a2, a3, 0)
+#define PAL_CALL_IC_OFF(iprv,a0,a1,a2,a3)	iprv = ia64_pal_call_static(a0, a1, a2, a3, 1)
+#define PAL_CALL_STK(iprv,a0,a1,a2,a3)		iprv = ia64_pal_call_stacked(a0, a1, a2, a3)
+#define PAL_CALL_PHYS(iprv,a0,a1,a2,a3)		iprv = ia64_pal_call_phys_static(a0, a1, a2, a3)
+#define PAL_CALL_PHYS_STK(iprv,a0,a1,a2,a3)	iprv = ia64_pal_call_phys_stacked(a0, a1, a2, a3)
 
 typedef int (*ia64_pal_handler) (u64, ...);
 extern ia64_pal_handler ia64_pal;
@@ -777,7 +779,7 @@
 ia64_pal_cache_flush (u64 cache_type, u64 invalidate, u64 *progress) 
 {	
 	struct ia64_pal_retval iprv;
-	PAL_CALL(iprv, PAL_CACHE_FLUSH, cache_type, invalidate, *progress); 
+	PAL_CALL_IC_OFF(iprv, PAL_CACHE_FLUSH, cache_type, invalidate, *progress); 
 	*progress = iprv.v1;
 	return iprv.status; 
 }
@@ -1385,6 +1387,14 @@
 	if (tr_valid)
 		tr_valid->piv_val = iprv.v0;
 	return iprv.status; 
+}
+
+extern inline s64
+ia64_pal_prefetch_visibility (void)
+{
+	struct ia64_pal_retval iprv;
+	PAL_CALL(iprv, PAL_PREFETCH_VISIBILITY, 0, 0, 0);
+	return iprv.status;
 }
 
 #endif /* __ASSEMBLY__ */
diff -urN linux-davidm/include/asm-ia64/processor.h lia64/include/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Thu Aug 24 08:17:47 2000
+++ lia64/include/asm-ia64/processor.h	Fri Sep  8 17:14:30 2000
@@ -305,10 +305,11 @@
 	__u64 csd;			/* IA32 code selector descriptor */
 	__u64 ssd;			/* IA32 stack selector descriptor */
 	__u64 tssd;			/* IA32 TSS descriptor */
+	__u64 old_iob;			/* old IOBase value */
 	union {
 		__u64 sigmask;		/* aligned mask for sigsuspend scall */
 	} un;
-# define INIT_THREAD_IA32	, 0, 0, 0x17800000037fULL, 0, 0, 0, 0, 0, {0}
+# define INIT_THREAD_IA32	, 0, 0, 0x17800000037fULL, 0, 0, 0, 0, 0, 0, {0}
 #else
 # define INIT_THREAD_IA32
 #endif /* CONFIG_IA32_SUPPORT */
@@ -334,6 +335,8 @@
 
 #define start_thread(regs,new_ip,new_sp) do {					\
 	set_fs(USER_DS);							\
+	ia64_psr(regs)->dfh = 1;	/* disable fph */			\
+	ia64_psr(regs)->mfh = 0;	/* clear mfh */				\
 	ia64_psr(regs)->cpl = 3;	/* set user mode */			\
 	ia64_psr(regs)->ri = 0;		/* clear return slot number */		\
 	ia64_psr(regs)->is = 0;		/* IA-64 instruction set */		\
@@ -390,6 +393,8 @@
 /* Return stack pointer of blocked task TSK.  */
 #define KSTK_ESP(tsk)  ((tsk)->thread.ksp)
 
+#ifndef CONFIG_SMP
+
 static inline struct task_struct *
 ia64_get_fpu_owner (void)
 {
@@ -403,6 +408,8 @@
 {
 	__asm__ __volatile__ ("mov ar.k5=%0" :: "r"(t));
 }
+
+#endif /* !CONFIG_SMP */
 
 extern void __ia64_init_fpu (void);
 extern void __ia64_save_fpu (struct ia64_fpreg *fph);
diff -urN linux-davidm/include/asm-ia64/ptrace.h lia64/include/asm-ia64/ptrace.h
--- linux-davidm/include/asm-ia64/ptrace.h	Thu Jun 22 07:09:45 2000
+++ lia64/include/asm-ia64/ptrace.h	Fri Sep  8 17:14:26 2000
@@ -219,6 +219,7 @@
   extern void show_regs (struct pt_regs *);
   extern long ia64_peek (struct pt_regs *, struct task_struct *, unsigned long addr, long *val);
   extern long ia64_poke (struct pt_regs *, struct task_struct *, unsigned long addr, long val);
+  extern void ia64_flush_fph (struct task_struct *t);
   extern void ia64_sync_fph (struct task_struct *t);
 
 #ifdef CONFIG_IA64_NEW_UNWIND
diff -urN linux-davidm/include/asm-ia64/ptrace_offsets.h lia64/include/asm-ia64/ptrace_offsets.h
--- linux-davidm/include/asm-ia64/ptrace_offsets.h	Thu Jun 22 07:09:45 2000
+++ lia64/include/asm-ia64/ptrace_offsets.h	Fri Sep  8 16:35:41 2000
@@ -157,6 +157,7 @@
 #define PT_B4			0x07f0
 #define PT_B5			0x07f8
 
+#define PT_AR_EC		0x0800
 #define PT_AR_LC		0x0808
 
 /* pt_regs */
diff -urN linux-davidm/include/asm-ia64/spinlock.h lia64/include/asm-ia64/spinlock.h
--- linux-davidm/include/asm-ia64/spinlock.h	Fri Sep  8 22:36:14 2000
+++ lia64/include/asm-ia64/spinlock.h	Fri Sep  8 17:14:30 2000
@@ -139,14 +139,24 @@
 			      : "memory");					\
 } while(0)
 
-#define write_lock(rw)				\
-do {						\
-	do {					\
-		while ((rw)->write_lock);	\
-	} while (test_and_set_bit(31, (rw)));	\
-	while ((rw)->read_counter);		\
-	barrier();				\
-} while (0)
+#define write_lock(rw)								\
+do {										\
+ 	__asm__ __volatile__ (							\
+		"mov ar.ccv = r0\n"						\
+		"movl r29 = 0x80000000\n"					\
+		";;\n"								\
+		"1:\n"								\
+		"ld4 r2 = %0\n"							\
+		";;\n"								\
+		"cmp4.eq p0,p7 = r0,r2\n"					\
+		"(p7) br.cond.spnt.few 1b \n"					\
+		IA64_SEMFIX"cmpxchg4.acq r2 = %0, r29, ar.ccv\n"		\
+		";;\n"								\
+		"cmp4.eq p0,p7 = r0, r2\n"					\
+		"(p7) br.cond.spnt.few 1b\n"					\
+		";;\n"								\
+		:: "m" __atomic_fool_gcc((rw)) : "r2", "r29", "memory");	\
+} while(0)
 
 /*
  * clear_bit() has "acq" semantics; we're really need "rel" semantics,
diff -urN linux-davidm/include/asm-ia64/system.h lia64/include/asm-ia64/system.h
--- linux-davidm/include/asm-ia64/system.h	Fri Sep  8 22:36:14 2000
+++ lia64/include/asm-ia64/system.h	Fri Sep  8 17:14:30 2000
@@ -424,33 +424,31 @@
 	if (((next)->thread.flags & (IA64_THREAD_DBG_VALID|IA64_THREAD_PM_VALID))	\
 	    || IS_IA32_PROCESS(ia64_task_regs(next)))					\
 		ia64_load_extra(next);							\
-	ia64_psr(ia64_task_regs(next))->dfh = (ia64_get_fpu_owner() != (next));		\
 	(last) = ia64_switch_to((next));						\
 } while (0)
 
 #ifdef CONFIG_SMP 
   /*
    * In the SMP case, we save the fph state when context-switching
-   * away from a thread that owned and modified fph.  This way, when
-   * the thread gets scheduled on another CPU, the CPU can pick up the
-   * state frm task->thread.fph, avoiding the complication of having
-   * to fetch the latest fph state from another CPU.  If the thread
-   * happens to be rescheduled on the same CPU later on and nobody
-   * else has touched the FPU in the meantime, the thread will fault
-   * upon the first access to fph but since the state in fph is still
-   * valid, no other overheads are incurred.  In other words, CPU
-   * affinity is a Good Thing.
+   * away from a thread that modified fph.  This way, when the thread
+   * gets scheduled on another CPU, the CPU can pick up the state from
+   * task->thread.fph, avoiding the complication of having to fetch
+   * the latest fph state from another CPU.
    */
-# define switch_to(prev,next,last) do {							\
-	if (ia64_get_fpu_owner() = (prev) && ia64_psr(ia64_task_regs(prev))->mfh) {	\
-		ia64_psr(ia64_task_regs(prev))->mfh = 0;				\
-		(prev)->thread.flags |= IA64_THREAD_FPH_VALID;				\
-		__ia64_save_fpu((prev)->thread.fph);					\
-	}										\
-	__switch_to(prev,next,last);							\
+# define switch_to(prev,next,last) do {						\
+	if (ia64_psr(ia64_task_regs(prev))->mfh) {				\
+		ia64_psr(ia64_task_regs(prev))->mfh = 0;			\
+		(prev)->thread.flags |= IA64_THREAD_FPH_VALID;			\
+		__ia64_save_fpu((prev)->thread.fph);				\
+	}									\
+	ia64_psr(ia64_task_regs(prev))->dfh = 1;				\
+	__switch_to(prev,next,last);						\
   } while (0)
 #else
-# define switch_to(prev,next,last) 	__switch_to(prev,next,last)
+# define switch_to(prev,next,last) do {						\
+	ia64_psr(ia64_task_regs(next))->dfh = (ia64_get_fpu_owner() != (next));	\
+	__switch_to(prev,next,last);						\
+} while (0)
 #endif
 
 #endif /* __KERNEL__ */
diff -urN linux-davidm/include/linux/skbuff.h lia64/include/linux/skbuff.h
--- linux-davidm/include/linux/skbuff.h	Thu Aug 24 08:17:48 2000
+++ lia64/include/linux/skbuff.h	Fri Sep  8 17:15:10 2000
@@ -896,7 +896,11 @@
 {
 	struct sk_buff *skb;
 
+#ifdef CONFIG_SKB_BELOW_4GB
+	skb = alloc_skb(length+16, GFP_ATOMIC | GFP_DMA);
+#else
 	skb = alloc_skb(length+16, GFP_ATOMIC);
+#endif
 	if (skb)
 		skb_reserve(skb,16);
 	return skb;


