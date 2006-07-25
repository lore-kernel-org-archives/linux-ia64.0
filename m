From: Zou Nan hai <nanhai.zou@intel.com>
Date: Tue, 25 Jul 2006 23:36:40 +0000
Subject: [Patch] Don't alloc empty frame in ia64_switch_mode_phys
Message-Id: <1153870600.3286.72.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I think ia64_switch_mode_phys and ia64_switch_mode_virt 
does not need to alloc an empty frame. 
An empty frame is required by loadrs but flushrs 
does not need that.

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

--- linux-2.6.18-rc2/arch/ia64/kernel/head.S	2006-07-26 11:30:08.000000000 +0800
+++ linux-2.6.18-rc2-fix/arch/ia64/kernel/head.S	2006-07-26 12:26:00.000000000 +0800
@@ -853,7 +853,6 @@ END(__ia64_init_fpu)
  */
 GLOBAL_ENTRY(ia64_switch_mode_phys)
  {
-	alloc r2=ar.pfs,0,0,0,0
 	rsm psr.i | psr.ic		// disable interrupts and interrupt collection
 	mov r15=ip
  }
@@ -902,7 +901,6 @@ END(ia64_switch_mode_phys)
  */
 GLOBAL_ENTRY(ia64_switch_mode_virt)
  {
-	alloc r2=ar.pfs,0,0,0,0
 	rsm psr.i | psr.ic		// disable interrupts and interrupt collection
 	mov r15=ip
  }




