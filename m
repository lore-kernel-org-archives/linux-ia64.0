From: jes@trained-monkey.org (Jes Sorensen)
Date: Wed, 19 Jan 2005 13:51:20 +0000
Subject: [patch] fix PAL_PREFETCH_VISIBILITY call
Message-Id: <16878.26072.590746.880340@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

The following patch fixes the ia64_pal_prefetch_visibility function to
take a transaction type argument for either virtual or physical memory
as specified in the System Architechture Manual page 2:358.

Signed-Off-By: Jes Sorensen <jes@trained-monkey.org>

Cheers,
Jes

--- linux-2.6.10-mm2-vanilla/include/asm-ia64/pal.h	2004-12-24 13:35:01 -08:00
+++ linux-2.6.10-mm2/include/asm-ia64/pal.h	2005-01-19 05:42:53 -08:00
@@ -66,7 +66,7 @@
 #define PAL_CACHE_PROT_INFO	38	/* get i/d cache protection info */
 #define PAL_REGISTER_INFO	39	/* return AR and CR register information*/
 #define PAL_SHUTDOWN		40	/* enter processor shutdown state */
-#define PAL_PREFETCH_VISIBILITY	41
+#define PAL_PREFETCH_VISIBILITY	41	/* Make Processor Prefetches Visible */
 
 #define PAL_COPY_PAL		256	/* relocate PAL procedures and PAL PMI */
 #define PAL_HALT_INFO		257	/* return the low power capabilities of processor */
@@ -1537,11 +1537,25 @@
 	return iprv.status;
 }
 
+/*
+ * PAL_PREFETCH_VISIBILITY transaction types
+ */
+#define PAL_VISIBILITY_VIRTUAL		0
+#define PAL_VISIBILITY_PHYSICAL		1
+
+/*
+ * PAL_PREFETCH_VISIBILITY return codes
+ */
+#define PAL_VISIBILITY_OK		1
+#define PAL_VISIBILITY_OK_REMOTE_NEEDED	0
+#define PAL_VISIBILITY_INVAL_ARG	-2
+#define PAL_VISIBILITY_ERROR		-3
+
 static inline s64
-ia64_pal_prefetch_visibility (void)
+ia64_pal_prefetch_visibility (s64 trans_type)
 {
 	struct ia64_pal_retval iprv;
-	PAL_CALL(iprv, PAL_PREFETCH_VISIBILITY, 0, 0, 0);
+	PAL_CALL(iprv, PAL_PREFETCH_VISIBILITY, trans_type, 0, 0);
 	return iprv.status;
 }
 
