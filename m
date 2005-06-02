From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 02 Jun 2005 14:25:25 +0000
Subject: Re: flush_icache_range
Message-Id: <429F16D5.7030305@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------060204090909050403050906"
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------060204090909050403050906
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed

Jack Steiner wrote:
> On Thu, Jun 02, 2005 at 02:12:02PM +0200, Zoltan Menyhart wrote:
> 
>>+.Loop:	fc.i	in0			// issuable on M0 only
>>+	add	in0=r21,in0
>> 	br.cloop.sptk.few .Loop
>> 	;;
> 
> 
> I noticed that the flush loop has a single bundle loop. I know
> that this loop was not introduced by your code, but according to 
> Intel, single bundle loops should not be used in performance critical code.
> 
> We ran in to severe performance problems several years ago with single bundle
> loops. IIRC, the details were posted to the ia64 mail list & the 
> resolution was "don't use single bundle loops". I don't know if the performance
> problem exists if the loop contains an fc instruction but you may want
> to unroll the loop one additional cycle. 
> 
> (The problem is that single bundle loops that are not aligned on a
> 0 mod 32 address will run significantly slower (we observed 3X slower) after 
> an interrupt).

Thank you for your remark.

I added a "nop.b. 0" to occupy the original slot of "br".
I hope it is fine that my "br" is shifted to the very last slot:

0xa000000100302d00 <flush_icache_range+64>:     [MIB]       fc.i r32
0xa000000100302d01 <flush_icache_range+65>:                 add r32=r21,r32
0xa000000100302d02 <flush_icache_range+66>:                 nop.b 0x0
0xa000000100302d10 <flush_icache_range+80>:     [MFB]       nop.m 0x0
0xa000000100302d11 <flush_icache_range+81>:                 nop.f 0x0
0xa000000100302d12 <flush_icache_range+82>:                 br.cloop.sptk.few 0xa000000100302d00
									<flush_icache_range+64>;;

Zoltan


--------------060204090909050403050906
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
 name="diff2"
Content-Disposition: inline;
 filename="diff2"

--- linux-2.6.11-orig/arch/ia64/lib/flush.S	2005-04-26 15:59:49.000000000 +0200
+++ linux-2.6.11/arch/ia64/lib/flush.S	2005-06-02 16:12:08.655606148 +0200
@@ -3,37 +3,57 @@
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
+
+	/*
+	 * 32 byte aligned loop, even number of (actually 2) bundles
+	 */
+.Loop:	fc.i	in0			// issuable on M0 only
+	add	in0=r21,in0
+	nop.b	0
 	br.cloop.sptk.few .Loop
 	;;
+
 	sync.i
 	;;
 	srlz.i
 	;;
-	mov ar.lc=r3			// restore ar.lc
+	mov	ar.lc=r3		// restore ar.lc
 	br.ret.sptk.many rp
 END(flush_icache_range)
--- linux-2.6.11-orig/arch/ia64/kernel/setup.c	2005-04-26 15:59:49.000000000 +0200
+++ linux-2.6.11/arch/ia64/kernel/setup.c	2005-06-02 13:55:23.448675412 +0200
@@ -15,6 +15,7 @@
  * 02/01/00 R.Seth	fixed get_cpuinfo for SMP
  * 01/07/99 S.Eranian	added the support for command line argument
  * 06/24/99 W.Drummond	added boot_cpu_data.
+ * 05/28/05 Z. Menyhart	Dynamic stride size for "flush_icache_range()"
  */
 #include <linux/config.h>
 #include <linux/module.h>
@@ -78,6 +79,13 @@
 EXPORT_SYMBOL(io_space);
 unsigned int num_io_spaces;
 
+/*
+ * "flush_icache_range()" needs to know what processor dependent stride size to use
+ * when it makes i-cache(s) coherent with d-caches.
+ */
+#define	LOG_2_I_CACHE_STRIDE_SIZE	5	/* Safest way to go: 32 bytes by 32 bytes */
+unsigned long log_2_i_cache_stride_size = ~0;
+
 unsigned char aux_device_present = 0xaa;        /* XXX remove this when legacy I/O is gone */
 
 /*
@@ -624,6 +632,34 @@
 		ia64_max_cacheline_size = max;
 }
 
+
+/*
+ * "flush_icache_range()" needs to know what processor dependent stride size to use
+ * when it makes i-cache(s) coherent with d-caches.
+ * The minimum of the i-cache stride sizes is calculated.
+ */
+static void
+get_i_cache_stride_size (void)
+{
+	pal_cache_config_info_t cci;
+	s64 status;
+
+	/*
+	 * We assume that the stride size of the L2I cache (if exixt) is the same as
+	 * that of the L1I cache.
+	 */
+	status = ia64_pal_cache_config_info(/* cache_level ( 0 means L1 ) */ 0,
+					    /* cache_type (instruction)= */ 1, &cci);
+	if (status != 0) {
+		printk(KERN_ERR
+		       "%s: ia64_pal_cache_config_info(L1I) failed (status=%ld CPU=%d)\n",
+		       __FUNCTION__, status, smp_processor_id());
+		cci.pcci_stride = LOG_2_I_CACHE_STRIDE_SIZE;
+	}
+	if (cci.pcci_stride < log_2_i_cache_stride_size)
+		log_2_i_cache_stride_size = cci.pcci_stride;
+}
+
 /*
  * cpu_init() initializes state that is per-CPU.  This function acts
  * as a 'CPU state barrier', nothing should get across.
@@ -649,6 +685,7 @@
 		    ia64_tpa(cpu_data) - (long) __per_cpu_start);
 
 	get_max_cacheline_size();
+	get_i_cache_stride_size();
 
 	/*
 	 * We can't pass "local_cpu_data" to identify_cpu() because we haven't called

--------------060204090909050403050906--
