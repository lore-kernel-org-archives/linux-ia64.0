From: Takanori Kawano <t-kawano@ebina.hitachi.co.jp>
Date: Tue, 26 Mar 2002 11:11:12 +0000
Subject: [Linux-ia64] [PATCH]fix for double free in efi.c
Message-Id: <marc-linux-ia64-105590701905336@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following is a fix for a double free bug in fs/partitions/efi.c.

--- efi.c	Fri Mar  1 16:59:19 2002
+++ efi.c.fixed	Mon Mar 11 16:34:29 2002
@@ -546,8 +547,8 @@
 
 		*gpt = pgpt;
 		*ptes = pptes;
-		if (agpt)  kfree(agpt);
-		if (aptes) kfree(aptes);
+		if (agpt)   { kfree(agpt); agpt=NULL; }
+		if (aptes)  { kfree(aptes); aptes=NULL; }
 	} /* if primary is valid */
 	else {
 		/* Primary GPT is bad, check the Alternate GPT */
@@ -595,6 +596,8 @@
         if (agpt) {kfree(agpt); agpt = NULL;}
         if (pptes) {kfree(pptes); pptes = NULL;}
         if (aptes) {kfree(aptes); aptes = NULL;}
+        *gpt = NULL;
+        *ptes = NULL;
 	return 0;
 }


This patch is against redhat 2.4.9 kernel and has already 
been reported to redhat Bugzilla.

I suppose why such a serious bug has remained for a long time 
is that the current debug code in slab.c fails to detect 
double free in case the object holded by cpucaches is doubly 
freed.
I think the current debug code should be improved to detect
this case.

---
Takanori Kawano
Hitachi Ltd,
Internet Systems Platform Division
t-kawano@ebina.hitachi.co.jp




