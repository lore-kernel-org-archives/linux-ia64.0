From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 20 May 2005 14:17:51 +0000
Subject: Re: flush_icache_range
Message-Id: <428DF18F.8040600@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010501030701050302080008"
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010501030701050302080008
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed

Here is a small patch that flushes the i-cache 64 bytes
by 64 bytes on Itanium 2 (or +).

Some measures on a Tiger box with the indicated CPU-s:

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
cpu MHz    : 1296.439995
itc MHz    : 1296.439995
BogoMIPS   : 1941.96
etc...

Flushing a page of 64 Kbytes (the others do not do anything,
they have not got anything about my data on their caches):

With a 32-byte stride:

Modified in d-cache: cycles = 215 K, time = 169 usec
Valid:               cycles = 222 K, time = 171 usec
Invalid:             cycles = 222 K, time = 171 usec

Note that for the dirty case, only the 1st flush causes a write-
back from the L2 / L3 caches, the 3 other flushes find the cache
entries invalid in the L2 / L3 caches.

With a 64-byte stride:

Modified in d-cache: cycles = 63 K, time = 49 usec
Valid:               cycles = 116 K, time = 89 usec
Invalid:             cycles = 116 K, time = 89 usec

It is funny to see that the dirty lines can be flushed more
efficiently. I guess the CPU knows in such a case that the others
cannot have anything to flush, the flush request may not even be
issued to the other CPU-s.

I also tried to issue more than one flush per loop-body
iteration, it did not help.

Thanks,

Zoltan


--------------010501030701050302080008
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
 name="diff"
Content-Disposition: inline;
 filename="diff"

diff -Nru linux-2.6.11-old/arch/ia64/lib/flush.S linux-2.6.11/arch/ia64/lib/flush.S
--- linux-2.6.11-old/arch/ia64/lib/flush.S	2005-05-20 15:26:18.330498876 +0200
+++ linux-2.6.11/arch/ia64/lib/flush.S	2005-05-20 15:28:25.639091067 +0200
@@ -7,6 +7,23 @@
 #include <asm/asmmacro.h>
 #include <asm/page.h>
 
+
+/*
+ * Note that "L1_CACHE_SHIFT" and "L1_CACHE_BYTES" defined in
+ * include/asm-ia64/cache.h are not what their names suggest.
+ * They actually defines the cache line size for L2.
+ *
+ * We have to flush the L1 i-cache, too.
+ */
+#if	defined(CONFIG_ITANIUM)
+#define L1_CACHE_SHIFT	5
+#else
+#define L1_CACHE_SHIFT	6
+#endif
+
+#define	L1_CACHE_BYTES	(1 << L1_CACHE_SHIFT)
+
+
 	/*
 	 * flush_icache_range(start,end)
 	 *	Must flush range from start to end-1 but nothing else (need to
@@ -17,7 +34,7 @@
 	alloc r2=ar.pfs,2,0,0,0
 	sub r8=in1,in0,1
 	;;
-	shr.u r8=r8,5			// we flush 32 bytes per iteration
+	shr.u r8=r8,L1_CACHE_SHIFT	// we flush L1_CACHE_BYTES bytes per iteration
 	.save ar.lc, r3
 	mov r3=ar.lc			// save ar.lc
 	;;
@@ -26,8 +43,12 @@
 
 	mov ar.lc=r8
 	;;
+#if	defined(CONFIG_ITANIUM)
 .Loop:	fc in0				// issuable on M0 only
-	add in0=32,in0
+#else
+.Loop:	fc.i in0
+#endif
+	add in0=L1_CACHE_BYTES,in0
 	br.cloop.sptk.few .Loop
 	;;
 	sync.i

--------------010501030701050302080008--
