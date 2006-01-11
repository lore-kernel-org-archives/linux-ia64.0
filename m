From: Mike Habeck <habeck@sgi.com>
Date: Wed, 11 Jan 2006 22:40:24 +0000
Subject: [PATCH] pass segment
Message-Id: <20060111224024.1129.47007.13037@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bugfix... the altix SN_SAL_IOIF_SLOT_ENABLE & SN_SAL_IOIF_SLOT_DISABLE 
SAL calls need to pass the segment# down

Signed-off-by: Mike Habeck <habeck@sgi.com>


Index: sal_fix/arch/ia64/sn/pci/pcibr/pcibr_provider.c
=================================--- sal_fix.orig/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2006-01-11 11:28:37.243628493 -0600
+++ sal_fix/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2006-01-11 14:23:48.953744738 -0600
@@ -24,13 +24,17 @@
 {
 	struct ia64_sal_retval ret_stuff;
 	uint64_t busnum;
+	u64 segment;
 
 	ret_stuff.status = 0;
 	ret_stuff.v0 = 0;
 
+	segment = soft->pbi_buscommon.bs_persist_segment;
 	busnum = soft->pbi_buscommon.bs_persist_busnum;
-	SAL_CALL_NOLOCK(ret_stuff, (u64) SN_SAL_IOIF_SLOT_ENABLE, (u64) busnum,
-			(u64) device, (u64) resp, 0, 0, 0, 0);
+
+	SAL_CALL_NOLOCK(ret_stuff, (u64) SN_SAL_IOIF_SLOT_ENABLE,
+			(u64) segment, (u64) busnum, (u64) device,
+			(u64) resp, 0, 0, 0);
 
 	return (int)ret_stuff.v0;
 }
@@ -41,14 +45,17 @@
 {
 	struct ia64_sal_retval ret_stuff;
 	uint64_t busnum;
+	u64 segment;
 
 	ret_stuff.status = 0;
 	ret_stuff.v0 = 0;
 
+	segment = soft->pbi_buscommon.bs_persist_segment;
 	busnum = soft->pbi_buscommon.bs_persist_busnum;
+
 	SAL_CALL_NOLOCK(ret_stuff, (u64) SN_SAL_IOIF_SLOT_DISABLE,
-			(u64) busnum, (u64) device, (u64) action,
-			(u64) resp, 0, 0, 0);
+			(u64) segment, (u64) busnum, (u64) device,
+			(u64) action, (u64) resp, 0, 0);
 
 	return (int)ret_stuff.v0;
 }
