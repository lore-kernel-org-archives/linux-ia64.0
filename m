From: Martin Hicks <mort@wildopensource.com>
Date: Fri, 06 Feb 2004 17:38:38 +0000
Subject: [PATCH] SN - fix pxm_to_nasid() for large machines
Message-Id: <20040206173838.GB21486@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="fUYQa+Pmc3FrFX/N"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Hi,

This is a patch for SN2 that fixes up pxm_to_nasid() for big machines.
Compile and boot tested.  The patch is against the latest 2.6 bitkeeper.

I also marked sn_init_pdas as __init, because it is.

Thanks
mh

-- 
Martin Hicks                Wild Open Source Inc.
mort@wildopensource.com     613-266-2296

--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sn-pxm_to_nasid-fix.patches"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1542  -> 1.1543 
#	arch/ia64/sn/kernel/setup.c	1.29    -> 1.30   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/06	mort@tomahawk.engr.sgi.com	1.1543
# Correct the pxm_to_nasid() definition so it works correctly for
# the big boxen.
# --------------------------------------------
#
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	Fri Feb  6 08:51:01 2004
+++ b/arch/ia64/sn/kernel/setup.c	Fri Feb  6 08:51:01 2004
@@ -50,8 +50,6 @@
 
 DEFINE_PER_CPU(struct pda_s, pda_percpu);
 
-#define pxm_to_nasid(pxm) ((pxm)<<1)
-
 #define MAX_PHYS_MEMORY		(1UL << 49)     /* 1 TB */
 
 extern void bte_init_node (nodepda_t *, cnodeid_t);
@@ -121,6 +119,29 @@
 char drive_info[4*16];
 #endif
 
+
+/*
+ * This routine can only be used during init, since
+ * smp_boot_data is an init data structure.
+ * We have to use smp_boot_data.cpu_phys_id to find
+ * the physical id of the processor because the normal
+ * cpu_physical_id() relies on data structures that
+ * may not be initialized yet.                                                                     
+ */
+static int __init
+pxm_to_nasid(int pxm)
+{
+	int i;
+	int nid;
+
+	nid = pxm_to_nid_map[pxm];
+	for (i = 0; i < num_memblks; i++)
+		if (node_memblk[i].nid == nid)
+			return NASID_GET(node_memblk[i].start_paddr);
+	return -1;
+}
+
+
 /**
  * early_sn_setup - early setup routine for SN platforms
  *
@@ -315,7 +336,7 @@
  *
  * One time setup for Node Data Area.  Called by sn_setup().
  */
-void
+void __init
 sn_init_pdas(char **cmdline_p)
 {
 	cnodeid_t	cnode;

--fUYQa+Pmc3FrFX/N--
