From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 14 Mar 2008 21:18:37 +0000
Subject: RE: [Patch 3/3] Allocate mca/init stacks as part of per_node reservation.
Message-Id: <1FE6DD409037234FAB833C420AA843ECD40937@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080213175520.786006915@attica.americas.sgi.com>
In-Reply-To: <20080213175520.786006915@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Index: per_cpu_mca_v1/arch/ia64/mm/contig.c
=================================--- per_cpu_mca_v1.orig/arch/ia64/mm/contig.c	2008-02-13 11:53:32.424525355 -0600
+++ per_cpu_mca_v1/arch/ia64/mm/contig.c	2008-02-13 11:53:55.887438125 -0600
@@ -182,8 +182,26 @@ alloc_per_cpu_data(void)
 	cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS,
 				   PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
 }
+
+static inline void
+alloc_mca_data(void)
+{
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		__per_cpu_mca[cpu] = __pa(__alloc_bootmem(
+			sizeof(struct ia64_mca_cpu), KERNEL_STACK_SIZE, 0));
+	}
+}

I applied this series ... and everything built cleanly.  But when I
try to boot my Tiger (built from tiger_defconfig) it hangs quite
early in boot (last message is "Boot processor id 0x0/0xc128").

I threw some printk() into the above function, and it seems
that in the contig.c case the possible cpu map isn't initialized
early enough.  The loop here just allocates mca_data for cpu 0
and no others.

-Tony
