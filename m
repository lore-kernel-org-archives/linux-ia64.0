From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:28 +0000
Subject: [PATCH 09/35] cpumask: add cpumask_copy()
Message-Id: <20081020170320.850964000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

Since cpumasks are to become pointers to undefined structs, we need to
replace assignments.  Also, dynamically allocated ones will eventually
be nr_cpu_ids bits (<= NR_CPUS), so assignment is a definite no-no.

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 include/linux/cpumask.h |    8 ++++++++
 1 file changed, 8 insertions(+)

--- linux-2.6.28.orig/include/linux/cpumask.h
+++ linux-2.6.28/include/linux/cpumask.h
@@ -64,6 +64,8 @@
  * int next_cpu(cpu, mask)		Next cpu past 'cpu', or NR_CPUS
  * int next_cpu_nr(cpu, mask)		Next cpu past 'cpu', or nr_cpu_ids
  *
+ * void cpumask_copy(dmask, smask)	dmask = smask
+ *
  * size_t cpumask_size()		Length of cpumask in bytes.
  * cpumask_t cpumask_of_cpu(cpu)	Return cpumask with bit 'cpu' set
  *					(can be used as an lvalue)
@@ -351,6 +353,12 @@ static inline void cpumask_fold(struct c
 	bitmap_fold(dstp->bits, origp->bits, sz, NR_CPUS);
 }
 
+static inline void cpumask_copy(struct cpumask *dstp,
+				const struct cpumask *srcp)
+{
+	bitmap_copy(cpumask_bits(dstp), cpumask_bits(srcp), NR_CPUS);
+}
+
 /*
  * Special-case data structure for "single bit set only" constant CPU masks.
  *

-- 
