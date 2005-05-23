From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 23 May 2005 13:43:16 +0000
Subject: Re: flush_icache_range
Message-Id: <4291DDF4.9060107@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------040000020006090207080804"
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------040000020006090207080804
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed

The Itanium 2 processor Reference Manual for SW development & optimization
(May 2004) says in the chapter 5.8:

"In Itanium 2 processor, each fc will invalidate 128 bytes corresponding
to the L3 cache line size. Since both the L1I and L1D have line sizes of
64 bytes, a single fc instruction can invalidate two lines."

Can someone please confirm that an equivalent statement is true for the
"fc.i", too ?
Say:

"In Itanium 2 processor, each fc.i instruction will ensure that 128 bytes
(corresponding to the L3 cache line size) of the I-cache(s) be coherent with
the data caches. Since the L1I cache has line sizes of 64 bytes, a single
fc.i instruction can make coherent two lines."


This gave me the idea to try with 128-byte strides
(the measures are repeated for 10 times):

Modified in d-cache:
cycles = 19,164 time = 14.782 usec
cycles = 18,060 time = 13.930 usec
cycles = 16,929 time = 13.058 usec
cycles = 17,597 time = 13.573 usec
cycles = 17,163 time = 13.239 usec
cycles = 16,990 time = 13.105 usec
cycles = 17,427 time = 13.442 usec
cycles = 17,028 time = 13.134 usec
cycles = 16,993 time = 13.107 usec
cycles = 16,930 time = 13.059 usec

Valid:
cycles = 13,514 time = 10.424 usec
cycles = 13,518 time = 10.427 usec
cycles = 13,518 time = 10.427 usec
cycles = 13,518 time = 10.427 usec
cycles = 13,518 time = 10.427 usec
cycles = 13,746 time = 10.603 usec
cycles = 13,866 time = 10.695 usec
cycles = 13,830 time = 10.668 usec
cycles = 13,790 time = 10.637 usec
cycles = 13,830 time = 10.668 usec

Invalid:
cycles = 13,794 time = 10.640 usec
cycles = 13,790 time = 10.637 usec
cycles = 13,830 time = 10.668 usec
cycles = 13,830 time = 10.668 usec
cycles = 13,966 time = 10.773 usec
cycles = 13,994 time = 10.794 usec
cycles = 14,074 time = 10.856 usec
cycles = 13,574 time = 10.470 usec
cycles = 13,902 time = 10.723 usec
cycles = 14,114 time = 10.887 usec

I got these incredibly low number of cycles,
compared to my previous results:

With a 32-byte stride:

Modified in d-cache: cycles = 215 K, time = 169 usec
Valid:               cycles = 222 K, time = 171 usec
Invalid:             cycles = 222 K, time = 171 usec

With a 64-byte stride:

Modified in d-cache: cycles = 63 K, time = 49 usec
Valid:               cycles = 116 K, time = 89 usec
Invalid:             cycles = 116 K, time = 89 usec 


This is a Tiger box with the following CPUs:
processor  : 0
vendor     : GenuineIntel
arch       : IA-64
family     : Itanium 2
model      : 1
revision   : 5
archrev    : 0
features   : branchlong
cpu number : 0
cpu regs   : 4
cpu MHz    : 1296.435998
itc MHz    : 1296.435998
BogoMIPS   : 1941.96
etc...

Can these results be real?

Thanks,

Zoltan



--------------040000020006090207080804
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
 name="diff"
Content-Disposition: inline;
 filename="diff"

--- linux-2.6.11-orig/arch/ia64/lib/flush.S	2005-04-26 15:59:49.000000000 +0200
+++ linux-2.6.11/arch/ia64/lib/flush.S	2005-05-23 15:30:24.891935385 +0200
@@ -7,6 +7,22 @@
 #include <asm/asmmacro.h>
 #include <asm/page.h>
 
+
+#if	defined(CONFIG_ITANIUM)
+#define CACHE_SHIFT	5
+#else
+/*
+ * In Itanium 2 processor, each fc.i instruction will ensure that 128 bytes
+ * (corresponding to the L3 cache line size) of the I-cache(s) be coherent with
+ * the data caches. Since the L1I cache has line sizes of 64 bytes, a single
+ * fc.i instruction can make coherent two lines.
+ */
+#define CACHE_SHIFT	7
+#endif
+
+#define	CACHE_BYTES	(1 << CACHE_SHIFT)
+
+
 	/*
 	 * flush_icache_range(start,end)
 	 *	Must flush range from start to end-1 but nothing else (need to
@@ -17,7 +33,7 @@
 	alloc r2=ar.pfs,2,0,0,0
 	sub r8=in1,in0,1
 	;;
-	shr.u r8=r8,5			// we flush 32 bytes per iteration
+	shr.u r8=r8,CACHE_SHIFT		// we flush CACHE_BYTES bytes per iteration
 	.save ar.lc, r3
 	mov r3=ar.lc			// save ar.lc
 	;;
@@ -26,8 +42,8 @@
 
 	mov ar.lc=r8
 	;;
-.Loop:	fc in0				// issuable on M0 only
-	add in0=32,in0
+.Loop:	fc.i in0			// issuable on M0 only
+	add in0=CACHE_BYTES,in0
 	br.cloop.sptk.few .Loop
 	;;
 	sync.i

--------------040000020006090207080804--
