From: Jes Sorensen <jes@trained-monkey.org>
Date: Fri, 17 Oct 2003 13:04:40 +0000
Subject: [patch] xbow.c kmalloc fixes
Message-Id: <marc-linux-ia64-106639647908532@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,

Included is a patch that fixes the kmalloc return value checks in xbow.c
and while at it also nukes some silly spin_lock wrappers. Patch relative
to your most recent release.

Cheers,
Jes

--- ../linux-2.6.0-test5/arch/ia64/sn/io/sn2/xbow.c	Fri Aug 22 16:54:57 2003
+++ linux/arch/ia64/sn/io/sn2/xbow.c	Fri Oct 17 06:00:13 2003
@@ -1,5 +1,4 @@
-/* $Id$
- *
+/*
  * This file is subject to the terms and conditions of the GNU General Public
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
@@ -12,6 +11,8 @@
 #include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/interrupt.h>
+#include <linux/mm.h>
+#include <asm/delay.h>
 #include <asm/sn/sgi.h>
 #include <asm/sn/intr.h>
 #include <asm/sn/sn2/sn_private.h>
@@ -42,9 +43,6 @@
 #include <asm/sn/hcl_util.h>
 
 
-#define NEW(ptr)	(ptr = kmalloc(sizeof (*(ptr)), GFP_KERNEL))
-#define DEL(ptr)	(kfree(ptr))
-
 /*
  * This file supports the Xbow chip.  Main functions: initializtion,
  * error handling, and GBR.
@@ -229,6 +227,8 @@
 #ifdef XBRIDGE_REGS_SIM
     printk("xbow_attach: XBRIDGE_REGS_SIM FIXME: allocating %ld bytes for xbow_s\n", sizeof(xbow_t));
     xbow = (xbow_t *) kmalloc(sizeof(xbow_t), GFP_KERNEL);
+    if (!xbow)
+	    return -ENOMEM;
     /*
      * turn on ports e and f like in a real live ibrick
      */
@@ -274,7 +274,9 @@
      * Allocate the soft state structure and attach
      * it to the xbow's vertex
      */
-    NEW(soft);
+    soft = kmalloc(sizeof(*soft), GFP_KERNEL);
+    if (!soft)
+	    return -ENOMEM;
     soft->conn = conn;
     soft->vhdl = vhdl;
     soft->busv = busv;
@@ -298,6 +300,10 @@
     s = dev_to_name(vhdl, devnm, MAXDEVNAME);
     soft->name = kmalloc(strlen(s) + strlen(XBOW_NUM_SUFFIX_FORMAT) + 1, 
 			    GFP_KERNEL);
+    if (!soft->name) {
+	    kfree(soft);
+	    return -ENOMEM;
+    }
     sprintf(soft->name,"%s"XBOW_NUM_SUFFIX_FORMAT, s,xbow_num);
 
 #ifdef XBRIDGE_REGS_SIM
@@ -311,12 +317,12 @@
 #endif /* XBRIDGE_REGS_SIM */
     rev = XWIDGET_PART_REV_NUM(id);
 
-    mutex_spinlock_init(&soft->xbow_perf_lock);
+    spin_lock_init(&soft->xbow_perf_lock);
     soft->xbow_perfcnt[0].xp_perf_reg = &xbow->xb_perf_ctr_a;
     soft->xbow_perfcnt[1].xp_perf_reg = &xbow->xb_perf_ctr_b;
 
     /* Initialization for GBR bw allocation */
-    mutex_spinlock_init(&soft->xbow_bw_alloc_lock);
+    spin_lock_init(&soft->xbow_bw_alloc_lock);
 
 #define	XBOW_8_BIT_PORT_BW_MAX		(400 * 1000 * 1000)	/* 400 MB/s */
 #define XBOW_16_BIT_PORT_BW_MAX		(800 * 1000 * 1000)	/* 800 MB/s */
@@ -764,16 +770,6 @@
 			}
 		    }
 
-#if !DEBUG
-		    if (kdebug) {
-#endif
-			XEM_ADD_VAR(link_control);
-			XEM_ADD_VAR(link_status);
-			XEM_ADD_VAR(link_aux_status);
-
-#if !DEBUG
-		    }
-#endif
 		    fatal++;
 		}
 	    }
@@ -805,7 +801,7 @@
 	XEM_ADD_VAR(wid_err_upper);
 	XEM_ADD_VAR(wid_err_lower);
 	XEM_ADD_VAR(wid_err_addr);
-	PRINT_PANIC("XIO Bus Error");
+	panic("XIO Bus Error");
     }
 }
 
@@ -923,18 +919,6 @@
 		    "\twith offset 0x%lx",
 		    soft->name, port, tmp);
 	}
-#if !DEBUG
-	if (kdebug) {
-#endif
-	    XEM_ADD_STR("Raw status values for Crossbow:\n");
-	    XEM_ADD_VAR(wid_stat);
-	    XEM_ADD_VAR(wid_err_cmdword);
-	    XEM_ADD_VAR(wid_err_upper);
-	    XEM_ADD_VAR(wid_err_lower);
-	    XEM_ADD_VAR(wid_err_addr);
-#if !DEBUG
-	}
-#endif
 
 	/* caller will dump contents of ioerror
 	 * in DEBUG and kdebug kernels.
@@ -980,24 +964,8 @@
 		    "\twith offset 0x%lx",
 		    soft->name, port, tmp);
 	}
-#if !DEBUG
-	if (kdebug) {
-#endif
-	    XEM_ADD_STR("Raw status values for Crossbow:\n");
-	    XEM_ADD_VAR(wid_stat);
-	    XEM_ADD_VAR(wid_err_cmdword);
-	    XEM_ADD_VAR(wid_err_upper);
-	    XEM_ADD_VAR(wid_err_lower);
-	    XEM_ADD_VAR(wid_err_addr);
-	    XEM_ADD_VAR(port);
-	    XEM_ADD_VAR(link_control);
-	    XEM_ADD_VAR(link_status);
-	    XEM_ADD_VAR(link_aux_status);
-#if !DEBUG
-	}
-#endif
-	return retval;
 
+	return retval;
     }
     /* Check that the link is alive.
      */
@@ -1064,22 +1032,6 @@
 	}
     }
 
-#if !DEBUG
-    if (kdebug) {
-#endif
-	XEM_ADD_STR("Raw status values for Crossbow:\n");
-	XEM_ADD_VAR(wid_stat);
-	XEM_ADD_VAR(wid_err_cmdword);
-	XEM_ADD_VAR(wid_err_upper);
-	XEM_ADD_VAR(wid_err_lower);
-	XEM_ADD_VAR(wid_err_addr);
-	XEM_ADD_VAR(port);
-	XEM_ADD_VAR(link_control);
-	XEM_ADD_VAR(link_status);
-	XEM_ADD_VAR(link_aux_status);
-#if !DEBUG
-    }
-#endif
     /* caller will dump raw ioerror data
      * in DEBUG and kdebug kernels.
      */
@@ -1094,14 +1046,13 @@
     xbow_perf_t            *xbow_perf = xbow_soft->xbow_perfcnt;
     xbow_perf_link_t       *xbow_plink = xbow_soft->xbow_perflink;
     xbow_perfcount_t        perf_reg;
-    unsigned long           s;
     int                     link, i;
 
     for (i = 0; i < XBOW_PERF_COUNTERS; i++, xbow_perf++) {
 	if (xbow_perf->xp_mode = XBOW_MONITOR_NONE)
 	    continue;
 
-	s = mutex_spinlock(&xbow_soft->xbow_perf_lock);
+	spin_lock(&xbow_soft->xbow_perf_lock);
 
 	perf_reg.xb_counter_val = *(xbowreg_t *) xbow_perf->xp_perf_reg;
 
@@ -1111,7 +1062,7 @@
 	    ((perf_reg.xb_perf.count - xbow_perf->xp_current) & XBOW_COUNTER_MASK);
 	xbow_perf->xp_current = perf_reg.xb_perf.count;
 
-	mutex_spinunlock(&xbow_soft->xbow_perf_lock, s);
+	spin_unlock(&xbow_soft->xbow_perf_lock);
     }
 }
 
@@ -1132,7 +1083,6 @@
     xbow_linkctrl_t         xbow_link_ctrl;
     xbow_t                 *xbow = xbow_soft->base;
     xbow_perfcount_t        perf_reg;
-    unsigned long           s;
     int                     i;
 
     link -= BASE_XBOW_PORT;
@@ -1145,10 +1095,10 @@
     if ((counter < 0) || (counter >= XBOW_PERF_COUNTERS))
 	return -1;
 
-    s = mutex_spinlock(&xbow_soft->xbow_perf_lock);
+    spin_lock(&xbow_soft->xbow_perf_lock);
 
     if ((xbow_perf + counter)->xp_mode && mode) {
-	mutex_spinunlock(&xbow_soft->xbow_perf_lock, s);
+	spin_unlock(&xbow_soft->xbow_perf_lock);
 	return -1;
     }
     for (i = 0; i < XBOW_PERF_COUNTERS; i++) {
@@ -1156,7 +1106,7 @@
 	    continue;
 	if (((xbow_perf + i)->xp_link = link) &&
 	    ((xbow_perf + i)->xp_mode)) {
-	    mutex_spinunlock(&xbow_soft->xbow_perf_lock, s);
+	    spin_unlock(&xbow_soft->xbow_perf_lock);
 	    return -1;
 	}
     }
@@ -1174,7 +1124,7 @@
     *(xbowreg_t *) xbow_perf->xp_perf_reg = perf_reg.xb_counter_val;
     xbow_perf->xp_current = perf_reg.xb_perf.count;
 
-    mutex_spinunlock(&xbow_soft->xbow_perf_lock, s);
+    spin_unlock(&xbow_soft->xbow_perf_lock);
     return 0;
 }
 
@@ -1262,15 +1212,10 @@
     xbow_t                 *xbow;
     xbowreg_t               ctrl;
     xbwX_stat_t             stat;
-    unsigned                itick;
+    unsigned long           itick;
     unsigned                dtick;
-    static int              ticks_per_ms = 0;
+    static long             ticks_to_wait = HZ / 1000;
 
-    if (!ticks_per_ms) {
-	itick = get_timestamp();
-	us_delay(1000);
-	ticks_per_ms = get_timestamp() - itick;
-    }
     widget_info = xwidget_info_get(xconn_vhdl);
     port = xwidget_info_id_get(widget_info);
 
@@ -1296,16 +1241,16 @@
      */
     ctrl = xbow->xb_link(port).link_control;
     xbow->xb_link(port).link_reset = 0;
-    itick = get_timestamp();
+    itick = jiffies;
     while (1) {
 	stat.linkstatus = xbow->xb_link(port).link_status;
 	if (stat.link_alive)
 	    break;
-	dtick = get_timestamp() - itick;
-	if (dtick > ticks_per_ms) {
+	dtick = jiffies - itick;
+	if (dtick > ticks_to_wait) {
 	    return -1;			/* never came out of reset */
 	}
-	DELAY(2);			/* don't beat on link_status */
+	udelay(2);			/* don't beat on link_status */
     }
     xbow->xb_link(port).link_control = ctrl;
     return 0;
@@ -1379,7 +1324,6 @@
     xbow_soft_t             soft = xbow_soft_get(vhdl);
     volatile xbowreg_t     *xreg;
     xbowreg_t               mask;
-    unsigned long           s;
     int                     error = 0;
     bandwidth_t             old_bw_BYTES, req_bw_BYTES;
     xbowreg_t               old_xreg;
@@ -1393,7 +1337,7 @@
     ASSERT(XBOW_WIDGET_IS_VALID(src_wid));
     ASSERT(XBOW_WIDGET_IS_VALID(dest_wid));
 
-    s = mutex_spinlock(&soft->xbow_bw_alloc_lock);
+    spin_lock(&soft->xbow_bw_alloc_lock);
 
     /* Get pointer to the correct register */
     xreg = XBOW_PRIO_ARBREG_PTR(soft->base, dest_wid, src_wid);
@@ -1444,7 +1388,7 @@
 	error = 1;
     }
 
-    mutex_spinunlock(&soft->xbow_bw_alloc_lock, s);
+    spin_unlock(&soft->xbow_bw_alloc_lock);
 
-    return (error);
+    return error;
 }
