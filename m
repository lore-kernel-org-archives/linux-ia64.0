From: Pat Gefre <pfg@sgi.com>
Date: Thu, 27 May 2004 15:31:18 +0000
Subject: [PATCH 2.6] Altix - disable mst errors on probe
Message-Id: <200405271531.i4RFVIX3333251@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


An Altix patch for disabling MST errors on probe.

-- Pat

Patrick Gefre
Silicon Graphics, Inc.                     (E-Mail)  pfg@sgi.com
2750 Blue Water Rd                         (Voice)   (651) 683-3127
Eagan, MN 55121-1400                       (FAX)     (651) 683-3054




# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/05/27 10:27:41-05:00 pfg@sgi.com 
#   Fix for disabling mst timeout errors on probes
# 
# arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c
#   2004/05/27 10:27:34-05:00 pfg@sgi.com +47 -3
#     
# 
diff -Nru a/arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c b/arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c
--- a/arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c	2004-05-27 10:29:15 -05:00
+++ b/arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c	2004-05-27 10:29:15 -05:00
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2001-2003 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2001-2004 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/types.h>
@@ -1615,6 +1615,46 @@
 				piomap->bp_kvaddr + offset, len, valp);
 }
 
+static uint64_t
+pcibr_disable_mst_timeout(pcibr_soft_t pcibr_soft)
+{
+    uint64_t		old_enable;
+    uint64_t		new_enable;
+    uint64_t		intr_bits;
+
+    intr_bits = PIC_ISR_PCI_MST_TIMEOUT
+		| PIC_ISR_PCIX_MTOUT | PIC_ISR_PCIX_SPLIT_EMSG;
+    old_enable = pcireg_intr_enable_get(pcibr_soft);
+    pcireg_intr_enable_bit_clr(pcibr_soft, intr_bits);
+    new_enable = pcireg_intr_enable_get(pcibr_soft);
+
+    if (old_enable = new_enable) {
+	return 0;		/* was already disabled */
+    } else {
+	return 1;
+    }
+}
+
+static int
+pcibr_enable_mst_timeout(pcibr_soft_t pcibr_soft)
+{
+    uint64_t		old_enable;
+    uint64_t		new_enable;
+    uint64_t		intr_bits;
+    
+    intr_bits = PIC_ISR_PCI_MST_TIMEOUT
+		| PIC_ISR_PCIX_MTOUT | PIC_ISR_PCIX_SPLIT_EMSG;
+    old_enable = pcireg_intr_enable_get(pcibr_soft);
+    pcireg_intr_enable_bit_set(pcibr_soft, intr_bits);
+    new_enable = pcireg_intr_enable_get(pcibr_soft);
+
+    if (old_enable = new_enable) {
+	return 0;		/* was alread enabled */
+    } else {
+	return 1;
+    }
+}
+
 /*
  * pcibr_probe_slot: read a config space word
  * while trapping any errors; return zero if
@@ -1628,7 +1668,7 @@
 		 int len,
 		 void *valp)
 {
-    int			rv;
+    int			rv, changed;
 
     /*
      * Sanity checks ...
@@ -1642,14 +1682,18 @@
 	return -1;				/* invalid alignment */
     }
 
+    changed = pcibr_disable_mst_timeout(pcibr_soft);
+
     rv = snia_badaddr_val((void *)addr, len, valp);
 
     /* Clear the int_view register incase it was set */
     pcireg_intr_reset_set(pcibr_soft, BRIDGE_IRR_MULTI_CLR);
 
+    if (changed) {
+	pcibr_enable_mst_timeout(pcibr_soft);
+    }
     return (rv ? 1 : 0);	/* return 1 for snia_badaddr_val error, 0 if ok */
 }
-
 
 void
 pcibr_device_info_free(vertex_hdl_t pcibr_vhdl, pciio_slot_t slot)
