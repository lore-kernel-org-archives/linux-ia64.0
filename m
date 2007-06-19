From: dcn@sgi.com (Dean Nelson)
Date: Tue, 19 Jun 2007 11:26:17 +0000
Subject: [PATCH] change sh_change_coherence oemcall to use nolock
Message-Id: <4677BD59.mailxFEQ11YCNJ@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Change sn_change_coherence's ia64_sal_oemcall to the nolock variety since
PROM does the locking for this function internally.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/include/asm-ia64/sn/sn_sal.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/sn_sal.h	2007-06-19 05:56:35.000000000 -0500
+++ linux-2.6/include/asm-ia64/sn/sn_sal.h	2007-06-19 05:57:54.347924486 -0500
@@ -696,8 +696,8 @@
 sn_change_coherence(u64 *new_domain, u64 *old_domain)
 {
 	struct ia64_sal_retval ret_stuff;
-	ia64_sal_oemcall(&ret_stuff, SN_SAL_COHERENCE, (u64)new_domain,
-			 (u64)old_domain, 0, 0, 0, 0, 0);
+	ia64_sal_oemcall_nolock(&ret_stuff, SN_SAL_COHERENCE, (u64)new_domain,
+				(u64)old_domain, 0, 0, 0, 0, 0);
 	return ret_stuff.status;
 }
 
