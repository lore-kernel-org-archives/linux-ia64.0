From: Grant Grundler <iod00d@hp.com>
Date: Tue, 13 Jul 2004 08:43:28 +0000
Subject: [PATCH] 2.6.7 enforce MMIO reads WRT udelay
Message-Id: <20040713084328.GE31289@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,
This adventure started out when Stephane Eranian and I were playing
around by measuring MMIO reads and where they were. He had recently
gotten the Data EAR programming in the PMU working and we were looking
at the output.  The instruction address sampled by DATA_EAR_CACHE_LAT512
psuedo event was NOT an MMIO read. But rather the next memory access.
We began scratching our head to understand how a regular
memory read might take over 500 cycles on a box that normally
was ~220 cycles (1.3Ghz) under load.

IA-64 lesson learned:
    Memory Ordering imposes no constraint on non-load/store instructions.

Fine. That explained why the d-cache miss (uncached read) was NOT seen
until the next memory access stalled the instruction pipeline because
the CPU was enforcing acquire semantics.
And no problem with that UNTIL one looks at this fairly normal
sequence in any device driver:
	writel(y,1);
	readl(y);	/* post the write */
	udelay(10);	/* let device digest */
	writel(y,0);	/* safe to toggle off now */

The problem is the udelay() will start executing before the
readl() has been "retired" (ie when data finally returns).
Intel agrees this is expected behavior.

It took a while to confirm "mf.a" would fix this *potential* problem.
David Mosberger and Asit Mallick get credit for figuring out the fix.

To be honest, I've not seen any drivers fail becuase of this bug.
I suspect folks just increases the udelay() value when it does fail.
David encouraged me to submit the patch anyway. And I'd rather not
chase down yet another variant of the write posting bugs if I don't
have to. :^)

(In researching this, qla2xxx/qla_init.c provides a good "bad" example.
 Look at the code sequence starting with the writel() to
 CSR_ISP_SOFT_RESET register - obvious write posting issues
 and potentially nasty issues if the udelay() were shortened.)

We wondered if ia32 sees the same issue and Intel just recently
confirmed it does NOT.  The IA32 SDM is not clear about how MMIO
access affect the instruction pipeline.  Intel assured us on P4
CPUs no other instructions can retire before any uncached load retires.
In the above example, the first instruction in the delay loop will
not retire until the readl(y) gets the returned data.
But someone may want to review the asm-i386/delay.h anyway
with this in mind.

A short changelog to this patch might be:
	Enforce MMIO loads complete before starting udelay() loop.

Signed-off-by: Grant Grundler (with HP Legal/OSRB permission)

grant


=== include/asm-ia64/delay.h 1.9 vs edited ==--- 1.9/include/asm-ia64/delay.h	Thu May 13 15:31:39 2004
+++ edited/include/asm-ia64/delay.h	Tue Jul 13 01:18:04 2004
@@ -87,9 +87,19 @@
 static __inline__ void
 udelay (unsigned long usecs)
 {
-	unsigned long start = ia64_get_itc();
-	unsigned long cycles = usecs*local_cpu_data->cyc_per_usec;
+	unsigned long start;
+	unsigned long cycles;
 
+	/* mf.a is guaranteed to flush the memory queues
+	 * (independent of any platform/chipset support)
+	 * This is necessary to guarantee MMIO reads have
+	 * completed (data returned) BEFORE starting the
+	 * timing loop.
+	 */
+	ia64_mfa();
+
+	start = ia64_get_itc();
+	cycles = usecs*local_cpu_data->cyc_per_usec;
 	while (ia64_get_itc() - start < cycles)
 		/* skip */;
 }
