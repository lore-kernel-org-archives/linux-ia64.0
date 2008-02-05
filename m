From: Russ Anderson <rja@sgi.com>
Date: Tue, 05 Feb 2008 23:12:32 +0000
Subject: Re: [patch] Fix large MCA bootmem allocation
Message-Id: <20080205231231.GB14894@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080205193232.GA8834@sgi.com>
In-Reply-To: <20080205193232.GA8834@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 05, 2008 at 01:21:00PM -0700, Bjorn Helgaas wrote:
> On Tuesday 05 February 2008 12:32:33 pm Russ Anderson wrote:
> > +		if (first_time) {
> > +			data = mca_bootmem();
> > +			first_time = 0;
> > +		} else
> > +			data = page_address(alloc_pages_node(numa_node_id(),
> > +					GFP_KERNEL, get_order(sz)));
> > +	}
> 
> I assume this alloc_pages_node() path happens when a CPU is hot-added.

I had assumed that, too, but it does not appear to be the case.
I have not followed the hot-plug enabled code path, but it does 
not call ia64_mca_cpu_init(). 

FWIW, the MCA code behaves correctly when cpus are logically offlined
(ie only the enabled cpus are rendezvoused) and onlined.  The 
disable path does not free the memory, so it is still there when the
cpu is re-enabled.

> What happens if this alloc fails?

The updated patch will panic is alloc fails.

----------------------------------------------------------------
[patch] Fix large MCA bootmem allocation

The MCA code allocates bootmem memory for NR_CPUS, regardless
of how many cpus the system actually has.  This change allocates
memory only for cpus that actually exist.

On my test system with NR_CPUS = 1024, reserved memory was reduced by 130944k.

Before: Memory: 27886976k/28111168k available (8282k code, 242304k reserved, 5928k data, 1792k init)
After:  Memory: 28017920k/28111168k available (8282k code, 111360k reserved, 5928k data, 1792k init)


Signed-off-by: Russ Anderson <rja@sgi.com>

---
 arch/ia64/kernel/mca.c |   55 +++++++++++++++++++++++--------------------------
 1 file changed, 26 insertions(+), 29 deletions(-)

Index: test/arch/ia64/kernel/mca.c
=================================--- test.orig/arch/ia64/kernel/mca.c	2008-02-05 13:01:56.000000000 -0600
+++ test/arch/ia64/kernel/mca.c	2008-02-05 16:39:18.116180868 -0600
@@ -17,7 +17,7 @@
  * Copyright (C) 2000 Intel
  * Copyright (C) Chuck Fleckenstein <cfleck@co.intel.com>
  *
- * Copyright (C) 1999, 2004 Silicon Graphics, Inc.
+ * Copyright (C) 1999, 2004-2008 Silicon Graphics, Inc.
  * Copyright (C) Vijay Chander <vijay@engr.sgi.com>
  *
  * Copyright (C) 2006 FUJITSU LIMITED
@@ -1762,11 +1762,8 @@ format_mca_init_stack(void *mca_data, un
 /* Caller prevents this from being called after init */
 static void * __init_refok mca_bootmem(void)
 {
-	void *p;
-
-	p = alloc_bootmem(sizeof(struct ia64_mca_cpu) * NR_CPUS +
-	                  KERNEL_STACK_SIZE);
-	return (void *)ALIGN((unsigned long)p, KERNEL_STACK_SIZE);
+	return __alloc_bootmem(sizeof(struct ia64_mca_cpu),
+	                    KERNEL_STACK_SIZE, 0);
 }
 
 /* Do per-CPU MCA-related initialization.  */
@@ -1774,33 +1771,33 @@ void __cpuinit
 ia64_mca_cpu_init(void *cpu_data)
 {
 	void *pal_vaddr;
+	void *data;
+	long sz = sizeof(struct ia64_mca_cpu);
+	int cpu = smp_processor_id();
 	static int first_time = 1;
 
-	if (first_time) {
-		void *mca_data;
-		int cpu;
-
-		first_time = 0;
-		mca_data = mca_bootmem();
-		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			format_mca_init_stack(mca_data,
-					offsetof(struct ia64_mca_cpu, mca_stack),
-					"MCA", cpu);
-			format_mca_init_stack(mca_data,
-					offsetof(struct ia64_mca_cpu, init_stack),
-					"INIT", cpu);
-			__per_cpu_mca[cpu] = __pa(mca_data);
-			mca_data += sizeof(struct ia64_mca_cpu);
-		}
-	}
-
 	/*
-	 * The MCA info structure was allocated earlier and its
-	 * physical address saved in __per_cpu_mca[cpu].  Copy that
-	 * address * to ia64_mca_data so we can access it as a per-CPU
-	 * variable.
+	 * Structure will already be allocated if cpu has been online,
+	 * then offlined.
 	 */
-	__get_cpu_var(ia64_mca_data) = __per_cpu_mca[smp_processor_id()];
+	if (__per_cpu_mca[cpu]) {
+		data = __va(__per_cpu_mca[cpu]);
+	} else {
+		if (first_time) {
+			data = mca_bootmem();
+			first_time = 0;
+		} else
+			data = page_address(alloc_pages_node(numa_node_id(),
+					GFP_KERNEL, get_order(sz)));
+		if (!data)
+			panic("Could not allocate MCA memory for cpu %d\n",
+					cpu);
+	}
+	format_mca_init_stack(data, offsetof(struct ia64_mca_cpu, mca_stack),
+		"MCA", cpu);
+	format_mca_init_stack(data, offsetof(struct ia64_mca_cpu, init_stack),
+		"INIT", cpu);
+	__get_cpu_var(ia64_mca_data) = __per_cpu_mca[cpu] = __pa(data);
 
 	/*
 	 * Stash away a copy of the PTE needed to map the per-CPU page.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
