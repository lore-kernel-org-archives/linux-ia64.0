From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 16 Aug 2004 18:31:16 +0000
Subject: Documentation update for ia64_switch_mode_virt
Message-Id: <B05667366EE6204181EABE9C1B1C0EB50405D52F@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Update comments in function ia64_switch_mode_virt() to reflect actual
implementation from recent region 5 init_task bug fix.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- linux-2.6.7/arch/ia64/kernel/head.S.orig	2004-08-16
10:59:55.000000000 -0700
+++ linux-2.6.7/arch/ia64/kernel/head.S	2004-08-16 11:14:10.000000000
-0700
@@ -781,8 +781,7 @@
 
 	// going to virtual
 	//   - for code addresses, set upper bits of addr to
KERNEL_START
-	//   - for stack addresses, set upper 3 bits to 0xe.... Dont
change any of the
-	//     lower bits since we want it to stay identity mapped
+	//   - for stack addresses, copy from input argument
 	movl r18=KERNEL_START
 	dep r3=0,r3,KERNEL_TR_PAGE_SHIFT,64-KERNEL_TR_PAGE_SHIFT
 	dep r14=0,r14,KERNEL_TR_PAGE_SHIFT,64-KERNEL_TR_PAGE_SHIFT

