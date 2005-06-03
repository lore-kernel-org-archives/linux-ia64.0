From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 03 Jun 2005 12:35:52 +0000
Subject: Re: flush_icache_range
Message-Id: <42A04EA8.8090507@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------040602090302050102090908"
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------040602090302050102090908
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed

David, Jim,

Here is my next try. I hope I have not missed out anything.

Thanks,

Zoltan

P.S.: next week I'll be away, should there be some minor problems...

--------------040602090302050102090908
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
 name="diff3"
Content-Disposition: inline;
 filename="diff3"

--- linux-2.6.11-orig/arch/ia64/lib/flush.S	2005-04-26 15:59:49.000000000 +0200
+++ linux-2.6.11/arch/ia64/lib/flush.S	2005-06-03 14:11:09.069041791 +0200
@@ -3,37 +3,59 @@
  *
  * Copyright (C) 1999-2001 Hewlett-Packard Co
  * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *
+ * 05/28/05 Zoltan Menyhart	Dynamic stride size
  */
+
 #include <asm/asmmacro.h>
-#include <asm/page.h>
+
 
 	/*
 	 * flush_icache_range(start,end)
-	 *	Must flush range from start to end-1 but nothing else (need to
+	 *
+	 *	Make i-cache(s) coherent with d-caches.
+	 *
+	 *	Must deal with range from start to end-1 but nothing else (need to
 	 *	be careful not to touch addresses that may be unmapped).
+	 *
+	 *	Note: "in0" and "in1" are preserved for debugging purposes.
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
+	movl	r3=ia64_i_cache_stride_shift
+ 	mov	r21=1
+	;;
+	ld8	r20=[r3]		// r20: stride shift
+	sub	r22=in1,r0,1		// last byte address
+	;;
+	shr.u	r23=in0,r20		// start / (stride size)
+	shr.u	r22=r22,r20		// (last byte address) / (stride size)
+	shl	r21=r21,r20		// r21: stride size of the i-cache(s)
+	;;
+	sub	r8=r22,r23		// number of strides - 1
+	shl	r24=r23,r20		// r24: addresses for "fc.i" =
+					//	"start" rounded down to stride boundary
+	.save	ar.lc,r3
+	mov	r3=ar.lc		// save ar.lc
 	;;
 
 	.body
-
-	mov ar.lc=r8
+	mov	ar.lc=r8
 	;;
-.Loop:	fc in0				// issuable on M0 only
-	add in0=32,in0
+	/*
+	 * 32 byte aligned loop, even number of (actually 2) bundles
+	 */
+.Loop:	fc.i	r24			// issuable on M0 only
+	add	r24=r21,r24		// we flush "stride size" bytes per iteration
+	nop.i	0
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
+++ linux-2.6.11/arch/ia64/kernel/setup.c	2005-06-03 14:06:23.779006224 +0200
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
+#define	I_CACHE_STRIDE_SHIFT	5	/* Safest way to go: 32 bytes by 32 bytes */
+unsigned long ia64_i_cache_stride_shift = ~0;
+
 unsigned char aux_device_present = 0xaa;        /* XXX remove this when legacy I/O is gone */
 
 /*
@@ -590,6 +598,12 @@
 	/* start_kernel() requires this... */
 }
 
+/*
+ * Calculate the max. cache line size.
+ *
+ * In addition, the minimum of the i-cache stride sizes is calculated for
+ * "flush_icache_range()".
+ */
 static void
 get_max_cacheline_size (void)
 {
@@ -603,6 +617,8 @@
                 printk(KERN_ERR "%s: ia64_pal_cache_summary() failed (status=%ld)\n",
                        __FUNCTION__, status);
                 max = SMP_CACHE_BYTES;
+		/* Safest setup for "flush_icache_range()" */
+		ia64_i_cache_stride_shift = I_CACHE_STRIDE_SHIFT;
 		goto out;
         }
 
@@ -611,14 +627,31 @@
 						    &cci);
 		if (status != 0) {
 			printk(KERN_ERR
-			       "%s: ia64_pal_cache_config_info(l=%lu) failed (status=%ld)\n",
+			       "%s: ia64_pal_cache_config_info(l=%lu, 2) failed (status=%ld)\n",
 			       __FUNCTION__, l, status);
 			max = SMP_CACHE_BYTES;
+			/* The safest setup for "flush_icache_range()" */
+			cci.pcci_stride = I_CACHE_STRIDE_SHIFT;
+			cci.pcci_unified = 1;
 		}
 		line_size = 1 << cci.pcci_line_size;
 		if (line_size > max)
 			max = line_size;
-        }
+		if (!cci.pcci_unified) {
+			status = ia64_pal_cache_config_info(l,
+						    /* cache_type (instruction)= */ 1,
+						    &cci);
+			if (status != 0) {
+				printk(KERN_ERR
+				"%s: ia64_pal_cache_config_info(l=%lu, 1) failed (status=%ld)\n",
+					__FUNCTION__, l, status);
+				/* The safest setup for "flush_icache_range()" */
+				cci.pcci_stride = I_CACHE_STRIDE_SHIFT;
+			}
+		}
+		if (cci.pcci_stride < ia64_i_cache_stride_shift)
+			ia64_i_cache_stride_shift = cci.pcci_stride;
+	}
   out:
 	if (max > ia64_max_cacheline_size)
 		ia64_max_cacheline_size = max;

--------------040602090302050102090908--
