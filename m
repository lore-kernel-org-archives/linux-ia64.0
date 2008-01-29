From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 29 Jan 2008 05:39:43 +0000
Subject: [PATCH] ia64: cleanup header comments in mca related files
Message-Id: <479EBC1F.4020100@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <476B3AF5.7030309@jp.fujitsu.com>
In-Reply-To: <476B3AF5.7030309@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[Refreshed for 2.6.24]

Unified changelog, 80 columns rule, and address form fix.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---
 arch/ia64/kernel/mca.c         |   68 ++++++++++++++++++++++-------------------
 arch/ia64/kernel/mca_asm.S     |   46 +++++++++++++++------------
 arch/ia64/kernel/mca_drv.c     |    2 -
 arch/ia64/kernel/mca_drv.h     |    2 -
 arch/ia64/kernel/mca_drv_asm.S |    2 -
 include/asm-ia64/mca.h         |    6 +--
 include/asm-ia64/mca_asm.h     |    3 +
 7 files changed, 71 insertions(+), 58 deletions(-)

Index: linux-2.6.24/arch/ia64/kernel/mca.c
=================================--- linux-2.6.24.orig/arch/ia64/kernel/mca.c
+++ linux-2.6.24/arch/ia64/kernel/mca.c
@@ -2,61 +2,69 @@
  * File:	mca.c
  * Purpose:	Generic MCA handling layer
  *
- * Updated for latest kernel
  * Copyright (C) 2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * Copyright (C) 2002 Dell Inc.
- * Copyright (C) Matt Domsch (Matt_Domsch@dell.com)
+ * Copyright (C) Matt Domsch <Matt_Domsch@dell.com>
  *
  * Copyright (C) 2002 Intel
- * Copyright (C) Jenna Hall (jenna.s.hall@intel.com)
+ * Copyright (C) Jenna Hall <jenna.s.hall@intel.com>
  *
  * Copyright (C) 2001 Intel
- * Copyright (C) Fred Lewis (frederick.v.lewis@intel.com)
+ * Copyright (C) Fred Lewis <frederick.v.lewis@intel.com>
  *
  * Copyright (C) 2000 Intel
- * Copyright (C) Chuck Fleckenstein (cfleck@co.intel.com)
+ * Copyright (C) Chuck Fleckenstein <cfleck@co.intel.com>
  *
  * Copyright (C) 1999, 2004 Silicon Graphics, Inc.
- * Copyright (C) Vijay Chander(vijay@engr.sgi.com)
+ * Copyright (C) Vijay Chander <vijay@engr.sgi.com>
  *
- * 03/04/15 D. Mosberger Added INIT backtrace support.
- * 02/03/25 M. Domsch	GUID cleanups
+ * Copyright (C) 2006 FUJITSU LIMITED
+ * Copyright (C) Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
  *
- * 02/01/04 J. Hall	Aligned MCA stack to 16 bytes, added platform vs. CPU
- *			error flag, set SAL default return values, changed
- *			error record structure to linked list, added init call
- *			to sal_get_state_info_size().
- *
- * 01/01/03 F. Lewis    Added setup of CMCI and CPEI IRQs, logging of corrected
- *                      platform errors, completed code for logging of
- *                      corrected & uncorrected machine check errors, and
- *                      updated for conformance with Nov. 2000 revision of the
- *                      SAL 3.0 spec.
- * 00/03/29 C. Fleckenstein  Fixed PAL/SAL update issues, began MCA bug fixes, logging issues,
- *                           added min save state dump, added INIT handler.
+ * 2000-03-29 Chuck Fleckenstein <cfleck@co.intel.com>
+ *	      Fixed PAL/SAL update issues, began MCA bug fixes, logging issues,
+ *	      added min save state dump, added INIT handler.
+ *
+ * 2001-01-03 Fred Lewis <frederick.v.lewis@intel.com>
+ *	      Added setup of CMCI and CPEI IRQs, logging of corrected platform
+ *	      errors, completed code for logging of corrected & uncorrected
+ *	      machine check errors, and updated for conformance with Nov. 2000
+ *	      revision of the SAL 3.0 spec.
+ *
+ * 2002-01-04 Jenna Hall <jenna.s.hall@intel.com>
+ *	      Aligned MCA stack to 16 bytes, added platform vs. CPU error flag,
+ *	      set SAL default return values, changed error record structure to
+ *	      linked list, added init call to sal_get_state_info_size().
+ *
+ * 2002-03-25 Matt Domsch <Matt_Domsch@dell.com>
+ *	      GUID cleanups.
+ *
+ * 2003-04-15 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	      Added INIT backtrace support.
  *
  * 2003-12-08 Keith Owens <kaos@sgi.com>
- *            smp_call_function() must not be called from interrupt context (can
- *            deadlock on tasklist_lock).  Use keventd to call smp_call_function().
+ *	      smp_call_function() must not be called from interrupt context
+ *	      (can deadlock on tasklist_lock).
+ *	      Use keventd to call smp_call_function().
  *
  * 2004-02-01 Keith Owens <kaos@sgi.com>
- *            Avoid deadlock when using printk() for MCA and INIT records.
- *            Delete all record printing code, moved to salinfo_decode in user space.
- *            Mark variables and functions static where possible.
- *            Delete dead variables and functions.
- *            Reorder to remove the need for forward declarations and to consolidate
- *            related code.
+ *	      Avoid deadlock when using printk() for MCA and INIT records.
+ *	      Delete all record printing code, moved to salinfo_decode in user
+ *	      space.  Mark variables and functions static where possible.
+ *	      Delete dead variables and functions.  Reorder to remove the need
+ *	      for forward declarations and to consolidate related code.
  *
  * 2005-08-12 Keith Owens <kaos@sgi.com>
- *	      Convert MCA/INIT handlers to use per event stacks and SAL/OS state.
+ *	      Convert MCA/INIT handlers to use per event stacks and SAL/OS
+ *	      state.
  *
  * 2005-10-07 Keith Owens <kaos@sgi.com>
  *	      Add notify_die() hooks.
  *
  * 2006-09-15 Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
- * 	      Add printing support for MCA/INIT.
+ *	      Add printing support for MCA/INIT.
  *
  * 2007-04-27 Russ Anderson <rja@sgi.com>
  *	      Support multiple cpus going through OS_MCA in the same event.
Index: linux-2.6.24/arch/ia64/kernel/mca_asm.S
=================================--- linux-2.6.24.orig/arch/ia64/kernel/mca_asm.S
+++ linux-2.6.24/arch/ia64/kernel/mca_asm.S
@@ -1,24 +1,28 @@
-//
-// assembly portion of the IA64 MCA handling
-//
-// Mods by cfleck to integrate into kernel build
-// 00/03/15 davidm Added various stop bits to get a clean compile
-//
-// 00/03/29 cfleck Added code to save INIT handoff state in pt_regs format, switch to temp
-//		   kstack, switch modes, jump to C INIT handler
-//
-// 02/01/04 J.Hall <jenna.s.hall@intel.com>
-//		   Before entering virtual mode code:
-//		   1. Check for TLB CPU error
-//		   2. Restore current thread pointer to kr6
-//		   3. Move stack ptr 16 bytes to conform to C calling convention
-//
-// 04/11/12 Russ Anderson <rja@sgi.com>
-//		   Added per cpu MCA/INIT stack save areas.
-//
-// 12/08/05 Keith Owens <kaos@sgi.com>
-//		   Use per cpu MCA/INIT stacks for all data.
-//
+/*
+ * File:	mca_asm.S
+ * Purpose:	assembly portion of the IA64 MCA handling
+ *
+ * Mods by cfleck to integrate into kernel build
+ *
+ * 2000-03-15 David Mosberger-Tang <davidm@hpl.hp.com>
+ *		Added various stop bits to get a clean compile
+ *
+ * 2000-03-29 Chuck Fleckenstein <cfleck@co.intel.com>
+ *		Added code to save INIT handoff state in pt_regs format,
+ *		switch to temp kstack, switch modes, jump to C INIT handler
+ *
+ * 2002-01-04 J.Hall <jenna.s.hall@intel.com>
+ *		Before entering virtual mode code:
+ *		 1. Check for TLB CPU error
+ *		 2. Restore current thread pointer to kr6
+ *		 3. Move stack ptr 16 bytes to conform to C calling convention
+ *
+ * 2004-11-12 Russ Anderson <rja@sgi.com>
+ *		Added per cpu MCA/INIT stack save areas.
+ *
+ * 2005-12-08 Keith Owens <kaos@sgi.com>
+ *		Use per cpu MCA/INIT stacks for all data.
+ */
 #include <linux/threads.h>

 #include <asm/asmmacro.h>
Index: linux-2.6.24/arch/ia64/kernel/mca_drv.c
=================================--- linux-2.6.24.orig/arch/ia64/kernel/mca_drv.c
+++ linux-2.6.24/arch/ia64/kernel/mca_drv.c
@@ -3,7 +3,7 @@
  * Purpose:	Generic MCA handling layer
  *
  * Copyright (C) 2004 FUJITSU LIMITED
- * Copyright (C) Hidetoshi Seto (seto.hidetoshi@jp.fujitsu.com)
+ * Copyright (C) 2004 Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
  * Copyright (C) 2005 Silicon Graphics, Inc
  * Copyright (C) 2005 Keith Owens <kaos@sgi.com>
  * Copyright (C) 2006 Russ Anderson <rja@sgi.com>
Index: linux-2.6.24/arch/ia64/kernel/mca_drv.h
=================================--- linux-2.6.24.orig/arch/ia64/kernel/mca_drv.h
+++ linux-2.6.24/arch/ia64/kernel/mca_drv.h
@@ -3,7 +3,7 @@
  * Purpose:	Define helpers for Generic MCA handling
  *
  * Copyright (C) 2004 FUJITSU LIMITED
- * Copyright (C) Hidetoshi Seto (seto.hidetoshi@jp.fujitsu.com)
+ * Copyright (C) 2004 Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
  */
 /*
  * Processor error section:
Index: linux-2.6.24/arch/ia64/kernel/mca_drv_asm.S
=================================--- linux-2.6.24.orig/arch/ia64/kernel/mca_drv_asm.S
+++ linux-2.6.24/arch/ia64/kernel/mca_drv_asm.S
@@ -3,7 +3,7 @@
  * Purpose:     Assembly portion of Generic MCA handling
  *
  * Copyright (C) 2004 FUJITSU LIMITED
- * Copyright (C) Hidetoshi Seto (seto.hidetoshi@jp.fujitsu.com)
+ * Copyright (C) 2004 Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
  */
 #include <linux/threads.h>

Index: linux-2.6.24/include/asm-ia64/mca.h
=================================--- linux-2.6.24.orig/include/asm-ia64/mca.h
+++ linux-2.6.24/include/asm-ia64/mca.h
@@ -3,9 +3,9 @@
  * Purpose:	Machine check handling specific defines
  *
  * Copyright (C) 1999, 2004 Silicon Graphics, Inc.
- * Copyright (C) Vijay Chander (vijay@engr.sgi.com)
- * Copyright (C) Srinivasa Thirumalachar (sprasad@engr.sgi.com)
- * Copyright (C) Russ Anderson (rja@sgi.com)
+ * Copyright (C) Vijay Chander <vijay@engr.sgi.com>
+ * Copyright (C) Srinivasa Thirumalachar <sprasad@engr.sgi.com>
+ * Copyright (C) Russ Anderson <rja@sgi.com>
  */

 #ifndef _ASM_IA64_MCA_H
Index: linux-2.6.24/include/asm-ia64/mca_asm.h
=================================--- linux-2.6.24.orig/include/asm-ia64/mca_asm.h
+++ linux-2.6.24/include/asm-ia64/mca_asm.h
@@ -1,8 +1,9 @@
 /*
  * File:	mca_asm.h
+ * Purpose:	Machine check handling specific defines
  *
  * Copyright (C) 1999 Silicon Graphics, Inc.
- * Copyright (C) Vijay Chander (vijay@engr.sgi.com)
+ * Copyright (C) Vijay Chander <vijay@engr.sgi.com>
  * Copyright (C) Srinivasa Thirumalachar <sprasad@engr.sgi.com>
  * Copyright (C) 2000 Hewlett-Packard Co.
  * Copyright (C) 2000 David Mosberger-Tang <davidm@hpl.hp.com>

