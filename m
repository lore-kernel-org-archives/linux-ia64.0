From: Jes Sorensen <jes@trained-monkey.org>
Date: Fri, 17 Oct 2003 14:43:29 +0000
Subject: [patch] sn2 kmalloc checks
Message-Id: <marc-linux-ia64-106640183215134@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,

Here is another one fixing some missing kmalloc checks and getting rid
of an unused variable in hub_intr_s.

Relative to your 0908 2.6.0-test5

Cheers,
Jes

--- /usr/tmp/TmpDir.1480-0/linux/arch/ia64/sn/io/sn2/shub_intr.c_1.3	Fri Oct 17 07:21:12 2003
+++ linux/arch/ia64/sn/io/sn2/shub_intr.c	Fri Oct 17 07:18:57 2003
@@ -1,5 +1,4 @@
-/* $Id: shub_intr.c,v 1.1 2002/02/28 17:31:25 marcelo Exp $
- *
+/*
  * This file is subject to the terms and conditions of the GNU General Public
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
@@ -50,7 +49,7 @@
 		vertex_hdl_t owner_dev,
 		int uncond_nothread)
 {
-	cpuid_t		cpu = 0;
+	cpuid_t		cpu;
 	int		vector;
 	hub_intr_t	intr_hdl;
 	cnodeid_t	cnode;
@@ -59,13 +58,12 @@
 	iopaddr_t	xtalk_addr;
 	struct xtalk_intr_s	*xtalk_info;
 	xwidget_info_t	xwidget_info;
-	ilvl_t		intr_swlevel = 0;
 
 	cpu = intr_heuristic(dev, dev_desc, -1, 0, owner_dev, NULL, &vector);
 
 	if (cpu = CPU_NONE) {
 		printk("Unable to allocate interrupt for 0x%p\n", (void *)owner_dev);
-		return(0);
+		return NULL;
 	}
 
 	cpuphys = cpu_physical_id(cpu);
@@ -79,8 +77,13 @@
 		xtalk_addr = SH_II_INT0 | ((unsigned long)nasid << 36) | (1UL << 47);
 	}
 
-	intr_hdl = snia_kmem_alloc_node(sizeof(struct hub_intr_s), KM_NOSLEEP, cnode);
-	ASSERT_ALWAYS(intr_hdl);
+	intr_hdl = kmalloc(sizeof(struct hub_intr_s), GFP_KERNEL);
+	if (!intr_hdl) {
+		printk(KERN_ERR "do_hub_intr_alloc(): Unable to allocate "
+		       "memory!\n");
+		return NULL;
+	}
+	memset(intr_hdl, 0, sizeof(struct hub_intr_s));
 
 	xtalk_info = &intr_hdl->i_xtalk_info;
 	xtalk_info->xi_dev = dev;
@@ -92,7 +95,6 @@
 		xtalk_info->xi_target = xwidget_info_masterid_get(xwidget_info);
 	}
 
-	intr_hdl->i_swlevel = intr_swlevel;
 	intr_hdl->i_cpuid = cpu;
 	intr_hdl->i_bit = vector;
 	intr_hdl->i_flags |= HUB_INTR_IS_ALLOCED;
@@ -150,7 +152,7 @@
 
 	ASSERT(intr_hdl->i_flags & HUB_INTR_IS_ALLOCED);
 
-	rv = intr_connect_level(cpu, vector, intr_hdl->i_swlevel, NULL);
+	rv = intr_connect_level(cpu, vector, 0, NULL);
 	if (rv < 0) {
 		return rv;
 	}

--- /usr/tmp/TmpDir.1480-0/linux/include/asm-ia64/sn/sn2/sn_private.h_1.4	Fri Oct 17 07:21:12 2003
+++ linux/include/asm-ia64/sn/sn2/sn_private.h	Fri Oct  3 18:09:13 2003
@@ -159,7 +159,6 @@
  */
 struct hub_intr_s {
 	struct xtalk_intr_s	i_xtalk_info;	/* standard crosstalk intr info */
-	ilvl_t			i_swlevel;	/* software level for blocking intr */
 	cpuid_t			i_cpuid;	/* which cpu */
 	int			i_bit;		/* which bit */
 	int			i_flags;
