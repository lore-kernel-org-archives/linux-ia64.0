From: Keith Owens <kaos@sgi.com>
Date: Tue, 13 May 2003 06:43:28 +0000
Subject: [Linux-ia64] [patch] 2.4.21-rc1 Close rmmod race on ia64
Message-Id: <marc-linux-ia64-105590723705748@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64 is not taking the spinlock that closes the race between module
removal and traversal of exception tables.  It can result in oops when
one cpu takes an exception while another is unloading a module.

Other architectures take this lock.  The patch is almost a cut and
paste from i386, plus it removes a dead variable.

diff -urp 2.4.21-rc1-ia64.orig/arch/ia64/mm/extable.c 2.4.21-rc1-ia64/arch/ia64/mm/extable.c
--- 2.4.21-rc1-ia64.orig/arch/ia64/mm/extable.c	Sat Aug  3 11:07:44 2002
+++ 2.4.21-rc1-ia64/arch/ia64/mm/extable.c	Tue May 13 16:37:30 2003
@@ -38,6 +38,8 @@ search_one_table (const struct exception
 register unsigned long main_gp __asm__("gp");
 #endif
 
+extern spinlock_t modlist_lock;
+
 struct exception_fixup
 search_exception_table (unsigned long addr)
 {
@@ -51,10 +53,11 @@ search_exception_table (unsigned long ad
 		fix.cont = entry->cont + main_gp;
 	return fix;
 #else
-	struct archdata *archdata;
+	unsigned long flags;
 	struct module *mp;
 
 	/* The kernel is the last "module" -- no need to treat it special. */
+	spin_lock_irqsave(&modlist_lock, flags);
 	for (mp = module_list; mp; mp = mp->next) {
 		if (!mp->ex_table_start)
 			continue;
@@ -65,9 +68,10 @@ search_exception_table (unsigned long ad
 					 addr, (unsigned long) archdata->gp);
 		if (entry) {
 			fix.cont = entry->cont + (unsigned long) archdata->gp;
-			return fix;
+			break;
 		}
 	}
+	spin_unlock_irqrestore(&modlist_lock, flags);
 #endif
 	return fix;
 }


