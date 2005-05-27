From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 27 May 2005 15:45:01 +0000
Subject: Re: flush_icache_range
Message-Id: <4297407D.8030402@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050904030702070709000106"
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------050904030702070709000106
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed

David Mosberger wrote:

> BTW: I would prefer if we picked up the stride from the PAL info.
> That way, we don't have to add ugly #ifdef's and hope that we get the
> right stride.  I just checked on a Madison and, indeed it reports:
> [...]
> So, what we could do is walk through the PAL cache-info, determine the
> minimum stride and store the min. stride in a per-CPU variable.

Well, if we want to get rid of all the #ifdef CONFIG_ITANIUM's...

I propose to support homogeneous systems only.
(Not a real restriction.)
Should any inhomogeneity or error be found, my code falls back to the
old golden stride size of 32 bytes.

> Can you remind me how much data you flushed?

It was a page of 64 Kbytes each time.

Thanks,

Zoltan

--------------050904030702070709000106
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
 name="diff"
Content-Disposition: inline;
 filename="diff"

--- linux-2.6.11-orig/arch/ia64/lib/flush.S	2005-04-26 15:59:49.000000000 +0200
+++ linux-2.6.11/arch/ia64/lib/flush.S	2005-05-27 14:26:15.326080510 +0200
@@ -3,37 +3,51 @@
  *
  * Copyright (C) 1999-2001 Hewlett-Packard Co
  * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *
+ * 05/28/05 Zoltan Menyhart	Dynamic stride size
  */
+
 #include <asm/asmmacro.h>
 #include <asm/page.h>
 
+
 	/*
 	 * flush_icache_range(start,end)
-	 *	Must flush range from start to end-1 but nothing else (need to
+	 *
+	 *	Make i-cache(s) coherent with d-caches.
+	 *
+	 *	Must deal with range from start to end-1 but nothing else (need to
 	 *	be careful not to touch addresses that may be unmapped).
 	 */
 GLOBAL_ENTRY(flush_icache_range)
+
 	.prologue
-	alloc r2=ar.pfs,2,0,0,0
-	sub r8=in1,in0,1
-	;;
-	shr.u r8=r8,5			// we flush 32 bytes per iteration
-	.save ar.lc, r3
-	mov r3=ar.lc			// save ar.lc
+	alloc	r2=ar.pfs,2,0,0,0
+	movl	r3=log_2_i_cache_stride_size
+ 	mov	r21=1
+	;;
+	ld8	r20=[r3]		// r20: log2( stride size of the i-cache(s) )
+	sub	r8=in1,in0,1
+	;;
+	shl	r21=r21,r20		// r21: stride size of the i-cache(s)
+	shr.u	r8=r8,r20		// we flush "stride size" bytes per iteration
+	
+	.save	ar.lc, r3
+	mov	r3=ar.lc		// save ar.lc
 	;;
 
 	.body
 
-	mov ar.lc=r8
+	mov	ar.lc=r8
 	;;
-.Loop:	fc in0				// issuable on M0 only
-	add in0=32,in0
+.Loop:	fc.i	in0			// issuable on M0 only
+	add	in0=r21,in0
 	br.cloop.sptk.few .Loop
 	;;
 	sync.i
 	;;
 	srlz.i
 	;;
-	mov ar.lc=r3			// restore ar.lc
+	mov	ar.lc=r3		// restore ar.lc
 	br.ret.sptk.many rp
 END(flush_icache_range)
--- linux-2.6.11-orig/arch/ia64/kernel/setup.c	2005-04-26 15:59:49.000000000 +0200
+++ linux-2.6.11/arch/ia64/kernel/setup.c	2005-05-27 17:41:04.680429503 +0200
@@ -15,6 +15,7 @@
  * 02/01/00 R.Seth	fixed get_cpuinfo for SMP
  * 01/07/99 S.Eranian	added the support for command line argument
  * 06/24/99 W.Drummond	added boot_cpu_data.
+ * 05/28/05 Z. Menyhart	Dynamic stride size for "flush_icache_range()"
  */
 #include <linux/config.h>
 #include <linux/module.h>
@@ -78,6 +79,14 @@
 EXPORT_SYMBOL(io_space);
 unsigned int num_io_spaces;
 
+/*
+ * "flush_icache_range()" needs to know what processor dependent stride size to use
+ * when it makes i-cache(s) coherent with d-caches.
+ */
+#define	LOG_2_I_CACHE_STRIDE_SIZE	5	/* Safest way to go: 32 bytes by 32 bytes */
+unsigned int log_2_i_cache_stride_size;
+static unsigned int have_found_i_cache_stride_size;	/* Not yet */
+
 unsigned char aux_device_present = 0xaa;        /* XXX remove this when legacy I/O is gone */
 
 /*
@@ -624,6 +633,47 @@
 		ia64_max_cacheline_size = max;
 }
 
+
+/*
+ * "flush_icache_range()" needs to know what processor dependent stride size to use
+ * when it makes i-cache(s) coherent with d-caches.
+ *
+ * Paranoia: all the CPUs are required to have the same stride size.
+ */
+static void
+get_i_cache_stride_size (void)
+{
+        pal_cache_config_info_t cci;
+        s64 status;
+
+        /*
+	 * We assume that the stride size of the L2I cache (if exixt) is the same as
+	 * that of the L1I cache.
+	 */
+	status = ia64_pal_cache_config_info(/* cache_level ( 0 means L1 ) */ 0,
+					    /* cache_type (instruction)= */ 1, &cci);
+	if (status != 0) {
+		printk(KERN_ERR
+		       "%s: ia64_pal_cache_config_info(L1I) failed (status=%ld CPU=%d)\n",
+		       __FUNCTION__, status, smp_processor_id());
+		log_2_i_cache_stride_size = LOG_2_I_CACHE_STRIDE_SIZE;
+		return;
+	}
+	if (have_found_i_cache_stride_size) {
+		if (log_2_i_cache_stride_size != cci.pcci_stride) {
+			printk(KERN_ERR
+			       "%s: L1I cache stride size %d on CPU %d is incoherent "
+			       "with previously seen value %d\n",
+			       __FUNCTION__, 1 << cci.pcci_stride, smp_processor_id(),
+			       1 << log_2_i_cache_stride_size);
+			log_2_i_cache_stride_size = LOG_2_I_CACHE_STRIDE_SIZE;
+		}
+		return;
+	}
+	log_2_i_cache_stride_size = cci.pcci_stride;
+	have_found_i_cache_stride_size = 1;
+}
+
 /*
  * cpu_init() initializes state that is per-CPU.  This function acts
  * as a 'CPU state barrier', nothing should get across.
@@ -649,6 +699,7 @@
 		    ia64_tpa(cpu_data) - (long) __per_cpu_start);
 
 	get_max_cacheline_size();
+	get_i_cache_stride_size();
 
 	/*
 	 * We can't pass "local_cpu_data" to identify_cpu() because we haven't called

--------------050904030702070709000106--
