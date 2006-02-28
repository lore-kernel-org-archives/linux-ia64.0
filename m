From: Fenghua Yu <fenghua.yu@intel.com>
Date: Tue, 28 Feb 2006 00:16:22 +0000
Subject: [PATCH]IA64: New IA64 core/thread detection patch
Message-Id: <20060227161622.A5605@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

IPF SDM 2.2 changes definition of PAL_LOGICAL_TO_PHYSICAL to add proc_number=-1 to get core/thread mapping info on the running processer.  
 
Based on this change, we had better to update existing core/thread detection in IA64 kernel correspondingly. The attached patch implements this change. It simplifies detection code and eliminates potential race condition. It also runs a bit faster and has better scalability especially when cores and threads number grows up in one package.
  
Please review and accept it.

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

--- linux-2.6.16-rc4.ia64coremapping/arch/ia64/kernel/smpboot.c.orig	2006-02-24 09:19:07.000000000 -0800
+++ linux-2.6.16-rc4.ia64coremapping/arch/ia64/kernel/smpboot.c	2006-02-24 16:34:05.000000000 -0800
@@ -572,32 +572,8 @@ void __devinit smp_prepare_boot_cpu(void
 	per_cpu(cpu_state, smp_processor_id()) = CPU_ONLINE;
 }
 
-/*
- * mt_info[] is a temporary store for all info returned by
- * PAL_LOGICAL_TO_PHYSICAL, to be copied into cpuinfo_ia64 when the
- * specific cpu comes.
- */
-static struct {
-	__u32   socket_id;
-	__u16   core_id;
-	__u16   thread_id;
-	__u16   proc_fixed_addr;
-	__u8    valid;
-} mt_info[NR_CPUS] __devinitdata;
-
 #ifdef CONFIG_HOTPLUG_CPU
 static inline void
-remove_from_mtinfo(int cpu)
-{
-	int i;
-
-	for_each_cpu(i)
-		if (mt_info[i].valid &&  mt_info[i].socket_id =
-		    				cpu_data(cpu)->socket_id)
-			mt_info[i].valid = 0;
-}
-
-static inline void
 clear_cpu_sibling_map(int cpu)
 {
 	int i;
@@ -626,12 +602,6 @@ remove_siblinginfo(int cpu)
 
 	/* remove it from all sibling map's */
 	clear_cpu_sibling_map(cpu);
-
-	/* if this cpu is the last in the core group, remove all its info 
-	 * from mt_info structure
-	 */
-	if (last)
-		remove_from_mtinfo(cpu);
 }
 
 extern void fixup_irqs(void);
@@ -776,40 +746,6 @@ init_smp_config(void)
 		       ia64_sal_strerror(sal_ret));
 }
 
-static inline int __devinit
-check_for_mtinfo_index(void)
-{
-	int i;
-	
-	for_each_cpu(i)
-		if (!mt_info[i].valid)
-			return i;
-
-	return -1;
-}
-
-/*
- * Search the mt_info to find out if this socket's cid/tid information is
- * cached or not. If the socket exists, fill in the core_id and thread_id 
- * in cpuinfo
- */
-static int __devinit
-check_for_new_socket(__u16 logical_address, struct cpuinfo_ia64 *c)
-{
-	int i;
-	__u32 sid = c->socket_id;
-
-	for_each_cpu(i) {
-		if (mt_info[i].valid && mt_info[i].proc_fixed_addr = logical_address
-		    && mt_info[i].socket_id = sid) {
-			c->core_id = mt_info[i].core_id;
-			c->thread_id = mt_info[i].thread_id;
-			return 1; /* not a new socket */
-		}
-	}
-	return 0;
-}
-
 /*
  * identify_siblings(cpu) gets called from identify_cpu. This populates the 
  * information related to logical execution units in per_cpu_data structure.
@@ -819,14 +755,12 @@ identify_siblings(struct cpuinfo_ia64 *c
 {
 	s64 status;
 	u16 pltid;
-	u64 proc_fixed_addr;
-	int count, i;
 	pal_logical_to_physical_t info;
 
 	if (smp_num_cpucores = 1 && smp_num_siblings = 1)
 		return;
 
-	if ((status = ia64_pal_logical_to_phys(0, &info)) != PAL_STATUS_SUCCESS) {
+	if ((status = ia64_pal_logical_to_phys(-1, &info)) != PAL_STATUS_SUCCESS) {
 		printk(KERN_ERR "ia64_pal_logical_to_phys failed with %ld\n",
 		       status);
 		return;
@@ -835,47 +769,12 @@ identify_siblings(struct cpuinfo_ia64 *c
 		printk(KERN_ERR "ia64_sal_pltid failed with %ld\n", status);
 		return;
 	}
-	if ((status = ia64_pal_fixed_addr(&proc_fixed_addr)) != PAL_STATUS_SUCCESS) {
-		printk(KERN_ERR "ia64_pal_fixed_addr failed with %ld\n", status);
-		return;
-	}
 
 	c->socket_id =  (pltid << 8) | info.overview_ppid;
 	c->cores_per_socket = info.overview_cpp;
 	c->threads_per_core = info.overview_tpc;
-	count = c->num_log = info.overview_num_log;
-
-	/* If the thread and core id information is already cached, then
-	 * we will simply update cpu_info and return. Otherwise, we will
-	 * do the PAL calls and cache core and thread id's of all the siblings.
-	 */
-	if (check_for_new_socket(proc_fixed_addr, c))
-		return;
-
-	for (i = 0; i < count; i++) {
-		int index;
+	c->num_log = info.overview_num_log;
 
-		if (i && (status = ia64_pal_logical_to_phys(i, &info))
-			  != PAL_STATUS_SUCCESS) {
-                	printk(KERN_ERR "ia64_pal_logical_to_phys failed"
-					" with %ld\n", status);
-                	return;
-		}
-		if (info.log2_la = proc_fixed_addr) {
-			c->core_id = info.log1_cid;
-			c->thread_id = info.log1_tid;
-		}
-
-		index = check_for_mtinfo_index();
-		/* We will not do the mt_info caching optimization in this case.
-		 */
-		if (index < 0)
-			continue;
-
-		mt_info[index].valid = 1;
-		mt_info[index].socket_id = c->socket_id;
-		mt_info[index].core_id = info.log1_cid;
-		mt_info[index].thread_id = info.log1_tid;
-		mt_info[index].proc_fixed_addr = info.log2_la;
-	}
+	c->core_id = info.log1_cid;
+	c->thread_id = info.log1_tid;
 }
--- linux-2.6.16-rc4.ia64coremapping/include/asm-ia64/pal.h.orig	2006-02-24 15:37:39.000000000 -0800
+++ linux-2.6.16-rc4.ia64coremapping/include/asm-ia64/pal.h	2006-02-24 15:38:00.000000000 -0800
@@ -1640,8 +1640,7 @@ ia64_pal_logical_to_phys(u64 proc_number
 
 	if (iprv.status = PAL_STATUS_SUCCESS)
 	{
-		if (proc_number = 0)
-			mapping->overview.overview_data = iprv.v0;
+		mapping->overview.overview_data = iprv.v0;
 		mapping->ppli1.ppli1_data = iprv.v1;
 		mapping->ppli2.ppli2_data = iprv.v2;
 	}
