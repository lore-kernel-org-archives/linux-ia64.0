From: Russ Anderson <rja@sgi.com>
Date: Thu, 01 Nov 2007 21:00:04 +0000
Subject: [patch] Clean-up McKinley Errata message
Message-Id: <20071101210004.GA11412@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Clean-up McKinley Errata message

A small clean-up patch.  

No need to print "McKinley Errata 9 workaround not needed; disabling it"
on every non-McKinley Itanium, which at this point is almost all of them.

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 arch/ia64/kernel/patch.c |    3 ---
 1 file changed, 3 deletions(-)

Index: test/arch/ia64/kernel/patch.c
=================================--- test.orig/arch/ia64/kernel/patch.c	2007-10-16 09:19:28.000000000 -0500
+++ test/arch/ia64/kernel/patch.c	2007-11-01 15:28:38.613965920 -0500
@@ -129,9 +129,6 @@ ia64_patch_mckinley_e9 (unsigned long st
 		first_time = 0;
 		if (need_workaround)
 			printk(KERN_INFO "Leaving McKinley Errata 9 workaround enabled\n");
-		else
-			printk(KERN_INFO "McKinley Errata 9 workaround not needed; "
-			       "disabling it\n");
 	}
 	if (need_workaround)
 		return;
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
