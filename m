From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:21 +0000
Subject: [PATCH 02/35] cpumask: remove min from first_cpu/next_cpu
Message-Id: <20081020170319.867619000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

Seems like this has been here forever, but I can't see why:
find_first_bit and find_next_bit both return >= NR_CPUS on failure.

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 lib/cpumask.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

--- linux-2.6.28.orig/lib/cpumask.c
+++ linux-2.6.28/lib/cpumask.c
@@ -5,21 +5,20 @@
 
 int __first_cpu(const cpumask_t *srcp)
 {
-	return min_t(int, NR_CPUS, find_first_bit(srcp->bits, NR_CPUS));
+	return find_first_bit(srcp->bits, NR_CPUS);
 }
 EXPORT_SYMBOL(__first_cpu);
 
 int __next_cpu(int n, const cpumask_t *srcp)
 {
-	return min_t(int, NR_CPUS, find_next_bit(srcp->bits, NR_CPUS, n+1));
+	return find_next_bit(srcp->bits, NR_CPUS, n+1);
 }
 EXPORT_SYMBOL(__next_cpu);
 
 #if NR_CPUS > 64
 int __next_cpu_nr(int n, const cpumask_t *srcp)
 {
-	return min_t(int, nr_cpu_ids,
-				find_next_bit(srcp->bits, nr_cpu_ids, n+1));
+	return find_next_bit(srcp->bits, nr_cpu_ids, n+1);
 }
 EXPORT_SYMBOL(__next_cpu_nr);
 #endif

-- 
