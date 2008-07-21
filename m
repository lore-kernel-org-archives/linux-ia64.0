From: Russ Anderson <rja@sgi.com>
Date: Mon, 21 Jul 2008 23:29:13 +0000
Subject: [patch] Add error_recovery_info field to SAL section header
Message-Id: <20080721232912.GA37347@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Add error_recovery_info field to SAL section header

Add the error_recovery_info field to the SAL section header,
as defined in the SAL Spec.

Signed-off-by: Russ Anderson <rja@sgi.com>

---
 include/asm-ia64/sal.h |   15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

Index: linus/include/asm-ia64/sal.h
=================================--- linus.orig/include/asm-ia64/sal.h	2008-07-18 11:32:02.000000000 -0500
+++ linus/include/asm-ia64/sal.h	2008-07-21 18:21:12.699419381 -0500
@@ -337,11 +337,24 @@ typedef struct sal_log_record_header {
 #define sal_log_severity_fatal		1
 #define sal_log_severity_corrected	2
 
+/*
+ * Error Recovery Info (ERI) bit decode.  From SAL Spec section B.2.2 Table B-3
+ * Error Section Error_Recovery_Info Field Definition.
+ */
+#define ERI_NOT_VALID		0x0	/* Error Recovery Field is not valid */
+#define ERI_NOT_ACCESSIBLE	0x30	/* Resource not accessible */
+#define ERI_CONTAINMENT_WARN	0x22	/* Corrupt data propagated */
+#define ERI_UNCORRECTED_ERROR	0x20	/* Uncorrected error */
+#define ERI_COMPONENT_RESET	0x24	/* Component must be reset */
+#define ERI_CORR_ERROR_LOG	0x21	/* Corrected error, needs logging */
+#define ERI_CORR_ERROR_THRESH	0x29	/* Corrected error threshold exceeded */
+
 /* Definition of log section header structures */
 typedef struct sal_log_sec_header {
     efi_guid_t guid;			/* Unique Section ID */
     sal_log_revision_t revision;	/* Major and Minor revision of Section */
-    u16 reserved;
+    u8 error_recovery_info;		/* Platform error recovery status */
+    u8 reserved;
     u32 len;				/* Section length */
 } sal_log_section_hdr_t;
 
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
