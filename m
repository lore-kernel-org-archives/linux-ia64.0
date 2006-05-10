From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Wed, 10 May 2006 16:09:01 +0000
Subject: [patch] Remove SN SAL error handling feature bit that is no longer needed
Message-Id: <200605101609.k4AG92Kn492660@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Remove SN SAL error handling feature bit that is no longer needed

Due to improvements in linux & SAL MCA handling, the 
SAL_ERR_FEAT_MCA_SLV_TO_OS_INIT_SLV error handling features bit 
is no longer needed.  


Signed-off-by: Russ Anderson (rja@sgi.com)

---
 include/asm-ia64/sn/sn_sal.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: test/include/asm-ia64/sn/sn_sal.h
=================================--- test.orig/include/asm-ia64/sn/sn_sal.h	2006-05-10 09:40:49.811364437 -0500
+++ test/include/asm-ia64/sn/sn_sal.h	2006-05-10 09:44:47.407988569 -0500
@@ -346,7 +346,7 @@ ia64_sn_plat_set_error_handling_features
 	ret_stuff.v1 = 0;
 	ret_stuff.v2 = 0;
 	SAL_CALL_REENTRANT(ret_stuff, SN_SAL_SET_ERROR_HANDLING_FEATURES,
-		(SAL_ERR_FEAT_MCA_SLV_TO_OS_INIT_SLV | SAL_ERR_FEAT_LOG_SBES),
+		SAL_ERR_FEAT_LOG_SBES,
 		0, 0, 0, 0, 0, 0);
 
 	return ret_stuff.status;
