From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 16 Oct 2002 00:15:30 +0000
Subject: [Linux-ia64] Fix RAW dependency introduced by HUGETLB patch
Message-Id: <marc-linux-ia64-105590709805166@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, 
If CONFIG_HUGETLB is not defined, you get a RAW dependency clash in
ivt.S. (2.5.39)


I believe this patch should fix it (but I'm not an IA64 assmebler
language expert!)

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.851   -> 1.852  
#	arch/ia64/kernel/ivt.S	1.10    -> 1.11   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/10/16	peterc@gelato.unsw.edu.au	1.852
# Fix RAW dependency when CONFIG_HUGETLB_PAGE is not defined.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
--- a/arch/ia64/kernel/ivt.S	Wed Oct 16 10:14:27 2002
+++ b/arch/ia64/kernel/ivt.S	Wed Oct 16 10:14:27 2002
@@ -116,8 +116,8 @@
 	;;
 (p8)	dep r25=r18,r25,2,6
 (p8)	shr r22=r22,HPAGE_SHIFT-PAGE_SHIFT
-	;;
 #endif
+	;;
 	cmp.eq p6,p7=5,r17			// is IFA pointing into to region 5?
 	shr.u r18=r22,PGDIR_SHIFT		// get bits 33-63 of the faulting address
 	;;


