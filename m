From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 15 Dec 2001 05:13:46 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.16)
Message-Id: <marc-linux-ia64-105590698805702@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

An updated ia64 patch for 2.4.16 is now available at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/ in file:

        linux-2.4.16-ia64-011214.diff*

change log (relative to 2.4.16+ia64-011128):

	- Add /proc/sal/ support (Jesse Barnes)
	- Add memory barrier before releasing a lock with clear_bit (Jack Steiner).
	- Cache-align BKL (Jack Steiner).
	- Fix kernel exit path to deliver only one signal at a time.
	- Disable interrupts during re-scheduling & signal delivery checking.
	- Fix performance bug in SW I/O TLB (Tony Luck)
	- Fix couple of buglets in simeth and simserial (Stephane & me)
	- Don't call consoles on APs until CPU is fully initialized
	  (Andrew Morton, NOMURA, Jun'ichi, me)

Enjoy,

	--david

diff -urN linux-davidm/arch/ia64/kernel/Makefile lia64-2.4/arch/ia64/kernel/Makefile
--- linux-davidm/arch/ia64/kernel/Makefile	Mon Nov 26 11:18:20 2001
+++ lia64-2.4/arch/ia64/kernel/Makefile	Fri Dec 14 15:48:59 2001
@@ -14,7 +14,7 @@
 export-objs := ia64_ksyms.o
 
 obj-y := acpi.o entry.o gate.o efi.o efi_stub.o ia64_ksyms.o irq.o irq_ia64.o irq_lsapic.o ivt.o \
-	 machvec.o pal.o process.o perfmon.o ptrace.o sal.o semaphore.o setup.o	\
+	 machvec.o pal.o process.o perfmon.o ptrace.o sal.o salinfo.o semaphore.o setup.o	 \
 	 signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o
 obj-$(CONFIG_IA64_GENERIC) += iosapic.o
 obj-$(CONFIG_IA64_DIG) += iosapic.o
diff -urN linux-davidm/arch/ia64/kernel/entry.S lia64-2.4/arch/ia64/kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Mon Nov 26 11:18:20 2001
+++ lia64-2.4/arch/ia64/kernel/entry.S	Tue Dec  4 19:35:07 2001
@@ -521,6 +521,8 @@
 	;;
 	mov.ret.sptk rp=r14,.restart
 .restart:
+	// need_resched and signals atomic test
+(pUser)	rsm psr.i
 	adds r17=IA64_TASK_NEED_RESCHED_OFFSET,r13
 	adds r18=IA64_TASK_SIGPENDING_OFFSET,r13
 #ifdef CONFIG_PERFMON
@@ -539,8 +541,6 @@
 (pUser)	cmp.ne.unc p7,p0=r17,r0			// current->need_resched != 0?
 (pUser)	cmp.ne.unc p8,p0=r18,r0			// current->sigpending != 0?
 	;;
-	adds r2=PT(R8)+16,r12
-	adds r3=PT(R9)+16,r12
 #ifdef CONFIG_PERFMON
 (p9)	br.call.spnt.many b7=pfm_block_on_overflow
 #endif
@@ -549,7 +549,10 @@
 #else
 (p7)	br.call.spnt.many b7=schedule
 #endif
-(p8)	br.call.spnt.many b7=handle_signal_delivery	// check & deliver pending signals
+(p8)	br.call.spnt.many rp=handle_signal_delivery	// check & deliver pending signals (once)
+	;;
+.ret9:	adds r2=PT(R8)+16,r12
+	adds r3=PT(R9)+16,r12
 	;;
 	// start restoring the state saved on the kernel stack (struct pt_regs):
 	ld8.fill r8=[r2],16
@@ -582,7 +585,7 @@
 	ld8.fill r30=[r2],16
 	ld8.fill r31=[r3],16
 	;;
-	rsm psr.i | psr.ic	// initiate turning off of interrupts & interruption collection
+	rsm psr.i | psr.ic	// initiate turning off of interrupt and interruption collection
 	invala			// invalidate ALAT
 	;;
 	ld8 r1=[r2],16		// ar.ccv
@@ -601,7 +604,7 @@
 	mov ar.fpsr=r13
 	mov b0=r14
 	;;
-	srlz.i			// ensure interrupts & interruption collection are off
+	srlz.i			// ensure interruption collection is off
 	mov b7=r15
 	;;
 	bsw.0			// switch back to bank 0
diff -urN linux-davidm/arch/ia64/kernel/irq.c lia64-2.4/arch/ia64/kernel/irq.c
--- linux-davidm/arch/ia64/kernel/irq.c	Fri Dec 14 20:03:42 2001
+++ lia64-2.4/arch/ia64/kernel/irq.c	Mon Dec  3 11:07:11 2001
@@ -291,6 +291,7 @@
 				break;
 
 		/* Duh, we have to loop. Release the lock to avoid deadlocks */
+		smp_mb__before_clear_bit();	/* need barrier before releasing lock... */
 		clear_bit(0,&global_irq_lock);
 
 		for (;;) {
diff -urN linux-davidm/arch/ia64/kernel/sal.c lia64-2.4/arch/ia64/kernel/sal.c
--- linux-davidm/arch/ia64/kernel/sal.c	Mon Nov 26 11:18:21 2001
+++ lia64-2.4/arch/ia64/kernel/sal.c	Fri Dec 14 15:50:57 2001
@@ -18,7 +18,8 @@
 #include <asm/sal.h>
 #include <asm/pal.h>
 
-spinlock_t sal_lock = SPIN_LOCK_UNLOCKED;
+spinlock_t sal_lock __cacheline_aligned = SPIN_LOCK_UNLOCKED;
+unsigned long sal_platform_features;
 
 static struct {
 	void *addr;	/* function entry point */
@@ -76,7 +77,7 @@
 	return str;
 }
 
-static void __init 
+static void __init
 ia64_sal_handler_init (void *entry_point, void *gpval)
 {
 	/* fill in the SAL procedure descriptor and point ia64_sal to it: */
@@ -102,7 +103,7 @@
 	if (strncmp(systab->signature, "SST_", 4) != 0)
 		printk("bad signature in system table!");
 
-	/* 
+	/*
 	 * revisions are coded in BCD, so %x does the job for us
 	 */
 	printk("SAL v%x.%02x: oem=%.32s, product=%.32s\n",
@@ -152,12 +153,12 @@
 		      case SAL_DESC_PLATFORM_FEATURE:
 		      {
 			      struct ia64_sal_desc_platform_feature *pf = (void *) p;
+			      sal_platform_features = pf->feature_mask;
 			      printk("SAL: Platform features ");
 
-			      if (pf->feature_mask & (1 << 0))
+			      if (pf->feature_mask & IA64_SAL_PLATFORM_FEATURE_BUS_LOCK)
 				      printk("BusLock ");
-
-			      if (pf->feature_mask & (1 << 1)) {
+			      if (pf->feature_mask & IA64_SAL_PLATFORM_FEATURE_IRQ_REDIR_HINT) {
 				      printk("IRQ_Redirection ");
 #ifdef CONFIG_SMP
 				      if (no_int_routing)
@@ -166,15 +167,17 @@
 					      smp_int_redirect |= SMP_IRQ_REDIRECTION;
 #endif
 			      }
-			      if (pf->feature_mask & (1 << 2)) {
+			      if (pf->feature_mask & IA64_SAL_PLATFORM_FEATURE_IPI_REDIR_HINT) {
 				      printk("IPI_Redirection ");
 #ifdef CONFIG_SMP
-				      if (no_int_routing) 
+				      if (no_int_routing)
 					      smp_int_redirect &= ~SMP_IPI_REDIRECTION;
 				      else
 					      smp_int_redirect |= SMP_IPI_REDIRECTION;
 #endif
 			      }
+			      if (pf->feature_mask & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT)
+				      printk("ITC_Drift ");
 			      printk("\n");
 			      break;
  		      }
diff -urN linux-davidm/arch/ia64/kernel/salinfo.c lia64-2.4/arch/ia64/kernel/salinfo.c
--- linux-davidm/arch/ia64/kernel/salinfo.c	Wed Dec 31 16:00:00 1969
+++ lia64-2.4/arch/ia64/kernel/salinfo.c	Fri Dec 14 20:07:14 2001
@@ -0,0 +1,105 @@
+/*
+ * salinfo.c
+ *
+ * Creates entries in /proc/sal for various system features.
+ *
+ * Copyright (c) 2001 Silicon Graphics, Inc.  All rights reserved.
+ *
+ * 10/30/2001	jbarnes@sgi.com		copied much of Stephane's palinfo
+ *					code to create this file
+ */
+
+#include <linux/types.h>
+#include <linux/proc_fs.h>
+#include <linux/module.h>
+
+#include <asm/sal.h>
+
+MODULE_AUTHOR("Jesse Barnes <jbarnes@sgi.com>");
+MODULE_DESCRIPTION("/proc interface to IA-64 SAL features");
+MODULE_LICENSE("GPL");
+
+int salinfo_read(char *page, char **start, off_t off, int count, int *eof, void *data);
+
+typedef struct {
+	const char		*name;		/* name of the proc entry */
+	unsigned long           feature;        /* feature bit */
+	struct proc_dir_entry	*entry;		/* registered entry (removal) */
+} salinfo_entry_t;
+
+/*
+ * List {name,feature} pairs for every entry in /proc/sal/<feature>
+ * that this module exports
+ */
+static salinfo_entry_t salinfo_entries[]={
+	{ "bus_lock",           IA64_SAL_PLATFORM_FEATURE_BUS_LOCK, },
+	{ "irq_redirection",	IA64_SAL_PLATFORM_FEATURE_IRQ_REDIR_HINT, },
+	{ "ipi_redirection",	IA64_SAL_PLATFORM_FEATURE_IPI_REDIR_HINT, },
+	{ "itc_drift",		IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT, },
+};
+
+#define NR_SALINFO_ENTRIES (sizeof(salinfo_entries)/sizeof(salinfo_entry_t))
+
+/*
+ * One for each feature and one more for the directory entry...
+ */
+static struct proc_dir_entry *salinfo_proc_entries[NR_SALINFO_ENTRIES + 1];
+
+static int __init
+salinfo_init(void)
+{
+	struct proc_dir_entry *salinfo_dir; /* /proc/sal dir entry */
+	struct proc_dir_entry **sdir = salinfo_proc_entries; /* keeps track of every entry */
+	int i;
+
+	salinfo_dir = proc_mkdir("sal", NULL);
+
+	for (i=0; i < NR_SALINFO_ENTRIES; i++) {
+		/* pass the feature bit in question as misc data */
+		*sdir++ = create_proc_read_entry (salinfo_entries[i].name, 0, salinfo_dir,
+						  salinfo_read, (void *)salinfo_entries[i].feature);
+	}
+	*sdir++ = salinfo_dir;
+
+	return 0;
+}
+
+static void __exit
+salinfo_exit(void)
+{
+	int i = 0;
+
+	for (i = 0; i < NR_SALINFO_ENTRIES ; i++) {
+		if (salinfo_proc_entries[i])
+			remove_proc_entry (salinfo_proc_entries[i]->name, NULL);
+	}
+}
+
+/*
+ * 'data' contains an integer that corresponds to the feature we're
+ * testing
+ */
+static int
+salinfo_read(char *page, char **start, off_t off, int count, int *eof, void *data)
+{
+	int len = 0;
+
+	MOD_INC_USE_COUNT;
+
+	len = sprintf(page, (sal_platform_features & (unsigned long)data) ? "1\n" : "0\n");
+
+	if (len <= off+count) *eof = 1;
+
+	*start = page + off;
+	len   -= off;
+
+	if (len>count) len = count;
+	if (len<0) len = 0;
+
+	MOD_DEC_USE_COUNT;
+
+	return len;
+}
+
+module_init(salinfo_init);
+module_exit(salinfo_exit);
diff -urN linux-davidm/arch/ia64/kernel/smp.c lia64-2.4/arch/ia64/kernel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Mon Nov 26 11:18:24 2001
+++ lia64-2.4/arch/ia64/kernel/smp.c	Fri Dec 14 14:13:03 2001
@@ -51,7 +51,7 @@
 #include <asm/mca.h>
 
 /* The 'big kernel lock' */
-spinlock_t kernel_flag = SPIN_LOCK_UNLOCKED;
+spinlock_t kernel_flag __cacheline_aligned = SPIN_LOCK_UNLOCKED;
 
 /*
  * Structure and data for smp_call_function(). This is designed to minimise static memory
diff -urN linux-davidm/arch/ia64/lib/swiotlb.c lia64-2.4/arch/ia64/lib/swiotlb.c
--- linux-davidm/arch/ia64/lib/swiotlb.c	Fri Dec 14 20:03:42 2001
+++ lia64-2.4/arch/ia64/lib/swiotlb.c	Mon Dec  3 13:52:19 2001
@@ -27,6 +27,16 @@
 #define ALIGN(val, align) ((unsigned long)	\
 	(((unsigned long) (val) + ((align) - 1)) & ~((align) - 1)))
 
+#define OFFSET(val,align) ((unsigned long)	\
+	                   ( (val) & ( (align) - 1)))
+
+/*
+ * Maximum allowable number of contiguous slabs to map, 
+ * must be a power of 2.  What is the appropriate value ?
+ * The complexity of {map,unmap}_single is linearly dependent on this value.
+ */ 
+#define IO_TLB_SEGSIZE	128
+
 /*
  * log of the size of each IO TLB slab.  The number of slabs is command line controllable.
  */
@@ -65,10 +75,15 @@
 setup_io_tlb_npages (char *str)
 {
 	io_tlb_nslabs = simple_strtoul(str, NULL, 0) << (PAGE_SHIFT - IO_TLB_SHIFT);
+
+	/* avoid tail segment of size < IO_TLB_SEGSIZE */  
+	io_tlb_nslabs = ALIGN(io_tlb_nslabs, IO_TLB_SEGSIZE);
+
 	return 1;
 }
 __setup("swiotlb=", setup_io_tlb_npages);
 
+
 /*
  * Statically reserve bounce buffer space and initialize bounce buffer data structures for
  * the software IO TLB used to implement the PCI DMA API.
@@ -88,12 +103,12 @@
 
 	/*
 	 * Allocate and initialize the free list array.  This array is used
-	 * to find contiguous free memory regions of size 2^IO_TLB_SHIFT between
-	 * io_tlb_start and io_tlb_end.
+	 * to find contiguous free memory regions of size up to IO_TLB_SEGSIZE
+	 * between io_tlb_start and io_tlb_end.
 	 */
 	io_tlb_list = alloc_bootmem(io_tlb_nslabs * sizeof(int));
 	for (i = 0; i < io_tlb_nslabs; i++)
-		io_tlb_list[i] = io_tlb_nslabs - i;
+ 		io_tlb_list[i] = IO_TLB_SEGSIZE - OFFSET(i, IO_TLB_SEGSIZE);
 	io_tlb_index = 0;
 	io_tlb_orig_addr = alloc_bootmem(io_tlb_nslabs * sizeof(char *));
 
@@ -120,7 +135,7 @@
 	if (size > (1 << PAGE_SHIFT))
 		stride = (1 << (PAGE_SHIFT - IO_TLB_SHIFT));
 	else
-		stride = nslots;
+		stride = 1; 
 
 	if (!nslots)
 		BUG();
@@ -147,7 +162,8 @@
 
 				for (i = index; i < index + nslots; i++)
 					io_tlb_list[i] = 0;
-				for (i = index - 1; (i >= 0) && io_tlb_list[i]; i--)
+				for (i = index - 1; (OFFSET(i, IO_TLB_SEGSIZE) != IO_TLB_SEGSIZE -1)
+				       && io_tlb_list[i]; i--)
 					io_tlb_list[i] = ++count;
 				dma_addr = io_tlb_start + (index << IO_TLB_SHIFT);
 
@@ -213,7 +229,8 @@
 	 */
 	spin_lock_irqsave(&io_tlb_lock, flags);
 	{
-		int count = ((index + nslots) < io_tlb_nslabs ? io_tlb_list[index + nslots] : 0);
+		int count = ((index + nslots) < ALIGN(index + 1, IO_TLB_SEGSIZE) ?
+			     io_tlb_list[index + nslots] : 0);
 		/*
 		 * Step 1: return the slots to the free list, merging the slots with
 		 * superceeding slots
@@ -224,7 +241,8 @@
 		 * Step 2: merge the returned slots with the preceeding slots, if
 		 * available (non zero)
 		 */
-		for (i = index - 1; (i >= 0) && io_tlb_list[i]; i--)
+		for (i = index - 1;  (OFFSET(i, IO_TLB_SEGSIZE) != IO_TLB_SEGSIZE -1) &&
+		       io_tlb_list[i]; i--)
 			io_tlb_list[i] = ++count;
 	}
 	spin_unlock_irqrestore(&io_tlb_lock, flags);
diff -urN linux-davidm/drivers/char/simserial.c lia64-2.4/drivers/char/simserial.c
--- linux-davidm/drivers/char/simserial.c	Fri Dec 14 20:03:44 2001
+++ lia64-2.4/drivers/char/simserial.c	Mon Dec  3 11:36:02 2001
@@ -958,7 +958,7 @@
 		       state->port, state->irq);
 }
 
-int rs_read_proc(char *page, char **start, off_t off, int count,
+static int rs_read_proc(char *page, char **start, off_t off, int count,
 		 int *eof, void *data)
 {
 	int i, len = 0, l;
diff -urN linux-davidm/drivers/net/simeth.c lia64-2.4/drivers/net/simeth.c
--- linux-davidm/drivers/net/simeth.c	Fri Dec 14 20:03:44 2001
+++ lia64-2.4/drivers/net/simeth.c	Fri Dec 14 14:36:09 2001
@@ -1,16 +1,14 @@
 /*
  * Simulated Ethernet Driver
  *
- * Copyright (C) 1999-2000 Hewlett-Packard Co
- * Copyright (C) 1999-2000 Stephane Eranain <eranian@hpl.hp.com>
+ * Copyright (C) 1999-2001 Hewlett-Packard Co
+ * Copyright (C) 1999-2001 Stephane Eranain <eranian@hpl.hp.com>
  */
 #include <linux/config.h>
 #include <linux/kernel.h>
-#include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/types.h>
 #include <linux/in.h>
-#include <linux/malloc.h>
 #include <linux/string.h>
 #include <linux/init.h>
 #include <linux/errno.h>
@@ -26,7 +24,6 @@
 #include <asm/system.h>
 #include <asm/irq.h>
 
-
 #define SIMETH_RECV_MAX	10
 
 /*
@@ -47,12 +44,7 @@
 
 #define NETWORK_INTR			8
 
-/*
- * This structure is need for the module version
- * It hasn't been tested yet
- */
 struct simeth_local {
-	struct net_device	*next_module;
 	struct net_device_stats stats;
 	int 			simfd;	 /* descriptor in the simulator */
 };
@@ -67,7 +59,7 @@
 static void set_multicast_list(struct net_device *dev);
 static int simeth_device_event(struct notifier_block *this,unsigned long event, void *ptr);
 
-static char *simeth_version="v0.2";
+static char *simeth_version="0.3";
 
 /*
  * This variable is used to establish a mapping between the Linux/ia64 kernel
@@ -89,7 +81,7 @@
 
 
 static volatile unsigned int card_count; /* how many cards "found" so far */
-static int simeth_debug=0;		/* set to 1 to get debug information */
+static int simeth_debug;		/* set to 1 to get debug information */
 
 /*
  * Used to catch IFF_UP & IFF_DOWN events
@@ -122,7 +114,15 @@
 int __init
 simeth_probe (void)
 {
-	return simeth_probe1();
+	int r;
+
+	printk("simeth: v%s\n", simeth_version);
+
+	r = simeth_probe1();
+
+	if (r = 0) register_netdevice_notifier(&simeth_dev_notifier);
+
+	return r;
 }
 
 extern long ia64_ssc (long, long, long, long, int);
@@ -194,7 +194,7 @@
 	int fd, i;
 
 	/*
-	 * XXX Fix me 
+	 * XXX Fix me
 	 * let's support just one card for now
 	 */
 	if (test_and_set_bit(0, &card_count))
@@ -225,7 +225,6 @@
 
 	local = dev->priv;
 	local->simfd = fd; /* keep track of underlying file descriptor */
-	local->next_module = NULL;
 
 	dev->open		= simeth_open;
 	dev->stop		= simeth_close;
@@ -236,24 +235,13 @@
 	/* Fill in the fields of the device structure with ethernet-generic values. */
 	ether_setup(dev);
 
-	printk("simeth:  %s alpha\n", simeth_version);
 	printk("%s: hosteth=%s simfd=%d, HwAddr", dev->name, simeth_device, local->simfd);
 	for(i = 0; i < ETH_ALEN; i++) {
 		printk(" %2.2x", dev->dev_addr[i]);
 	}
 	printk(", IRQ %d\n", dev->irq);
 
-#ifdef MODULE
-	local->next_module = simeth_dev;
-	simeth_dev  = dev;
-#endif
-	/*
-	 * XXX Fix me
-	 * would not work with more than one device !
-	 */
-	register_netdevice_notifier(&simeth_dev_notifier);
-
-	return 0;
+		return 0;
 }
 
 /*
@@ -268,7 +256,6 @@
 	}
 
 	netif_start_queue(dev);
-	MOD_INC_USE_COUNT;
 
 	return 0;
 }
@@ -355,8 +342,6 @@
 
 	free_irq(dev->irq, dev);
 
-	MOD_DEC_USE_COUNT;
-
 	return 0;
 }
 
@@ -545,52 +530,4 @@
 }
 #endif
 
-
-#ifdef MODULE
-static int
-simeth_init(void)
-{
-	unsigned int cards_found = 0;
-
-	/* iterate over probe */
-
-	while ( simeth_probe1() = 0 ) cards_found++;
-
-	return cards_found ? 0 : -ENODEV;
-}
-
-
-int
-init_module(void)
-{
-	simeth_dev = NULL;
-
-	/* the register_netdev is done "indirectly by ether_initdev() */
-
-	return simeth_init();
-}
-
-void
-cleanup_module(void)
-{
-	struct net_device *next;
-
-	while ( simeth_dev ) {
-
-		next = ((struct simeth_private *)simeth_dev->priv)->next_module;
-
-		unregister_netdev(simeth_dev);
-
-		kfree(simeth_dev);
-
-		simeth_dev = next;
-	}
-	/*
-	 * XXX fix me
-	 * not clean wihen multiple devices
-	 */
-	unregister_netdevice_notifier(&simeth_dev_notifier);
-}
-#else /* !MODULE */
 __initcall(simeth_probe);
-#endif /* !MODULE */
diff -urN linux-davidm/include/asm-ia64/bitops.h lia64-2.4/include/asm-ia64/bitops.h
--- linux-davidm/include/asm-ia64/bitops.h	Tue Jul 31 10:30:09 2001
+++ lia64-2.4/include/asm-ia64/bitops.h	Fri Dec 14 17:16:48 2001
@@ -57,10 +57,10 @@
 }
 
 /*
- * clear_bit() doesn't provide any barrier for the compiler.
+ * clear_bit() has "acquire" semantics.
  */
 #define smp_mb__before_clear_bit()	smp_mb()
-#define smp_mb__after_clear_bit()	smp_mb()
+#define smp_mb__after_clear_bit()	do { /* skip */; } while (0)
 
 /**
  * clear_bit - Clears a bit in memory
diff -urN linux-davidm/include/asm-ia64/hardirq.h lia64-2.4/include/asm-ia64/hardirq.h
--- linux-davidm/include/asm-ia64/hardirq.h	Fri Dec 14 20:03:45 2001
+++ lia64-2.4/include/asm-ia64/hardirq.h	Fri Dec 14 17:21:51 2001
@@ -70,6 +70,7 @@
 	/* if we didn't own the irq lock, just ignore.. */
 	if (global_irq_holder = cpu) {
 		global_irq_holder = NO_PROC_ID;
+		smp_mb__before_clear_bit();	/* need barrier before releasing lock... */
 		clear_bit(0,&global_irq_lock);
         }
 }
diff -urN linux-davidm/include/asm-ia64/sal.h lia64-2.4/include/asm-ia64/sal.h
--- linux-davidm/include/asm-ia64/sal.h	Mon Nov 26 11:19:18 2001
+++ lia64-2.4/include/asm-ia64/sal.h	Fri Dec 14 17:57:29 2001
@@ -149,6 +149,7 @@
 #define IA64_SAL_PLATFORM_FEATURE_BUS_LOCK		(1 << 0)
 #define IA64_SAL_PLATFORM_FEATURE_IRQ_REDIR_HINT	(1 << 1)
 #define IA64_SAL_PLATFORM_FEATURE_IPI_REDIR_HINT	(1 << 2)
+#define IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT	 	(1 << 3)
 
 typedef struct ia64_sal_desc_platform_feature {
 	u8 type;
@@ -775,5 +776,7 @@
 		*scratch_buf_size_needed = isrv.v1;
 	return isrv.status;
 }
+
+extern unsigned long sal_platform_features;
 
 #endif /* _ASM_IA64_PAL_H */
diff -urN linux-davidm/include/asm-ia64/spinlock.h lia64-2.4/include/asm-ia64/spinlock.h
--- linux-davidm/include/asm-ia64/spinlock.h	Fri Dec 14 20:03:47 2001
+++ lia64-2.4/include/asm-ia64/spinlock.h	Fri Dec 14 17:21:40 2001
@@ -159,10 +159,10 @@
 		:: "r"(rw) : "ar.ccv", "p7", "r2", "r29", "memory");		\
 } while(0)
 
-/*
- * clear_bit() has "acq" semantics; we're really need "rel" semantics,
- * but for simplicity, we simply do a fence for now...
- */
-#define write_unlock(x)				({clear_bit(31, (x)); mb();})
+#define write_unlock(x)									\
+({											\
+	smp_mb__before_clear_bit();	/* need barrier before releasing lock... */	\
+	clear_bit(31, (x));								\
+})
 
 #endif /*  _ASM_IA64_SPINLOCK_H */
diff -urN linux-davidm/include/asm-ia64/system.h lia64-2.4/include/asm-ia64/system.h
--- linux-davidm/include/asm-ia64/system.h	Mon Nov 26 11:19:18 2001
+++ lia64-2.4/include/asm-ia64/system.h	Fri Dec 14 11:02:39 2001
@@ -405,6 +405,10 @@
 	ia64_psr(ia64_task_regs(prev))->dfh = 1;				\
 	__switch_to(prev,next,last);						\
   } while (0)
+
+/* Return true if this CPU can call the console drivers in printk() */
+#define arch_consoles_callable() (cpu_online_map & (1UL << smp_processor_id()))
+
 #else
 # define switch_to(prev,next,last) do {						\
 	ia64_psr(ia64_task_regs(next))->dfh = (ia64_get_fpu_owner() != (next));	\
diff -urN linux-davidm/kernel/printk.c lia64-2.4/kernel/printk.c
--- linux-davidm/kernel/printk.c	Fri Dec 14 20:03:47 2001
+++ lia64-2.4/kernel/printk.c	Fri Dec 14 11:02:39 2001
@@ -38,6 +38,10 @@
 
 #define LOG_BUF_MASK	(LOG_BUF_LEN-1)
 
+#ifndef arch_consoles_callable
+#define arch_consoles_callable() (1)
+#endif
+
 /* printk's without a loglevel use this.. */
 #define DEFAULT_MESSAGE_LOGLEVEL 4 /* KERN_WARNING */
 
@@ -445,6 +449,14 @@
 			log_level_unknown = 1;
 	}
 
+	if (!arch_consoles_callable()) {
+		/*
+		 * On some architectures, the consoles are not usable
+		 * on secondary CPUs early in the boot process.
+		 */
+		spin_unlock_irqrestore(&logbuf_lock, flags);
+		goto out;
+	}
 	if (!down_trylock(&console_sem)) {
 		/*
 		 * We own the drivers.  We can drop the spinlock and let
@@ -461,6 +473,7 @@
 		 */
 		spin_unlock_irqrestore(&logbuf_lock, flags);
 	}
+out:
 	return printed_len;
 }
 EXPORT_SYMBOL(printk);

