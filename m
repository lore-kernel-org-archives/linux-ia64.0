From: Jay Lan <jlan@sgi.com>
Date: Tue, 20 Mar 2007 02:12:44 +0000
Subject: [PATCH] fix an IA64 MCA kdump bug in kdump_init_notifier
Message-Id: <45FF431C.1040607@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------020805090909020503010905"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------020805090909020503010905
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

In my original patch to support MCA in kdump, changes were made to
kdump_init_notifier() of arch/ia64/kernel/crash.c. But one change
was somehow incorrectly modified in 2.6.20 to as below:

>        if ((val == DIE_INIT_MONARCH_ENTER || DIE_INIT_SLAVE_ENTER) &&
>                 nd->sos->rv_rc == 1)
>                return NOTIFY_DONE;

Since DIE_INIT_SLAVE_ENTER is a non-zero value, thus "nd->sos->rv_rc
==1" is always evaluated. The kdump kernel aborted because nd->sos
is NULL in (at least some) MCA cases.

This patch corrects the problem. It was created against 2.6.21-rc4.

Signed-Off-By: Jay Lan <jlan@sgi.com>


--------------020805090909020503010905
Content-Type: text/plain;
 name="mca-fix-in-kdump_init_notifier"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mca-fix-in-kdump_init_notifier"

Index: linux/arch/ia64/kernel/crash.c
===================================================================
--- linux.orig/arch/ia64/kernel/crash.c	2007-03-15 17:20:01.000000000 -0700
+++ linux/arch/ia64/kernel/crash.c	2007-03-19 17:27:42.102401208 -0700
@@ -164,7 +164,7 @@ kdump_init_notifier(struct notifier_bloc
 
 	nd = (struct ia64_mca_notify_die *)args->err;
 	/* Reason code 1 means machine check rendezous*/
-	if ((val == DIE_INIT_MONARCH_ENTER || DIE_INIT_SLAVE_ENTER) &&
+	if ((val == DIE_INIT_MONARCH_ENTER || val == DIE_INIT_SLAVE_ENTER) &&
 		 nd->sos->rv_rc == 1)
 		return NOTIFY_DONE;
 

--------------020805090909020503010905--
