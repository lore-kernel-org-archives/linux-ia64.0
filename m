From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:27 +0000
Subject: [PATCH 08/35] cpumask: cpumask_size()
Message-Id: <20081020170320.713010000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

Dynamic allocation of cpumasks requires the size.

Signed-off-by: Mike Travis <travis@sgi.com>
---
 include/linux/cpumask.h |    6 ++++++
 1 file changed, 6 insertions(+)

--- test-compile.orig/include/linux/cpumask.h
+++ test-compile/include/linux/cpumask.h
@@ -64,6 +64,7 @@
  * int next_cpu(cpu, mask)		Next cpu past 'cpu', or NR_CPUS
  * int next_cpu_nr(cpu, mask)		Next cpu past 'cpu', or nr_cpu_ids
  *
+ * size_t cpumask_size()		Length of cpumask in bytes.
  * cpumask_t cpumask_of_cpu(cpu)	Return cpumask with bit 'cpu' set
  *					(can be used as an lvalue)
  * CPU_MASK_ALL				Initializer - all bits set
@@ -148,6 +149,11 @@ struct cpumask
 };
 #define cpumask_bits(maskp) ((maskp)->bits)
 
+static inline ssize_t cpumask_size(void)
+{
+	return BITS_TO_LONGS(NR_CPUS) * sizeof(long);
+}
+
 /* Deprecated. */
 typedef struct cpumask cpumask_t;
 extern cpumask_t _unused_cpumask_arg_;

-- 
