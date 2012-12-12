From: Joe Perches <joe@perches.com>
Date: Wed, 12 Dec 2012 18:18:56 +0000
Subject: [TRIVIAL PATCH 07/26] ia64: Convert print_symbol to %pSR
Message-Id: <90df189c061ddc1580efd32a179a9c409967b1d5.1355335227.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1355335227.git.joe@perches.com>
In-Reply-To: <cover.1355335227.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Kosina <trivial@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Use the new vsprintf extension to avoid any possible
message interleaving.

Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/ia64/kernel/process.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 31360cb..f11105a 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -1,4 +1,4 @@
-/*
+ /*
  * Architecture-specific setup.
  *
  * Copyright (C) 1998-2003 Hewlett-Packard Co
@@ -66,7 +66,6 @@ void
 ia64_do_show_stack (struct unw_frame_info *info, void *arg)
 {
 	unsigned long ip, sp, bsp;
-	char buf[128];			/* don't make it so big that it overflows the stack! */
 
 	printk("\nCall Trace:\n");
 	do {
@@ -76,11 +75,9 @@ ia64_do_show_stack (struct unw_frame_info *info, void *arg)
 
 		unw_get_sp(info, &sp);
 		unw_get_bsp(info, &bsp);
-		snprintf(buf, sizeof(buf),
-			 " [<%016lx>] %%s\n"
-			 "                                sp=%016lx bsp=%016lx\n",
-			 ip, sp, bsp);
-		print_symbol(buf, ip);
+		printk(" [<%016lx>] %pSR\n"
+		       "                                sp=%016lx bsp=%016lx\n",
+		       ip, (void *)ip, sp, bsp);
 	} while (unw_unwind(info) >= 0);
 }
 
@@ -116,7 +113,7 @@ show_regs (struct pt_regs *regs)
 	printk("psr : %016lx ifs : %016lx ip  : [<%016lx>]    %s (%s)\n",
 	       regs->cr_ipsr, regs->cr_ifs, ip, print_tainted(),
 	       init_utsname()->release);
-	print_symbol("ip is at %s\n", ip);
+	printk("ip is at %pSR\n", (void *)ip);
 	printk("unat: %016lx pfs : %016lx rsc : %016lx\n",
 	       regs->ar_unat, regs->ar_pfs, regs->ar_rsc);
 	printk("rnat: %016lx bsps: %016lx pr  : %016lx\n",
-- 
1.7.8.112.g3fd21

