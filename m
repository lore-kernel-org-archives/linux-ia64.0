From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 08 Sep 2004 10:02:52 +0000
Subject: to .nta or not?
Message-Id: <16702.55500.416678.727769@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A recent discussion initiated among Dave Miller, Linus and a couple of
others made me wonder if the .nta qualifiers in the clear_page()
routine are really a win.  Interestingly, on a 2-way 1.5GHz/6M
Madison, removing the .nta _increases_ the time spent in clear_page()
(as you'd expect) but _overall_ it results in faster linux kernel
compile-times.  It would be interesting to try this on a wider range
of machines and workloads, so I attached the patch below.  If a large
number of workloads and machines can benefit from the (efficient)
cache-warmup done by clear_page(), perhaps we should consider removing
the ".nta"s for good.

If you have an interesting workload, please give it a try and post the
results (relative numbers are OK if you're leery to post absolute
results).

	--david

=== arch/ia64/lib/clear_page.S 1.6 vs edited ==--- 1.6/arch/ia64/lib/clear_page.S	2002-03-11 19:32:00 -08:00
+++ edited/arch/ia64/lib/clear_page.S	2004-08-16 05:24:05 -07:00
@@ -43,7 +43,7 @@
 	adds dst1 = 16, in0
 	adds dst2 = 32, in0
 	;;
-.fetch:	stf.spill.nta [dst_fetch] = f0, L3_LINE_SIZE
+.fetch:	stf.spill [dst_fetch] = f0, L3_LINE_SIZE
 	adds dst3 = 48, in0		// executing this multiple times is harmless
 	br.cloop.sptk.few .fetch
 	;;
@@ -59,17 +59,17 @@
 	;;
 #else
 	// Optimized for McKinley
-1:	stf.spill.nta [dst1] = f0, 64
-	stf.spill.nta [dst2] = f0, 64
-	stf.spill.nta [dst3] = f0, 64
-	stf.spill.nta [dst4] = f0, 128
+1:	stf.spill [dst1] = f0, 64
+	stf.spill [dst2] = f0, 64
+	stf.spill [dst3] = f0, 64
+	stf.spill [dst4] = f0, 128
 	cmp.lt p8,p0=dst_fetch, dst_last
 	;;
-	stf.spill.nta [dst1] = f0, 64
-	stf.spill.nta [dst2] = f0, 64
+	stf.spill [dst1] = f0, 64
+	stf.spill [dst2] = f0, 64
 #endif
-	stf.spill.nta [dst3] = f0, 64
-(p8)	stf.spill.nta [dst_fetch] = f0, L3_LINE_SIZE
+	stf.spill [dst3] = f0, 64
+(p8)	stf.spill [dst_fetch] = f0, L3_LINE_SIZE
 	br.cloop.sptk.few 1b
 	;;
 	mov ar.lc = saved_lc		// restore lc
