From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 14 Mar 2008 23:56:26 +0000
Subject: RE: [Patch 3/3] Allocate mca/init stacks as part of per_node reservation.
Message-Id: <1FE6DD409037234FAB833C420AA843ECD40BD1@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080213175520.786006915@attica.americas.sgi.com>
In-Reply-To: <20080213175520.786006915@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Perhaps we should leave mca.c using alloc_pages_node()
for cpu!=0 and just have the mm/{contig.c,discontig.c}
do a pre-allocation for cpu0 only.  In contig.c you'd
just use the !SMP version of alloc_mca_data() for all
cases.  Changes to discontig.c are left as an exercise
to the reader.  Patch for mca.c looks like this:

--- a/arch/ia64/kernel/mca.c	2008-03-14 16:51:10.000000000 -0700
+++ b/arch/ia64/kernel/mca.c	2008-03-14 16:50:35.000000000 -0700
@@ -1756,13 +1756,6 @@
 	strncpy(p->comm, type, sizeof(p->comm)-1);
 }
 
-/* Caller prevents this from being called after init */
-static void * __init_refok mca_bootmem(void)
-{
-	return __alloc_bootmem(sizeof(struct ia64_mca_cpu),
-	                    KERNEL_STACK_SIZE, 0);
-}
-
 /* Do per-CPU MCA-related initialization.  */
 void __cpuinit
 ia64_mca_cpu_init(void *cpu_data)
@@ -1771,20 +1764,15 @@
 	void *data;
 	long sz = sizeof(struct ia64_mca_cpu);
 	int cpu = smp_processor_id();
-	static int first_time = 1;
 
 	/*
 	 * Structure will already be allocated if cpu has been online,
-	 * then offlined.
+	 * then offlined.  Cpu 0 is pre-allocated using bootmem.
 	 */
 	if (__per_cpu_mca[cpu]) {
 		data = __va(__per_cpu_mca[cpu]);
 	} else {
-		if (first_time) {
-			data = mca_bootmem();
-			first_time = 0;
-		} else
-			data = page_address(alloc_pages_node(numa_node_id(),
+		data = page_address(alloc_pages_node(numa_node_id(),
 					GFP_KERNEL, get_order(sz)));
 		if (!data)
 			panic("Could not allocate MCA memory for cpu %d\n",
