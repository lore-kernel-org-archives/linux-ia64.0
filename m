From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 06 Oct 2003 21:50:07 +0000
Subject: [PATCH] deal with lack of SRAT in generic kernels
Message-Id: <marc-linux-ia64-106547702702916@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On platforms without an SRAT (e.g. zx1), the cpu_to_node_map will get
built incorrectly without this fix, making generic kernels fail when
they try to alloc_pages_node() from a nodeid of -1.  This is a simple
port forward of the 2.4 code, please let me know if you'd like this
stuff cleaned up before it goes in or if it's ok the way it is.

 acpi.c |   12 ++++++++++++

Thanks,
Jesse

diff -Nru a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c	Mon Oct  6 14:47:47 2003
+++ b/arch/ia64/kernel/acpi.c	Mon Oct  6 14:47:47 2003
@@ -453,6 +453,12 @@
 {
 	int i, j, node_from, node_to;
 
+	/* If there's no SRAT, fix the phys_id */
+	if (srat_num_cpus = 0) {
+		node_cpuid[0].phys_id = hard_smp_processor_id();
+		return;
+	}
+
 	/* calculate total number of nodes in system from PXM bitmap */
 	numnodes = 0;		/* init total nodes in system */
 
@@ -613,6 +619,12 @@
 
 	smp_build_cpu_map();
 # ifdef CONFIG_NUMA
+	if (srat_num_cpus = 0) {
+		int cpu, i = 1;
+		for (cpu = 0; cpu < smp_boot_data.cpu_count; cpu++)
+			if (smp_boot_data.cpu_phys_id[cpu] != hard_smp_processor_id())
+				node_cpuid[i++].phys_id = smp_boot_data.cpu_phys_id[cpu];
+	}
 	build_cpu_to_node_map();
 # endif
 #endif
